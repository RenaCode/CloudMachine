#!/bin/bash
# Montuje folder tej maszyny z Google Drive jako lokalny wolumin, gotowy do
# wskazania jako cel Time Machine.
#
# Uzywamy `rclone nfsmount`, NIE `rclone mount` - Homebrew'owy rclone na macOS
# jest budowany bez wsparcia FUSE (`rclone mount` konczy sie od razu bledem
# "not supported on MacOS when rclone is installed via Homebrew"). `nfsmount`
# to wbudowany w rclone serwer NFS, ktory macOS montuje swoim natywnym
# klientem NFS - bez FUSE-T/macFUSE i bez zadnego instalatora proszacego o sudo.

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ./common.sh

cm_require_config
cm_require_jq

REMOTE_NAME="$(cm_remote_name)"
MACHINE_KEY="$(cm_machine_key)"
REMOTE_PATH="$(cm_remote_path_for "$MACHINE_KEY")"
LOCAL_DIR="$(cm_local_machine_mount_dir "$MACHINE_KEY")"
SP_MOUNT="$(cm_sparsebundle_mount_dir "$MACHINE_KEY")"

VFS_CACHE_MAX_SIZE="${CM_VFS_CACHE_MAX_SIZE:-40G}"
# Wartosci dobrane i sprawdzone w praktyce (wielogodzinny test na zywym
# koncie z WLASNYM, prywatnym client_id - patrz sekcja "Wlasny client_id
# Google" w README) - zero throttlingu/bledow 403/429 nawet przy tym
# poziomie. WAZNE: to sa tez wartosci, ktorych uzyje KAZDA automatyczna
# naprawa mount-watchdog.sh (wywoluje mount.sh bez zadnych wlasnych zmiennych
# CM_RCLONE_*), wiec musza tu byc na stale, a nie tylko przekazywane recznie
# przy pojedynczym wywolaniu - inaczej auto-naprawa cicho cofa sie do
# duzo wolniejszych ustawien bez ostrzezenia. Jesli nadal uzywasz
# DZIELONEGO (domyslnego) client_id rclone, obnizyc przez
# CM_RCLONE_TRANSFERS/CM_RCLONE_CHECKERS/CM_RCLONE_TPSLIMIT (patrz README).
RCLONE_TRANSFERS="${CM_RCLONE_TRANSFERS:-32}"
RCLONE_CHECKERS="${CM_RCLONE_CHECKERS:-32}"
RCLONE_TPSLIMIT="${CM_RCLONE_TPSLIMIT:-50}"
RCLONE_VFS_WRITE_BACK="${CM_RCLONE_VFS_WRITE_BACK:-5s}"
# --poll-interval sluzy do wykrywania zmian zrobionych na remote Z ZEWNATRZ
# (np. przez inne urzadzenie) - u nas nic innego nie pisze do tego folderu,
# wiec ta funkcja jest niepotrzebna, a przy bardzo czesto nadpisywanych
# malych plikach metadanych sparsebundle (bitmapa alokacji, Info.plist)
# moze aktywnie szkodzic: rclone porownuje lokalny cache ze stanem remote co
# CM_RCLONE_POLL_INTERVAL, a Google Drive API bywa chwilowo niespojne zaraz
# po uploadzie (swiezo wyslany plik jeszcze "nie dojrzal" po stronie
# Google) - rclone widzi wtedy falszywa roznice, kasuje swoj wlasnie
# zapisany lokalny cache jako "stale", i kolejny odczyt tego samego pliku
# (ktory TM robi natychmiast potem) dostaje niespojne dane. Domyslnie
# wylaczone (0 = brak pollingu) wlasnie zeby wyeliminowac ten wyscig.
RCLONE_POLL_INTERVAL="${CM_RCLONE_POLL_INTERVAL:-0}"

if ! cm_acquire_lock "mount-${MACHINE_KEY}"; then
  cm_log "Inna instancja mount.sh dla tej maszyny juz dziala, pomijam ten przebieg."
  exit 0
fi

mkdir -p "$LOCAL_DIR"

# Sprawdzamy czy woluminy są już zamontowane
NFS_MNT=0
SP_MNT=0

if mount | grep -q "$LOCAL_DIR"; then
  NFS_MNT=1
