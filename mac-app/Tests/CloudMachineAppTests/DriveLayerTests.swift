import XCTest

@testable import CloudMachineCore

/// Testy warstwy Google Drive. Pokrywaja parsowanie i decyzje - czyli te
/// miejsca, gdzie bledy byly ciche i kosztowne, a nie widac ich po tym, ze
/// "backup sie robi".
final class DriveLayerTests: XCTestCase {

  // MARK: - Parsowanie hdiutil info

  /// `hdiutil info` grupuje wpisy w bloki: po linii `image-path` naleza
  /// wszystkie kolejne linie `/dev/diskN`, az do nastepnego `image-path`.
  private let hdiutilInfo = """
    framework       : 595.100.2
    driver          : 595.100.2
    ================================================
    image-path      : /Users/x/.cloudmachine/drive/other.sparsebundle
    image-alias     : /Users/x/.cloudmachine/drive/other.sparsebundle
    shadow-path     : <none>
    /dev/disk4\tGUID_partition_scheme\t
    /dev/disk4s1\t41504653-0000-11AA-AA11-00306543ECAC\t/Volumes/Other
    ================================================
    image-path      : /Users/x/.cloudmachine/drive/mac-studio.sparsebundle
    image-alias     : /Users/x/.cloudmachine/drive/mac-studio.sparsebundle
    shadow-path     : <none>
    /dev/disk7\tEF57347C-0000-11AA-AA11-00306543ECAC\t
    /dev/disk7s1\t41504653-0000-11AA-AA11-00306543ECAC\t/Volumes/CloudMachine
    """

  func testParseDevicesFindsOnlyMatchingImage() {
    let devices = BackupImageService.parseDevices(
      hdiutilInfo: hdiutilInfo,
      imagePath: "/Users/x/.cloudmachine/drive/mac-studio.sparsebundle")
    XCTAssertEqual(devices, ["/dev/disk7"])
  }

  func testParseDevicesIgnoresOtherImages() {
    let devices = BackupImageService.parseDevices(
      hdiutilInfo: hdiutilInfo,
      imagePath: "/Users/x/.cloudmachine/drive/other.sparsebundle")
    XCTAssertEqual(devices, ["/dev/disk4"])
  }

  /// Regresja: gdy obraz nie jest podpiety, nie wolno zwrocic cudzych
  /// urzadzen - odpiecie ich zabiloby czyjs wolumen.
  func testParseDevicesReturnsNothingForUnknownImage() {
    let devices = BackupImageService.parseDevices(
      hdiutilInfo: hdiutilInfo, imagePath: "/Users/x/nieistniejacy.sparsebundle")
    XCTAssertTrue(devices.isEmpty)
  }

  func testParseDevicesHandlesEmptyInput() {
    XCTAssertTrue(BackupImageService.parseDevices(hdiutilInfo: "", imagePath: "/x").isEmpty)
  }

  // MARK: - Suma kontrolna rclone

  private let sums = """
    3a1f0000000000000000000000000000000000000000000000000000000000aa  rclone-v1.75.1-osx-amd64.zip
    c61d7a371c62bcbbe882c3423aa4b8bf63485c248dd0f692997b8f0c3f6d0c6f  rclone-v1.75.1-osx-arm64.zip
    9b2c0000000000000000000000000000000000000000000000000000000000bb  rclone-v1.75.1-linux-amd64.zip
    """

  func testExpectedChecksumPicksTheRightArchive() {
    XCTAssertEqual(
      RcloneInstaller.expectedChecksum(sumsContent: sums, zipName: "rclone-v1.75.1-osx-arm64.zip"),
      "c61d7a371c62bcbbe882c3423aa4b8bf63485c248dd0f692997b8f0c3f6d0c6f")
  }

  /// Brak wpisu MUSI dac nil, a nie dowolna inna sume - inaczej instalator
  /// porownalby archiwum z suma innego pliku i albo odrzucil poprawne
  /// pobranie, albo (gorzej) przepuscil niepoprawne.
  func testExpectedChecksumReturnsNilWhenArchiveMissing() {
    XCTAssertNil(
      RcloneInstaller.expectedChecksum(sumsContent: sums, zipName: "rclone-v9.9.9-osx-arm64.zip"))
  }

  // MARK: - Argumenty montowania

