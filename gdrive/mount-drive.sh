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
