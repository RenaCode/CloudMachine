import Foundation

/// The backup image living on Google Drive - a port of `gdrive/create-image.sh`,
/// `attach-image.sh` and `verify-image.sh`.
///
/// Time Machine is handed an attached, ordinary APFS volume and does not know
/// that the image's bands live in the cloud. Thanks to that there is no network
/// file system in the write path - SMB is gone, and with it a whole class of
/// failures that plague network backups.
public enum BackupImageService {

  // MARK: - Paths

  public static let imageName = "mac-studio"
  public static let volumeName = "CloudMachine"

  public static var imagePath: URL {
    DriveBufferService.mountPoint.appendingPathComponent("\(imageName).sparsebundle")
  }

  /// The destination's mount point.
  ///
  /// `/Volumes` is a path Time Machine is sure to accept - and that is the only
  /// reason it is here. The price: after an unclean detach the
  /// `/Volumes/<name>` directory is left behind orphaned and blocks the next
  /// attach. It belongs to the user, but lives in root-owned `/Volumes`, so
  /// `rmdir` refuses - an agent running as the user cannot clean up after
  /// itself. The alternative (a directory wholly ours, self-healing) is
  /// untested: it is unknown whether `tmutil setdestination` accepts a
  /// destination outside `/Volumes`.
  public static var targetPath: URL {
    URL(fileURLWithPath: "/Volumes/\(volumeName)")
  }

  /// 32 MB per band, in 512 B sectors. Chosen by measurement - see
  /// `cloudmachine-poc amplification` and the table in `gdrive/README.md`.
  ///
  /// Two forces pull in opposite directions. Google Drive lets through about
  /// two operations per file per second, so small bands lengthen the first
  /// upload. But every change dirties the whole band, so large bands multiply
  /// the transfer on every increment - measured 768 MB at 64 MB versus 384 MB
  /// at 8 MB for the same 300 MB of real change. 32 MB is the point where the
  /// first upload stops being limited by the operation rate and starts being
  /// limited by link bandwidth.
  ///
  /// Only takes effect when the image is created - changing it later requires a
  /// backup from scratch.
  public static let bandSectors = 65536

  private static let fsckPath =
    "/System/Library/Filesystems/apfs.fs/Contents/Resources/fsck_apfs"

  // MARK: - Mutual exclusion

  /// Name of the lock under which ALL operations that change the image's state
  /// run: `create`, `attach`, `detach`, `verify`.
  ///
  /// Until 23 September 2026 they did not exclude each other at all - `CMLock`
  /// existed, but `withCMLock` was not called from a single place in the repo.
  /// The real run that exposed it: `detach` waits for the drain (35 s pause for
  /// the queue to fill + up to 600 s for quiet, i.e. a window of up to 10.5
  /// minutes), and the `gdrive-attach` agent ticks every 900 s. The agent
  /// regularly hit that window, saw the image as detached - because
  /// `hdiutil detach` had already gone through - and attached it back in the
  /// middle of someone else's detach.
  ///
  /// A second variant of the same race: `purgeStaleDevices()` from the agent's
  /// tick runs `hdiutil detach -force` on the device that `fsck_apfs` from
  /// `verify` is running on at that moment - and `verify` reported "Image
  /// INCONSISTENT" about the whole backup (see the comment at `verify`).
  public static let lockName = "image"

  /// Result of an operation that DID NOT HAPPEN, because another operation
  /// holds the image.
  ///
  /// `withCMLock` then returns `nil`, and that `nil` must not pass as success:
  /// an `attach` that never happened would report "Attached", and a `detach`
  /// that never happened - "everything uploaded to Google Drive".
  ///
  /// `operation` goes to the log, `displayName` to the person.
  private static func busyResult(_ operation: String, displayName: String) -> CMActionResult {
    CMLogger.log(
      "\(operation): lock '\(lockName)' is held by another image operation - doing nothing")
    return CMActionResult(
      succeeded: false,
      message: L10n.tr(
        "%@: another image operation is in progress (creating, attaching, detaching or verifying) - NOTHING was done. Try again shortly.",
        displayName),
      // Not a failure, just "not now" - see `CMActionResult.Disposition`.
      didNotRun: true)
  }

  // MARK: - State

  public static var exists: Bool {
    var isDir: ObjCBool = false
    let ok = FileManager.default.fileExists(atPath: imagePath.path, isDirectory: &isDir)
    return ok && isDir.boolValue
  }

  /// Whether the volume is in the mount table.
  ///
  /// NOTE: this only says that `hdiutil` attached the image at some point - NOT
  /// that the image returns data. A dead device (see `ImageProbe`) sits in that
  /// table just like a live one. The question "does Time Machine have somewhere
  /// to write" is answered by `attachment`; `isAttached` stays where only the
  /// detach itself matters.
  public static var isAttached: Bool { attachedState() ?? false }

