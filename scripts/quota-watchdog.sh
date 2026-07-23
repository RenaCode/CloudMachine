#!/bin/bash
# Pilnuje, zeby backup TEJ maszyny na Google Drive nie przekroczyl przydzielonego
# jej limitu (config/machines.json -> machines.<key>.limit_gb).
#
# Gdy limit jest przekroczony, kasuje najstarsze backupy Time Machine (tmutil delete)
# az do zejscia ponizej progu - ale NIGDY nie usuwa ostatniego pozostalego backupu,
# zeby nie zostac bez zadnej kopii.
#
# Uruchamiane cyklicznie przez launchd (patrz launchd/com.renacode.cloudmachine.quota-watchdog.plist).

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ./common.sh

cm_require_config
cm_require_jq

if ! cm_acquire_lock "quota-watchdog"; then
  cm_log "Watchdog juz dziala, pomijam ten przebieg."
  exit 0
fi

MACHINE_KEY="$(cm_machine_key)"
LOCAL_DIR="$(cm_local_machine_mount_dir "$MACHINE_KEY")"
SP_MOUNT="$(cm_sparsebundle_mount_dir "$MACHINE_KEY")"
REMOTE_PATH="$(cm_remote_path_for "$MACHINE_KEY")"
LIMIT_GB="$(cm_machine_limit_gb "$MACHINE_KEY")"

# Sprawdzaj przy 90% limitu, zeby zdazyc przyciac zanim TM sam zablokuje zapis.
TRIGGER_GB=$(awk -v l="$LIMIT_GB" 'BEGIN { printf "%d", l * 0.9 }')

cm_log "Sprawdzam wykorzystanie ${REMOTE_PATH} (limit ${LIMIT_GB} GB, próg przycinania ${TRIGGER_GB} GB)"

SIZE_JSON="$(rclone size "$REMOTE_PATH" --json 2>>"$CM_LOG_DIR/rclone-size-errors.log")" || {
  cm_log "BLAD: 'rclone size' nie powiodlo sie, sprawdz $CM_LOG_DIR/rclone-size-errors.log. Przerywam ten przebieg."
  exit 1
}
BYTES_USED="$(echo "$SIZE_JSON" | jq -r '.bytes')"
GB_USED=$(awk -v b="$BYTES_USED" 'BEGIN { printf "%.1f", b / 1024 / 1024 / 1024 }')

cm_log "Aktualne wykorzystanie: ${GB_USED} GB / ${LIMIT_GB} GB"

USED_INT=$(awk -v g="$GB_USED" 'BEGIN { printf "%d", g }')
if [ "$USED_INT" -lt "$TRIGGER_GB" ]; then
  cm_log "Ponizej progu, nic do zrobienia."
  exit 0
fi

if ! mount | grep -q "$SP_MOUNT"; then
  cm_log "BLAD: przekroczono prog, ale wirtualny dysk sparsebundle pod $SP_MOUNT nie jest zamontowany - nie moge wylistowac backupow TM do przyciecia."
  exit 1
fi

cm_log "Przekroczono prog przycinania. Szukam najstarszych backupow Time Machine do usuniecia."

# tmutil listbackups zwraca sciezki posortowane od najstarszego do najnowszego.
mapfile -t BACKUPS < <(tmutil listbackups -d "$SP_MOUNT" 2>/dev/null || true)

if [ "${#BACKUPS[@]}" -le 1 ]; then
  cm_log "UWAGA: zostal juz tylko ${#BACKUPS[@]} backup(ow) - nie usuwam, zeby nie zostac bez kopii zapasowej. Rozwaz podniesienie limitu w machines.json."
  exit 0
fi

DELETED=0
for backup_path in "${BACKUPS[@]}"; do
  # Zawsze zostaw co najmniej jeden (ostatni) backup.
  if [ "${#BACKUPS[@]}" -le $((DELETED + 1)) ]; then
    break
  fi

  cm_log "Usuwam najstarszy backup: $backup_path"
  sudo tmutil delete -p "$backup_path" 2>>"$CM_LOG_DIR/tmutil-delete-errors.log" || {
    cm_log "BLAD przy usuwaniu $backup_path, sprawdz $CM_LOG_DIR/tmutil-delete-errors.log"
    break
  }
  DELETED=$((DELETED + 1))

  SIZE_JSON="$(rclone size "$REMOTE_PATH" --json 2>>"$CM_LOG_DIR/rclone-size-errors.log")" || break
  BYTES_USED="$(echo "$SIZE_JSON" | jq -r '.bytes')"
  GB_USED=$(awk -v b="$BYTES_USED" 'BEGIN { printf "%.1f", b / 1024 / 1024 / 1024 }')
  USED_INT=$(awk -v g="$GB_USED" 'BEGIN { printf "%d", g }')
  cm_log "Po usunieciu: ${GB_USED} GB / ${LIMIT_GB} GB"

  if [ "$USED_INT" -lt "$TRIGGER_GB" ]; then
    break
  fi
done

cm_log "Zakonczono. Usunieto ${DELETED} backup(ow)."

if command -v osascript >/dev/null 2>&1 && [ "$DELETED" -gt 0 ]; then
  osascript -e "display notification \"Usunieto ${DELETED} najstarszych backupow, zeby zmiescic sie w limicie ${LIMIT_GB} GB\" with title \"CloudMachine\"" || true
fi
