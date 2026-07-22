#!/bin/bash
# Prowadzi przez konfiguracje polaczenia z Google Drive w rclone (OAuth w przegladarce)
# i tworzy folder tej maszyny na koncie Drive.
#
# Uruchom raz na kazdym Macu. Wymaga config/machines.json (patrz machines.example.json)
# oraz wpisu dla tej maszyny (nazwa = scutil --get ComputerName, znormalizowana).

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ./common.sh

cm_require_config
cm_require_jq

REMOTE_NAME="$(cm_remote_name)"
ROOT_FOLDER="$(cm_remote_root_folder)"
MACHINE_KEY="$(cm_machine_key)"

cm_log "Ta maszyna zostala rozpoznana jako: $MACHINE_KEY"
LIMIT_GB="$(cm_machine_limit_gb "$MACHINE_KEY")"
cm_log "Limit dla tej maszyny w config/machines.json: ${LIMIT_GB} GB"

if rclone listremotes | grep -q "^${REMOTE_NAME}:$"; then
  cm_log "Remote '${REMOTE_NAME}' juz istnieje w rclone, pomijam kreator OAuth."
else
  cm_log "Uruchamiam kreator rclone dla nowego remote '${REMOTE_NAME}' (typ: drive)."
  echo ""
  echo "W kreatorze wybierz:"
  echo "  n) New remote"
  echo "  name> ${REMOTE_NAME}"
  echo "  Storage> drive (Google Drive)"
  echo "  client_id / client_secret> zostaw puste (Enter), chyba ze masz wlasne z Google Cloud Console"
  echo "  scope> 1 (pelny dostep do wlasnego Drive)"
  echo "  root_folder_id> zostaw puste"
  echo "  Auto config> y (otworzy przegladarke do logowania Google)"
  echo ""
  rclone config
fi

cm_log "Tworze folder ${ROOT_FOLDER}/${MACHINE_KEY} na Google Drive (jesli nie istnieje)."
rclone mkdir "$(cm_remote_path_for "$MACHINE_KEY")"

cm_log "Gotowe. Sprawdzam polaczenie (rclone about):"
rclone about "${REMOTE_NAME}:" || cm_log "UWAGA: 'rclone about' nie zwrocilo danych - niektóre konta Google nie udostepniają tej statystyki, to nie jest blad krytyczny."

cm_log "Nastepny krok: scripts/mount.sh"
