#!/bin/bash
# Sprawdza, czy backup Time Machine na zamontowanym wolumenie CloudMachine jest
# spojny. To jest GLOWNE narzedzie do oceny, czy podejscie "prawdziwy TM na
# zmontowanym Google Drive" faktycznie dziala stabilnie, czy trzeba przejsc
# na plan B (patrz README.md).
#
# Uruchom po kazdym z pierwszych kilku backupow w fazie testowej.

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ./common.sh

cm_require_config
MACHINE_KEY="$(cm_machine_key)"
LOCAL_DIR="$(cm_local_machine_mount_dir "$MACHINE_KEY")"
SP_MOUNT="$(cm_sparsebundle_mount_dir "$MACHINE_KEY")"
REMOTE_PATH="$(cm_remote_path_for "$MACHINE_KEY")"

if ! mount | grep -q "$SP_MOUNT"; then
  cm_log "BLAD: Wirtualny dysk sparsebundle pod $SP_MOUNT nie jest zamontowany."
  exit 1
fi

cm_log "=== 1/3: tmutil destinationinfo ==="
tmutil destinationinfo

cm_log "=== 2/3: lista backupow (tmutil listbackups) ==="
tmutil listbackups -d "$SP_MOUNT" || cm_log "Brak backupow albo blad odczytu."

cm_log "=== 3/3: weryfikacja sum kontrolnych najnowszego backupu (tmutil verifychecksums) ==="
LATEST_BACKUP="$(tmutil listbackups -d "$SP_MOUNT" 2>/dev/null | tail -n 1 || true)"
if [ -z "$LATEST_BACKUP" ]; then
  cm_log "Brak backupu do zweryfikowania. Odpal najpierw: sudo tmutil startbackup --auto --block"
  exit 1
fi

cm_log "Weryfikuje: $LATEST_BACKUP (to moze potrwac dlugo przy duzych backupach)"
if sudo tmutil verifychecksums "$LATEST_BACKUP"; then
  cm_log "OK: sumy kontrolne sie zgadzaja."
else
  cm_log "UWAGA: verifychecksums zglosilo problem - to jest sygnal, ze montowanie przez rclone nfsmount"
  cm_log "moze nie byc wystarczajaco niezawodne dla Time Machine. Rozwaz przejscie na plan B z README.md."
  exit 2
fi

cm_log "Dodatkowo: rclone check lokalnego cache vs. Google Drive (wykrywa rozjazdy po stronie transferu)"
rclone check "$LOCAL_DIR" "$REMOTE_PATH" --one-way || {
  cm_log "UWAGA: rclone check wykazalo roznice miedzy lokalnym widokiem a stanem na Google Drive."
  exit 2
}

cm_log "Wszystkie testy przeszly. Backup wyglada na spojny."
