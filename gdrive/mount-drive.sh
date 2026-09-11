#!/bin/bash
# Montuje Google Drive jako wolumen z buforem zapisu na dysku lokalnym.
# Zapis konczy sie w momencie trafienia do bufora; wysylka do Drive'a idzie w tle,
# wiec zerwanie lacza nie przerywa Time Machine, tylko wstrzymuje drenaz.
#
# Proces zostaje na pierwszym planie - zarzadza nim launchd (KeepAlive).

set -euo pipefail
source "$(dirname "$0")/cm-env.sh"

mkdir -p "$CM_MOUNT" "$CM_CACHE"

if cm_is_mounted; then
  echo "Juz zamontowane: $CM_MOUNT"
  exit 0
fi

if [ ! -x "$CM_RCLONE" ]; then
  echo "Brak rclone z obsluga mount w $CM_RCLONE - uruchom install-rclone.sh" >&2
  exit 1
fi

# Bez FUSE rclone konczy sie natychmiast bledem "cgofuse: cannot find FUSE".
# Agent launchd ma KeepAlive, wiec probowalby w kolko co 30 s i zalewal log.
# Ten projekt ma juz za soba incydent logu na 3,3 GiB - lepiej stanac od razu.
if ! ls /usr/local/lib/libfuse-t.dylib /usr/local/lib/libfuse.2.dylib \
        /Library/Filesystems/fuse-t.fs /usr/local/lib/libfuse.dylib >/dev/null 2>&1; then
  echo "Nie znalazlem FUSE. Zainstaluj:" >&2
  echo "  brew install macos-fuse-t/homebrew-cask/fuse-t" >&2
  exit 1
fi

# rclone nie rotuje wlasnego logu. Przy dzialaniu ciaglym trzeba go przyciac
# samemu, bo inaczej rosnie bez konca.
if [ -f "$CM_LOG" ] && [ "$(stat -f%z "$CM_LOG")" -gt 104857600 ]; then
  mv -f "$CM_LOG" "$CM_LOG.1"
fi

# Bufor trzyma kopie danych backupu. Gdyby Time Machine go objal, backupowalby
# wlasny backup i rosl bez konca.
tmutil addexclusion "$CM_ROOT" 2>/dev/null || true

exec "$CM_RCLONE" mount "${CM_REMOTE}:${CM_REMOTE_PATH}" "$CM_MOUNT" \
  --vfs-cache-mode full \
  --vfs-cache-max-size "$CM_CACHE_SIZE" \
  --vfs-cache-max-age 9999h \
  --vfs-write-back 30s \
  --vfs-cache-poll-interval 1m \
  --cache-dir "$CM_CACHE" \
  --dir-cache-time 5m \
  --attr-timeout 5m \
  --transfers 8 \
  --drive-chunk-size 64M \
  --drive-use-trash=false \
  --drive-stop-on-upload-limit \
  --volname "$CM_REMOTE" \
  --rc --rc-addr 127.0.0.1:5572 --rc-no-auth \
  --log-file "$CM_LOG" \
  --log-level INFO
