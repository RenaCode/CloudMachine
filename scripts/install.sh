#!/bin/bash
# Instaluje WSZYSTKO od zera, bez zadnych zalozen o stanie maszyny: Homebrew
# (jesli brak), potem rclone i jq.
#
# Nie instalujemy FUSE/macFUSE/FUSE-T - Homebrew'owy rclone na macOS jest budowany
# bez wsparcia dla `rclone mount` (patrz README.md, sekcja "Ryzyka"), wiec montujemy
# przez `rclone nfsmount` - wbudowany serwer NFS w samym rclone, ktory macOS montuje
# swoim natywnym klientem NFS. Nie wymaga zadnych dodatkowych sterownikow ani
# instalatorow proszacych o haslo administratora.

set -euo pipefail

if ! command -v brew >/dev/null 2>&1; then
  echo "==> Homebrew nie jest zainstalowany - instaluje go teraz (poprosi o haslo administratora)"
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  else
    echo "BLAD: instalacja Homebrew nie powiodla sie."
    exit 1
  fi
fi

echo "==> Instaluje rclone i jq"
brew install rclone jq

echo "==> Gotowe. Nastepny krok: scripts/configure-remote.sh"
