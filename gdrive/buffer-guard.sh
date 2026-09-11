#!/bin/bash
# Pilnuje, zeby bufor nie zjadl dysku.
#
# Time Machine pisze do podpietego obrazu z predkoscia SSD, a rclone wysyla
# z predkoscia lacza - u nas ~41 MB/s. Roznica ladu­je w buforze. Limit
# --vfs-cache-max-size jest miekki: rclone usuwa z bufora tylko to, co juz
# wyslal, wiec gdy wszystko czeka w kolejce, bufor rosnie dalej i moze zapelnic
# dysk. Przy pierwszym backupie liczonym w terabajtach to nie teoria.
#
# Dozorca wstrzymuje Time Machine, gdy bufor urosnie ponad prog, i wznawia,
# gdy wysylka go opcni. Backup staje sie wtedy wolniejszy, ale konczy sie
# zamiast wysypac maszyne.
#
# Osobno pilnuje dobowego limitu Google Drive (750 GB). Po jego przekroczeniu
# rclone konczy prace (--drive-stop-on-upload-limit), a agent launchd probuje
# go podniesc - bez sensu, dopoki limit sie nie odnowi. Dozorca to wykrywa
# i mowi wprost, zamiast pozwolic systemowi kreci sie w kolko.

set -uo pipefail
source "$(dirname "$0")/cm-env.sh"

HIGH_GB="${CM_BUFFER_HIGH:-150}"   # powyzej tego wstrzymujemy Time Machine
LOW_GB="${CM_BUFFER_LOW:-40}"      # ponizej tego wznawiamy
INTERVAL="${CM_GUARD_INTERVAL:-30}"
FREE_MIN_GB="${CM_FREE_MIN:-80}"   # ponizej tego wstrzymujemy niezaleznie od bufora

cache_gb() { du -sk "$CM_CACHE" 2>/dev/null | awk '{printf "%d", $1/1048576}'; }
free_gb()  { df -k /System/Volumes/Data | awk 'NR==2 {printf "%d", $4/1048576}'; }
tm_running() { tmutil status 2>/dev/null | grep -q "Running = 1"; }
tm_percent() { tmutil status 2>/dev/null | awk -F'= ' '/"_raw_Percent"/ {gsub(/[";]/,"",$2); printf "%.1f", $2*100}'; }

quota_hit() {
  [ -f "$CM_LOG" ] || return 1
  tail -200 "$CM_LOG" 2>/dev/null | grep -qiE "quota|userRateLimitExceeded|storageQuotaExceeded|upload limit"
}

paused=0
echo "dozorca: prog $HIGH_GB GB / wznowienie $LOW_GB GB / min. wolnego $FREE_MIN_GB GB"

while :; do
  c=$(cache_gb); f=$(free_gb); p=$(tm_percent)
  [ -z "$p" ] && p="?"

  if quota_hit; then
    echo "LIMIT GOOGLE: dobowy limit uploadu wyczerpany - wysylka wstrzymana do odnowienia"
    if [ "$paused" -eq 0 ] && tm_running; then
      tmutil stopbackup 2>/dev/null; paused=1
      echo "  wstrzymano Time Machine, zeby bufor nie rosl bez odbioru"
    fi
    sleep 300; continue
  fi

  if [ "$paused" -eq 0 ]; then
    if [ "$c" -ge "$HIGH_GB" ] || [ "$f" -le "$FREE_MIN_GB" ]; then
      tmutil stopbackup 2>/dev/null
      paused=1
      echo "PAUZA: bufor ${c} GB, wolne ${f} GB, postep ${p}% - czekam na wysylke"
    fi
  else
    if [ "$c" -le "$LOW_GB" ]; then
      tmutil startbackup 2>/dev/null
      paused=0
      echo "WZNOWIENIE: bufor ${c} GB, wolne ${f} GB, postep ${p}%"
    fi
  fi

  if [ "$paused" -eq 0 ] && ! tm_running; then
    echo "KONIEC: Time Machine zakonczyl. Bufor ${c} GB, postep ${p}%"
    echo "Czekam na oproznienie bufora..."
    while ! cm_vfs_quiet; do sleep 30; done
    echo "Bufor opróżniony - wszystko na Google Drive."
    exit 0
  fi

  sleep "$INTERVAL"
done
