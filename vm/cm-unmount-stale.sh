#!/bin/sh
# ExecStartPre=- of the chain units: lazily unmounts DEAD FUSE mounts (vm/README.md).
#   cm-unmount-stale <mountpoint | --bands>...   (--bands: /srv/tm-local/*/bands)
MOUNTS="${CM_MOUNTS:-/proc/mounts}"
LOCAL="${CM_LOCAL:-/srv/tm-local}"
T="${CM_STAT_TIMEOUT:-5}"
mps() { while read -r _ mp _; do printf '%b\n' "$mp"; done <"$MOUNTS" 2>/dev/null; }
# Dead: listed in /proc/mounts and stat fails with an error (a timeout is "slow", not dead).
clean() {
  mps | grep -Fxq -- "$1" || return 0
  if command -v timeout >/dev/null 2>&1; then timeout "$T" stat -t "$1"; else stat -t "$1"; fi >/dev/null 2>&1
  case $? in 0 | 124 | 137) return 0 ;; esac
  echo "cm-unmount-stale: $1 is dead, unmounting" >&2
  umount -l "$1" 2>/dev/null || fusermount3 -uz "$1" 2>/dev/null
}
for a in "$@"; do
  case "$a" in
    --bands) mps | while read -r mp; do case "$mp" in "$LOCAL"/*/bands) clean "$mp" ;; esac; done ;;
    *) clean "$a" ;;
  esac
done
exit 0
