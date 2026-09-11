#!/bin/bash
# Sprawdza spojnosc obrazu backupu.
#
# Uwaga: na sparsebundle NIE dziala `hdiutil verify` - taki obraz nie ma sumy
# kontrolnej i narzedzie konczy komunikatem "has no checksum". Trzeba podpiac
# urzadzenie bez montowania i puscic na nim fsck_apfs.
#
# To jest test rozstrzygajacy dla calej architektury: po zerwaniu lacza
# w trakcie backupu i pelnym drenazu bufora obraz musi byc spojny. Jesli nie
# jest, asynchroniczna wysylka gubi dane i uklad trzeba zmienic.

set -euo pipefail
source "$(dirname "$0")/cm-env.sh"

IMAGE="${1:-$CM_IMAGE}"
FSCK=/System/Library/Filesystems/apfs.fs/Contents/Resources/fsck_apfs

if [ ! -d "$IMAGE" ]; then
  echo "Brak obrazu: $IMAGE" >&2
  exit 1
fi

if cm_is_attached; then
  echo "Obraz jest podpiety pod $CM_TARGET - odepnij go najpierw:" >&2
  echo "  hdiutil detach $CM_TARGET" >&2
  exit 1
fi

echo "Podpinam bez montowania: $IMAGE"
ATTACH_OUT="$(hdiutil attach "$IMAGE" -nomount)"
DEV="$(echo "$ATTACH_OUT" | awk '/41504653/ {print $1; exit}')"

if [ -z "$DEV" ]; then
  echo "Nie znalazlem urzadzenia APFS w wyniku hdiutil:" >&2
  echo "$ATTACH_OUT" >&2
  hdiutil detach "$(echo "$ATTACH_OUT" | awk 'NR==1{print $1}')" -quiet 2>/dev/null || true
  exit 1
fi

cleanup() { hdiutil detach "$DEV" -quiet 2>/dev/null || true; }
trap cleanup EXIT

echo "Urzadzenie: $DEV"
echo

if "$FSCK" -n "$DEV"; then
  echo
  echo "SPOJNY"
else
  echo
  echo "NIESPOJNY - fsck_apfs zglosil problemy" >&2
  exit 1
fi
