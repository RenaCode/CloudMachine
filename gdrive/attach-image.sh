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

# Zombie po poprzednim, nieczystym odpieciu blokuje ponowne podpiecie
# komunikatem "no mountable file systems". Zaobserwowane w poc-pullplug.sh.
if [ -n "$(cm_devices_for_image "$CM_IMAGE")" ]; then
  echo "Usuwam zawieszone urzadzenia po poprzednim podpieciu"
  cm_purge_stale_devices "$CM_IMAGE"
  sleep 2
fi

# Osierocony punkt montowania po nieczystym odpieciu blokuje podpiecie.
# Jesli lezy w /Volumes, usuniecie wymaga roota - dlatego mowimy dokladnie, co
# uruchomic, zamiast ponawiac w nieskonczonosc.
if [ -d "$CM_TARGET" ] && ! cm_is_attached; then
  if rmdir "$CM_TARGET" 2>/dev/null; then
    echo "Usunieto osierocony punkt montowania $CM_TARGET"
  else
    echo "Osierocony punkt montowania blokuje podpiecie: $CM_TARGET" >&2
    echo "Usun go i uruchom ponownie:" >&2
    echo "  sudo rmdir '$CM_TARGET'" >&2
    exit 1
  fi
fi

cm_wait_quiet 120 || true

cm_attach() {
  hdiutil attach "$CM_IMAGE" -nobrowse -mountpoint "$CM_TARGET"
}

if ! cm_retry 5 cm_attach; then
  echo "Nie udalo sie podpiac obrazu po 5 probach." >&2
  exit 1
fi

echo "Podpiete: $CM_TARGET"
