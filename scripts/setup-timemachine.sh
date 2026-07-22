#!/bin/bash
# Rejestruje zamontowany wolumin wirtualny sparsebundle jako cel Time Machine (tmutil setdestination).
# Wymaga wczesniejszego uruchomienia mount.sh i uprawnien administratora (sudo).
#
# Uzywa "-a" (dodaj), zeby nie kasowac ewentualnego istniejacego lokalnego dysku TM -
# Time Machine potrafi rotacyjnie/rownolegle korzystac z wielu celow.

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ./common.sh

cm_require_config
MACHINE_KEY="$(cm_machine_key)"
SP_MOUNT="$(cm_sparsebundle_mount_dir "$MACHINE_KEY")"

if ! mount | grep -q "$SP_MOUNT"; then
  cm_log "BLAD: Wirtualny dysk sparsebundle pod $SP_MOUNT nie jest zamontowany. Uruchom najpierw scripts/mount.sh"
  exit 1
fi

cm_log "Rejestruje $SP_MOUNT jako cel Time Machine (wymaga sudo)."
sudo tmutil setdestination -a "$SP_MOUNT"

cm_log "Aktualne cele Time Machine:"
tmutil destinationinfo

cat <<'EOF'

Kolejne kroki:
1. Otworz Ustawienia systemowe -> Time Machine i sprawdz, ze nowy dysk (CloudMachine-Backup) widnieje na liscie.
2. Zrob PIERWSZY test na malym zbiorze danych zanim zaufasz temu z cala reszta dysku -
   patrz README.md sekcja "Plan testowy", zeby nie ryzykowac godzin uploadu do korupcji.
3. Recznie odpal pierwszy backup: sudo tmutil startbackup --auto --block
4. Po zakonczeniu uruchom scripts/verify-backup.sh, zeby sprawdzic integralnosc.
EOF
