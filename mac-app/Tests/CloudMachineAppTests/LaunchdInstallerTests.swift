import XCTest

@testable import CloudMachineCore

/// Ustalenie 9: instalator agentow launchd meldowal sukces przy CZESCIOWEJ
/// porazce.
///
/// Wystarczyl jeden zaladowany agent, zeby `install()` zwrocilo
/// `succeeded: true` i komunikat "Zainstalowano agentow: ...", wymieniajacy
/// wylacznie te udane. Nieczytelny szablon szedl przez `continue`, nieudany
/// zapis przez `try?` - a po nieudanym zapisie `launchctl load` wczytywal STARY
/// plik `.plist` i konczyl sie kodem 0, czyli zaliczal sie jako sukces.
///
/// Skutek: `buffer-guard` sie nie ladowal, instalator meldowal sukces, jedyna
/// ochrona dysku nie dzialala i nikt o tym nie wiedzial. Brakujacej nazwy na
/// liscie nie zauwazy nikt, kto nie zna tej listy z pamieci.
///
/// Testy podstawiaja czytanie szablonu, zapis i przeladowanie: instalacja
/// PRAWDZIWA odpina obraz backupu i przeladowuje agentow tej maszyny, wiec nie
/// da sie jej odpalic w tescie bez rozbierania dzialajacego backupu.
final class LaunchdInstallerTests: XCTestCase {

  private let agentBin = URL(
    fileURLWithPath: "/Applications/CloudMachine.app/bin/cloudmachine-agent")
  private let logDir = URL(fileURLWithPath: "/Users/kto/Library/Logs/CloudMachine")
  private let docelowy = URL(fileURLWithPath: "/Users/kto/Library/LaunchAgents")

  private func szablony(_ nazwy: [String]) -> [URL] {
    nazwy.map { URL(fileURLWithPath: "/repo/launchd/\($0).plist.template") }
  }

  private struct ZlaProbka: Error {}

  // MARK: - Zbieranie porazek

  /// TA usterka, w calosci. Trzy agenty, jeden wchodzi, dwa padaja na dwa rozne
  /// sposoby (`launchctl` odmawia, szablon nieczytelny) - wynik MUSI byc
  /// porazka wymieniajaca to, czego NIE ma.
  func testJedenUdanyAgentToNieJestUdanaInstalacja() async {
    let wszystkie = szablony([
      "com.renacode.cloudmachine.app",
      "com.renacode.cloudmachine.buffer-guard",
      "com.renacode.cloudmachine.backup-health",
    ])

    let outcome = await LaunchdInstaller.installAgents(
      templates: wszystkie, into: docelowy, agentBin: agentBin, logDir: logDir,
      read: { url in
        // Zepsuty szablon backup-health: wczesniej `guard ... else { continue }`
        // wycinal go z instalacji BEZ SLADU.
        if url.lastPathComponent.contains("backup-health") { throw ZlaProbka() }
        return "__CM_AGENT_BIN__ __CM_LOG_DIR__"
      },
      write: { _, _ in },
      // buffer-guard sie nie laduje - dokladnie ten agent z opisu ustalenia.
      reload: { !$0.lastPathComponent.contains("buffer-guard") },
      log: { _ in })

    XCTAssertEqual(outcome.installed, ["com.renacode.cloudmachine.app"])
    XCTAssertEqual(
      outcome.failed.map(\.label).sorted(),
      ["com.renacode.cloudmachine.backup-health", "com.renacode.cloudmachine.buffer-guard"])

    let wynik = LaunchdInstaller.installVerdict(outcome)
    XCTAssertFalse(
      wynik.succeeded,
      "instalacja bez buffer-guard nie jest udana - dostalem: \(wynik.message)")
    XCTAssertTrue(
      wynik.message.contains("buffer-guard"),
      "komunikat musi NAZWAC agenta, ktorego brakuje: \(wynik.message)")
    XCTAssertTrue(
      wynik.message.contains("backup-health"),
      "i drugiego tez: \(wynik.message)")
    XCTAssertTrue(
      wynik.message.contains("launchctl load odmowil"),
      "i powiedziec, DLACZEGO nie wszedl: \(wynik.message)")
  }

  /// Nieudany zapis `.plist` NIE MOZE konczyc sie proba przeladowania.
  ///
  /// Wczesniej zapis szedl przez `try?`, wiec po jego porazce lecialo
  /// `launchctl load` na pliku, ktory nadal lezy w `~/Library/LaunchAgents` ze
  /// STAREJ instalacji. `launchctl` konczyl sie wtedy kodem 0 i agent trafial
  /// na liste "zainstalowanych", choc launchd chodzil na poprzedniej wersji -
  /// byc moze wskazujacej na binarke, ktorej juz nie ma.
  func testNieudanyZapisNieProbujePrzeladowac() async {
    let przeladowania = Licznik()

    let outcome = await LaunchdInstaller.installAgents(
      templates: szablony(["com.renacode.cloudmachine.buffer-guard"]),
      into: docelowy, agentBin: agentBin, logDir: logDir,
      read: { _ in "__CM_AGENT_BIN__" },
      write: { _, _ in throw ZlaProbka() },
      reload: { _ in
        przeladowania.zwieksz()
        // Tak zachowywal sie launchctl na starym pliku: kod 0, czyli "sukces".
        return true
      },
      log: { _ in })

    XCTAssertEqual(
      przeladowania.ile, 0,
      "po nieudanym zapisie launchctl load wczytalby STARY .plist i zaliczyl sie jako sukces")
    XCTAssertTrue(outcome.installed.isEmpty)
    XCTAssertEqual(outcome.failed.count, 1, "nieudany zapis musi zostac ZAPISANY jako porazka")
    XCTAssertTrue(
      outcome.failed.first?.reason.contains("nie udalo sie zapisac") == true,
      "powod: \(outcome.failed.first?.reason ?? "(brak - porazki nikt nie zapisal)")")
    XCTAssertFalse(LaunchdInstaller.installVerdict(outcome).succeeded)
  }

