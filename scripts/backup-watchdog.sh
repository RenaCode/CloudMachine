#!/bin/bash
# Pilnuje, zeby backup Time Machine na CloudMachine wznawial sie SAM po
# nieudanej probie, bez recznej interwencji.
#
# Time Machine na sieciowym sparsebundle (NFS-loop -> rclone -> Google Drive)
# ma udokumentowane, znane ryzyko: czasem TM konczy backup bledem
# BACKUP_FAILED_DISCONNECTED_DESTINATION (EILSEQ przy tescie zapisu), mimo ze
# sam wolumin (NFS + sparsebundle) jest w tym momencie realnie zdrowy - patrz
# README sekcja "Ryzyko spojnosci". To NIE jest cos, co mount-watchdog.sh
# naprawia (ten dba wylacznie o zdrowie samego montowania, nie o to, czy TM
# akurat aktywnie kopiuje) - stad osobny watchdog.
#
# Naprawiamy TYLKO objaw (TM jest bezczynne, mimo ze CloudMachine powinno byc
# aktywnym celem) - nie probujemy diagnozowac przyczyny na biezaco. Ten sam
# mechanizm naprawia tez drugi, obserwowany w praktyce przypadek: TM czasem
# po prostu nie wznawia samo CloudMachine po skonczeniu backupu na INNY
# skonfigurowany cel uzytkownika (np. NAS) - oba przypadki wygladaja
# identycznie z zewnatrz (Running=0, mimo ze user chce miec CloudMachine
# aktywne), wiec obsluga jest wspolna.
#
# Uruchamiane cyklicznie przez launchd, patrz
# launchd/com.renacode.cloudmachine.backup-watchdog.plist.template.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ./common.sh
set +e

cm_require_config
cm_require_jq

if ! cm_acquire_lock "backup-watchdog"; then
  exit 0
fi

if [ "$(cm_mount_desired)" != "on" ]; then
  exit 0
fi

MACHINE_KEY="$(cm_machine_key)"
LOCAL_DIR="$(cm_local_machine_mount_dir "$MACHINE_KEY")"
SP_MOUNT="$(cm_sparsebundle_mount_dir "$MACHINE_KEY")"

# Interweniujemy WYLACZNIE gdy nasz wlasny mount (NFS + sparsebundle) jest w
# tabeli `mount` - jesli jest zepsuty/brakujacy, to zadanie mount-watchdog.sh
# (osobny proces), nie nasze. Odpalanie backupu na polamany wolumin
# doprowadziloby tylko do kolejnego, natychmiastowego bledu.
if ! mount | grep -q "$LOCAL_DIR" || ! mount | grep -q "$SP_MOUNT"; then
  exit 0
fi

# ID celu CloudMachine w tmutil zmienia sie za kazdym razem, gdy wolumin
# trzeba odtworzyc od zera (nowy UUID) - szukamy go po sciezce mountpointu
# zamiast trzymac na sztywno.
DEST_ID="$(tmutil destinationinfo 2>/dev/null | awk -v mp="$SP_MOUNT" '
  /^Mount Point/ { found = index($0, mp) > 0 }
  found && /^ID/ { print $NF; exit }
')"
if [ -z "$DEST_ID" ]; then
  exit 0
fi

# Jesli TM aktualnie cos aktywnie robi - czy to do CloudMachine, czy do
# INNEGO skonfigurowanego celu uzytkownika (np. drugiego dysku NAS) - nie
# przeszkadzamy. Interweniujemy WYLACZNIE gdy TM jest bezczynne (Running=0).
RUNNING="$(tmutil status 2>/dev/null | awk -F'= ' '/Running/ { gsub(";","",$2); print $2 }')"
if [ "$RUNNING" = "1" ]; then
  exit 0
fi

# Nie probujemy czesciej niz raz na COOLDOWN sekund - zapobiega zapetleniu w
# kolko przy powtarzajacym sie, natychmiastowym bledzie (dajemy TM chwile
# oddechu miedzy probami, zamiast dobijac je co StartInterval watchdoga).
COOLDOWN=180
STATE_FILE="$CM_LOG_DIR/.backup-watchdog-last-attempt"
last="$(cat "$STATE_FILE" 2>/dev/null || echo 0)"
now="$(date +%s)"
if [ $((now - last)) -lt "$COOLDOWN" ]; then
  exit 0
fi
echo "$now" > "$STATE_FILE"

cm_log "[backup-watchdog] Time Machine jest bezczynne, mimo ze CloudMachine ($DEST_ID) powinno byc aktywne - wznawiam."
if sudo -n /usr/bin/tmutil startbackup -d "$DEST_ID" >>"$CM_LOG_DIR/cloudmachine.log" 2>&1; then
  cm_log "[backup-watchdog] Wznowiono backup."
else
  cm_log "[backup-watchdog] Nie udalo sie wznowic backupu (sudo bez hasla niedostepne lub inny blad) - sprawdz regule w /etc/sudoers.d/cloudmachine."
fi
