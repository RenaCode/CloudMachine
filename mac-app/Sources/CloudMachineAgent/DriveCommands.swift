import ArgumentParser
import CloudMachineCore
import Foundation

/// Podkomendy warstwy Google Drive. Zastepuja skrypty z `gdrive/` - launchd
/// i GUI wolaja odtad wylacznie te binarke, nie powloke.

// MARK: - Bufor

struct MountDrive: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "mount-drive",
    abstract: "Montuje Google Drive z buforem zapisu. Zostaje na pierwszym planie (dla launchd).")

  func run() async throws {
    if DriveBufferService.isMounted {
      print("Juz zamontowane: \(DriveBufferService.mountPoint.path)")
      return
    }

    // Deinstalator FUSE-T kasuje cala zawartosc /usr/local/lib pod swoja
    // sciezka, w tym nasze dowiazanie - odtwarzamy je, zanim cokolwiek sprawdzimy.
    FuseInstaller.ensureSystemLink()

    // Bez FUSE rclone konczy natychmiast bledem "cgofuse: cannot find FUSE".
    // Agent ma KeepAlive, wiec probowalby w kolko co 30 s i zalewal log -
    // lepiej stanac od razu i powiedziec, czego brakuje.
    let readiness = CMTooling.checkReadiness()
    guard readiness.ready else {
      for (what, how) in zip(readiness.missing, readiness.remedies) {
        FileHandle.standardError.write(Data("Brakuje: \(what)\n  \(how)\n".utf8))
      }
      throw ExitCode(1)
    }

    await DriveBufferService.excludeBufferFromTimeMachine()
    let args = try DriveBufferService.prepare()

    // Nasza kopia serwera NFS, jesli jest - wtedy osobna instalacja FUSE-T
    // w systemie nie jest potrzebna.
    if FileManager.default.isExecutableFile(atPath: CMTooling.bundledNfsServer.path) {
      setenv("FUSE_NFSSRV_PATH", CMTooling.bundledNfsServer.path, 1)
    }

    // Podmieniamy sie na rclone zamiast go nadzorowac: launchd ma pilnowac
    // procesu, ktory faktycznie trzyma montowanie, a nie posrednika.
    let rclone = CMTooling.managedRclonePath.path
    var argv: [UnsafeMutablePointer<CChar>?] = ([rclone] + args).map { strdup($0) }
    argv.append(nil)
    execv(rclone, &argv)

    FileHandle.standardError.write(Data("Nie udalo sie uruchomic \(rclone)\n".utf8))
    throw ExitCode(1)
  }
}

// MARK: - Obraz backupu

struct CreateImage: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "create-image",
    abstract: "Tworzy obraz backupu na Google Drive. Jednorazowo.")

  @Option(name: .long, help: "Rozmiar deklarowany w GB (obraz jest rzadki).")
  var sizeGB: Int = 4000

  func run() async throws {
    let result = await BackupImageService.create(sizeGB: sizeGB)
    print(result.message)
    if result.succeeded {
      print("Nastepny krok: cloudmachine-agent attach-image, potem")
      print("  sudo tmutil setdestination \(BackupImageService.targetPath.path)")
    } else {
      throw ExitCode(1)
    }
  }
}

struct AttachImage: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "attach-image",
    abstract: "Podpina obraz backupu jako cel Time Machine.")

  func run() async throws {
    // Time Machine nie moze zobaczyc celu, zanim bufor bedzie gotowy - inaczej
    // uzna, ze dysk backupu zniknal. Ile czekamy i na co dokladnie - patrz
    // `BufferReadiness`.
    let ready = await BufferReadiness.wait(
      sleep: { seconds in
        try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
      },
      probe: {
        BufferReadiness.isReady(
          mounted: DriveBufferService.isMounted,
          imageVisible: BackupImageService.exists)
      })
    if !ready {
      print(
        """
        Bufor nie stanal w \(Int(BufferReadiness.defaultTimeout / 60)) min - nie podpinam obrazu.
        Time Machine jest teraz BEZ CELU. Sprawdz: cloudmachine-agent drive-status
        """)
      throw ExitCode(1)
    }
    let result = await BackupImageService.attach()
    print(result.message)
    if !result.succeeded { throw ExitCode(1) }
  }
}

struct DetachImage: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "detach-image",
    abstract: "Odpina obraz i czeka, az wszystko doleci na Google Drive.")

  @Flag(name: .long, help: "Nie czekaj na wysylke - RYZYKOWNE, patrz BackupImageService.detach.")
  var noWait = false

  func run() async throws {
    let result = await BackupImageService.detach(waitForUpload: !noWait)
    print(result.message)
    if !result.succeeded { throw ExitCode(1) }
  }
}

struct VerifyImage: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "verify-image",
    abstract:
      "Sprawdza spojnosc obrazu przez fsck_apfs (hdiutil verify na sparsebundle nie dziala).")

  func run() async throws {
    let result = await BackupImageService.verify()
    print(result.message)
    if !result.succeeded { throw ExitCode(1) }
  }
}

