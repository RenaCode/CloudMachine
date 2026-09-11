#!/bin/bash
# Zaklada remote rclone wskazujacy na Google Drive.
#
# Klucze OAuth siedza w Keychainie macOS pod usluga "cloudmachine-gdrive", nie
# w pliku i nie w zmiennych srodowiskowych. Keychain jest zaszyfrowany na dysku
# i otwiera sie razem z logowaniem, wiec skrypt bierze je sam:
#
#   ./gdrive/setup-remote.sh
#
# Zalozenie kluczy w Keychainie (raz), bez podawania ich w argumentach:
#   security add-generic-password -a client_id     -s cloudmachine-gdrive -w -U
#   security add-generic-password -a client_secret -s cloudmachine-gdrive -w -U
# Bez -w z wartoscia `security` zapyta interaktywnie i nic nie trafi do
# historii powloki ani do `ps`.
#
# Zmienne CM_CLIENT_ID / CM_CLIENT_SECRET nadal dzialaja i maja pierwszenstwo,
# gdyby Keychain byl niedostepny.
#
# Skad wziac klucze: console.developers.google.com -> nowy projekt ->
# wlacz "Google Drive API" -> ekran zgody OAuth -> dane logowania ->
# "OAuth 2.0", typ aplikacji "Desktop".
#
# Po co wlasne: wspoldzielony client_id rclone jest wycofywany i przestanie
# dzialac w trakcie 2026 roku, a Google limituje tempo per client_id - na
# wspoldzielonym konkurujesz ze wszystkimi uzytkownikami rclone naraz.
#
# To repo jest publiczne - nic z sekretami tu nie wchodzi.

set -euo pipefail
source "$(dirname "$0")/cm-env.sh"

if [ ! -x "$CM_RCLONE" ]; then
  echo "Brak rclone w $CM_RCLONE - uruchom install-rclone.sh" >&2
  exit 1
fi

CM_KEYCHAIN_SERVICE="${CM_KEYCHAIN_SERVICE:-cloudmachine-gdrive}"

from_keychain() {
  security find-generic-password -a "$1" -s "$CM_KEYCHAIN_SERVICE" -w 2>/dev/null
}

CM_CLIENT_ID="${CM_CLIENT_ID:-$(from_keychain client_id)}"
CM_CLIENT_SECRET="${CM_CLIENT_SECRET:-$(from_keychain client_secret)}"

if [ -z "$CM_CLIENT_ID" ] || [ -z "$CM_CLIENT_SECRET" ]; then
  echo "Brak kluczy OAuth w Keychainie (usluga: $CM_KEYCHAIN_SERVICE)." >&2
  echo "Zaloz je - security zapyta o wartosc, nic nie trafi do historii:" >&2
  echo "  security add-generic-password -a client_id     -s $CM_KEYCHAIN_SERVICE -w -U" >&2
  echo "  security add-generic-password -a client_secret -s $CM_KEYCHAIN_SERVICE -w -U" >&2
  exit 1
fi

echo "Klucze OAuth: z Keychaina (${CM_CLIENT_ID%%-*}...)"

if "$CM_RCLONE" listremotes | grep -qx "${CM_REMOTE}:"; then
  echo "Remote '${CM_REMOTE}' juz istnieje. Usun go recznie, jesli chcesz zalozyc od nowa:" >&2
  echo "  $CM_RCLONE config delete ${CM_REMOTE}" >&2
  exit 1
fi

echo "Zakladam remote '${CM_REMOTE}'. Otworzy sie przegladarka do zalogowania."

# Klucze przez srodowisko, nie przez argumenty: `rclone config create` z
# client_secret= w linii polecen wystawia sekret w `ps` na caly czas czekania
# na zatwierdzenie w przegladarce - czyli na minuty.
#
# Wyjscie idzie do /dev/null, bo rclone wypisuje na koniec gotowa sekcje
# konfiguracji razem z tokenem odswiezajacym. Token daje trwaly dostep do
# calego Dysku, wiec nie ma powodu, zeby ladowal w terminalu, logach czy
# historii sesji. Bledy nadal widac - one ida na stderr.
RCLONE_DRIVE_CLIENT_ID="$CM_CLIENT_ID" \
RCLONE_DRIVE_CLIENT_SECRET="$CM_CLIENT_SECRET" \
"$CM_RCLONE" config create "$CM_REMOTE" drive scope=drive >/dev/null

echo
echo "Sprawdzam dostep i wolne miejsce:"
"$CM_RCLONE" about "${CM_REMOTE}:"

echo
echo "Tworze katalog docelowy ${CM_REMOTE}:${CM_REMOTE_PATH}"
"$CM_RCLONE" mkdir "${CM_REMOTE}:${CM_REMOTE_PATH}"

echo
echo "Gotowe. Nastepny krok: mount-drive.sh"
