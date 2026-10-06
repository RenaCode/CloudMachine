# Restoring from CloudMachine

Nothing special: this is a normal Time Machine backup. Enter Time Machine from
the menu bar to browse versions, or restore a whole system through Migration
Assistant. That is the reason for the disk-image approach — file-level cloud
backup tools cannot feed Migration Assistant.

### What is actually in there

CloudMachine decides *where* the backup goes; Time Machine decides *what* goes
into it, and it will happily report a healthy 210 GiB backup that omits your
home directory. Check before you need it:

```sh
tmutil isexcluded ~/Documents ~/Desktop ~/Pictures
plutil -p /Library/Preferences/com.apple.TimeMachine.plist | grep -A15 SkipPaths
```

`SkipPaths` is the exclusion list from System Settings → Time Machine →
Options. `~/.cloudmachine` belongs there — it is the write buffer, and backing
it up would mean backing up the backup. Anything else on that list is a
deliberate decision worth re-reading.

### Actually pulling a file back out

A backup nobody has ever restored from is a hypothesis, not a backup. This
takes a minute and touches nothing:

```sh
B=$(tmutil listbackups -m | tail -1)   # -m mounts the snapshot; without it the path 404s
ls "$B"                                 # -> Data
cp "$B/Data/private/etc/hosts" /tmp/    # a single file
cp -R "$B/Data/private/etc/pam.d" /tmp/ # a whole directory
shasum -a 256 /tmp/hosts /etc/hosts     # the two lines must match
```

Then unmount what you browsed, because a mounted snapshot holds the image
device busy and makes `detach-image` fail:

```sh
mount | grep /Volumes/.timemachine/ |
  sed -E 's/^.* on (\/Volumes\/\.timemachine\/[^(]*) \(.*$/\1/' |
  while read -r m; do diskutil unmount "$m"; done
```

Use `diskutil unmount`, not `umount` — the latter returns
`Operation not permitted` for these snapshots.

### Checking the image

```sh
cloudmachine-agent verify-image
```

`hdiutil verify` does not work on a sparsebundle: such an image carries no
checksum and the tool reports `has no checksum`. The right tool is `fsck_apfs`
on the attached device, which is what `verify-image` runs.

**`verify-image` is not a background task.** `fsck_apfs` reads the image's
metadata through the rclone mount, snapshot by snapshot, so its runtime tracks
the snapshot count rather than the data size — 39 snapshots over a 589 GiB
image (29 Sep 2026) is hours, not minutes, and the count climbs hourly.
Running it against the *attached* image saturates the mount badly enough that
`mount(8)` itself blocks and `backupd` cannot mount the destination, so the
hourly backups fail while it runs. Detach first, as the command requires, and
do it when you can leave the Mac alone.
