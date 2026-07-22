#!/bin/bash
# Pakuje zbudowane CloudMachine.app (patrz build-app.sh) do instalatora .dmg
# z przeciagalnym skrotem do /Applications.

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
MAC_APP_ROOT="$(pwd)"

APP_NAME="CloudMachine"
BUILD_DIR="$MAC_APP_ROOT/build"
APP_BUNDLE="$BUILD_DIR/${APP_NAME}.app"
STAGING_DIR="$BUILD_DIR/dmg-staging"
VERSION="$(cat "$MAC_APP_ROOT/VERSION" 2>/dev/null || echo "1.0.0")"
DMG_PATH="$BUILD_DIR/${APP_NAME}-${VERSION}.dmg"

if [ ! -d "$APP_BUNDLE" ]; then
  echo "BLAD: brak $APP_BUNDLE - uruchom najpierw scripts/build-app.sh"
  exit 1
fi

echo "==> Przygotowuje folder staging"
rm -rf "$STAGING_DIR" "$DMG_PATH"
mkdir -p "$STAGING_DIR"
cp -R "$APP_BUNDLE" "$STAGING_DIR/"
ln -s /Applications "$STAGING_DIR/Applications"

echo "==> Tworze $DMG_PATH"
hdiutil create -volname "$APP_NAME" -srcfolder "$STAGING_DIR" -ov -format UDZO "$DMG_PATH"

rm -rf "$STAGING_DIR"

echo "==> Gotowe: $DMG_PATH"
cat <<EOF

Przy pierwszym uruchomieniu (appka niepodpisana kontem Apple Developer):
1. Otworz $DMG_PATH i przeciagnij CloudMachine.app do Applications.
2. W Finderze kliknij CloudMachine.app PRAWYM przyciskiem -> Otworz -> Otworz
   (samo dwuklikniecie pokaze blokade Gatekeepera "niezidentyfikowany deweloper").
3. Kolejne uruchomienia dzialaja juz normalnie, dwuklikiem.
EOF
