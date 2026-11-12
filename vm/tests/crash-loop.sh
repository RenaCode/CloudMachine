#!/bin/bash
# Crash-consistency loop for the fsync chain (APFS image on SMB -> Samba ->
# punchfs -> rclone mount/mount2 -> VM disk). Run on the Mac, against a
# DISPOSABLE Lima machine, never against cmsmb:
#
#   limactl create --name cmtest --tty=false --set '.disk="30GiB"' vm/cmsmb.yaml
#   limactl start cmtest
#   vm/tests/crash-loop.sh prepare              # guest: local backend, SMB password, smbd unmasked
#   vm/tests/crash-loop.sh run new 20 OUTDIR    # mount2 + syncfs (the shipped configuration)
#   vm/tests/crash-loop.sh run old 10 OUTDIR    # rclone mount, no syncfs (the configuration before PR #58)
#   limactl delete -f cmtest; rm -rf ~/cmtest-smb
#
# One iteration: attach the sparsebundle APFS image (32 MB bands, as in
# production) from the SMB share, write for a random 5-40 s with
# crash-loop-workload.py (create/overwrite/delete, F_FULLFSYNC after every
# operation, ledger on the local disk), kill -9 the Lima host agent and the
# Virtualization process of the machine (a hard crash, nothing graceful), force
# the Mac side loose, start the machine, put the configuration back, remount,
# `fsck_apfs -n` on the unmounted volume, mount it and compare every file
# with the ledger. Results: OUTDIR/results.tsv, details in OUTDIR/iter-N.log.
#
# Notes: the machine's provisioning rewrites the unit files on every boot, so
# the "old" configuration is applied by editing the units after each boot and
# restarting the services. A damaged image is replaced by a fresh one so the
# loop can go on. Env: CM_LOOP_VM (cmtest), CM_LOOP_SMB_MOUNT (~/cmtest-smb),
# CM_LOOP_SMB_PASSWORD (cmtest), CM_LOOP_SIZE (6g). Takes minutes per iteration.
set -u
VM=${CM_LOOP_VM:-cmtest}
MNT=${CM_LOOP_SMB_MOUNT:-$HOME/cmtest-smb}
PASS=${CM_LOOP_SMB_PASSWORD:-cmtest}
SIZE=${CM_LOOP_SIZE:-6g}
HERE=$(cd "$(dirname "$0")" && pwd)
[ "$VM" = cmsmb ] && { echo "refusing to touch cmsmb" >&2; exit 2; }

gsh() { limactl shell "$VM" sudo bash -c "$1"; }
ts() { date +%H:%M:%S; }

prepare() {
  gsh "set -e
mkdir -p /srv/tm-local-remote
echo 'CM_REMOTE=:local:/srv/tm-local-remote' > /etc/cloudmachine/vm.env
echo '[x]' > /etc/rclone/rclone.conf
printf '$PASS\n$PASS\n' | smbpasswd -a -s tm
systemctl unmask smbd 2>/dev/null || true
systemctl start rclone-tm punchfs smbd
ip -4 -o addr show lima0"
}

guest_ip() { limactl shell "$VM" ip -4 -o addr show lima0 | awk '{print $4}' | cut -d/ -f1; }

# old: rclone mount (fsync is a no-op), punchfs without syncfs. new: as provisioned.
apply_config() {
  if [ "$1" = old ]; then
    gsh "systemctl stop smbd tm-bands-bind punchfs rclone-tm
sed -i 's#rclone mount2#rclone mount#' /etc/systemd/system/rclone-tm.service
sed -i '/^ExecStart=\/bin\/sh/c\\ExecStart=/usr/local/bin/punchfs -f -o source=/srv/tm,allow_other /srv/tm-punch' /etc/systemd/system/punchfs.service
systemctl daemon-reload
systemctl start smbd"
  else
    gsh "systemctl is-active --quiet smbd || systemctl start smbd"
  fi
  sleep 2
  local c
  c=$(gsh "pgrep -a rclone | cut -c1-60; pgrep -a punchfs")
  echo "config check: $c"
  if [ "$1" = old ]; then
    echo "$c" | grep -q 'rclone mount2' && { echo "config old not applied"; return 1; }
    echo "$c" | grep -q 'syncfs=' && { echo "config old not applied"; return 1; }
  else
    echo "$c" | grep -q 'rclone mount2' || { echo "config new not applied"; return 1; }
    echo "$c" | grep -q 'syncfs=' || { echo "config new not applied"; return 1; }
  fi
  return 0
}

