import CloudMachineCore
import Foundation
import SwiftUI

/// Laczy interfejs z serwisami w `CloudMachineCore`. Sam nie zawiera logiki
/// backupu - to, co wie o Google Drive, obrazie i buforze, siedzi w serwisach,
/// zeby CLI i GUI robily dokladnie to samo.
@MainActor
final class CloudMachineController: ObservableObject {
  let status = AppStatus()

  private var refreshTask: Task<Void, Never>?
  private var lastBytesDone: Double?
  private var lastBytesSampledAt: Date?

  // MARK: - Cykl odswiezania

  func startAutoRefresh(interval: TimeInterval = 10) {
    refreshTask?.cancel()
    refreshTask = Task { [weak self] in
      while !Task.isCancelled {
        await self?.refreshAll()
        try? await Task.sleep(nanoseconds: UInt64(interval) * 1_000_000_000)
      }
    }
  }

  func stopAutoRefresh() {
    refreshTask?.cancel()
    refreshTask = nil
  }

  func refreshAll() async {
    await refreshDependencies()
    await refreshBuffer()
    await refreshTimeMachine()
    await refreshProgress()
    status.lastRefresh = Date()
    // Logu NIE czytamy w cyklu odswiezania - jest od tego osobna zakladka,
    // ktora wola refreshLogTail() sama, gdy jest widoczna. Czytanie pliku co
    // kilka sekund w tle tylko po to, zeby nikt na to nie patrzyl, jest
    // marnotrawstwem.
  }

  // MARK: - Poszczegolne odczyty

  private func refreshDependencies() async {
    let readiness = CMTooling.checkReadiness()
    status.dependencyState =
      readiness.ready ? .ready : .missing(readiness.missing, readiness.remedies)
    status.remoteConfigured = await RemoteConfigurer.isConfigured(
      remoteName: DriveBufferService.remoteName)
    status.hasFullDiskAccess = FileManager.default.isReadableFile(
      atPath: NSHomeDirectory() + "/Library/Application Support/com.apple.TCC")
  }

  private func refreshBuffer() async {
    let stats = await DriveBufferService.queueStats()
    var buffer = BufferStatus()
    buffer.mounted = DriveBufferService.isMounted
    buffer.imageAttached = BackupImageService.isAttached
    // Rozmiar bufora bierzemy od rclone; wlasny obchod katalogu to 6504
    // wywolania stat co 10 sekund na dysku, na ktory leci backup.
    buffer.sizeGB = BufferGuardService.bufferGB(stats: stats)
    buffer.freeDiskGB = BufferGuardService.freeGB()
    buffer.dailyQuotaHit = DriveBufferService.hitDailyQuota()
    if let stats {
      buffer.uploadsQueued = stats.uploadsQueued
      buffer.uploadsInProgress = stats.uploadsInProgress
      buffer.erroredFiles = stats.erroredFiles
      buffer.outOfSpace = stats.outOfSpace
    }
    status.buffer = buffer
  }

  private func refreshTimeMachine() async {
    guard let mountPoint = await TimeMachineStatus.currentDestinationMountPoint() else {
      status.timeMachineState = .notRegistered
      return
    }
    // Cel moze istniec, ale wskazywac gdzie indziej - wtedy backupu na Drive
    // nie ma, mimo ze Time Machine wyglada na skonfigurowany.
    status.timeMachineState =
      mountPoint == BackupImageService.targetPath.path
      ? .registered(mountPoint: mountPoint) : .notRegistered
  }

  private func refreshProgress() async {
    guard await TimeMachineStatus.isRunning(),
      let progress = await TimeMachineStatus.currentProgress()
    else {
      status.backupProgress = nil
      lastBytesDone = nil
      lastBytesSampledAt = nil
      return
    }

    var info = BackupProgressInfo(
      phase: progress.phase, percent: progress.percent, bytesDone: progress.bytes,
      bytesTotal: progress.totalBytes, filesDone: progress.files, filesTotal: progress.totalFiles,
      timeRemainingSeconds: progress.timeRemainingSeconds)

    // tmutil nie podaje tempa - liczymy je z roznicy miedzy odczytami.
    if let bytes = progress.bytes, let previous = lastBytesDone, let at = lastBytesSampledAt {
      let seconds = Date().timeIntervalSince(at)
      if seconds > 0, bytes >= previous {
        info.transferRateMBs = (bytes - previous) / seconds / 1_048_576
      }
    }
    lastBytesDone = progress.bytes
    lastBytesSampledAt = Date()
    status.backupProgress = info
  }

  func refreshLogTail() {
    guard let handle = try? FileHandle(forReadingFrom: CMPaths.combinedLogFile) else { return }
    defer { try? handle.close() }
    let size = (try? handle.seekToEnd()) ?? 0
    let window: UInt64 = 16 * 1024
    try? handle.seek(toOffset: size > window ? size - window : 0)
    if let data = try? handle.readToEnd(), let text = String(data: data, encoding: .utf8) {
      status.logTail = text
    }
  }

  // MARK: - Akcje

  func installRclone() async {
    await run("Instaluje rclone") { await RcloneInstaller.install() }
  }

  /// Polaczenie z Google Drive robi sie z terminala, nie z GUI: OAuth otwiera
  /// przegladarke i czeka na zatwierdzenie, a klucze czytamy z Keychaina.
  var connectDriveCommand: String {
    "\(CMPaths.agentBinaryPath?.path ?? "cloudmachine-agent") configure-remote"
  }

  func createImage(sizeGB: Int) async {
    await run("Tworze obraz backupu") { await BackupImageService.create(sizeGB: sizeGB) }
  }

  func attachImage() async {
    await run("Podpinam obraz") { await BackupImageService.attach() }
  }

  func verifyImage() async {
    await run("Sprawdzam spojnosc obrazu") { await BackupImageService.verify() }
  }

  func installAgents() async {
    await run("Instaluje agentow launchd") { await LaunchdInstaller.install() }
  }

  func startBackup() async {
    await run("Uruchamiam backup") {
      let result = try? await ProcessRunner.run("/usr/bin/tmutil", ["startbackup"], timeout: 60)
      return CMActionResult(
        succeeded: result?.succeeded == true,
        message: result?.succeeded == true
          ? "Backup uruchomiony." : "Nie udalo sie uruchomic backupu.")
    }
  }

  func stopBackup() async {
    await run("Wstrzymuje backup") {
      let result = try? await ProcessRunner.run("/usr/bin/tmutil", ["stopbackup"], timeout: 60)
      return CMActionResult(
        succeeded: result?.succeeded == true,
        message: result?.succeeded == true
          ? "Backup wstrzymany." : "Nie udalo sie wstrzymac backupu.")
    }
  }

  /// Polecenie, ktore uzytkownik musi wkleic sam - `tmutil setdestination`
  /// wymaga roota, a aplikacja nie ma reguly sudoers.
  var setDestinationCommand: String {
    "sudo tmutil setdestination '\(BackupImageService.targetPath.path)'"
  }

  // MARK: - Wspolna obsluga akcji

  private func run(_ label: String, _ action: () async -> CMActionResult) async {
    status.isBusy = true
    status.busyLabel = label
    status.errorMessage = nil
    defer {
      status.isBusy = false
      status.busyLabel = ""
    }

    let result = await action()
    status.lastAction = LastRunResult(
      succeeded: result.succeeded, message: result.message, date: Date())
    if !result.succeeded { status.errorMessage = result.message }
    CMLogger.log("[gui] \(label): \(result.message)")
    await refreshAll()
  }
}
