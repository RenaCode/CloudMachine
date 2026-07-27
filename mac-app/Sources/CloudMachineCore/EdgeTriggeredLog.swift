import Foundation

/// Loguje `message` tylko przy PIERWSZYM napotkaniu danego stanu (`active ==
/// true`) - kolejne cykle watchdoga w tym samym stanie milcza, zeby nie
/// zasypac wspolnego logu setkami identycznych linii przy dluzszej awarii.
/// Gdy `active` wroci do `false`, znacznik sie czysci i nastepne wystapienie
/// znow zaloguje.
///
/// Powstalo z realnego przypadku: `BackupWatchdogService`/
/// `VerifyWatchdogService` milczaly przez >2 dni, bo ich strazniki "mount
/// jeszcze niegotowy" po prostu `return`owaly bez sladu w logu - diagnoza
/// zajela znacznie dluzej, niz gdyby ta granica stanu byla widoczna.
public enum EdgeTriggeredLog {
  public static func log(marker: URL, active: Bool, _ message: @autoclosure () -> String) {
    if active {
      guard !FileManager.default.fileExists(atPath: marker.path) else { return }
      CMLogger.log(message())
      FileManager.default.createFile(atPath: marker.path, contents: nil)
    } else {
      try? FileManager.default.removeItem(at: marker)
    }
  }
}
