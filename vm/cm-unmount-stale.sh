#!/bin/sh
# Lazily unmounts dead FUSE mounts of the chain units (vm/README.md, "Dead FUSE mount").
#   cm-unmount-stale [--bands] [--own] <path>...   --own: next path is the unit's own mount
MOUNTS="${CM_MOUNTS:-/proc/mounts}"
LOCAL="${CM_LOCAL:-/srv/tm-local}"
T="${CM_STAT_TIMEOUT:-5}"
say() { echo "cm-unmount-stale: $*" >&2; }
mps() { while read -r _ mp _; do printf '%b\n' "$mp"; done <"$MOUNTS" 2>/dev/null; }
drop() {
  say "$1: unmounting"
  umount -l "$1" 2>/dev/null || fusermount3 -uz "$1" 2>/dev/null || say "$1: could not unmount"
}
probe() {
  mps | grep -Fxq -- "$1" || return 0
  timeout "$T" stat --cached=never -t "$1" >/dev/null 2>&1
  rc=$?
  case $rc in
    0) ;;
    1) say "$1 is dead"; drop "$1" ;;
    *) say "$1: probe inconclusive (exit $rc), left alone" ;;
  esac
}
own=
for a in "$@"; do
  case "$a" in
    --own) own=1; continue ;;
    --bands) mps | while read -r mp; do case "$mp" in "$LOCAL"/*/bands) probe "$mp" ;; esac; done ;;
    *) if [ -n "$own" ]; then mps | grep -Fxq -- "$a" && drop "$a"; else probe "$a"; fi ;;
  esac
  own=
done
exit 0