mount_smb() {
  mkdir -p "$MNT"
  mount | grep -q " on $MNT " && return 0
  timeout 60 mount_smbfs "//tm:$PASS@$(guest_ip)/CloudMachine" "$MNT"
}

# Creates a fresh image and moves its bands onto punchfs (what vm-prepare-bundle does).
new_image() {
  mount_smb || return 1
  rm -rf "$MNT/loop.sparsebundle" 2>/dev/null
  gsh "systemctl stop smbd; umount -l /srv/tm-local/loop.sparsebundle/bands 2>/dev/null; rm -rf /srv/tm-local/loop.sparsebundle /srv/tm-punch/bands/*; systemctl start smbd"
  umount -f "$MNT" 2>/dev/null; sleep 1; mount_smb || return 1
  (cd "$MNT" && hdiutil create -quiet -type SPARSEBUNDLE -fs APFS -size "$SIZE" -imagekey sparse-band-size=65536 -volname cmloop loop) || return 1
  umount "$MNT" || return 1
  gsh "set -e; systemctl stop smbd; mkdir -p /srv/tm-punch/bands; cp -a /srv/tm-local/loop.sparsebundle/bands/. /srv/tm-punch/bands/
echo CM_BUNDLE=loop.sparsebundle > /etc/cloudmachine/bundle.env; systemctl start tm-bands-bind smbd"
  mount_smb
}

DEV=""; VOLDEV=""
attach_nomount() {
  local out
  out=$(timeout 180 hdiutil attach -nomount -noverify "$MNT/loop.sparsebundle" 2>&1) || { echo "$out"; return 1; }
  echo "$out"
  out=$(echo "$out" | grep '^/dev/')
  DEV=$(echo "$out" | head -1 | awk '{print $1}')
  VOLDEV=$(echo "$out" | tail -1 | awk '{print $1}')
}

vz_pid() {
  local p
  for p in $(pgrep -f com.apple.Virtualization.VirtualMachine); do
    lsof -p "$p" 2>/dev/null | grep -q "/.lima/$VM/" && echo "$p"
  done
}

start_vm() {
  limactl stop -f "$VM" >/dev/null 2>&1
  limactl start "$VM" 2>&1 | tail -2
}

