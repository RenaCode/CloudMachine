#!/bin/bash
# CloudMachine: checks punchfs inside the machine (run as root):
#   limactl shell cmsmb sudo /opt/cloudmachine/punchfs/test-punchfs.sh
#
# It mounts a throwaway rclone mount of a local directory (a FUSE filesystem
# with no fallocate and no extended attributes - the same gaps as the Google
# Drive mount), puts punchfs on top, and checks the two things macOS needs:
#   1. hole punch / zero range succeed, read back as zeros, keep the size;
#   2. extended attributes can be set, read, listed and removed;
#   3. extended attributes are keyed by path, so they survive a restart of
#      rclone (whose mount2 inodes come from a per-process counter), follow a
#      rename and go away with the file;
#   4. fsync through punchfs is durable:
#      - no page of rclone's cache DATA file is dirty or under writeback after
#        it (read per file from the kernel: /proc/self/pagemap +
#        /proc/kpageflags, so other writers on a live machine cannot fail it;
#        reading the data back could not tell page cache from disk);
#      - the kernel saw punchfs call syncfs on the cache's filesystem during
#        the fsync (ftrace event ext4:ext4_sync_fs). The metadata file (vfsMeta)
#        cannot be checked by page flags: ext4 starts its write at close, and
#        what is still missing is the journal commit, which syncfs forces.
#        The machine mounts / with commit=30, so a missing syncfs leaves the
#        change uncommitted for up to 30 s.
# The mount is `rclone mount2` like production (`mount` ignores fsync); set
# RCLONE_MOUNT_CMD=mount and PUNCHFS_SYNCFS=0 to see the old behaviour fail
# (the dirty-page checks are the ones that must then FAIL: run it so once
# after changing this script, a detector never seen failing proves nothing).
# Nothing touches /srv/tm or Google Drive. Attributes of the test files land in
# /srv/tm-xattr/p/cmtest-<pid>-* and are removed at the end.
set -euo pipefail

PUNCHFS=${PUNCHFS:-/usr/local/bin/punchfs}
work=$(mktemp -d /var/tmp/punchfs-test.XXXXXX)
mkdir -p "$work/src" "$work/rc" "$work/punch" "$work/cache"
failures=0
# Test files are named so that their attribute directories cannot be a real
# file of the machine: /srv/tm-xattr/p/<name> is keyed by the path.
tag="cmtest-$$"
xroot=/srv/tm-xattr/p

