# Google Drive layer - measurements and conclusions

The working system lives in the app, not here. This directory holds the
measurement harnesses and the reasoning behind the decisions that came out of
those measurements.

```
Time Machine
  -> /Volumes/CloudMachine          image attached by hdiutil; TM sees plain APFS
     -> ~/.cloudmachine/drive       rclone mount on FUSE-T
        -> ~/.cloudmachine/cache    100 GB write buffer
        -> gdrive:CloudMachine/...  Google Drive
```

The point of this layout: **there is no network file system in the write path.**
Time Machine writes to a locally attached image and does not know that the bands
live in the cloud. SMB drops out, and with it the most common cause of corrupted
network backups.

## Where things are

| What | Where |
|---|---|
| Buffer (mounting, cache, queue) | `CloudMachineCore/DriveBufferService` |
| Image (creating, attaching, consistency) | `CloudMachineCore/BackupImageService` |
| Buffer guard | `CloudMachineCore/BufferGuardService` |
| Installing rclone with mount support | `CloudMachineCore/RcloneInstaller` |
| Tool resolution, FUSE check | `CloudMachineCore/CMTooling` |
| Subcommands | `CloudMachineAgent/DriveCommands` |
| launchd agents | `launchd/*.plist.template` |

```sh
cloudmachine-agent install-rclone     # official binary (the Homebrew one cannot mount)
cloudmachine-agent configure-remote   # OAuth, keys from the Keychain
cloudmachine-agent create-image --size-gb 4000
cloudmachine-agent attach-image
cloudmachine-agent drive-status
sudo tmutil setdestination /Volumes/CloudMachine
```

## Band size

Set only when the image is created; it cannot be changed later without starting
the backup from scratch. Two forces pull in opposite directions: Google Drive
allows roughly **two operations per file per second** and has a limit of
**400,000 files**, which favours large bands - but every change dirties the
**whole** band, which, with the daily limit of **750 GB**, favours small ones.

Measured (`cloudmachine-poc amplification`, 3 GB image, 300 MB change):

| Band  | Bands per 3 GB | Scattered change | Append (like TM)   | Files per 200 GB |
|-------|----------------|------------------|--------------------|------------------|
| 8 MB  | 381            | 2712 MB          | 384 MB             | 25,600           |
| 16 MB | 193            | 3040 MB          | 480 MB             | 12,800           |
| 32 MB | 99             | 3072 MB          | **672 MB**         | **6,400**        |
| 64 MB | 52             | 3136 MB          | 768 MB             | 3,200            |

With a change **scattered** across the whole volume, band size does not matter -
almost every band gets dirtied and in practice the whole image is uploaded. That
is the worst case, though, not the one that applies to us.

With **appending**, which is what Time Machine actually does, transfer grows
monotonically with band size: 64 MB costs exactly twice as much as 8 MB. Large
bands are not free.

Hence **32 MB**: the smallest band at which the initial upload stops being
limited by Drive's operation rate (6,400 files, ~0.9 h) and starts being limited
by link bandwidth (~1.3 h at 332 Mb/s).

## FUSE-T mount quirks

FUSE-T mounts via NFS, and `hdiutil` on such a volume is sometimes rejected with
the error **`RPC version wrong`**. Measured: the error does not depend on image
size or on the data (one run failed for 100 GB and 400 GB and passed for 600,
1000 and 1500 GB), only on the **moment** - with an empty upload queue 5 out of
5 attempts succeeded, with rclone busy it was random. Hence waiting for quiet and
retrying in `BackupImageService`; when the production image was created, the
first attempt failed and the second one succeeded.

**The image has to be created in place, on the mounted Drive.** Creating it
locally and moving it produces an image that `hdiutil` later will not open
(`CBSDBackingStore::newProbe stat() failed`), even though all the files and bands
are in place and readable.

The other FUSE-T backends do not help: `backend=fskit` does not mount at all,
`backend=smb` mounts, but `hdiutil create` ends with `Is a directory`.

## What survives the death of the cloud layer

`cloudmachine-poc pullplug` detaches a stand-in for the mount in the middle of a
write, i.e. it simulates the rclone process dying or FUSE-T crashing. Three
rounds, **zero irreversible losses** - the image passed `fsck_apfs` every time.

Losing just the network link is milder: with `--vfs-cache-mode full` writes go
to the buffer, the mount stays up and Time Machine notices nothing.

Two traps this test uncovered, both patched in `BackupImageService`:

**Zombie devices.** After a forced detach the image's device can remain in the
system. Attaching then returns a dead handle, on which `fsck_apfs` reports
`failed to read container superblock` with an all-zero UUID. It looks like a
deleted backup, but it is only an unreadable device - on that basis the first
version of this test declared, three times in a row, the loss of data that was
intact.

**Orphaned mount point.** After an unclean detach the `/Volumes/CloudMachine`
directory remains and blocks re-attaching with the message
`no mountable file systems`. It belongs to the user, but it sits in `/Volumes`,
which belongs to root, so `rmdir` refuses - **an agent running as the user
cannot clean up after itself**. The app detects this and gives the exact
command.

## The buffer is a soft limit

`--vfs-cache-max-size` is not a hard limit: rclone evicts from the buffer only
data that has already been uploaded, so when everything is waiting in the queue,
the buffer keeps growing and can fill the disk. Time Machine writes to the image
at SSD speed (measured 267 MB/s), rclone uploads at link speed (~41 MB/s) - at
the start of the first backup the buffer grew by a net 32 MB/s.

That is why `BufferGuardService` pauses Time Machine above a threshold and
resumes it once uploading catches up. It also watches Drive's daily limit: once
it is exceeded, rclone stops working by design and bringing it back up achieves
nothing until the limit resets.

## Measurement harnesses

They are not part of the running system - they are run by hand when something
needs to be measured or a regression confirmed. They measure the behaviour of
`hdiutil` and FUSE-T, i.e. things a unit test cannot measure.

They live in a separate binary, `cloudmachine-poc`, which `build-app` does NOT
put into `CloudMachine.app` - so they never reach users' machines, yet they are
still built and checked by CI along with the rest of the code. Each of them
creates and deletes disk images, which is why they are deliberately not
subcommands of `cloudmachine-agent`: there is no way to launch them by mistake
on production.

```sh
cd mac-app
swift run cloudmachine-poc amplification --band-mb 32 --workload append
swift run cloudmachine-poc pullplug --band-mb 32 --rounds 3

# after an interrupted run, attached images are left behind - cleanup:
swift run cloudmachine-poc amplification --clean
swift run cloudmachine-poc pullplug --clean
```

## What is still unknown

- How the mount will behave under the load of a full, multi-hour backup.
  Individual operations work (a 50 MB write at 267 MB/s), but that is a
  different scale.
- Whether rclone never evicts data that has not been uploaded yet from the
  buffer. `cloudmachine-poc pullplug` covers a stronger case - the death of the
  whole layer - but not this specific one, because it requires a running rclone.
- Whether `tmutil setdestination` accepts a destination outside `/Volumes`. That
  determines whether the need for manual intervention after an unclean detach
  can be removed.
