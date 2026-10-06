# How CloudMachine works, and what it costs

Why the design is what it is, and the numbers measured on a real Mac.

## What it costs in practice

Measured on a Mac Studio, 332 Mbit/s uplink:

| | |
|---|---|
| Full backup | 210 GiB, about two hours |
| Incremental backup | ~370 MB of new data, a few minutes |
| Google Drive used | 589 GiB (29 Sep 2026) — of which only 417 GiB is live data |
| Actually uploaded per day | **327–595 GB** — see below |

That last row is not a typo, and it is the number that surprises people. What
Time Machine *writes* and what rclone *sends* are different quantities, because
the unit of upload is a 32 MB band and any touch of a band re-sends all of it.
Time Machine revisits the same bands throughout a run, so one changed byte can
cost 32 MB several times over.

Measured here across five days: bands were re-sent a median of **9.5 minutes
apart**, giving 7.6× to 24× more traffic than the underlying change. On 14–15
September 2026 that put 823 GB on the wire in 24 hours for roughly 45 GB of real
change — past Google's 750 GB/day write ceiling, which blocked *all* uploads for
several hours.

So the daily cap is not just a first-backup concern, and it does not require a
source larger than 750 GB. A 265 GiB backup reached it. `--vfs-write-back` is
the lever that keeps it in check — see [Why the pieces are what they
are](#why-the-pieces-are-what-they-are) below.

### The image is larger than the backup, and the gap only grows

The other number that surprises people is the first one. Measured 29 September
2026, on an image created on the 11th:

```
live data in the volume   417 GiB
bands on Google Drive     589 GiB   (18,860 files x 31.98 MiB)
gap                       172 GiB   -- 29% of the image holds nothing
```

Three layers, none of which can tell the one below what it just did:

1. Time Machine writes a snapshot. APFS allocates blocks, the sparsebundle
   allocates the 32 MB bands covering them.
2. Time Machine thins old snapshots. APFS frees those blocks *inside* the
   volume — but **there is no TRIM path from a filesystem, through `hdiutil`,
   down to the band files.** The band stays, holding data nothing references.
3. APFS keeps writing. Being copy-on-write, it prefers untouched ranges over
   recycling what was just freed.

Step 3 is what makes this grow rather than settle. If freed blocks were reused
promptly the dead bands would be self-replenishing headroom and the image would
plateau. They are not, so the gap widens.

**Do not try to reclaim it with `hdiutil compact`.** It is the only tool for the
job and it takes nothing but an image path — no way to scope it. Against an
image that lives on Drive it would pull the whole ~589 GiB down through rclone
past a 100 GB cache, push back hundreds of GiB as it relocates data, blow the
750 GB/day write ceiling, and hold the image detached for a day or more with no
backups running. The return is a fraction of the 172 GiB, because a band can
only be dropped when all 32 MB of it is free and APFS scatters its allocations.
Google does not bill for writes; the dead bands cost quota and nothing else.

The lever worth *measuring*, if the gap ever matters, is the cause rather than
the symptom: the volume is 3.9 TiB of logical space holding 417 GiB, so the
allocator never has a reason to reuse anything. Sizing the image nearer the
working set should force recycling and flatten the band count. That is an
untested hypothesis, written down here so the next person does not have to
re-derive it.

One trap while reading any of this: **Google's storage UI labels GiB as GB.**
The "591.79 GB" it shows is 589 GiB of sparsebundle plus 2.8 GiB of everything
else on the account. `operations/about` through the rclone rc gives real bytes.

## Why the pieces are what they are

**32 MB bands.** Google Drive allows roughly two operations per file per second
and caps a drive at 400,000 files, which favours large bands. But every change
dirties a whole band, which favours small ones. Measured under Time Machine's
actual write pattern, 64 MB bands cost exactly twice the transfer of 8 MB bands.
32 MB is the smallest band at which the first upload stops being bound by
Drive's per-file rate and becomes bound by the link. The size is fixed when the
image is created and cannot be changed afterwards.

**A ten-minute write-back.** `--vfs-write-back` sets how long rclone waits after
a band stops changing before sending it. Short delays send a band again on every
touch; long delays coalesce those touches into one upload but widen the window
where data exists only locally.

It was 30 s, and that is how 823 GB went out in a day for 45 GB of change. The
current 600 s comes from measurement rather than taste: across 56,533 gaps
between consecutive re-sends of the same band, the median gap is 9.5 minutes, so
ten minutes absorbs about half of the repeats. Going further pays less and less —
15 minutes reaches 57%, 30 minutes 70% — while the local-only window grows in
proportion.

The catch is that a long write-back breaks every drain path, because a queued
item carries a future expiry and `waitUntilQuiet` counts it. Detaching would
block for the full ten minutes and time out. `expireQueuedUploads()` pulls those
expiries forward through rclone's `vfs/queue-set-expiry`, so detach still drains
in seconds. Attach does the same before waiting, since `hdiutil` on FUSE-T
rejects mounts more often while rclone is busy.

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
when the backlog grows past a threshold and resumes when the upload catches up,
trading speed for finishing at all.

What it measures is the **unsent backlog**, not the size of the cache. Those are
not the same number and the difference cost the guard its whole purpose: with
`--vfs-cache-max-age 9999h` the cache sits at its limit permanently (281
measurements here, never below 99 GB), so a resume threshold expressed in cache
size was unreachable. The journal shows it exactly: one PAUZA line ever, and not
a single WZNOWIENIE. The backlog is the part of the cache rclone *cannot* evict,
so it is also the number that decides whether the limit can hold at all — the
guard pauses above 50 GB of backlog and resumes below 10 GB, both derived from
the 100 GB cache size rather than written down twice. The backlog in gigabytes
is an *estimate*: rclone reports how many items are queued, not how many bytes,
and every item here is a fixed 32 MiB sparsebundle band, so the guard multiplies
and says so with a `~` wherever it prints the number.

**Pausing is not one command.** `tmutil stopbackup` cancels the backup that is
running and does not touch the schedule, so macOS starts another one an hour
later. The guard therefore re-issues the stop on every 30-second tick for as
long as the pause lasts, rather than once when it enters the paused state — that
bug kept the state for 53 hours while the actual write pause lasted one backup.
`tmutil disable` would hold by itself, and is deliberately not used: the guard
keeps its state in memory and runs under `KeepAlive`, so a crash between
disabling and resuming would leave Time Machine switched off with nobody to
switch it back on.

Disk protection does not depend on any of the above. The free-space threshold
and rclone's own "out of space" are checked in **every** state, including while
paused — previously they lived in the running branch only, so one pause switched
off the protection this process exists for. And nothing here treats a missing
answer as good news: if rclone's control interface does not reply, the backlog is
*unknown*, which neither pauses nor resumes, and says so in the log once.
