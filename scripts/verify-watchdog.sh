#!/bin/bash
# Automatyzuje to, co README opisuje jako "wysoce zalecane, rob to regularnie",
# ale co wczesniej trzeba bylo pamietac odpalic recznie: weryfikacje sum
# kontrolnych najnowszego backupu (scripts/verify-backup.sh robi to samo, ale
# interaktywnie/na zadanie).
#
# Uruchamiane cyklicznie przez launchd (patrz
# launchd/com.renacode.cloudmachine.verify-watchdog.plist.template), ale
# realna weryfikacja odpala sie co najwyzej raz na VERIFY_INTERVAL_DAYS dni
# (domyslnie 7) - `tmutil verifychecksums` na duzym backupie moze trwac
# dlugo i mocno obciazyc I/O, wiec launchd budzi ten skrypt czesciej (raz
# dziennie) tylko po to, zeby sprawdzic, czy termin juz minal.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ./common.sh
set +e

cm_require_config

if ! cm_acquire_lock "verify-watchdog"; then
  exit 0
fi

if [ "$(cm_mount_desired)" != "on" ]; then
  exit 0
fi

MACHINE_KEY="$(cm_machine_key)"
SP_MOUNT="$(cm_sparsebundle_mount_dir "$MACHINE_KEY")"

if ! mount | grep -q "$SP_MOUNT"; then
  exit 0
fi

# Nie przeszkadzamy aktywnemu backupowi - weryfikacja duzego backupu potrafi
# zajac I/O na dlugo, a robienie tego rownolegle z aktywnym zapisem TM tylko
# spowolniloby oba.
RUNNING="$(tmutil status 2>/dev/null | awk -F'= ' '/Running/ { gsub(";","",$2); print $2 }')"
if [ "$RUNNING" = "1" ]; then
  exit 0
fi

VERIFY_INTERVAL_DAYS="${CM_VERIFY_INTERVAL_DAYS:-7}"
VERIFY_INTERVAL_SECONDS=$((VERIFY_INTERVAL_DAYS * 86400))
STATE_FILE="$CM_LOG_DIR/.verify-watchdog-last-run"
last="$(cat "$STATE_FILE" 2>/dev/null || echo 0)"
now="$(date +%s)"
if [ $((now - last)) -lt "$VERIFY_INTERVAL_SECONDS" ]; then
  exit 0
fi

LATEST_BACKUP="$(tmutil listbackups -d "$SP_MOUNT" 2>/dev/null | tail -n 1 || true)"
if [ -z "$LATEST_BACKUP" ]; then
  cm_log "[verify-watchdog] Brak backupow do zweryfikowania, pomijam ten przebieg."
  exit 0
fi

# Zapisujemy PRZED faktyczna weryfikacja (nie po) - dluga weryfikacja
# (potencjalnie godziny) nie powinna sama siebie wywolywac ponownie w kolko,
# jesli nastepny cykl watchdoga (raz dziennie) trafi w trakcie jej trwania.
echo "$now" > "$STATE_FILE"

cm_log "[verify-watchdog] Weryfikuje sumy kontrolne najnowszego backupu: $LATEST_BACKUP (moze potrwac dlugo)."
if sudo -n /usr/bin/tmutil verifychecksums "$LATEST_BACKUP" >>"$CM_LOG_DIR/cloudmachine.log" 2>&1; then
  cm_log "[verify-watchdog] OK: sumy kontrolne sie zgadzaja."
else
  cm_log "[verify-watchdog] UWAGA: verifychecksums zglosilo problem (albo sudo bez hasla niedostepne - sprawdz /etc/sudoers.d/cloudmachine). Rozwaz uruchomienie scripts/verify-backup.sh recznie."
  if command -v osascript >/dev/null 2>&1; then
    osascript -e 'display notification "Weryfikacja sum kontrolnych najnowszego backupu wykazala problem - sprawdz Logi." with title "CloudMachine"' >/dev/null 2>&1
  fi
fi