// MARK: - Dozorca bufora

struct BufferGuard: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "buffer-guard",
    abstract: "Wstrzymuje Time Machine, gdy bufor rosnie szybciej, niz idzie wysylka.")

  // Domyslne progi bierzemy Z `Thresholds`, ktore wylicza je z rozmiaru
  // bufora - NIE wpisujemy ich tu po raz drugi z palca.
  //
  // Wpisane liczby (150/40/80) zgadzaly sie z wyliczonymi tylko przypadkiem,
  // dla bufora 100 GB. launchd uruchamia `buffer-guard` BEZ argumentow, wiec
  // to wlasnie te literaly trafialy na produkcje - wyliczanie progow
  // z `cacheSizeGB` bylo w praktyce martwe, a trzy testy pilnujace tego
  // wyliczenia sprawdzaly `Thresholds()` bezposrednio i przechodzily, nie
  // dotykajac sciezki, ktora naprawde dziala. Po zmianie `cacheSizeGB` progi
  // rozjechalyby sie po cichu: dozorca albo wstrzymywalby backup bez przerwy,
  // albo nie wstrzymalby go nigdy.
  @Option(name: .long, help: "Powyzej tylu GB bufora wstrzymujemy Time Machine.")
  var highGB: Int = BufferGuardService.Thresholds().highGB

  @Option(name: .long, help: "Ponizej tylu GB bufora wznawiamy.")
  var lowGB: Int = BufferGuardService.Thresholds().lowGB

  @Option(name: .long, help: "Ponizej tylu GB wolnych na dysku wstrzymujemy niezaleznie od bufora.")
  var minFreeGB: Int = BufferGuardService.Thresholds().minFreeGB

  @Option(name: .long, help: "Co ile sekund sprawdzac.")
  var interval: Int = 30

  func run() async throws {
    let guardService = BufferGuardService(
      thresholds: .init(highGB: highGB, lowGB: lowGB, minFreeGB: minFreeGB))
    CMLogger.log(
      "Dozorca bufora: prog \(highGB) GB / wznowienie \(lowGB) GB / min. wolnego \(minFreeGB) GB")

    // Bez konca: dozorca ma przezyc kazdy backup, nie tylko pierwszy.
    while true {
      await guardService.step()
      try? await Task.sleep(nanoseconds: UInt64(interval) * 1_000_000_000)
    }
  }
}

// MARK: - Czujka cyklu backupu

struct BackupHealthCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "backup-health",
    abstract:
      "Sprawdza, czy cykl godzinowy NADAL dziala (data ostatniej UDANEJ kopii), i zglasza awarie.")

  @Option(name: .long, help: "Po tylu godzinach bez udanej kopii uznajemy cykl za zerwany.")
  var maxAgeHours: Double = BackupHealth.maxAgeHours

  @Flag(name: .long, help: "Tylko wypisz stan, bez powiadomienia systemowego.")
  var quiet = false

  @Option(
    name: .long,
    help: "Inny plik preferencji Time Machine - do sprawdzenia czujki na znanej probce.")
  var preferences: String = BackupHealth.preferencesPath

  func run() async throws {
    let report = await BackupHealth.currentReport(
      maxAgeHours: maxAgeHours, preferencesFile: preferences)

    if let lastSuccess = report.lastSuccess {
      print("Ostatnia udana kopia: \(BackupHealth.stamp(lastSuccess))")
    } else {
      print("Ostatnia udana kopia: BRAK")
    }
    if let lastAttempt = report.lastAttempt {
      print("Ostatnia proba:       \(BackupHealth.stamp(lastAttempt))")
    }

    guard !report.healthy else {
      print("Cykl backupu: OK")
      if !quiet { await HealthAlert.report(report) }
      return
    }

    for problem in report.problems {
      print("AWARIA: \(problem.summary)")
      print("        \(problem.detail)")
    }
    if !quiet { await HealthAlert.report(report) }

    // Niezerowy kod wyjscia, zeby launchd, `&&` w skrypcie i czlowiek
    // patrzacy na `echo $?` dostali ten sam sygnal co tekst powyzej.
    throw ExitCode(1)
  }
}

// MARK: - Bezpieczne wygaszenie

struct PrepareShutdown: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "prepare-shutdown",
    abstract: "Przygotowuje do restartu: wstrzymuje backup, odpina obraz i czeka na wysylke.")

  func run() async throws {
    // Kolejnosc nie jest dowolna. Najpierw Time Machine przestaje dokladac
    // nowych zapisow, dopiero potem odpinamy obraz - inaczej odpiecie
    // walczyloby z trwajacym backupem.
    if await TimeMachineStatus.isRunning() {
      print("Wstrzymuje backup...")
      _ = try? await ProcessRunner.run("/usr/bin/tmutil", ["stopbackup"], timeout: 120)
      try? await Task.sleep(nanoseconds: 3_000_000_000)
    }

    print("Odpinam obraz i czekam na wysylke...")
    let result = await BackupImageService.detach()
    print(result.message)

    guard result.succeeded else {
      print("")
      print("NIE RESTARTUJ jeszcze - w buforze sa dane, ktore nie doleciely na Dysk.")
      print("Sprawdz stan:  cloudmachine-agent drive-status")
      throw ExitCode(1)
    }

    print("")
    print("Mozna restartowac. Po starcie agenty podniosa bufor i podepna obraz same.")
  }
}

