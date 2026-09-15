# ☁️ CloudMachine

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: macOS 14+](https://img.shields.io/badge/Platform-macOS%2014%2B-blue.svg)](#)
[![CI](https://github.com/RenaCode/CloudMachine/actions/workflows/ci.yml/badge.svg)](https://github.com/RenaCode/CloudMachine/actions/workflows/ci.yml)

Native Time Machine, backed by Google Drive. No external disk, no NAS, nothing
plugged in at home.

Time Machine writes to a disk image that macOS mounts like any other volume. The
image's contents live on Google Drive, behind a local write buffer. Backups land
in the buffer at SSD speed and drain to the cloud in the background, so a dropped
connection stalls the upload instead of interrupting the backup.

```
Time Machine
  -> /Volumes/CloudMachine          attached sparsebundle; Time Machine sees plain APFS
     -> ~/.cloudmachine/drive       rclone mount over FUSE-T
        -> ~/.cloudmachine/cache    100 GB write buffer
        -> gdrive:CloudMachine/...  Google Drive
```

**No network filesystem sits in the write path.** That is the whole point.
Time Machine over SMB to a NAS or a cloud share is the common approach and the
fragile one — a sparsebundle written directly over a network link corrupts when
the link drops. Here Time Machine talks to a locally attached image and never
knows the cloud exists.

---

## What it costs in practice

Measured on a Mac Studio, 332 Mbit/s uplink, ~600 GB of live data:

| | |
|---|---|
| Full backup | 210 GiB, about two hours |
| Incremental backup | ~370 MB, a few minutes |
| Daily upload | ~9 GB — 1.2% of Google's 750 GB/day ceiling |
| Google Drive used | 214 GiB |

The daily cap only matters for the first backup, and only if the source is
larger than 750 GB.

---

## Requirements

- macOS 14 (Sonoma) or newer. Administrator rights for two commands, listed below.
- A Google account with room to spare.
- Nothing else. CloudMachine installs its own `rclone` and its own copy of FUSE-T.

---

## Setup

`cloudmachine-agent` lives inside the app bundle. `install-launchd` symlinks it
into `/usr/local/bin`; until then, call it by its full path:

```sh
/Applications/CloudMachine.app/Contents/MacOS/cloudmachine-agent --help
```

```sh
cloudmachine-agent install-rclone     # official binary — the Homebrew build cannot mount
cloudmachine-agent install-fuse       # FUSE-T, inside CloudMachine, no separate app
cloudmachine-agent configure-remote   # Google OAuth in the browser
cloudmachine-agent create-image --size-gb 4000
cloudmachine-agent attach-image
cloudmachine-agent install-launchd    # agents that keep it running
```

Two steps need `sudo`, because they change system-wide settings:

```sh
sudo tmutil setdestination /Volumes/CloudMachine
sudo tmutil enable                    # hourly backups; skip if you prefer manual
```

### Your own Google OAuth credentials

`configure-remote` reads `client_id` and `client_secret` from the macOS Keychain
under the service `cloudmachine-gdrive`. Create them at
[console.developers.google.com](https://console.developers.google.com/): new
project, enable the Google Drive API, consent screen, credentials, OAuth 2.0 of
type *Desktop*. Then:

```sh
security add-generic-password -a client_id     -s cloudmachine-gdrive -w -U
security add-generic-password -a client_secret -s cloudmachine-gdrive -w -U
```

Without `-w <value>`, `security` prompts — the secret stays out of your shell
history and out of `ps`.

Your own credentials are not optional polish: rclone's shared `client_id` is
being retired during 2026, and Google rate-limits per `client_id`, so on the
shared one you compete with every other rclone user. If the Keychain entries are
missing, `configure-remote` still works — it falls back to the shared
`client_id` and says so in the log rather than pretending otherwise.

The remote is created with scope `drive.file`, which grants access only to files
this application itself created. Full `drive` scope would hand out read, write
and **delete** over the entire Google account, which is far more than a folder
of disk-image bands needs — especially with `--drive-use-trash=false`, where a
delete has no bin to recover from.

`configure-remote` refuses to touch a remote that already exists. Overwriting it
replaces the token and the scope, and credentials scoped `drive.file` cannot see
files created by the previous credentials — the backup stays intact but becomes
unreachable, which amounts to the same thing. Back up `~/.config/rclone/rclone.conf`
first and pass `--replace-existing` if you really mean it.

---

## Running it

```sh
cloudmachine-agent drive-status
```

```
Narzedzia:        OK
Montowanie Drive: OK
Obraz podpiety:   OK  (/Volumes/CloudMachine)
Bufor:            103 GB z 100G
Wolne na dysku:   288 GB
Kolejka wysylki:  0 w toku, 0 w kolejce, 0 bledow
Wysylka:          Wszystko wyslane na Google Drive
Cel Time Machine: /Volumes/CloudMachine
Backup:           nie trwa
```

The number that matters is the upload queue. Until it returns to zero between
backups, part of the backup is still only on this Mac.

The `Wysylka:` line is the same verdict the app window shows, computed in one
place so the two can never disagree. When it is not nominal it prints a second
line saying why, and whether it clears on its own.

Three launchd agents keep it alive, all running the binary inside the app:

| Agent | Job |
|---|---|
| `gdrive-buffer` | holds the rclone mount; `KeepAlive` |
| `gdrive-attach` | attaches the image, retries every 15 minutes |
| `buffer-guard` | pauses Time Machine when the buffer outgrows the uplink |
| `backup-health` | every 30 min: is a backup still *completing*? |

### Knowing when it stops working

Every other check here reports the state of the plumbing — mount up, image
attached, queue empty. None of them notices the failure that matters most:
everything looks attached and nothing has finished a backup in two days. The
dashboard shows a green tick for exactly that state.

```sh
cloudmachine-agent backup-health
```

```
Ostatnia udana kopia: 2026-09-12 18:25
Ostatnia proba:       2026-09-12 18:02
Cykl backupu: OK
```

It reads the date of the last **completed** backup — `SnapshotDates` in
`/Library/Preferences/com.apple.TimeMachine.plist`, a counter macOS only
advances on success — and complains after three missed hourly runs, on a
non-zero `RESULT`, on unsent files, on a Drive or disk running out of room, and
when the mount, the image or the Time Machine destination is gone. A problem
goes to the macOS notification centre and to `cloudmachine.log`, once, with a
reminder every twelve hours while it lasts. Exit code 1 means broken, so `&&`
and launchd see the same answer as you do.

It deliberately reads a local file rather than calling `tmutil latestbackup`:
the latter mounts a snapshot on a volume that lives on Google Drive, and a
watchdog that hangs when the mount is sick is silent exactly when it is needed.

### Reading the logs

The app window deliberately does **not** show a log viewer. It answers one
question — is the backup reaching Google Drive, and if not, why — and a wall of
timestamped lines is not that answer. It also aged badly: the pane showed the
tail of the log, so on a quiet day it still displayed last night's failure and
looked like a live one.

Logs are a diagnostic tool, so they live here instead.

| File | What it holds |
|---|---|
| `~/Library/Logs/CloudMachine/cloudmachine.log` | everything the agents decided: pauses, resumes, alerts, attach/detach |
| `~/.cloudmachine/rclone.log` | every transfer and every API error, one line each |
| `~/Library/Logs/CloudMachine/launchd-*.out.log` | stdout per agent, one file each |

Both main logs are rotated by size, so they will not eat the disk.

**Check the timestamps before concluding anything.** An entry is not news
because it is the last one in the file; on a quiet day the newest line can be
hours old.

```sh
# Did anything fail today?
grep "^\[$(date +%Y-%m-%d)" ~/Library/Logs/CloudMachine/cloudmachine.log | grep -i awaria

# Is the upload actually moving, or only erroring? Successes vs refusals per minute.
grep "^$(date +%Y/%m/%d)" ~/.cloudmachine/rclone.log \
  | awk '{k=$1" "substr($2,1,5)}
         /: Copied \(/     {ok[k]++}
         /upload limit/   {err[k]++}
         END {for (k in ok) seen[k]; for (k in err) seen[k];
              for (k in seen) print k, "ok:" ok[k]+0, "err:" err[k]+0}' \
  | sort | tail -20
```

That second one is worth knowing, because a wall of `403` lines on its own says
very little. Google returns `userRateLimitExceeded` both for ordinary throttling
and for the exhausted 750 GB/day write quota, and the text is identical — it was
measured at exactly 1:1 across 81036 error lines here. What separates them is
whether anything is still getting through. Ordinary throttling runs at one
success per error or better; a real stall drops to roughly one in a hundred.
`buffer-guard` uses that same ratio to decide whether to report a stall, so this
command shows you what it is looking at.

Empty logs after a fresh install are normal — the agents only write when
something happens.

### Before rebooting

```sh
cloudmachine-agent prepare-shutdown
```

Powering off is where this design is fragile. Detaching the image is itself a
write — APFS flushes metadata into bands, and the upload of those bands is
deferred. Killing rclone inside that window does not cost "the last few
changes", it costs the volume's root directory. `prepare-shutdown` stops the
backup, detaches, waits for the queue to drain, and refuses to report success
while anything is still local.

Sleep is safe and needs nothing: the buffer survives, uploads resume on wake,
and Power Nap wakes the Mac for scheduled backups.

---

## Why the pieces are what they are

**32 MB bands.** Google Drive allows roughly two operations per file per second
and caps a drive at 400,000 files, which favours large bands. But every change
dirties a whole band, which favours small ones. Measured under Time Machine's
actual write pattern, 64 MB bands cost exactly twice the transfer of 8 MB bands.
32 MB is the smallest band at which the first upload stops being bound by
Drive's per-file rate and becomes bound by the link. The size is fixed when the
image is created and cannot be changed afterwards.

**Its own rclone.** The Homebrew build is compiled without FUSE and refuses to
mount outright. CloudMachine installs the official binary beside it, verified by
SHA256.

**Its own FUSE-T.** The official installer leaves an app in `/Applications` that
only hosts an FSKit backend this project does not use. CloudMachine keeps the two
files it actually needs in `~/.cloudmachine/fuse` and symlinks the library where
rclone looks for it — no root required, since `/usr/local/lib` belongs to the
user. FUSE-T is not open source: its binary distribution is free for
non-commercial use provided the copyright notice is kept, which is why
`LICENSE.rtf` is copied alongside. Bundling it with commercial software needs a
licence from its authors.

**A buffer guard.** `--vfs-cache-max-size` is a soft limit — rclone only evicts
what it has already uploaded, so when everything is queued the buffer keeps
growing and can fill the disk. Time Machine writes at SSD speed, rclone uploads
at link speed, and the difference accumulates. The guard pauses Time Machine
above a threshold and resumes when the queue catches up, trading speed for
finishing at all.

---

## Restoring

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
metadata through the rclone mount, snapshot by snapshot — on a 210 GiB backup
with 18 snapshots that is hours, not minutes. Running it against the *attached*
image saturates the mount badly enough that `mount(8)` itself blocks and
`backupd` cannot mount the destination, so the hourly backups fail while it
runs. Detach first, as the command requires, and do it when you can leave the
Mac alone.

---

## Measurement harnesses

`gdrive/` holds the scripts used to measure the behaviour behind these
decisions — write amplification per band size, and what survives the cloud layer
dying mid-write. They are not part of the running system; see
[gdrive/README.md](gdrive/README.md) for the numbers.

---

## Licence

MIT. FUSE-T and rclone keep their own licences; see above.