  /// Like `isAttached`, but `nil` = the mount table COULD NOT be read.
  ///
  /// The same change as in `DriveBufferService.mountPoints()` and for the same
  /// reason: until now this went through `/sbin/mount` without a time limit,
  /// and it asks about a volume that is sometimes DEAD - that is, exactly the
  /// one on which such a read can hang. Now it goes through the kernel table,
  /// without a process and without touching the file system.
  public static func attachedState() -> Bool? {
    guard let points = DriveBufferService.mountPoints() else { return nil }
    return points.contains(targetPath.path)
  }

  public enum Attachment: Equatable, Sendable {
    case detached
    case attached
    /// In the mount table, but reads fail with the given `errno`. Time Machine
    /// sees this state as "disk disconnected" and will not make a single
    /// backup until the image is detached and attached again.
    case dead(errno: Int32)
    /// NOTHING is known about the image's state. This is not `.detached`:
    /// `.detached` is a claim ("I checked, it is not there"), while here there
    /// was nothing to check.
    ///
    /// Two causes, both leading to the same decision (hold off, do not touch
    /// the image):
    ///
    /// 1. The mount table could not be read. Since the switch to
    ///    `getmntinfo(MNT_NOWAIT)` extremely unlikely - it is a read from
    ///    kernel memory that has no way to hang or go to the network.
    /// 2. The image IS in the mount table, but the readability probe did not
    ///    answer within `ImageProbe.probeTimeout` (since 26.09.2026 - before
    ///    that it did not answer forever and took the caller down with it).
    ///
    /// There is deliberately NO separate, fifth state for the second case:
    /// every decision made on this type is identical in both cases, and
    /// separating them would invite those paths to drift apart. Whoever writes
    /// to a person and has to give the cause takes it from
    /// `attachmentReading()`.
    case unknown

    /// Whether Time Machine has somewhere to write. `.unknown` deliberately
    /// gives `false` - the question is "CAN I rely on this", and you cannot
    /// rely on an unknown.
    public var isUsable: Bool { self == .attached }
  }

  /// Attachment state taking into account whether the device is ALIVE.
  ///
  /// `async` rather than a computed property ever since the readability probe
  /// got a time limit: waiting for it must not block the calling thread (see
  /// `ImageProbe` - the panel's `@MainActor` and the monitor without
  /// `KeepAlive` paid for that with a frozen interface and silence).
  public static func attachment() async -> Attachment {
    await attachmentReading().attachment
  }

  /// Like `attachment()`, but ALSO says whether "I do not know" came from a
  /// probe that did not answer in time.
  ///
  /// For the decision the difference does not matter (both cases hold off),
  /// but for the MESSAGE it matters a lot: "could not read the mount table"
  /// tells a person to check something entirely different than "the image is
  /// in the table, but reads from it do not come back".
  public static func attachmentReading() async -> (attachment: Attachment, probeTimedOut: Bool) {
    switch attachedState() {
    case .none: return (.unknown, false)
    case .some(false): return (.detached, false)
    case .some(true):
      switch await ImageProbe.probe(volume: targetPath) {
      case .dead(let errno): return (.dead(errno: errno), false)
      case .readable, .nothingToProbe: return (.attached, false)
      // NOT `.dead`: `.dead` means "the device answered with a device error",
      // while here the device did not answer at all.
      case .timedOut: return (.unknown, true)
      }
    }
  }

  public static func describe(_ attachment: Attachment, probeTimedOut: Bool = false) -> String {
    switch attachment {
    case .detached: return L10n.tr("NOT ATTACHED")
    case .attached: return "OK  (\(targetPath.path))"
    case .dead(let errno):
      return L10n.tr(
        "DEAD - in the mount table, but reads fail (errno %@); attach-image attaches it again",
        "\(errno)")
    case .unknown where probeTimedOut:
      return L10n.tr(
        "UNKNOWN - in the mount table, but the readability probe did not answer within %@ s",
        "\(Int(ImageProbe.probeTimeout))")
    case .unknown:
      return L10n.tr("UNKNOWN - could not read the mount table")
    }
  }

  /// Mount points of browsed backup snapshots.
  ///
  /// A pure version, so that it can be tested without mounting anything -
  /// previously the same thing came from parsing `/sbin/mount` output
  /// (`" on "` ... `" ("`), so there was nothing to substitute a sample for.
  static func browsedSnapshotMounts(_ points: [String]) -> [String] {
    points.filter { $0.hasPrefix("/Volumes/.timemachine/") }
  }

  // MARK: - Hung devices

  /// `/dev/diskN` devices attached to the given image.
  ///
  /// After a forced detach a device can remain in the system as a zombie.
  /// A new attach then ends with a "no mountable file systems" error, or -
  /// worse - returns a dead handle on which `fsck_apfs` reports "failed to read
  /// container superblock" with an all-zero UUID. It looks like a deleted
  /// backup, but is only an unreadable device: an earlier version of the
  /// pull-the-floor test concluded three times in a row, on that basis, that
  /// data was lost which was in fact intact.
  public static func devicesForImage(_ image: URL = imagePath) async -> [String] {
    guard let result = try? await ProcessRunner.run("/usr/bin/hdiutil", ["info"], timeout: 60),
      result.succeeded
    else { return [] }
    return parseDevices(hdiutilInfo: result.stdout, imagePath: image.path)
  }

