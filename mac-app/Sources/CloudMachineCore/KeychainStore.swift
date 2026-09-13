import Foundation

/// Zapis poswiadczen do Keychaina.
///
/// **Dlaczego przez `security`, a nie przez API Security (SecItemAdd).**
/// Wpis zalozony przez `SecItemAdd` dostaje ACL ograniczony do programu, ktory
/// go utworzyl. Odczyt z INNEJ binarki - a dokladnie to robi
/// `RemoteConfigurer.keychainSecret`, wolane z agenta launchd - podnosi wtedy
/// okno "pozwol na dostep". Agent launchd nie ma komu tego okna pokazac, wiec
/// odczyt zawisa albo wraca pusty, a rclone po cichu laczy sie na
/// wspoldzielonym `client_id`. Zmierzone 13 wrz 2026: `SecItemAdd` zwrocil 0,
/// po czym `security find-generic-password -w` z innego procesu zawisl na
/// oknie SecurityAgent.
///
/// Zapis przez `security` daje wpis czytelny dla `security` - czyli dokladnie
/// dla tej sciezki, ktorej uzywa dzialajacy system.
///
/// **Cena: haslo idzie w argv `security`,** wiec przez ulamek sekundy widac je
/// w `ps`. Swiadomy kompromis wobec alternatywy, ktora jest cicha awaria
/// backupu. Ekspozycja dotyczy procesu zyjacego milisekundy i wylacznie na tej
/// maszynie; sekret i tak zaraz laduje w Keychainie tego samego uzytkownika.
public enum KeychainStore {

  public enum StoreError: LocalizedError {
    case emptyValue
    case failed(String)

    public var errorDescription: String? {
      switch self {
      case .emptyValue: return "Pusta wartosc - nie zapisuje."
      case .failed(let detail): return "Keychain odmowil: \(detail)"
      }
    }
  }

  /// Zapisuje albo nadpisuje wpis. `-U` znaczy "podmien, jesli juz jest" -
  /// bez tego poprawienie literowki konczyloby sie bledem i stara wartoscia
  /// nadal w uzyciu.
  public static func save(_ value: String, account: String, service: String) async throws {
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { throw StoreError.emptyValue }

    let result = try? await ProcessRunner.run(
      "/usr/bin/security",
      ["add-generic-password", "-a", account, "-s", service, "-w", trimmed, "-U"],
      timeout: 30)
    guard result?.succeeded == true else {
      throw StoreError.failed(result?.stderr ?? "nieznany blad")
    }
  }

  /// Czy wpis istnieje - BEZ `-w`, czyli bez siegania po sama wartosc.
  ///
  /// To nie jest drobiazg: samo sprawdzenie istnienia nie rusza ACL i nie
  /// podnosi okna, a odczyt wartosci (`-w`) potrafi. Interfejs ma pokazac
  /// "ustawione / brak" i do tego wartosc nie jest potrzebna.
  public static func exists(account: String, service: String) async -> Bool {
    let result = try? await ProcessRunner.run(
      "/usr/bin/security",
      ["find-generic-password", "-a", account, "-s", service],
      timeout: 30)
    return result?.succeeded == true
  }

  public static func delete(account: String, service: String) async throws {
    let result = try? await ProcessRunner.run(
      "/usr/bin/security",
      ["delete-generic-password", "-a", account, "-s", service],
      timeout: 30)
    // Brak wpisu to nie blad - kasowanie ma byc idempotentne.
    guard result?.succeeded == true || result?.stderr.contains("could not be found") == true else {
      throw StoreError.failed(result?.stderr ?? "nieznany blad")
    }
  }
}
