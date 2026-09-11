#!/bin/bash
# Symuluje smierc warstwy chmurowej w trakcie zapisu.
#
# Najgrozniejszy scenariusz tej architektury: Time Machine pisze do podpietego
# obrazu, a pod spodem znika montowanie rclone - bo padl proces, bo FUSE-T sie
# wysypal, bo system uspil dysk. Obraz traci swoje pasma w srodku zapisu.
#
# Test odpina zewnetrzny obraz (zastepnik montowania rclone) w trakcie zapisu
# do wewnetrznego, potem podpina wszystko z powrotem i sprawdza fsck_apfs.
#
# Interesuje nas nie to, czy zapis przezyje - nie przezyje - tylko czy obraz
# da sie pozniej naprawic, czy jest do wyrzucenia. Roznica miedzy "backup
# przerwany, wznowi sie" a "backup stracony, zaczynamy od zera".

set -euo pipefail
source "$(dirname "$0")/cm-env.sh"

POC_ROOT="${POC_ROOT:-/tmp/cm-plug}"
BAND_MB="${BAND_MB:-64}"
ROUNDS="${ROUNDS:-3}"

BAND_SECTORS=$((BAND_MB * 1024 * 1024 / 512))
OUTER="$POC_ROOT/stand-in.sparseimage"
MOUNT="$POC_ROOT/drive"
IMAGE="$MOUNT/plug.sparsebundle"
TARGET="/Volumes/PlugPOC"
FSCK=/System/Library/Filesystems/apfs.fs/Contents/Resources/fsck_apfs

detach_all() {
  hdiutil detach "$TARGET" -force -quiet 2>/dev/null || true
  hdiutil detach "$MOUNT" -force -quiet 2>/dev/null || true
}
trap detach_all EXIT

[ "${1:-}" = "clean" ] && { detach_all; rm -rf "$POC_ROOT"; echo "Posprzatane."; exit 0; }

detach_all; rm -rf "$POC_ROOT"; mkdir -p "$MOUNT"

echo "Przygotowanie"
hdiutil create -type SPARSE -size 20g -fs APFS -volname PlugStandIn "$OUTER" >/dev/null
hdiutil attach "$OUTER" -mountpoint "$MOUNT" -nobrowse >/dev/null
hdiutil create -type SPARSEBUNDLE -size 10g -fs "Case-sensitive APFS" \
  -volname PlugPOC -imagekey "sparse-band-size=$BAND_SECTORS" "$IMAGE" >/dev/null

FAILED=0
for r in $(seq 1 "$ROUNDS"); do
  echo
  echo "--- runda $r ---"
  hdiutil attach "$IMAGE" -nobrowse -mountpoint "$TARGET" >/dev/null

  # Zapis w tle, zeby wyrwac podloge w jego trakcie.
  ( dd if=/dev/urandom of="$TARGET/obciazenie-$r.bin" bs=1m count=1500 2>/dev/null ) &
  WRITER=$!
  sleep 3

  echo "Wyrywam podloge (odpinam zastepnik montowania)"
  hdiutil detach "$MOUNT" -force -quiet 2>/dev/null || true
  wait "$WRITER" 2>/dev/null || echo "  zapis przerwany, zgodnie z oczekiwaniem"
  hdiutil detach "$TARGET" -force -quiet 2>/dev/null || true

  echo "Przywracam warstwe i sprawdzam obraz"
  # Nie sprawdzamy obrazu w miejscu. Po wymuszonym odpieciu urzadzenie potrafi
  # zostac w systemie jako zombie; podpiecie zwraca wtedy martwy uchwyt, a
  # fsck_apfs melduje "failed to read container superblock" z UUID z samych zer.
  # Wyglada to jak nieodwracalne uszkodzenie, a jest tylko nieczytelnym
  # urzadzeniem - wczesniejsza wersja tego testu na tej podstawie trzy razy
  # z rzedu orzekla utrate backupu, ktory byl caly.
  #
  # Kopia pod swieza sciezka jest odporna na ten artefakt: nowy plik, nowe
  # urzadzenie, zaden stary uchwyt nie ma z nim zwiazku.
  hdiutil detach "$TARGET" -force -quiet 2>/dev/null || true
  cm_purge_stale_devices "$IMAGE"
  sleep 2
  hdiutil attach "$OUTER" -mountpoint "$MOUNT" -nobrowse >/dev/null
  sleep 1

  COPY="$POC_ROOT/kontrola-$r.sparsebundle"
  rm -rf "$COPY"
  cp -R "$IMAGE" "$COPY"

  DEV=$(hdiutil attach "$COPY" -nomount 2>/dev/null | awk '/41504653/ {print $1; exit}')
  if [ -z "$DEV" ]; then
    echo "  WYNIK: obrazu nie da sie nawet podpiac - stracony"
    FAILED=$((FAILED + 1))
    break
  fi
  if "$FSCK" -n "$DEV" >"$POC_ROOT/fsck-$r.log" 2>&1; then
    echo "  WYNIK: spojny"
  else
    echo "  WYNIK: niespojny - probuje naprawic"
    if "$FSCK" -y "$DEV" >>"$POC_ROOT/fsck-$r.log" 2>&1; then
      echo "  naprawa udana - backup do uratowania"
    else
      echo "  naprawa nieudana - backup stracony (log: $POC_ROOT/fsck-$r.log)"
      FAILED=$((FAILED + 1))
    fi
  fi
  hdiutil detach "$DEV" -force -quiet 2>/dev/null || true
  rm -rf "$COPY"
done

echo
echo "==================================="
echo "Rund: $ROUNDS   nieodwracalnych strat: $FAILED"
[ "$FAILED" -eq 0 ] && echo "Obraz przezyl kazde wyrwanie podlogi." \
                    || echo "UWAGA: architektura gubi backup przy utracie warstwy chmurowej."
