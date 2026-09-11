#!/bin/bash
# Mierzy wzmocnienie zapisu: ile megabajtow trzeba wyslac do Drive'a,
# zeby utrwalic jeden megabajt faktycznej zmiany.
#
# To jest liczba, ktora decyduje o rozmiarze pasma. Duze pasma oszczedzaja
# operacje na plikach (Drive przepuszcza ~2/s i ma limit 400 000 plikow), ale
# kazda drobna zmiana kaze wyslac cale pasmo od nowa. Jesli wzmocnienie okaze
# sie wysokie, 64 MB jest bledem i trzeba zejsc nizej.
#
# Uruchamiane dla kazdego rozmiaru pasma osobno; wynik to tabela do porownania.

set -euo pipefail

POC_ROOT="${POC_ROOT:-/tmp/cm-amp}"
BAND_MB="${BAND_MB:-64}"
SEED_FILES="${SEED_FILES:-3000}"     # plikow w pierwszym zapisie
FILE_KB="${FILE_KB:-64}"             # rozmiar pojedynczego pliku
TOUCH_FILES="${TOUCH_FILES:-300}"    # ile plikow zmieniamy w drugim przebiegu
WORKLOAD="${WORKLOAD:-scatter}"      # scatter = przepisanie rozrzuconych plikow
                                     # append  = dopisanie nowych, jak robi TM

BAND_SECTORS=$((BAND_MB * 1024 * 1024 / 512))
ROOT="$POC_ROOT/b$BAND_MB"
OUTER="$ROOT/stand-in.sparseimage"
MOUNT="$ROOT/drive"
IMAGE="$MOUNT/amp.sparsebundle"
TARGET="/Volumes/AmpPOC$BAND_MB"

cleanup() {
  hdiutil detach "$TARGET" -quiet 2>/dev/null || true
  hdiutil detach "$MOUNT" -quiet 2>/dev/null || true
}
trap cleanup EXIT

[ "${1:-}" = "clean" ] && { cleanup; rm -rf "$POC_ROOT"; echo "Posprzatane."; exit 0; }

cleanup; rm -rf "$ROOT"; mkdir -p "$MOUNT"

hdiutil create -type SPARSE -size 40g -fs APFS -volname AmpStandIn "$OUTER" >/dev/null
hdiutil attach "$OUTER" -mountpoint "$MOUNT" -nobrowse >/dev/null
hdiutil create -type SPARSEBUNDLE -size 30g -fs "Case-sensitive APFS" \
  -volname "AmpPOC$BAND_MB" -imagekey "sparse-band-size=$BAND_SECTORS" "$IMAGE" >/dev/null
hdiutil attach "$IMAGE" -nobrowse -mountpoint "$TARGET" >/dev/null

# Pierwszy zapis - odpowiednik pelnego backupu.
mkdir -p "$TARGET/dane"
for i in $(seq 1 "$SEED_FILES"); do
  dd if=/dev/urandom of="$TARGET/dane/plik-$i.bin" bs=1k count="$FILE_KB" 2>/dev/null
done
sync; hdiutil detach "$TARGET" -quiet

SEED_BANDS=$(ls "$IMAGE/bands" | wc -l | tr -d ' ')
SEED_MB=$(du -sk "$IMAGE" | awk '{print int($1/1024)}')

# Znacznik czasu, wzgledem ktorego liczymy zmienione pasma.
MARK="$ROOT/mark"; touch "$MARK"; sleep 1

# Drugi przebieg - odpowiednik backupu przyrostowego. Zmieniamy rozrzucone
# pliki, zeby trafic w mozliwie wiele roznych pasm; to najgorszy realny
# przypadek, nie sredni.
hdiutil attach "$IMAGE" -nobrowse -mountpoint "$TARGET" >/dev/null
CHANGED_KB=0
if [ "$WORKLOAD" = "append" ]; then
  # Time Machine nie przepisuje istniejacych danych w miejscu - kazdy backup
  # dokłada nowe pliki. Zapis jest wtedy skupiony, nie rozrzucony.
  mkdir -p "$TARGET/dane/przyrost"
  for i in $(seq 1 "$TOUCH_FILES"); do
    dd if=/dev/urandom of="$TARGET/dane/przyrost/nowy-$i.bin" bs=1k count="$FILE_KB" 2>/dev/null
    CHANGED_KB=$((CHANGED_KB + FILE_KB))
  done
else
  STEP=$((SEED_FILES / TOUCH_FILES))
  for i in $(seq 1 "$STEP" "$SEED_FILES"); do
    dd if=/dev/urandom of="$TARGET/dane/plik-$i.bin" bs=1k count="$FILE_KB" conv=notrunc 2>/dev/null
    CHANGED_KB=$((CHANGED_KB + FILE_KB))
  done
fi
sync; hdiutil detach "$TARGET" -quiet

DIRTY=$(find "$IMAGE/bands" -type f -newer "$MARK" | wc -l | tr -d ' ')
UPLOAD_MB=$((DIRTY * BAND_MB))
CHANGED_MB=$((CHANGED_KB / 1024))
[ "$CHANGED_MB" -eq 0 ] && CHANGED_MB=1

printf '%s\n' "---"
printf 'pasmo                : %s MB   (scenariusz: %s)\n' "$BAND_MB" "$WORKLOAD"
printf 'po pelnym zapisie    : %s pasm, %s MB\n' "$SEED_BANDS" "$SEED_MB"
printf 'zmieniono realnie    : %s MB w %s plikach\n' "$CHANGED_MB" "$TOUCH_FILES"
printf 'pobrudzonych pasm    : %s\n' "$DIRTY"
printf 'do wyslania          : %s MB\n' "$UPLOAD_MB"
printf 'WZMOCNIENIE          : %sx\n' "$((UPLOAD_MB / CHANGED_MB))"
