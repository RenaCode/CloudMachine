#!/bin/bash
# Zaklada remote rclone wskazujacy na Google Drive.
#
# Klucze podaje sie przez zmienne srodowiskowe, nie jako argumenty - argumenty
# ladują w historii powloki i w `ps` widocznym dla innych procesow:
#
#   read -s -r CM_CLIENT_SECRET; export CM_CLIENT_SECRET
#   export CM_CLIENT_ID=...apps.googleusercontent.com
#   ./gdrive/setup-remote.sh
#
# Klucze trafiaja wylacznie do ~/.config/rclone/rclone.conf. To repo jest
# publiczne - nic z sekretami tu nie wchodzi.
#
# Skad wziac klucze: console.developers.google.com -> nowy projekt ->
# wlacz "Google Drive API" -> ekran zgody OAuth -> dane logowania ->
# "OAuth 2.0", typ aplikacji "Desktop".
#
# Po co wlasne: wspoldzielony client_id rclone jest wycofywany i przestanie
# dzialac w trakcie 2026 roku, a Google limituje tempo per client_id - na
# wspoldzielonym konkurujesz ze wszystkimi uzytkownikami rclone naraz.

set -euo pipefail
source "$(dirname "$0")/cm-env.sh"

if [ ! -x "$CM_RCLONE" ]; then
  echo "Brak rclone w $CM_RCLONE - uruchom install-rclone.sh" >&2
  exit 1
fi

: "${CM_CLIENT_ID:?Ustaw CM_CLIENT_ID (z konsoli Google)}"
: "${CM_CLIENT_SECRET:?Ustaw CM_CLIENT_SECRET (z konsoli Google)}"

if "$CM_RCLONE" listremotes | grep -qx "${CM_REMOTE}:"; then
  echo "Remote '${CM_REMOTE}' juz istnieje. Usun go recznie, jesli chcesz zalozyc od nowa:" >&2
  echo "  $CM_RCLONE config delete ${CM_REMOTE}" >&2
  exit 1
fi

echo "Zakladam remote '${CM_REMOTE}'. Otworzy sie przegladarka do zalogowania."
"$CM_RCLONE" config create "$CM_REMOTE" drive \
  client_id="$CM_CLIENT_ID" \
  client_secret="$CM_CLIENT_SECRET" \
  scope=drive

echo
echo "Sprawdzam dostep i wolne miejsce:"
"$CM_RCLONE" about "${CM_REMOTE}:"

echo
echo "Tworze katalog docelowy ${CM_REMOTE}:${CM_REMOTE_PATH}"
"$CM_RCLONE" mkdir "${CM_REMOTE}:${CM_REMOTE_PATH}"

echo
echo "Gotowe. Nastepny krok: mount-drive.sh"
