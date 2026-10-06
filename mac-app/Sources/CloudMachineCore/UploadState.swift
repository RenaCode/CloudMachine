import Foundation

/// The answer to the only question the user really asks: is the backup
/// reaching Google Drive, and if not - why, and do I have to do something.
///
/// Reason to exist: until now the interface showed counters (queue, errors,
/// buffer size) and the raw log. The answer can be read from both, but you have
/// to know what to look for - and during the jam of 12 September 2026 nobody
/// read it. Numbers describe the state, they do not explain it.
///
/// The distinction that matters most here: **the daily limit passes by itself,
/// lack of space does not**. One means "wait", the other "do something". They
/// look alike in every counter and differ in everything that follows from them.
public enum UploadState: Equatable, Sendable {

  /// No connection to Drive - backups are only written locally.
  case mountDown
  /// Drive is full. It will NOT pass by itself.
  case driveFull
  /// rclone gave up on these files. They exist only on this Mac.
  case failedFiles(Int)
  /// Buffer clogged with nothing but unsent data.
  case bufferFull
  /// Google's daily write limit is exhausted. It passes BY ITSELF.
  case dailyQuotaExhausted
  /// Upload is moving.
  case flowing(queued: Int)
  /// Nothing waiting - everything is on Drive.
  case upToDate
  /// The queue could not be read - the upload state is UNKNOWN.
  ///
  /// A third state next to "good" and "bad", and it must exist on its own.
  /// Previously no answer from `rclone rc` ended with zeros substituted, which
  /// gave `.upToDate`: with 386 bands in the queue the interface said
  /// "Everything uploaded to Google Drive". False calm is worse than no answer,
  /// because it silences the monitor exactly when nobody knows what is going on.
  case queueUnknown

  /// Whether the state needs a person to react. `false` means "it will sort
  /// itself out", not "all good" - see `dailyQuotaExhausted`.
  public var needsAttention: Bool {
    switch self {
    case .mountDown, .driveFull, .failedFiles, .bufferFull: return true
    // An unknown state does NOT call for a person: a single timeout happens
    // when rclone is under load and passes by itself. When it does not pass,
    // `backup-health` raises the alarm - persistence is its job, not the
    // card's colour.
    case .dailyQuotaExhausted, .flowing, .upToDate, .queueUnknown: return false
    }
  }

  /// Whether the state is NOMINAL.
  ///
  /// Different from `needsAttention`, on purpose: with the daily limit
  /// exhausted nobody has to do anything, but the bands then sit only on this
  /// Mac - and the menu bar has no business glowing green then. The September
  /// audit started exactly from "Ready" being shown for bands that never made
  /// it to Drive.
  public var isNominal: Bool {
    switch self {
    case .flowing, .upToDate: return true
    case .mountDown, .driveFull, .failedFiles, .bufferFull, .dailyQuotaExhausted, .queueUnknown:
      return false
    }
  }

  /// Whether the backup is actually reaching Drive right now.
  public var isMovingData: Bool {
    if case .flowing = self { return true }
    return false
  }

  /// Label above the card heading: what the user should do about it.
  ///
  /// Previously the interface built it from two bools (`needsAttention`,
  /// `isNominal`), so it could express only three variants and every new state
  /// had to squeeze into one of them. `queueUnknown` fits none: it is not a
  /// failure, it is not fine, and it is not "passes by itself" either, because
  /// nobody knows whether there is anything to wait out.
  public var badge: String {
    switch self {
    case .mountDown, .driveFull, .failedFiles, .bufferFull: return L10n.tr("ACTION NEEDED")
    case .dailyQuotaExhausted: return L10n.tr("WILL PASS BY ITSELF — DO NOTHING")
    case .queueUnknown: return L10n.tr("UNKNOWN — CHECK AGAIN SHORTLY")
    case .flowing, .upToDate: return L10n.tr("ALL GOOD")
    }
  }

