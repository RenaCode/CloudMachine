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
```

Each layer is there for a reason:

- Samba straight on rclone fails with `NT_STATUS_SHARING_VIOLATION`: rclone
  derives inodes from a hash of the path, and they change under a rename.
  So the image's small files stay on local ext4 and only `bands/` goes to Drive.
- macOS frees bands with a hole punch and keeps Samba's sparse flag and Apple
  streams in extended attributes; rclone supports neither. `punchfs` fills
  both gaps (see `punchfs/README.md`).
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

    cloudmachine-agent vm-setup            # create/start the machine, print the tmutil command
    sudo tmutil setdestination smb://tm:<password>@<address>/CloudMachine
    # ...Time Machine creates its empty image; stop the backup...
    cloudmachine-agent vm-prepare-bundle   # 32 MB bands, bands moved to Drive
    cloudmachine-agent vm-status
    cloudmachine-agent vm-guard            # one check; the launchd agent runs it every minute