  /// Komplet agentow - i tylko komplet - jest sukcesem. Bez tego testu
  /// "naprawa" zwracajaca `succeeded: false` zawsze przeszlaby niezauwazona,
  /// a instalacja, ktora nigdy nie melduje sukcesu, jest tak samo bezuzyteczna
  /// jak ta, ktora melduje go zawsze.
  func testKompletAgentowToNadalSukces() async {
    let outcome = await LaunchdInstaller.installAgents(
      templates: szablony([
        "com.renacode.cloudmachine.app", "com.renacode.cloudmachine.buffer-guard",
      ]),
      into: docelowy, agentBin: agentBin, logDir: logDir,
      read: { _ in "__CM_AGENT_BIN__ __CM_LOG_DIR__" },
      write: { _, _ in }, reload: { _ in true }, log: { _ in })

    XCTAssertTrue(outcome.failed.isEmpty)
    let wynik = LaunchdInstaller.installVerdict(outcome)
    XCTAssertTrue(wynik.succeeded, wynik.message)
    XCTAssertEqual(
      wynik.message,
      "Zainstalowano agentow: com.renacode.cloudmachine.app, com.renacode.cloudmachine.buffer-guard"
    )
  }

  /// Brak szablonow to nadal porazka - inaczej instalacja, ktora nie zrobila
  /// NIC, meldowalaby sukces z pusta lista.
  func testBrakSzablonowToPorazka() {
    XCTAssertFalse(LaunchdInstaller.installVerdict(LaunchdInstaller.InstallOutcome()).succeeded)
  }

  // MARK: - Podstawianie sciezek

  /// Szablon musi dostac sciezki, po ktore sie zglasza - inaczej agent
  /// wystartowalby z literalem `__CM_AGENT_BIN__` jako programem.
  func testSciezkiTrafiajaDoZapisanegoPliku() async {
    let zapisane = Przechwycone()

    _ = await LaunchdInstaller.installAgents(
      templates: szablony(["com.renacode.cloudmachine.app"]),
      into: docelowy, agentBin: agentBin, logDir: logDir,
      read: { _ in "<string>__CM_AGENT_BIN__</string><string>__CM_LOG_DIR__</string>" },
      write: { tresc, url in zapisane.dodaj(tresc, url) },
      reload: { _ in true }, log: { _ in })

    XCTAssertEqual(
      zapisane.tresci,
      ["<string>\(agentBin.path)</string><string>\(logDir.path)</string>"])
    XCTAssertEqual(
      zapisane.sciezki,
      [docelowy.appendingPathComponent("com.renacode.cloudmachine.app.plist").path])
  }

  /// Pliki, ktore nie sa szablonami, nie moga trafic do instalacji - katalog
  /// `launchd/` bywa listowany w calosci (README, `.DS_Store`).
  func testNieSzablonyZostajaPominiete() async {
    let outcome = await LaunchdInstaller.installAgents(
      templates: [
        URL(fileURLWithPath: "/repo/launchd/README.md"),
        URL(fileURLWithPath: "/repo/launchd/com.renacode.cloudmachine.app.plist.template"),
      ],
      into: docelowy, agentBin: agentBin, logDir: logDir,
      read: { _ in "x" }, write: { _, _ in }, reload: { _ in true }, log: { _ in })

    XCTAssertEqual(outcome.installed, ["com.renacode.cloudmachine.app"])
    XCTAssertTrue(outcome.failed.isEmpty, "README nie jest nieudanym agentem")
  }

  // MARK: - Pomocnicze

  /// Klasy, bo podstawiane domkniecia sa `@Sendable`.
  private final class Licznik: @unchecked Sendable {
    private let lock = NSLock()
    private var licznik = 0
    func zwieksz() {
      lock.lock()
      licznik += 1
      lock.unlock()
    }
    var ile: Int {
      lock.lock()
      defer { lock.unlock() }
      return licznik
    }
  }

  private final class Przechwycone: @unchecked Sendable {
    private let lock = NSLock()
    private var zebrane: [(String, String)] = []
    func dodaj(_ tresc: String, _ url: URL) {
      lock.lock()
      zebrane.append((tresc, url.path))
      lock.unlock()
    }
    var tresci: [String] {
      lock.lock()
      defer { lock.unlock() }
      return zebrane.map(\.0)
    }
    var sciezki: [String] {
      lock.lock()
      defer { lock.unlock() }
      return zebrane.map(\.1)
    }
  }
}