  func testMountArgumentsCarryTheNonObviousFlags() {
    let args = DriveBufferService.mountArguments()

    // Bez tego skasowane pasma ida do kosza Dysku i dalej licza sie do limitu.
    XCTAssertTrue(args.contains("--drive-use-trash=false"))

    // Po przekroczeniu dobowego limitu 750 GB rclone ma stanac, a nie kreci
    // sie w 403.
    XCTAssertTrue(args.contains("--drive-stop-on-upload-limit"))

    // Bez pelnego cache zapis nie jest buforowany, czyli cala obietnica
    // nieprzerywalnosci znika.
    XCTAssertTrue(args.contains("--vfs-cache-mode"))
    XCTAssertEqual(args[(args.firstIndex(of: "--vfs-cache-mode")! + 1)], "full")

    // Interfejs rc jest jedynym zrodlem stanu kolejki - bez niego dozorca
    // bufora jest slepy.
    XCTAssertTrue(args.contains("--rc"))
  }

  /// Rozmiar pasma zostal wybrany pomiarem (patrz gdrive/README.md). Zmiana
  /// dziala tylko przy tworzeniu obrazu, wiec nie wolno jej przeoczyc.
  func testBandSizeIs32MB() {
    XCTAssertEqual(BackupImageService.bandSectors * 512, 32 * 1024 * 1024)
  }

  // MARK: - Progi dozorcy

  func testGuardThresholdsAreOrdered() {
    let t = BufferGuardService.Thresholds()
    XCTAssertLessThan(
      t.lowGB, t.highGB,
      "Prog wznowienia musi byc nizszy niz prog pauzy, inaczej dozorca wpadnie w oscylacje.")
  }

  /// Wolne miejsce musi byc liczone pesymistycznie, jak `df`. Miara
  /// "important usage" wliczala miejsce zajete przez migawki i pokazywala
  /// 1202 GB tam, gdzie `df` mowilo 427 GB - dozorca spoznilby sie z pauza.
  func testFreeSpaceMatchesStatfs() {
    var stats = statfs()
    XCTAssertEqual(statfs("/System/Volumes/Data", &stats), 0)
    let expected = Int(UInt64(stats.f_bavail) * UInt64(stats.f_bsize) / 1_073_741_824)
    XCTAssertEqual(BufferGuardService.freeGB(), expected)
  }
}

/// Wykrywanie dobowego limitu Google Drive. Osobna klasa, bo to pojedyncza
/// pomylka, ktora zatrzymala prawdziwy backup - zasluguje na wlasne miejsce.
final class DailyQuotaDetectionTests: XCTestCase {
  private let formatter: DateFormatter = {
    let f = DateFormatter()
    // Probka udaje log rclone, wiec musi wygladac tak samo na kazdej maszynie.
    // Literal, a NIE `DriveBufferService.rcloneLogLocale`: generator probki nie
    // moze zalezec od stalej, ktorej poprawnosc wlasnie sprawdzamy - inaczej
    // podmiana tej stalej przestawilaby generator razem z parserem i test
    // przechodzilby w obu stanach.
    f.locale = Locale(identifier: "en_US_POSIX")
    f.dateFormat = "yyyy/MM/dd HH:mm:ss"
    return f
  }()

  private func line(_ minutesAgo: Int, _ message: String, now: Date) -> String {
    let stamp = formatter.string(from: now.addingTimeInterval(-Double(minutesAgo) * 60))
    return "\(stamp) ERROR : \(message)"
  }

  /// TO jest ten blad. rclone opisuje chwilowa przepustnice komunikatem
  /// "Received upload limit error", nie do odroznienia po tekscie od limitu
  /// dobowego - i sam ja ponawia. Zlapanie tego wstrzymalo backup po wyslaniu
  /// 109 GiB z 750 GB dozwolonych na dobe.
  func testTransientRateLimitIsNotTheDailyQuota() {
    let now = Date()
    let log = [
      line(
        2,
        "Received upload limit error: googleapi: Error 403: User rate limit exceeded., userRateLimitExceeded",
        now: now),
      line(2, "bands/cf9: vfs cache: failed to upload try #1, will retry in 1m0s", now: now),
    ].joined(separator: "\n")
    XCTAssertFalse(DriveBufferService.logMentionsUploadLimit(log, now: now, within: 30))
  }

  func testRealQuotaErrorIsDetected() {
    let now = Date()
    let log = line(
      1,
      "googleapi: Error 403: The user has exceeded their Drive storage quota, storageQuotaExceeded",
      now: now)
    XCTAssertTrue(DriveBufferService.logMentionsUploadLimit(log, now: now, within: 30))
  }

  /// Bez okna czasowego raz zapalony alarm nigdy by nie zgasl - wpis zostaje
  /// w logu, wiec backup wpadlby w cykl pauza-wznowienie-pauza.
  func testOldQuotaErrorIsIgnored() {
    let now = Date()
    let log = line(120, "googleapi: Error 403: storageQuotaExceeded", now: now)
    XCTAssertFalse(DriveBufferService.logMentionsUploadLimit(log, now: now, within: 30))
  }

