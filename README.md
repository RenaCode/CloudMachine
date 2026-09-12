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
shared one you compete with every other rclone user.

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
Cel Time Machine: /Volumes/CloudMachine
Backup:           nie trwa
```

The number that matters is the upload queue. Until it returns to zero between
backups, part of the backup is still only on this Mac.

Three launchd agents keep it alive, all running the binary inside the app:

| Agent | Job |
|---|---|
| `gdrive-buffer` | holds the rclone mount; `KeepAlive` |
| `gdrive-attach` | attaches the image, retries every 15 minutes |
| `buffer-guard` | pauses Time Machine when the buffer outgrows the uplink |

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

Check the image itself with:

```sh
cloudmachine-agent verify-image
```

`hdiutil verify` does not work on a sparsebundle: such an image carries no
checksum and the tool reports `has no checksum`. The right tool is `fsck_apfs`
on the attached device, which is what `verify-image` runs.

---

## Measurement harnesses

`gdrive/` holds the scripts used to measure the behaviour behind these
decisions — write amplification per band size, and what survives the cloud layer
dying mid-write. They are not part of the running system; see
[gdrive/README.md](gdrive/README.md) for the numbers.

---

## Licence

MIT. FUSE-T and rclone keep their own licences; see above.