  /// Pure version of the parser - `hdiutil info` groups entries into blocks,
  /// where all `/dev/diskN` lines after an `image-path` line belong to it.
  public static func parseDevices(hdiutilInfo: String, imagePath: String) -> [String] {
    var devices: [String] = []
    var currentImage: String?
    for line in hdiutilInfo.components(separatedBy: .newlines) {
      if line.hasPrefix("image-path") {
        currentImage =
          line
          .drop(while: { $0 != ":" })
          .dropFirst()
          .trimmingCharacters(in: .whitespaces)
        continue
      }
      guard line.hasPrefix("/dev/disk"), currentImage == imagePath else { continue }
      let device = String(line.prefix(while: { !$0.isWhitespace }))
      // We want the parent device (/dev/disk7), not the partition
      // (/dev/disk7s1) - detaching the parent takes the partitions with it.
      //
      // NOTE: the tempting `!device.contains("s")` is WRONG, because "disk"
      // contains an "s" too and it rejects everything. We check whether only
      // digits are left after the prefix.
      let suffix = device.dropFirst("/dev/disk".count)
      guard !suffix.isEmpty, suffix.allSatisfy(\.isNumber) else { continue }
      if !devices.contains(device) {
        devices.append(device)
      }
    }
    return devices
  }

  public static func purgeStaleDevices(_ image: URL = imagePath) async {
    for device in await devicesForImage(image) {
      _ = try? await ProcessRunner.run(
        "/usr/bin/hdiutil", ["detach", device, "-force", "-quiet"], timeout: 60)
    }
  }

  // MARK: - Creation

  /// Creates the image IN PLACE, on the mounted Drive.
  ///
  /// Creating it locally and moving it gives an image that `hdiutil` later
  /// does not open ("CBSDBackingStore::newProbe stat() failed"), even though
  /// all files and bands are in place and readable.
  public static func create(sizeGB: Int) async -> CMActionResult {
    await withCMLock(lockName) { await createLocked(sizeGB: sizeGB) }
      ?? busyResult("Image creation", displayName: L10n.tr("Creating the image"))
  }

  private static func createLocked(sizeGB: Int) async -> CMActionResult {
    switch DriveBufferService.mountedState() {
    case .some(true):
      break
    case .some(false):
      return CMActionResult(
        succeeded: false, message: L10n.tr("Drive is not mounted - start the buffer first."))
    case .none:
      // Not `isMounted`: creating the image is IRREVERSIBLE, so "I do not
      // know" must not pass here as "not mounted", let alone go any further.
      return CMActionResult(
        succeeded: false,
        message: L10n.tr(
          "Could not read the mount table - it is UNKNOWN whether the buffer is mounted. NOT creating the image."
        ))
    }

    // The "image already exists" guard reads the FUSE cache, and rclone
    // exposes the mount BEFORE it loads the directory contents from Drive - in
    // that window `exists` says "no image" about an image that is there.
    // `attach-image` has waited here on `BufferReadiness.wait` since
    // 13 September 2026, `create` did not wait at all. For `attach` missing the
    // window costs one failed attach; for `create` - `hdiutil create` goes to
    // the path of an existing backup, and with five retries at that.
    //
    // We wait for a SUCCESSFUL listing of the mount point, not just for
    // `isMounted`: the guard above has already answered the latter, so the
    // probe would pass immediately and the wait would do NOTHING. Listing the
    // root with a cold `--dir-cache-time` goes to Google for data, so its
    // success means "rclone is actually serving this directory"; until FUSE
    // has started serving, it ends with a device error.
    //
    // NOTE on scope: this wait removes the "FUSE is not answering yet" window,
    // but does NOT prove the image is absent - an empty listing looks the same
    // for an empty account and for a directory not yet loaded. The proof is
    // `remoteImagePresence()` below, and it, not this wait, holds back the
    // irreversible operation.
    let ready = await BufferReadiness.wait(
      sleep: { seconds in
        try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
      },
      probe: {
        DriveBufferService.isMounted
          && (try? FileManager.default.contentsOfDirectory(
            atPath: DriveBufferService.mountPoint.path)) != nil
      })
    guard ready else {
      return CMActionResult(
        succeeded: false,
        message: L10n.tr(
          "The buffer did not come up within %@ min - NOT creating the image.",
          "\(Int(BufferReadiness.defaultTimeout / 60))"))
    }

    guard !exists else {
      return CMActionResult(
        succeeded: false,
        message: L10n.tr(
          "The image already exists. Deleting it erases the whole backup - do it deliberately."))
    }

    // The FUSE cache has already lied once, so we ask the REMOTE again,
    // bypassing the mount. This is an IRREVERSIBLE operation: lack of certainty
    // must ABORT it, not just print a warning that nobody reads before
    // confirming anyway.
    switch await remoteImagePresence() {
    case .absent:
      break
    case .present:
      return CMActionResult(
        succeeded: false,
        message: L10n.tr(
          "The image already exists on Google Drive (the mount cache did not show it, but the remote has it). Deleting it erases the whole backup - do it deliberately."
        ))
    case .unknown(let why):
      return CMActionResult(
        succeeded: false,
        message: L10n.tr(
          "Could not confirm on Google Drive that the image is not there yet (%@) - ABORTING. Creating the image over an existing backup is irreversible, so I do not start without that answer.",
          why))
    }

    await DriveBufferService.waitUntilIdle(timeout: 180)

    let args = [
      "create", "-type", "SPARSEBUNDLE",
      "-size", "\(sizeGB)g",
      "-fs", "Case-sensitive APFS",
      "-volname", volumeName,
      "-imagekey", "sparse-band-size=\(bandSectors)",
      imagePath.path,
    ]

    let result = await retryingFlakyMount(attempts: 5) {
      try? await ProcessRunner.run("/usr/bin/hdiutil", args, timeout: 600)
    }

    guard result?.succeeded == true else {
      return CMActionResult(
        succeeded: false,
        message: L10n.tr(
          "Could not create the image: %@", result?.stderr ?? L10n.tr("unknown error")))
    }
    return CMActionResult(
      succeeded: true,
      message: L10n.tr(
        "Created a %@ GB image, band size %@ MB.", "\(sizeGB)",
        "\(bandSectors * 512 / 1024 / 1024)"))
  }

