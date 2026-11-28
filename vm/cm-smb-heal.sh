#!/bin/sh
# Level-triggered healing (cm-smb-heal.timer, 60 s): systemd does not revive dependents.
HOLD="${CM_SMBD_HOLD:-/run/cloudmachine-smbd-hold}"
ATTENTION="${CM_SMBD_ATTENTION:-/var/lib/cloudmachine/smbd-attention}"
BUNDLE_ENV="${CM_BUNDLE_ENV:-/etc/cloudmachine/bundle.env}"
active() { systemctl is-active --quiet "$1"; }
# Seconds since mtime (VMLayout.smbdHoldLimit).
age() {
  m=$(stat -c %Y "$1" 2>/dev/null || stat -f %m "$1" 2>/dev/null) || return 1
  echo $(($(date +%s) - m))
}

# 0. start-limit-hit is final: reset and start, at most 6 times an hour (README).
R="${CM_HEAL_RESETS:-/run/cloudmachine-heal-resets}"
recent() { awk -v n="$(date +%s)" 'n >= $1 && n - $1 < 3600' "$R" 2>/dev/null; }
for u in rclone-tm punchfs tm-bands-bind; do
  if ! active "$u" \
    && [ "$(systemctl show -p Result --value "$u" 2>/dev/null)" = start-limit-hit ] \
    && [ "$(recent | wc -l)" -lt 6 ]; then
    { recent; date +%s; } >"$R.t" && mv "$R.t" "$R"
    systemctl reset-failed "$u"
    systemctl --no-block start "$u"
  fi
done

# 1. punchfs is up and mounted, the bind is not: bind again.
if active punchfs && mountpoint -q /srv/tm-punch && [ -s "$BUNDLE_ENV" ] \
  && ! active tm-bands-bind; then
  systemctl --no-block start tm-bands-bind
fi

# 2. bind up, Samba not: start it, unless held on purpose (marker 0..7200 s old) or attention file.
if active tm-bands-bind && ! active smbd; then
  [ -e "$ATTENTION" ] && exit 0
  if a=$(age "$HOLD") && [ "$a" -ge 0 ] && [ "$a" -le 7200 ]; then exit 0; fi
  rm -f "$HOLD"
  systemctl --no-block start smbd
fi
