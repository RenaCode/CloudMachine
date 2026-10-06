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
  -> /Volumes/CloudMachine                  attached sparsebundle; Time Machine sees plain APFS
     -> ~/.cloudmachine/drive               rclone mount over FUSE-T
        -> ~/.cloudmachine/cache            100 GB write buffer
        -> gdrive:CloudMachine/mac-studio   Google Drive
```

**No network filesystem sits in the write path.** That is the whole point.
Time Machine over SMB to a NAS or a cloud share is the common approach and the
fragile one — a sparsebundle written directly over a network link corrupts when
the link drops. Here Time Machine talks to a locally attached image and never
knows the cloud exists.

---

## Requirements

- macOS 14 (Sonoma) or newer, and an administrator password for one step
  (pointing Time Machine at CloudMachine).
- A Google account with room to spare.
- [Homebrew](https://brew.sh).
- Nothing else at runtime. CloudMachine installs its own `rclone` and its own
  copy of FUSE-T.

The menu-bar app, CLI output and notifications follow the system language:
Polish when Polish is the first preferred language, English otherwise.
`CM_LANGUAGE=en` or `CM_LANGUAGE=pl` overrides it. Logs are always English,
so they read the same whoever sends them to you.

### Current limitations

- **Not notarised.** Releases are signed with a self-signed certificate, not
  with an Apple Developer ID. The Homebrew cask clears the quarantine flag; a
  DMG downloaded by hand gets Gatekeeper's "unidentified developer" warning.
- **Per-machine budgets are not enforced.** `config/machines.example.json`
  describes `limit_gb` per Mac, but nothing acts on it — what is checked is the
  real free space on Drive, reported by rclone. Several Macs on one account
  share that space.

---

## Getting started

```sh
brew install --cask renacode/tap/cloudmachine
open -a CloudMachine
```

CloudMachine lives in the menu bar. Its window opens on a **Required Setup
Steps** card listing what is left to do on this Mac, in order, each with a
button — or, for the two steps an app cannot do, a command to copy:

1. **Install rclone** and **Install FUSE-T.** CloudMachine downloads its own
   copies; nothing else is installed system-wide.
2. **Connect Google Drive** — a command to run in Terminal. It opens Google's
   sign-in in the browser and waits for your approval. Enter your own OAuth
   credentials first (see [below](#your-own-google-oauth-credentials)).
3. **Grant Full Disk Access** — opens the right pane of System Settings.
   Without it CloudMachine cannot read when Time Machine last *finished* a
   backup, which is the one check that matters.
4. **Install agents** — the launchd agents that keep the Drive mounted, attach
   the image and watch the backup.
5. **Create image**, then **Attach image** — the backup image on Google Drive.
   The size is a ceiling, not an allocation: the image is sparse, and Drive
   only holds what has been written.
6. **Point Time Machine at CloudMachine** — a `sudo tmutil setdestination`
   command to copy, because only an administrator can change it.

When the card disappears, setup is done. Turn on automatic backups in System
Settings → General → Time Machine, or run `sudo tmutil enable`.

### Several Macs, one Google account

Install CloudMachine on each Mac and go through the same steps; they can all
use the same Google account and the same OAuth credentials. Each Mac backs up
into its own folder, `gdrive:CloudMachine/<folder>`, holding
`<folder>.sparsebundle`, so their backups never mix.

The folder name is chosen once, in the **Connect Google Drive** step: the card
has a **Folder on Google Drive** field, filled in from the computer name, and
the command to copy includes whatever you type there. Give each Mac its own
name. It cannot be changed afterwards, because a new name is a new, empty
backup; CloudMachine refuses rather than orphan the old one. The window shows
the folder in use. Installations set up before per-Mac folders
keep `mac-studio`, which is where their backup already is.

### Upgrading and uninstalling

`brew upgrade` replaces the app without restarting the Google Drive mount.
When Homebrew reopens the app, it reloads the background agents so they run
the new version; `cloudmachine-agent drive-status` shows `Agents: OK`. If a
new version does not show up, run `brew update` first - Homebrew refreshes the
tap only now and then. Neither `brew uninstall` nor
`--zap` touches the launchd agents or the upload buffer in `~/.cloudmachine`,
which may hold backups that have not reached Google Drive yet. Run
`cloudmachine-agent prepare-shutdown` before uninstalling.

### Your own Google OAuth credentials

Do this before **Connect Google Drive**. Create the credentials at
[console.developers.google.com](https://console.developers.google.com/): new
project, enable the Google Drive API, consent screen, credentials, OAuth 2.0 of
type *Desktop*. Paste the client ID and secret into the **Google Drive
Credentials (OAuth 2.0)** card at the bottom of the app window; it stores them
in the macOS Keychain.

They are not optional polish: rclone's shared `client_id` is being retired
during 2026, and Google rate-limits per `client_id`, so on the shared one you
compete with every other rclone user.

The connection uses scope `drive.file`, which grants access only to files this
application itself created. Full `drive` scope would hand out read, write and
**delete** over the entire Google account, which is far more than a folder of
disk-image bands needs — especially with `--drive-use-trash=false`, where a
delete has no bin to recover from.

---

## Documentation

- [Running CloudMachine](docs/operations.md) — checking from Terminal,
  knowing when backups stop, reading the logs, before rebooting.
- [Restoring](docs/restoring.md) — getting files back, and checking the image.
- [How it works, and what it costs](docs/design.md) — measured traffic and
  storage, and why each piece is the way it is.
- [Setting up from Terminal](docs/setup-cli.md) — the same setup without the app.
- [Building from source](docs/building.md) — local builds, tests, releases,
  measurement harnesses.

---

## Licence

MIT. FUSE-T and rclone keep their own licences; see
[How it works](docs/design.md#why-the-pieces-are-what-they-are).
