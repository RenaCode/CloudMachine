#!/bin/bash
# Tworzy jednorazowy, lokalny certyfikat self-signed do podpisywania
# CloudMachine.app, zeby uprawnienia TCC (Pelny dostep do dysku itp.)
# PRZETRWALY kolejne przebudowy appki.
#
# Domyslny podpis ad-hoc w build-app.sh (uzywany gdy nie ma konta Apple
# Developer) generuje NOWY hash tozsamosci (CDHash) przy kazdym rebuildzie,
# wiec macOS traktuje kazda przebudowana wersje jak zupelnie inna appke i
# cofa jej wczesniej przyznane uprawnienia - stad koniecznosc recznego
# ich przyznawania po kazdej aktualizacji.
#
# Ten certyfikat jest czysto lokalny: nie jest nigdzie wysylany, nie jest
# zaufany przez nikogo poza tym Makiem, i sluzy WYLACZNIE do podpisywania
# kodu (code signing) - nie do niczego innego. Uruchom ten skrypt RAZ; kazdy
# kolejny scripts/build-app.sh uzyje go automatycznie, jesli istnieje.

set -euo pipefail

CERT_NAME="${CM_SIGNING_CERT_NAME:-CloudMachine Local Signing}"
KEYCHAIN="$HOME/Library/Keychains/login.keychain-db"

if security find-certificate -c "$CERT_NAME" "$KEYCHAIN" >/dev/null 2>&1; then
  echo "Certyfikat '$CERT_NAME' juz istnieje w $KEYCHAIN, nic nie robie."
  exit 0
fi

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

cat > "$WORKDIR/codesign.cnf" <<EOF
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no
[req_distinguished_name]
CN = $CERT_NAME
[v3_req]
keyUsage = critical, digitalSignature
extendedKeyUsage = critical, codeSigning
basicConstraints = critical, CA:false
EOF

echo "==> Generuje klucz i certyfikat self-signed '$CERT_NAME'..."
openssl req -x509 -newkey rsa:2048 -keyout "$WORKDIR/key.pem" -out "$WORKDIR/cert.pem" \
  -days 3650 -nodes -config "$WORKDIR/codesign.cnf" -sha256

# -legacy: OpenSSL 3.x domyslnie szyfruje PKCS12 algorytmami (AES-256+SHA-256
# MAC), ktorych macOS'owy Security framework (`security import`) nie rozumie -
# bez tej flagi import konczy sie mylacym "MAC verification failed (wrong
# password?)" mimo poprawnego hasla. -legacy wraca do 3DES/RC2, ktore macOS
# poprawnie parsuje.
openssl pkcs12 -export -legacy -out "$WORKDIR/cert.p12" -inkey "$WORKDIR/key.pem" -in "$WORKDIR/cert.pem" \
  -passout pass:cloudmachine-local

echo "==> Importuje certyfikat do $KEYCHAIN (z gory autoryzuje /usr/bin/codesign, bez pytania o haslo keychaina za kazdym razem)..."
security import "$WORKDIR/cert.p12" -k "$KEYCHAIN" -P cloudmachine-local -T /usr/bin/codesign -T /usr/bin/security

echo "==> Ufam certyfikatowi WYLACZNIE do podpisywania kodu (code signing)..."
security add-trusted-cert -r trustRoot -p codeSign -k "$KEYCHAIN" "$WORKDIR/cert.pem"

echo
echo "Gotowe. Certyfikat '$CERT_NAME' jest teraz dostepny dla codesign."
echo "Nastepny scripts/build-app.sh uzyje go automatycznie zamiast podpisu ad-hoc."
echo "Po TYM JEDNYM rebuildzie przyznaj Pelny dostep do dysku ostatni raz - kolejne"
echo "przebudowy juz go nie zresetuja, dopoki podpisujesz tym samym certyfikatem."
