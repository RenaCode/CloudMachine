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

    public init(highGB: Int = 150, lowGB: Int = 40, minFreeGB: Int = 80) {
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

  public static func bufferGB() -> Int {
    Int(DriveBufferService.cacheSizeBytes() / 1_073_741_824)
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
    let buffer = Self.bufferGB()
    let free = Self.freeGB()
    let running = await TimeMachineStatus.isRunning()
    let percent = (await TimeMachineStatus.currentProgress())?.percent ?? 0

    // Limit dobowy ma pierwszenstwo: dopoki sie nie odnowi, wysylka nie ruszy,
    // wiec pozwolenie Time Machine na dalsza prace tylko napompuje bufor.
    if DriveBufferService.hitDailyQuota() {
      if state != .pausedForQuota {
        CMLogger.log("Dobowy limit uploadu Google Drive wyczerpany - wstrzymuje Time Machine")
        await stopBackup()
        state = .pausedForQuota
      }
      return Snapshot(
        state: state, bufferGB: buffer, freeGB: free, backupRunning: running, percent: percent)
    }

    switch state {
    case .idle:
      if running {
        CMLogger.log("Backup ruszyl - nadzoruje bufor")
        sawBackupRunning = true
        state = .running
      }

    case .running:
      if buffer >= thresholds.highGB || free <= thresholds.minFreeGB {
        CMLogger.log("PAUZA: bufor \(buffer) GB, wolne \(free) GB - czekam na wysylke")
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
      if buffer <= thresholds.lowGB {
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

  private func stopBackup() async {
    _ = try? await ProcessRunner.run("/usr/bin/tmutil", ["stopbackup"], timeout: 120)
  }

  private func startBackup() async {
    _ = try? await ProcessRunner.run("/usr/bin/tmutil", ["startbackup"], timeout: 120)
  }
}
