#!/bin/bash
# CloudMachine: checks punchfs inside the machine (run as root):
#   limactl shell cmsmb sudo /opt/cloudmachine/punchfs/test-punchfs.sh
#
# It mounts a throwaway rclone mount of a local directory (a FUSE filesystem
# with no fallocate and no extended attributes - the same gaps as the Google
# Drive mount), puts punchfs on top, and checks the two things macOS needs:
#   1. hole punch / zero range succeed, read back as zeros, keep the size;
#   2. extended attributes can be set, read, listed and removed.
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

rclone mount "$work/src" "$work/rc" --config /dev/null --vfs-cache-mode full \
  --cache-dir "$work/cache" --log-level ERROR &
wait_mounted "$work/rc"
"$PUNCHFS" -f -o source="$work/rc" "$work/punch" &
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

# The side directory is keyed by the inode punchfs sees, i.e. rclone's.
ino=$(printf '%x' "$(stat -c %i "$work/rc/band")")
rmdir --ignore-fail-on-non-empty "/srv/tm-xattr/$ino" 2>/dev/null || true

if [ "$failures" -eq 0 ]; then echo "punchfs: all checks passed"; else echo "punchfs: $failures check(s) FAILED"; fi
exit "$failures"
