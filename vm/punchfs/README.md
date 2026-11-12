# punchfs

`punchfs.c` is libfuse's `example/passthrough_ll.c` (libfuse 3.14, the version
in Ubuntu 24.04) with two changes. It runs inside the CloudMachine machine,
between rclone's Google Drive mount (`/srv/tm`) and Samba (`/srv/tm-punch`).

## What changed and why

- **`fallocate` (hole punch, zero range).** macOS (DiskImages2) frees a band
  of a sparse bundle by punching a hole in it over SMB. rclone's FUSE mount
  has no `fallocate`, answers `EOPNOTSUPP`, and the refusal makes macOS drop
  the whole image. punchfs passes the call on and, when the layer below
  refuses it, writes zeros over the range instead - never past the end of
  the file for a punch or a keep-size zero range; a plain allocation extends
  the file.
- **Extended attributes.** Samba keeps the sparse flag (`user.DOSATTRIB`)
  and the Apple metadata streams (`streams_xattr`) in extended attributes,
  and rclone has none. Without them macOS treats the band files as not
  sparse and refuses to erase a band. punchfs stores each attribute as a
  small file `/srv/tm-xattr/p/<path below source>/#xattr#/<name>` on the
  machine's local disk. The key is the PATH, not the inode: `rclone mount2`
  hands out inodes from a counter of its process, so they change when rclone
  restarts (measured: the same file got another number after a restart that
  looked other files up first) and the sparse flag of a band would be lost
  or land on another file. `unlink`/`rmdir` remove a path's attributes,
  `rename` moves them. The old layout (`/srv/tm-xattr/<inode hex>`) cannot be
  used and is removed when punchfs starts.

Everything else is upstream code, unchanged, apart from a header comment
saying what was modified and when (GPLv2 section 2a).

## Building and testing

The sources reach the machine as ONE archive, `src.tar.gz.b64`, which the
provisioning unpacks into `/opt/cloudmachine/punchfs/`: Lima embeds every file
of the template in the machine's `lima.yaml`, and `limactl list --json` of a
running machine fails ("bufio.Scanner: token too long") past 64 KiB, which blinds
`vm-status`, `vm-guard`, `backup-health` and `vm-hold`. After changing
`punchfs.c`, `passthrough_helpers.h` or `test-punchfs.sh` run `./pack.sh`; a test
fails while the archive is stale.

The machine's provisioning builds it (`vm/cmsmb.yaml`):

    gcc -Wall -O2 -D_FILE_OFFSET_BITS=64 -DHAVE_FALLOCATE punchfs.c \
      $(pkg-config fuse3 --cflags --libs) -o /usr/local/bin/punchfs

### Durable fsync (`-o syncfs=<dir>`)

`rclone mount` answers fsync with OK and does nothing, and rclone writes its
cache metadata (`vfsMeta`, with the list of cached ranges `Rs`) without fsync,
so APFS barriers inside the Time Machine image were not durable and a hard stop
of the machine lost writes APFS considered safe. Production therefore uses
`rclone mount2` (passes fsync to the cache item) and `-o syncfs=/var/cache/rclone`:
after a successful fsync/fsyncdir punchfs also calls `syncfs()` on that
directory's filesystem and replies with its errno on failure. Without the
option nothing changes. (From Linux 5.8 `syncfs` can also return a write error
of ANOTHER writer on that filesystem, e.g. an upload buffer file; punchfs
passes it on as EIO, which is the safe direction for Time Machine.)

`punchfs.service` starts punchfs only when the installed binary knows
`-o syncfs`; an old binary (the unit is copied before the binary is rebuilt, and
a failed rebuild keeps the old one) ends once with status 78 instead of
restarting in a loop. `cloudmachine-agent vm-update` rebuilds it.

`test-punchfs.sh` checks all of this: both changes above (attributes also across
a restart of rclone, a rename and an unlink) and the fsync on a throwaway rclone
mount of a local directory, without touching Google Drive. The fsync check reads
the dirty pages of rclone's cache data file from the kernel and the kernel's own
record (ftrace `ext4:ext4_sync_fs`) that punchfs called syncfs, so neither another
writer on a live machine nor the page cache can make it pass or fail wrongly. Run
it once with `PUNCHFS_SYNCFS=0` (must FAIL the syncfs check) and with
`RCLONE_MOUNT_CMD=mount PUNCHFS_SYNCFS=0` (must FAIL both) after changing it:

    limactl shell cmsmb sudo /opt/cloudmachine/punchfs/test-punchfs.sh

## Licence

`punchfs.c` is distributed under the terms of the **GNU GPLv2**, like the
libfuse example it is based on (see its header); the licence text is in
[`COPYING`](COPYING). This applies to that one file only; the rest of the
CloudMachine repository is MIT. `passthrough_helpers.h` is libfuse's,
unchanged, under the BSD 2-Clause notice in the file. See also
[`THIRD-PARTY-NOTICES.md`](../../THIRD-PARTY-NOTICES.md).
