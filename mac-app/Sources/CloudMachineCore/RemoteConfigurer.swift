import Foundation

/// Port `configure-remote.sh` (+ scalone z dawnym `CloudMachineController.
/// connectGoogleDrive()` w GUI) - laczy z Google Drive przez `rclone
/// authorize` (nieinteraktywny OAuth w przegladarce), zamiast starszego,
/// interaktywnego kreatora `rclone config`. CLI i GUI uzywaja teraz
/// DOKLADNIE tej samej sciezki logowania.
public enum RemoteConfigurer {
  /// Czy remote istnieje w konfiguracji rclone.
  ///
  /// Pyta binarke zarzadzana przez CloudMachine, nie te z Homebrew. Obie czytaja
  /// ten sam plik konfiguracyjny, ale reszta systemu chodzi na naszej - a stan
  /// pokazywany uzytkownikowi musi opisywac to, czego uzywamy naprawde, nie
  /// przypadkowa druga instalacje, ktorej moze kiedys nie byc.
  public static func isConfigured(remoteName: String) async -> Bool {
    guard let result = try? await CMTooling.runRclone(["listremotes"], timeout: 30) else {
      return false
    }
    return result.stdout.contains("\(remoteName):")
  }

  /// Usluga w Keychainie, pod ktora leza wlasne poswiadczenia OAuth.
  public static let keychainService = "cloudmachine-gdrive"

  /// Czyta `client_id` / `client_secret` z Keychaina.
  ///
  /// README opisywal to od dawna jako dzialajaca czesc `configure-remote`,
  /// a ANI JEDNA linia kodu tego nie robila - `rclone authorize drive` szlo
  /// na wspoldzielonym `client_id` rclone, tym samym, o ktorym README pisze,
  /// ze jest wycofywany i limitowany wspolnie ze wszystkimi uzytkownikami
  /// rclone. Dokumentacja opisywala zabezpieczenie, ktorego nie bylo.
  static func keychainSecret(account: String) async -> String? {
    guard
      let result = try? await ProcessRunner.run(
        "/usr/bin/security",
        ["find-generic-password", "-a", account, "-s", keychainService, "-w"],
        timeout: 30),
      result.succeeded
    else { return nil }
    let value = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
    return value.isEmpty ? nil : value
  }