  // MARK: - Ustalenie 15a: kalendarz czlowieka nie moze uciszac parsera

  /// ZNANY ZLY KALENDARZ - taki, jaki `Locale.current` oddaje na tajskim Macu.
  ///
  /// `DateFormatter` z ustalonym `dateFormat` bierze kalendarz z locale, wiec
  /// "2026/09/25" parsuje sie BEZ BLEDU jako rok buddyjski 2026, czyli
  /// gregorianski 1483. Data wypada 543 lata przed oknem, `stamp < cutoff`
  /// konczy petle na pierwszej linii i realny limit dysku przestaje istniec.
  func testKalendarzBuddyjskiKasowalWykrycieLimitu() {
    let now = Date()
    let log = line(
      1,
      "googleapi: Error 403: The user has exceeded their Drive storage quota, storageQuotaExceeded",
      now: now)
    XCTAssertFalse(
      DriveBufferService.logMentionsUploadLimit(
        log, now: now, within: 30, locale: Locale(identifier: "th_TH@calendar=buddhist")),
      "to jest opis USTERKI, nie oczekiwanie - naprawa siedzi w domyslnym locale")
    XCTAssertTrue(
      DriveBufferService.logMentionsUploadLimit(log, now: now, within: 30),
      "domyslny parser musi czytac ten sam log niezaleznie od ustawien czlowieka")
  }

  func testEmptyLogIsNotAQuotaError() {
    XCTAssertFalse(DriveBufferService.logMentionsUploadLimit("", now: Date(), within: 30))
  }
}

/// Rozpoznanie ZATORU wysylki po zachowaniu rclone.
///
/// Wszystkie proporcje ponizej sa ZMIERZONE na produkcyjnym `rclone.log` tej
/// maszyny, nie wymyslone. Tekst bledu jest w obu przypadkach identyczny -
/// gdyby dalo sie je rozroznic po tresci, ta klasa nie musialaby istniec.
final class UploadStallDetectionTests: XCTestCase {
  private let formatter: DateFormatter = {
    let f = DateFormatter()
    // Probka udaje log rclone, wiec musi wygladac tak samo na kazdej maszynie.
    // Literal, a NIE `DriveBufferService.rcloneLogLocale`: generator probki nie
    // moze zalezec od stalej, ktorej poprawnosc wlasnie sprawdzamy - inaczej
    // podmiana tej stalej przestawilaby generator razem z parserem i test
    // przechodzilby w obu stanach.
    f.locale = Locale(identifier: "en_US_POSIX")
    f.dateFormat = "yyyy/MM/dd HH:mm:ss"
    return f
  }()

  /// Buduje probke o zadanym stosunku sukcesow do bledow, w oknie.
  private func sample(errors: Int, successes: Int, minutesAgo: Int, now: Date) -> String {
    let stamp = formatter.string(from: now.addingTimeInterval(-Double(minutesAgo) * 60))
    var lines: [String] = []
    for _ in 0..<errors {
      lines.append(
        "\(stamp) ERROR : Google drive root 'CloudMachine/mac-studio': Received upload limit "
          + "error: googleapi: Error 403: User rate limit exceeded., userRateLimitExceeded")
    }
    for i in 0..<successes {
      lines.append(
        "\(stamp) INFO  : mac-studio.sparsebundle/bands/\(String(i, radix: 16)): "
          + "Copied (replaced existing)")
    }
    return lines.joined(separator: "\n")
  }

  /// ZNANA ZLA PROBKA. 12 wrzesnia 2026, godzina 10: 5467 bledow i 59 udanych
  /// wysylek. Wysylka stala wtedy trzy godziny i NIC tego nie zglosilo.
  func testRealStallIsDetected() {
    let now = Date()
    let log = sample(errors: 5467, successes: 59, minutesAgo: 5, now: now)
    XCTAssertTrue(DriveBufferService.logShowsUploadStalled(log, now: now, within: 30))
  }

  /// Drugi zator, 15 wrzesnia godzina 9: 8915 bledow, 31 sukcesow.
  func testSecondRealStallIsDetected() {
    let now = Date()
    let log = sample(errors: 8915, successes: 31, minutesAgo: 2, now: now)
    XCTAssertTrue(DriveBufferService.logShowsUploadStalled(log, now: now, within: 30))
  }

