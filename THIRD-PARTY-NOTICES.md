# Third-party notices

CloudMachine itself is MIT-licensed (see [`LICENSE`](LICENSE)). This file
lists the third-party code it contains, and the third-party software it
installs or downloads on your Mac without shipping it.

## Shipped with CloudMachine

These are in this repository and in `CloudMachine.app`
(`Contents/Resources/vm/` holds the machine template, sources included).

### punchfs - from libfuse (GPLv2)

- File: [`vm/punchfs/punchfs.c`](vm/punchfs/punchfs.c)
- Origin: `example/passthrough_ll.c` from
  [libfuse](https://github.com/libfuse/libfuse) 3.14.0, the version in
  Ubuntu 24.04.
- Copyright (C) 2001-2007 Miklos Szeredi.
- Licence: GNU General Public License, version 2. The full text is in
  [`vm/punchfs/COPYING`](vm/punchfs/COPYING). This applies to that file
  only: libfuse ships its examples under the GPLv2 (libfuse `LICENSE`).
- Modified for CloudMachine in October 2026: `fallocate` falls back to
  writing zeros, and extended attributes are kept in side files. What
  changed and why: [`vm/punchfs/README.md`](vm/punchfs/README.md).
- punchfs is built from this source inside the Linux machine on your Mac and
  runs there as a separate program; it is not linked into the CloudMachine
  app or agent.

### passthrough_helpers.h - from libfuse (BSD 2-Clause)

- File: [`vm/punchfs/passthrough_helpers.h`](vm/punchfs/passthrough_helpers.h),
  unchanged from libfuse 3.14.0 `example/passthrough_helpers.h`.
- Licence notice, as in the file:

```
FUSE: Filesystem in Userspace

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
SUCH DAMAGE
```

### Swift Argument Parser (Apache-2.0 with Runtime Library Exception)

- [apple/swift-argument-parser](https://github.com/apple/swift-argument-parser)
  1.8.2 (`mac-app/Package.resolved`), compiled into the `cloudmachine-agent`
  binary.
- Copyright (c) 2020 Apple Inc. and the Swift project authors.
- Licence: Apache License 2.0 with the Runtime Library Exception,
  <https://github.com/apple/swift-argument-parser/blob/1.8.2/LICENSE.txt>.
  The project has no `NOTICE` file.

## Installed or downloaded on your Mac, not shipped

CloudMachine does not redistribute these. It downloads them from their
publishers, or asks you to install them, and each keeps its own licence.

| Software | Licence | How it gets there |
|---|---|---|
| [rclone](https://rclone.org) | MIT | downloaded from `downloads.rclone.org` (checked against its published SHA-256 sums), on the Mac and in the machine |
| [Lima](https://lima-vm.io) | Apache-2.0 | `brew install lima`, by you |
| [Ubuntu 24.04 cloud image](https://cloud-images.ubuntu.com) | the licences of its packages; Canonical's IP policy | downloaded by Lima from `cloud-images.ubuntu.com` |
| [Samba](https://www.samba.org) | GPL-3.0-or-later | `apt-get install samba` in the machine |
| libfuse / fuse3 | library LGPL-2.1, tools GPL-2.0 | `apt-get install fuse3 libfuse3-dev` in the machine (punchfs links against it there) |
| attr, curl, unzip, pkg-config, build-essential | their Ubuntu package licences | `apt-get install` in the machine |

## Trademarks

Time Machine, Mac and macOS are trademarks of Apple Inc. Google Drive is a
trademark of Google LLC. CloudMachine is an independent project, not
affiliated with, endorsed or sponsored by Apple or Google.