fi
if mount | grep -q "$SP_MOUNT"; then
  SP_MNT=1
fi

if [ "$NFS_MNT" = "1" ] && [ "$SP_MNT" = "1" ]; then
  cm_log "Zarowno wolumin NFS jak i wirtualny dysk sparsebundle sa juz zamontowane."
  exit 0
fi

# 1. Sprawdzamy, czy wirtualny dysk (sparsebundle) istnieje na zdalnym dysku Google Drive.
# Robimy to za pomocą rclone lsf PRZED montowaniem NFS, aby uniknąć problemów z cache
# oraz wyeliminować potrzebę zapisu plików konfiguracyjnych bezpośrednio przez NFS (błędy O_EXCL).
SP_EXISTS=0
if rclone lsf "${REMOTE_PATH}/backup.sparsebundle" >/dev/null 2>&1; then
  SP_EXISTS=1
fi

if [ "$SP_EXISTS" = "0" ]; then
  limit_gb="$(cm_machine_limit_gb "$MACHINE_KEY")"
  cm_log "Brak sparsebundle w chmurze. Tworze i przesylam nowy wirtualny dysk (limit ${limit_gb} GB)..."
  
  # Tworzymy dysk lokalnie w katalogu tymczasowym
  tmp_sp="/tmp/cm-temp-${MACHINE_KEY}.sparsebundle"
  rm -rf "$tmp_sp"
  hdiutil create -size "${limit_gb}g" -fs APFS -volname "CloudMachine-Backup-${MACHINE_KEY}" -type SPARSEBUNDLE "$tmp_sp"
  
  # Przesyłamy bezpośrednio na Google Drive za pomocą rclone copy
  cm_log "Przesylam sparsebundle bezposrednio na Dysk Google (bypassing NFS)..."
  rclone copy "$tmp_sp" "${REMOTE_PATH}/backup.sparsebundle"
  rm -rf "$tmp_sp"
  cm_log "Wirtualny dysk zostal przeslany do chmury."

  # `--vfs-cache-mode full` trzyma cache NA DYSKU (nie tylko w pamieci) i
  # przezywa restart procesu rclone - jesli backup.sparsebundle pod tą samą
  # sciezką kiedys juz istniał (np. zostal usuniety i tworzymy go tutaj od
  # nowa), stary cache nadal zawiera "stare" wersje Info.plist/bandow. Kiedy
  # potem hdiutil czyta ten obszar przez NFS, rclone w trakcie odczytu
  # wykrywa niezgodnosc ("remote is different") i podmienia zawartosc w
  # locie - hdiutil dostaje wtedy niespojne dane w polowie odczytu i konczy
  # sie to "no mountable file systems", mimo ze swiezo przeslany plik jest
  # calkowicie poprawny. Czyscimy wiec ten konkretny cache PRZED
  # zamontowaniem NFS, zeby pierwszy odczyt byl od razu spojny.
  RCLONE_CACHE_DIR="$(rclone config paths 2>/dev/null | awk -F': *' '/Cache dir/ {print $2}')"
  if [ -n "$RCLONE_CACHE_DIR" ]; then
    rm -rf "${RCLONE_CACHE_DIR}/vfs/${REMOTE_NAME}/$(cm_remote_root_folder)/${MACHINE_KEY}/backup.sparsebundle"
    rm -rf "${RCLONE_CACHE_DIR}/vfsMeta/${REMOTE_NAME}/$(cm_remote_root_folder)/${MACHINE_KEY}/backup.sparsebundle"
  fi
fi

# 2. Montujemy wolumin NFS (jeśli nie jest zamontowany)
MOUNT_ARGS=(
  "$REMOTE_PATH" "$LOCAL_DIR"
  --volname "CloudMachine-${MACHINE_KEY}"
  --vfs-cache-mode full
  --vfs-cache-max-size "$VFS_CACHE_MAX_SIZE"
  --vfs-cache-max-age 72h
  --vfs-write-back "$RCLONE_VFS_WRITE_BACK"
  --dir-cache-time 1h
  --poll-interval "$RCLONE_POLL_INTERVAL"
  --tpslimit "$RCLONE_TPSLIMIT"
  --transfers "$RCLONE_TRANSFERS"
  --checkers "$RCLONE_CHECKERS"
  --log-level INFO
  --log-file "$CM_LOG_DIR/rclone-mount.log"
  -o "nolocks,locallocks"
)

