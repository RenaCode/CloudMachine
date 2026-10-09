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
    "Generates and installs the launchd agents (Drive buffer, image attach, buffer guard).":
      "Generuje i instaluje agentów launchd (bufor Drive, podpięcie obrazu, dozorca bufora).",
    "Connects to Google Drive through rclone (OAuth in the browser) and creates this machine's folder.":
      "Łączy z Google Drive przez rclone (OAuth w przeglądarce) i tworzy folder tej maszyny.",
    "Overwrite the existing remote. RISKY: replaces the token and permissions.":
      "Nadpisz istniejący remote. RYZYKOWNE: podmienia token i uprawnienia.",
    "Installs rclone through Homebrew - WARNING: this build CANNOT mount, see install-rclone.":
      "Instaluje rclone przez Homebrew - UWAGA: ta wersja NIE umie montować, patrz install-rclone.",
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
    "Builds CloudMachine.app (Release) - GUI + cloudmachine-agent in Contents/MacOS/, plus launchd/config as Resources.":
      "Buduje CloudMachine.app (Release) - GUI + cloudmachine-agent w Contents/MacOS/, plus launchd/config jako Resources.",
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
    "Mounts Google Drive with a write buffer. Stays in the foreground (for launchd).":
      "Montuje Google Drive z buforem zapisu. Zostaje na pierwszym planie (dla launchd).",
    "Already mounted: %@":
      "Już zamontowane: %@",
    "Missing: %@\n  %@\n":
      "Brakuje: %@\n  %@\n",
    "Could not start %@\n":
      "Nie udało się uruchomić %@\n",
    "Creates the backup image on Google Drive. One-off.":
      "Tworzy obraz backupu na Google Drive. Jednorazowo.",
    "Declared size in GB (the image is sparse).":
      "Rozmiar deklarowany w GB (obraz jest rzadki).",
    "Next step: %@, then":
      "Następny krok: %@, potem",
    "Attaches the backup image as the Time Machine destination.":
      "Podpina obraz backupu jako cel Time Machine.",
    "The buffer did not come up within %@ min - not attaching the image.":
      "Bufor nie stanął w %@ min - nie podpinam obrazu.",
    "Time Machine now has NO DESTINATION. Check: %@":
      "Time Machine jest teraz BEZ CELU. Sprawdź: %@",
    "This is not an error - the agent's next run will try again.":
      "Nie jest to błąd - następny przebieg agenta spróbuje ponownie.",
    "Detaches the image and waits until everything reaches Google Drive.":
      "Odpina obraz i czeka, aż wszystko doleci na Google Drive.",
    "Do not wait for the upload - RISKY, see BackupImageService.detach.":
      "Nie czekaj na wysyłkę - RYZYKOWNE, patrz BackupImageService.detach.",
    "Checks the image's consistency with fsck_apfs (hdiutil verify does not work on a sparsebundle).":
      "Sprawdza spójność obrazu przez fsck_apfs (hdiutil verify na sparsebundle nie działa).",
    "Pauses Time Machine when the unsent backlog grows faster than the upload goes.":
      "Wstrzymuje Time Machine, gdy zaległość niewysłana rośnie szybciej, niż idzie wysyłka.",
    "Above this many GB of unsent backlog we pause Time Machine.":
      "Powyżej tylu GB zaległości niewysłanej wstrzymujemy Time Machine.",
    "Below this many GB of unsent backlog we resume.":
      "Poniżej tylu GB zaległości niewysłanej wznawiamy.",
    "Below this many GB free on disk we pause regardless of the buffer.":
      "Poniżej tylu GB wolnych na dysku wstrzymujemy niezależnie od bufora.",
    "How often to check, in seconds.":
      "Co ile sekund sprawdzać.",
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
    "Prepares for a restart: pauses the backup, detaches the image and waits for the upload.":
      "Przygotowuje do restartu: wstrzymuje backup, odpina obraz i czeka na wysyłkę.",
    "Pausing the backup...":
      "Wstrzymuję backup...",
    "Detaching the image and waiting for the upload...":
      "Odpinam obraz i czekam na wysyłkę...",
    "Do NOT restart yet - the buffer holds data that has not reached Drive.":
      "NIE RESTARTUJ jeszcze - w buforze są dane, które nie doleciały na Dysk.",
    "Check the state:  %@":
      "Sprawdź stan:  %@",
    "Safe to restart. After startup the agents will bring up the buffer and attach the image themselves.":
      "Można restartować. Po starcie agenty podniosą bufor i podepną obraz same.",
    "State of the buffer, the upload queue and Time Machine.":
      "Stan bufora, kolejki wysyłki i Time Machine.",
    "Tools:            %@":
      "Narzędzia:        %@",
    "missing: %@":
      "brakuje: %@",
    "Drive mount:      %@":
      "Montowanie Drive: %@",
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
    "Image attached:   %@":
      "Obraz podpięty:   %@",
    "Remote control:   %@":
      "Sterowanie rc:    %@",
    "private socket":
      "prywatne gniazdo",
    "OPEN on %@ - the mount was started by an older version, and any web page can send it commands. It switches to the private socket on its next start: run prepare-shutdown, then restart the Mac.":
      "OTWARTE na %@ - montowanie uruchomiła starsza wersja i każda strona WWW może wysyłać mu polecenia. Przejdzie na prywatne gniazdo przy następnym starcie: uruchom prepare-shutdown, potem zrestartuj Maca.",
    "no socket - the mount is not running":
      "brak gniazda - montowanie nie działa",
    "Cache on disk:    %@":
      "Cache na dysku:   %@",
    "To upload:        %@":
      "Do wysłania:      %@",
    "Free on disk:     %@":
      "Wolne na dysku:   %@",
    "Upload queue:     %@ in progress, %@ queued, %@ errors":
      "Kolejka wysyłki:  %@ w toku, %@ w kolejce, %@ błędów",
    "Upload queue:     (rc interface unreachable)":
      "Kolejka wysyłki:  (interfejs rc nieosiągalny)",
    "Restart without asking: %@":
      "Restart bez pytania: %@",
    "YES - queue empty":
      "TAK - kolejka pusta",
    "NO - run prepare-shutdown first":
      "NIE - najpierw prepare-shutdown",
    "Upload:           %@":
      "Wysyłka:          %@",
    "TM destination:   %@":
      "Cel Time Machine: %@",
    "TM destination:   none":
      "Cel Time Machine: brak",
    "Backup:           running, %@%% (%@)":
      "Backup:           trwa, %@%% (%@)",
    "Backup:           not running":
      "Backup:           nie trwa",
    "Backup watchdog:  %@":
      "Czujka backupu:   %@",
    "Pulls FUSE-T into CloudMachine, so there is no separate app in the system.":
      "Wciąga FUSE-T do CloudMachine, żeby nie było osobnej aplikacji w systemie.",
    "Downloads the official rclone binary (the Homebrew one cannot mount).":
      "Pobiera oficjalną binarkę rclone (ta z Homebrew nie umie montować).",
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
