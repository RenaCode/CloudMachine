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
  small file `/srv/tm-xattr/<inode hex>/<name>` on the machine's local disk.
  rclone's inode is a hash of the path, so it stays the same for a band.

Everything else is upstream code, unchanged.

## Building and testing

The machine's provisioning builds it (`vm/cmsmb.yaml`):

    gcc -Wall -O2 -D_FILE_OFFSET_BITS=64 -DHAVE_FALLOCATE punchfs.c \
      $(pkg-config fuse3 --cflags --libs) -o /usr/local/bin/punchfs

`test-punchfs.sh` checks both changes on a throwaway rclone mount of a local
directory, without touching Google Drive:

    limactl shell cmsmb sudo /opt/cloudmachine/punchfs/test-punchfs.sh

## Licence

`punchfs.c` is distributed under the terms of the **GNU GPLv2**, like the
libfuse example it is based on (see its header). This applies to that one
file only; the rest of the CloudMachine repository is MIT.
