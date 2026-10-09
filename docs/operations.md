# Running CloudMachine

The menu-bar app is all most people need. This page is for checking from
Terminal, reading the logs, and knowing what to do before a reboot.

## Running it

Day to day, the menu-bar icon is the whole interface. Its menu shows whether a
backup is running and what is still waiting to upload, with **Back up now** and
**Stop backup**. The window answers one question — is the backup reaching Google
Drive, and if not, why: the time of the last *completed* backup, the state of
the local buffer and the upload, and a red line naming the problem when there is
one. Problems also arrive as macOS notifications, so nothing depends on someone
opening the window.

Everything the window shows is also available in Terminal, for scripts and for
checking over SSH:

```sh
cloudmachine-agent drive-status
```

```
Tools:            OK
Drive mount:      OK
Remote control:   private socket
Drive folder:     gdrive:CloudMachine/mac-studio
Image attached:   OK  (/Volumes/CloudMachine)
Cache on disk:    103 GB of 100G
To upload:        ~14 GB (462 items)
Free on disk:     288 GB
Upload queue:     0 in progress, 0 queued, 0 errors
Restart without asking: YES - queue empty
Upload:           Everything uploaded to Google Drive
TM destination:   /Volumes/CloudMachine
Backup:           not running
```

The number that matters is the upload queue. Until it returns to zero between
backups, part of the backup is still only on this Mac.

The `Upload:` line is the same verdict the app window shows, computed in one
place so the two can never disagree. When it is not nominal it prints a second
line saying why, and whether it clears on its own.

It has three kinds of answer, not two. Besides "fine" and "broken" there is
**"unknown"** — printed when rclone does not answer the question about its
queue. That third state exists because of a specific lie: the queue read used
to time out, the caller substituted zeros for the missing numbers, and both the
CLI and the app then announced *Everything uploaded to Google Drive* while 386
bands sat unsent. A verdict computed from numbers nobody measured is worse than
no verdict, so now it says so.

Five launchd agents keep it alive, all running code from inside the app:

| Agent | Job |
|---|---|
| `gdrive-buffer` | holds the rclone mount; `KeepAlive` |
| `gdrive-attach` | attaches the image, retries every 15 minutes |
| `buffer-guard` | watches the buffer and the upload; `KeepAlive` |
| `backup-health` | every 30 min: is a backup still *completing*? |
| `app` | the menu-bar app itself |

`buffer-guard` distinguishes two things that look identical in every counter and
mean opposite things. **Out of space on Drive** does not pass on its own, so it
pauses Time Machine until someone frees space. **The daily write quota** clears
by itself within hours, so it only reports — measured twice, the buffer did not
move off 99–103 GB during either stall, and pausing would have cost backups for
nothing. The disk is still protected either way: the size thresholds (see
[How it works](design.md#why-the-pieces-are-what-they-are)) act whatever the
cause.

### Knowing when it stops working

Every other check here reports the state of the plumbing — mount up, image
attached, queue empty. None of them notices the failure that matters most:
everything looks attached and nothing has finished a backup in two days. The
dashboard shows a green tick for exactly that state.

```sh
cloudmachine-agent backup-health
```

```
Last successful backup: 2026-09-12 18:25
Last attempt:           2026-09-12 18:02
Backup cycle: OK
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
| `~/Library/Logs/CloudMachine/launchd-*.out.log`, `launchd-*.err.log` | stdout and stderr per agent |

Neither main log can eat the disk: `cloudmachine.log` is cut back to its last
5,000 lines once it passes 200 MiB, and `rclone.log` is moved aside to
`rclone.log.1` when the mount starts if it is over 100 MiB.

**Check the timestamps before concluding anything.** An entry is not news
because it is the last one in the file; on a quiet day the newest line can be
hours old.

```sh
# Did anything fail today?
grep "^\[$(date +%Y-%m-%d)" ~/Library/Logs/CloudMachine/cloudmachine.log | grep -i "backup failure"

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

That last sentence is also why silence proves nothing about the watchdog itself.
`backup-health` runs on `StartInterval 1800` with no `KeepAlive`, so an agent
that was unloaded or that hung looks exactly like one that ran and had nothing
to report. Every run therefore drops its date into
`~/Library/Application Support/CloudMachine/backup-health-last-run`, and both
`drive-status` and the app window show it:

```
Backup watchdog:  2026-09-25 22:04 (12 min ago)
Backup watchdog:  2026-09-22 03:10 (3 days ago) - THE WATCHDOG MAY NOT BE RUNNING
```

The second line means nobody has been asking whether the backup works — not
that the backup is broken. Check the cycle yourself (`cloudmachine-agent
backup-health`) and then find out why the agent stopped
(`launchctl print gui/$UID/com.renacode.cloudmachine.backup-health`).

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

It stays quick despite the ten-minute `--vfs-write-back`: detaching pulls every
queued expiry forward first, so the wait is the upload itself, not the delay. A
`prepare-shutdown` nobody is willing to sit through is one nobody runs, and
skipping it is what once left Time Machine without a destination overnight.

Sleep is safe and needs nothing: the buffer survives, uploads resume on wake,
and Power Nap wakes the Mac for scheduled backups.
