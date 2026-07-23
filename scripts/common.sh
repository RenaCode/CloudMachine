#!/bin/bash
# Wspolne funkcje uzywane przez skrypty CloudMachine.
# Zaklada, ze jq jest zainstalowany (instaluje go install.sh).

set -euo pipefail

CM_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CM_CONFIG="${CM_CONFIG:-$CM_ROOT/config/machines.json}"
CM_LOG_DIR="${CM_LOG_DIR:-$HOME/Library/Logs/CloudMachine}"
CM_MOUNT_POINT="${CM_MOUNT_POINT:-$HOME/CloudMachine-Mount}"

mkdir -p "$CM_LOG_DIR"

cm_log() {
  local msg="$1"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $msg" | tee -a "$CM_LOG_DIR/cloudmachine.log"
}

cm_require_config() {
  if [ ! -f "$CM_CONFIG" ]; then
    cm_log "BLAD: brak pliku konfiguracyjnego $CM_CONFIG. Skopiuj config/machines.example.json -> config/machines.json i uzupelnij."
    exit 1
  fi
}

cm_require_jq() {
  if ! command -v jq >/dev/null 2>&1; then
    cm_log "BLAD: brak 'jq'. Zainstaluj: brew install jq (albo uruchom scripts/install.sh)."
    exit 1
  fi
}

# Zwraca klucz tej maszyny w config/machines.json.
# Domyslnie dopasowuje po nazwie komputera (scutil --get ComputerName, znormalizowanej),
# mozna nadpisac zmienna srodowiskowa CM_MACHINE_KEY.
cm_machine_key() {
  if [ -n "${CM_MACHINE_KEY:-}" ]; then
    echo "$CM_MACHINE_KEY"
    return
  fi
  scutil --get ComputerName 2>/dev/null | tr '[:upper:] ' '[:lower:]-' | tr -cd '[:alnum:]-'
}

cm_remote_name() {
  cm_require_jq
  jq -r '.remote_name' "$CM_CONFIG"
}

cm_remote_root_folder() {
  cm_require_jq
  jq -r '.remote_root_folder' "$CM_CONFIG"
}

cm_machine_limit_gb() {
  local key="$1"
  cm_require_jq
  local limit
  limit=$(jq -r --arg k "$key" '.machines[$k].limit_gb // empty' "$CM_CONFIG")
  if [ -z "$limit" ]; then
    cm_log "BLAD: maszyna '$key' nie jest zdefiniowana w $CM_CONFIG (sekcja machines)."
    exit 1
  fi
  echo "$limit"
}

# Sciezka na remote dla tej maszyny, np. gdrive-cloudmachine:CloudMachine/macbook-pro-marcin
cm_remote_path_for() {
  local key="$1"
  echo "$(cm_remote_name):$(cm_remote_root_folder)/$key"
}

cm_local_machine_mount_dir() {
  local key="$1"
  echo "$CM_MOUNT_POINT/$key"
}

cm_sparsebundle_mount_dir() {
  local key="$1"
  echo "/Volumes/CloudMachine-Backup-$key"
}

# "Stan pozadany" montowania - czy uzytkownik CHCE miec dysk zamontowany.
# Ustawiane przez mount.sh (sukces -> "on") i unmount.sh ("off"), czytane
# przez mount-watchdog.sh: watchdog nigdy nie montuje niczego z wlasnej
# inicjatywy, tylko UTRZYMUJE stan, ktory user ostatnio jawnie wybral -
# inaczej wracalby wbrew woli uzytkownika po recznym "Odmontuj".
cm_mount_desired_state_file() {
  echo "$(dirname "$CM_CONFIG")/mount-desired.state"
}

cm_set_mount_desired() {
  local state="$1"
  local f
  f="$(cm_mount_desired_state_file)"
  mkdir -p "$(dirname "$f")"
  echo "$state" > "$f"
}

cm_mount_desired() {
  local f
  f="$(cm_mount_desired_state_file)"
  if [ -f "$f" ]; then
    cat "$f"
  else
    echo "off"
  fi
}

# `backupd` sam trzyma asercje "PreventUserIdleSystemSleep" WYLACZNIE podczas
# aktywnego kopiowania - w przerwach miedzy proba a nastepna (np. gdy TM
# padnie z bledem i czeka az backup-watchdog.sh je wznowi) nic nie blokuje
# snu z bezczynnosci. Zaobserwowany na zywo efekt: Mac zasypia w takiej
# przerwie, budzi sie z polamanym mountem/polaczeniami sieciowymi, kolejna
# proba backupu natychmiast pada, powstaje kolejna przerwa, Mac znowu
# zasypia - blad w kolko. `caffeinate -s` blokuje sen systemowy (na zasilaniu
# AC) niezaleznie od tego, czy backupd akurat w danej sekundzie kopiuje, wiec
# trzymamy go przez caly czas trwania "mount_desired=on", nie tylko podczas
# pojedynczych sesji backupu.
cm_caffeinate_pid_file() {
  echo "$CM_LOG_DIR/.caffeinate.pid"
}

