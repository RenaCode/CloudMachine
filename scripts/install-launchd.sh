#!/bin/bash
# Generuje pliki .plist z podstawiona sciezka projektu i instaluje je jako
# LaunchAgents (uruchamiane w sesji zalogowanego uzytkownika - potrzebne, bo
# montowanie FUSE musi dziac sie w kontekscie uzytkownika, nie systemowym).

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ./common.sh

LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
mkdir -p "$LAUNCH_AGENTS_DIR"

# Migracja: wczesniejsza wersja instalowala "com.renacode.cloudmachine.mount"
# jako KeepAlive+"exec rclone nfsmount" w tle, rownolegle do montowania
# wywolywanego z przycisku "Zamontuj" w apce - dwa niezalezne procesy rclone
# walczyly wtedy o ten sam mountpoint, co powodowalo "serwer nie odpowiada" /
# zawieszenia opisane w README. Ten agent zostal zastapiony przez
# com.renacode.cloudmachine.mount-watchdog (RunAtLoad + cykliczne sprawdzanie
# zdrowia mountu), wiec jesli stary jest nadal zaladowany - usuwamy go.
OLD_MOUNT_PLIST="$LAUNCH_AGENTS_DIR/com.renacode.cloudmachine.mount.plist"
if [ -f "$OLD_MOUNT_PLIST" ]; then
  cm_log "Usuwam przestarzaly agent com.renacode.cloudmachine.mount (zastapiony przez mount-watchdog)."
  launchctl unload "$OLD_MOUNT_PLIST" 2>/dev/null || true
  rm -f "$OLD_MOUNT_PLIST"
fi

for template in ../launchd/*.plist.template; do
  name="$(basename "$template" .template)"
  dest="$LAUNCH_AGENTS_DIR/$name"
  sed -e "s|__CM_ROOT__|$CM_ROOT|g" -e "s|__CM_LOG_DIR__|$CM_LOG_DIR|g" -e "s|__CM_CONFIG__|$CM_CONFIG|g" "$template" > "$dest"
  cm_log "Wygenerowano $dest"

  label="$(basename "$name" .plist)"
  launchctl unload "$dest" 2>/dev/null || true
  launchctl load -w "$dest"
  cm_log "Zaladowano $label przez launchctl"
done

cat <<'EOF'

Sprawdz status:
  launchctl list | grep renacode.cloudmachine

Podglad logow:
  tail -f ~/Library/Logs/CloudMachine/*.log

mount-watchdog sprawdza co 60s, czy wolumin jest zamontowany i realnie
odpowiada, i naprawia go automatycznie (wymuszone odmontowanie + ponowne
zamontowanie) jesli nie - ale tylko dopoki nie klikniesz "Odmontuj".

WAZNE: quota-watchdog uzywa 'sudo tmutil delete' do przycinania starych
backupow. Zeby dzialalo to automatycznie (bez interaktywnego hasla), dodaj
wpis w sudoers ograniczony wylacznie do tmutil - patrz README.md sekcja
"Watchdog i automatyczne kasowanie starych backupow".
EOF
