# The CloudMachine machine (Time Machine over SMB)

macOS 27 does not accept a disk image as a new Time Machine destination, so
CloudMachine gives Time Machine what it does accept: an SMB share. The share is
served by a small Linux machine on this Mac (Lima, Apple Virtualization),
and the backup's bands live on Google Drive.

```
Time Machine --SMB--> Samba  /srv/tm-local/<Computer>.sparsebundle   (ext4: image metadata)
                               bands/ = bind of /srv/tm-punch/bands
                      punchfs /srv/tm-punch                          (hole punch, xattrs)
                      rclone  /srv/tm  = gdrive:CloudMachine/<folder>-tm
tm-meta-sync (every 15 min): /srv/tm-local minus bands/ -> gdrive:CloudMachine/<folder>-tm-meta
```

Each layer is there for a reason:

- Samba straight on rclone fails with `NT_STATUS_SHARING_VIOLATION`: rclone
  derives inodes from a hash of the path, and they change under a rename.
  So the image's small files stay on local ext4 and only `bands/` goes to Drive.
- macOS frees bands with a hole punch and keeps Samba's sparse flag and Apple
  streams in extended attributes; rclone supports neither. `punchfs` fills
  both gaps (see `punchfs/README.md`).
- The image's small files (Info.plist, token, `mapped/`, Time Machine's
  plists) are on the machine's disk, and that disk is kept out of Time
  Machine. `tm-meta-sync` copies them to `<folder>-tm-meta` every 15 minutes;
  without them the bands cannot be opened again (see "Restoring").
- Time Machine creates bands of 875 MB. `vm-prepare-bundle` converts the new,
  empty image to 32 MB bands, so a day of changes fits Google's upload limit.

## Files

- `cmsmb.yaml` - the Lima template; its provisioning installs everything and
  can run again on every boot.
- `samba/smb.conf`, `fuse.conf`, `systemd/` - copied into the machine as they are.
  Machine-specific values come from files `cloudmachine-agent` writes:
  `/etc/cloudmachine/vm.env` (the Drive folder) and
  `/etc/cloudmachine/bundle.env` (the image name, from the computer name).
- `punchfs/` - the FUSE layer and its test.

## Commands

    cloudmachine-agent vm-setup --install-agents   # create/start the machine, agents, print the tmutil command
    sudo tmutil setdestination smb://tm:<password>@<address>/CloudMachine
    # ...Time Machine creates its empty image; stop the backup...
    cloudmachine-agent vm-prepare-bundle   # 32 MB bands, bands moved to Drive
    cloudmachine-agent vm-status
    cloudmachine-agent vm-guard            # one check; the launchd agent runs it every minute
    cloudmachine-agent prepare-shutdown    # before a restart: stop the backup, drain, limactl stop

`install-launchd` (also run by `--install-agents`) installs four agents:
`app`, `backup-health`, `vm-start` (boots the machine at login) and `vm-guard`
(pauses Time Machine when more than 110 GiB waits to be uploaded or the
machine has less than 40 GiB free, resumes below 40 GiB - only what it paused).

## Restoring

The backup on Drive is two folders: the bands in `gdrive:CloudMachine/<folder>-tm`
and everything else of the image in `gdrive:CloudMachine/<folder>-tm-meta`
(`vm-status`: "Image metadata"; the backup watchdog reports a copy older than
an hour). To open it on a new Mac or after the machine's disk is lost:

1. Install CloudMachine and rclone's configuration for the same Google
   account, and give the Mac the same Drive folder name.
2. `cloudmachine-agent vm-setup` - but do NOT point Time Machine at the
   machine and do NOT run `vm-prepare-bundle`: either would start a new image.
3. Put the image's files back and the bands under them (`<name>` is the
   folder in `-tm-meta`, e.g. `Mac Studio.sparsebundle`):

   ```sh
   limactl shell --workdir / cmsmb sudo bash -c '
     set -e
     systemctl stop smbd
     . /etc/cloudmachine/vm.env
     rclone --config /etc/rclone/rclone.conf copy "$CM_REMOTE-meta/" /srv/tm-local/
     cd /srv/tm-local && ls -d *.sparsebundle'      # -> <name>
   limactl shell --workdir / cmsmb sudo bash -c '
     set -e
     b="/srv/tm-local/<name>"
     mkdir -p "$b/bands" && chown -R tm:tm /srv/tm-local
     printf "CM_BUNDLE=\"%s\"\n" "<name>" > /etc/cloudmachine/bundle.env
     systemctl start tm-bands-bind smbd && findmnt "$b/bands"'
   ```

4. On the Mac, connect to the share (`smb://tm@<address>/CloudMachine`,
   password in `~/.cloudmachine/vm/tm-smb.pass`). Migration Assistant ("From a
   Mac, Time Machine backup") or Time Machine's "Browse backups" sees it; for a
   read-only look, `hdiutil attach -readonly` the image.

The metadata is copied every 15 minutes while bands are uploaded continuously,
so restore from a state after a backup finished and its upload drained
(`vm-status`: "Still to upload: 0"). Samba's `user.DOSATTRIB` attributes are
not copied; Samba recreates them.

## No ports to the Mac

rclone's remote control listens in the machine on `127.0.0.1:5572` without a
password - the guard and the status read the upload queue through it. Lima
forwards a guest's localhost ports to the Mac's by default, and on the Mac's
localhost any web page can send it commands, deleting the backup included.
`cmsmb.yaml` therefore forwards nothing (`portForwards` with `ignore: true`);
Samba is reached over vzNAT. A machine created from an older template keeps
the forwarding until the rule is added to `~/.lima/cmsmb/lima.yaml` and the
machine is restarted (`cloudmachine-agent prepare-shutdown`, then
`limactl start cmsmb`). `vm-status` and the backup watchdog report it while
`127.0.0.1:5572` answers on the Mac.

## Trying a change without touching the live machine

Every `vm-*` command takes the machine and the Drive folder from two
variables, so a change can be tried on a throwaway machine while `cmsmb`
keeps backing up:

```sh
export CLOUDMACHINE_VM_INSTANCE=cmtest CLOUDMACHINE_VM_REMOTE=gdrive:CloudMachine/test-vm-tm
cloudmachine-agent vm-setup && cloudmachine-agent vm-status
```

`vm-prepare-bundle` refuses while Time Machine is backing up to *this*
machine; a backup going to another destination does not stop it.
