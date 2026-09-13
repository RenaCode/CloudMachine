import ArgumentParser
import Foundation

/// Mierzy wzmocnienie zapisu: ile megabajtow trzeba wyslac do Drive'a, zeby
/// utrwalic jeden megabajt faktycznej zmiany.
///
/// To jest liczba, ktora decyduje o rozmiarze pasma. Duze pasma oszczedzaja
/// operacje na plikach (Drive przepuszcza ~2/s i ma limit 400 000 plikow), ale
/// kazda drobna zmiana kaze wyslac cale pasmo od nowa. Jesli wzmocnienie okaze
/// sie wysokie, 64 MB jest bledem i trzeba zejsc nizej.
///
/// Uruchamiane dla kazdego rozmiaru pasma osobno; wynik to tabela do
/// porownania.
struct AmplificationCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "amplification",
    abstract: "Mierzy wzmocnienie zapisu dla zadanego rozmiaru pasma.")

  enum Workload: String, ExpressibleByArgument, CaseIterable {
    /// Przepisanie rozrzuconych plikow - najgorszy realny przypadek.
    case scatter
    /// Dopisanie nowych plikow - tak zachowuje sie Time Machine.
    case append
  }

  @Option(name: .long, help: "Rozmiar pasma w MB.")
  var bandMB: Int = 64

  @Option(name: .long, help: "Ile plikow w pierwszym zapisie.")
  var seedFiles: Int = 3000

  @Option(name: .long, help: "Rozmiar pojedynczego pliku w KB.")
  var fileKB: Int = 64

  @Option(name: .long, help: "Ile plikow zmieniamy w drugim przebiegu.")
  var touchFiles: Int = 300

  @Option(name: .long, help: "scatter = rozrzucone przepisanie, append = nowe pliki jak TM.")
  var workload: Workload = .scatter

  @Option(name: .long, help: "Katalog roboczy.")
  var root: String = "/tmp/cm-amp"

  @Flag(name: .long, help: "Tylko posprzataj po poprzednim przebiegu i zakoncz.")
  var clean = false

  private var runRoot: URL { URL(fileURLWithPath: root).appendingPathComponent("b\(bandMB)") }
  private var outerImage: URL { runRoot.appendingPathComponent("stand-in.sparseimage") }
  private var mountPoint: URL { runRoot.appendingPathComponent("drive") }
  private var image: URL { mountPoint.appendingPathComponent("amp.sparsebundle") }
  private var target: URL { URL(fileURLWithPath: "/Volumes/AmpPOC\(bandMB)") }

  private func cleanup() async {
    await POC.detachQuietly(target.path)
    await POC.detachQuietly(mountPoint.path)
  }

  func run() async throws {
    guard !clean else {
      await cleanup()
      try? FileManager.default.removeItem(at: URL(fileURLWithPath: root))
      print("Posprzatane.")
      return
    }

    // `trap cleanup EXIT` z wersji powlokowej: cokolwiek pojdzie nie tak,
    // nie zostawiamy podpietych obrazow.
    do {
      try await measure()
    } catch {
      await cleanup()
      throw error
    }
    await cleanup()
  }

  private func measure() async throws {
    await cleanup()
    try POC.recreateDirectory(runRoot)
    try FileManager.default.createDirectory(at: mountPoint, withIntermediateDirectories: true)

    try await POC.createSparseImage(at: outerImage, sizeGB: 40, volumeName: "AmpStandIn")
    try await POC.attach(outerImage, mountpoint: mountPoint)
    try await POC.createSparsebundle(
      at: image, sizeGB: 30, volumeName: "AmpPOC\(bandMB)", bandMB: bandMB)
    try await POC.attach(image, mountpoint: target)

    // Pierwszy zapis - odpowiednik pelnego backupu.
    let dataDir = target.appendingPathComponent("dane")
    try FileManager.default.createDirectory(at: dataDir, withIntermediateDirectories: true)
    for i in 1...seedFiles {
      try POC.createFile(dataDir.appendingPathComponent("plik-\(i).bin"), kilobytes: fileKB)
    }
    await POC.sync()
    await POC.detachQuietly(target.path)

    let bands = image.appendingPathComponent("bands")
    let seedBands = POC.fileCount(in: bands)
    let seedMB = POC.allocatedMegabytes(of: image)

    // Znacznik czasu, wzgledem ktorego liczymy zmienione pasma.
    let mark = Date()
    try await Task.sleep(nanoseconds: 1_000_000_000)

    // Drugi przebieg - odpowiednik backupu przyrostowego.
    try await POC.attach(image, mountpoint: target)
    var changedKB = 0
    switch workload {
    case .append:
      // Time Machine nie przepisuje istniejacych danych w miejscu - kazdy
      // backup doklada nowe pliki. Zapis jest wtedy skupiony, nie rozrzucony.
      let growth = dataDir.appendingPathComponent("przyrost")
      try FileManager.default.createDirectory(at: growth, withIntermediateDirectories: true)
      for i in 1...touchFiles {
        try POC.createFile(growth.appendingPathComponent("nowy-\(i).bin"), kilobytes: fileKB)
        changedKB += fileKB
      }
    case .scatter:
      // Zmieniamy rozrzucone pliki, zeby trafic w mozliwie wiele roznych pasm;
      // to najgorszy realny przypadek, nie sredni.
      let step = max(1, seedFiles / touchFiles)
      for i in stride(from: 1, through: seedFiles, by: step) {
        try POC.overwriteInPlace(
          dataDir.appendingPathComponent("plik-\(i).bin"),
          with: POC.randomData(kilobytes: fileKB))
        changedKB += fileKB
      }
    }
    await POC.sync()
    await POC.detachQuietly(target.path)

    let dirty = POC.filesModified(after: mark, in: bands)
    let uploadMB = dirty * bandMB
    let changedMB = max(1, changedKB / 1024)

    print("---")
    print("pasmo                : \(bandMB) MB   (scenariusz: \(workload.rawValue))")
    print("po pelnym zapisie    : \(seedBands) pasm, \(seedMB) MB")
    print("zmieniono realnie    : \(changedMB) MB w \(touchFiles) plikach")
    print("pobrudzonych pasm    : \(dirty)")
    print("do wyslania          : \(uploadMB) MB")
    print("WZMOCNIENIE          : \(uploadMB / changedMB)x")
  }
}