  // MARK: - Image on the remote

  /// Whether the image is on Google Drive - asked WITHOUT going through the mount.
  public enum RemotePresence: Equatable {
    case present
    case absent
    /// Unknown. `why` goes into the message, so that the user knows what
    /// exactly was missing.
    case unknown(String)
  }

  /// Asks `rclone lsf` directly about the remote backup directory.
  ///
  /// The point is that it bypasses the FUSE cache - and it is precisely the
  /// FUSE cache that says "no image" during the first seconds after the mount
  /// is exposed.
  public static func remoteImagePresence() async -> RemotePresence {
    let remote = "\(DriveBufferService.remoteName):\(DriveBufferService.remotePath)"
    guard
      let result = try? await CMTooling.runRclone(["lsf", "--dirs-only", remote], timeout: 120)
    else {
      return .unknown(L10n.tr("rclone did not answer"))
    }
    return classifyRemoteListing(
      succeeded: result.succeeded, stdout: result.stdout, stderr: result.stderr)
  }

  /// Pure version - so that it can be tested without a network and without an
  /// account.
  ///
  /// A failed `lsf` with the message "directory not found" is NOT a missing
  /// answer, but the answer "there is nothing there": that is what the first
  /// run looks like, before anything has been uploaded to Drive. If we counted
  /// it as `.unknown`, `create` could not run EVEN ONCE - the guard would block
  /// exactly the case it exists for.
  static func classifyRemoteListing(succeeded: Bool, stdout: String, stderr: String)
    -> RemotePresence
  {
    if succeeded {
      return listingContainsImage(stdout) ? .present : .absent
    }
    if stderr.lowercased().contains("directory not found") { return .absent }
    let reason = stderr.trimmingCharacters(in: .whitespacesAndNewlines)
    return .unknown(
      reason.isEmpty ? L10n.tr("rclone lsf ended with an error") : String(reason.suffix(200)))
  }

  /// `rclone lsf --dirs-only` ends directory names with a slash, but we do not
  /// rely on it - we accept both forms.
  static func listingContainsImage(_ listing: String) -> Bool {
    let wanted = "\(imageName).sparsebundle"
    return listing.components(separatedBy: .newlines)
      .map { $0.trimmingCharacters(in: .whitespaces) }
      .contains { $0 == wanted || $0 == wanted + "/" }
  }

  // MARK: - Attaching

  public static func attach() async -> CMActionResult {
    await withCMLock(lockName) { await attachLocked() }
      ?? busyResult("Image attach", displayName: L10n.tr("Attaching the image"))
  }