  /// ZNANA DOBRA PROBKA. 12 wrzesnia godzina 9, tuz PRZED zatorem: tyle samo
  /// bledow co sukcesow (781 do 833). Wysylka szla. To jest ta sytuacja,
  /// ktora kiedys niepotrzebnie wstrzymala backup po 109 GiB.
  func testThrottlingWithUploadsFlowingIsNotAStall() {
    let now = Date()
    let log = sample(errors: 781, successes: 833, minutesAgo: 5, now: now)
    XCTAssertFalse(DriveBufferService.logShowsUploadStalled(log, now: now, within: 30))
  }

  /// 15 wrzesnia godzina 8: 1040 bledow, ale 2481 sukcesow - dlawienie tempa
  /// przy wysylce idacej pelna para. Godzine pozniej to samo przeszlo w zator
  /// i wtedy juz musi zadzialac.
  func testHeavyThrottlingWithMoreSuccessesIsNotAStall() {
    let now = Date()
    let log = sample(errors: 1040, successes: 2481, minutesAgo: 10, now: now)
    XCTAssertFalse(DriveBufferService.logShowsUploadStalled(log, now: now, within: 30))
  }

  /// 11 wrzesnia godzina 14: JEDEN blad na 4833 udane wysylki. Pojedyncze
  /// odbicie nie jest zatorem, choc stosunek sukcesow bylby tu bez znaczenia -
  /// ratuje nas dolny prog liczby bledow.
  func testSingleErrorIsNotAStall() {
    let now = Date()
    let log = sample(errors: 1, successes: 4833, minutesAgo: 5, now: now)
    XCTAssertFalse(DriveBufferService.logShowsUploadStalled(log, now: now, within: 30))
  }

  /// Zator, ktory byl i minal, nie moze trzymac alarmu w nieskonczonosc -
  /// wpis zostaje w logu na zawsze.
  func testStallOutsideTheWindowIsIgnored() {
    let now = Date()
    let log = sample(errors: 5467, successes: 59, minutesAgo: 120, now: now)
    XCTAssertFalse(DriveBufferService.logShowsUploadStalled(log, now: now, within: 30))
  }

  /// Cisza to nie zator. W oknie bez ruchu nie ma ani bledow, ani sukcesow -
  /// bez dolnego progu liczby bledow stosunek 0/0 dalby falszywy alarm.
  func testSilenceIsNotAStall() {
    XCTAssertFalse(DriveBufferService.logShowsUploadStalled("", now: Date(), within: 30))
  }

  // MARK: - Ustalenie 15a: kalendarz czlowieka nie moze uciszac zatoru

  /// Ten sam zator, ktory `testRealStallIsDetected` wykrywa, znikal bez sladu
  /// na maszynie z kalendarzem niegregorianskim: wszystkie linie wypadaly poza
  /// okno, `errors` zostawalo zerem i `uploadStalled()` meldowal "nie ma
  /// zatoru" - a dozorca bufora na tej podstawie NIE wstrzymuje Time Machine.
  func testKalendarzBuddyjskiKasowalWykrycieZatoru() {
    let now = Date()
    let log = sample(errors: 5467, successes: 59, minutesAgo: 5, now: now)
    XCTAssertFalse(
      DriveBufferService.logShowsUploadStalled(
        log, now: now, within: 30, locale: Locale(identifier: "th_TH@calendar=buddhist")),
      "to jest opis USTERKI, nie oczekiwanie")
    XCTAssertTrue(
      DriveBufferService.logShowsUploadStalled(log, now: now, within: 30),
      "domyslnie parsujemy ustalonym en_US_POSIX, wiec zator zostaje zatorem")
  }

  /// Sama stala - zeby "naprawa" polegajaca na cofnieciu jej do
  /// `Locale.current` nie przeszla niezauwazona na maszynie, ktora akurat ma
  /// kalendarz gregorianski (czyli na tej).
  func testParserLoguJestPinowanyNaPosix() {
    XCTAssertEqual(DriveBufferService.rcloneLogLocale.identifier, "en_US_POSIX")
  }

  /// Odroczenie wysylki musi isc do rclone z jednej stalej - inaczej zmiana
  /// jednego miejsca zostawia drugie z poprzednia wartoscia.
  func testMountUsesConfiguredWriteBack() {
    let args = DriveBufferService.mountArguments()
    guard let index = args.firstIndex(of: "--vfs-write-back") else {
      return XCTFail("brak --vfs-write-back w argumentach montowania")
    }
    XCTAssertEqual(args[index + 1], "\(DriveBufferService.writeBackSeconds)s")
  }
}

/// Decyzje dozorcy bufora. Komentarz przy `step()` obiecywal, ze wydzielenie
/// go z petli sluzy testowaniu - a testu nie bylo. Tu jest.
final class BufferGuardThresholdTests: XCTestCase {