rclone_pid=""
punch_pid=""
stop_mounts() {
  [ -n "$punch_pid" ] && { fusermount3 -u "$work/punch" 2>/dev/null || fusermount3 -uz "$work/punch" 2>/dev/null || true; wait "$punch_pid" 2>/dev/null || true; }
  [ -n "$rclone_pid" ] && { fusermount3 -u "$work/rc" 2>/dev/null || fusermount3 -uz "$work/rc" 2>/dev/null || true; wait "$rclone_pid" 2>/dev/null || true; }
  punch_pid=""; rclone_pid=""
  return 0
}
cleanup() {
  stop_mounts
  rm -rf "$work" "$xroot/$tag"-*
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

start_rclone() {
  rclone "$RCLONE_MOUNT_CMD" "$work/src" "$work/rc" --config /dev/null --vfs-cache-mode full \
    --cache-dir "$work/cache" --log-level ERROR &
  rclone_pid=$!
  wait_mounted "$work/rc"
}
start_punch() {
  "$PUNCHFS" -f -o "$punch_opts" "$work/punch" &
  punch_pid=$!
  wait_mounted "$work/punch"
}
start_rclone
start_punch

f="$work/punch/$tag-band"
MiB=1048576
head -c $((4 * MiB)) /dev/zero | tr '\0' 'A' > "$f"

# The layer below really refuses fallocate - otherwise this test proves nothing.
check "rclone below refuses hole punch (the gap punchfs covers)" \
  bash -c "! fallocate --punch-hole --offset 0 --length $MiB '$work/rc/$tag-band' 2>/dev/null"

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

# --- extended attributes are keyed by path ---------------------------------
# rclone mount2 gives inodes from a counter of its process, so they change when
# rclone restarts (and with the order of lookups). Keyed by inode, the sparse
# flag of every band would be lost or land on another file.
g="$work/punch/$tag-keep"
head -c 4096 /dev/zero > "$g"
setfattr -n user.DOSATTRIB -v sparse "$g"
setfattr -n user.cmtest.bin -v 0x00010203 "$g"
ino_before=$(stat -c %i "$work/rc/$tag-keep")
check "attribute directory is below the path-keyed tree" \
  test -f "$xroot/$tag-keep/#xattr#/user.DOSATTRIB"

# Restart rclone and punchfs the way systemd does (Requires=), after other
# files were looked up first so that a counter hands out different numbers.
stop_mounts
for i in 1 2 3 4 5; do echo "$i" > "$work/src/$tag-other$i"; done
if [ "$RCLONE_MOUNT_CMD" = mount2 ]; then
  start_rclone
  for i in 1 2 3 4 5; do stat -c %i "$work/rc/$tag-other$i" > /dev/null; done
  ino_after=$(stat -c %i "$work/rc/$tag-keep")
  check "(test is meaningful) rclone gave the file another inode after its restart" \
    test "$ino_before" != "$ino_after"
else
  start_rclone
fi
start_punch
check "attribute survives a restart of rclone" \
  test "$(getfattr --only-values -n user.DOSATTRIB "$g" 2>/dev/null)" = sparse
check "binary attribute survives a restart of rclone" \
  bash -c "getfattr -e hex -n user.cmtest.bin '$g' | grep -q '=0x00010203'"
check "a file looked up earlier has none of it" \
  bash -c "! getfattr -n user.DOSATTRIB '$work/punch/$tag-other1' 2>/dev/null"

# rename: the attributes follow the path
mv "$g" "$work/punch/$tag-moved"
check "attribute follows a rename" \
  test "$(getfattr --only-values -n user.DOSATTRIB "$work/punch/$tag-moved" 2>/dev/null)" = sparse
check "the old name keeps nothing" test ! -e "$xroot/$tag-keep"
# a rename OVER a file replaces its attributes too (Samba replaces files by rename)
echo old > "$work/punch/$tag-victim"
setfattr -n user.DOSATTRIB -v stale "$work/punch/$tag-victim"
echo new > "$work/punch/$tag-plain"
mv "$work/punch/$tag-plain" "$work/punch/$tag-victim"
check "rename over a file does not leave the old file's attributes" \
  bash -c "! getfattr -n user.DOSATTRIB '$work/punch/$tag-victim' 2>/dev/null"
# names that look like the machinery: a file called "#xattr#" must not touch
# the attributes of its directory, one called "x (deleted)" must work
mkdir "$work/punch/$tag-dir"
setfattr -n user.cmtest -v dirattr "$work/punch/$tag-dir"
echo x > "$work/punch/$tag-dir/#xattr#"
rm "$work/punch/$tag-dir/#xattr#"
check "removing a file named like the attribute leaf keeps the directory's attributes" \
  test "$(getfattr --only-values -n user.cmtest "$work/punch/$tag-dir" 2>/dev/null)" = dirattr
echo x > "$work/punch/$tag-odd (deleted)"
check "a file whose name ends in ' (deleted)' has working attributes" \
  bash -c "setfattr -n user.cmtest -v odd '$work/punch/$tag-odd (deleted)' && test \"\$(getfattr --only-values -n user.cmtest '$work/punch/$tag-odd (deleted)')\" = odd"
# unlink: and go away with the file, so a new file of that name starts clean
rm "$work/punch/$tag-moved"
check "attributes go away with the file" test ! -e "$xroot/$tag-moved"
echo new > "$work/punch/$tag-moved"
check "a new file of that name has no attributes" \
  bash -c "! getfattr -n user.DOSATTRIB '$work/punch/$tag-moved' 2>/dev/null"

# --- durability of fsync ---------------------------------------------------
# Pages of rclone's cache files that are dirty or under writeback, "dirty total".
dirty_pages() { # dirty_pages <file> <start> <end>
  python3 - "$@" <<'PY'
import ctypes, mmap, os, sys
path, start, end = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
ps = os.sysconf("SC_PAGE_SIZE")
end = min(end, os.path.getsize(path))
fd = os.open(path, os.O_RDONLY)
m = mmap.mmap(fd, os.path.getsize(path), access=mmap.ACCESS_COPY)
base = ctypes.addressof(ctypes.c_char.from_buffer(m))
pm = open("/proc/self/pagemap", "rb", buffering=0)
kf = open("/proc/kpageflags", "rb", buffering=0)
dirty = total = 0
for off in range(start - start % ps, end, ps):
    _ = m[off]  # fault the page cache page in (a clean one if it was dropped)
    pm.seek(((base + off) // ps) * 8)
    entry = int.from_bytes(pm.read(8), "little")
    if not entry >> 63 & 1:
        continue
    kf.seek((entry & ((1 << 55) - 1)) * 8)
    flags = int.from_bytes(kf.read(8), "little")
    total += 1
    if flags >> 4 & 1 or flags >> 8 & 1:  # KPF_DIRTY, KPF_WRITEBACK
        dirty += 1
print(dirty, total)
PY
}

tr=/sys/kernel/tracing
trace_on() {
  [ -w $tr/trace ] || return 1
  echo 0 > $tr/tracing_on
  : > $tr/trace
  echo 1 > $tr/events/ext4/ext4_sync_fs/enable
  echo 1 > $tr/tracing_on
}
trace_off() {
  [ -w $tr/trace ] || return 0
  echo 0 > $tr/events/ext4/ext4_sync_fs/enable 2>/dev/null || true
  echo 0 > $tr/tracing_on
  return 0
}
trap 'trace_off; cleanup' EXIT
cache_dev=$(mountpoint -d "$(df --output=target "$work/cache" | tail -1)")   # major:minor, as ftrace prints it
d="$work/punch/durable"
sync   # the next write is a PARTIAL one into a file the cache has never seen
# 8 MiB of new data at 8 MiB of a 64 MiB file, then fsync (dd conv=fsync = one fsync at the end)
trace_ok=0; trace_on && trace_ok=1
head -c $((8 * MiB)) /dev/zero | tr "\0" C | dd of="$d" bs=$MiB seek=8 conv=notrunc,fsync status=none
syncfs_calls=0
if [ "$trace_ok" = 1 ]; then
  syncfs_calls=$(grep -c "punchfs.*ext4_sync_fs: dev ${cache_dev/:/,} " $tr/trace || true)
fi
trace_off
echo "Dirty after fsync (whole machine, informational): $(awk '/^Dirty:/ {print $2}' /proc/meminfo) kB"

if [ "$trace_ok" = 1 ]; then
  echo "syncfs calls by punchfs during the fsync: $syncfs_calls"
else
  echo "ftrace is not available ($tr): cannot observe syncfs"
fi
check "punchfs called syncfs on the cache filesystem during fsync" test "$syncfs_calls" -gt 0

# rclone's cache: data file and the metadata file ("Rs" = ranges present).
data=$(find "$work/cache/vfs" -type f -name durable -print -quit)
meta=$(find "$work/cache/vfsMeta" -type f -name durable -print -quit)
check "cache data file exists" test -n "$data"
check "vfsMeta file exists" test -n "$meta"
if [ -n "$data" ]; then
  read -r dd_dirty dd_total <<< "$(dirty_pages "$data" $((8 * MiB)) $((16 * MiB)) || echo "unreadable 0")"
  echo "cache data pages dirty/in page cache: $dd_dirty/$dd_total"
  check "fsync left no dirty page of the cache data (written range)" test "$dd_dirty" = 0 -a "$dd_total" -gt 0
fi
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

if [ "$failures" -eq 0 ]; then echo "punchfs: all checks passed"; else echo "punchfs: $failures check(s) FAILED"; fi
exit "$failures"
