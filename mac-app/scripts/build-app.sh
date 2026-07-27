#!/bin/bash
# Buduje CloudMachine.app (Release) z pakietu SwiftUI (Swift Package Manager) -
# GUI (CloudMachineApp) ORAZ CLI (cloudmachine-agent, wolany przez launchd
# zamiast dawnych skryptow bash) trafiaja jako dwie binarki w tym samym
# Contents/MacOS/, plus szablony launchd/config jako Resources - appka jest
# wiec w pelni samodzielna, nie wymaga osobno sklonowanego repo obok.
#
# Podpisuje lokalnym certyfikatem (patrz setup-local-signing-cert.sh), jesli
# istnieje - a w przeciwnym razie ad-hoc (bez konta Apple Developer). Podpis
# ad-hoc generuje NOWY hash tozsamosci przy kazdym rebuildzie, wiec macOS
# cofa uprawnienia TCC (np. Pelny dostep do dysku) po kazdej przebudowie;
# stabilny lokalny certyfikat rozwiazuje ten problem raz na zawsze. Przy
# pierwszym uruchomieniu i tak Gatekeeper pokaze ostrzezenie "niezidentyfikowany
# deweloper" (patrz README.md), niezaleznie od tego, ktora sciezke wybierzesz.

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
MAC_APP_ROOT="$(pwd)"
PROJECT_ROOT="$(cd .. && pwd)"

APP_NAME="CloudMachine"
BUILD_DIR="$MAC_APP_ROOT/build"
APP_BUNDLE="$BUILD_DIR/${APP_NAME}.app"

VERSION="$(cat "$MAC_APP_ROOT/VERSION" 2>/dev/null || echo "1.0.0")"
BUILD_NUMBER="$(git -C "$PROJECT_ROOT" rev-list --count HEAD 2>/dev/null || date +%Y%m%d%H%M)"

echo "==> Buduje CloudMachineApp + cloudmachine-agent (release) - wersja ${VERSION} (${BUILD_NUMBER})"
swift build -c release --package-path "$MAC_APP_ROOT"

APP_BIN_PATH="$MAC_APP_ROOT/.build/release/${APP_NAME}App"
AGENT_BIN_PATH="$MAC_APP_ROOT/.build/release/cloudmachine-agent"
for p in "$APP_BIN_PATH" "$AGENT_BIN_PATH"; do
  if [ ! -f "$p" ]; then
    echo "BLAD: nie znaleziono zbudowanej binarki pod $p"
    exit 1
  fi
done

echo "==> Skladam .app bundle w $APP_BUNDLE"
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS" "$APP_BUNDLE/Contents/Resources"

cp "$APP_BIN_PATH" "$APP_BUNDLE/Contents/MacOS/${APP_NAME}"
# cloudmachine-agent siedzi OBOK glownej binarki GUI w tym samym Contents/MacOS -
# to ta binarka wola launchd (patrz launchd/*.plist.template, __CM_AGENT_BIN__)
# i to na nia wskazuje CMPaths.agentBinaryPath, gdy GUI instaluje agentow.
cp "$AGENT_BIN_PATH" "$APP_BUNDLE/Contents/MacOS/cloudmachine-agent"

sed -e "s|__CM_VERSION__|$VERSION|g" -e "s|__CM_BUILD__|$BUILD_NUMBER|g" \
  "$MAC_APP_ROOT/Resources/Info.plist" > "$APP_BUNDLE/Contents/Info.plist"

# Bundlujemy szablony launchd i przykladowy config jako Resources - to samo,
# czego uzywa wersja CLI-only (patrz CMPaths.resourcesRoot).
cp -R "$PROJECT_ROOT/launchd" "$APP_BUNDLE/Contents/Resources/launchd"
mkdir -p "$APP_BUNDLE/Contents/Resources/config"
cp "$PROJECT_ROOT/config/machines.example.json" "$APP_BUNDLE/Contents/Resources/config/machines.example.json"

if [ ! -f "$MAC_APP_ROOT/Resources/AppIcon.icns" ]; then
  echo "BLAD: brak Resources/AppIcon.icns - wygeneruj go: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns"
  exit 1
fi
cp "$MAC_APP_ROOT/Resources/AppIcon.icns" "$APP_BUNDLE/Contents/Resources/AppIcon.icns"

CM_SIGNING_CERT_NAME="${CM_SIGNING_CERT_NAME:-CloudMachine Local Signing}"
if security find-certificate -c "$CM_SIGNING_CERT_NAME" >/dev/null 2>&1; then
  echo "==> Podpisuje lokalnym certyfikatem '$CM_SIGNING_CERT_NAME' (Pelny dostep do dysku przetrwa kolejne przebudowy)"
  codesign --force --deep --sign "$CM_SIGNING_CERT_NAME" "$APP_BUNDLE"
else
  echo "==> Podpisuje ad-hoc (bez konta Apple Developer) - uruchom raz scripts/setup-local-signing-cert.sh, zeby uprawnienia TCC przetrwaly kolejne przebudowy"
  codesign --force --deep --sign - "$APP_BUNDLE"
fi

echo "==> Gotowe: $APP_BUNDLE"
echo "Nastepny krok: scripts/make-dmg.sh"