cm_start_caffeinate() {
  local pid_file
  pid_file="$(cm_caffeinate_pid_file)"
  if [ -f "$pid_file" ]; then
    local pid
    pid="$(cat "$pid_file" 2>/dev/null)"
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
      return 0
    fi
  fi
  nohup caffeinate -s >/dev/null 2>&1 &
  disown 2>/dev/null
  echo "$!" > "$pid_file"
}

cm_stop_caffeinate() {
  local pid_file
  pid_file="$(cm_caffeinate_pid_file)"
  if [ -f "$pid_file" ]; then
    local pid
    pid="$(cat "$pid_file" 2>/dev/null)"
    [ -n "$pid" ] && kill "$pid" 2>/dev/null
    rm -f "$pid_file"
  fi
}

# Ubija istniejace procesy 'rclone nfsmount' dla danej sciezki remote.
# Najpierw TERM (grzecznie, zeby rclone zdazyl posprzatac swoj serwer NFS),
# a jesli po kilku sekundach proces nadal zyje (np. utknal w nieudanej
# probie odmontowania NFS - patrz komentarz w mount-watchdog.sh), dobija KILL.
cm_kill_rclone_for_remote() {
  local remote_path="$1"
  local pattern="rclone nfsmount ${remote_path} "
  if ! pgrep -f "$pattern" >/dev/null 2>&1; then
    return 0
  fi
  cm_log "Ubijam istniejace procesy 'rclone nfsmount' dla ${remote_path}..."
  pkill -TERM -f "$pattern" 2>/dev/null || true
  for _ in 1 2 3 4 5; do
    pgrep -f "$pattern" >/dev/null 2>&1 || return 0
    sleep 1
  done
  cm_log "Proces nie zareagowal na TERM w 5s, wysylam KILL."
  pkill -KILL -f "$pattern" 2>/dev/null || true
}

# Zwraca "prawda" (0), jesli proces rclone nfsmount dla danego remote ZYJE i
# jego log rosl w ciagu ostatnich `quiet_threshold` sekund - czyli realnie
# COS ROBI, mimo ze wolumin NFS jeszcze sie nie pojawil w tabeli `mount`.
#
# Powod: rclone (potwierdzone tez w dokumentacji/na forum rclone) NIE
# uruchamia swojego serwera NFS, dopoki najpierw nie przetworzy calej
# zaleglej kolejki uploadow z lokalnego cache (`--vfs-cache-mode full`) - po
# przerwanym w polowie backupie Time Machine ta kolejka moze miec setki
# pozycji i naturalnie zajmuje to dlugo. To NIE jest zawieszenie - to rclone
# w trakcie pracy. Watchdog nie powinien wtedy ubijac tego procesu (widzielismy
# to bezposrednio: powtarzajace sie ubicie w takiej sytuacji NIGDY nie
# pozwala kolejce sie skonczyc, bo kazdy restart zaczyna odliczanie od nowa).
#
# Prawdziwe zawieszenie (np. rclone utknal wewnetrznie, zero postepu) wyglada
# INACZEJ: proces zyje, ale jego log przestaje rosnac na dobre - to jest
# sygnal, ktorego uzywa ta funkcja.
cm_rclone_busy_draining() {
  local remote_path="$1"
  local quiet_threshold="${2:-45}"
  pgrep -f "rclone nfsmount ${remote_path} " >/dev/null 2>&1 || return 1
  local log_file="$CM_LOG_DIR/rclone-mount.log"
  [ -f "$log_file" ] || return 1
  local mtime now age
  mtime="$(stat -f %m "$log_file" 2>/dev/null || echo 0)"
  now="$(date +%s)"
  age=$((now - mtime))
  [ "$age" -lt "$quiet_threshold" ]
}

