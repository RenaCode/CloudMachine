#!/bin/sh
# Live check of the 27.11.2026 fix, run INSIDE the machine (limactl shell cmsmb)
# with no backup running. The chain is revived by cm-smb-heal.timer (every 60 s)
# from the STATE, not from systemd events:
#   - kill -9 of rclone or punchfs brings rclone-tm, punchfs, tm-bands-bind and
#     smbd back by themselves;
#   - a smbd stopped on purpose (fresh hold marker) stays stopped, an EXPIRED
#     marker (older than 120 min) does not hide a dead smbd, the persistent
#     attention file blocks it until removed (the healer starts with --no-block,
#     so it never hangs past its 60 s period);
#   - a failing bind, once repaired, brings smbd back;
#   - kill -9 leaves a DEAD FUSE mount behind (28.11.2026, "Transport endpoint is
#     not connected"): the units clear it themselves (cm-unmount-stale), no manual
#     umount, and everything is back within 3 minutes.
#
#   sudo sh restart-chain.sh
set -eu
HOLD=/run/cloudmachine-smbd-hold
ATTENTION=/var/lib/cloudmachine/smbd-attention

wait_active() { # unit, seconds
  i=0
  while [ "$i" -lt "$2" ]; do
    [ "$(systemctl is-active "$1")" = active ] && return 0
    i=$((i + 5)); sleep 5
  done
  echo "FAIL: $1 not active after $2 s ($(systemctl is-active "$1"))"; return 1
}
# kill -9 the main process of a unit, then wait until systemd has really restarted it:
# right after the kill every unit is still "active" (RestartSec window), so a check
# made at once passes or fails on the OLD state (28.11.2026).
kill_and_wait() { # unit, seconds
  old=$(systemctl show -p MainPID --value "$1.service")
  [ -n "$old" ] && [ "$old" != 0 ] || { echo "FAIL: $1 has no main process"; return 1; }
  kill -9 "$old"
  i=0
  while [ "$i" -lt "$2" ]; do
    pid=$(systemctl show -p MainPID --value "$1.service")
    [ "$pid" != "$old" ] && [ "$pid" != 0 ] && return 0
    i=$((i + 2)); sleep 2
  done
  echo "FAIL: $1 did not restart within $2 s (MainPID $old)"; return 1
}
wait_ok() { # seconds, description, command...
  t=$1; d=$2; shift 2
  i=0
  while [ "$i" -lt "$t" ]; do
    "$@" >/dev/null 2>&1 && return 0
    i=$((i + 5)); sleep 5
  done
  echo "FAIL: $d"; return 1
}
all_up() {
  for u in rclone-tm punchfs tm-bands-bind smbd; do wait_active "$u" "$1" || return 1; done
  wait_ok "$1" "/srv/tm-punch not mounted" mountpoint -q /srv/tm-punch || return 1
  wait_ok "$1" "bands unreadable" ls /srv/tm-punch/bands || return 1
}

echo "0. the healer timer runs"
[ "$(systemctl is-active cm-smb-heal.timer)" = active ] || { echo "FAIL: cm-smb-heal.timer"; exit 1; }
rm -f "$HOLD"

echo "1. baseline"; all_up 30
echo "2. kill -9 rclone (what the OOM killer does)"
kill_and_wait rclone-tm 120
all_up 900   # rclone scans the VFS cache before it mounts: minutes
echo "2b. the same kill leaves a DEAD mount; nobody unmounts it by hand, all is back in 3 min"
kill_and_wait rclone-tm 60 || exit 1
if timeout 5 stat -t /srv/tm >/dev/null 2>&1; then echo "   (rclone was already back: no dead mount this time)"; else echo "   /srv/tm is dead right after the kill, as expected"; fi
all_up 180
echo "3. kill -9 punchfs"
kill_and_wait punchfs 60
all_up 300
echo "4. smbd stopped on purpose (FRESH marker, as holdSmbd does) must STAY stopped"
touch "$HOLD" && systemctl stop smbd.service
sleep 150                                   # at least two healer runs
[ "$(systemctl is-active smbd)" != active ] || { echo "FAIL: smbd started under a fresh marker"; exit 1; }
echo "5. the same marker EXPIRED (3 h old) must not hide a dead smbd"
touch -d '3 hours ago' "$HOLD"
wait_active smbd 150
[ ! -e "$HOLD" ] || { echo "FAIL: expired marker left behind"; exit 1; }
echo "6. the persistent attention file (failed conversion): never auto-started, even after a reboot-like restart"
mkdir -p /var/lib/cloudmachine; echo attention > "$ATTENTION"; systemctl stop smbd.service
sleep 150
[ "$(systemctl is-active smbd)" != active ] || { echo "FAIL: smbd started under attention"; exit 1; }
systemctl start smbd.service                # skipped by ConditionPathExists=!
[ "$(systemctl is-active smbd)" != active ] || { echo "FAIL: smbd ignored the attention file"; exit 1; }
rm -f "$ATTENTION"                          # what a new attempt (holdSmbd) does
wait_active smbd 150                        # the healer starts it again
all_up 60
echo "7. a FAILING bind, then its repair: Samba comes back by itself (27 Nov incident)"
d=/run/systemd/system/tm-bands-bind.service.d
mkdir -p "$d"
trap 'rm -rf "$d"; systemctl daemon-reload' EXIT
printf '[Service]\nExecStartPre=/bin/false\n' > "$d/cm-test-fail.conf"
systemctl daemon-reload
systemctl restart punchfs.service || true
sleep 130                                   # more than two healer periods
[ "$(systemctl is-active smbd)" != active ] || { echo "FAIL: smbd up with a failing bind"; exit 1; }
rm -rf "$d"; systemctl daemon-reload        # repair
all_up 300                                  # bind retry (15 s) + healer (<= 60 s) + margin
echo "OK"