// MARK: - Stan

struct DriveStatus: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "drive-status",
    abstract: "Stan bufora, kolejki wysylki i Time Machine.")

  func run() async throws {
    let readiness = CMTooling.checkReadiness()
    print(
      "Narzedzia:        \(readiness.ready ? "OK" : "brakuje: " + readiness.missing.joined(separator: ", "))"
    )
    print("Montowanie Drive: \(DriveBufferService.isMounted ? "OK" : "BRAK")")
    print(
      "Obraz podpiety:   \(BackupImageService.isAttached ? "OK  (\(BackupImageService.targetPath.path))" : "BRAK")"
    )
    print("Bufor:            \(BufferGuardService.bufferGB()) GB z \(DriveBufferService.cacheSize)")
    print("Wolne na dysku:   \(BufferGuardService.freeGB()) GB")

    let queueStats = await DriveBufferService.queueStats()
    if let stats = queueStats {
      print(
        "Kolejka wysylki:  \(stats.uploadsInProgress) w toku, \(stats.uploadsQueued) w kolejce, \(stats.erroredFiles) bledow"
      )
    } else {
      print("Kolejka wysylki:  (interfejs rc nieosiagalny)")
    }

    let safe = await BackupImageService.safeToRebootNow()
    print(
      "Restart bez pytania: \(safe ? "TAK - kolejka pusta" : "NIE - najpierw prepare-shutdown")")

    // Ta sama odpowiedz, co na karcie w interfejsie - jedno zrodlo, zeby CLI
    // i GUI nie mogly twierdzic czegos innego o tym samym stanie.
    let upload = UploadState.from(
      mounted: DriveBufferService.isMounted,
      queued: queueStats?.uploadsQueued ?? 0,
      inProgress: queueStats?.uploadsInProgress ?? 0,
      failedFiles: queueStats?.erroredFiles ?? 0,
      bufferOutOfSpace: queueStats?.outOfSpace ?? false,
      driveFull: DriveBufferService.hitStorageQuota(),
      dailyQuotaExhausted: DriveBufferService.uploadStalled())
    print("Wysylka:          \(upload.headline)")
    if !upload.isNominal {
      print("                  \(upload.explanation.replacingOccurrences(of: "\n", with: " "))")
    }

    if let mountPoint = await TimeMachineStatus.currentDestinationMountPoint() {
      print("Cel Time Machine: \(mountPoint)")
    } else {
      print("Cel Time Machine: brak")
    }
    if await TimeMachineStatus.isRunning(), let progress = await TimeMachineStatus.currentProgress()
    {
      let percent = (progress.percent ?? 0) * 100
      print(
        "Backup:           trwa, \(String(format: "%.1f", percent))% (\(progress.phase ?? "?"))")
    } else {
      print("Backup:           nie trwa")
    }
  }
}

// MARK: - Instalacja FUSE

struct InstallFuse: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "install-fuse",
    abstract: "Wciaga FUSE-T do CloudMachine, zeby nie bylo osobnej aplikacji w systemie.")

  func run() async throws {
    let result = await FuseInstaller.install()
    print(result.message)
    if !result.succeeded { throw ExitCode(1) }
  }
}

// MARK: - Instalacja rclone

struct InstallRclone: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "install-rclone",
    abstract: "Pobiera oficjalna binarke rclone (ta z Homebrew nie umie montowac).")

  func run() async throws {
    let result = await RcloneInstaller.install()
    print(result.message)
    if !result.succeeded { throw ExitCode(1) }
  }
}

// MARK: - Wersja

/// Odpowiada na pytanie "czy dziala to, co w repozytorium".
///
/// Samo `1.1.0` na to nie odpowiada - dlatego wypisujemy commit i stan drzewa
/// z chwili budowania, a przy braku bundla mowimy wprost, ze to build z drzewa
/// roboczego, zamiast zmyslac numer.
struct Version: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "version",
    abstract: "Wypisuje wersje, numer budowy i commit, z ktorego zbudowano te binarke.")

  @Flag(name: .long, help: "Tylko jedna linia, bez opisu.")
  var short = false

  func run() async throws {
    guard let version = AppVersionReader.current() else {
      print("Build z drzewa roboczego (poza bundlem) - brak danych o wersji.")
      return
    }
    guard !short else {
      print(version.summary)
      return
    }
    print("Wersja:  \(version.shortVersion)")
    print("Budowa:  \(version.build)")
    print("Commit:  \(version.commit)")
    if version.dirty {
      print("")
      print("UWAGA: zbudowano z BRUDNEGO drzewa - w binarce jest kod, ktorego")
      print("       nie ma w zadnym commicie. Numer commitu NIE opisuje tego,")
      print("       co naprawde dziala.")
    }
  }
}