# Sprawdza, czy katalog faktycznie ODPOWIADA (a nie tylko figuruje w tabeli
# `mount`) - zawieszony serwer NFS dalej tam wisi, ale kazda operacja I/O na
# nim blokuje sie w nieskonczonosc (i to w nieprzerywalnym oczekiwaniu w
# jadrze - nawet `kill -9` na taki proces nie dziala, dopoki jadro nie dostanie
# odpowiedzi z serwera albo mount nie zostanie wymuszony do odmontowania).
#
# Uzywamy `stat` na SAMYM katalogu (getattr), NIE `ls`/readdir na jego
# zawartosci - readdir na korzeniu mountu (gdzie lezy backup.sparsebundle)
# wymaga od rclone realnego wylistowania folderu z Google Drive za kazdym
# razem, gdy vfs dir-cache jest zimny (a jest zimny po kazdym ponownym
# zamontowaniu - czyli akurat po kazdej naprawie tego watchdoga!). To
# tworzylo samonapedzajaca sie petle: zimny cache -> wolne readdir -> false
# positive "zawieszone" -> kolejny remount -> znowu zimny cache. `stat`
# samego punktu montowania to tanie zapytanie o atrybuty, ktore nie zalezy
# od tego, ile plikow jest w folderze ani czy trzeba je wylistowac z API.
#
# Probe odpalamy w tle i NIGDY na niego nie czekamy (`wait`) - po prostu
# odpytujemy plik-znacznik przez maksymalnie `timeout_s` sekund. Jesli sie
# nie pojawi, uznajemy katalog za niezdrowy i wracamy od razu - a osierocony
# probe kiedys sam dokonczy (lub przepadnie razem z force-unmount).
cm_probe_responsive() {
  local dir="$1"
  local timeout_s="${2:-6}"
  local marker
  marker="$(mktemp -u "${TMPDIR:-/tmp}/cm-probe.XXXXXX")"
  ( /usr/bin/stat -f "%N" "$dir" >/dev/null 2>&1 && touch "$marker" ) &
  disown 2>/dev/null || true
  local waited=0
  while [ "$waited" -lt "$timeout_s" ]; do
    if [ -f "$marker" ]; then
      rm -f "$marker"
      return 0
    fi
    sleep 1
    waited=$((waited + 1))
  done
  rm -f "$marker" 2>/dev/null || true
  return 1
}

# Blokada oparta na atomowym `mkdir` - NIE na `flock`, ktorego macOS nie ma
# domyslnie zainstalowanego (brak `/usr/bin/flock` na stockowym systemie;
# `flock -n` po prostu nie uruchamia sie, wiec kazdy skrypt myslal, ze
# blokada jest zawsze zajeta i cicho rezygnowal z pracy przy KAZDYM
# uruchomieniu - to byla prawdziwa przyczyna, dla ktorej montowanie
# "nigdy nie ruszalo z miejsca").
#
# Zwraca 0 i rejestruje automatyczne zwolnienie blokady na wyjsciu skryptu
# (trap EXIT), albo zwraca 1, jesli inna zywa instancja juz trzyma blokade.
#
# Osierocenie blokady (np. po kill -9 procesu, ktory nie zdazyl posprzatac)
# wykrywamy sprawdzajac, czy PID zapisany w blokadzie wciaz zyje (`kill -0`),
# NIE po wieku katalogu blokady. Wczesniejsza wersja uzywala progu czasowego
# (max_age_seconds) - to dzialalo tylko dopoki proces trzymajacy blokade
# faktycznie konczyl prace w zakladanym oknie czasowym. mount.sh moze dzis
# legalnie trzymac swoja blokade znacznie dluzej niz jakikolwiek rozsadny
# staly prog (dogananie duzej zaleglej kolejki uploadow po przerwanym
# backupie), wiec kazdy staly prog albo falszywie oznaczalby wciaz zywy,
# pracujacy proces jako "osierocony" (i pozwalal drugiej instancji odpalic
# sie rownolegle - kolizja dwoch `rclone nfsmount` na tym samym remote), albo
# musialby byc absurdalnie duzy. Sprawdzenie zywotnosci PID dziala poprawnie
# niezaleznie od tego, jak dlugo trwa legalna praca.
cm_acquire_lock() {
  local name="$1"
  local lock_dir="$CM_LOG_DIR/${name}.lock.d"
  local pid_file="$lock_dir/pid"

  if ! mkdir "$lock_dir" 2>/dev/null; then
    local holder_pid
    holder_pid="$(cat "$pid_file" 2>/dev/null || echo "")"
    if [ -n "$holder_pid" ] && kill -0 "$holder_pid" 2>/dev/null; then
      return 1
    fi
    # Proces-wlasciciel juz nie zyje (lub blokada zostala przerwana zanim
    # zdazyl zapisac swoj PID) - blokada jest osierocona, przejmujemy ja.
    rm -rf "$lock_dir"
    mkdir "$lock_dir" 2>/dev/null || return 1
  fi

  echo $$ > "$pid_file"
  trap "rm -rf '$lock_dir' 2>/dev/null || true" EXIT
  return 0
}