  private static func attachLocked() async -> CMActionResult {
    switch DriveBufferService.mountedState() {
    case .some(true):
      break
    case .some(false):
      return CMActionResult(succeeded: false, message: L10n.tr("Drive is not mounted."))
    case .none:
      // Attaching the image on an UNMOUNTED buffer ends with an image hanging
      // on an empty directory, so "I do not know" must hold off here, not let
      // it through. The agent's tick will try again in 900 s.
      return CMActionResult(
        succeeded: false,
        message: L10n.tr(
          "Could not read the mount table - it is UNKNOWN whether the buffer is mounted. NOT attaching the image."
        ))
    }
    guard exists else {
      return CMActionResult(
        succeeded: false, message: L10n.tr("No image - create it first."))
    }
    let reading = await attachmentReading()
    switch reading.attachment {
    case .attached:
      return CMActionResult(
        succeeded: true, message: L10n.tr("Already attached: %@", targetPath.path))
    case .unknown:
      // Not `.detached`, because the next step would be `hdiutil attach` on an
      // image that may already be attached - and before that
      // `purgeStaleDevices()`, i.e. `detach -force` on someone else's live
      // device. "I do not know" must not trigger either of them.
      //
      // This ALSO applies to a probe that did not answer in time. The price is
      // real and chosen deliberately: if the image really is dead and reads
      // from it hang, this function will not fix it, and the agent's tick will
      // try again in 900 s. The opposite mistake, however, is irreversible -
      // `detach -force` on a slow but LIVE device drops writes that have not
      // reached Drive. The `backup-health` monitor reports that the state is
      // unknown; there is no silence here.
      if reading.probeTimedOut {
        return CMActionResult(
          succeeded: false,
          message: L10n.tr(
            "The image is in the mount table, but the readability probe did not answer within %@ s - it is UNKNOWN whether the device is alive. NOT force-detaching and NOT attaching.",
            "\(Int(ImageProbe.probeTimeout))"))
      }
      return CMActionResult(
        succeeded: false,
        message: L10n.tr(
          "Could not read the mount table - it is UNKNOWN whether the image is attached. NOT attaching."
        ))
    case .dead(let errno):
      // The image is in the mount table, but returns no data. Until 22 Sep 2026
      // this function then said "Already attached" and returned - the attaching
      // agent repeated that every 15 minutes for 15 hours, and Time Machine had
      // no destination. The only way is to detach (it has to be `-force`, a
      // plain one refuses on a dead device) and attach again. The wait for the
      // upload stays: whatever made it into the rclone buffer still has to
      // reach Drive.
      CMLogger.log("Image dead (errno \(errno)) - force-detaching and attaching again")
      // `detachLocked`, not `detach`: we already hold the 'image' lock, and
      // `CMLock` is not reentrant - going through the public `detach` would see
      // our own live lock and refuse itself.
      let detached = await detachLocked(force: true)
      CMLogger.log("Detaching the dead image: \(detached.message)")
      guard !isAttached else {
        return CMActionResult(
          succeeded: false,
          message: L10n.tr(
            "Image dead (errno %@) and could not be detached: %@", "\(errno)", detached.message))
      }
    case .detached:
      break
    }

    await purgeStaleDevices()

    // An orphaned mount point blocks the attach. If it is in /Volumes, removing
    // it needs root - so we say exactly what to run, instead of retrying
    // forever.
    if FileManager.default.fileExists(atPath: targetPath.path) {
      do {
        try FileManager.default.removeItem(at: targetPath)
      } catch {
        return CMActionResult(
          succeeded: false,
          message: L10n.tr(
            "An orphaned mount point blocks the attach: %@\nRemove it and try again:  sudo rmdir '%@'",
            targetPath.path, targetPath.path))
      }
    }

    // A quiet queue is not a convenience here but a condition for success:
    // `hdiutil` on a FUSE-T volume rejects the mount the more often, the busier
    // rclone is (see `retryingFlakyMount`). With `writeBackSeconds` counted in
    // minutes the queue will not empty by itself within the time limit below,
    // so we force the upload first - otherwise attaching after every start-up
    // would be a lottery.
    //
    // We wait as long as the upload makes progress, not a fixed 120 s - after a
    // restart without `prepare-shutdown` the backlog reaches a dozen or more GB
    // (see `UploadDrain`).
    let drain = await UploadDrain.wait(
      sleep: { try? await Task.sleep(nanoseconds: UInt64($0 * 1_000_000_000)) },
      expire: { _ = await DriveBufferService.expireQueuedUploads() },
      unsent: { await DriveBufferService.queueStats()?.unsentItems })
    switch drain {
    case .idle:
      break
    case .stalled(let unsent):
      CMLogger.log("Attach: upload stalled (\(unsent) items queued) - attaching anyway")
    case .timedOut(let unsent):
      CMLogger.log(
        "Attach: backlog did not drain within \(Int(UploadDrain.defaultMaxTotal / 60)) min (\(unsent) items) - attaching anyway"
      )
    case .noAnswer:
      CMLogger.log("Attach: rclone does not answer about the queue state - attaching blind")
    }

    let result = await retryingFlakyMount(attempts: 5) {
      try? await ProcessRunner.run(
        "/usr/bin/hdiutil",
        ["attach", imagePath.path, "-nobrowse", "-mountpoint", targetPath.path],
        timeout: 300)
    }

    guard result?.succeeded == true else {
      return CMActionResult(
        succeeded: false,
        message: L10n.tr(
          "Could not attach the image: %@", result?.stderr ?? L10n.tr("unknown error")))
    }
    return CMActionResult(succeeded: true, message: L10n.tr("Attached: %@", targetPath.path))
  }

