import ArgumentParser
import CloudMachineCore
import Foundation

/// Port of `scripts/setup-local-signing-cert.sh` - creates a one-off, local
/// self-signed certificate for signing `CloudMachine.app`, so that TCC
/// permissions (Full Disk Access etc.) SURVIVE later rebuilds of the app.
///
/// The default ad-hoc signature in `build-app` produces a NEW identity hash
/// (CDHash) on every rebuild, so macOS treats each rebuilt version as a
/// completely different app and revokes the permissions granted to it before.
/// This certificate is purely local: it is not sent anywhere, it is not
/// trusted by anyone but this Mac, and it is used ONLY for code signing. Run
/// it ONCE; every later `build-app` will use it automatically.
struct SetupSigningCert: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "setup-signing-cert",
    abstract:
      L10n.tr(
        "Creates a local self-signed certificate so that Full Disk Access survives later rebuilds of the app."
      )
  )

  func run() async throws {
    let certName =
      ProcessInfo.processInfo.environment["CM_SIGNING_CERT_NAME"] ?? "CloudMachine Local Signing"
    let keychain = FileManager.default.homeDirectoryForCurrentUser
      .appendingPathComponent("Library/Keychains/login.keychain-db")

    if let check = try? await ProcessRunner.run(
      "/usr/bin/security", ["find-certificate", "-c", certName, keychain.path]),
      check.succeeded
    {
      print(
        L10n.tr(
          "Certificate '%@' already exists in %@, nothing to do.", certName, keychain.path))
      return
    }

    let workDir = FileManager.default.temporaryDirectory
      .appendingPathComponent("cloudmachine-signing-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: workDir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: workDir) }

    let configFile = workDir.appendingPathComponent("codesign.cnf")
    let keyFile = workDir.appendingPathComponent("key.pem")
    let certFile = workDir.appendingPathComponent("cert.pem")
    let p12File = workDir.appendingPathComponent("cert.p12")

    let configContents = """
      [req]
      distinguished_name = req_distinguished_name
      x509_extensions = v3_req
      prompt = no
      [req_distinguished_name]
      CN = \(certName)
      [v3_req]
      keyUsage = critical, digitalSignature
      extendedKeyUsage = critical, codeSigning
      basicConstraints = critical, CA:false
      """
    try configContents.write(to: configFile, atomically: true, encoding: .utf8)

    print(L10n.tr("==> Generating the key and self-signed certificate '%@'...", certName))
    let reqStatus = try await InteractiveProcess.run(
      "/usr/bin/openssl",
      [
        "req", "-x509", "-newkey", "rsa:2048", "-keyout", keyFile.path, "-out", certFile.path,
        "-days", "3650", "-nodes", "-config", configFile.path, "-sha256",
      ])
    guard reqStatus == 0 else {
      print(L10n.tr("ERROR: openssl req exited with code %@.", "\(reqStatus)"))
      throw ExitCode.failure
    }

    // -legacy: OpenSSL 3.x encrypts PKCS12 by default with algorithms
    // (AES-256 + SHA-256 MAC) that the macOS Security framework (`security
    // import`) does not understand - without this flag the import fails with a
    // misleading "MAC verification failed (wrong password?)" despite a correct
    // password. -legacy goes back to 3DES/RC2, which macOS parses correctly.
    //
    // But `/usr/bin/openssl` on macOS is LibreSSL, which does NOT KNOW the
    // -legacy flag and fails with an error (checked on LibreSSL 3.3.6) - and it
    // already uses 3DES/RC2 by default. So we add the flag only for real
    // OpenSSL 3.
    let versionOutput =
      (try? await ProcessRunner.run("/usr/bin/openssl", ["version"]))?.stdout ?? ""
    let legacyFlag = versionOutput.hasPrefix("OpenSSL 3") ? ["-legacy"] : []
    let pkcs12Status = try await InteractiveProcess.run(
      "/usr/bin/openssl",
      ["pkcs12", "-export"] + legacyFlag + [
        "-out", p12File.path, "-inkey", keyFile.path,
        "-in", certFile.path, "-passout", "pass:cloudmachine-local",
      ])
    guard pkcs12Status == 0 else {
      print(L10n.tr("ERROR: openssl pkcs12 exited with code %@.", "\(pkcs12Status)"))
      throw ExitCode.failure
    }

    print(
      L10n.tr(
        "==> Importing the certificate into %@ (pre-authorizing /usr/bin/codesign, so it does not ask for the keychain password every time)...",
        keychain.path)
    )
    let importStatus = try await InteractiveProcess.run(
      "/usr/bin/security",
      [
        "import", p12File.path, "-k", keychain.path, "-P", "cloudmachine-local",
        "-T", "/usr/bin/codesign", "-T", "/usr/bin/security",
      ])
    guard importStatus == 0 else {
      print(L10n.tr("ERROR: security import exited with code %@.", "\(importStatus)"))
      throw ExitCode.failure
    }

    print(L10n.tr("==> Trusting the certificate ONLY for code signing..."))
    let trustStatus = try await InteractiveProcess.run(
      "/usr/bin/security",
      ["add-trusted-cert", "-r", "trustRoot", "-p", "codeSign", "-k", keychain.path, certFile.path])
    guard trustStatus == 0 else {
      print(L10n.tr("ERROR: security add-trusted-cert exited with code %@.", "\(trustStatus)"))
      throw ExitCode.failure
    }

    print("")
    print(L10n.tr("Done. Certificate '%@' is now available to codesign.", certName))
    print(
      L10n.tr(
        "The next 'cloudmachine-agent build-app' will use it automatically instead of an ad-hoc signature."
      ))
    print(
      L10n.tr(
        "After THAT ONE rebuild, grant Full Disk Access one last time - later\nrebuilds will no longer reset it, as long as you sign with the same certificate."
      ))
  }
}
