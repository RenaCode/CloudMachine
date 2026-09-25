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
  /// `cloudmachine-poc amplification` i tabela w `gdrive/README.md`.
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

  // MARK: - Wzajemne wykluczenie

  /// Nazwa blokady, pod ktora chodza WSZYSTKIE operacje zmieniajace stan
  /// obrazu: `create`, `attach`, `detach`, `verify`.
  ///
  /// Do 23 wrzesnia 2026 nie wykluczaly sie nawzajem niczym - `CMLock` istnial,
  /// ale `withCMLock` nie bylo wolane z ani jednego miejsca w repo. Realny
  /// przebieg, ktory to ujawnil: `detach` czeka na drenaz (35 s przerwy na
  /// zapelnienie kolejki + do 600 s na cisze, czyli okno do 10,5 minuty),
  /// a agent `gdrive-attach` tyka co 900 s. Agent regularnie wchodzil w to
  /// okno, widzial obraz jako odpiety - bo `hdiutil detach` juz przeszedl -
  /// i podpinal go z powrotem w srodku cudzego odpinania.
  ///
  /// Drugi wariant tego samego wyscigu: `purgeStaleDevices()` z tiku agenta
  /// robi `hdiutil detach -force` na urzadzeniu, na ktorym akurat chodzi
  /// `fsck_apfs` z `verify` - i `verify` meldowal "Obraz NIESPOJNY" o calym
  /// backupie (patrz komentarz przy `verify`).
  public static let lockName = "image"

  /// Wynik operacji, ktora sie NIE WYDARZYLA, bo obraz zajmuje inna operacja.
  ///
  /// `withCMLock` oddaje wtedy `nil` i to `nil` nie moze przejsc jako sukces:
  /// `attach`, ktorego nie bylo, zameldowalby "Podpiete", a `detach`, ktorego
  /// nie bylo - "wszystko wyslane na Google Drive".
  private static func busyResult(_ what: String) -> CMActionResult {
    CMLogger.log("\(what): blokade '\(lockName)' trzyma inna operacja na obrazie - nie robie nic")
    return CMActionResult(
      succeeded: false,
      message: """
        \(what): inna operacja na obrazie jest w toku (tworzenie, podpinanie, \
        odpinanie albo sprawdzanie) - NIE zrobiono nic. Sprobuj za chwile.
        """,
      // Nie awaria, tylko "nie teraz" - patrz `CMActionResult.Disposition`.
      didNotRun: true)
  }

  // MARK: - Stan

  public static var exists: Bool {
    var isDir: ObjCBool = false
    let ok = FileManager.default.fileExists(atPath: imagePath.path, isDirectory: &isDir)
    return ok && isDir.boolValue
  }

  /// Czy wolumen figuruje w tablicy montowan.
  ///
  /// UWAGA: to mowi tylko, ze `hdiutil` kiedys podpial obraz - NIE, ze obraz
  /// oddaje dane. Martwe urzadzenie (patrz `ImageProbe`) siedzi w tej tablicy
  /// tak samo jak zywe. Do pytania "czy Time Machine ma gdzie pisac" sluzy
  /// `attachment`; `isAttached` zostaje tam, gdzie chodzi o samo odpiecie.
  public static var isAttached: Bool { attachedState() ?? false }

  /// Jak `isAttached`, ale `nil` = tablicy montowan NIE UDALO SIE odczytac.
  ///
  /// Ta sama zmiana, co w `DriveBufferService.mountPoints()` i z tego samego
  /// powodu: dotad szlo to przez `/sbin/mount` bez limitu czasu, a pyta o
  /// wolumen, ktory bywa MARTWY - czyli dokladnie o ten, na ktorym taki odczyt
  /// potrafi zawisnac. Teraz idzie przez tablice jadra, bez procesu i bez
  /// dotykania systemu plikow.
  public static func attachedState() -> Bool? {
    guard let points = DriveBufferService.mountPoints() else { return nil }
    return points.contains(targetPath.path)
  }

  public enum Attachment: Equatable {
    case detached
    case attached
    /// W tablicy montowan, ale odczyt pada z podanym `errno`. Time Machine
    /// widzi ten stan jako "dysk odlaczony" i nie zrobi ani jednej kopii,
    /// dopoki obraz nie zostanie odpiety i podpiety na nowo.
    case dead(errno: Int32)
    /// Tablicy montowan NIE UDALO SIE odczytac, wiec o stanie obrazu nie
    /// wiadomo nic. To nie jest `.detached`: `.detached` to twierdzenie
    /// ("sprawdzilem, nie ma"), a tu nie bylo czego sprawdzic.
    ///
    /// Po przejsciu na `getmntinfo(MNT_NOWAIT)` ten stan jest skrajnie malo
    /// prawdopodobny - to odczyt z pamieci jadra, ktory nie ma jak zawisnac
    /// ani pojsc do sieci. Istnieje mimo to, bo `attachment` jest typem, na
    /// ktorym wolajacy opieraja decyzje, a typ nie powinien zmuszac do
    /// zmyslania odpowiedzi.
    case unknown

    /// Czy Time Machine ma gdzie pisac. `.unknown` swiadomie daje `false` -
    /// to jest pytanie "czy MOGE na tym polegac", a na niewiadomej polegac
    /// nie mozna.
    public var isUsable: Bool { self == .attached }
  }

  /// Stan podpiecia z uwzglednieniem tego, czy urzadzenie ZYJE.
  public static var attachment: Attachment {
    switch attachedState() {
    case .none: return .unknown
    case .some(false): return .detached
    case .some(true):
      switch ImageProbe.probe(volume: targetPath) {
      case .dead(let errno): return .dead(errno: errno)
      case .readable, .nothingToProbe: return .attached
      }
    }
  }

  public static func describe(_ attachment: Attachment) -> String {
    switch attachment {
    case .detached: return "BRAK"
    case .attached: return "OK  (\(targetPath.path))"
    case .dead(let errno):
      return
        "MARTWY - w tablicy montowan, ale odczyt pada (errno \(errno)); attach-image podpina na nowo"
    case .unknown:
      return "NIE WIADOMO - nie udalo sie odczytac tablicy montowan"
    }
  }

  /// Punkty montowania przegladanych migawek backupu.
  ///
  /// Czysta wersja, zeby dalo sie ja sprawdzic testem bez montowania
  /// czegokolwiek - wczesniej to samo wychodzilo z parsowania wydruku
  /// `/sbin/mount` (`" on "` ... `" ("`), wiec nie bylo do czego podstawic
  /// probki.
  static func browsedSnapshotMounts(_ points: [String]) -> [String] {
    points.filter { $0.hasPrefix("/Volumes/.timemachine/") }
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
    await withCMLock(lockName) { await createLocked(sizeGB: sizeGB) }
      ?? busyResult("Tworzenie obrazu")
  }

  private static func createLocked(sizeGB: Int) async -> CMActionResult {
    switch DriveBufferService.mountedState() {
    case .some(true):
      break
    case .some(false):
      return CMActionResult(
        succeeded: false, message: "Drive nie jest zamontowany - najpierw uruchom bufor.")
    case .none:
      // Nie `isMounted`: tworzenie obrazu jest NIEODWRACALNE, wiec "nie wiem"
      // nie moze tu przejsc jako "nie zamontowany" ani tym bardziej dalej.
      return CMActionResult(
        succeeded: false,
        message: """
          Nie udalo sie odczytac tablicy montowan - NIE WIADOMO, czy bufor jest \
          zamontowany. NIE tworze obrazu.
          """)
    }

    // Straznik "obraz juz istnieje" czyta cache FUSE, a rclone wystawia
    // montowanie ZANIM wczyta z Dysku zawartosc katalogu - w tym oknie
    // `exists` mowi "nie ma obrazu" o obrazie, ktory jest. `attach-image`
    // czeka tu na `BufferReadiness.wait` od 13 wrzesnia 2026, `create` nie
    // czekalo wcale. Dla `attach` przegapienie okna kosztuje jedno nieudane
    // podpiecie; dla `create` - `hdiutil create` idzie na sciezke istniejacego
    // backupu, i to z pieciokrotnym ponawianiem.
    //
    // Czekamy na UDANE listowanie punktu montowania, a nie na samo
    // `isMounted`: na to drugie odpowiedzial juz straznik wyzej, wiec probka
    // przechodzilaby natychmiast i czekanie nie robiloby NIC. Listowanie
    // korzenia przy zimnym `--dir-cache-time` idzie po dane do Google, wiec
    // jego powodzenie znaczy "rclone faktycznie obsluguje ten katalog";
    // dopoki FUSE nie zaczelo serwowac, konczy sie bledem urzadzenia.
    //
    // UWAGA co do zasiegu: to czekanie usuwa okno "FUSE jeszcze nie odpowiada",
    // ale NIE dowodzi nieobecnosci obrazu - puste listowanie wyglada tak samo
    // przy pustym koncie i przy niewczytanym katalogu. Dowodem jest dopiero
    // `remoteImagePresence()` nizej i to on, a nie to czekanie, wstrzymuje
    // operacje nieodwracalna.
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
        message:
          "Bufor nie stanal w \(Int(BufferReadiness.defaultTimeout / 60)) min - NIE tworze obrazu.")
    }

    guard !exists else {
      return CMActionResult(
        succeeded: false,
        message: "Obraz juz istnieje. Usuniecie go kasuje caly backup - zrob to swiadomie.")
    }

    // Cache FUSE juz raz sklamal, wiec pytamy jeszcze raz ZDALNEGO, z
    // pominieciem montowania. To jest operacja NIEODWRACALNA: brak pewnosci
    // musi ja PRZERWAC, a nie tylko wypisac ostrzezenie, ktore i tak nikt nie
    // czyta przed zatwierdzeniem.
    switch await remoteImagePresence() {
    case .absent:
      break
    case .present:
      return CMActionResult(
        succeeded: false,
        message: """
          Obraz juz istnieje na Google Drive (cache montowania go nie pokazywal, \
          ale zdalny go ma). Usuniecie go kasuje caly backup - zrob to swiadomie.
          """)
    case .unknown(let why):
      return CMActionResult(
        succeeded: false,
        message: """
          Nie udalo sie potwierdzic na Google Drive, ze obrazu tam jeszcze nie ma \
          (\(why)) - PRZERYWAM. Tworzenie obrazu na istniejacym backupie jest \
          nieodwracalne, wiec bez tej odpowiedzi nie zaczynam.
          """)
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
        message: "Nie udalo sie utworzyc obrazu: \(result?.stderr ?? "nieznany blad")")
    }
    return CMActionResult(
      succeeded: true,
      message: "Utworzono obraz \(sizeGB) GB, pasmo \(bandSectors * 512 / 1024 / 1024) MB.")
  }

  // MARK: - Obraz na zdalnym

  /// Czy obraz lezy na Google Drive - pytane BEZ posrednictwa montowania.
  public enum RemotePresence: Equatable {
    case present
    case absent
    /// Nie wiadomo. `why` idzie do komunikatu, zeby uzytkownik wiedzial,
    /// czego dokladnie zabraklo.
    case unknown(String)
  }

  /// Pyta `rclone lsf` prosto o zdalny katalog backupu.
  ///
  /// Sens jest w tym, ze omija cache FUSE - a to wlasnie cache FUSE mowi
  /// "nie ma obrazu" przez pierwsze sekundy po wystawieniu montowania.
  public static func remoteImagePresence() async -> RemotePresence {
    let remote = "\(DriveBufferService.remoteName):\(DriveBufferService.remotePath)"
    guard
      let result = try? await CMTooling.runRclone(["lsf", "--dirs-only", remote], timeout: 120)
    else {
      return .unknown("rclone nie odpowiedzial")
    }
    return classifyRemoteListing(
      succeeded: result.succeeded, stdout: result.stdout, stderr: result.stderr)
  }

  /// Czysta wersja - zeby dalo sie ja sprawdzic testem bez sieci i bez konta.
  ///
  /// Nieudane `lsf` z komunikatem "directory not found" NIE jest brakiem
  /// odpowiedzi, tylko odpowiedzia "nie ma tam niczego": tak wyglada pierwsze
  /// uruchomienie, zanim cokolwiek zostalo na Dysk wyslane. Gdybysmy zaliczyli
  /// to do `.unknown`, `create` nie dalby sie wykonac ANI RAZU - straznik
  /// blokowalby dokladnie ten przypadek, dla ktorego istnieje.
  static func classifyRemoteListing(succeeded: Bool, stdout: String, stderr: String)
    -> RemotePresence
  {
    if succeeded {
      return listingContainsImage(stdout) ? .present : .absent
    }
    if stderr.lowercased().contains("directory not found") { return .absent }
    let reason = stderr.trimmingCharacters(in: .whitespacesAndNewlines)
    return .unknown(reason.isEmpty ? "rclone lsf zakonczylo sie bledem" : String(reason.suffix(200)))
  }

  /// `rclone lsf --dirs-only` konczy nazwy katalogow ukosnikiem, ale nie
  /// polegamy na tym - przyjmujemy obie postacie.
  static func listingContainsImage(_ listing: String) -> Bool {
    let wanted = "\(imageName).sparsebundle"
    return listing.components(separatedBy: .newlines)
      .map { $0.trimmingCharacters(in: .whitespaces) }
      .contains { $0 == wanted || $0 == wanted + "/" }
  }

  // MARK: - Podpinanie

  public static func attach() async -> CMActionResult {
    await withCMLock(lockName) { await attachLocked() } ?? busyResult("Podpinanie obrazu")
  }

  private static func attachLocked() async -> CMActionResult {
    switch DriveBufferService.mountedState() {
    case .some(true):
      break
    case .some(false):
      return CMActionResult(succeeded: false, message: "Drive nie jest zamontowany.")
    case .none:
      // Podpiecie obrazu na NIEZAMONTOWANYM buforze konczy sie obrazem
      // wiszacym na pustym katalogu, wiec "nie wiem" ma tu wstrzymac, a nie
      // przepuscic. Tik agenta sprobuje znowu za 900 s.
      return CMActionResult(
        succeeded: false,
        message: """
          Nie udalo sie odczytac tablicy montowan - NIE WIADOMO, czy bufor jest \
          zamontowany. NIE podpinam obrazu.
          """)
    }
    guard exists else {
      return CMActionResult(succeeded: false, message: "Brak obrazu - najpierw go utworz.")
    }
    switch attachment {
    case .attached:
      return CMActionResult(succeeded: true, message: "Juz podpiete: \(targetPath.path)")
    case .unknown:
      // Nie `.detached`, bo nastepnym krokiem bylby `hdiutil attach` na
      // obrazie, ktory moze byc juz podpiety - a wczesniej jeszcze
      // `purgeStaleDevices()`, czyli `detach -force` na cudzym, zywym
      // urzadzeniu. "Nie wiem" nie moze uruchamiac ani jednego, ani drugiego.
      return CMActionResult(
        succeeded: false,
        message: """
          Nie udalo sie odczytac tablicy montowan - NIE WIADOMO, czy obraz jest \
          podpiety. NIE podpinam.
          """)
    case .dead(let errno):
      // Obraz jest w tablicy montowan, ale nie oddaje danych. Do 22 wrz 2026
      // ta funkcja mowila wtedy "Juz podpiete" i wychodzila - agent podpinajacy
      // powtarzal to co 15 minut przez 15 godzin, a Time Machine nie mial celu.
      // Jedyna droga jest odpiecie (musi byc `-force`, zwykle odmawia na
      // martwym urzadzeniu) i podpiecie od nowa. Czekanie na wysylke zostaje:
      // to, co zdazylo trafic do bufora rclone, nadal ma doleciec na Dysk.
      CMLogger.log("Obraz martwy (errno \(errno)) - odpinam na sile i podpinam od nowa")
      // `detachLocked`, nie `detach`: blokade 'image' trzymamy juz my,
      // a `CMLock` nie jest wznawialna - wejscie przez publiczna `detach`
      // zobaczyloby wlasna, zywa blokade i odmowilo samo sobie.
      let detached = await detachLocked(force: true)
      CMLogger.log("Odpiecie martwego obrazu: \(detached.message)")
      guard !isAttached else {
        return CMActionResult(
          succeeded: false,
          message: "Obraz martwy (errno \(errno)) i nie dal sie odpiac: \(detached.message)")
      }
    case .detached:
      break
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

    // Cisza w kolejce nie jest tu wygoda, tylko warunkiem powodzenia:
    // `hdiutil` na wolumenie FUSE-T odrzuca montowanie tym czesciej, im
    // bardziej rclone jest zajety (patrz `retryingFlakyMount`). Przy
    // `writeBackSeconds` liczonym w minutach kolejka sama nie opustoszeje
    // w ponizszym limicie czasu, wiec najpierw wymuszamy wysylke - inaczej
    // podpiecie po kazdym starcie bylo by loteria.
    await DriveBufferService.expireQueuedUploads()
    await DriveBufferService.waitUntilIdle(timeout: 120)

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
    await withCMLock(lockName) { await detachLocked(force: force, waitForUpload: waitForUpload) }
      ?? busyResult("Odpinanie obrazu")
  }

  private static func detachLocked(force: Bool = false, waitForUpload: Bool = true) async
    -> CMActionResult
  {
    let stillMounted = await unmountBrowsedSnapshots()

    var args = ["detach", targetPath.path, "-quiet"]
    if force { args.append("-force") }
    let result = try? await ProcessRunner.run("/usr/bin/hdiutil", args, timeout: 120)
    guard result?.succeeded == true else {
      // Podajemy powod, jesli go znamy. `hdiutil` mowi tylko "resource busy"
      // i ani slowa o tym, co trzyma urzadzenie - a to prawie zawsze
      // przegladana migawka backupu.
      guard stillMounted.isEmpty else {
        return CMActionResult(
          succeeded: false,
          message: """
            Nie udalo sie odpiac - obraz trzymaja przegladane migawki backupu, \
            ktorych nie dalo sie odmontowac:
            \(stillMounted.joined(separator: "\n"))
            Zamknij okno Time Machine / Findera na backupie i sprobuj ponownie.
            """)
      }
      return CMActionResult(succeeded: false, message: "Nie udalo sie odpiac.")
    }

    guard waitForUpload else {
      return CMActionResult(
        succeeded: true,
        message: "Odpiete (bez czekania na wysylke - dane moga byc tylko lokalnie).")
    }

    // Zapisy z odpiecia musza najpierw trafic do kolejki - bez tej przerwy
    // wygladalaby na pusta, bo jeszcze by sie nie zdazyla zapelnic.
    //
    // UWAGA co do mechanizmu: pozycja pojawia sie w kolejce ZARAZ po zapisie,
    // tyle ze z terminem wysylki `writeBackSeconds` w przod (widac to w
    // `vfs/queue` jako dodatnie `expiry`). Ta przerwa czeka wiec na samo
    // zakolejkowanie, a NIE na uplyw tego terminu - wczesniejszy komentarz
    // w tym miejscu twierdzil odwrotnie.
    try? await Task.sleep(nanoseconds: 35_000_000_000)

    // Terminy przesuwamy dopiero teraz, gdy kolejka jest juz kompletna.
    // Bez tego drenaz trwalby tyle, co `writeBackSeconds` (dziesiec minut),
    // czyli dluzej niz ponizszy limit czasu - i odpiecie zglaszaloby
    // niepowodzenie za kazdym razem.
    CMLogger.log(expiryLogLine(await DriveBufferService.expireQueuedUploads()))
    return detachVerdict(settled: await DriveBufferService.statsWhenIdle(timeout: 600))
  }

  /// Co odpiecie wpisuje do logu po probie przyspieszenia kolejki.
  ///
  /// TRZY rozne rzeczy wygladaly tu jak dwie. "Nie dostalismy odpowiedzi" od
  /// "kolejka byla pusta" odroznilismy 23.09.2026, ale trzeci przypadek -
  /// kolejka PELNA, a kazde `vfs/queue-set-expiry` padlo - nadal wychodzil
  /// z `expireQueuedUploads` jako `0` i log meldowal "kolejka pusta".
  /// Zmierzony stan tej maszyny w chwili audytu: 462 pozycje w kolejce.
  ///
  /// Tryb awarii jest ciezszy niz sama nieprawda w logu: czlowiek czyta te
  /// linie dokladnie wtedy, gdy decyduje, czy wolno skasowac bufor. "Kolejka
  /// pusta" czyta sie jako "nic nie czeka na wyslanie", a znaczylo
  /// "czekaja 462 pozycje i zadnej nie udalo sie ruszyc".
  ///
  /// Wydzielone i CZYSTE, zeby te trzy przypadki dalo sie sprawdzic testem bez
  /// rclone. Funkcja jest wylacznie opisem: o czekaniu na drenaz i o werdykcie
  /// decyduje `detachLocked`/`detachVerdict` i ta poprawka ich nie dotyka.
  static func expiryLogLine(_ outcome: DriveBufferService.ExpiryOutcome?) -> String {
    let drenaz = "drenaz moze trwac do \(DriveBufferService.writeBackSeconds / 60) min"
    guard let outcome else {
      // Brak odpowiedzi to NIE pusta kolejka - patrz `expireQueuedUploads`.
      return "Odpiecie: rclone nie odpowiedzial na pytanie o kolejke - terminow wysylki NIE"
        + " przesunieto, \(drenaz)"
    }
    if outcome.queued == 0 {
      return "Odpiecie: kolejka pusta - nie bylo czego przyspieszac"
    }
    if outcome.moved == 0 {
      return "Odpiecie: UWAGA - kolejka ma \(outcome.queued) pozycji i ANI JEDNEJ nie udalo sie"
        + " przyspieszyc (rclone odrzucil kazde vfs/queue-set-expiry), \(drenaz)"
    }
    if outcome.moved < outcome.queued {
      return "Odpiecie: wymuszono wysylke \(outcome.moved) z \(outcome.queued) pozycji kolejki -"
        + " pozostalym \(outcome.queued - outcome.moved) NIE przesunieto terminu, \(drenaz)"
    }
    return "Odpiecie: wymuszono wysylke \(outcome.moved) pozycji z kolejki"
  }

  /// Czysta wersja werdyktu o odpieciu - `settled` to odczyt kolejki z chwili,
  /// w ktorej ucichla (`nil` = nie ucichla w czasie albo rclone nie odpowiedzial).
  ///
  /// Pusta kolejka to jeszcze nie komplet danych na Dysku. Pasma, ktore rclone
  /// PORZUCIL, wypadaja z kolejki dokladnie tak samo jak wyslane i zostaja
  /// wylacznie w `erroredFiles`. Do 23 wrzesnia 2026 odpiecie patrzylo tylko
  /// na `uploadsInProgress`/`uploadsQueued`, wiec meldowalo "Odpiete, wszystko
  /// wyslane na Google Drive" przy danych istniejacych TYLKO na tym Macu -
  /// a `UploadState` z tych samych licznikow wyprowadzal juz wtedy
  /// `.failedFiles(...)` z etykieta "WYMAGA REAKCJI". CLI i GUI mowily o tej
  /// samej chwili dwie rozne rzeczy.
  static func detachVerdict(settled: DriveBufferService.QueueStats?) -> CMActionResult {
    guard let settled else {
      return CMActionResult(
        succeeded: false,
        message: "Odpiete, ale wysylka NIE zakonczyla sie w czasie - nie kasuj bufora.")
    }
    guard settled.erroredFiles == 0 else {
      return CMActionResult(
        succeeded: false,
        message: """
          Odpiete, ale rclone PORZUCIL \(settled.erroredFiles) fragmentow kopii - istnieja \
          wylacznie na tym Macu i na Google Drive ich nie ma. Nie kasuj bufora.
          """)
    }
    return CMActionResult(succeeded: true, message: "Odpiete, wszystko wyslane na Google Drive.")
  }

  /// Odmontowuje migawki backupu podpiete pod `/Volumes/.timemachine/`.
  /// Zwraca sciezki, ktorych NIE udalo sie odmontowac.
  ///
  /// Przegladanie backupu - w Finderze albo zwyklym `ls` po sciezce z
  /// `tmutil listbackups` - montuje jego migawke tylko do odczytu. Takie
  /// montowanie trzyma urzadzenie obrazu zajete i `hdiutil detach` odmawia,
  /// a komunikat nie mowi ani slowa o tym, co go blokuje.
  ///
  /// UZYWAMY `diskutil unmount`, NIE `/sbin/umount`. Zmierzone na dzialajacej
  /// instalacji: `umount` na takiej migawce konczy sie
  /// `Operation not permitted` dla uzytkownika (montowaniem zarzadza system),
  /// a `diskutil unmount` na tej samej sciezce przechodzi bez roota.
  /// Poprzednia wersja wolala `umount` przez `try?` i logowala "Odmontowano"
  /// NIEZALEZNIE od wyniku - wiec przy 18 podpietych migawkach log meldowal
  /// 18 sukcesow, zadna nie zostala odmontowana, a `hdiutil detach` zaraz
  /// potem odmawial bez zwiazku ze soba widocznego w logu.
  @discardableResult
  public static func unmountBrowsedSnapshots() async -> [String] {
    guard let points = DriveBufferService.mountPoints() else { return [] }
    var failed: [String] = []
    for path in browsedSnapshotMounts(points) {
      let result = try? await ProcessRunner.run(
        "/usr/sbin/diskutil", ["unmount", path], timeout: 60)
      if result?.succeeded == true {
        CMLogger.log("Odmontowano przegladana migawke backupu: \(path)")
      } else {
        failed.append(path)
        CMLogger.log("NIE udalo sie odmontowac migawki backupu: \(path)")
      }
    }
    return failed
  }

  // MARK: - Weryfikacja

  /// Sprawdza spojnosc obrazu.
  ///
  /// UWAGA: `hdiutil verify` na sparsebundle NIE dziala - taki obraz nie ma
  /// sumy kontrolnej i narzedzie konczy komunikatem "has no checksum".
  /// Trzeba podpiac urzadzenie bez montowania i puscic na nim `fsck_apfs`.
  public static func verify() async -> CMActionResult {
    await withCMLock(lockName) { await verifyLocked() } ?? busyResult("Sprawdzanie obrazu")
  }

  private static func verifyLocked() async -> CMActionResult {
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

    // BEZ timeoutu. `fsck_apfs` czyta metadane przez montowanie rclone, wiec
    // jego czas zalezy od lacza i od liczby migawek - zmierzone na obrazie
    // 210 GiB z 18 migawkami: pojedyncza migawka schodzi w minutach.
    // Wczesniejsza granica godziny nie chronila przed niczym, a zamieniala
    // "sprawdzenie jeszcze trwa" w "Obraz NIESPOJNY", bo ubity `fsck` zwraca
    // niezerowy kod tak samo jak `fsck`, ktory znalazl uszkodzenie. Falszywy
    // alarm o utracie backupu jest tu grozniejszy niz dlugie czekanie.
    let fsck = try? await ProcessRunner.run(fsckPath, ["-n", String(device)])

    // Czy urzadzenie bylo jeszcze nasze, gdy `fsck` konczyl?
    //
    // `fsck_apfs` zwraca niezerowy kod tak samo, gdy znalazl uszkodzenie, jak
    // i wtedy, gdy ktos wyrwal mu urzadzenie spod nog - a wyrwac je potrafi
    // `purgeStaleDevices()` (`hdiutil detach -force`) przy tiku agenta
    // `gdrive-attach` co 900 s. Bez tego sprawdzenia `verify` meldowal wtedy
    // "Obraz NIESPOJNY", czyli falszywy alarm o utracie calego backupu.
    // Blokada 'image' zamyka juz to okno, ale komunikat ma byc uczciwy
    // takze wtedy, gdy urzadzenie znika z innego powodu.
    let deviceSurvived = await devicesForImage().contains(parentDevice(of: String(device)))

    // Odpinamy Z CZEKANIEM, nie przez `defer { Task { ... } }`. Tamta wersja
    // wracala z funkcji, zanim odpiecie sie wydarzylo - a wolajacy zwykle od
    // razu podpina obraz z powrotem, wiec podpiecie scigalo sie z zaleglym
    // odpieciem tego samego urzadzenia.
    _ = try? await ProcessRunner.run(
      "/usr/bin/hdiutil", ["detach", String(device), "-force", "-quiet"], timeout: 120)

    // "Nie udalo sie sprawdzic" to NIE to samo co "niespojny" - jedno znaczy
    // brak wyniku, drugie uszkodzony backup. Zlanie ich w jeden komunikat
    // kazaloby uzytkownikowi odtwarzac cala kopie z powodu nieudanego
    // uruchomienia narzedzia.
    guard let fsck else {
      return CMActionResult(
        succeeded: false,
        message: "Nie udalo sie uruchomic \(fsckPath) - spojnosc obrazu POZOSTAJE NIESPRAWDZONA.")
    }
    if !fsck.succeeded && !deviceSurvived {
      return CMActionResult(
        succeeded: false,
        message: """
          Sprawdzenie PRZERWANE - urzadzenie \(device) zniklo w trakcie (ktos odpial \
          obraz na sile). To nie jest wynik o stanie backupu: spojnosc obrazu \
          POZOSTAJE NIESPRAWDZONA. Powtorz sprawdzenie.
          """)
    }
    return CMActionResult(
      succeeded: fsck.succeeded,
      message: fsck.succeeded
        ? "Obraz spojny." : "Obraz NIESPOJNY: \(fsck.stdout.suffix(500))")
  }

  /// `/dev/disk7s1` -> `/dev/disk7`.
  ///
  /// `fsck_apfs` dostaje partycje APFS, a `hdiutil info` - i wiec
  /// `devicesForImage()` - wypisuje urzadzenie NADRZEDNE. Porownanie ich
  /// wprost nigdy by sie nie zgodzilo, wiec sprawdzenie "czy urzadzenie
  /// przezylo" cicho odpowiadaloby "nie" za kazdym razem.
  static func parentDevice(of device: String) -> String {
    let prefix = "/dev/disk"
    guard device.hasPrefix(prefix) else { return device }
    let digits = device.dropFirst(prefix.count).prefix(while: \.isNumber)
    return digits.isEmpty ? device : prefix + digits
  }

  // MARK: - Gotowosc do restartu

  /// Czy mozna bezpiecznie wylaczyc Maca bez `prepare-shutdown`.
  ///
  /// Ryzyko przy wylaczaniu nie jest stale - istnieje tylko wtedy, gdy w
  /// buforze czekaja dane jeszcze niewyslane. macOS daje agentom kilkanascie
  /// sekund na zamkniecie, co przy pustej kolejce wystarcza z zapasem, a przy
  /// pelnej nie wystarcza wcale.
  ///
  /// Zmierzone: kolejka wraca do zera w ciagu kilku minut po kazdym backupie
  /// godzinowym, wiec przez wieksza czesc doby restart jest po prostu
  /// bezpieczny. Zamiast kazac uzytkownikowi pamietac o poleceniu przed kazdym
  /// restartem, mowimy mu, kiedy naprawde jest potrzebne.
  public static func safeToRebootNow() async -> Bool {
    guard let stats = await DriveBufferService.queueStats() else {
      // Bez odczytu ze stanu kolejki nie mamy podstaw twierdzic, ze jest
      // bezpiecznie - a przy takim pytaniu milczenie musi znaczyc "nie".
      return false
    }
    // `isQuiet`, NIE `isIdle`: pusta kolejka nie wystarczy, bo pasma porzucone
    // przez rclone (`erroredFiles`) wypadaja z kolejki tak samo jak wyslane.
    // Restart przy takim stanie nie niszczy niczego dodatkowo, ale odpowiedz
    // "TAK - kolejka pusta" czytalo sie jako "kopia na Dysku jest kompletna",
    // a nie byla - i to samo zdanie padalo w `drive-status` obok
    // `UploadState.failedFiles` z etykieta "WYMAGA REAKCJI".
    return stats.isQuiet
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
      await DriveBufferService.waitUntilIdle(timeout: 60)
    }
    return last
  }
}
