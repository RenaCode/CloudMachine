# ☁️ CloudMachine

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: macOS 14+](https://img.shields.io/badge/Platform-macOS%2014%2B-blue.svg)](#)
[![CI](https://github.com/RenaCode/CloudMachine/actions/workflows/ci.yml/badge.svg)](https://github.com/RenaCode/CloudMachine/actions/workflows/ci.yml)

Native Time Machine backup for a Mac, with automatic offsite archiving to Google Drive.

CloudMachine runs on a **two-tier architecture**: Time Machine backs up to a real local disk (fully durable, native macOS backup with full version history and Migration Assistant support), and a background job archives completed backups to Google Drive for offsite retention. That same local disk can optionally be shared over the network (SMB), so a second Mac can use it as its own, independent Time Machine target.

CloudMachine does not create or register the local Time Machine volume, or start/stop backups, itself — that's a deliberate choice, kept fully in your hands via the normal macOS tools (Disk Utility, *System Settings -> Time Machine*), so you're free to point it at any disk, internal or external. CloudMachine's job is what's hard to do by hand: cloud archiving, checksum verification, and (optionally) turning that disk into a network share for a second Mac.

---

## 📋 Requirements

*   macOS 14 (Sonoma) or newer, with administrator privileges.
*   A Google account with free space (e.g., Google One or Workspace) and the Google Drive API enabled.
*   **Tools**: Homebrew and `rclone`. The GUI application (and `cloudmachine-agent install-dependencies`) install these automatically if needed.

---

## 🚀 Setup

### 1. Create and register the local backup volume (manual, once)

Do this first, with the normal macOS tools — CloudMachine only reads whatever is currently registered as the Time Machine destination, it doesn't create or register it:

*   **Disk Utility (GUI)**: format the disk — an internal partition, or a whole external drive (e.g. an SSD) — as APFS, then *System Settings -> Time Machine -> Add Backup Disk* and pick it.
*   **Terminal**, for an internal partition sized with a quota (a ceiling, not a guarantee — actual usable space is still capped by real free space in the container):
    ```bash
    diskutil apfs list   # find your boot container's disk identifier, e.g. disk3
    diskutil apfs addVolume disk3 APFS "CloudMachine-Local" -quota 300G
    sudo tmutil setdestination -a /Volumes/CloudMachine-Local
    ```
    For a whole external disk instead, erase it directly (⚠️ **destroys any existing data on that disk**):
    ```bash
    diskutil list external physical   # find the external disk's identifier, e.g. disk4
    diskutil eraseDisk APFS "CloudMachine-Local" disk4
    sudo tmutil setdestination -a /Volumes/CloudMachine-Local
    ```

Want to exclude folders from the backup (VM disk images, container/Docker data, anything already synced elsewhere like iCloud Drive)? Use *System Settings -> Time Machine -> Options*.

Start a backup with `sudo tmutil startbackup --auto` (or just wait for Time Machine's own hourly schedule). If it fails with `BACKUP_FAILED_TARGETVOL_DISK_FULL`, that's expected on a tightly-sized volume — Time Machine cleans up and retries automatically.

### 2. Let the GUI Setup Wizard handle the rest

Full Disk Access (see below) is required for step 3 below (checksum verification).

1.  **Install dependencies**: installs `rclone` via Homebrew.
2.  **Connect Google Drive**: `cloudmachine-agent configure-remote` (opens a browser for OAuth login). Cloud archiving to Google Drive starts working automatically once connected.
3.  **Pick a disk and share it over the network** (optional): lists local disks under `/Volumes` (excluding the boot disk), turns on File Sharing if it's off, and creates a plain SMB share via the public `sharing` tool. This is meant for a *second* Mac (e.g. a MacBook) to use the same physical disk as its own, independent network Time Machine target. CloudMachine deliberately stops at creating the SMB share — check "Share as a Time Machine backup destination" for it yourself in *System Settings -> General -> Sharing* (that specific mechanism isn't public API, so automating it would be a fragile dependency on the exact macOS version).

    Equivalent manual commands for this step, if you prefer the terminal:
    ```bash
    sudo launchctl enable system/com.apple.smbd
    sudo launchctl kickstart -k system/com.apple.smbd
    sudo sharing -a /Volumes/YourDisk -S "ShareName" -s 001 -g 000
    ```

---

## 🔒 Full Disk Access Requirements

> [!IMPORTANT]
> For security reasons, macOS requires **Full Disk Access (FDA)** permissions for processes reading/verifying Time Machine backups. Without this permission, the OS blocks the internal mechanisms of `tmutil`, resulting in errors like `Resource busy` or similar Full Disk Access errors.
>
> Add the **CloudMachine.app** (and **Terminal**, if you use the CLI) in *System Settings -> Privacy & Security -> Full Disk Access*.
>
> If you build the app yourself from source: the default ad-hoc signature generates a new identifier with **every** rebuild, so macOS revokes previously granted Full Disk Access after each build. Run `cloudmachine-agent setup-signing-cert` once (creates a local, self-signed code-signing certificate) so the app's identity — and thus the granted permission — persists across rebuilds. `build-app` uses this certificate automatically once it exists.

---

## ☁️ Cloud Archiving

`CloudArchiveService` periodically copies completed, "cold" backups from the local volume up to Google Drive via `rclone`. Safety comes from two guarantees: `tmutil listbackups` only ever lists fully-finished backups (an in-progress one is invisible to it until done), and the archiver additionally refuses to run while Time Machine is actively writing. Each backup is copied at most once (tracked in a local state file) and in chronological order, since later backups are hardlinked to earlier ones — a failed copy stops the run rather than skipping ahead, so cloud-side history never gets holes.

It runs automatically via the `archive-watchdog` background agent (checks hourly, real work gated to once per `CM_ARCHIVE_INTERVAL_HOURS` — 6 by default), or on demand from the GUI ("Archiwizuj teraz") or `cloudmachine-agent archive-now`. The cloud side can retain far more history than fits in the local quota, at the cost of not being instantly browsable from Time Machine's UI for very old snapshots (they'd need to be pulled back down first).

Optional upload speed limit: set `bwlimit_mbps` (Mbps, like an ISP plan) in `~/Library/Application Support/CloudMachine/machines.json`.

---

## 🩺 Background Automation

Two agents run via `launchctl`, installed together with `cloudmachine-agent install-launchd`:

*   **Verify Watchdog** (`com.renacode.cloudmachine.verify-watchdog`): performs a checksum validation of the latest backup once every 7 days when Time Machine is idle, notifying you via system notifications if any integrity issue is detected.
*   **Archive Watchdog** (`com.renacode.cloudmachine.archive-watchdog`): copies completed backups to Google Drive on the schedule described above.

Time Machine's own native retry/thinning behavior handles backup scheduling and local space management — no separate watchdog needed for that.

---

## 🔑 Custom Google client_id (Recommended)

By default, `rclone` logs in using a **shared application ID (client_id)** used by all `rclone` users worldwide. This means the global request-per-second limit for the Google Drive API is shared, which under heavy load (large initial backup, many small band files) leads to throttling and slowdowns. Creating your own private `client_id` is a free, one-time setup in the Google Cloud Console that gives you your own dedicated quota.

1.  Go to [console.cloud.google.com](https://console.cloud.google.com) and log in with the Google account used for Drive.
2.  Create a new project (project selector at the top → *New Project*).
3.  Go to **APIs & Services → Library** → search for **Google Drive API** → click **Enable**.
4.  Go to **APIs & Services → OAuth consent screen** → User Type: **External** → Create. Fill in the app name and contact email. In the **Test users** section, add **exactly the Gmail address** you use to log into CloudMachine.
5.  Go to **APIs & Services → Credentials** → **+ Create Credentials → OAuth client ID** → Application type: **Desktop app** → Create.
6.  Copy the displayed **Client ID** and **Client secret**.
7.  Update your existing remote configuration and log in again (this will open a browser window):
    ```bash
    rclone config update gdrive-cloudmachine client_id "YOUR_CLIENT_ID" client_secret "YOUR_CLIENT_SECRET"
    ```
    Data already synchronized on Google Drive remains untouched — only the authentication method changes.

If you encounter the Google error **"Access blocked: project has not configured OAuth consent screen"** or similar, make sure you added your email as a Test User in Step 4.

---

## 🧪 Test Plan (Do this before trusting this solution)

1.  **Exclude Large Directories**: Temporarily exclude large folders (e.g., Downloads, heavy project directories) in Time Machine settings (*System Settings -> Time Machine -> Options*) so that the first test backup completes quickly.
2.  **Start the First Backup Manually**:
    ```bash
    sudo tmutil startbackup --auto --block
    ```
3.  **Verify Integrity**:
    ```bash
    cloudmachine-agent verify-backup
    ```
4.  **Test Incremental Backups**: Run the backup process manually 2–3 times. Monitor progress with `tmutil status` and history with `tmutil listbackups -d /Volumes/CloudMachine-Local`.
5.  **Test Cloud Archiving**: `cloudmachine-agent archive-now`, then check the Google Drive folder for the copied backup.
6.  **Enable Full Backups**: If the verifications completed without errors, remove the temporary exclusions and let Time Machine secure the entire drive.

If `cloudmachine-agent verify-backup` reports a checksum error at any point, **stop the backup immediately** and inspect the logs.

---

## 🔒 Passwordless `tmutil verifychecksums` (sudoers)

`verifychecksums` is the only privileged `tmutil` subcommand CloudMachine itself still calls (registering the destination and starting/stopping backups are now manual steps — see Setup above). The GUI configures this automatically the first time verification is needed (GUI "Verify checksums" button, or the verify-watchdog) — one administrator password prompt, then it writes a `sudoers` rule with `NOPASSWD`, scoped to your local backup volume's actual path.

Without the GUI (command-line installation), add this rule manually:

```bash
sudo visudo -f /etc/sudoers.d/cloudmachine
```

Paste the following (replace `YOUR_USERNAME` with the output of `whoami`, and `/Volumes/CloudMachine-Local` with your actual local backup volume's path):

```
YOUR_USERNAME ALL=(root) NOPASSWD: /usr/bin/tmutil verifychecksums /Volumes/CloudMachine-Local**
```

---

## 📊 Monitoring

```bash
tail -f ~/Library/Logs/CloudMachine/*.log
launchctl list | grep renacode.cloudmachine
tmutil destinationinfo
```

The GUI's Status tab shows the same information visually: dependency/connection state, local volume usage, live backup progress, and cloud archive status (archived/pending counts, last archived backup).

---

## 🧹 Uninstallation

```bash
for plist in ~/Library/LaunchAgents/com.renacode.cloudmachine.*.plist; do
  launchctl unload "$plist"
done
rm ~/Library/LaunchAgents/com.renacode.cloudmachine.*.plist
sudo tmutil removedestination <ID from tmutil destinationinfo>
```

To also reclaim the disk space, delete the local backup volume (this destroys all local backup history — make sure Google Drive has what you need first, via `cloudmachine-agent archive-now`):
```bash
diskutil apfs deleteVolume /Volumes/CloudMachine-Local
```

---

## 🛠️ Building the Application from Source

The build tools (`build-app`, `make-dmg`, `setup-signing-cert`) are subcommands of `cloudmachine-agent` — the entire build system is written in Swift, without bash scripts. Running `swift run` automatically compiles `cloudmachine-agent` (in debug mode) on first use.

```bash
cd mac-app
swift run cloudmachine-agent setup-signing-cert   # ONCE - creates a local cert so FDA survives rebuilds
swift run cloudmachine-agent build-app            # Compiles the Release version, builds the .app bundle (GUI + CLI agent)
swift run cloudmachine-agent make-dmg             # Packs build/CloudMachine.app into build/CloudMachine-<version>.dmg
```

`build-app` compiles two binaries from the same Swift Package (`mac-app/`): `CloudMachine.app` (GUI) and `cloudmachine-agent` (CLI, called by launchd and the command line). Both share the same local-volume, archiving, verification, and setup logic (`CloudMachineCore`), ensuring identical behavior. To build the CLI agent alone without packaging `.app`: `cd mac-app && swift build -c release --product cloudmachine-agent`. The version shown in the GUI sidebar comes from `mac-app/VERSION`.

### CI and Releases

*   Every push or pull request triggers [CI](.github/workflows/ci.yml): runs `swift format lint`, `swift build`, and `swift test` for the entire package.
*   Pushing a tag in the format `vX.Y.Z` triggers [Release DMG](.github/workflows/release.yml): builds the app (ad-hoc signing, no Apple Developer account required) and publishes `CloudMachine-<version>.dmg` as a GitHub Release asset.

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