  /// Detaches the image and WAITS until everything has reached Google Drive.
  ///
  /// The wait is not extra caution. The detach itself writes APFS metadata to
  /// the bands, and `--vfs-write-back` delays uploading them by tens of
  /// seconds. Losing the buffer in that window does not cost "the latest
  /// changes" - it takes the volume's root directory. Observed live: 367 MiB of
  /// bands were already on Drive, and the image was empty after re-attaching,
  /// because three bands with metadata were killed in the queue.
  ///
  /// That is why every shutdown path - detach, stopping the buffer, turning off
  /// the Mac - must let the drain run to the end.
  public static func detach(force: Bool = false, waitForUpload: Bool = true) async -> CMActionResult
  {
    await withCMLock(lockName) { await detachLocked(force: force, waitForUpload: waitForUpload) }
      ?? busyResult("Image detach", displayName: L10n.tr("Detaching the image"))
  }

  private static func detachLocked(force: Bool = false, waitForUpload: Bool = true) async
    -> CMActionResult
  {
    let stillMounted = await unmountBrowsedSnapshots()

    var args = ["detach", targetPath.path, "-quiet"]
    if force { args.append("-force") }
    let result = try? await ProcessRunner.run("/usr/bin/hdiutil", args, timeout: 120)
    guard result?.succeeded == true else {
      // We give the reason if we know it. `hdiutil` only says "resource busy"
      // and not a word about what holds the device - and that is almost always
      // a browsed backup snapshot.
      guard stillMounted.isEmpty else {
        return CMActionResult(
          succeeded: false,
          message: L10n.tr(
            "Could not detach - the image is held by browsed backup snapshots that could not be unmounted:\n%@\nClose the Time Machine / Finder window on the backup and try again.",
            stillMounted.joined(separator: "\n")))
      }
      return CMActionResult(succeeded: false, message: L10n.tr("Could not detach."))
    }

    guard waitForUpload else {
      return CMActionResult(
        succeeded: true,
        message: L10n.tr(
          "Detached (without waiting for the upload - the data may be local only)."))
    }

    // Writes from the detach must reach the queue first - without this pause
    // it would look empty, because it would not have had time to fill yet.
    //
    // NOTE on the mechanism: an item appears in the queue RIGHT after the
    // write, only with an upload deadline `writeBackSeconds` ahead (visible in
    // `vfs/queue` as a positive `expiry`). So this pause waits for the queuing
    // itself, NOT for that deadline to pass - the earlier comment here claimed
    // the opposite.
    try? await Task.sleep(nanoseconds: 35_000_000_000)

    // We move the deadlines only now, when the queue is complete. Without this
    // the drain would take as long as `writeBackSeconds` (ten minutes), i.e.
    // longer than the time limit below - and the detach would report failure
    // every time.
    CMLogger.log(expiryLogLine(await DriveBufferService.expireQueuedUploads()))
    return detachVerdict(settled: await DriveBufferService.statsWhenIdle(timeout: 600))
  }

  /// What the detach writes to the log after trying to speed up the queue.
  ///
  /// THREE different things looked like two here. "We got no answer" was told
  /// apart from "the queue was empty" on 23.09.2026, but the third case - the
  /// queue FULL and every `vfs/queue-set-expiry` failed - still came out of
  /// `expireQueuedUploads` as `0`, and the log reported "queue empty". The
  /// measured state of this machine at the time of the audit: 462 items queued.
  ///
  /// The failure mode is worse than just an untruth in the log: a person reads
  /// this line exactly when deciding whether the buffer may be deleted. "Queue
  /// empty" reads as "nothing is waiting to be uploaded", while it meant "462
  /// items are waiting and not one of them could be moved".
  ///
  /// Split out and PURE, so that these three cases can be tested without
  /// rclone. The function is only a description: waiting for the drain and the
  /// verdict are decided by `detachLocked`/`detachVerdict`, and this fix does
  /// not touch them.
  static func expiryLogLine(_ outcome: DriveBufferService.ExpiryOutcome?) -> String {
    let drain = "the drain may take up to \(DriveBufferService.writeBackSeconds / 60) min"
    guard let outcome else {
      // No answer is NOT an empty queue - see `expireQueuedUploads`.
      return "Detach: rclone did not answer the question about the queue - upload deadlines were"
        + " NOT moved, \(drain)"
    }
    if outcome.queued == 0 {
      return "Detach: queue empty - nothing to speed up"
    }
    if outcome.moved == 0 {
      return "Detach: WARNING - the queue has \(outcome.queued) items and NOT ONE could be"
        + " sped up (rclone rejected every vfs/queue-set-expiry), \(drain)"
    }
    if outcome.moved < outcome.queued {
      return "Detach: forced upload of \(outcome.moved) of \(outcome.queued) queued items -"
        + " the deadline of the remaining \(outcome.queued - outcome.moved) was NOT moved, \(drain)"
    }
    return "Detach: forced upload of \(outcome.moved) queued items"
  }

