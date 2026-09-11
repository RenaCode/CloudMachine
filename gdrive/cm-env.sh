#!/bin/bash
# Wspolna konfiguracja dla warstwy Google Drive.
# Kazda wartosc da sie nadpisac zmienna srodowiskowa przed uruchomieniem skryptu.

# rclone z Homebrew jest zbudowany BEZ obslugi mount i odmawia z komunikatem
# "rclone mount is not supported on MacOS when rclone is installed via Homebrew".
# Potrzebna jest oficjalna binarka z rclone.org - patrz install-rclone.sh.
CM_RCLONE="${CM_RCLONE:-$HOME/.cloudmachine/bin/rclone}"

CM_REMOTE="${CM_REMOTE:-gdrive}"                      # nazwa remote'a w rclone.conf
CM_REMOTE_PATH="${CM_REMOTE_PATH:-CloudMachine/mac-studio}"
CM_ROOT="${CM_ROOT:-$HOME/.cloudmachine}"
CM_MOUNT="$CM_ROOT/drive"                             # tu widac zawartosc Drive'a
CM_CACHE="$CM_ROOT/cache"                             # bufor zapisu
CM_LOG="$CM_ROOT/rclone.log"
CM_CACHE_SIZE="${CM_CACHE_SIZE:-100G}"

CM_IMAGE_NAME="${CM_IMAGE_NAME:-mac-studio}"
CM_IMAGE_SIZE="${CM_IMAGE_SIZE:-1500g}"               # rozmiar deklarowany, obraz jest rzadki
CM_VOLNAME="${CM_VOLNAME:-CloudMachine}"
CM_IMAGE="$CM_MOUNT/$CM_IMAGE_NAME.sparsebundle"
# Punkt montowania celu. Domyslnie /Volumes, bo to sciezka, ktora Time Machine
# na pewno przyjmuje.
#
# Cena tego wyboru, zmierzona w poc-pullplug.sh: po nieczystym odpieciu katalog
# /Volumes/<nazwa> zostaje jako osierocony i blokuje ponowne podpiecie
# komunikatem "no mountable file systems". Nalezy do uzytkownika, ale leży
# w /Volumes nalezacym do roota, wiec rmdir odmawia - agent launchd dzialajacy
# jako uzytkownik nie posprzata po sobie sam.
#
# Alternatywa: CM_TARGET="$CM_ROOT/target" - katalog w calosci nasz, wiec
# samonaprawialny. NIEPRZETESTOWANE: nie wiadomo, czy tmutil setdestination
# przyjmie cel spoza /Volumes. Do sprawdzenia, gdy bedzie dostep do sudo.
CM_TARGET="${CM_TARGET:-/Volumes/$CM_VOLNAME}"

# 32 MB na pasmo, podane w sektorach po 512 B. Wybrane pomiarem, nie z palca -
# patrz tabela w README i skrypt poc-amplification.sh.
#
# Dwie sily ciagna w przeciwne strony. Google Drive przepuszcza okolo 2 operacji
# na plik na sekunde, wiec male pasma wydluzaja pierwsza wysylke: 200 GB przy
# 8 MB to ~25 600 plikow i ~3,6 h samych operacji, podczas gdy lacze zrobiloby
# to w ~1,3 h. Z drugiej strony kazda zmiana brudzi cale pasmo, wiec duze pasma
# mnoza transfer przy kazdym przyroscie - zmierzone 768 MB przy 64 MB wobec
# 384 MB przy 8 MB na te same 300 MB realnej zmiany.
#
# 32 MB to punkt, w ktorym pierwsza wysylka przestaje byc ograniczona tempem
# operacji (6 400 plikow, ~0,9 h) i zaczyna byc ograniczona pasmem lacza.
# Powyzej tego progu placi sie wiekszym transferem za korzysc, ktorej juz nie ma.
#
# Zmiana dziala tylko przy tworzeniu obrazu - pozniej wymaga backupu od zera.
CM_BAND_SECTORS="${CM_BAND_SECTORS:-65536}"

cm_is_mounted() {
  /sbin/mount | grep -q " on $CM_MOUNT "
}

cm_is_attached() {
  [ -d "$CM_TARGET" ] && /sbin/mount | grep -q " on $CM_TARGET "
}

# Zwraca urzadzenia /dev/diskN podpiete pod wskazany obraz.
#
# Po wymuszonym odpieciu urzadzenie potrafi zostac w systemie jako zombie.
# Ponowne podpiecie obrazu konczy sie wtedy bledem "no mountable file systems",
# albo - gorzej - zwraca martwy uchwyt, na ktorym fsck_apfs melduje
# "failed to read container superblock" i wyglada to jak utrata backupu.
cm_devices_for_image() {
  hdiutil info | awk -v img="$1" '
    /^image-path/ { sub(/^image-path[ \t]*:[ \t]*/, ""); path = $0; next }
    /^\/dev\/disk[0-9]+[ \t]/ { if (path == img) print $1 }
  ' | sort -u
}

cm_purge_stale_devices() {
  local img="$1" d
  for d in $(cm_devices_for_image "$img"); do
    hdiutil detach "$d" -force -quiet 2>/dev/null || true
  done
}

CM_RC_URL="${CM_RC_URL:-127.0.0.1:5572}"

# Czy rclone skonczyl wysylke. Pusta kolejka to warunek, pod ktorym operacje
# hdiutil na tym montowaniu sa stabilne - patrz nizej.
cm_vfs_quiet() {
  local out
  out="$("$CM_RCLONE" rc --url "$CM_RC_URL" vfs/stats 2>/dev/null)" || return 1
  local busy
  busy="$(printf '%s' "$out" | awk -F: '/uploadsInProgress|uploadsQueued/ {gsub(/[^0-9]/,"",$2); s+=$2} END {print s+0}')"
  [ "$busy" = "0" ]
}

# Czeka, az wysylka ucichnie. Bez tego hdiutil bywa odrzucany.
cm_wait_quiet() {
  local limit="${1:-120}" i=0
  while [ "$i" -lt "$limit" ]; do
    cm_vfs_quiet && return 0
    i=$((i + 1)); sleep 1
  done
  return 1
}

# Ponawia polecenie. Operacje hdiutil na montowaniu FUSE-T zawodza przejsciowo
# bledem "RPC version wrong", gdy rclone akurat wysyla albo kasuje dane.
# Zmierzone: przy pustej kolejce 5 prob na 5 udanych, przy zajetej - losowo.
# To nie jest blad zalezny od rozmiaru ani od danych, tylko od chwili.
cm_retry() {
  local tries="$1"; shift
  local i=1
  while :; do
    if "$@"; then return 0; fi
    [ "$i" -ge "$tries" ] && return 1
    echo "  proba $i nieudana, ponawiam za 5 s..." >&2
    i=$((i + 1)); sleep 5
    cm_wait_quiet 60 || true
  done
}
