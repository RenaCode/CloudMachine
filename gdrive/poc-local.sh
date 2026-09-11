#!/bin/bash
# POC bez Google Drive i bez FUSE-T.
#
# W miejsce montowania rclone podstawia zwykly obraz dyskowy przypiety pod
# ta sama sciezka. Dzieki temu create-image.sh i attach-image.sh widza prawdziwy
# punkt montowania i nie trzeba ich modyfikowac na czas testu.
#
# Co to dowodzi: ze obraz z pasmami 64 MB powstaje, podpina sie, przyjmuje dane,
# rozklada je na pasma zgodnie z zalozeniem i przezywa odpiecie z ponownym
# podpieciem. Czego NIE dowodzi: zachowania FUSE-T, limitow Drive'a ani tego,
# czy Time Machine przyjmie taki cel - to wymaga sudo i konta Google.

set -euo pipefail

POC_ROOT="${POC_ROOT:-/tmp/cm-poc}"
OUTER="$POC_ROOT/stand-in-drive.sparseimage"
DATA_MB="${DATA_MB:-4096}"

export CM_ROOT="$POC_ROOT/home"
export CM_VOLNAME="${CM_VOLNAME:-CloudMachinePOC}"
export CM_IMAGE_NAME="${CM_IMAGE_NAME:-poc}"
export CM_IMAGE_SIZE="${CM_IMAGE_SIZE:-200g}"

HERE="$(cd "$(dirname "$0")" && pwd)"
source "$HERE/cm-env.sh"

step() { printf '\n\033[1m== %s ==\033[0m\n' "$1"; }

cleanup() {
  hdiutil detach "$CM_TARGET" -quiet 2>/dev/null || true
  hdiutil detach "$CM_MOUNT" -quiet 2>/dev/null || true
}

case "${1:-run}" in
  clean)
    cleanup
    rm -rf "$POC_ROOT"
    echo "Posprzatane."
    exit 0
    ;;
esac

step "Przygotowanie piaskownicy"
cleanup
rm -rf "$POC_ROOT"
mkdir -p "$CM_MOUNT" "$CM_CACHE"
hdiutil create -type SPARSE -size 60g -fs APFS -volname StandInDrive "$OUTER" >/dev/null
hdiutil attach "$OUTER" -mountpoint "$CM_MOUNT" -nobrowse >/dev/null
cm_is_mounted && echo "Stand-in zamontowany pod $CM_MOUNT"

step "create-image.sh"
"$HERE/create-image.sh"

step "Weryfikacja rozmiaru pasma"
BAND=$(plutil -extract band-size raw "$CM_IMAGE/Info.plist")
echo "band-size = $BAND B = $((BAND / 1024 / 1024)) MB"
[ "$BAND" -eq $((CM_BAND_SECTORS * 512)) ] || { echo "BLAD: nie zgadza sie z CM_BAND_SECTORS"; exit 1; }

step "attach-image.sh"
"$HERE/attach-image.sh"
df -h "$CM_TARGET" | tail -1

step "Zapis ${DATA_MB} MB danych"
time dd if=/dev/urandom of="$CM_TARGET/dane.bin" bs=1m count="$DATA_MB" 2>&1 | tail -2
sync

step "Rozklad na pasma"
N=$(ls "$CM_IMAGE/bands" | wc -l | tr -d ' ')
TOTAL=$(du -sk "$CM_IMAGE" | awk '{print $1}')
echo "pasm: $N"
echo "obraz zajmuje: $((TOTAL / 1024)) MB na ${DATA_MB} MB danych"
echo "rozmiary pasm (unikalne):"
ls -l "$CM_IMAGE/bands" | awk 'NR>1{print $5}' | sort -n | uniq -c | tail -3

step "Odpiecie i ponowne podpiecie"
hdiutil detach "$CM_TARGET" -quiet
"$HERE/attach-image.sh"
SUM_BEFORE=$(ls -l "$CM_TARGET/dane.bin" | awk '{print $5}')
echo "plik po ponownym podpieciu: $SUM_BEFORE B"
[ "$SUM_BEFORE" -eq $((DATA_MB * 1024 * 1024)) ] || { echo "BLAD: rozmiar sie nie zgadza"; exit 1; }

step "hdiutil verify"
hdiutil detach "$CM_TARGET" -quiet
hdiutil verify "$CM_IMAGE" 2>&1 | tail -3

step "Gotowe"
echo "Piaskownica: $POC_ROOT   (sprzatanie: $0 clean)"
