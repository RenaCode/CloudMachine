#!/bin/sh
# Lazily unmounts a DEAD FUSE mount so its unit can mount again (ExecStartPre=- of
# rclone-tm, punchfs, tm-bands-bind; 28 Nov 2026: kill -9 of rclone left /srv/tm
# dead and every start failed with "directory already mounted").
#   cm-unmount-stale <mountpoint | --bands>...   (--bands: /srv/tm-local/*/bands)
# Unmounts only if the path is listed in /proc/mounts AND `stat` on it fails with
# an error within CM_STAT_TIMEOUT s. A healthy or merely slow mount is left alone.
# `umount -l`, else `fusermount3 -uz`. Always exits 0.
MOUNTS="${CM_MOUNTS:-/proc/mounts}"
LOCAL="${CM_LOCAL:-/srv/tm-local}"
T="${CM_STAT_TIMEOUT:-5}"

log() { echo "cm-unmount-stale: $*" >&2; }

# Mount point of each line, escapes (\040 for a space) undone.
mount_points() {
  while read -r _ mp _; do
    printf '%b\n' "$mp"
  done <"$MOUNTS" 2>/dev/null
}

is_mounted() {
  mount_points | grep -Fxq -- "$1"
}

# 0 = dead: stat answered with an error (not a timeout, not success).
is_dead() {
  if command -v timeout >/dev/null 2>&1; then
    timeout "$T" stat -t "$1" >/dev/null 2>&1
  else
    stat -t "$1" >/dev/null 2>&1
  fi
  rc=$?
  [ "$rc" -ne 0 ] && [ "$rc" -ne 124 ] && [ "$rc" -ne 137 ]
}

clean() {
  is_mounted "$1" || return 0
  is_dead "$1" || return 0
  log "$1 is a dead mount: unmounting it lazily"
  umount -l "$1" 2>/dev/null || fusermount3 -uz "$1" 2>/dev/null \
    || log "could not unmount $1"
}

for arg in "$@"; do
  case "$arg" in
    --bands)
      mount_points | while read -r mp; do
        case "$mp" in "$LOCAL"/*/bands) clean "$mp" ;; esac
      done
      ;;
    *) clean "$arg" ;;
  esac
done
exit 0
