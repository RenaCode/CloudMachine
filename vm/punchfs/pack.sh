#!/bin/bash
# Regenerates vm/punchfs/src.tar.gz.b64 from the punchfs sources.
#
# Lima embeds every `file:` of vm/cmsmb.yaml in the machine's lima.yaml, and
# `limactl list --json` of a running machine fails ("bufio.Scanner: token too
# long") once that JSON passes 64 KiB, which blinds vm-status, vm-guard,
# backup-health and vm-hold. The sources are most of it, so they ship as one
# compressed archive that the machine's provisioning unpacks into
# /opt/cloudmachine/punchfs/ before it builds. A test keeps the archive equal
# to the files: run this after changing any of them.
set -euo pipefail
cd "$(dirname "$0")"
COPYFILE_DISABLE=1 tar --no-xattrs -cz punchfs.c passthrough_helpers.h test-punchfs.sh | base64 > src.tar.gz.b64
echo "src.tar.gz.b64: $(wc -c < src.tar.gz.b64) bytes"