  /// One sentence for the menu bar and the card heading.
  public var headline: String {
    switch self {
    case .mountDown: return L10n.tr("Upload is not working")
    case .driveFull: return L10n.tr("Upload stopped — no space left on Google Drive")
    case .failedFiles(let count): return L10n.tr("%@ backup fragments not uploaded", "\(count)")
    case .bufferFull: return L10n.tr("Upload cannot keep up with writes")
    case .dailyQuotaExhausted: return L10n.tr("Upload paused — Google daily limit")
    case .flowing(let queued): return L10n.tr("Uploading to Google Drive — %@ queued", "\(queued)")
    case .upToDate: return L10n.tr("Everything uploaded to Google Drive")
    case .queueUnknown: return L10n.tr("Unknown what is waiting in the queue")
    }
  }

  /// What it means and what to do about it. Written for reading, not for
  /// diagnosis - whoever needs numbers has `cloudmachine-agent drive-status`.
  public var explanation: String {
    switch self {
    case .mountDown:
      return L10n.tr(
        "There is no connection to Google Drive, so backups are only made on this Mac. If this does not pass by itself within a few minutes, check the network and the connection to Drive."
      )
    case .driveFull:
      return L10n.tr(
        "There is no space left on Google Drive. This will NOT pass by itself — you need to free up space on Drive. Until then Time Machine is paused, so that it does not fill up this Mac's disk."
      )
    case .failedFiles(let count):
      return L10n.tr(
        "%@ backup fragments could not be uploaded and rclone stopped trying. These fragments exist only on this Mac, so the backup on Drive is incomplete. This needs checking.",
        "\(count)")
    case .bufferFull:
      return L10n.tr(
        "Time Machine is writing faster than the upload goes, and the buffer has filled up. The backup will be paused until the upload catches up — this is a safeguard against filling up the disk, not a failure."
      )
    case .dailyQuotaExhausted:
      return L10n.tr(
        "Google accepts 750 GB per day and that limit has been used up. There is nothing to do: the limit renews by itself, usually within a few hours. Time Machine backups are made normally in the meantime and wait in the buffer — they will be uploaded as soon as Google starts accepting again."
      )
    case .flowing(let queued):
      return L10n.tr("%@ backup fragments are queued and on their way to Drive.", "\(queued)")
    case .upToDate:
      return L10n.tr("Nothing is waiting in the queue — the backup on Google Drive is complete.")
    case .queueUnknown:
      return L10n.tr(
        "rclone did not answer the question about the queue, so it is unknown how many backups are still waiting to be uploaded. This does not mean something broke — under load the answer can be late. It only means that right now nobody knows. If it persists, the backup cycle check will report it."
      )
    }
  }

  /// Builds the state from individual facts.
  ///
  /// The order is NOT arbitrary - from the hardest fact to the softest.
  /// `failedFiles` comes before the daily limit, because "rclone gave up" means
  /// the backup is incomplete NOW, while the limit only means it will wait.
  /// `queueKnown` has NO default value, and that is deliberate. All counters
  /// below come from `vfs/stats`; when rclone does not answer, the caller has
  /// only zeros at hand and none of them means "zero". The required argument
  /// forces every place in the code to answer the question that used to be
  /// skipped - that is where the "Everything uploaded" screen with a full queue
  /// came from.
  public static func from(
    mounted: Bool,
    queueKnown: Bool,
    queued: Int,
    inProgress: Int,
    failedFiles: Int,
    bufferOutOfSpace: Bool,
    driveFull: Bool,
    dailyQuotaExhausted: Bool
  ) -> UploadState {
    if !mounted { return .mountDown }
    if driveFull { return .driveFull }
    // Before every state computed from counters, because without reading the
    // queue "nothing is waiting" cannot be told from "I do not know what is
    // waiting". The daily limit is lost here too, and rightly so: when it is
    // unknown whether rclone has abandoned something, "wait, it will pass" is
    // not an honest answer.
    if !queueKnown { return .queueUnknown }
    if failedFiles > 0 { return .failedFiles(failedFiles) }
    if bufferOutOfSpace { return .bufferFull }
    if dailyQuotaExhausted { return .dailyQuotaExhausted }
    if queued > 0 || inProgress > 0 { return .flowing(queued: queued + inProgress) }
    return .upToDate
  }
}
