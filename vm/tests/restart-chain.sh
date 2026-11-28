#!/bin/sh
# Live check of the 27.11.2026 fix, run INSIDE the machine (limactl shell cmsmb)
# with no backup running: killing rclone must bring rclone-tm, punchfs,
# tm-bands-bind and smbd back by themselves, and a smbd that was stopped on
# purpose must stay stopped.
#
#   sudo sh restart-chain.sh
set -eu

wait_active() { # unit, seconds
  i=0
  while [ "$i" -lt "$2" ]; do
    [ "$(systemctl is-active "$1")" = active ] && return 0
    i=$((i + 5)); sleep 5
  done
  echo "FAIL: $1 not active after $2 s ($(systemctl is-active "$1"))"; return 1
}
all_up() {
  for u in rclone-tm punchfs tm-bands-bind smbd; do wait_active "$u" "$1" || return 1; done
  mountpoint -q /srv/tm-punch || { echo "FAIL: /srv/tm-punch not mounted"; return 1; }
  ls /srv/tm-punch/bands >/dev/null || { echo "FAIL: bands unreadable"; return 1; }
}

echo "1. baseline"; all_up 30
echo "2. kill -9 rclone (what the OOM killer does)"
kill -9 "$(systemctl show -p MainPID --value rclone-tm.service)"
all_up 600   # rclone scans the VFS cache before it mounts: minutes
echo "3. smbd stopped on purpose must STAY stopped across a punchfs restart"
# the app's deliberate stop: marker first (VMLayout.holdSmbd)
touch /run/cloudmachine-smbd-hold && systemctl stop smbd.service
systemctl restart punchfs.service
wait_active tm-bands-bind 180
sleep 20
[ "$(systemctl is-active smbd)" != active ] || { echo "FAIL: smbd was started again"; exit 1; }
systemctl start smbd.service   # its ExecStartPost removes the marker
[ ! -e /run/cloudmachine-smbd-hold ] || { echo "FAIL: marker left behind"; exit 1; }
all_up 60
echo "4. a FAILING bind, then its repair: Samba must come back by itself (the 27 Nov incident)"
d=/run/systemd/system/tm-bands-bind.service.d
mkdir -p "$d"
printf '[Service]\nExecStartPre=/bin/false\n' > "$d/cm-test-fail.conf"
trap 'rm -rf "$d"; systemctl daemon-reload' EXIT
systemctl daemon-reload
systemctl restart punchfs.service || true
sleep 40
[ "$(systemctl is-active smbd)" != active ] || { echo "FAIL: smbd up with a failing bind"; exit 1; }
rm -rf "$d"; systemctl daemon-reload   # repair; the bind's retry (15 s) succeeds
all_up 180
echo "OK"
