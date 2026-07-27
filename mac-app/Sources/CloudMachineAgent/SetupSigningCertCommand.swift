import ArgumentParser
import CloudMachineCore
import Foundation

/// Port `scripts/setup-local-signing-cert.sh` - tworzy jednorazowy, lokalny
/// certyfikat self-signed do podpisywania `CloudMachine.app`, zeby uprawnienia
/// TCC (Pelny dostep do dysku itp.) PRZETRWALY kolejne przebudowy appki.
///
/// Domyslny podpis ad-hoc w `build-app` generuje NOWY hash tozsamosci (CDHash)
/// przy kazdym rebuildzie, wiec macOS traktuje kazda przebudowana wersje jak
/// zupelnie inna appke i cofa jej wczesniej przyznane uprawnienia. Ten
/// certyfikat jest czysto lokalny: nie jest nigdzie wysylany, nie jest
/// zaufany przez nikogo poza tym Makiem, i sluzy WYLACZNIE do podpisywania
/// kodu. Uruchom RAZ; kazde kolejne `build-app` uzyje go automatycznie.
struct SetupSigningCert: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "setup-signing-cert",
    abstract:
      "Tworzy lokalny certyfikat self-signed, zeby Full Disk Access przetrwalo kolejne przebudowy appki."
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
      print("Certyfikat '\(certName)' juz istnieje w \(keychain.path), nic nie robie.")
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

    print("==> Generuje klucz i certyfikat self-signed '\(certName)'...")
    let reqStatus = try await InteractiveProcess.run(
      "/usr/bin/openssl",
      [
        "req", "-x509", "-newkey", "rsa:2048", "-keyout", keyFile.path, "-out", certFile.path,
        "-days", "3650", "-nodes", "-config", configFile.path, "-sha256",
      ])
    guard reqStatus == 0 else {
      print("BLAD: openssl req zakonczyl sie kodem \(reqStatus).")
      throw ExitCode.failure
    }

    // -legacy: OpenSSL 3.x domyslnie szyfruje PKCS12 algorytmami (AES-256+
    // SHA-256 MAC), ktorych macOS'owy Security framework (`security import`)
    // nie rozumie - bez tej flagi import konczy sie mylacym "MAC
    // verification failed (wrong password?)" mimo poprawnego hasla. -legacy
    // wraca do 3DES/RC2, ktore macOS poprawnie parsuje.
    let pkcs12Status = try await InteractiveProcess.run(
      "/usr/bin/openssl",
      [
        "pkcs12", "-export", "-legacy", "-out", p12File.path, "-inkey", keyFile.path,
        "-in", certFile.path, "-passout", "pass:cloudmachine-local",
      ])
    guard pkcs12Status == 0 else {
      print("BLAD: openssl pkcs12 zakonczyl sie kodem \(pkcs12Status).")
      throw ExitCode.failure
    }

    print(
      "==> Importuje certyfikat do \(keychain.path) (z gory autoryzuje /usr/bin/codesign, bez pytania o haslo keychaina za kazdym razem)..."
    )
    let importStatus = try await InteractiveProcess.run(
      "/usr/bin/security",
      [
        "import", p12File.path, "-k", keychain.path, "-P", "cloudmachine-local",
        "-T", "/usr/bin/codesign", "-T", "/usr/bin/security",
      ])
    guard importStatus == 0 else {
      print("BLAD: security import zakonczyl sie kodem \(importStatus).")
      throw ExitCode.failure
    }

    print("==> Ufam certyfikatowi WYLACZNIE do podpisywania kodu (code signing)...")
    let trustStatus = try await InteractiveProcess.run(
      "/usr/bin/security",
      ["add-trusted-cert", "-r", "trustRoot", "-p", "codeSign", "-k", keychain.path, certFile.path])
    guard trustStatus == 0 else {
      print("BLAD: security add-trusted-cert zakonczyl sie kodem \(trustStatus).")
      throw ExitCode.failure
    }

    print(
      """

      Gotowe. Certyfikat '\(certName)' jest teraz dostepny dla codesign.
      Nastepne 'cloudmachine-agent build-app' uzyje go automatycznie zamiast podpisu ad-hoc.
      Po TYM JEDNYM rebuildzie przyznaj Pelny dostep do dysku ostatni raz - kolejne
      przebudowy juz go nie zresetuja, dopoki podpisujesz tym samym certyfikatem.
      """)
  }
}