# Funkcja pomocnicza do montowania sparsebundle
mount_sparsebundle() {
  local sp_path="$LOCAL_DIR/backup.sparsebundle"
  if mount | grep -q "$SP_MOUNT"; then
    return 0
  fi
  cm_log "Montuje wirtualny dysk sparsebundle pod $SP_MOUNT..."
  # Zaraz po swiezym zamontowaniu NFS katalog-cache rclone (VFS) bywa jeszcze
  # "zimny" - pierwsze zapytanie o listing folderu (ktorego hdiutil potrzebuje,
  # zeby w ogole "zobaczyc" backup.sparsebundle) moze wymagac realnego
  # zapytania do Google Drive i chwile potrwac, wiec proba pierwsza moze
  # dostac "No such file or directory" mimo ze plik na pewno tam jest.
  for attempt in 1 2 3; do
    # Używamy -noverify oraz -noautoopen, aby montowanie przez sieć było natychmiastowe i bezproblemowe
    if hdiutil attach -noverify -noautoopen -nobrowse -mountpoint "$SP_MOUNT" "$sp_path" 2>>"$CM_LOG_DIR/cloudmachine.log"; then
      return 0
    fi
    if [ "$attempt" -lt 3 ]; then
      cm_log "Proba $attempt montowania sparsebundle nie powiodla sie (mozliwe zimne dir-cache po swiezym mouncie), ponawiam za 3s..."
      sleep 3
    fi
  done

  # UWAGA: celowo NIE czyscimy tu lokalnego cache VFS jako "ostatniej deski
  # ratunku" (wczesniejsza wersja to robila) - w tym miejscu w cache moga
  # lezec realne, jeszcze nie przeslane na Google Drive fragmenty AKTYWNEGO
  # backupu Time Machine (bandy oczekujace w kolejce na upload). Skasowanie
  # ich obcieloby prawdziwe dane backupu, nie tylko "stary, nieaktualny
  # cache". Bezpieczne czyszczenie cache robimy WYLACZNIE zaraz po tym, jak
  # SAMI dopiero co utworzylismy i przeslalismy zupelnie nowy sparsebundle
  # (patrz sekcja "Brak sparsebundle w chmurze" wyzej) - tam nie ma szans na
  # kolizje z czyimis oczekujacymi uploadami, bo plik dopiero co powstal.
  return 1
}

# Zawsze montujemy w trybie tla (--daemon), niezaleznie od tego czy wywoluje
# nas GUI/CLI czy launchd. Kiedys istnial tu odrebny "CM_FOREGROUND=1" tryb
# dla launchd, ktory robil `exec rclone nfsmount` i zyl jako drugi, niezalezny
# proces obok tego wywolywanego z przycisku "Zamontuj" w apce. Oba montowaly
# ten sam katalog: kazde uruchomienie tego skryptu ubijalo "osierocony"
# proces rclone dla tego samego REMOTE_PATH ponizej, co w praktyce ubijalo
# ZDROWY mount tego drugiego procesu w trakcie pracy - to bylo realne zrodlo
# opisywanego "serwer nie odpowiada" -> "trzeba odlaczyc" -> zawieszenia.
# Teraz istnieje dokladnie jedna droga tworzenia procesu rclone nfsmount
# (ponizej); ciagle dzialajacy nadzor to osobny scripts/mount-watchdog.sh
# odpalany cyklicznie przez launchd, ktory naprawia TYLKO realnie niezdrowe
# mounty (patrz tamten plik), zamiast trzymac wlasny, rownolegly proces rclone.
MOUNT_OK=0
if [ "$NFS_MNT" = "1" ]; then
  MOUNT_OK=1
