import Foundation

/// Pilnuje, zeby bufor nie zjadl dysku - port `gdrive/buffer-guard.sh`.
///
/// Time Machine pisze do podpietego obrazu z predkoscia SSD (zmierzone
/// 267 MB/s), a rclone wysyla z predkoscia lacza (~41 MB/s przy 332 Mb/s
/// uploadu). Roznica laduje w buforze.
///
/// `--vfs-cache-max-size` jest limitem MIEKKIM: rclone usuwa z bufora tylko
/// dane juz wyslane, wiec gdy wszystko czeka w kolejce, bufor rosnie dalej
/// i moze zapelnic dysk. Przy pierwszym backupie liczonym w terabajtach to nie
/// jest teoria - zmierzony przyrost netto na starcie wynosil 32 MB/s.
///
/// Dozorca wstrzymuje Time Machine powyzej progu i wznawia, gdy wysylka
/// nadgoni. Backup staje sie wolniejszy, ale konczy sie zamiast wysypac
/// maszyne.
public actor BufferGuardService {

  public struct Thresholds: Sendable {
    /// Powyzej tego rozmiaru bufora wstrzymujemy Time Machine.
    public var highGB: Int
    /// Ponizej tego wznawiamy.
    public var lowGB: Int
    /// Ponizej tylu GB wolnych na dysku wstrzymujemy niezaleznie od bufora.
    public var minFreeGB: Int
    /// Ponizej tylu GB wolnych NA DYSKU GOOGLE nie wolno zdjac pauzy
    /// zalozonej z powodu braku miejsca na Dysku.
    ///
    /// Ta sama liczba, ktora `BackupHealth` uwaza za prog ostrzegawczy dla
    /// Dysku - jedno zrodlo prawdy. Przy przyroscie rzedu 600 MB na cykl
    /// godzinowy 30 GB to okolo dwoch tygodni zapasu, czyli tyle, zeby
    /// wznowiony backup mial gdzie sie zmiescic, a nie wrocil pod sciane
    /// w kolejnej godzinie.
    public var minDriveFreeGB: Int

    /// Progi wyliczane z rozmiaru bufora, nie wpisane z palca.
    ///
    /// `--vfs-cache-max-size` jest granica MIEKKA: rclone usuwa tylko to, co
    /// juz wyslal, wiec przy pelnej kolejce bufor rosnie ponad limit. Prog
    /// pauzy musi wiec lezec POWYZEJ rozmiaru bufora - inaczej dozorca
    /// wstrzymywalby backup bez przerwy, bo bufor normalnie stoi przy limicie
    /// (zmierzone: rowno 100 GiB przez cala pierwsza wysylke).
    ///
    /// Wpisanie 150 na sztywno dzialalo tylko przypadkiem, dla bufora 100 GB -
    /// po zmianie rozmiaru bufora prog bylby albo absurdalny, albo martwy.
    public init(
      highGB: Int = DriveBufferService.cacheSizeGB * 3 / 2,
      lowGB: Int = DriveBufferService.cacheSizeGB * 2 / 5,
      minFreeGB: Int = 80,
      minDriveFreeGB: Int = BackupHealth.driveFreeWarningGB
    ) {
      self.highGB = highGB
      self.lowGB = lowGB
      self.minFreeGB = minFreeGB
      self.minDriveFreeGB = minDriveFreeGB
    }
  }

  public enum State: String, Sendable {
    /// Nadzorujemy trwajacy backup.
    case running
    case pausedForBuffer
    case pausedForQuota
    /// Backup nie trwa - czuwamy do nastepnego.
    ///
    /// Dozorca NIE konczy pracy po skonczonym backupie. Dziala pod launchd
    /// z KeepAlive, wiec wyjscie oznaczaloby natychmiastowy restart, a przy
    /// niedzialajacym Time Machine - ciasna petle restartow ograniczana tylko
    /// przez ThrottleInterval.
    case idle
  }

  public struct Snapshot: Sendable {
    public var state: State
    public var bufferGB: Int
    /// `nil` = pomiaru NIE BYLO (statfs zawiodl), a nie "zero gigabajtow".
    public var freeGB: Int?
    /// `nil` = tmutil nie odpowiedzial, czyli nie wiadomo.
    public var backupRunning: Bool?
    public var percent: Double
  }

  /// Zrodla pomiarow i sterowania.
  ///
  /// Domyslne (`live`) czytaja prawdziwy system. Test podstawia wlasne i dzieki
  /// temu przechodzi CALA sciezke decyzji dozorcy - pauze, zmiane stanu,
  /// wznowienie - bez tmutil, rclone i prawdziwego backupu. Ten sam wzorzec,
  /// co `preferencesFile` w `BackupHealth.currentReport`: nie da sie inaczej
  /// wstrzyknac ZNANEJ ZLEJ probki, a wlasnie w decyzjach dozorcy (a nie
  /// w parsowaniu) siedzialy tu ciche awarie.
  public struct Probes: Sendable {
    public var queueStats: @Sendable () async -> DriveBufferService.QueueStats?
    /// `nil` = nie zmierzono.
    public var freeGB: @Sendable () -> Int?
    /// `nil` = tmutil nie odpowiedzial.
    public var backupRunning: @Sendable () async -> Bool?
    public var progressPercent: @Sendable () async -> Double
    public var hitStorageQuota: @Sendable () -> Bool
    public var uploadStalled: @Sendable () -> Bool
    /// Wolne bajty na Dysku Google. `nil` = NIE WIADOMO (rclone nie
    /// odpowiedzial) - i to nie jest zgoda na wznowienie.
    public var driveFreeBytes: @Sendable () async -> UInt64?
    /// `true` TYLKO gdy tmutil potwierdzil wykonanie polecenia.
    public var stopBackup: @Sendable () async -> Bool
    public var startBackup: @Sendable () async -> Bool
    public var reportStall: @Sendable (Bool) async -> Void
    /// Wydzielone, zeby test nie dopisywal swoich zmyslonych "PAUZA (prog)"
    /// do produkcyjnego `cloudmachine.log` - ten log sluzy do diagnozy
    /// prawdziwych awarii i nie moze zawierac zdarzen, ktore sie nie zdarzyly.
    public var log: @Sendable (String) -> Void

    public init(
      queueStats: @escaping @Sendable () async -> DriveBufferService.QueueStats?,
      freeGB: @escaping @Sendable () -> Int?,
      backupRunning: @escaping @Sendable () async -> Bool?,
      progressPercent: @escaping @Sendable () async -> Double,
      hitStorageQuota: @escaping @Sendable () -> Bool,
      uploadStalled: @escaping @Sendable () -> Bool,
      driveFreeBytes: @escaping @Sendable () async -> UInt64?,
      stopBackup: @escaping @Sendable () async -> Bool,
      startBackup: @escaping @Sendable () async -> Bool,
      reportStall: @escaping @Sendable (Bool) async -> Void,
      log: @escaping @Sendable (String) -> Void
    ) {
      self.queueStats = queueStats
      self.freeGB = freeGB
      self.backupRunning = backupRunning
      self.progressPercent = progressPercent
      self.hitStorageQuota = hitStorageQuota
      self.uploadStalled = uploadStalled
      self.driveFreeBytes = driveFreeBytes
      self.stopBackup = stopBackup
      self.startBackup = startBackup
      self.reportStall = reportStall
      self.log = log
    }

    public static let live = Probes(
      queueStats: { await DriveBufferService.queueStats() },
      freeGB: { BufferGuardService.freeGB() },
      backupRunning: { await TimeMachineStatus.runningState() },
      progressPercent: { (await TimeMachineStatus.currentProgress())?.percent ?? 0 },
      hitStorageQuota: { DriveBufferService.hitStorageQuota() },
      uploadStalled: { DriveBufferService.uploadStalled() },
      driveFreeBytes: { await DriveBufferService.remoteQuota()?.free },
      stopBackup: { await BufferGuardService.tmutil("stopbackup") },
      startBackup: { await BufferGuardService.tmutil("startbackup") },
      reportStall: { await BufferGuardService.reportUploadStall($0) },
      log: { CMLogger.log($0) })
  }

  private let thresholds: Thresholds
  private let probes: Probes
  private var state: State = .idle
  /// Czy od ostatniego przejscia w czuwanie widzielismy dzialajacy backup -
  /// zeby zameldowac zakonczenie raz, a nie przy kazdym tyknieciu.
  private var sawBackupRunning = false
  /// Czy poprzedni krok juz zglosil nieudane wstrzymanie - zeby przy awarii
  /// trwajacej godzinami log nie urosl o linie co 30 sekund, ale zeby samo
  /// zdarzenie NIE zniknelo (patrz `EdgeTriggeredLog`, ten sam powod).
  private var reportedStopFailure = false
  /// To samo dla braku pomiaru wolnego miejsca.
  private var reportedFreeUnknown = false
  /// To samo dla pauzy z powodu braku miejsca na Dysku trzymanej bez dowodu.
  private var reportedQuotaHold = false

  public init(thresholds: Thresholds = Thresholds(), probes: Probes = .live) {
    self.thresholds = thresholds
    self.probes = probes
  }

  // MARK: - Pomiary

  /// Rozmiar bufora wg rclone, z obchodem katalogu tylko jako awaryjnym
  /// zapasem - patrz `DriveBufferService.cacheSizeBytesByWalk`.
  public static func bufferGB(stats: DriveBufferService.QueueStats? = nil) -> Int {
    if let bytes = stats?.bytesUsed, bytes > 0 { return Int(bytes / 1_073_741_824) }
    return Int(DriveBufferService.cacheSizeBytesByWalk() / 1_073_741_824)
  }

  /// Wolne miejsce liczone tak, jak liczy je `df` - czyli PESYMISTYCZNIE.
  ///
  /// Kusi, zeby uzyc `volumeAvailableCapacityForImportantUsageKey`, ale to
  /// miara optymistyczna: wlicza miejsce zajete przez lokalne migawki, ktore
  /// system dopiero MOGLBY zwolnic. Na tej maszynie pokazywala 1202 GB, gdy
  /// `df` mowilo 427 GB. Dozorca ma wstrzymywac backup, zanim dysk sie zapelni,
  /// wiec musi patrzec na miejsce faktycznie dostepne teraz, a nie na obietnice.
  ///
  /// `nil` znaczy "NIE ZMIERZONO", i to nie jest kosmetyka. Wczesniej nieudany
  /// `statfs` zwracal `0`, czyli liczbe - a wtedy warunek pauzy
  /// (`free <= minFreeGB`) byl spelniony natychmiast, warunek wznowienia
  /// (`free > minFreeGB`) NIGDY, i dozorca wstrzymywal Time Machine na zawsze.
  /// Rownolegle czujka meldowala "Konczy sie miejsce na dysku Maca (0 GB)" -
  /// alarm o stanie, ktorego nikt nie zmierzyl. To samo rozroznienie, ktore
  /// `BufferStatus.queueKnown` wprowadzil juz dla kolejki wysylki.
  public static func freeGB() -> Int? {
    var stats = statfs()
    guard statfs("/System/Volumes/Data", &stats) == 0 else { return nil }
    let available = UInt64(stats.f_bavail) * UInt64(stats.f_bsize)
    return Int(available / 1_073_741_824)
  }

  /// Czy wolno wznowic Time Machine, patrzac WYLACZNIE na pomiary lokalne.
  ///
  /// Czysta funkcja - decyzja da sie sprawdzic testem bez dysku i bez tmutil.
  /// `free == nil` nie wznawia: brak pomiaru to nie jest dowod, ze miejsce
  /// jest. Wznowienie sprawdza wolne miejsce TAK SAMO jak pauza, bo pauza
  /// chroniaca dysk nie moze byc odwolywana przez warunek, ktory o dysku nic
  /// nie wie.
  static func canResumeLocally(buffer: Int, free: Int?, thresholds: Thresholds) -> Bool {
    guard let free else { return false }
    return buffer <= thresholds.lowGB && free > thresholds.minFreeGB
  }

  /// Czy na Dysku Google jest DOWIEDZIONE miejsce na dalsza prace.
  ///
  /// `nil` (rclone nie odpowiedzial) to NIE jest zgoda - patrz `step()`.
  static func driveHasRoom(freeBytes: UInt64?, minGB: Int) -> Bool {
    guard let freeBytes else { return false }
    return freeBytes / 1_073_741_824 >= UInt64(max(0, minGB))
  }

  // MARK: - Jeden krok

  /// Wykonuje jeden krok nadzoru i zwraca stan. Wydzielone z petli, zeby dalo
  /// sie sprawdzic decyzje testem bez czekania w czasie rzeczywistym.
  @discardableResult
  public func step() async -> Snapshot {
    let stats = await probes.queueStats()
    let buffer = Self.bufferGB(stats: stats)
    let free = probes.freeGB()
    let running = await probes.backupRunning()
    let percent = await probes.progressPercent()

    // Nieudany pomiar wolnego miejsca NIE moze przejsc po cichu: od tej liczby
    // zalezy jedyna ochrona dysku przed zapelnieniem, a bez niej dozorca nie
    // wstrzyma Time Machine (i slusznie - nie zgaduje). Czlowiek musi o tym
    // wiedziec z logu, a nie z pelnego dysku.
    if free == nil, !reportedFreeUnknown {
      probes.log(
        "UWAGA: nie da sie zmierzyc wolnego miejsca na dysku (statfs zawiodl) - dozorca nie wstrzyma Time Machine z powodu dysku, bo nie ma na czym oprzec decyzji."
      )
    }
    reportedFreeUnknown = (free == nil)

    // Brak MIEJSCA na Dysku ma pierwszenstwo i nie minie sam: dopoki
    // uzytkownik czegos nie skasuje, wysylka nie ruszy, a dalsza praca
    // Time Machine tylko pompuje bufor.
    if probes.hitStorageQuota() {
      if state != .pausedForQuota {
        await pause(reason: "Brak miejsca na Google Drive", into: .pausedForQuota)
      }
      return Snapshot(
        state: state, bufferGB: buffer, freeGB: free, backupRunning: running, percent: percent)
    }

    // Dobowy limit uploadu to CO INNEGO i celowo NIE wstrzymuje backupu.
    //
    // Zmierzone na dwoch epizodach (12 i 15 wrzesnia 2026): przy zatorze
    // trwajacym kilka godzin bufor ani drgnal - 99-103 GB, dokladnie tyle,
    // co zwykle - a kolejka rozeszla sie sama, gdy okno kroczace 24 h
    // przesunelo sie do przodu. Pauza kosztowalaby wtedy kopie i nie dalaby
    // nic w zamian. Przed zapelnieniem dysku chronia progi ponizej i one
    // dzialaja niezaleznie od tego, co jest przyczyna zatoru.
    //
    // Zglaszamy natomiast ZAWSZE, bo zator z 12 wrzesnia przeszedl zupelnie
    // niezauwazony - trzy godziny bez wysylki i ani jednego sladu poza
    // surowym logiem rclone.
    await probes.reportStall(probes.uploadStalled())

    switch state {
    case .idle:
      // Tylko JAWNE "tak". `nil` (tmutil nie odpowiedzial) zostawia stan bez
      // zmiany - nie zaczynamy nadzoru nad czyms, o czym nic nie wiemy.
      if running == true {
        probes.log("Backup ruszyl - nadzoruje bufor")
        sawBackupRunning = true
        state = .running
      }

    case .running:
      // outOfSpace pochodzi od rclone i znaczy "nie mam juz gdzie odlozyc
      // danych" - to twardszy fakt niz jakikolwiek nasz prog.
      //
      // Brak pomiaru wolnego miejsca (`free == nil`) NIE wstrzymuje backupu.
      // Wczesniej nieudany `statfs` dawal zero, zero spelnialo warunek pauzy
      // i dozorca wstrzymywal Time Machine na podstawie liczby, ktorej nigdy
      // nie zmierzyl - a potem nie umial go wznowic, bo warunek wznowienia
      // przy zerze nie zachodzi nigdy.
      let lowDisk = free.map { $0 <= thresholds.minFreeGB } ?? false
      if stats?.outOfSpace == true || buffer >= thresholds.highGB || lowDisk {
        let why = stats?.outOfSpace == true ? "rclone zglasza brak miejsca w buforze" : "prog"
        await pause(
          reason: "PAUZA (\(why)): bufor \(buffer) GB, wolne \(describe(free)) - czekam na wysylke",
          into: .pausedForBuffer)
      } else if running == false {
        if sawBackupRunning {
          probes.log("Time Machine zakonczyl. Bufor \(buffer) GB")
          sawBackupRunning = false
        }
        state = .idle
      }

    case .pausedForBuffer:
      // Wznawiamy dopiero, gdy wysylka faktycznie nadgonila - inaczej
      // wpadlibysmy w oscylacje start/stop przy progu.
      if Self.canResumeLocally(buffer: buffer, free: free, thresholds: thresholds) {
        await resume(bufferGB: buffer, freeGB: free)
      }

    case .pausedForQuota:
      // Pauza z powodu BRAKU MIEJSCA na Dysku wymaga do zdjecia POZYTYWNEGO
      // dowodu, ze miejsce jest. To nie jest ostroznosc na zapas:
      //
      // `hitStorageQuota()` czyta wpisy z ostatnich 30 minut logu rclone.
      // Po wstrzymaniu Time Machine nowe pasma przestaja powstawac, rclone
      // przestaje probowac wysylac, wpisy sie starzeja i funkcja zaczyna
      // zwracac `false` - mimo ze na Dysku jak nie bylo miejsca, tak nie ma.
      // Przy spokojnym buforze (a po pauzie bufor sie wlasnie oprozni)
      // wspolny warunek wznowienia byl wtedy spelniony natychmiast: dozorca
      // puszczal Time Machine, ten pisal kolejne pasma, ktorych nie ma jak
      // wyslac, i cala pauza konczyla sie po kilkudziesieciu minutach bez
      // zmiany czegokolwiek po stronie Dysku. `UploadState` mowi wprost, ze
      // ten stan NIE mija sam.
      guard Self.canResumeLocally(buffer: buffer, free: free, thresholds: thresholds) else { break }
      let driveFree = await probes.driveFreeBytes()
      guard Self.driveHasRoom(freeBytes: driveFree, minGB: thresholds.minDriveFreeGB) else {
        // Brak odpowiedzi od rclone PODTRZYMUJE pauze - "nie wiem" nigdy nie
        // jest zgoda na wznowienie czegos, co zapelnia dysk.
        if !reportedQuotaHold {
          let ile =
            driveFree.map { "\($0 / 1_073_741_824) GB" } ?? "nie wiadomo (rclone nie odpowiedzial)"
          probes.log(
            "PAUZA (brak miejsca na Dysku) utrzymana: wolne na Google Drive \(ile), wymagane co najmniej \(thresholds.minDriveFreeGB) GB."
          )
          reportedQuotaHold = true
        }
        break
      }
      reportedQuotaHold = false
      await resume(bufferGB: buffer, freeGB: free)
    }

    return Snapshot(
      state: state, bufferGB: buffer, freeGB: free, backupRunning: running, percent: percent)
  }

  public func currentState() -> State { state }

  /// Wolne miejsce do logu. Brak pomiaru MUSI wygladac inaczej niz zero,
  /// inaczej linia w logu klamie tak samo, jak klamala sama liczba.
  private func describe(_ freeGB: Int?) -> String {
    freeGB.map { "\($0) GB" } ?? "nie zmierzono"
  }

  // MARK: - Sterowanie Time Machine

  /// Wstrzymuje Time Machine i przechodzi w `into` TYLKO gdy sie udalo.
  ///
  /// TO jest ta poprawka. Wczesniej wynik `tmutil stopbackup` byl wyrzucany
  /// (`_ = try? await ...`), a stan zmienial sie BEZWARUNKOWO. Gdy polecenie
  /// padalo - brak uprawnien, przekroczony limit czasu - dozorca uznawal pauze
  /// za wykonana, a poniewaz `stopBackup()` wola sie wylacznie przy ZMIANIE
  /// stanu, nie ponawial jej nigdy. Time Machine pisal dalej, dozorca czekal
  /// na drenaz, dysk zapelnial sie do konca, a w logu stalo "PAUZA ... czekam
  /// na wysylke".
  ///
  /// Przy niepowodzeniu stan zostaje na `.running`, wiec warunek pauzy
  /// (nadal spelniony) wyzwoli kolejna probe przy nastepnym tyknieciu - czyli
  /// za 30 sekund, bez zadnego dodatkowego mechanizmu ponawiania.
  private func pause(reason: String, into paused: State) async {
    probes.log(reason)
    if await probes.stopBackup() {
      state = paused
      reportedStopFailure = false
      return
    }
    if !reportedStopFailure {
      probes.log(
        "NIE UDALO SIE wstrzymac Time Machine (tmutil stopbackup). Stan zostaje na '\(state.rawValue)', ponawiam przy kazdym kolejnym sprawdzeniu. Time Machine PISZE DALEJ - dysk moze sie zapelnic."
      )
      reportedStopFailure = true
    }
  }

  /// Wznawia Time Machine.
  ///
  /// Asymetria wzgledem `pause` jest celowa. Nieudane `stopbackup` grozi
  /// zapelnieniem dysku, wiec nie wolno udawac, ze pauza zaszla. Nieudane
  /// `startbackup` nie grozi niczym: Time Machine i tak ruszy sam w swoim
  /// cyklu godzinowym, a `startbackup` jest tylko przyspieszeniem tego.
  /// Gdybysmy przy jego niepowodzeniu zostawali w pauzie, dozorca tkwilby
  /// w stanie, z ktorego jedyne wyjscie wlasnie nie dziala.
  private func resume(bufferGB: Int, freeGB: Int?) async {
    probes.log("WZNOWIENIE: bufor \(bufferGB) GB, wolne \(describe(freeGB))")
    if await probes.startBackup() == false {
      probes.log(
        "tmutil startbackup nie powiodlo sie - Time Machine ruszy sam w swoim cyklu godzinowym.")
    }
    state = .running
  }

  /// Zglasza poczatek i koniec zatoru wysylki - raz na zmiane stanu.
  ///
  /// Stan trzymamy w pliku, a nie w polu, bo `buffer-guard` chodzi pod
  /// launchd z `KeepAlive`: po kazdym wskrzeszeniu procesu pole zaczynaloby
  /// od zera i ten sam zator zglaszalby sie od nowa co 30 sekund.
  static func reportUploadStall(_ stalled: Bool) async {
    let marker = CMPaths.appSupportDir.appendingPathComponent(".upload-stalled")
    let reported = FileManager.default.fileExists(atPath: marker.path)
    guard stalled != reported else { return }

    if stalled {
      let message = "Wysylka na Google Drive stoi - wyczerpany limit dobowy."
      CMLogger.log("\(message) Kopie ida dalej, zator mija sam w kilka godzin.")
      // Znacznik zakladamy DOPIERO po doreczeniu powiadomienia. Zalozony
      // wczesniej zamykal sprawe takze wtedy, gdy powiadomienie nie doszlo -
      // czyli gasil zgloszenie dokladnie w przypadku, dla ktorego istnieje
      // (ten sam blad, co w `HealthAlert.report`, patrz tamtejszy komentarz).
      if await HealthAlert.notify(title: "CloudMachine: wysylka na Dysk stoi", message: message) {
        FileManager.default.createFile(atPath: marker.path, contents: nil)
      } else {
        CMLogger.log(
          "Powiadomienie o zatorze wysylki NIE zostalo doreczone - sprobuje ponownie przy nastepnym sprawdzeniu."
        )
      }
    } else {
      try? FileManager.default.removeItem(at: marker)
      CMLogger.log("Wysylka na Google Drive ruszyla z powrotem.")
    }
  }

  /// Wola `tmutil <polecenie>` i mowi, czy NAPRAWDE sie udalo.
  ///
  /// Najpierw przez `sudo -n`: `tmutil stopbackup` i `startbackup` wymagaja
  /// uprawnien roota, a dozorca chodzi pod launchd w sesji uzytkownika.
  /// Istniejacy `runTmutilUnattended` byl tu nieuzyty, mimo ze powstal
  /// dokladnie do tego. Regula NOPASSWD w `/etc/sudoers.d/cloudmachine` nie
  /// jest przez nic w tym repo zakladana (sprawdzone: zaden instalator jej
  /// nie pisze), wiec `sudo -n` dzis odmawia natychmiast - i wlasnie dlatego
  /// przy odmowie AUTORYZACJI probujemy jeszcze bez sudo, zamiast uznawac
  /// sprawe za przegrana. `isSudoAuthFailure` odroznia "sudo nas nie wpuscilo"
  /// od "polecenie sie wykonalo i zwrocilo blad".
  static func tmutil(_ command: String) async -> Bool {
    if let viaSudo = try? await ProcessRunner.runTmutilUnattended([command], timeout: 120) {
      if viaSudo.succeeded { return true }
      if !viaSudo.isSudoAuthFailure {
        CMLogger.log(
          "sudo tmutil \(command): kod \(viaSudo.exitCode) \(shortError(viaSudo))")
        return false
      }
    }
    guard let direct = try? await ProcessRunner.run("/usr/bin/tmutil", [command], timeout: 120)
    else {
      CMLogger.log("tmutil \(command): BRAK ODPOWIEDZI w limicie czasu.")
      return false
    }
    if !direct.succeeded {
      CMLogger.log("tmutil \(command): kod \(direct.exitCode) \(shortError(direct))")
    }
    return direct.succeeded
  }

  private static func shortError(_ result: ProcessResult) -> String {
    let text = (result.stderr + " " + result.stdout).trimmingCharacters(in: .whitespacesAndNewlines)
    return text.isEmpty ? "(bez komunikatu)" : text.replacingOccurrences(of: "\n", with: " ")
  }
}
