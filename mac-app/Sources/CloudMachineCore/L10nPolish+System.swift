// Polish translations, keyed by the English text passed to `L10n.tr`.
extension L10nPolish {
  static let system: [String: String] = [
    "This Mac is close to its space limit on Google Drive":
      "Ten Mac zbliża się do swojego limitu miejsca na Google Drive",
    "%@ GB of %@ GB used. Time Machine deletes the oldest backups to stay within its quota; check that the quota is set (drive-status).":
      "Zajęte %@ GB z %@ GB. Time Machine kasuje najstarsze kopie, żeby zmieścić się w limicie; sprawdź, czy limit jest ustawiony (drive-status).",
    "This Mac is over its space limit on Google Drive":
      "Ten Mac przekroczył swój limit miejsca na Google Drive",
    "%@ GB of %@ GB used. Set the Time Machine quota (command in the app window or drive-status), or raise the limit.":
      "Zajęte %@ GB z %@ GB. Ustaw limit Time Machine (polecenie w oknie aplikacji albo w drive-status) albo podnieś limit.",
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
    "rclone with mount support":
      "rclone z obsługą montowania",
    "Could not determine the FUSE-T version.":
      "Nie udało się ustalić wersji FUSE-T.",
    "Could not download the FUSE-T package.":
      "Nie udało się pobrać pakietu FUSE-T.",
    "Could not unpack the FUSE-T package.":
      "Nie udało się rozpakować pakietu FUSE-T.",
    "The FUSE-T package does not contain the expected files.":
      "W pakiecie FUSE-T nie ma spodziewanych plików.",
    "Installing FUSE-T failed: %@":
      "Instalacja FUSE-T nie powiodła się: %@",
    "Installed FUSE-T %@ inside CloudMachine (%@).\nThe separate fuse-t application is no longer needed - you can remove it:\n  sudo \"/Library/Application Support/fuse-t/uninstall.sh\"":
      "Zainstalowano FUSE-T %@ wewnątrz CloudMachine (%@).\nOsobna aplikacja fuse-t nie jest już potrzebna - możesz ją usunąć:\n  sudo \"/Library/Application Support/fuse-t/uninstall.sh\"",
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
    "rclone authorize failed (%@). If that binary is missing, start with: cloudmachine-agent install-rclone.":
      "rclone authorize nie powiodło się (%@). Jeśli tej binarki nie ma, zacznij od: cloudmachine-agent install-rclone.",
    "Could not read the token from the output of rclone authorize.":
      "Nie udało się odczytać tokenu z wyniku rclone authorize.",
    "rclone config create failed.":
      "rclone config create nie powiodło się.",
    "Connected to Google Drive, but could not create the folder '%@' - without it the mount will not start. Check the account permissions and try again.":
      "Połączono z Google Drive, ale nie udało się utworzyć folderu '%@' - bez niego montowanie nie ruszy. Sprawdź uprawnienia konta i spróbuj ponownie.",
    "Connected to Google Drive as remote '%@', folder %@.":
      "Połączono z Google Drive jako remote '%@', folder %@.",
    "Google Drive mount is not working":
      "Montowanie Google Drive nie działa",
    "Without it the backup image is unreachable and Time Machine has nowhere to write.":
      "Bez niego obraz backupu jest nieosiągalny i Time Machine nie ma gdzie pisać.",
    "Unknown whether the Google Drive mount is working":
      "Nie wiadomo, czy montowanie Google Drive działa",
    "Could not read the mount table. That does not mean the Drive is unmounted - it means nobody has checked. Without this answer there is no way to tell whether backups have anywhere to go.":
      "Nie udało się odczytać tablicy montowań. To nie znaczy, że Dysk jest odmontowany - znaczy, że nikt tego nie sprawdził. Bez tej odpowiedzi nie da się stwierdzić, czy kopie mają gdzie powstawać.",
    "The backup image is attached, but DEAD (errno %@)":
      "Obraz backupu jest podpięty, ale MARTWY (errno %@)",
    "The image device stopped returning data - Time Machine sees it as a disconnected disk. Fix: cloudmachine-agent attach-image (force-detaches and attaches again).":
      "Urządzenie obrazu przestało oddawać dane - Time Machine widzi to jako odłączony dysk. Naprawa: cloudmachine-agent attach-image (odpina na siłę i podpina na nowo).",
    "The backup image is not attached":
      "Obraz backupu nie jest podpięty",
    "Time Machine cannot see the destination %@.":
      "Time Machine nie widzi celu %@.",
    "Unknown whether the backup image returns data":
      "Nie wiadomo, czy obraz backupu oddaje dane",
    "The image %@ is listed in the mount table, but the readability probe did not answer within %@ s - that is how a read blocked on a dead FUSE-T mount behaves. This is NOT proof that the image is dead, so do NOT force-detach it: `attach-image` deliberately does nothing in that case, because detaching a live device abandons data waiting to be uploaded. First check whether rclone responds (cloudmachine-agent drive-status) and whether the gdrive-buffer agent is alive.":
      "Obraz %@ figuruje w tablicy montowań, ale sonda czytelności nie odpowiedziała w %@ s - tak zachowuje się odczyt zablokowany na martwym montowaniu FUSE-T. To NIE jest dowód, że obraz jest martwy, więc NIE odpinaj go na siłę: `attach-image` świadomie nic wtedy nie robi, bo odpięcie żywego urządzenia porzuca dane czekające na wysyłkę. Sprawdź najpierw, czy rclone odpowiada (cloudmachine-agent drive-status) i czy agent gdrive-buffer żyje.",
    "Unknown whether the backup image is attached":
      "Nie wiadomo, czy obraz backupu jest podpięty",
    "Could not read the mount table, so the state of the image %@ is UNKNOWN. Do not attach it blindly - first check whether `mount` responds at all (with a dead FUSE-T mount it can hang).":
      "Nie udało się odczytać tablicy montowań, więc stan obrazu %@ jest NIEZNANY. Nie podpinaj go na oślep - najpierw sprawdź, czy `mount` w ogóle odpowiada (przy martwym montowaniu FUSE-T potrafi wisieć).",
    "Time Machine does not point to CloudMachine":
      "Time Machine nie wskazuje na CloudMachine",
    "The backup destination was changed or unregistered - backups are not being made.":
      "Cel backupu został przestawiony albo wyrejestrowany - kopie nie powstają.",
    "tmutil is not responding - unknown where the backup goes":
      "tmutil nie odpowiada - nie wiadomo, gdzie idzie backup",
    "Reading the Time Machine destination did not return within %@ s. That is how tmutil behaves when blocked on a dead Google Drive mount. Fix: cloudmachine-agent attach-image, and if that does not help - restart the gdrive-buffer agent.":
      "Odczyt celu Time Machine nie wrócił w %@ s. Tak zachowuje się tmutil zablokowany na martwym montowaniu Google Drive. Naprawa: cloudmachine-agent attach-image, a gdy to nie pomoże - restart agenta gdrive-buffer.",
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
    "These image bands exist only locally. The backup on Google Drive is INCOMPLETE and may not open.":
      "Te pasma obrazu istnieją tylko lokalnie. Kopia na Google Drive jest NIEPEŁNA i może się nie otworzyć.",
    "Buffer full of nothing but unsent data":
      "Bufor pełny samymi niewysłanymi danymi",
    "rclone has nothing left to evict from the buffer - the upload cannot keep up or has stalled.":
      "rclone nie ma już czego usunąć z bufora - wysyłka nie nadąża albo stoi.",
    "The rclone control interface is not responding":
      "Interfejs sterujący rclone nie odpowiada",
    "Without it there is no way to check whether anything reached the Drive - the buffer guard is blind then.":
      "Bez niego nie da się sprawdzić, czy cokolwiek doleciało na Dysk - dozorca bufora jest wtedy ślepy.",
    "Google Drive is running out of space (%@ GB)":
      "Kończy się miejsce na Google Drive (%@ GB)",
    "Once it runs out, rclone exits with a storageQuotaExceeded error, the mount disappears and backups stop being made. At a growth of ~600 MB per hourly cycle that is about %@ days.":
      "Po wyczerpaniu rclone kończy pracę z błędem storageQuotaExceeded, montowanie znika i backupy przestają powstawać. Przy przyroście ~600 MB na cykl godzinowy to około %@ dni.",
    "The Mac's disk is running out of space (%@ GB)":
      "Kończy się miejsce na dysku Maca (%@ GB)",
    "The upload buffer lives on this disk. When it fills up, the guard pauses Time Machine, and with no space left at all rclone has nowhere to put data waiting to be uploaded.":
      "Bufor wysyłki leży na tym dysku. Gdy się zapełni, dozorca wstrzyma Time Machine, a przy całkowitym braku miejsca rclone nie ma gdzie odłożyć danych czekających na wysłanie.",
    "Cannot read the Time Machine preferences":
      "Nie da się odczytać preferencji Time Machine",
    "%@ is unreadable - most often Full Disk Access is missing. Without this file it is UNKNOWN when the last backup was made, so we treat it as a failure, not as the absence of a problem.":
      "%@ jest nieczytelny - najczęściej brak Pełnego dostępu do dysku. Bez tego pliku NIE WIADOMO, kiedy ostatnio powstała kopia, więc traktujemy to jak awarię, a nie jak brak problemu.",
    "Cannot measure free space on the Mac's disk":
      "Nie da się zmierzyć wolnego miejsca na dysku Maca",
    "statfs('/System/Volumes/Data') returned an error. The buffer guard will then not pause Time Machine before the disk fills up, because it does not know the number it bases that decision on.":
      "statfs('/System/Volumes/Data') zwrócił błąd. Dozorca bufora nie wstrzyma wtedy Time Machine przed zapełnieniem dysku, bo nie zna liczby, na której opiera tę decyzję.",
    "%@ days":
      "%@ dni",
    "CloudMachine: backup is not working":
      "CloudMachine: backup nie działa",
    "unknown reason":
      "nieznany powód",
    "osascript did not show the notification (permissions or no graphical session)":
      "osascript nie pokazał powiadomienia (uprawnienia albo brak sesji graficznej)",
    "MISSING":
      "BRAK",
    "UNKNOWN - could not read the mount table":
      "NIE WIADOMO - nie udało się odczytać tablicy montowań",
    "NOT MEASURED - the buffer guard will not pause Time Machine before the disk fills up":
      "NIE ZMIERZONO - dozorca bufora nie wstrzyma Time Machine przed zapełnieniem dysku",
    "NOT MEASURED - rclone did not respond, and walking the buffer directory failed":
      "NIE ZMIERZONO - rclone nie odpowiedział, a obchód katalogu bufora się nie udał",
    "%@ GB of %@G":
      "%@ GB z %@G",
    "UNKNOWN - the rclone control interface did not respond (the buffer guard will neither pause nor resume Time Machine on this basis)":
      "NIE WIADOMO - interfejs sterujący rclone nie odpowiedział (dozorca bufora nie wstrzyma ani nie wznowi Time Machine na tej podstawie)",
    "~%@ GB (%@ items)":
      "~%@ GB (%@ pozycji)",
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
    "The image was not detached before reloading the agents - aborting, so as not to lose data waiting in the buffer.\n%@":
      "Nie odpięto obrazu przed przeładowaniem agentów - przerywam, żeby nie stracić danych czekających w buforze.\n%@",
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
    "Agent installation INCOMPLETE - %@ of %@ did not go in:\n%@\n%@\nEvery missing agent is a function that has silently stopped working (buffer-guard watches the disk, backup-health reports failures). Fix the cause and repeat the installation.":
      "Instalacja agentów NIEPEŁNA - nie weszło %@ z %@:\n%@\n%@\nKażdy brakujący agent to funkcja, która przestała działać po cichu (buffer-guard pilnuje dysku, backup-health zgłasza awarie). Napraw powód i powtórz instalację.",
    "Could not load any launchd agent.":
      "Nie udało się załadować żadnego agenta launchd.",
    "Installed agents: %@":
      "Zainstalowano agentów: %@",
  ]
}