else
  # Sprzątanie ewentualnych osieroconych procesów - ale TYLKO jesli naprawde
  # sa osierocone (martwe/zawieszone), a NIE jesli po prostu aktywnie dogania
  # zalegla kolejke uploadow po przerwanym w polowie backupie (rclone celowo
  # NIE uruchamia serwera NFS, dopoki nie przetworzy calej takiej kolejki -
  # to udokumentowane zachowanie rclone, nie usterka). Zabicie takiego
  # procesu resetuje postep do zera i przy duzej kolejce moze skutecznie
  # UNIEMOZLIWIC montowanie na zawsze, jesli cos (np. ten sam watchdog) robi
  # to w kolko - dokladnie to zaobserwowalismy przy realnym przerwanym
  # backupie.
  already_running=0
  if cm_rclone_busy_draining "$REMOTE_PATH" 45; then
    cm_log "Istniejacy proces rclone dla tego remote wciaz aktywnie pracuje (prawdopodobnie dogania zalegla kolejke) - NIE ubijam, czekam na niego zamiast startowac nowy."
    already_running=1
  else
    cm_kill_rclone_for_remote "$REMOTE_PATH"
    cm_force_unmount "$LOCAL_DIR" 10 || true
  fi

  cm_log "Montuje $REMOTE_PATH -> $LOCAL_DIR (vfs-cache-mode=full, cache max=$VFS_CACHE_MAX_SIZE)"

  for attempt in 1 2; do
    if [ "$already_running" = "1" ] || rclone nfsmount "${MOUNT_ARGS[@]}" --daemon; then
      # Czekamy na pojawienie sie NFS w tabeli mount BEZ sztywnego limitu
      # czasu, dopoki rclone realnie cos robi (log rosnie w ostatnich 45s) -
      # dogonienie duzej zaleglej kolejki uploadow po przerwanym backupie
      # moze legalnie trwac znacznie dluzej niz 10 minut (patrz README).
      # Wczesniejsza wersja miala tu twardy limit 600s, ktory - jesli
      # drenowanie akurat trwalo dluzej - ubijal AKTYWNIE PRACUJACY proces
      # rclone w kroku "Proba $attempt nie powiodla sie" ponizej, zerujac
      # postep; to dokladnie ten sam blad, przed ktorym ostrzega komentarz
      # przy cm_kill_rclone_for_remote powyzej. Przerywamy WYLACZNIE gdy
      # rclone naprawde ucichnie (>45s bez postepu) - to jedyny wiarygodny
      # sygnal, ze faktycznie utknelo, a nie tylko wciaz pracuje.
      waited=0
      while true; do
        if mount | grep -q "$LOCAL_DIR"; then
          MOUNT_OK=1
          break 2
        fi
        if [ "$waited" -ge 10 ] && ! cm_rclone_busy_draining "$REMOTE_PATH" 45; then
          cm_log "Proba $attempt: rclone przestal robic postepy (brak aktywnosci w logu >45s) po ${waited}s oczekiwania - przerywam ta probe."
          break
        fi
        sleep 5
        waited=$((waited + 5))
      done
    fi
    already_running=0
    if [ "$attempt" -eq 1 ]; then
      cm_log "Proba $attempt nie powiodla sie, sprzatam i probuje ponownie..."
      cm_force_unmount "$LOCAL_DIR" 10 || true
      cm_kill_rclone_for_remote "$REMOTE_PATH"
      sleep 1
      if ! mount | grep -q "$LOCAL_DIR"; then
        mv "$LOCAL_DIR" "${LOCAL_DIR}-zaklinowany-$(date +%s)" 2>/dev/null || true
        mkdir -p "$LOCAL_DIR"
      fi
      sleep 1
    fi
  done
fi

if [ "$MOUNT_OK" = "1" ]; then
  cm_log "NFS gotowy, montuje wirtualny dysk..."
  mount_sparsebundle
  cm_log "Narzędzie CloudMachine gotowe do pracy."
  # Zapamietujemy, ze uzytkownik CHCE miec dysk zamontowany - mount-watchdog.sh
  # bedzie odtad pilnowal, zeby tak zostalo, az do jawnego unmount.sh.
  cm_set_mount_desired "on"
  # Blokujemy sen systemowy na caly czas trwania (patrz komentarz przy
  # cm_start_caffeinate w common.sh) - inaczej Mac usypia w przerwach miedzy
  # proba a nastepna i budzi sie z polamanym mountem.
  cm_start_caffeinate
else
  cm_log "BLAD: montowanie nie powiodlo sie po 2 probach. Ostatnie linie logu:"
  tail -n 10 "$CM_LOG_DIR/rclone-mount.log" 2>/dev/null | while IFS= read -r line; do cm_log "  $line"; done
  exit 1
fi