  public static func extractToken(from output: String) -> String? {
    guard let startRange = output.range(of: "--->"),
      let endRange = output.range(of: "<---")
    else { return nil }
    let token = output[startRange.upperBound..<endRange.lowerBound]
    return token.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  /// Laczy z Google Drive i przygotowuje DOKLADNIE ten remote i folder, ktorych
  /// uzywa montowanie.
  ///
  /// Wczesniej nazwy brano z `machines.json` (`remote_name`, domyslnie
  /// `gdrive-cloudmachine`, plus folder z kluczem maszyny), a montowanie
  /// chodzi na stalych `DriveBufferService.remoteName` / `.remotePath`
  /// (`gdrive:CloudMachine/mac-studio`). Udokumentowana sciezka instalacji -
  /// `configure-remote`, potem `create-image` - konczyla sie wiec remote'em,
  /// ktorego nikt nigdy nie uzywa, i bledem "Drive nie jest zamontowany" przy
  /// nastepnym kroku. Dzialajaca instalacja na tej maszynie ma `[gdrive]`
  /// zlozony recznie; z samego repo nie dalo sie jej odtworzyc.
  ///
  /// `config` i `machineKey` zostaja w sygnaturze, bo GUI i CLI je maja, ale
  /// o nazwie remote'a decyduje odtad ta sama stala, ktora buduje polecenie
  /// montowania. Jedno zrodlo prawdy albo zaden.
  @discardableResult
  public static func connect(
    config: MachinesConfig, machineKey: String, replaceExisting: Bool = false
  ) async -> CMActionResult {
    let remoteName = DriveBufferService.remoteName
    let remotePath = "\(remoteName):\(DriveBufferService.remotePath)"

    // PRZERYWAMY, a nie ostrzegamy. `rclone config create` nadpisuje wpis
    // o tej samej nazwie bez pytania, a wraz z nim token, `client_id`
    // i `scope` dzialajacej instalacji. Nowe poswiadczenie z zakresem
    // `drive.file` widzi wylacznie pliki utworzone przez SIEBIE - istniejacy
    // obraz backupu, zalozony przez poprzednie poswiadczenie, staje sie
    // wtedy niewidoczny i montowanie przestaje go znajdowac. Kopia jest cala,
    // ale niedostepna, co w praktyce znaczy to samo.
    if !replaceExisting, await isConfigured(remoteName: remoteName) {
      return CMActionResult(
        succeeded: false,
        message: """
          Remote '\(remoteName)' juz istnieje i NIE zostal ruszony.
          Nadpisanie go podmienia token i zakres uprawnien; poswiadczenie \
          z zakresem 'drive.file' nie widzi plikow zalozonych przez poprzednie, \
          wiec istniejacy backup staje sie nieosiagalny.
          Jesli naprawde chcesz go zastapic, zrob najpierw kopie \
          ~/.config/rclone/rclone.conf i uruchom ponownie z --replace-existing.
          """)
    }

    // Wlasne poswiadczenia OAuth z Keychaina. Na wspoldzielonym `client_id`
    // rclone konkurujemy o limit tempa ze wszystkimi uzytkownikami rclone,
    // a sam ten `client_id` jest wycofywany w 2026.
    let clientID = await keychainSecret(account: "client_id")
    let clientSecret = await keychainSecret(account: "client_secret")
    // Do `authorize` podajemy je przez SRODOWISKO, nie przez argumenty:
    // wiersz polecenia kazdego procesu widzi na macOS kazdy uzytkownik przez
    // `ps`, a srodowisko - tylko wlasciciel procesu i root. `rclone authorize`
    // czeka na zatwierdzenie w przegladarce, wiec ten proces zyje minutami,
    // nie ulamkiem sekundy.
    var authEnv: [String: String] = [:]
    if let clientID, let clientSecret {
      authEnv["RCLONE_DRIVE_CLIENT_ID"] = clientID
      authEnv["RCLONE_DRIVE_CLIENT_SECRET"] = clientSecret
    } else {
      // NIE przerywamy - bez wlasnych kluczy polaczenie nadal dziala, tylko
      // gorzej. Ale mowimy o tym wprost, zamiast milczec: to byla dokladnie
      // ta roznica, ktora README opisywal jako zalatwiona, a ktorej nie bylo.
      CMLogger.log(
        "UWAGA: brak client_id/client_secret w Keychainie (usluga '\(keychainService)') - lacze na wspoldzielonym client_id rclone, ktory jest limitowany wspolnie i wycofywany w 2026. Patrz README."
      )
    }

    // `drive.file` ogranicza dostep do plikow, ktore ta aplikacja sama
    // utworzyla. Pelne `drive` - domyslne dla `rclone authorize drive`, i to,
    // co ma dzialajaca instalacja - daje odczyt, zmiane i KASOWANIE calej
    // zawartosci konta Google. To nieporownanie szersze uprawnienie, niz
    // potrzebuje katalog z pasmami jednego obrazu, tym bardziej ze montowanie
    // chodzi z `--drive-use-trash=false`, wiec kasowanie nie ma kosza, z
    // ktorego dalo by sie cokolwiek cofnac.
    //
    // Binarka: TA SAMA, ktorej uzywa reszta systemu (`~/.cloudmachine/bin/
    // rclone`), a nie `/usr/bin/env rclone`. Do 23.09.2026 `connect` szlo
    // przez `env`, czyli w rclone z Homebrew - podczas gdy `isConfigured`
    // w tym samym pliku i cale montowanie ida przez `CMTooling.runRclone`.
    // Konsekwencje byly dwie i obie ciche: bez Homebrew udokumentowana
    // sciezka instalacji (`install-rclone`, potem `configure-remote`) konczyla
    // sie kodem 127 i komunikatem bez przyczyny, a Z Homebrew konfiguracje
    // zapisywala INNA binarka niz ta, ktorej system potem uzywa.
    //
    // `authorize` woly przez `ProcessRunner.run` wprost na sciezce
    // zarzadzanej binarki, bo `CMTooling.runRclone` nie przyjmuje `env`,
    // a klucze OAuth MUSZA isc srodowiskiem (patrz komentarz wyzej) i
    // `CMTooling.swift` nie nalezy do zakresu tej poprawki.
    guard
      let authResult = try? await ProcessRunner.run(
        CMTooling.managedRclonePath.path,
        ["authorize", "drive", "--drive-scope", "drive.file"],
        env: authEnv, timeout: 300),
      authResult.succeeded
    else {
      return CMActionResult(
        succeeded: false,
        message:
          "rclone authorize nie powiodlo sie (\(CMTooling.managedRclonePath.path)). Jesli tej binarki nie ma, zacznij od: cloudmachine-agent install-rclone."
      )
    }
    guard let token = extractToken(from: authResult.stdout) else {
      return CMActionResult(
        succeeded: false, message: "Nie udalo sie odczytac tokenu z wyniku rclone authorize.")
    }
    // Tutaj klucze MUSZA przejsc argumentami - `config create` ma je zapisac
    // do `rclone.conf`, wiec srodowisko nic by nie dalo. Proces trwa ulamek
    // sekundy i jest jednorazowy, w odroznieniu od `authorize` powyzej.
    var createArgs = ["config", "create", remoteName, "drive", "scope=drive.file"]
    if let clientID, let clientSecret {
      createArgs += ["client_id=\(clientID)", "client_secret=\(clientSecret)"]
    }
    createArgs.append("token=\(token)")
    // Znowu ta sama binarka co montowanie: gdyby `config create` poszlo przez
    // Homebrew, zapisalby wpis w konfiguracji, ktorej moze nie czytac binarka
    // uzywana przez system - a wtedy `isConfigured` mowi "nie ma remote'a"
    // zaraz po udanym "polaczono".
    let createResult = try? await CMTooling.runRclone(createArgs, timeout: 60)
    guard createResult?.succeeded == true else {
      return CMActionResult(succeeded: false, message: "rclone config create nie powiodlo sie.")
    }
    let mkdirResult = try? await CMTooling.runRclone(["mkdir", remotePath], timeout: 120)
    guard mkdirResult?.succeeded == true else {
      // ZWRACAMY BLAD, nie "sukces": remote istnieje, ale bez tego folderu nie
      // mamy potwierdzenia, ze zapis na to konto faktycznie dziala - a kolejny
      // krok instalacji (`create-image`) zaklada, ze dziala.
      return CMActionResult(
        succeeded: false,
        message:
          "Polaczono z Google Drive, ale nie udalo sie utworzyc folderu '\(remotePath)' - bez niego montowanie nie ruszy. Sprawdz uprawnienia konta i sprobuj ponownie."
      )
    }
    return CMActionResult(
      succeeded: true,
      message: "Polaczono z Google Drive jako remote '\(remoteName)', folder \(remotePath).")
  }
}
