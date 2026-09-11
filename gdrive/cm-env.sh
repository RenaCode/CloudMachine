#!/bin/bash
# Wspolna konfiguracja dla warstwy Google Drive.
# Kazda wartosc da sie nadpisac zmienna srodowiskowa przed uruchomieniem skryptu.

CM_REMOTE="${CM_REMOTE:-gdrive}"                      # nazwa remote'a w rclone.conf
CM_REMOTE_PATH="${CM_REMOTE_PATH:-CloudMachine/mac-studio}"
CM_ROOT="${CM_ROOT:-$HOME/.cloudmachine}"
CM_MOUNT="$CM_ROOT/drive"                             # tu widac zawartosc Drive'a
CM_CACHE="$CM_ROOT/cache"                             # bufor zapisu
CM_LOG="$CM_ROOT/rclone.log"
CM_CACHE_SIZE="${CM_CACHE_SIZE:-100G}"

CM_IMAGE_NAME="${CM_IMAGE_NAME:-mac-studio}"
CM_IMAGE_SIZE="${CM_IMAGE_SIZE:-1500g}"               # rozmiar deklarowany, obraz jest rzadki
CM_VOLNAME="${CM_VOLNAME:-CloudMachine}"
CM_IMAGE="$CM_MOUNT/$CM_IMAGE_NAME.sparsebundle"
CM_TARGET="/Volumes/$CM_VOLNAME"

# 64 MB na pasmo, podane w sektorach po 512 B.
# Powod: Google Drive przepuszcza okolo 2 operacji na plik na sekunde i ma limit
# 400 000 plikow. Domyslne pasma 8 MB daloby ~25 000 plikow na 200 GB backupu,
# 64 MB schodzi do ~3 200. Cena: kazda zmiana w pasmie to wyslanie calych 64 MB.
CM_BAND_SECTORS="${CM_BAND_SECTORS:-131072}"

cm_is_mounted() {
  /sbin/mount | grep -q " on $CM_MOUNT "
}

cm_is_attached() {
  [ -d "$CM_TARGET" ] && /sbin/mount | grep -q " on $CM_TARGET "
}
