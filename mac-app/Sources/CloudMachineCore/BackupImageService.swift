import Foundation

/// Obraz backupu lezacy na Google Drive - port `gdrive/create-image.sh`,
/// `attach-image.sh` i `verify-image.sh`.
///
/// Time Machine dostaje do reki podpiety, zwykly wolumen APFS i nie wie, ze
/// pasma obrazu leza w chmurze. Dzieki temu w sciezce zapisu nie ma sieciowego
/// systemu plikow - odpada SMB i cala klasa awarii, ktore trapia backupy
/// sieciowe.
public enum BackupImageService {

  // MARK: - Sciezki

  public static let imageName = "mac-studio"
  public static let volumeName = "CloudMachine"

  public static var imagePath: URL {
    DriveBufferService.mountPoint.appendingPathComponent("\(imageName).sparsebundle")
  }

  /// Punkt montowania celu.
  ///
  /// `/Volumes` jest sciezka, ktora Time Machine na pewno przyjmuje - i to jest
  /// jedyny powod, dla ktorego tu siedzi. Cena: po nieczystym odpieciu katalog
  /// `/Volumes/<nazwa>` zostaje jako osierocony i blokuje ponowne podpiecie.
  /// Nalezy do uzytkownika, ale lezy w `/Volumes` nalezacym do roota, wiec
  /// `rmdir` odmawia - agent dzialajacy jako uzytkownik nie posprzata po sobie
  /// sam. Alternatywa (katalog w calosci nasz, samonaprawialny) jest
  /// nieprzetestowana: nie wiadomo, czy `tmutil setdestination` przyjmie cel
  /// spoza `/Volumes`.
  public static var targetPath: URL {
    URL(fileURLWithPath: "/Volumes/\(volumeName)")
  }

  /// 32 MB na pasmo, w sektorach po 512 B. Wybrane pomiarem - patrz
  /// `gdrive/poc-amplification.sh` i tabela w `gdrive/README.md`.
  ///
  /// Dwie sily ciagna w przeciwne strony. Google Drive przepuszcza okolo dwoch
  /// operacji na plik na sekunde, wiec male pasma wydluzaja pierwsza wysylke.
  /// Ale kazda zmiana brudzi cale pasmo, wiec duze pasma mnoza transfer przy
  /// kazdym przyroscie - zmierzone 768 MB przy 64 MB wobec 384 MB przy 8 MB na
  /// te same 300 MB realnej zmiany. 32 MB to punkt, w ktorym pierwsza wysylka
  /// przestaje byc ograniczona tempem operacji, a zaczyna pasmem lacza.
  ///
  /// Dziala tylko przy tworzeniu obrazu - pozniej wymaga backupu od zera.
  public static let bandSectors = 65536

  private static let fsckPath =
    "/System/Library/Filesystems/apfs.fs/Contents/Resources/fsck_apfs"

  // MARK: - Stan

  public static var exists: Bool {
    var isDir: ObjCBool = false
    let ok = FileManager.default.fileExists(atPath: imagePath.path, isDirectory: &isDir)
    return ok && isDir.boolValue
  }

  public static var isAttached: Bool {
    guard let out = try? mountTable() else { return false }
    return out.contains(" on \(targetPath.path) ")
  }

  private static func mountTable() throws -> String {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/sbin/mount")
    let pipe = Pipe()
    process.standardOutput = pipe
    try process.run()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()
    return String(data: data, encoding: .utf8) ?? ""
  }

  // MARK: - Zawieszone urzadzenia

  /// Urzadzenia `/dev/diskN` podpiete pod wskazany obraz.
  ///
  /// Po wymuszonym odpieciu urzadzenie potrafi zostac w systemie jako zombie.
  /// Ponowne podpiecie konczy sie wtedy bledem "no mountable file systems",
  /// albo - gorzej - zwraca martwy uchwyt, na ktorym `fsck_apfs` melduje
  /// "failed to read container superblock" z UUID z samych zer. Wyglada to jak
  /// skasowany backup, a jest tylko nieczytelnym urzadzeniem: wczesniejsza
  /// wersja testu wyrywania podlogi trzy razy z rzedu orzekla na tej podstawie
  /// utrate danych, ktore byly cale.
  public static func devicesForImage(_ image: URL = imagePath) async -> [String] {
    guard let result = try? await ProcessRunner.run("/usr/bin/hdiutil", ["info"], timeout: 60),
      result.succeeded
    else { return [] }
    return parseDevices(hdiutilInfo: result.stdout, imagePath: image.path)
  }