  /// Prog pauzy MUSI lezec PONIZEJ rozmiaru bufora - i to jest odwrocenie
  /// wymagania, ktore stalo tu wczesniej.
  ///
  /// Stara wersja zadala progu POWYZEJ rozmiaru cache'a, bo progi odnosily sie
  /// do `bytesUsed`, czyli do rozmiaru CALEGO cache'a. Ta wielkosc z definicji
  /// stoi przy limicie (`--vfs-cache-max-size 100G` plus `max-age 9999h`),
  /// zmierzone: 281 pomiarow, minimum 99 GB. Prog ponizej niej faktycznie
  /// wstrzymywalby backup bez przerwy - wiec tamto wymaganie bylo sluszne DLA
  /// TAMTEJ MIARY.
  ///
  /// Od 2026-09-25 progi odnosza sie do ZALEGLOSCI NIEWYSLANEJ. Zaleglosc to
  /// dokladnie ta czesc cache'a, ktorej rclone NIE MOZE usunac, wiec gdy
  /// zrowna sie z `cacheSizeGB`, limit nie ma juz zapasu i kazdy kolejny
  /// gigabajt idzie poza niego, w wolne miejsce na dysku. Prog pauzy musi wiec
  /// zdazyc ZANIM to nastapi.
  ///
  /// Co kosztowala stara wersja: przy progu wznowienia 40 GB liczonym z miary,
  /// ktora nigdy nie spadla ponizej 99 GB, w calym dzienniku jest jedna linia
  /// PAUZA i ZERO linii WZNOWIENIE - dozorca stal w pauzie 53 godziny.
  func testPauseThresholdSitsBelowTheCacheSize() {
    let t = BufferGuardService.Thresholds()
    XCTAssertLessThan(
      t.highGB, DriveBufferService.cacheSizeGB,
      "Prog pauzy rowny rozmiarowi bufora znaczy zero zapasu: zaleglosc rowna "
        + "pojemnosci cache'a wypycha kazdy kolejny gigabajt w wolne miejsce.")
  }

  /// Prog wznowienia musi byc wyraznie nizszy od progu pauzy, inaczej dozorca
  /// oscylowalby miedzy start i stop przy kazdym tyknieciu.
  func testResumeThresholdLeavesHysteresis() {
    let t = BufferGuardService.Thresholds()
    XCTAssertLessThan(t.lowGB, t.highGB)
    XCTAssertLessThanOrEqual(
      t.lowGB, t.highGB / 2,
      "Zbyt waski odstep progow daje cykl pauza-wznowienie-pauza.")
  }

  /// Progi nadal WYLICZAJA sie z rozmiaru bufora, a nie sa wpisane z palca -
  /// ta wlasnosc zostaje, zmienily sie tylko mnozniki, bo zmienila sie
  /// wielkosc, do ktorej progi sie odnosza (zaleglosc zamiast rozmiaru cache'a).
  /// Wpisane z palca dzialaly tylko przypadkiem, dla jednej konkretnej wartosci.
  func testThresholdsFollowTheCacheSize() {
    let t = BufferGuardService.Thresholds()
    XCTAssertEqual(t.highGB, DriveBufferService.cacheSizeGB / 2)
    XCTAssertEqual(t.lowGB, DriveBufferService.cacheSizeGB / 10)
  }

  /// Prog wznowienia musi byc OSIAGALNY. To jest cala lekcja z 53 godzin pauzy:
  /// stare 40 GB odnosilo sie do wielkosci, ktora nigdy nie zeszla ponizej
  /// 99 GB, wiec warunek wyjscia z pauzy byl falszywy w 281 obserwacjach na 281.
  /// Zaleglosc schodzi do zera, gdy kolejka sie oprozni - ale tylko wtedy, gdy
  /// prog lezy w zasiegu tego, co kolejka potrafi oddac.
  func testResumeThresholdIsReachable() {
    let t = BufferGuardService.Thresholds()
    XCTAssertGreaterThan(t.lowGB, 0, "Prog wznowienia rowny zeru wymaga pustej kolejki.")
    XCTAssertLessThan(
      t.lowGB, DriveBufferService.cacheSizeGB,
      "Prog wznowienia powyzej pojemnosci cache'a jest nieosiagalny z definicji.")
  }

  func testExplicitThresholdsAreRespected() {
    let t = BufferGuardService.Thresholds(highGB: 10, lowGB: 2, minFreeGB: 5)
    XCTAssertEqual(t.highGB, 10)
    XCTAssertEqual(t.lowGB, 2)
    XCTAssertEqual(t.minFreeGB, 5)
  }
}
