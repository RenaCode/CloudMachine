import Foundation

public struct ProcessResult {
  public var stdout: String
  public var stderr: String
  public var exitCode: Int32
  public var succeeded: Bool { exitCode == 0 }

  /// `true`, jesli to niepowodzenie to `sudo -n` odmawiajace natychmiast z
  /// powodu brakujacej reguly NOPASSWD w sudoers (a NIE realny blad
  /// polecenia, ktore sudo zdazylo faktycznie uruchomic) - odroznia "trzeba
  /// dopisac regule i sprobowac ponownie" od "polecenie i tak zawiedzie
  /// identycznie przy ponownej probie", wiec nie ma sensu prosic uzytkownika
  /// o haslo administratora ani straszyc go w logu/notyfikacji fikcyjnym
  /// problemem z danymi.
  public var isSudoAuthFailure: Bool {
    let text = (stderr + stdout).lowercased()
    return text.contains("a password is required") || text.contains("no tty present")
  }
}

public enum ProcessRunnerError: LocalizedError {
  case launchFailed(String)
  case timedOut(String)

  public var errorDescription: String? {
    switch self {
    case .launchFailed(let msg): return msg
    case .timedOut(let executable):
      return
        "\(executable) nie odpowiedzialo w wyznaczonym czasie (proces zostal osierocony w tle)."
    }
  }
}

/// Chroni `continuation` przed podwojnym wznowieniem - potrzebne, odkad
/// `run(timeout:)` moze "poddac sie" i zwrocic blad, ZANIM proces faktycznie
/// sie zakonczy (patrz komentarz przy `timeout` nizej). Jesli terminationHandler
/// i tak pozniej sie odpali, MUSI juz nic nie robic zamiast wywolac fatal error
/// przez powtorne `continuation.resume`.
private final class ContinuationGuard: @unchecked Sendable {
  private let lock = NSLock()
  private var done = false

  /// Zwraca `true` tylko za PIERWSZYM razem - a wiec "to Ty masz prawo
  /// wznowic continuation", kazde kolejne wywolanie dostaje `false`.
  func claim() -> Bool {
    lock.lock()
    defer { lock.unlock() }
    if done { return false }
    done = true
    return true
  }
}