  /// Czysta wersja parsera - `hdiutil info` grupuje wpisy w bloki, gdzie po
  /// linii `image-path` naleza wszystkie kolejne linie `/dev/diskN`.
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
      // Interesuje nas urzadzenie nadrzedne (/dev/disk7), nie partycja
      // (/dev/disk7s1) - odpiecie nadrzednego zabiera ze soba partycje.
      //
      // UWAGA: kuszace `!device.contains("s")` jest BLEDNE, bo "disk" tez
      // zawiera "s" i odrzuca wszystko. Sprawdzamy, czy po prefiksie zostaly
      // same cyfry.
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

  // MARK: - Tworzenie

  /// Tworzy obraz NA MIEJSCU, na zamontowanym Drive.
  ///
  /// Utworzenie go lokalnie i przeniesienie daje obraz, ktorego `hdiutil`
  /// pozniej nie otwiera ("CBSDBackingStore::newProbe stat() failed"), mimo ze
  /// wszystkie pliki i pasma sa na swoim miejscu i daja sie czytac.
  public static func create(sizeGB: Int) async -> CMActionResult {
    guard DriveBufferService.isMounted else {
      return CMActionResult(
        succeeded: false, message: "Drive nie jest zamontowany - najpierw uruchom bufor.")
    }
    guard !exists else {
      return CMActionResult(
        succeeded: false,
        message: "Obraz juz istnieje. Usuniecie go kasuje caly backup - zrob to swiadomie.")
    }

    await DriveBufferService.waitUntilQuiet(timeout: 180)

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
        message: "Nie udalo sie utworzyc obrazu: \(result?.stderr ?? "nieznany blad")")
    }
    return CMActionResult(
      succeeded: true,
      message: "Utworzono obraz \(sizeGB) GB, pasmo \(bandSectors * 512 / 1024 / 1024) MB.")
  }

  // MARK: - Podpinanie

  public static func attach() async -> CMActionResult {
    guard DriveBufferService.isMounted else {
      return CMActionResult(succeeded: false, message: "Drive nie jest zamontowany.")
    }
    guard exists else {
      return CMActionResult(succeeded: false, message: "Brak obrazu - najpierw go utworz.")
    }
    if isAttached {
      return CMActionResult(succeeded: true, message: "Juz podpiete: \(targetPath.path)")
    }

    await purgeStaleDevices()

    // Osierocony punkt montowania blokuje podpiecie. Jesli lezy w /Volumes,
    // usuniecie wymaga roota - mowimy wiec dokladnie, co uruchomic, zamiast
    // ponawiac bez konca.
    if FileManager.default.fileExists(atPath: targetPath.path) {
      do {
        try FileManager.default.removeItem(at: targetPath)
      } catch {
        return CMActionResult(
          succeeded: false,
          message: """
            Osierocony punkt montowania blokuje podpiecie: \(targetPath.path)
            Usun go i sprobuj ponownie:  sudo rmdir '\(targetPath.path)'
            """)
      }
    }

    await DriveBufferService.waitUntilQuiet(timeout: 120)

    let result = await retryingFlakyMount(attempts: 5) {
      try? await ProcessRunner.run(
        "/usr/bin/hdiutil",
        ["attach", imagePath.path, "-nobrowse", "-mountpoint", targetPath.path],
        timeout: 300)
    }

    guard result?.succeeded == true else {
      return CMActionResult(
        succeeded: false,
        message: "Nie udalo sie podpiac obrazu: \(result?.stderr ?? "nieznany blad")")
    }
    return CMActionResult(succeeded: true, message: "Podpiete: \(targetPath.path)")
  }

  /// Odpina obraz i CZEKA, az wszystko doleci na Google Drive.
  ///
  /// Czekanie nie jest ostroznoscia na zapas. Samo odpiecie zapisuje metadane
  /// APFS do pasm, a `--vfs-write-back` odklada ich wyslanie o kilkadziesiat
  /// sekund. Utrata bufora w tym oknie nie kosztuje "ostatnich zmian" - zabiera
  /// katalog glowny wolumenu. Zaobserwowane na zywo: 367 MiB pasm lezalo juz na
  /// Dysku, a obraz po ponownym podpieciu byl pusty, bo trzy pasma z metadanymi
  /// zostaly zabite w kolejce.
  ///
  /// Dlatego kazda sciezka wygaszania - odpiecie, zatrzymanie bufora,
  /// wylaczenie Maca - musi przepuscic drenaz do konca.
  public static func detach(force: Bool = false, waitForUpload: Bool = true) async -> CMActionResult
  {
    var args = ["detach", targetPath.path, "-quiet"]
    if force { args.append("-force") }
    let result = try? await ProcessRunner.run("/usr/bin/hdiutil", args, timeout: 120)
    guard result?.succeeded == true else {
      return CMActionResult(succeeded: false, message: "Nie udalo sie odpiac.")
    }

    guard waitForUpload else {
      return CMActionResult(
        succeeded: true, message: "Odpiete (bez czekania na wysylke - dane moga byc tylko lokalnie).")
    }

    // Zapisy z odpiecia trafiaja do kolejki dopiero po `--vfs-write-back`,
    // wiec najpierw dajemy im szanse tam trafic, a dopiero potem czekamy
    // na cisze. Bez tej przerwy kolejka wygladalaby na pusta, bo jeszcze
    // by sie nie zdazyla zapelnic.
    try? await Task.sleep(nanoseconds: 35_000_000_000)
    let drained = await DriveBufferService.waitUntilQuiet(timeout: 600)
    return CMActionResult(
      succeeded: drained,
      message: drained
        ? "Odpiete, wszystko wyslane na Google Drive."
        : "Odpiete, ale wysylka NIE zakonczyla sie w czasie - nie kasuj bufora.")
  }

  // MARK: - Weryfikacja

  /// Sprawdza spojnosc obrazu.
  ///
  /// UWAGA: `hdiutil verify` na sparsebundle NIE dziala - taki obraz nie ma
  /// sumy kontrolnej i narzedzie konczy komunikatem "has no checksum".
  /// Trzeba podpiac urzadzenie bez montowania i puscic na nim `fsck_apfs`.
  public static func verify() async -> CMActionResult {
    guard exists else {
      return CMActionResult(succeeded: false, message: "Brak obrazu.")
    }
    if isAttached {
      return CMActionResult(
        succeeded: false,
        message: "Obraz jest podpiety - odepnij go przed sprawdzeniem.")
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
      return CMActionResult(succeeded: false, message: "Nie znalazlem urzadzenia APFS w obrazie.")
    }

    defer {
      Task {
        _ = try? await ProcessRunner.run(
          "/usr/bin/hdiutil", ["detach", String(device), "-force", "-quiet"], timeout: 60)
      }
    }

    let fsck = try? await ProcessRunner.run(fsckPath, ["-n", String(device)], timeout: 3600)
    return CMActionResult(
      succeeded: fsck?.succeeded == true,
      message: fsck?.succeeded == true
        ? "Obraz spojny." : "Obraz NIESPOJNY: \(fsck?.stdout.suffix(500) ?? "")")
  }

  // MARK: - Ponawianie

  /// Ponawia operacje `hdiutil` na montowaniu FUSE-T.
  ///
  /// FUSE-T montuje przez NFS, a `hdiutil` na takim wolumenie bywa odrzucany
  /// bledem "RPC version wrong". Zmierzone: blad nie zalezy od rozmiaru obrazu
  /// ani od danych (jeden przebieg padl dla 100 GB i 400 GB, a przeszedl dla
  /// 600, 1000 i 1500 GB), tylko od chwili - przy pustej kolejce wysylki
  /// 5 prob na 5 udanych, przy rclone zajetym losowo. Przy tworzeniu obrazu
  /// produkcyjnego pierwsza proba padla, druga przeszla.
  private static func retryingFlakyMount(
    attempts: Int, _ operation: () async -> ProcessResult?
  ) async -> ProcessResult? {
    var last: ProcessResult?
    for attempt in 1...attempts {
      last = await operation()
      if last?.succeeded == true { return last }
      guard attempt < attempts else { break }
      CMLogger.log("hdiutil: proba \(attempt) nieudana, ponawiam")
      try? await Task.sleep(nanoseconds: 5_000_000_000)
      await DriveBufferService.waitUntilQuiet(timeout: 60)
    }
    return last
  }
}
