# Setting up CloudMachine from Terminal

The menu-bar app walks through setup with a button for each step (see
[Getting started](../README.md#getting-started)). This page is the same
setup without the app — for a Mac you reach over SSH, for scripting, or to see
exactly what each button does.

## The agent

`cloudmachine-agent` lives inside the app bundle. `install-launchd` links it
into `/usr/local/bin`; until then call it by its full path:

```sh
/Applications/CloudMachine.app/Contents/MacOS/cloudmachine-agent --help
```

## Steps

Run them in this order. `configure-remote` comes before anything that mounts,
because it chooses this Mac's folder on Google Drive, and `create-image` needs
the mount that `install-launchd` starts.

```sh
cloudmachine-agent install-rclone     # official binary — the Homebrew build cannot mount
cloudmachine-agent install-fuse       # FUSE-T, inside CloudMachine, no separate app
cloudmachine-agent configure-remote   # Google OAuth in the browser; --folder NAME to choose this Mac's folder
cloudmachine-agent install-launchd    # agents that mount Drive and keep it running
cloudmachine-agent create-image --size-gb 4000   # needs the mount from the step above
cloudmachine-agent attach-image
```

Two steps need `sudo`, because they change system-wide settings:

```sh
sudo tmutil setdestination /Volumes/CloudMachine
sudo tmutil enable                    # hourly backups; skip if you prefer manual
```

Full Disk Access cannot be granted from Terminal: add CloudMachine in System
Settings → Privacy & Security → Full Disk Access.

## Google OAuth credentials from Terminal

`configure-remote` reads `client_id` and `client_secret` from the macOS Keychain
under the service `cloudmachine-gdrive`. Instead of the app's credentials card:

```sh
security add-generic-password -a client_id     -s cloudmachine-gdrive -w -U
security add-generic-password -a client_secret -s cloudmachine-gdrive -w -U
```

Without `-w <value>`, `security` prompts — the secret stays out of your shell
history and out of `ps`.

The app's card writes through the same `security` tool rather than the Keychain
API on purpose — an entry created by `SecItemAdd` gets an ACL limited to the
program that made it, and reading it from a different binary raises an
authorisation dialog. The launchd agent has nobody to show that dialog to, so it
would read nothing and quietly fall back to the shared `client_id`.

If the Keychain entries are missing, `configure-remote` still works — it falls
back to rclone's shared `client_id` and says so in the log rather than
pretending otherwise.

## Replacing the connection

`configure-remote` refuses to touch a remote that already exists. Overwriting it
replaces the token and the scope, and credentials scoped `drive.file` cannot see
files created by the previous credentials — the backup stays intact but becomes
unreachable, which amounts to the same thing. Back up `~/.config/rclone/rclone.conf`
first and pass `--replace-existing` if you really mean it. The Drive folder of
this Mac does not change with it.
