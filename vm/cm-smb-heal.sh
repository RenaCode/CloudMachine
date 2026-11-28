#!/bin/sh
# Level-triggered healing (cm-smb-heal.timer, 60 s): systemd does not revive units
# stopped by a dependency (kill -9 of a BindsTo= target leaves them inactive).
HOLD="${CM_SMBD_HOLD:-/run/cloudmachine-smbd-hold}"
ATTENTION="${CM_SMBD_ATTENTION:-/var/lib/cloudmachine/smbd-attention}"
BUNDLE_ENV="${CM_BUNDLE_ENV:-/etc/cloudmachine/bundle.env}"
active() { systemctl is-active --quiet "$1"; }
# Seconds since the file's mtime, as the app counts (VMLayout.smbdHoldLimit).
age() {
  m=$(stat -c %Y "$1" 2>/dev/null || stat -f %m "$1" 2>/dev/null) || return 1
  echo $(($(date +%s) - m))
}

# 1. punchfs is up and mounted, the bind is not: bind again.
if active punchfs && mountpoint -q /srv/tm-punch && [ -s "$BUNDLE_ENV" ] \
  && ! active tm-bands-bind; then
  systemctl --no-block start tm-bands-bind
fi

# 2. bind is up, Samba is not: start it, unless it was stopped on purpose (marker
# 0..7200 s old; a future mtime is expired) or a failed operation left it stopped (attention file).
if active tm-bands-bind && ! active smbd; then
  [ -e "$ATTENTION" ] && exit 0
  if a=$(age "$HOLD") && [ "$a" -ge 0 ] && [ "$a" -le 7200 ]; then exit 0; fi
  rm -f "$HOLD"
  systemctl --no-block start smbd
fi
