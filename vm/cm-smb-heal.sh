#!/bin/sh
# Level-triggered healing (cm-smb-heal.timer, 60 s): systemd does not revive units
# stopped by a dependency (kill -9 of a BindsTo= target leaves them inactive).
HOLD="${CM_SMBD_HOLD:-/run/cloudmachine-smbd-hold}"
BUNDLE_ENV="${CM_BUNDLE_ENV:-/etc/cloudmachine/bundle.env}"
active() { systemctl is-active --quiet "$1"; }

# 1. punchfs is up and mounted, the bind is not: bind again.
if active punchfs && mountpoint -q /srv/tm-punch && [ -s "$BUNDLE_ENV" ] \
  && ! active tm-bands-bind; then
  systemctl start tm-bands-bind
fi

# 2. bind is up, Samba is not: start it, unless it was stopped on purpose
# (marker younger than 120 min = VMLayout.smbdHoldLimit; "attention" = never).
if active tm-bands-bind && ! active smbd; then
  if grep -qs attention "$HOLD"; then exit 0; fi
  if [ -e "$HOLD" ] && [ -n "$(find "$HOLD" -mmin -120)" ]; then exit 0; fi
  rm -f "$HOLD"
  systemctl start smbd
fi
