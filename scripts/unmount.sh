#!/bin/bash
# Odmontowuje wolumin CloudMachine i sparsebundle. Uzyj przed wylaczeniem Maca / snem na dluzej
# oraz zawsze przed edycja machines.json lub reinstalacja rclone.

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ./common.sh

cm_require_config
MACHINE_KEY="$(cm_machine_key)"
LOCAL_DIR="$(cm_local_machine_mount_dir "$MACHINE_KEY")"
SP_MOUNT="$(cm_sparsebundle_mount_dir "$MACHINE_KEY")"
REMOTE_PATH="$(cm_remote_path_for "$MACHINE_KEY")"

# Zapisujemy to PRZED faktycznym odmontowaniem, zeby mount-watchdog.sh (ktory
# moze odpalic sie w dowolnej chwili w tle) od razu przestal traktowac ten
# wolumin jako "powinien byc zamontowany" i nie zaczal go odmontowywac z
# powrotem w trakcie tej operacji.
cm_set_mount_desired "off"

# 1. Odmontowanie sparsebundle, jeśli jest zamontowane
if mount | grep -q "$SP_MOUNT"; then
  cm_log "Odmontowuje sparsebundle: $SP_MOUNT"
  hdiutil detach "$SP_MOUNT" 2>/dev/null || umount "$SP_MOUNT" 2>/dev/null || diskutil unmount force "$SP_MOUNT" || true
fi

# 2. Odmontowanie NFS share
if ! mount | grep -q "$LOCAL_DIR"; then
  cm_log "Nic do odmontowania pod $LOCAL_DIR."
  cm_kill_rclone_for_remote "$REMOTE_PATH"
  exit 0
fi

cm_log "Odmontowuje $LOCAL_DIR"
umount "$LOCAL_DIR" 2>/dev/null || diskutil unmount "$LOCAL_DIR" 2>/dev/null || {
  cm_log "Zwykle odmontowanie nie powiodlo sie, probuje force unmount."
  diskutil unmount force "$LOCAL_DIR"
}
cm_kill_rclone_for_remote "$REMOTE_PATH"
cm_log "Odmontowano."
