#!/bin/bash
# Stan warstwy Drive: czy bufor stoi, ile w nim zalega, co robi Time Machine.
# Kluczowa liczba to "uploads in progress/queued" - jesli rosnie i nie spada,
# wysylka nie nadaza za zapisem i bufor sie zapelnia.

source "$(dirname "$0")/cm-env.sh"

printf '%-22s ' "Montowanie Drive:"
cm_is_mounted && echo "OK  ($CM_MOUNT)" || echo "BRAK"

printf '%-22s ' "Obraz podpiety:"
cm_is_attached && echo "OK  ($CM_TARGET)" || echo "BRAK"

printf '%-22s ' "Bufor na dysku:"
if [ -d "$CM_CACHE" ]; then
  echo "$(du -shx "$CM_CACHE" 2>/dev/null | awk '{print $1}')  z limitu $CM_CACHE_SIZE"
else
  echo "brak katalogu"
fi

echo
echo "--- kolejka wysylki (rclone vfs/stats) ---"
rclone rc --url 127.0.0.1:5572 --no-auth vfs/stats 2>/dev/null \
  | grep -E '"(uploadsInProgress|uploadsQueued|files|erroredFiles|bytesUsed)"' \
  || echo "(rclone rc nieosiagalne - bufor nie dziala?)"

echo
echo "--- Time Machine ---"
tmutil destinationinfo 2>/dev/null | grep -E "Name|Kind|Mount" || echo "(brak celu)"
tmutil status 2>/dev/null | grep -E "Running|Percent|BytesWritten|Phase" || true

echo
echo "--- ostatnie bledy w logu rclone ---"
if [ -f "$CM_LOG" ]; then
  grep -iE "error|failed|403|quota" "$CM_LOG" | tail -5 || echo "(brak)"
else
  echo "(brak logu)"
fi
