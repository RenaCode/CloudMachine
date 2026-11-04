import ArgumentParser
import CloudMachineCore
import Foundation

// Client-side encryption of the bands on Google Drive - see DriveEncryption.

struct VMEncrypt: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "vm-encrypt",
    abstract: L10n.tr(
      "Moves the backup on Google Drive under rclone encryption: setup, copy, switch, then delete-plain."
    ),
    subcommands: [
      VMEncryptStatus.self, VMEncryptSetup.self, VMEncryptCopy.self, VMEncryptSwitch.self,
      VMEncryptRollback.self, VMEncryptDeletePlain.self,
    ],
    defaultSubcommand: VMEncryptStatus.self)
}

private func finish(_ outcome: DriveEncryption.Outcome) throws {
  print(outcome.message)
  if !outcome.succeeded { throw ExitCode.failure }
}

struct VMEncryptStatus: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "status", abstract: L10n.tr("Shows which folder the machine uses and the copy."))

  func run() async throws {
    for line in await DriveEncryption.status() { print(line) }
  }
}

struct VMEncryptSetup: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "setup",
    abstract: L10n.tr(
      "Adds the encrypted remote on the Mac and in the machine (asks for the password). Moves no data."
    ))

  func run() async throws {
    // getpass reads from the terminal without echo; never an argument (ps).
    guard let first = getpass(L10n.tr("Encryption password: ")).map({ String(cString: $0) }),
      let second = getpass(L10n.tr("Again: ")).map({ String(cString: $0) })
    else { throw ExitCode.failure }
    guard first == second else {
      print(L10n.tr("The passwords differ - nothing was changed."))
      throw ExitCode.failure
    }
    try finish(await DriveEncryption.setup(password: first))
  }
}

struct VMEncryptCopy: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "copy",
    abstract: L10n.tr(
      "Copies the plain backup into the encrypted folder, in the background; backups go on."))

  func run() async throws { try finish(await DriveEncryption.copy()) }
}

struct VMEncryptSwitch: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "switch",
    abstract: L10n.tr(
      "With Time Machine stopped: last sync, cryptcheck, then the machine uses the encrypted folder. The plain one stays."
    ))

  func run() async throws { try finish(await DriveEncryption.move(.encrypt)) }
}

struct VMEncryptRollback: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "rollback",
    abstract: L10n.tr(
      "The switch the other way: decrypts what changed back into the plain folder and uses it again."
    ))

  func run() async throws { try finish(await DriveEncryption.move(.decrypt)) }
}

struct VMEncryptDeletePlain: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "delete-plain",
    abstract: L10n.tr(
      "Moves the plain folder to Google Drive's bin - only after a backup has finished into the encrypted one."
    ))

  @Flag(
    name: .long,
    help: ArgumentHelp(
      L10n.tr("The encryption password and salt are kept outside this Mac.")))
  var secretsSavedElsewhere = false

  @Flag(
    name: .long,
    help: ArgumentHelp(L10n.tr("A file was restored from the encrypted backup.")))
  var restoreChecked = false

  func run() async throws {
    try finish(
      await DriveEncryption.deletePlain(
        secretsSavedElsewhere: secretsSavedElsewhere, restoreChecked: restoreChecked))
  }
}
