#!/bin/sh
# CloudMachine: which image in /srv/tm-local holds the bands that live on Drive.
#
# bundle.env (CM_BUNDLE=<name>.sparsebundle) is written by vm-prepare-bundle.
# Time Machine renames the image when the Mac's name changes (25 Nov 2026), so
# the stored name is checked before every use and follows the rename - but only
# to the unmistakably prepared image: 32 MB bands, none of its own on local disk.
# A new image Time Machine started (875 MB bands) is never bound over.
#
#   tm-bundle resolve    print the image's name, fixing bundle.env if renamed
#   tm-bundle bind       bind the Drive bands into the image (tm-bands-bind)
#   tm-bundle unbind     undo the bind, whatever the image is called now
#   tm-bundle has-info   0 when the image has an Info.plist (tm-meta-sync)
set -u

LOCAL="${CM_LOCAL:-/srv/tm-local}"
ENV_FILE="${CM_BUNDLE_ENV:-/etc/cloudmachine/bundle.env}"
PUNCH_BANDS="${CM_PUNCH_BANDS:-/srv/tm-punch/bands}"
# VMBundlePrep.bandBytes: 65536 sectors of 512 bytes.
BAND_BYTES=33554432

log() { echo "tm-bundle: $*" >&2; }

# The value as systemd reads it (quotes off, escapes undone).
stored_name() {
  sed -n 's/^CM_BUNDLE=//p' "$ENV_FILE" 2>/dev/null | head -n 1 \
    | sed 's/^"//; s/"$//; s/\\\(.\)/\1/g'
}

# bundle.env is also sourced as shell: only names without shell syntax go in.
safe_name() {
  case "$1" in
    *[\"\\\$\`]* | *"
"*) return 1 ;;
  esac
  return 0
}

band_size() {
  # The <integer> on the line after <key>band-size</key>.
  sed -n '/<key>band-size<\/key>/{n;s/[^0-9]//gp;}' "$1/Info.plist" 2>/dev/null | head -n 1
}

is_mountpoint() {
  command -v mountpoint >/dev/null 2>&1 && mountpoint -q "$1"
}

# The image vm-prepare-bundle made: bands/ is empty or the bind mount itself.
is_prepared() {
  [ -s "$1/Info.plist" ] || return 1
  [ "$(band_size "$1")" = "$BAND_BYTES" ] || return 1
  [ -d "$1/bands" ] || return 1
  is_mountpoint "$1/bands" && return 0
  [ -z "$(ls -A "$1/bands" 2>/dev/null)" ]
}

resolve() {
  if [ ! -f "$ENV_FILE" ]; then
    log "$ENV_FILE is missing: vm-prepare-bundle has not run"
    return 1
  fi
  name=$(stored_name)
  if [ -n "$name" ] && [ -d "$LOCAL/$name" ]; then
    printf '%s\n' "$name"
    return 0
  fi
  found=""
  count=0
  all=""
  for dir in "$LOCAL"/*.sparsebundle; do
    [ -d "$dir" ] || continue
    all="$all '${dir##*/}'"
    if is_prepared "$dir"; then
      found="${dir##*/}"
      count=$((count + 1))
    fi
  done
  if [ "$count" -ne 1 ]; then
    log "the image '$name' named in $ENV_FILE is not in $LOCAL, and $count prepared images are there (found:${all:- none}); not guessing"
    return 1
  fi
  if ! safe_name "$found"; then
    log "the image was renamed to '$found', which has shell syntax in it; not writing it to $ENV_FILE"
    return 1
  fi
  tmp="$ENV_FILE.tmp.$$"
  printf 'CM_BUNDLE="%s"\n' "$found" >"$tmp" && mv "$tmp" "$ENV_FILE" || {
    rm -f "$tmp"
    log "could not update $ENV_FILE"
    return 1
  }
  log "Time Machine renamed the image '$name' to '$found'; $ENV_FILE updated"
  printf '%s\n' "$found"
}

case "${1:-}" in
  resolve)
    resolve
    ;;
  bind)
    name=$(resolve) || exit 1
    exec mount --bind "$PUNCH_BANDS" "$LOCAL/$name/bands"
    ;;
  unbind)
    status=0
    for bands in "$LOCAL"/*.sparsebundle/bands; do
      if is_mountpoint "$bands"; then umount -l "$bands" || status=1; fi
    done
    exit $status
    ;;
  has-info)
    name=$(resolve) || exit 1
    [ -s "$LOCAL/$name/Info.plist" ]
    ;;
  *)
    log "usage: tm-bundle resolve|bind|unbind|has-info"
    exit 2
    ;;
esac