/// Cienka warstwa nad `Process` do uruchamiania zewnetrznych narzedzi
/// (rclone, tmutil, hdiutil, diskutil...) - dzielona przez GUI i CLI. Wczesniej
/// zyla wylacznie w GUI jako `Shell.run`; przeniesiona tu, zeby watchdogi CLI
/// mialy dokladnie te sama, juz sprawdzona semantyke timeoutu.
public enum ProcessRunner {
  public static func run(
    _ executable: String, _ args: [String], env: [String: String] = [:],
    timeout: TimeInterval? = nil
  ) async throws -> ProcessResult {
    try await withCheckedThrowingContinuation { continuation in
      let process = Process()
      process.executableURL = URL(fileURLWithPath: executable)
      process.arguments = args

      var fullEnv = ProcessInfo.processInfo.environment
      // Homebrew na Apple Silicon instaluje do /opt/homebrew/bin - dorzucamy na wszelki wypadek.
      fullEnv["PATH"] =
        "/opt/homebrew/bin:/usr/local/bin:" + (fullEnv["PATH"] ?? "/usr/bin:/bin:/usr/sbin:/sbin")
      for (k, v) in env { fullEnv[k] = v }
      process.environment = fullEnv

      let stdoutPipe = Pipe()
      let stderrPipe = Pipe()
      process.standardOutput = stdoutPipe
      process.standardError = stderrPipe
      process.standardInput = FileHandle.nullDevice

      let queue = DispatchQueue(label: "com.renacode.cloudmachine.process-pipe")
      var stdoutData = Data()
      var stderrData = Data()
      let resumeGuard = ContinuationGuard()

      stdoutPipe.fileHandleForReading.readabilityHandler = { handle in
        let data = handle.availableData
        if !data.isEmpty {
          queue.async { stdoutData.append(data) }
        }
      }
      stderrPipe.fileHandleForReading.readabilityHandler = { handle in
        let data = handle.availableData
        if !data.isEmpty {
          queue.async { stderrData.append(data) }
        }
      }

      process.terminationHandler = { proc in
        stdoutPipe.fileHandleForReading.readabilityHandler = nil
        stderrPipe.fileHandleForReading.readabilityHandler = nil

        // WAZNE: NIE wolno tu wolac readDataToEndOfFile() - blokuje sie do
        // zamkniecia pisania konca potoku przez WSZYSTKICH jego posiadaczy.
        // Procesy odpalane z "--daemon" (np. `rclone nfsmount --daemon`)
        // forkuja dziecko, ktore dziedziczy te same FD stdout/stderr i NIGDY
        // ich nie zamyka - terminationHandler natychmiastowego procesu-rodzica
        // odpala sie normalnie, ale readDataToEndOfFile() wisi wtedy w
        // nieskonczonosc, bo EOF nigdy nie nadejdzie (zaobserwowane realnie:
        // watchdog zawieszony na >10 min po kazdym swiezym starcie rclone).
        // `readabilityHandler` juz i tak zbiera wszystko na biezaco w miare
        // nadchodzenia danych - nie potrzeba dodatkowego, blokujacego dobicia.
        queue.async {
          let result = ProcessResult(
            stdout: String(data: stdoutData, encoding: .utf8) ?? "",
            stderr: String(data: stderrData, encoding: .utf8) ?? "",
            exitCode: proc.terminationStatus
          )
          if resumeGuard.claim() {
            continuation.resume(returning: result)
          }
        }
      }

      do {
        try process.run()
      } catch {
        if resumeGuard.claim() {
          continuation.resume(
            throwing: ProcessRunnerError.launchFailed(
              "Nie mozna uruchomic \(executable): \(error.localizedDescription)"))
        }
        return
      }

      if let timeout {
        DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
          if process.isRunning {
            process.terminate()
          }
        }
        // Eskalacja do SIGKILL, jesli proces zignoruje SIGTERM - patrz
        // uzasadnienie przy tym samym mechanizmie w dawnym Shell.swift
        // (zawieszony potomny diskutil/umount ignoruje SIGTERM bez konca).
        DispatchQueue.global().asyncAfter(deadline: .now() + timeout + 5) {
          if process.isRunning {
            kill(process.processIdentifier, SIGKILL)
          }
        }
        // WAZNE: SIGKILL NIE dziala na proces zawieszony w jadrze w
        // nieprzerywalnym oczekiwaniu (stan "U" w `ps`, np. hdiutil/
        // diskimages-helper czekajacy na I/O przez martwy/wolny NFS -
        // zaobserwowane realnie na zywo). Bez tej ostatecznej granicy
        // `timeout` NIE bylby prawdziwym gornym ograniczeniem czasu
        // oczekiwania, wbrew temu co sugeruje parametr - `continuation`
        // czekalaby w nieskonczonosc na `terminationHandler`, ktory nigdy by
        // sie nie odpalil. Tutaj poddajemy sie i zwracamy blad zamiast
        // wisiec; proces zostaje osierocony w tle (nieszkodliwie - kiedys
        // sam dokonczy, gdy jadro w koncu dostanie odpowiedz, a
        // `resumeGuard` zapobiegnie podwojnemu wznowieniu, jesli
        // `terminationHandler` odpali sie pozniej).
        DispatchQueue.global().asyncAfter(deadline: .now() + timeout + 10) {
          if resumeGuard.claim() {
            // WAZNE: NIE zerujemy handlera do `nil` - to zostawia potok bez
            // ZADNEGO czytelnika. Jesli proces przetrwal nawet SIGKILL
            // (zawieszony w jadrze w nieprzerywalnym I/O - patrz komentarz
            // wyzej) i kiedys jednak wznowi dzialanie, dalej moze pisac do
            // stdout/stderr; bez czytelnika zapelniony bufor potoku
            // zablokowalby go na `write()` NA ZAWSZE, zamieniajac
            // "niegrozny osierocony proces" w trwale zawieszony zombie,
            // ktory nigdy nie zostanie sprzatniety. Podmieniamy wiec handler
            // na taki, ktory nadal drenuje i odrzuca dane - wynik i tak juz
            // nie zostanie odczytany (continuation ponizej wznawia sie
            // bledem timeoutu), ale osierocony proces moze swobodnie
            // dokonczyc zapis i zakonczyc sie samodzielnie.
            stdoutPipe.fileHandleForReading.readabilityHandler = { handle in
              _ = handle.availableData
            }
            stderrPipe.fileHandleForReading.readabilityHandler = { handle in
              _ = handle.availableData
            }
            continuation.resume(throwing: ProcessRunnerError.timedOut(executable))
          }
        }
      }
    }
  }

  /// Uruchamia `rclone` przez `/usr/bin/env`, zeby dzialalo niezaleznie od
  /// tego, czy Homebrew zainstalowal je do /opt/homebrew/bin czy /usr/local/bin.
  public static func runRclone(_ args: [String], timeout: TimeInterval? = nil) async throws
    -> ProcessResult
  {
    try await run("/usr/bin/env", ["rclone"] + args, timeout: timeout)
  }

  /// Uruchamia `tmutil` przez `sudo -n` (bez pytania o haslo) - wymaga
  /// wczesniej skonfigurowanej reguly NOPASSWD w /etc/sudoers.d/cloudmachine
  /// (patrz LaunchdInstaller/DependencyInstaller). Uzywane przez watchdogi
  /// dzialajace bez sesji GUI (nie moga pokazac dialogu autoryzacji).
  public static func runTmutilUnattended(_ args: [String], timeout: TimeInterval? = nil)
    async throws -> ProcessResult
  {
    try await run("/usr/bin/sudo", ["-n", "/usr/bin/tmutil"] + args, timeout: timeout)
  }

  public static func isProcessRunning(pid: pid_t) -> Bool {
    kill(pid, 0) == 0
  }
}
