import Foundation

/// Sciezki potrzebne WYLACZNIE narzedziom budowania (`build-app`, `make-dmg`,
/// `setup-signing-cert`) - w przeciwienstwie do `CMPaths` (CloudMachineCore),
/// ktore rozwiazuje sciezki dla dzialajacej juz appki/CLI (w tym wewnatrz
/// zainstalowanego .app), te narzedzia maja sens WYLACZNIE uruchomione z
/// checkoutu zrodlowego (to one PRODUKUJA .app, nie go konsumuja) - stad
/// `#filePath` (znane w czasie kompilacji, niezalezne od tego skad polecenie
/// zostanie potem uruchomione) zamiast `CommandLine.arguments[0]`.
enum BuildPaths {
  static var macAppRoot: URL {
    URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()  // CloudMachineAgent
      .deletingLastPathComponent()  // Sources
      .deletingLastPathComponent()  // mac-app
  }

  static var projectRoot: URL {
    macAppRoot.deletingLastPathComponent()
  }
}
