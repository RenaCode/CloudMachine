#!/bin/bash
# CloudMachine: checks punchfs inside the machine (run as root):
#   limactl shell cmsmb sudo /opt/cloudmachine/punchfs/test-punchfs.sh
#
# It mounts a throwaway rclone mount of a local directory (a FUSE filesystem
# with no fallocate and no extended attributes - the same gaps as the Google
# Drive mount), puts punchfs on top, and checks the two things macOS needs:
#   1. hole punch / zero range succeed, read back as zeros, keep the size;
#   2. extended attributes can be set, read, listed and removed;
#   3. fsync through punchfs is durable: it leaves ~0 Dirty pages (rclone's
#      cache metadata included, via -o syncfs=) and rclone's metadata file
#      (vfsMeta) already lists the written range in "Rs".
# The mount is `rclone mount2` like production (`mount` ignores fsync); set
# RCLONE_MOUNT_CMD=mount and PUNCHFS_SYNCFS=0 to see the old behaviour fail.
# Nothing touches /srv/tm or Google Drive. Attributes of the test file land in
# /srv/tm-xattr/<inode> and are removed at the end.
set -euo pipefail

PUNCHFS=${PUNCHFS:-/usr/local/bin/punchfs}
work=$(mktemp -d /var/tmp/punchfs-test.XXXXXX)
mkdir -p "$work/src" "$work/rc" "$work/punch" "$work/cache"
failures=0

cleanup() {
  fusermount3 -uz "$work/punch" 2>/dev/null || true
  fusermount3 -uz "$work/rc" 2>/dev/null || true
  sleep 1
  rm -rf "$work"
}
trap cleanup EXIT

check() { # check <description> <command...>
  local what=$1; shift
  if "$@"; then echo "ok   - $what"; else echo "FAIL - $what"; failures=$((failures + 1)); fi
}

wait_mounted() {
  for _ in $(seq 1 50); do mountpoint -q "$1" && return 0; sleep 0.2; done
  echo "not mounted: $1" >&2; return 1
}

# An existing file the cache has never seen, so that the partial write below
# leaves a sparse "Rs" (only the written range is in the cache).
head -c $((64 * 1048576)) /dev/zero | tr "\0" B > "$work/src/durable"

RCLONE_MOUNT_CMD=${RCLONE_MOUNT_CMD:-mount2}
PUNCHFS_SYNCFS=${PUNCHFS_SYNCFS:-1}
punch_opts="source=$work/rc"
[ "$PUNCHFS_SYNCFS" = 1 ] && punch_opts="$punch_opts,syncfs=$work/cache"

rclone "$RCLONE_MOUNT_CMD" "$work/src" "$work/rc" --config /dev/null --vfs-cache-mode full \
  --cache-dir "$work/cache" --log-level ERROR &
wait_mounted "$work/rc"
"$PUNCHFS" -f -o "$punch_opts" "$work/punch" &
wait_mounted "$work/punch"

f="$work/punch/band"
MiB=1048576
head -c $((4 * MiB)) /dev/zero | tr '\0' 'A' > "$f"

# The layer below really refuses fallocate - otherwise this test proves nothing.
check "rclone below refuses hole punch (the gap punchfs covers)" \
  bash -c "! fallocate --punch-hole --offset 0 --length $MiB '$work/rc/band' 2>/dev/null"

check "hole punch succeeds" fallocate --punch-hole --offset $MiB --length $MiB "$f"
check "size is kept after hole punch" test "$(stat -c %s "$f")" -eq $((4 * MiB))
check "punched range reads as zeros" \
  cmp -s <(dd if="$f" bs=$MiB skip=1 count=1 status=none) <(head -c $MiB /dev/zero)
check "data before the hole is intact" \
  cmp -s <(dd if="$f" bs=$MiB count=1 status=none) <(head -c $MiB /dev/zero | tr '\0' 'A')
check "zero range with keep-size succeeds past EOF" \
  fallocate --zero-range --keep-size --offset $((3 * MiB)) --length $((2 * MiB)) "$f"
check "zero range did not grow the file" test "$(stat -c %s "$f")" -eq $((4 * MiB))
check "zeroed range reads as zeros" \
  cmp -s <(dd if="$f" bs=$MiB skip=3 count=1 status=none) <(head -c $MiB /dev/zero)

check "set text attribute" setfattr -n user.cmtest -v hello "$f"
check "read text attribute" test "$(getfattr --only-values -n user.cmtest "$f")" = hello
check "set binary attribute" setfattr -n user.cmtest.bin -v 0x00010203 "$f"
check "read binary attribute" \
  bash -c "getfattr -e hex -n user.cmtest.bin '$f' | grep -q '=0x00010203'"
check "list attributes" bash -c "getfattr -d -m 'user\\.cmtest' '$f' | grep -q user.cmtest.bin"
check "XATTR_CREATE refuses an existing name" \
  bash -c "! python3 -c 'import os,sys; os.setxattr(sys.argv[1], \"user.cmtest\", b\"x\", os.XATTR_CREATE)' '$f' 2>/dev/null"
check "remove attributes" bash -c "setfattr -x user.cmtest '$f' && setfattr -x user.cmtest.bin '$f'"
check "removed attribute is gone" bash -c "! getfattr -n user.cmtest '$f' 2>/dev/null"

# --- durability of fsync ---------------------------------------------------
dirty_kb() { awk '/^Dirty:/ {print $2}' /proc/meminfo; }

d="$work/punch/durable"
sync   # start from a quiet system; the next write is a PARTIAL one into an uncached file
# 8 MiB of new data at 8 MiB of a 64 MiB file, then fsync (dd conv=fsync = one fsync at the end)
head -c $((8 * MiB)) /dev/zero | tr "\0" C | dd of="$d" bs=$MiB seek=8 conv=notrunc,fsync status=none
dirty=$(dirty_kb)
echo "Dirty after fsync: ${dirty} kB"
check "fsync leaves almost nothing dirty (< 2 MiB)" test "$dirty" -lt 2048

# rclone's metadata file for the cache item: "Rs" = ranges present in the cache.
meta=$(find "$work/cache/vfsMeta" -type f -name durable | head -1)
check "vfsMeta file exists" test -n "$meta"
check "vfsMeta Rs covers the range written before fsync" \
  python3 - "$meta" $((8 * MiB)) $((16 * MiB)) <<'PY'
import json, sys
meta = json.load(open(sys.argv[1]))
start, end = int(sys.argv[2]), int(sys.argv[3])
rs = sorted((r["Pos"], r["Pos"] + r["Size"]) for r in meta.get("Rs", []))
merged = []
for a, b in rs:
    if merged and a <= merged[-1][1]:
        merged[-1] = (merged[-1][0], max(merged[-1][1], b))
    else:
        merged.append((a, b))
print("Rs:", merged)
sys.exit(0 if any(a <= start and end <= b for a, b in merged) else 1)
PY

# The side directory is keyed by the inode punchfs sees, i.e. rclone's.
ino=$(printf '%x' "$(stat -c %i "$work/rc/band")")
rmdir --ignore-fail-on-non-empty "/srv/tm-xattr/$ino" 2>/dev/null || true

if [ "$failures" -eq 0 ]; then echo "punchfs: all checks passed"; else echo "punchfs: $failures check(s) FAILED"; fi
exit "$failures"
