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
      minFreeGB: Int = 80
    ) {
      self.highGB = highGB
      self.lowGB = lowGB
      self.minFreeGB = minFreeGB
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
    public var freeGB: Int
    public var backupRunning: Bool
    public var percent: Double
  }

  private let thresholds: Thresholds
  private var state: State = .idle
  /// Czy od ostatniego przejscia w czuwanie widzielismy dzialajacy backup -
  /// zeby zameldowac zakonczenie raz, a nie przy kazdym tyknieciu.
  private var sawBackupRunning = false

  public init(thresholds: Thresholds = Thresholds()) {
    self.thresholds = thresholds
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
  public static func freeGB() -> Int {
    var stats = statfs()
    guard statfs("/System/Volumes/Data", &stats) == 0 else { return 0 }
    let available = UInt64(stats.f_bavail) * UInt64(stats.f_bsize)
    return Int(available / 1_073_741_824)
  }

  // MARK: - Jeden krok

  /// Wykonuje jeden krok nadzoru i zwraca stan. Wydzielone z petli, zeby dalo
  /// sie sprawdzic decyzje testem bez czekania w czasie rzeczywistym.
  @discardableResult
  public func step() async -> Snapshot {
    let stats = await DriveBufferService.queueStats()
    let buffer = Self.bufferGB(stats: stats)
    let free = Self.freeGB()
    let running = await TimeMachineStatus.isRunning()
    let percent = (await TimeMachineStatus.currentProgress())?.percent ?? 0

    // Brak MIEJSCA na Dysku ma pierwszenstwo i nie minie sam: dopoki
    // uzytkownik czegos nie skasuje, wysylka nie ruszy, a dalsza praca
    // Time Machine tylko pompuje bufor.
    if DriveBufferService.hitStorageQuota() {
      if state != .pausedForQuota {
        CMLogger.log("Brak miejsca na Google Drive - wstrzymuje Time Machine")
        await stopBackup()
        state = .pausedForQuota
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
    await reportUploadStall(DriveBufferService.uploadStalled())

    switch state {
    case .idle:
      if running {
        CMLogger.log("Backup ruszyl - nadzoruje bufor")
        sawBackupRunning = true
        state = .running
      }

    case .running:
      // outOfSpace pochodzi od rclone i znaczy "nie mam juz gdzie odlozyc
      // danych" - to twardszy fakt niz jakikolwiek nasz prog.
      if stats?.outOfSpace == true || buffer >= thresholds.highGB || free <= thresholds.minFreeGB {
        let why = stats?.outOfSpace == true ? "rclone zglasza brak miejsca w buforze" : "prog"
        CMLogger.log("PAUZA (\(why)): bufor \(buffer) GB, wolne \(free) GB - czekam na wysylke")
        await stopBackup()
        state = .pausedForBuffer
      } else if !running {
        if sawBackupRunning {
          CMLogger.log("Time Machine zakonczyl. Bufor \(buffer) GB")
          sawBackupRunning = false
        }
        state = .idle
      }

    case .pausedForBuffer, .pausedForQuota:
      // Wznawiamy dopiero, gdy wysylka faktycznie nadgonila - inaczej
      // wpadlibysmy w oscylacje start/stop przy progu.
      //
      // Wolne miejsce sprawdzamy TAK SAMO jak przy pauzie. Wczesniej warunek
      // wznowienia patrzyl wylacznie na bufor: dozorca, ktory wstrzymal backup
      // z powodu konczacego sie dysku, wznawial go, gdy tylko bufor zszedl
      // ponizej progu - czyli przy dysku nadal pelnym. Pauza chroniaca dysk
      // nie moze byc odwolywana przez warunek, ktory o dysku nic nie wie.
      if buffer <= thresholds.lowGB && free > thresholds.minFreeGB {
        CMLogger.log("WZNOWIENIE: bufor \(buffer) GB, wolne \(free) GB")
        await startBackup()
        state = .running
      }
    }

    return Snapshot(
      state: state, bufferGB: buffer, freeGB: free, backupRunning: running, percent: percent)
  }

  public func currentState() -> State { state }

  // MARK: - Sterowanie Time Machine

  /// Zglasza poczatek i koniec zatoru wysylki - raz na zmiane stanu.
  ///
  /// Stan trzymamy w pliku, a nie w polu, bo `buffer-guard` chodzi pod
  /// launchd z `KeepAlive`: po kazdym wskrzeszeniu procesu pole zaczynaloby
  /// od zera i ten sam zator zglaszalby sie od nowa co 30 sekund.
  private func reportUploadStall(_ stalled: Bool) async {
    let marker = CMPaths.appSupportDir.appendingPathComponent(".upload-stalled")
    let reported = FileManager.default.fileExists(atPath: marker.path)
    guard stalled != reported else { return }

    if stalled {
      FileManager.default.createFile(atPath: marker.path, contents: nil)
      let message = "Wysylka na Google Drive stoi - wyczerpany limit dobowy."
      CMLogger.log("\(message) Kopie ida dalej, zator mija sam w kilka godzin.")
      await HealthAlert.notify(title: "CloudMachine: wysylka na Dysk stoi", message: message)
    } else {
      try? FileManager.default.removeItem(at: marker)
      CMLogger.log("Wysylka na Google Drive ruszyla z powrotem.")
    }
  }

  private func stopBackup() async {
    _ = try? await ProcessRunner.run("/usr/bin/tmutil", ["stopbackup"], timeout: 120)
  }

  private func startBackup() async {
    _ = try? await ProcessRunner.run("/usr/bin/tmutil", ["startbackup"], timeout: 120)
  }
}