  /// Pure version of the detach verdict - `settled` is the queue reading from
  /// the moment it went quiet (`nil` = it did not go quiet in time, or rclone
  /// did not answer).
  ///
  /// An empty queue is not yet complete data on Drive. Bands that rclone
  /// ABANDONED drop out of the queue exactly like uploaded ones and remain only
  /// in `erroredFiles`. Until 23 September 2026 the detach looked only at
  /// `uploadsInProgress`/`uploadsQueued`, so it reported "Detached, everything
  /// uploaded to Google Drive" with data existing ONLY on this Mac - while
  /// `UploadState`, from the same counters, already derived `.failedFiles(...)`
  /// with the label "ACTION NEEDED". The CLI and the GUI said two different
  /// things about the same moment.
  static func detachVerdict(settled: DriveBufferService.QueueStats?) -> CMActionResult {
    guard let settled else {
      return CMActionResult(
        succeeded: false,
        message: L10n.tr(
          "Detached, but the upload did NOT finish in time - do not delete the buffer."))
    }
    guard settled.erroredFiles == 0 else {
      return CMActionResult(
        succeeded: false,
        message: L10n.tr(
          "Detached, but rclone ABANDONED %@ backup fragments - they exist only on this Mac and are not on Google Drive. Do not delete the buffer.",
          "\(settled.erroredFiles)"))
    }
    return CMActionResult(
      succeeded: true, message: L10n.tr("Detached, everything uploaded to Google Drive."))
  }

  /// Unmounts backup snapshots mounted under `/Volumes/.timemachine/`.
  /// Returns the paths that could NOT be unmounted.
  ///
  /// Browsing a backup - in Finder or with a plain `ls` on a path from
  /// `tmutil listbackups` - mounts its snapshot read-only. Such a mount keeps
  /// the image's device busy and `hdiutil detach` refuses, while the message
  /// says not a word about what is blocking it.
  ///
  /// We USE `diskutil unmount`, NOT `/sbin/umount`. Measured on a working
  /// installation: `umount` on such a snapshot ends with
  /// `Operation not permitted` for the user (the system manages the mount),
  /// while `diskutil unmount` on the same path succeeds without root.
  /// The previous version called `umount` via `try?` and logged "Unmounted"
  /// REGARDLESS of the result - so with 18 mounted snapshots the log reported
  /// 18 successes, none was unmounted, and `hdiutil detach` right after refused
  /// with no connection visible in the log.
  @discardableResult
  public static func unmountBrowsedSnapshots() async -> [String] {
    guard let points = DriveBufferService.mountPoints() else { return [] }
    var failed: [String] = []
    for path in browsedSnapshotMounts(points) {
      let result = try? await ProcessRunner.run(
        "/usr/sbin/diskutil", ["unmount", path], timeout: 60)
      if result?.succeeded == true {
        CMLogger.log("Unmounted browsed backup snapshot: \(path)")
      } else {
        failed.append(path)
        CMLogger.log("FAILED to unmount backup snapshot: \(path)")
      }
    }
    return failed
  }

  // MARK: - Verification

  /// Checks the image's consistency.
  ///
  /// NOTE: `hdiutil verify` on a sparsebundle does NOT work - such an image has
  /// no checksum and the tool ends with the message "has no checksum". The
  /// device has to be attached without mounting and `fsck_apfs` run on it.
  public static func verify() async -> CMActionResult {
    await withCMLock(lockName) { await verifyLocked() }
      ?? busyResult("Image verify", displayName: L10n.tr("Verifying the image"))
  }

