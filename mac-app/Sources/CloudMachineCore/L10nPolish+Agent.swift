// Polish translations, keyed by the English text passed to `L10n.tr`.
extension L10nPolish {
  static let agent: [String: String] = [
    "Space limit:      %@":
      "Limit miejsca:    %@",
    "                  Time Machine quota not set to match - run: %@":
      "                  Limit Time Machine nie pasuje - uruchom: %@",
    "Sets how much of Google Drive this Mac may use, and prints the Time Machine quota command.":
      "Ustawia, ile miejsca na Google Drive może zająć ten Mac, i wypisuje polecenie ustawiające limit Time Machine.",
    "Limit in GB.":
      "Limit w GB.",
    "Limit for this Mac: %@ GB.":
      "Limit dla tego Maca: %@ GB.",
    "Now set the Time Machine quota (needs an administrator password):":
      "Teraz ustaw limit Time Machine (wymaga hasła administratora):",
    "CloudMachine - verification, Google Drive setup and installation. Called by launchd on a schedule, or by hand from Terminal.":
      "CloudMachine - weryfikacja, konfiguracja Google Drive i instalacja. Wołane przez launchd według harmonogramu albo ręcznie z Terminala.",
    "Connects to Google Drive through rclone (OAuth in the browser) and creates this machine's folder.":
      "Łączy z Google Drive przez rclone (OAuth w przeglądarce) i tworzy folder tej maszyny.",
    "Overwrite the existing remote. RISKY: replaces the token and permissions.":
      "Nadpisz istniejący remote. RYZYKOWNE: podmienia token i uprawnienia.",
    "Packs build/CloudMachine.app into build/CloudMachine-<version>.dmg.":
      "Pakuje build/CloudMachine.app do pliku build/CloudMachine-<wersja>.dmg.",
    "ERROR: %@ is missing - run 'cloudmachine-agent build-app' first":
      "BŁĄD: brak %@ - uruchom najpierw 'cloudmachine-agent build-app'",
    "==> Preparing the staging folder":
      "==> Przygotowuję folder staging",
    "==> Creating %@":
      "==> Tworzę %@",
    "ERROR: hdiutil exited with code %@.":
      "BŁĄD: hdiutil zakończył się kodem %@.",
    "==> Done: %@":
      "==> Gotowe: %@",
    "On first launch (the app is not signed with an Apple Developer account):":
      "Przy pierwszym uruchomieniu (appka niepodpisana kontem Apple Developer):",
    "1. Open %@ and drag CloudMachine.app to Applications.":
      "1. Otwórz %@ i przeciągnij CloudMachine.app do Applications.",
    "2. In Finder, RIGHT-click CloudMachine.app -> Open -> Open\n   (a plain double-click shows the Gatekeeper block \"unidentified developer\").":
      "2. W Finderze kliknij CloudMachine.app PRAWYM przyciskiem -> Otwórz -> Otwórz\n   (samo dwukliknięcie pokaże blokadę Gatekeepera „niezidentyfikowany deweloper”).",
    "3. Later launches work normally, with a double-click.":
      "3. Kolejne uruchomienia działają już normalnie, dwuklikiem.",
    "Builds CloudMachine.app (Release) - GUI + cloudmachine-agent in Contents/MacOS/, plus launchd/, vm/ and config/ as Resources.":
      "Buduje CloudMachine.app (Release) - GUI + cloudmachine-agent w Contents/MacOS/, plus launchd/, vm/ i config/ jako Resources.",
    "Binaries for Apple Silicon and Intel at once (how CI builds a release; unnecessary locally).":
      "Binarki dla Apple Silicon i Intela naraz (tak buduje wydanie CI; lokalnie zbędne).",
    "==> Building CloudMachineApp + cloudmachine-agent (release) - version %@ (%@)":
      "==> Buduję CloudMachineApp + cloudmachine-agent (release) - wersja %@ (%@)",
    "ERROR: swift build exited with code %@.":
      "BŁĄD: swift build zakończył się kodem %@.",
    "ERROR: swift build --show-bin-path did not report the binaries directory.":
      "BŁĄD: swift build --show-bin-path nie podał katalogu z binarkami.",
    "ERROR: no built binary found at %@":
      "BŁĄD: nie znaleziono zbudowanej binarki pod %@",
    "==> Assembling the .app bundle in %@":
      "==> Składam bundle .app w %@",
    "==> WARNING: you are building from a DIRTY tree - the version will not point to a commit.":
      "==> UWAGA: budujesz z BRUDNEGO drzewa - wersja nie wskaże commitu.",
    "ERROR: Resources/AppIcon.icns is missing - generate it: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns":
      "BŁĄD: brak Resources/AppIcon.icns - wygeneruj go: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns",
    "==> Signing with the local certificate '%@' (Full Disk Access will survive later rebuilds)":
      "==> Podpisuję lokalnym certyfikatem '%@' (Pełny dostęp do dysku przetrwa kolejne przebudowy)",
    "==> Signing ad-hoc (no Apple Developer account) - run 'cloudmachine-agent setup-signing-cert' once so that TCC permissions survive later rebuilds":
      "==> Podpisuję ad-hoc (bez konta Apple Developer) - uruchom raz 'cloudmachine-agent setup-signing-cert', żeby uprawnienia TCC przetrwały kolejne przebudowy",
    "ERROR: codesign exited with code %@.":
      "BŁĄD: codesign zakończył się kodem %@.",
    "Next step: %@":
      "Następny krok: %@",
    "Creates a local self-signed certificate so that Full Disk Access survives later rebuilds of the app.":
      "Tworzy lokalny certyfikat self-signed, żeby Pełny dostęp do dysku przetrwał kolejne przebudowy appki.",
    "Certificate '%@' already exists in %@, nothing to do.":
      "Certyfikat '%@' już istnieje w %@, nic nie robię.",
    "==> Generating the key and self-signed certificate '%@'...":
      "==> Generuję klucz i certyfikat self-signed '%@'...",
    "ERROR: openssl req exited with code %@.":
      "BŁĄD: openssl req zakończył się kodem %@.",
    "ERROR: openssl pkcs12 exited with code %@.":
      "BŁĄD: openssl pkcs12 zakończył się kodem %@.",
    "==> Importing the certificate into %@ (pre-authorizing /usr/bin/codesign, so it does not ask for the keychain password every time)...":
      "==> Importuję certyfikat do %@ (z góry autoryzuję /usr/bin/codesign, bez pytania o hasło pęku kluczy za każdym razem)...",
    "ERROR: security import exited with code %@.":
      "BŁĄD: security import zakończył się kodem %@.",
    "==> Trusting the certificate ONLY for code signing...":
      "==> Ufam certyfikatowi WYŁĄCZNIE do podpisywania kodu (code signing)...",
    "ERROR: security add-trusted-cert exited with code %@.":
      "BŁĄD: security add-trusted-cert zakończył się kodem %@.",
    "Done. Certificate '%@' is now available to codesign.":
      "Gotowe. Certyfikat '%@' jest teraz dostępny dla codesign.",
    "The next 'cloudmachine-agent build-app' will use it automatically instead of an ad-hoc signature.":
      "Następne 'cloudmachine-agent build-app' użyje go automatycznie zamiast podpisu ad-hoc.",
    "After THAT ONE rebuild, grant Full Disk Access one last time - later\nrebuilds will no longer reset it, as long as you sign with the same certificate.":
      "Po TYM JEDNYM rebuildzie przyznaj Pełny dostęp do dysku ostatni raz - kolejne\nprzebudowy już go nie zresetują, dopóki podpisujesz tym samym certyfikatem.",
    "Checks whether the hourly cycle STILL works (date of the last SUCCESSFUL backup) and reports failures.":
      "Sprawdza, czy cykl godzinowy NADAL działa (data ostatniej UDANEJ kopii), i zgłasza awarie.",
    "After this many hours without a successful backup we consider the cycle broken.":
      "Po tylu godzinach bez udanej kopii uznajemy cykl za zerwany.",
    "Only print the state, without a system notification.":
      "Tylko wypisz stan, bez powiadomienia systemowego.",
    "A different Time Machine preferences file - to test the watchdog on a known sample.":
      "Inny plik preferencji Time Machine - do sprawdzenia czujki na znanej próbce.",
    "Last successful backup: %@":
      "Ostatnia udana kopia: %@",
    "Last successful backup: NONE":
      "Ostatnia udana kopia: BRAK",
    "Last attempt:           %@":
      "Ostatnia próba:       %@",
    "WAITING (system startup): %@":
      "CZEKAM (start systemu): %@",
    "Backup cycle: OK":
      "Cykl backupu: OK",
    "FAILURE: %@":
      "AWARIA: %@",
    "         %@":
      "        %@",
    "Check the state:  %@":
      "Sprawdź stan:  %@",
    "Preparing for restart":
      "Przygotowanie do restartu",
    "Prepare for restart":
      "Przygotuj do restartu",
    "Prepare":
      "Przygotuj",
    "==> WARNING: git rev-list failed (%@) - using the date as the build number.":
      "==> UWAGA: git rev-list nie powiódł się (%@) - jako numer budowy idzie data.",
    "Agents:           %@":
      "Agenci:           %@",
    "CANNOT START: %@ - open CloudMachine or run backup-health to reload them":
      "NIE STARTUJĄ: %@ - otwórz CloudMachine albo uruchom backup-health, żeby je przeładować",
    "Reloaded agents that could not start: %@":
      "Przeładowano agentów, którzy nie mogli wystartować: %@",
    "Drive folder:     %@":
      "Folder na Drive:  %@",
    "Name of this Mac's folder on Google Drive (default: derived from the computer name). Set once; it cannot be changed later.":
      "Nazwa folderu tego Maca na Google Drive (domyślnie z nazwy komputera). Ustawiana raz; później nie da się jej zmienić.",
    "Backup watchdog:  %@":
      "Czujka backupu:   %@",
    "Prints the version, the build number and the commit this binary was built from.":
      "Wypisuje wersję, numer budowy i commit, z którego zbudowano tę binarkę.",
    "Only one line, without a description.":
      "Tylko jedna linia, bez opisu.",
    "Build from the working tree (outside a bundle) - no version data.":
      "Build z drzewa roboczego (poza bundlem) - brak danych o wersji.",
    "Version: %@":
      "Wersja:  %@",
    "Build:   %@":
      "Budowa:  %@",
    "Commit:  %@":
      "Commit:  %@",
    "WARNING: built from a DIRTY tree - the binary contains code that\n         is in no commit. The commit number does NOT describe\n         what actually runs.":
      "UWAGA: zbudowano z BRUDNEGO drzewa - w binarce jest kod, którego\n       nie ma w żadnym commicie. Numer commitu NIE opisuje tego,\n       co naprawdę działa.",
  ]
}