run() {
  local CONFIG=$1 N=$2 OUT=$3 i
  mkdir -p "$OUT"
  [ -f "$OUT/results.tsv" ] || printf 'iter\tconfig\ttime\trun_s\tdirty_kB\twriteback_kB\tops_done\tin_flight\tguest_unclean\tdetach\tattach\tfsck\tmount\tverify\tnotes\n' > "$OUT/results.tsv"
  umount -f "$MNT" 2>/dev/null   # a mount from an earlier run points at a dead machine
  start_vm
  # Clean slate: no bundle, empty backend/cache, so every run starts from the same state.
  gsh "systemctl stop smbd tm-bands-bind punchfs rclone-tm; rm -f /etc/cloudmachine/bundle.env
rm -rf /srv/tm-local-remote/* /var/cache/rclone/* /srv/tm-xattr/* /srv/tm-local/*; systemctl reset-failed"
  apply_config "$CONFIG" || exit 1
  # Always a fresh image per run. (Never delete band files behind rclone's back:
  # its directory cache would still list them and a later boot loses the bands dir.)
  mount_smb && new_image || { echo "image create failed"; exit 1; }
  for i in $(seq 1 "$N"); do
    local L="$OUT/iter-$i.log" ledger="$OUT/ledger-$i.jsonl" notes="" detach=ok attach=ok fsck=- mountr=- verify=- unclean=- dirty=- wb=- ops=0 infl=-
    exec 3>&1 1>"$L" 2>&1
    echo "== iteration $i ($CONFIG) $(ts)"
    # 1. attach + mount, clean up the previous iteration
    mount_smb || notes="$notes smbmount-failed"
    attach_nomount || { attach=FAIL; notes="$notes attach-failed-before-run"; }
    if [ "$attach" = ok ]; then
      diskutil mount "$VOLDEV" || notes="$notes mount-failed-before-run"
      V=/Volumes/cmloop
      touch $V/.metadata_never_index 2>/dev/null
      rm -rf $V/it_* 2>/dev/null
      mkdir -p "$V/it_$i" && sync
      # 2. load
      : > "$ledger"
      python3 "$HERE/crash-loop-workload.py" run "$V/it_$i" "$ledger" $((3<<30)) &
      WL=$!
      T=$((5 + RANDOM % 36)); t0=$(date +%s)
      sleep "$T"
      dirty=$(limactl shell "$VM" grep '^Dirty:' /proc/meminfo | awk '{print $2}')
      wb=$(limactl shell "$VM" grep '^Writeback:' /proc/meminfo | awk '{print $2}')
      # 3. hard kill: hostagent and VZ process, SIGKILL
      HA=$(cat ~/.lima/$VM/ha.pid); VZ=$(vz_pid)
      echo "killing ha=$HA vz=$VZ"
      kill -9 $HA $VZ
      run_s=$(( $(date +%s) - t0 ))
      kill -9 $WL 2>/dev/null
      ops=$(grep -c '"done"' "$ledger"); infl=$(tail -1 "$ledger" | grep -q '"begin"' && tail -1 "$ledger" | python3 -c 'import sys,json;e=json.loads(sys.stdin.read());print(e["kind"])' || echo none)
      # 4. Mac side loose
      d0=$(date +%s)
      timeout 120 hdiutil detach -force "$DEV" || { detach=HUNG; notes="$notes detach-hung"; }
      timeout 60 umount -f "$MNT" || timeout 60 diskutil unmount force "$MNT" || notes="$notes umount-failed"
      echo "detach took $(( $(date +%s) - d0 )) s"
    else
      run_s=0
    fi
    # 5. restart, config, remount
    start_vm; apply_config "$CONFIG" || notes="$notes config-failed"
    unclean=$(gsh "dmesg | grep -c 'recovery required'")
    timeout 60 umount -f "$MNT" 2>/dev/null   # a mount left over from before the crash is stale
    mount_smb || notes="$notes smbmount-failed-after"
    # 6. check
    if attach_nomount; then
      echo "-- fsck_apfs -n /dev/r${VOLDEV#/dev/}"
      fsck_apfs -n "/dev/r${VOLDEV#/dev/}"; fsck=$?
      if diskutil mount "$VOLDEV"; then
        mountr=ok
        python3 "$HERE/crash-loop-workload.py" verify "/Volumes/cmloop/it_$i" "$ledger"; verify=$?
      else
        mountr=FAIL
      fi
    else
      attach=FAIL; notes="$notes attach-failed-after"
    fi
    exec 1>&3 3>&-
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$i" "$CONFIG" "$(ts)" "$run_s" "$dirty" "$wb" "$ops" "$infl" "$unclean" "$detach" "$attach" "$fsck" "$mountr" "$verify" "$notes" | tee -a "$OUT/results.tsv"
    if [ "$attach" != ok ] || [ "$fsck" != 0 ] || [ "$mountr" != ok ]; then
      echo "damaged image at iteration $i: replacing it" | tee -a "$OUT/results.tsv"
      timeout 120 hdiutil detach -force "$DEV" >>"$L" 2>&1
      new_image >>"$L" 2>&1 && attach_nomount >>"$L" 2>&1 && timeout 120 hdiutil detach -force "$DEV" >>"$L" 2>&1
    else
      timeout 120 hdiutil detach "$DEV" >>"$L" 2>&1 || timeout 120 hdiutil detach -force "$DEV" >>"$L" 2>&1
    fi
  done
}

case "${1:-}" in
  prepare) prepare ;;
  run) shift; run "$@" ;;
  *) sed -n '2,25p' "$0"; exit 2 ;;
esac
