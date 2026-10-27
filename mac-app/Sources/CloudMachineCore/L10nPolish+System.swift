// Polish translations, keyed by the English text passed to `L10n.tr`.
extension L10nPolish {
  static let system: [String: String] = [
    "This Mac is close to its space limit on Google Drive":
      "Ten Mac zbliża się do swojego limitu miejsca na Google Drive",
    "%@ GB of %@ GB used. Time Machine deletes the oldest backups to stay within its quota; check that the quota is set (vm-status).":
      "Zajęte %@ GB z %@ GB. Time Machine kasuje najstarsze kopie, żeby zmieścić się w limicie; sprawdź, czy limit jest ustawiony (vm-status).",
    "This Mac is over its space limit on Google Drive":
      "Ten Mac przekroczył swój limit miejsca na Google Drive",
    "%@ GB of %@ GB used. Set the Time Machine quota (command in the app window or vm-status), or raise the limit.":
      "Zajęte %@ GB z %@ GB. Ustaw limit Time Machine (polecenie w oknie aplikacji albo w vm-status) albo podnieś limit.",
    "not set":
      "nie ustawiony",
    "%@ GB - usage not measured yet":
      "%@ GB - zajętość jeszcze nie zmierzona",
    "%@ of %@ GB used (%@%%)":
      "zajęte %@ z %@ GB (%@%%)",
    "The limit must be a whole number of GB above zero.":
      "Limit musi być całkowitą liczbą GB większą od zera.",
    "machines.json cannot be read, so it was not overwritten. Fix or remove it first.":
      "Nie da się odczytać machines.json, więc nie został nadpisany. Najpierw go popraw albo usuń.",
    // DriveFolder
    "'%@' is not a valid folder name: use lowercase letters, digits and dashes.":
      "'%@' to nieprawidłowa nazwa folderu: użyj małych liter, cyfr i myślników.",
    "This Mac already backs up to folder '%@'. Switching to '%@' would start a new, empty backup and orphan the existing one, so nothing was changed.":
      "Ten Mac już robi kopię do folderu '%@'. Przejście na '%@' zaczęłoby nową, pustą kopię i osierociło istniejącą, więc nic nie zmieniono.",
    "This Mac already has a CloudMachine installation, whose backup is in folder '%@'. Switching to '%@' would orphan it, so nothing was changed.":
      "Ten Mac ma już instalację CloudMachine, której kopia leży w folderze '%@'. Przejście na '%@' by ją osierociło, więc nic nie zmieniono.",
    "Could not save the folder name to %@: %@":
      "Nie udało się zapisać nazwy folderu w %@: %@",
    "Homebrew is not installed. Install it manually: https://brew.sh":
      "Homebrew nie jest zainstalowany. Zainstaluj go ręcznie: https://brew.sh",
    "Installing rclone failed: %@":
      "Instalacja rclone nie powiodła się: %@",
    "unknown error":
      "nieznany błąd",
    "Installed rclone.":
      "Zainstalowano rclone.",
    "Own Google credentials: set.":
      "Własne poświadczenia Google: ustawione.",
    "INCOMPLETE: %@ is missing - rclone will use rclone's shared client_id anyway.":
      "NIEPEŁNE: brakuje %@ - rclone i tak użyje współdzielonego client_id rclone.",
    "No own credentials - rclone uses the shared client_id, rate-limited jointly and being retired in 2026.":
      "Brak własnych poświadczeń - rclone używa współdzielonego client_id, limitowanego wspólnie i wycofywanego w 2026.",
    "Empty value - not saving.":
      "Pusta wartość - nie zapisuję.",
    "Keychain refused: %@":
      "Keychain odmówił: %@",
    "DIRTY-TREE":
      "BRUDNE-DRZEWO",
    "Cannot create the working directory: %@":
      "Nie mogę utworzyć katalogu roboczego: %@",
    "Could not read the rclone version number.":
      "Nie udało się odczytać numeru wersji rclone.",
    "Could not download %@.":
      "Nie udało się pobrać %@.",
    "No entry for %@ in SHA256SUMS.":
      "Brak wpisu dla %@ w SHA256SUMS.",
    "Could not compute the checksum.":
      "Nie udało się policzyć sumy kontrolnej.",
    "SHA256 checksum does not match - NOT installing.\n  expected: %@\n  computed: %@":
      "Suma SHA256 się nie zgadza - NIE instaluję.\n  oczekiwana: %@\n  policzona: %@",
    "Could not unpack the archive.":
      "Nie udało się rozpakować archiwum.",
    "Could not install the binary: %@":
      "Nie udało się zainstalować binarki: %@",
    "Installed rclone %@ in %@ (SHA256 checksum matches).":
      "Zainstalowano rclone %@ w %@ (suma SHA256 zgodna).",
    "%@ did not respond within the allotted time (the process was left orphaned in the background).":
      "%@ nie odpowiedziało w wyznaczonym czasie (proces został osierocony w tle).",
    "Cannot launch %@: %@":
      "Nie można uruchomić %@: %@",
    "Remote '%@' already exists and was NOT touched.\nOverwriting it replaces the token and the permission scope; a credential with the 'drive.file' scope does not see files created by the previous one, so the existing backup becomes unreachable.\nIf you really want to replace it, first back up ~/.config/rclone/rclone.conf and run again with --replace-existing.":
      "Remote '%@' już istnieje i NIE został ruszony.\nNadpisanie go podmienia token i zakres uprawnień; poświadczenie z zakresem 'drive.file' nie widzi plików założonych przez poprzednie, więc istniejący backup staje się nieosiągalny.\nJeśli naprawdę chcesz go zastąpić, zrób najpierw kopię ~/.config/rclone/rclone.conf i uruchom ponownie z --replace-existing.",
    "Could not check whether remote '%@' already exists (rclone listremotes did not answer or failed), so nothing was changed. Run `%@ listremotes` to see the error, then try again.":
      "Nie udało się sprawdzić, czy remote '%@' już istnieje (rclone listremotes nie odpowiedział albo zgłosił błąd), więc nic nie zostało zmienione. Uruchom `%@ listremotes`, żeby zobaczyć błąd, i spróbuj ponownie.",
    "Could not check whether this Mac already has a CloudMachine installation (rclone did not answer), so no folder was chosen. Try again in a moment.":
      "Nie udało się sprawdzić, czy ten Mac ma już instalację CloudMachine (rclone nie odpowiedział), więc folder nie został wybrany. Spróbuj ponownie za chwilę.",
    "rclone authorize failed (%@). If that binary is missing, start with: cloudmachine-agent install-rclone.":
      "rclone authorize nie powiodło się (%@). Jeśli tej binarki nie ma, zacznij od: cloudmachine-agent install-rclone.",
    "Could not read the token from the output of rclone authorize.":
      "Nie udało się odczytać tokenu z wyniku rclone authorize.",
    "rclone config create failed.":
      "rclone config create nie powiodło się.",
    "Connected to Google Drive as remote '%@', folder %@.":
      "Połączono z Google Drive jako remote '%@', folder %@.",
    "Time Machine does not point to CloudMachine":
      "Time Machine nie wskazuje na CloudMachine",
    "tmutil is not responding - unknown where the backup goes":
      "tmutil nie odpowiada - nie wiadomo, gdzie idzie backup",
    "No successful backup for %@":
      "Brak udanej kopii od %@",
    "Last COMPLETED backup: %@. The cycle is hourly, so that is %@ missed runs.":
      "Ostatnia ZAKOŃCZONA kopia: %@. Cykl jest godzinowy, więc to %@ pominiętych przebiegów.",
    "There is NOT A SINGLE successful backup":
      "Nie ma ANI JEDNEJ udanej kopii",
    "The Time Machine preferences contain no date of a completed backup for this destination.":
      "Preferencje Time Machine nie zawierają żadnej daty zakończonego backupu dla tego celu.",
    "The last backup attempt did not end in a backup":
      "Ostatnia próba backupu nie skończyła się kopią",
    "The attempt at %@ is newer than the last successful backup at %@.":
      "Próba %@ jest nowsza niż ostatnia udana kopia %@.",
    "Time Machine reports an error in the last run (RESULT=%@)":
      "Time Machine zgłasza błąd ostatniego przebiegu (RESULT=%@)",
    "A non-zero RESULT in the Time Machine preferences means the run did not succeed.":
      "Niezerowy RESULT w preferencjach Time Machine znaczy, że przebieg się nie udał.",
    "rclone failed to upload %@ files":
      "rclone nie wysłał %@ plików",
    "Buffer full of nothing but unsent data":
      "Bufor pełny samymi niewysłanymi danymi",
    "rclone has nothing left to evict from the buffer - the upload cannot keep up or has stalled.":
      "rclone nie ma już czego usunąć z bufora - wysyłka nie nadąża albo stoi.",
    "The rclone control interface is not responding":
      "Interfejs sterujący rclone nie odpowiada",
    "Google Drive is running out of space (%@ GB)":
      "Kończy się miejsce na Google Drive (%@ GB)",
    "The Mac's disk is running out of space (%@ GB)":
      "Kończy się miejsce na dysku Maca (%@ GB)",
    "Cannot read the Time Machine preferences":
      "Nie da się odczytać preferencji Time Machine",
    "%@ is unreadable - most often Full Disk Access is missing. Without this file it is UNKNOWN when the last backup was made, so we treat it as a failure, not as the absence of a problem.":
      "%@ jest nieczytelny - najczęściej brak Pełnego dostępu do dysku. Bez tego pliku NIE WIADOMO, kiedy ostatnio powstała kopia, więc traktujemy to jak awarię, a nie jak brak problemu.",
    "Cannot measure free space on the Mac's disk":
      "Nie da się zmierzyć wolnego miejsca na dysku Maca",
    "%@ days":
      "%@ dni",
    "CloudMachine: backup is not working":
      "CloudMachine: backup nie działa",
    "unknown reason":
      "nieznany powód",
    "osascript did not show the notification (permissions or no graphical session)":
      "osascript nie pokazał powiadomienia (uprawnienia albo brak sesji graficznej)",
    "UNDELIVERED ALARM: %@":
      "NIEDORĘCZONY ALARM: %@",
    "from %@, reason: %@":
      "z %@, powód: %@",
    "The system notification was not delivered - you will see this alarm ONLY here.":
      "Powiadomienie systemowe nie doszło - ten alarm zobaczysz TYLKO tutaj.",
    "%@ (%@ ago)":
      "%@ (%@ temu)",
    "%@ - marker from the FUTURE":
      "%@ - znacznik z PRZYSZŁOŚCI",
    "%@ (%@ ago) - THE WATCHDOG MAY NOT BE RUNNING":
      "%@ (%@ temu) - CZUJKA MOŻE NIE CHODZIĆ",
    "NEVER - the watchdog has not recorded a single run":
      "NIGDY - czujka nie zapisała żadnego przebiegu",
    "Could not find the launchd/ directory with templates.":
      "Nie znaleziono katalogu launchd/ z szablonami.",
    "Could not find the compiled cloudmachine-agent binary.":
      "Nie znaleziono skompilowanej binarki cloudmachine-agent.",
    "ABORTED: could not put cloudmachine-agent in a stable location\n(%@) - most often a lack of space or permissions.\nNOT installing agents pointing at %@: that path\ndisappears on the next `swift build` or `git clean`, and backups stop\nwithout any visible signal.":
      "PRZERWANO: nie udało się odłożyć cloudmachine-agent w stabilnym miejscu\n(%@) - najczęściej brak miejsca albo uprawnień.\nNIE instaluję agentów wskazujących na %@: ta ścieżka\nznika przy kolejnym `swift build` albo `git clean`, a backupy ustają\nbez żadnego widocznego sygnału.",
    "ABORTED: %@":
      "PRZERWANO: %@",
    "Could not list the templates in %@.":
      "Nie udało się wylistować szablonów w %@.",
    "could not read the template %@":
      "nie dało się odczytać szablonu %@",
    "could not write %@ (lack of space or permissions)":
      "nie udało się zapisać %@ (brak miejsca albo uprawnień)",
    "launchctl load refused to load %@":
      "launchctl load odmówił załadowania %@",
    "NOT A SINGLE agent was loaded.":
      "Nie załadowano ANI JEDNEGO agenta.",
    "Only these went in: %@.":
      "Weszły tylko: %@.",
    "Could not load any launchd agent.":
      "Nie udało się załadować żadnego agenta launchd.",
    "Installed agents: %@":
      "Zainstalowano agentów: %@",
  ]
}
