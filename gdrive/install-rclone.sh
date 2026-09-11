#!/bin/bash
# Instaluje oficjalna binarke rclone obok tej z Homebrew.
#
# Powod: rclone z Homebrew jest zbudowany bez obslugi FUSE i przy probie
# montowania odmawia wprost:
#   "rclone mount is not supported on MacOS when rclone is installed via Homebrew"
# Binarka z rclone.org dochodzi do prawdziwego montowania.
#
# Nie ruszamy instalacji Homebrew - ta binarka siedzi we wlasnym katalogu
# i uzywaja jej tylko skrypty CloudMachine, przez CM_RCLONE.

set -euo pipefail
source "$(dirname "$0")/cm-env.sh"

DEST="$(dirname "$CM_RCLONE")"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

VER="$(curl -fsSL https://downloads.rclone.org/version.txt | awk '{print $2}')"
case "$(uname -m)" in
  arm64) ARCH="osx-arm64" ;;
  x86_64) ARCH="osx-amd64" ;;
  *) echo "Nieznana architektura: $(uname -m)" >&2; exit 1 ;;
esac
ZIP="rclone-${VER}-${ARCH}.zip"

echo "Pobieram $ZIP"
curl -fsSL -o "$TMP/$ZIP" "https://downloads.rclone.org/${VER}/${ZIP}"
curl -fsSL -o "$TMP/SHA256SUMS" "https://downloads.rclone.org/${VER}/SHA256SUMS"

EXPECT="$(grep " $ZIP\$\|$ZIP\$" "$TMP/SHA256SUMS" | awk '{print $1}' | head -1)"
ACTUAL="$(shasum -a 256 "$TMP/$ZIP" | awk '{print $1}')"
if [ -z "$EXPECT" ] || [ "$EXPECT" != "$ACTUAL" ]; then
  echo "Suma SHA256 sie nie zgadza - nie instaluje." >&2
  echo "  oczekiwana: ${EXPECT:-brak wpisu}" >&2
  echo "  policzona : $ACTUAL" >&2
  exit 1
fi
echo "Suma SHA256 zgodna."

mkdir -p "$DEST"
unzip -oq "$TMP/$ZIP" -d "$TMP"
cp "$TMP/rclone-${VER}-${ARCH}/rclone" "$CM_RCLONE"
chmod +x "$CM_RCLONE"

echo "Zainstalowane: $CM_RCLONE"
"$CM_RCLONE" version | head -2
