import Foundation

// The words for the two share probes, shared by `backup-health`, `vm-status`
// and the panel, so the three never describe the same state differently.

extension ShareReadProbe.Verdict {
  /// One sentence for a state that is not fine; `nil` for a confirmed one.
  public var problemSummary: String? {
    switch self {
    case .readable, .noImage: return nil
    case .dead, .failed: return L10n.tr("The machine's share cannot be read")
    case .noAnswer: return L10n.tr("Unknown whether the machine's share can be read")
    }
  }

  /// Red (needs a person) or amber (unknown) in the panel.
  public var isFailure: Bool {
    switch self {
    case .dead, .failed: return true
    case .readable, .noImage, .noAnswer: return false
    }
  }
}

extension SMBProbe.Verdict {
  public var problemSummary: String? {
    switch self {
    case .answers: return nil
    case .refused, .notSMB: return L10n.tr("Samba in the machine does not answer this Mac")
    case .noAnswer, .noAddress, .unreachable:
      return L10n.tr("Unknown whether Samba in the machine answers this Mac")
    }
  }

  public var isFailure: Bool {
    switch self {
    case .refused, .notSMB: return true
    case .answers, .noAnswer, .noAddress, .unreachable: return false
    }
  }
}

extension BackupHealth {
  /// The probes' problems. Pure; `nil` = not asked.
  static func shareProblems(
    read: ShareReadProbe.Verdict?, smb: SMBProbe.Verdict?, address: String?
  ) -> (problems: [Problem], notReadyYet: [Problem]) {
    var problems: [Problem] = []
    var notReadyYet: [Problem] = []
    let band = "\(VMLayout.Guest.localRoot)/<image>/bands/0"

    switch read {
    case .dead(let reason)?, .failed(let reason)?:
      problems.append(
        Problem(
          summary: L10n.tr("The machine's share cannot be read"),
          detail: L10n.tr(
            "Reading 1 byte of %@ in the machine failed: %@. Every service says it is active, yet Time Machine cannot use the image there. Nothing restarts it by itself. Check: cloudmachine-agent vm-status, then in the machine: journalctl -u punchfs -u tm-bands-bind -u rclone-tm",
            band, reason),
          code: "share-unreadable"))
    case .noAnswer(let hung)?:
      problems.append(
        Problem(
          summary: L10n.tr("Unknown whether the machine's share can be read"),
          detail: L10n.tr(
            "Reading 1 byte of %@ in the machine has not returned for %@ s. That is how a hung punchfs or rclone mount behaves. Nothing is restarted while the state is unknown - a restart under a write still going could lose it. Check in the machine: journalctl -u punchfs -u rclone-tm",
            band, hung.map { "\($0)" } ?? "?"),
          code: "share-read-no-answer"))
    case .readable?, .noImage?, nil:
      break
    }

    let where445 = "\(address ?? "?"):445"
    switch smb {
    case .refused(let reason)?:
      notReadyYet.append(smbRefused(where445, reason))
    case .notSMB?:
      notReadyYet.append(smbRefused(where445, "not SMB2"))
    case .noAnswer(let seconds)?:
      problems.append(
        Problem(
          summary: L10n.tr("Unknown whether Samba in the machine answers this Mac"),
          detail: L10n.tr(
            "An SMB connection to %@ got no answer within %@ s. Time Machine reaches the machine at this address. Check the machine's network and smbd: cloudmachine-agent vm-status",
            where445, "\(seconds)"),
          code: "smb-no-answer"))
    case .unreachable(let reason)?:
      problems.append(
        Problem(
          summary: L10n.tr("Unknown whether Samba in the machine answers this Mac"),
          detail: L10n.tr(
            "This Mac found no route to %@ (%@). Either the route to the machine is gone, or macOS Local Network privacy has not allowed CloudMachine - then allow it in System Settings > Privacy & Security > Local Network. Check: cloudmachine-agent vm-status",
            where445, reason),
          code: "smb-unreachable"))
    case .noAddress?:
      problems.append(
        Problem(
          summary: L10n.tr("Unknown whether Samba in the machine answers this Mac"),
          detail: L10n.tr(
            "The machine did not report its address, so nobody could try an SMB connection. Check: cloudmachine-agent vm-status"
          ),
          code: "smb-no-address"))
    case .answers?, nil:
      break
    }
    return (problems, notReadyYet)
  }

  private static func smbRefused(_ where445: String, _ reason: String) -> Problem {
    Problem(
      summary: L10n.tr("Samba in the machine does not answer this Mac"),
      detail: L10n.tr(
        "An SMB connection to %@ failed (%@). Time Machine reaches the machine at this address, so no backup is made. Check the machine's network and smbd: cloudmachine-agent vm-status",
        where445, reason),
      code: "smb-no-connection")
  }
}

extension VMStatus {
  /// The two `vm-status` lines for the probes. Pure.
  public static func shareLines(
    read: ShareReadProbe.Verdict, smb: SMBProbe.Verdict, address: String?
  ) -> (lines: [String], healthy: Bool) {
    let readText: String
    switch read {
    case .readable: readText = L10n.tr("readable")
    case .noImage: readText = L10n.tr("no image yet")
    case .dead(let reason), .failed(let reason):
      readText = "\(read.problemSummary ?? "") (\(reason))"
    case .noAnswer(let hung):
      readText = "\(read.problemSummary ?? "") (\(hung.map { "\($0) s" } ?? "?"))"
    }
    let smbText: String
    switch smb {
    case .answers: smbText = L10n.tr("answers")
    case .refused(let reason), .unreachable(let reason):
      smbText = "\(smb.problemSummary ?? "") (\(reason))"
    case .notSMB: smbText = "\(smb.problemSummary ?? "") (not SMB2)"
    case .noAnswer(let seconds): smbText = "\(smb.problemSummary ?? "") (\(seconds) s)"
    case .noAddress: smbText = smb.problemSummary ?? ""
    }
    return (
      [
        L10n.tr("Share read:       %@", readText),
        L10n.tr("Samba from Mac:   %@", "\(address ?? "?"):445 - \(smbText)"),
      ],
      read.isConfirmed && smb.answers
    )
  }
}
