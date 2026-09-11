#!/bin/bash
# Podpina obraz jako /Volumes/CloudMachine. Uruchamiane przy kazdym starcie,
# po tym jak mount-drive.sh postawi montowanie.

set -euo pipefail
source "$(dirname "$0")/cm-env.sh"

# Time Machine nie moze zobaczyc celu, zanim bufor bedzie gotowy - inaczej
# uzna, ze dysk backupu zniknal.
for _ in $(seq 1 60); do
  cm_is_mounted && break
  sleep 2
done

if ! cm_is_mounted; then
  echo "Drive nie wstal w $CM_MOUNT po 120 s - przerywam" >&2
  exit 1
fi

if cm_is_attached; then
  echo "Juz podpiety: $CM_TARGET"
  exit 0
fi

if [ ! -d "$CM_IMAGE" ]; then
  echo "Brak obrazu $CM_IMAGE - najpierw create-image.sh" >&2
  exit 1
fi

hdiutil attach "$CM_IMAGE" \
  -nobrowse \
  -mountpoint "$CM_TARGET"

echo "Podpiete: $CM_TARGET"
