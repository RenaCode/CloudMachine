#!/bin/bash
# Testuje orkiestracje launchd bez Google Drive i bez FUSE-T.
#
# W miejsce rclone podstawia zaslepke, ktora podpina lokalny obraz pod ta sama
# sciezke i zostaje na pierwszym planie - tak samo zachowuje sie prawdziwy
# `rclone mount`. Dzieki temu da sie sprawdzic to, co w tej ukladance jest
# niezalezne od chmury:
#   - czy plisty w ogole sie laduja,
#   - czy agent podpinajacy poprawnie czeka na bufor zamiast wyscigowac sie z nim,
#   - czy KeepAlive podnosi bufor po padnieciu.
#
# Etykiety sa wlasne (poc-*), zeby nie kolidowaly z produkcyjnymi agentami.

set -euo pipefail

POC_ROOT="${POC_ROOT:-/tmp/cm-launchd}"
LABEL_MOUNT="com.renacode.cloudmachine.poc-mount"
LABEL_ATTACH="com.renacode.cloudmachine.poc-attach"
LA="$HOME/Library/LaunchAgents"
HERE="$(cd "$(dirname "$0")" && pwd)"
GUI="gui/$(id -u)"

export CM_ROOT="$POC_ROOT/home"
export CM_VOLNAME="CloudMachineLaunchdPOC"
export CM_IMAGE_NAME="poc"
export CM_IMAGE_SIZE="20g"
source "$HERE/cm-env.sh"

teardown() {
  launchctl bootout "$GUI/$LABEL_ATTACH" 2>/dev/null || true
  launchctl bootout "$GUI/$LABEL_MOUNT" 2>/dev/null || true
  sleep 1
  rm -f "$LA/$LABEL_MOUNT.plist" "$LA/$LABEL_ATTACH.plist"
  hdiutil detach "$CM_TARGET" -force -quiet 2>/dev/null || true
  hdiutil detach "$CM_MOUNT" -force -quiet 2>/dev/null || true
}

[ "${1:-}" = "clean" ] && { teardown; rm -rf "$POC_ROOT"; echo "Posprzatane."; exit 0; }
trap teardown EXIT

step() { printf '\n\033[1m== %s ==\033[0m\n' "$1"; }

step "Piaskownica"
teardown; rm -rf "$POC_ROOT"; mkdir -p "$CM_MOUNT" "$CM_CACHE"
hdiutil create -type SPARSE -size 30g -fs APFS -volname LaunchdStandIn \
  "$POC_ROOT/stand-in.sparseimage" >/dev/null

# Zaslepka rclone: podpina zastepnik i zostaje na pierwszym planie.
cat > "$POC_ROOT/stub-mount.sh" <<STUB
#!/bin/bash
set -euo pipefail
export CM_ROOT="$CM_ROOT"
source "$HERE/cm-env.sh"
cm_is_mounted && exit 0
tmutil addexclusion "\$CM_ROOT" 2>/dev/null || true
hdiutil attach "$POC_ROOT/stand-in.sparseimage" -mountpoint "\$CM_MOUNT" -nobrowse >/dev/null
echo "zaslepka: podpieta \$(date +%T)"
while cm_is_mounted; do sleep 2; done
echo "zaslepka: montowanie zniknelo, koncze"
STUB
chmod +x "$POC_ROOT/stub-mount.sh"
echo "gotowa"

step "Generuje i laduje agenty"
sed -e "s|__REPO__/gdrive/mount-drive.sh|$POC_ROOT/stub-mount.sh|" \
    -e "s|__HOME__|$POC_ROOT|g" \
    -e "s|$LABEL_MOUNT|$LABEL_MOUNT|" \
    -e "s|com.renacode.cloudmachine.gdrive|$LABEL_MOUNT|" \
    "$HERE/com.renacode.cloudmachine.gdrive.plist.template" > "$LA/$LABEL_MOUNT.plist"
sed -e "s|__REPO__|$HERE/..|" -e "s|__HOME__|$POC_ROOT|g" \
    -e "s|com.renacode.cloudmachine.gdrive-attach|$LABEL_ATTACH|" \
    "$HERE/com.renacode.cloudmachine.gdrive-attach.plist.template" > "$LA/$LABEL_ATTACH.plist"

# Agent podpinajacy musi dostac te sama piaskownice.
/usr/libexec/PlistBuddy -c "Add :EnvironmentVariables:CM_ROOT string $CM_ROOT" \
  -c "Add :EnvironmentVariables:CM_VOLNAME string $CM_VOLNAME" \
  -c "Add :EnvironmentVariables:CM_IMAGE_NAME string $CM_IMAGE_NAME" \
  "$LA/$LABEL_ATTACH.plist" >/dev/null

plutil -lint "$LA/$LABEL_MOUNT.plist" && plutil -lint "$LA/$LABEL_ATTACH.plist"
mkdir -p "$POC_ROOT/.cloudmachine"

launchctl bootstrap "$GUI" "$LA/$LABEL_MOUNT.plist"
echo "zaladowany: $LABEL_MOUNT"

step "Czy bufor wstal"
for _ in $(seq 1 15); do cm_is_mounted && break; sleep 1; done
cm_is_mounted && echo "TAK - $CM_MOUNT" || { echo "NIE"; exit 1; }

step "Tworze obraz i laduje agenta podpinajacego"
"$HERE/create-image.sh" >/dev/null
launchctl bootstrap "$GUI" "$LA/$LABEL_ATTACH.plist"
for _ in $(seq 1 20); do cm_is_attached && break; sleep 1; done
cm_is_attached && echo "podpiete: $CM_TARGET" || { echo "NIE podpiete"; cat "$POC_ROOT/.cloudmachine/launchd-attach.err.log" 2>/dev/null; exit 1; }

step "KeepAlive: zabijam bufor i patrze, czy wroci"
PID=$(launchctl print "$GUI/$LABEL_MOUNT" 2>/dev/null | awk '/pid = / {print $3}')
echo "pid zaslepki: ${PID:-brak}"
hdiutil detach "$CM_TARGET" -force -quiet 2>/dev/null || true
[ -n "${PID:-}" ] && kill -9 "$PID" 2>/dev/null || true
hdiutil detach "$CM_MOUNT" -force -quiet 2>/dev/null || true
echo "czekam na restart (ThrottleInterval 30 s)..."
OK=0
for _ in $(seq 1 50); do cm_is_mounted && { OK=1; break; }; sleep 2; done
[ "$OK" = 1 ] && echo "WROCIL - KeepAlive dziala" || echo "NIE WROCIL"

step "Wynik"
[ "$OK" = 1 ] && echo "Orkiestracja launchd dziala." || { echo "Orkiestracja zawodzi."; exit 1; }