  private static func verifyLocked() async -> CMActionResult {
    guard exists else {
      return CMActionResult(succeeded: false, message: L10n.tr("No image."))
    }
    if isAttached {
      return CMActionResult(
        succeeded: false,
        message: L10n.tr("The image is attached - detach it before verifying."))
    }

    guard
      let attachResult = try? await ProcessRunner.run(
        "/usr/bin/hdiutil", ["attach", imagePath.path, "-nomount"], timeout: 300),
      attachResult.succeeded,
      let device = attachResult.stdout
        .components(separatedBy: .newlines)
        .first(where: { $0.contains("41504653") })?
        .prefix(while: { !$0.isWhitespace })
    else {
      return CMActionResult(
        succeeded: false, message: L10n.tr("Could not find an APFS device in the image."))
    }

    // NO timeout. `fsck_apfs` reads metadata through the rclone mount, so its
    // time depends on the link and on the number of snapshots - measured on a
    // 210 GiB image with 18 snapshots: a single snapshot takes minutes.
    // The earlier one-hour limit protected against nothing, but turned "the
    // check is still running" into "Image INCONSISTENT", because a killed
    // `fsck` returns a non-zero code just like an `fsck` that found damage.
    // A false alarm about losing the backup is more dangerous here than a long
    // wait.
    let fsck = try? await ProcessRunner.run(fsckPath, ["-n", String(device)])

    // Was the device still ours when `fsck` finished?
    //
    // `fsck_apfs` returns a non-zero code both when it found damage and when
    // someone pulled the device out from under it - and
    // `purgeStaleDevices()` (`hdiutil detach -force`) can do exactly that on
    // the `gdrive-attach` agent's tick every 900 s. Without this check `verify`
    // then reported "Image INCONSISTENT", i.e. a false alarm about losing the
    // whole backup. The 'image' lock already closes that window, but the
    // message has to be honest also when the device disappears for another
    // reason.
    let deviceSurvived = await devicesForImage().contains(parentDevice(of: String(device)))

    // We detach WITH waiting, not via `defer { Task { ... } }`. That version
    // returned from the function before the detach happened - and the caller
    // usually attaches the image back right away, so the attach raced with a
    // pending detach of the same device.
    _ = try? await ProcessRunner.run(
      "/usr/bin/hdiutil", ["detach", String(device), "-force", "-quiet"], timeout: 120)

    // "Could not check" is NOT the same as "inconsistent" - one means no
    // result, the other a damaged backup. Merging them into one message would
    // make the user restore the whole backup because of a failed tool run.
    guard let fsck else {
      return CMActionResult(
        succeeded: false,
        message: L10n.tr(
          "Could not run %@ - the image's consistency REMAINS UNCHECKED.", fsckPath))
    }
    if !fsck.succeeded && !deviceSurvived {
      return CMActionResult(
        succeeded: false,
        message: L10n.tr(
          "Check INTERRUPTED - device %@ disappeared midway (someone force-detached the image). This is not a result about the backup's state: the image's consistency REMAINS UNCHECKED. Repeat the check.",
          String(device)))
    }
    return CMActionResult(
      succeeded: fsck.succeeded,
      message: fsck.succeeded
        ? L10n.tr("Image consistent.")
        : L10n.tr("Image INCONSISTENT: %@", String(fsck.stdout.suffix(500))))
  }

  /// `/dev/disk7s1` -> `/dev/disk7`.
  ///
  /// `fsck_apfs` gets the APFS partition, while `hdiutil info` - and therefore
  /// `devicesForImage()` - lists the PARENT device. Comparing them directly
  /// would never match, so the "did the device survive" check would silently
  /// answer "no" every time.
  static func parentDevice(of device: String) -> String {
    let prefix = "/dev/disk"
    guard device.hasPrefix(prefix) else { return device }
    let digits = device.dropFirst(prefix.count).prefix(while: \.isNumber)
    return digits.isEmpty ? device : prefix + digits
  }

  // MARK: - Restart readiness

  /// Whether the Mac can be safely shut down without `prepare-shutdown`.
  ///
  /// The risk when shutting down is not constant - it exists only when data
  /// not yet uploaded is waiting in the buffer. macOS gives agents a dozen or
  /// so seconds to quit, which with an empty queue is plenty, and with a full
  /// one not enough at all.
  ///
  /// Measured: the queue returns to zero within a few minutes after every
  /// hourly backup, so for most of the day a restart is simply safe. Instead of
  /// making the user remember a command before every restart, we tell them
  /// when it is really needed.
  public static func safeToRebootNow() async -> Bool {
    guard let stats = await DriveBufferService.queueStats() else {
      // Without a reading of the queue state we have no grounds to claim it is
      // safe - and for such a question silence must mean "no".
      return false
    }
    // `isQuiet`, NOT `isIdle`: an empty queue is not enough, because bands
    // abandoned by rclone (`erroredFiles`) drop out of the queue just like
    // uploaded ones. A restart in that state does not destroy anything extra,
    // but the answer "YES - queue empty" read as "the backup on Drive is
    // complete", and it was not - and the same sentence appeared in
    // `drive-status` next to `UploadState.failedFiles` with the label
    // "ACTION NEEDED".
    return stats.isQuiet
  }

  // MARK: - Retrying

  /// Retries `hdiutil` operations on a FUSE-T mount.
  ///
  /// FUSE-T mounts via NFS, and `hdiutil` on such a volume is sometimes
  /// rejected with "RPC version wrong". Measured: the error does not depend on
  /// the image size or the data (one run failed for 100 GB and 400 GB, and
  /// passed for 600, 1000 and 1500 GB), only on the moment - with an empty
  /// upload queue 5 of 5 attempts succeeded, with rclone busy it was random.
  /// When creating the production image, the first attempt failed and the
  /// second passed.
  private static func retryingFlakyMount(
    attempts: Int, _ operation: () async -> ProcessResult?
  ) async -> ProcessResult? {
    var last: ProcessResult?
    for attempt in 1...attempts {
      last = await operation()
      if last?.succeeded == true { return last }
      guard attempt < attempts else { break }
      CMLogger.log("hdiutil: attempt \(attempt) failed, retrying")
      try? await Task.sleep(nanoseconds: 5_000_000_000)
      await DriveBufferService.waitUntilIdle(timeout: 60)
    }
    return last
  }
}
