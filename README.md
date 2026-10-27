# ☁️ CloudMachine

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: macOS 14+](https://img.shields.io/badge/Platform-macOS%2014%2B-blue.svg)](#)
[![CI](https://github.com/RenaCode/CloudMachine/actions/workflows/ci.yml/badge.svg)](https://github.com/RenaCode/CloudMachine/actions/workflows/ci.yml)

Native Time Machine, backed by Google Drive. No external disk, no NAS, nothing
plugged in at home.

Time Machine backs up over SMB to a small Linux machine that runs on this Mac
([Lima](https://lima-vm.io), Apple Virtualization). The machine keeps the
backup's small files on its own disk and its bands on Google Drive, behind a
local upload buffer: backups land in the buffer at disk speed and drain to the
cloud in the background, so a dropped connection stalls the upload instead of
interrupting the backup.

```
Time Machine --SMB--> machine cmsmb (Lima)
                        Samba    /srv/tm-local/<Computer>.sparsebundle   image metadata, local
                                 bands/ -> punchfs -> rclone mount         120 GB upload buffer
                                 gdrive:CloudMachine/<folder>-tm           Google Drive
```

Why a machine at all: macOS 27 no longer accepts a disk image as a new Time
Machine destination (`tmutil setdestination` answers error 45), and refuses SMB
to the Mac's own address. A share served from a machine on the Mac is what Time
Machine still accepts. Why each layer inside it is there: [`vm/README.md`](vm/README.md).

---

## Requirements

- macOS 14 (Sonoma) or newer, Apple silicon, and an administrator password for
  one step (pointing Time Machine at the machine).
- A Google account with room to spare.
- [Homebrew](https://brew.sh) and Lima from it (`brew install lima`).
- About 200 GB of free disk: the machine's disk file grows with the upload
  buffer.

The menu-bar app, CLI output and notifications follow the system language:
Polish when Polish is the first preferred language, English otherwise.
`CM_LANGUAGE=en` or `CM_LANGUAGE=pl` overrides it. Logs are always English,
so they read the same whoever sends them to you.

### Current limitations

- **Not notarised.** Releases are signed with a self-signed certificate, not
  with an Apple Developer ID. The Homebrew cask clears the quarantine flag; a
  DMG downloaded by hand gets Gatekeeper's "unidentified developer" warning.
- **Google's daily upload limit and a full Drive are not named in the app.**
  rclone's log that says so lives in the machine; what the app does show is
  the backlog growing and the guard pausing Time Machine.

---

## Getting started

```sh
brew install --cask renacode/tap/cloudmachine
open -a CloudMachine
```

CloudMachine lives in the menu bar. Its window opens on a **Required Setup
Steps** card listing what is left to do on this Mac, in order, each with a
button — or, for the steps an app cannot do, a command to copy:

1. **Install rclone.** CloudMachine downloads its own copy; it signs in to
   Google Drive and writes the configuration the machine gets a copy of.
2. **Connect Google Drive** — a command to run in Terminal. It opens Google's
   sign-in in the browser and waits for your approval. Enter your own OAuth
   credentials first (see [below](#your-own-google-oauth-credentials)).
3. **Install Lima** — `brew install lima`, to copy.
4. **Set up the machine** — creates and starts `cmsmb` (the first start
   downloads Ubuntu and installs packages, several minutes), copies rclone's
   configuration into it and sets its SMB password.
5. **Grant Full Disk Access** — opens the right pane of System Settings.
   Without it CloudMachine cannot read when Time Machine last *finished* a
   backup, which is the one check that matters.
6. **Install agents** — the launchd agents that start the machine at login,
   pause Time Machine while the upload buffer is full, and watch the backup.
7. **Point Time Machine at the machine** — a `sudo tmutil setdestination
   smb://tm:…@<address>/CloudMachine` command. The card shows the password
   masked; **Copy** puts the real command on the clipboard.
8. **Convert the image** — once Time Machine has created its first, empty
   image, stop that backup (`tmutil stopbackup`) and press the button
   (`cloudmachine-agent vm-prepare-bundle`): the image gets 32 MB bands, and
   the bands move to Google Drive.

When the card disappears, setup is done. Turn on automatic backups in System
Settings → General → Time Machine, or run `sudo tmutil enable`.

The same from Terminal: `install-rclone`, `configure-remote`, `vm-setup
--install-agents` (prints the `tmutil` command), then `vm-prepare-bundle`;
`vm-status` shows everything at once.

### Several Macs, one Google account

Install CloudMachine on each Mac and go through the same steps; they can all
use the same Google account and the same OAuth credentials. Each Mac backs up
into its own folder, `gdrive:CloudMachine/<folder>-tm`, so their backups never
mix.

The folder name is chosen once, in the **Connect Google Drive** step: the card
has a **Folder on Google Drive** field, filled in from the computer name, and
the command to copy includes whatever you type there. Give each Mac its own
name. It cannot be changed afterwards, because a new name is a new, empty
backup; CloudMachine refuses rather than orphan the old one. The window shows
the folder in use. Installations set up before per-Mac folders
keep `mac-studio`, which is where their backup already is.

### Space limit per Mac

Macs on one account share its space, so each can get a limit: the **Space limit
for this Mac** card in the window (or `cloudmachine-agent set-limit --gb 1500`).
It works two ways:

- **Time Machine quota.** The card gives a `sudo tmutil setquota` command to
  copy; Time Machine then deletes this Mac's oldest backups to stay under it.
  The quota is 70% of the limit, because the bands on Drive grow larger than
  the backup inside them (see `renacode-infra: docs/projekty/cloudmachine/design.md`).
- **An alarm on the real usage.** The watchdog measures this Mac's folder on
  Drive every few hours and warns from 90% of the limit, and again above it.
  The card and `vm-status` show the usage.

### Upgrading and uninstalling

`brew upgrade --cask renacode/tap/cloudmachine` replaces the app; the machine
keeps running. The cask in the tap can be a version behind the latest GitHub
Release: it is updated by a pull request after each release (see
`packaging/README.md`). If a new version does not show up, run `brew update`
first - Homebrew refreshes the tap only now and then. When Homebrew reopens
the app, it reloads the background agents so they run the new version;
`cloudmachine-agent vm-status` shows `Agents: OK`.

**Coming from the disk-image layout** (an rclone mount on the Mac and an image
in `/Volumes/CloudMachine`): the app removes its launchd agents
(`gdrive-buffer`, `gdrive-attach`, `buffer-guard`) on its first launch and
lists in `~/Library/Logs/CloudMachine/cloudmachine.log` what that layout left
behind - `~/.cloudmachine/cache`, `drive`, `fuse`, the old image in
`gdrive:CloudMachine/<folder>` - without deleting any of it. The new layout
starts a new backup in `<folder>-tm`; delete the old one when you no longer
need to restore from it.

Before restarting the Mac, **Prepare for restart** in the menu (or
`cloudmachine-agent prepare-shutdown`) stops the backup, gives the upload up
to 30 minutes, and shuts the machine down cleanly; it starts again at the next
login. Neither `brew uninstall` nor `--zap` touches the launchd agents or the
machine, whose buffer may hold backups that have not reached Google Drive yet:
run `prepare-shutdown`, then `limactl delete cmsmb` and remove
`~/Library/LaunchAgents/com.renacode.cloudmachine.*.plist`.

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
backup bands needs — especially with `--drive-use-trash=false`, where a
delete has no bin to recover from.

On a Mac that is already connected, keep the connection it has. A new sign-in
with different credentials sees only what it created itself, so the existing
backup would vanish from view; `configure-remote` refuses to replace a working
connection unless told twice, and checks the new token against the backup first
(see `renacode-infra: docs/projekty/cloudmachine/setup-cli.md`, "Replacing the connection").

---

## Documentation

The full documentation is kept in the owner's private infrastructure
repository (`renacode-infra: docs/projekty/cloudmachine/`):

- Running CloudMachine (`operations.md`) — checking from Terminal,
  knowing when backups stop, reading the logs, before rebooting.
- Restoring (`restoring.md`) — getting files back.
- How it works, and what it costs (`design.md`) — measured traffic and
  storage, and why each piece is the way it is.
- Setting up from Terminal (`setup-cli.md`) — the same setup without the app.
- Building from source (`building.md`) — local builds, tests, releases.

---

## Licence

MIT. rclone, Lima and Samba keep their own licences. One file is GPLv2:
`vm/punchfs/punchfs.c`, based on libfuse's passthrough example (see
`vm/punchfs/README.md`).
