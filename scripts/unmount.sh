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
cm_stop_caffeinate

# 0. Jesli Time Machine akurat aktywnie pisze na ten wolumin, zatrzymujemy
# backup i CZEKAMY az faktycznie stanie, ZANIM odmontujemy. Odmontowanie
# (zwlaszcza wymuszone) w trakcie aktywnego zapisu obserwowane na zywo
# uszkadza metadane sparsebundle (Info.plist / bitmapa alokacji) tak, ze
# hdiutil pozniej zglasza "no mountable file systems" mimo ze dane sa nadal
# tam - to sie zdarzylo trzykrotnie w trakcie prac nad tym projektem.
# `tmutil stopbackup` NIE wymaga sudo (w przeciwienstwie do startbackup).
RUNNING="$(tmutil status 2>/dev/null | awk -F'= ' '/Running/ { gsub(";","",$2); print $2 }')"
if [ "$RUNNING" = "1" ]; then
  cm_log "Time Machine aktywnie kopiuje - zatrzymuje backup przed odmontowaniem, zeby nie uszkodzic sparsebundle."
  tmutil stopbackup >/dev/null 2>&1 || true
  waited=0
  while [ "$waited" -lt 30 ]; do
    RUNNING="$(tmutil status 2>/dev/null | awk -F'= ' '/Running/ { gsub(";","",$2); print $2 }')"
    [ "$RUNNING" != "1" ] && break
    sleep 2
    waited=$((waited + 2))
  done
  if [ "$RUNNING" = "1" ]; then
    cm_log "OSTRZEZENIE: Time Machine nie zatrzymalo sie po ${waited}s - odmontowuje mimo to, ryzyko uszkodzenia sparsebundle."
  else
    cm_log "Backup zatrzymany po ${waited}s."
  fi
fi

# 1. Odmontowanie sparsebundle, jeśli jest zamontowane. `hdiutil detach` (bez
#    -force) probujemy jako pierwszy krok normalnego, grzecznego odmontowania -
#    ale fallback idzie przez cm_force_unmount, NIE przez synchroniczny
#    `diskutil unmount force`, ktory potrafi zawiesic sie na dobre, jesli
#    backend NFS pod spodem akurat nie odpowiada (patrz komentarz przy
#    cm_force_unmount w common.sh - dokladnie ten mechanizm zawiesil kiedys
#    caly cykl naprawy na >48h).
if mount | grep -q "$SP_MOUNT"; then
  cm_log "Odmontowuje sparsebundle: $SP_MOUNT"
  hdiutil detach "$SP_MOUNT" 2>/dev/null || umount "$SP_MOUNT" 2>/dev/null || cm_force_unmount "$SP_MOUNT" 10 || true
fi

# 2. Odmontowanie NFS share
if ! mount | grep -q "$LOCAL_DIR"; then
  cm_log "Nic do odmontowania pod $LOCAL_DIR."
  cm_kill_rclone_for_remote "$REMOTE_PATH"
  exit 0
fi

cm_log "Odmontowuje $LOCAL_DIR"
if ! umount "$LOCAL_DIR" 2>/dev/null && ! diskutil unmount "$LOCAL_DIR" 2>/dev/null; then
  cm_log "Zwykle odmontowanie nie powiodlo sie, probuje force unmount (max 10s, w tle)."
  cm_force_unmount "$LOCAL_DIR" 10 || cm_log "OSTRZEZENIE: punkt montowania nadal widnieje w tabeli po probie wymuszonego odmontowania - proces diskutil moze zostac osierocony w tle."
fi
cm_kill_rclone_for_remote "$REMOTE_PATH"
cm_log "Odmontowano."
