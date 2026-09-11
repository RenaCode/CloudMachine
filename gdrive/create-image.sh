#!/bin/bash
# Tworzy obraz sparsebundle na zamontowanym Drive. Uruchamiane raz.
#
# Time Machine dostaje do reki zwykly wolumen APFS i nie wie, ze pasma obrazu
# leza w chmurze. Dzieki temu w sciezce zapisu nie ma sieciowego systemu plikow -
# odpada cala klasa awarii, ktore trapia Time Machine po SMB.

set -euo pipefail
source "$(dirname "$0")/cm-env.sh"

if ! cm_is_mounted; then
  echo "Drive nie jest zamontowany w $CM_MOUNT - najpierw mount-drive.sh" >&2
  exit 1
fi

if [ -d "$CM_IMAGE" ]; then
  echo "Obraz juz istnieje: $CM_IMAGE" >&2
  echo "Usun go recznie, jesli chcesz zaczac od zera - to kasuje caly backup." >&2
  exit 1
fi

echo "Tworze $CM_IMAGE"
echo "  rozmiar deklarowany: $CM_IMAGE_SIZE (rzadki - zajmuje tyle, ile zapisane)"
echo "  pasmo: $((CM_BAND_SECTORS * 512 / 1024 / 1024)) MB"

echo "Czekam, az wysylka ucichnie..."
cm_wait_quiet 180 || echo "  (kolejka nadal zajeta, probuje mimo to)"

cm_create() {
  hdiutil create \
    -type SPARSEBUNDLE \
    -size "$CM_IMAGE_SIZE" \
    -fs "Case-sensitive APFS" \
    -volname "$CM_VOLNAME" \
    -imagekey "sparse-band-size=$CM_BAND_SECTORS" \
    "$CM_IMAGE"
}

if ! cm_retry 5 cm_create; then
  echo "Nie udalo sie utworzyc obrazu po 5 probach." >&2
  exit 1
fi

echo
echo "Gotowe. Nastepny krok: attach-image.sh, potem"
echo "  sudo tmutil setdestination $CM_TARGET"
