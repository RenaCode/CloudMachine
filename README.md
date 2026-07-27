# ☁️ CloudMachine

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: macOS 14+](https://img.shields.io/badge/Platform-macOS%2014%2B-blue.svg)](#)
[![Status: Experimental](https://img.shields.io/badge/Status-Experimental-orange.svg)](#)
[![CI](https://github.com/RenaCode/CloudMachine/actions/workflows/ci.yml/badge.svg)](https://github.com/RenaCode/CloudMachine/actions/workflows/ci.yml)

Native Time Machine solution for multiple Mac computers backing up to a shared Google Drive (e.g., Google One/Workspace), with a hard space limit enforced on each machine to prevent any single machine from consuming the entire storage pool.

---

## ⚠️ Status: Experimental

This project enables **genuine, native Time Machine backups** (featuring full version history, the native "Time Machine" browsing interface, and recovery via Migration Assistant) instead of simple file synchronization tools like `rsync` or `restic`.

It achieves this by mounting a Google Drive subdirectory as a local volume using `rclone nfsmount` (rclone's built-in NFS server, mounted using the native macOS NFS client—without requiring FUSE or kernel extensions) and designating it as a Time Machine destination using `tmutil setdestination`.

This solution is **not** officially supported by either Apple or Google. Before trusting it with your most important backups, **please complete the test plan** described below. Known risks and limitations:

*   **Performance and Bandwidth**: Time Machine performs many small, random writes to "band" files (~8MB each) inside the backup bundle. Google Drive does not support partial file updates—every modification to a band file requires re-uploading the entire 8MB file. This can significantly slow down the initial backup and large incremental updates, consuming considerable network bandwidth.
*   **Google Drive API Limits**: The default limit is approximately 10 requests per second. A high volume of small file operations (typical for Time Machine) may be throttled by `rclone`, further slowing down the process. Refer to the "Custom Google client_id" section below to mitigate this.
*   **Large Interrupted Backups May Take Time to Reconnect**: If a backup is interrupted (e.g., the Mac sleeps or Wi-Fi drops) while copying a large amount of data, `rclone` must catch up with the backlog of pending uploads before the volume becomes available again—and it intentionally does not start the NFS server until this is done. The mount-watchdog (see below) detects this state and waits patiently instead of restarting, but catching up on a large backlog can take anywhere from a few minutes to an hour.
*   **Consistency Risk**: Mounting over a local NFS loopback (even with `--vfs-cache-mode full`) does not guarantee the same level of file locking as a local SSD or physical SMB share. Therefore, the project includes a checksum verification utility (`cloudmachine-agent verify-backup`)—regular validation is highly recommended.
*   **No FUSE Required**: The standard Homebrew build of `rclone` does not include built-in FUSE support on macOS. Hence, mounting uses `rclone nfsmount`, which utilizes the built-in macOS NFS client. This eliminates the need to install third-party drivers (such as FUSE-T or macFUSE) or enter the administrator password for every mount operation.

*Alternative*: If this solution proves unstable for your workflow, consider using [Kopia](https://kopia.io)—an open-source tool with native Google Drive support, deduplication, encryption, and retention policies. While Kopia does not integrate with the system Time Machine, the directory structure for multiple machines and the watchdog can easily be adapted for it.

---

## 📋 Requirements

*   macOS 14 (Sonoma) or newer, with administrator privileges.
*   A Google account with free space (e.g., Google One or Workspace) and the Google Drive API enabled.
*   **Tools**: Homebrew and `rclone`. The GUI application (and `cloudmachine-agent install-dependencies`) will check for their presence and install them automatically if needed.

---

## 🚀 Quick Start (GUI Application)

This is the recommended installation method for most users. The Setup Wizard in the application handles all the steps described below in the "Command Line Installation" section (dependencies, Google Drive connection, mounting, Time Machine registration, background automation), including sudoers configuration (one administrator password prompt instead of manual editing of `/etc/sudoers.d`).

1.  Download `CloudMachine-<version>.dmg` (see [Building the Application from Source](#-building-the-application-from-source) if building yourself) and drag `CloudMachine.app` to `/Applications`.
2.  **Right-click** the application icon and select **Open** (double-clicking will trigger Gatekeeper because the app is not signed with an Apple Developer certificate). Confirm the warning about an unidentified developer. All subsequent launches can be done by double-clicking normally.
3.  Open the app from the menu bar and go through the **Setup Wizard** step-by-step: dependencies → Google Drive connection → machine configuration (name + quota) → mounting and Time Machine registration → background automation.
4.  Before trusting this setup fully, execute the [test plan](#-test-plan-do-this-before-trusting-this-solution) below.
5.  Consider setting up a [custom Google API client_id](#-custom-google-client_id-recommended)—the default client ID shared by all `rclone` users worldwide may be throttled under heavy load.

---

## 🔒 Full Disk Access Requirements

> [!IMPORTANT]
> For security reasons, macOS requires **Full Disk Access (FDA)** permissions for processes managing backups and virtual disk creation. Without this permission, the OS will block the internal mechanisms of `hdiutil` (creating and mounting virtual APFS images) and `tmutil` (registration/backup), resulting in errors like `Resource busy` or `setdestination requires Full Disk Access privileges`.
>
> Before running scripts or the application, add the **Terminal** app (and **CloudMachine.app** if using the GUI) in the panel:
> *System Settings -> Privacy & Security -> Full Disk Access*.
>
> If you build the app yourself from source: the default ad-hoc signature generates a new identifier with **every** rebuild, so macOS revokes the previously granted Full Disk Access after each build. Run `cloudmachine-agent setup-signing-cert` once (which creates a local, self-signed code-signing certificate) so that the app's identity—and thus the granted permission—persists across rebuilds. `build-app` will use this certificate automatically if it exists.

---

## 🩺 Background Automation & Watchdogs

The background automation (installed via **Setup Wizard Step 5** or `cloudmachine-agent install-launchd`) consists of **4 launchd agents** that keep the backup process robust and fully automated:

1.  **Mount Watchdog** (`com.renacode.cloudmachine.mount-watchdog`): Checks every 60 seconds if the NFS volume and virtual sparsebundle disk are not only mounted but also responding. If they hang or become unresponsive, it automatically repairs them (forces unmount, kills hung `rclone` processes, and remounts).
    *   It is smart enough to distinguish between a genuinely hung state and `rclone` catching up with a large backlog of uploads after an interrupted backup, waiting patiently in the latter case.
    *   It only runs when the drive is *supposed* to be mounted (i.e., activated via "Mount" in the GUI or CLI, and deactivated on explicit "Unmount"). This state is maintained in the `mount-desired.state` file next to `machines.json`.
2.  **Backup Watchdog** (`com.renacode.cloudmachine.backup-watchdog`): Automatically resumes Time Machine backups (`tmutil startbackup`) when Time Machine goes idle despite CloudMachine being mounted. This bypasses common transient issues like `BACKUP_FAILED_DISCONNECTED_DESTINATION` without requiring manual intervention.
3.  **Quota Watchdog** (`com.renacode.cloudmachine.watchdog`): Runs every 6 hours to ensure this machine's backup does not exceed the limit specified in `config/machines.json`. If needed, it automatically prunes the oldest snapshots using `sudo tmutil delete`.
4.  **Verify Watchdog** (`com.renacode.cloudmachine.verify-watchdog`): Automatically performs a checksum validation of the latest backup once every 7 days when Time Machine is idle, notifying you via system notifications if any integrity issue is detected.

Once the volume is mounted under `/Volumes/CloudMachine-Backup-<machine>`, register it ONCE using the "Register in Time Machine" button (wizard step 4). From then on, `tmutil` will recognize it by UUID, and the watchdog only needs to keep the volume mounted at the same path.

> [!NOTE]
> If you ever need to recreate `backup.sparsebundle` from scratch (e.g., after an unrecoverable `hdiutil: no mountable file systems` error), the disk will get a new UUID. Time Machine will show it as disconnected until you click "Register in Time Machine" again. You should then remove the old, dead destination: `sudo tmutil removedestination <old ID from tmutil destinationinfo>`.

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
    Data already synchronized on Google Drive remains untouched—only the authentication method changes.

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
4.  **Test Incremental Backups**: Run the backup process manually 2–3 times. Monitor the duration and bandwidth usage in the log file `~/Library/Logs/CloudMachine/rclone-mount.log`.
5.  **Enable Full Backups**: If the verifications completed without errors, remove the temporary exclusions and let Time Machine secure the entire drive.

If `cloudmachine-agent verify-backup` reports a checksum error at any point, **stop the backup immediately** and inspect the logs.

---

## 🔒 Automatic Space Pruning (Quota Limit)

In the GUI application, this is configured with a single click: the "Allow automatic backup pruning" button (wizard step 5) adds a `sudoers` rule with `NOPASSWD` for all required `tmutil` subcommands (`delete`, `setdestination`, `startbackup`, `verifychecksums`, `removedestination`) with a single administrator password prompt.

Without the GUI (command-line installation), you must add this rule manually:

```bash
sudo visudo -f /etc/sudoers.d/cloudmachine
```

Paste the following (replace `YOUR_USERNAME` with the output of `whoami`):

```
YOUR_USERNAME ALL=(root) NOPASSWD: /usr/bin/tmutil delete -p *
YOUR_USERNAME ALL=(root) NOPASSWD: /usr/bin/tmutil setdestination -a *
YOUR_USERNAME ALL=(root) NOPASSWD: /usr/bin/tmutil startbackup *
YOUR_USERNAME ALL=(root) NOPASSWD: /usr/bin/tmutil verifychecksums *
YOUR_USERNAME ALL=(root) NOPASSWD: /usr/bin/tmutil removedestination *
```

---

## 📊 Monitoring Logs

To track background process activity:
```bash
tail -f ~/Library/Logs/CloudMachine/*.log
launchctl list | grep renacode.cloudmachine
tmutil destinationinfo
```

---

## 🧹 Uninstallation

To completely remove the daemons, configurations, and Time Machine destinations from your system:

```bash
for plist in ~/Library/LaunchAgents/com.renacode.cloudmachine.*.plist; do
  launchctl unload "$plist"
done
rm ~/Library/LaunchAgents/com.renacode.cloudmachine.*.plist
sudo tmutil removedestination <ID from tmutil destinationinfo>
cloudmachine-agent unmount
```

---

## 🖥️ Command Line Installation (Advanced / Headless)

These are the same steps performed by the GUI Setup Wizard, executed manually via `cloudmachine-agent` (the native Swift CLI—see [Building the Application from Source](#-building-the-application-from-source) below on how to compile it). Useful for automation, debugging, or if you prefer not to use the GUI.

### 1. Install Dependencies
```bash
cloudmachine-agent install-dependencies
```

### 2. Configure Machine Quotas
Copy the example configuration file to `~/Library/Application Support/CloudMachine/machines.json` and adjust the machine names and storage quotas:
```bash
mkdir -p ~/Library/Application\ Support/CloudMachine
cp config/machines.example.json ~/Library/Application\ Support/CloudMachine/machines.json
$EDITOR ~/Library/Application\ Support/CloudMachine/machines.json
```
The machine keys in the JSON file must match normalized computer names (lowercase, numbers, and hyphens, e.g., `macbook-pro-office`)—the same name you enter in the Machines tab of the GUI.

### 3. Connect to Google Drive
Authorize `rclone` to access your Google Drive account (this opens a browser window for OAuth login):
```bash
cloudmachine-agent configure-remote
```
Consider using a [custom client_id](#-custom-google-client_id-recommended) immediately.

### 4. Mount the Volume
```bash
cloudmachine-agent mount
```
*Note:* On the first run, this will automatically create a virtual `.sparsebundle` image and upload it directly to the cloud (bypassing NFS). This can take 15 to 45 seconds depending on your connection speed and Google Drive API latency. Subsequent mounts will be near-instant (under 3 seconds), as long as there is no pending upload backlog.

### 5. Register the Time Machine Destination
```bash
cloudmachine-agent setup-timemachine
```

### 6. Enable Background Automation
```bash
cloudmachine-agent install-launchd
```

---

## 🛠️ Building the Application from Source

The build tools themselves (`build-app`, `make-dmg`, `setup-signing-cert`) are subcommands of `cloudmachine-agent`—the entire build system is written in Swift, without bash scripts. Running `swift run` automatically compiles `cloudmachine-agent` (in debug mode) on first use.

```bash
cd mac-app
swift run cloudmachine-agent setup-signing-cert   # ONCE - creates a local cert so FDA survives rebuilds
swift run cloudmachine-agent build-app            # Compiles the Release version, builds the .app bundle (GUI + CLI agent)
swift run cloudmachine-agent make-dmg             # Packs build/CloudMachine.app into build/CloudMachine-<version>.dmg
```

`build-app` compiles two binaries from the same Swift Package (`mac-app/`): `CloudMachine.app` (GUI) and `cloudmachine-agent` (CLI, called by launchd and the command line). Both share the same mounting, watchdog, and setup logic (`CloudMachineCore`), ensuring identical behavior. To build the CLI agent alone without packaging `.app`: `cd mac-app && swift build -c release --product cloudmachine-agent`.

### CI and Releases

*   Every push or pull request triggers [CI](.github/workflows/ci.yml): runs `swift format lint`, `swift build`, and `swift test` for the entire package.
*   Pushing a tag in the format `vX.Y.Z` triggers [Release DMG](.github/workflows/release.yml): builds the app (ad-hoc signing, no Apple Developer account required) and publishes `CloudMachine-<version>.dmg` as a GitHub Release asset.

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
