// Polish translations, keyed by the English text passed to `L10n.tr`.
// The machine layout as the app, the watchdog and prepare-shutdown show it.
extension L10nPolish {
  static let machine: [String: String] = [
    "%@ GiB":
      "%@ GiB",
    "%@ GiB in %@ bands, %@ uploading":
      "%@ GiB w %@ pasmach, wysyłanych %@",
    "%@ bands":
      "%@ pasm",
    "%@ fragments abandoned - only in the machine":
      "%@ porzuconych fragmentów - tylko w maszynie",
    "127.0.0.1:5572 answers on the Mac: Lima forwards the machine's rclone remote control, which has no password. Any web page open in a browser can send it commands - including deleting the backup on Google Drive. Add the portForwards rule from vm/cmsmb.yaml to the machine and restart it (see vm/README.md).":
      "127.0.0.1:5572 odpowiada na Macu: Lima przekazuje zdalne sterowanie rclone z maszyny, które nie ma hasła. Każda strona otwarta w przeglądarce może wysłać mu polecenie - także usunięcie kopii na Google Drive. Dodaj do maszyny regułę portForwards z vm/cmsmb.yaml i uruchom ją ponownie (patrz vm/README.md).",
    "A service in the CloudMachine machine is not running":
      "Usługa w maszynie CloudMachine nie działa",
    "Address":
      "Adres",
    "Agent installation INCOMPLETE - %@ of %@ did not go in:\n%@\n%@\nEvery missing agent is a function that has silently stopped working (vm-guard watches the machine's buffer, backup-health reports failures). Fix the cause and repeat the installation.":
      "Instalacja agentów NIEPEŁNA - %@ z %@ nie weszło:\n%@\n%@\nKażdy brakujący agent to funkcja, która po cichu przestała działać (vm-guard pilnuje bufora maszyny, backup-health zgłasza awarie). Usuń przyczynę i powtórz instalację.",
    "All running":
      "Wszystkie działają",
    "Also install the launchd agents (same as install-launchd).":
      "Zainstaluj też agentów launchd (to samo co install-launchd).",
    "At most this many minutes of waiting for the upload.":
      "Najwyżej tyle minut czekania na wysyłkę.",
    "At the limit every new band fails with EMFILE and the backup stops. Check: cloudmachine-agent vm-status":
      "Przy limicie każde nowe pasmo kończy się błędem EMFILE i kopia staje. Sprawdź: cloudmachine-agent vm-status",
    "Cache on the machine's disk":
      "Pamięć podręczna na dysku maszyny",
    "Connected to Google Drive, but could not create the folder '%@' - without it the machine has nowhere to keep the backup. Check the account permissions and try again.":
      "Połączono z Google Drive, ale nie udało się utworzyć folderu '%@' - bez niego maszyna nie ma gdzie trzymać kopii. Sprawdź uprawnienia konta i spróbuj ponownie.",
    "Convert the image":
      "Przerób obraz",
    "Converting the image to 32 MB bands":
      "Przerabianie obrazu na pasma 32 MB",
    "Could not check with the current connection whether the backup is on Google Drive (%@), so remote '%@' was NOT replaced: without that answer the new sign-in cannot be checked against it.":
      "Nie udało się sprawdzić obecnym połączeniem, czy kopia jest na Google Drive (%@), więc zdalny '%@' NIE został zastąpiony: bez tej odpowiedzi nowego logowania nie da się z nią porównać.",
    "Downloads the official rclone binary into ~/.cloudmachine/bin (Google sign-in and the machine's rclone.conf).":
      "Pobiera oficjalną binarkę rclone do ~/.cloudmachine/bin (logowanie do Google i rclone.conf dla maszyny).",
    "Free in the machine":
      "Wolne w maszynie",
    "Free in the machine: %@":
      "Wolne w maszynie: %@",
    "Generates and installs the launchd agents (app, backup watchdog, machine start, machine guard).":
      "Generuje i instaluje agentów launchd (aplikacja, czujka kopii, start maszyny, strażnik maszyny).",
    "Install Lima, which runs the CloudMachine machine: run this in Terminal":
      "Zainstaluj Limę, która uruchamia maszynę CloudMachine: wykonaj to w Terminalu",
    "Install rclone (signs in to Google Drive for the machine)":
      "Zainstaluj rclone (loguje maszynę do Google Drive)",
    "Install the background agents (machine start, buffer guard, backup watchdog)":
      "Zainstaluj agentów w tle (start maszyny, strażnik bufora, czujka kopii)",
    "Installs rclone through Homebrew - CloudMachine itself uses the one from install-rclone.":
      "Instaluje rclone przez Homebrew - sam CloudMachine używa tego z install-rclone.",
    "Info.plist, token and mapped/ of the backup image exist only on the machine's disk; without them the bands in %@ cannot be restored. The copy (tm-meta-sync, every 15 min) goes to %@. Check: cloudmachine-agent vm-status, then in the machine: journalctl -u tm-meta-sync":
      "Info.plist, token i mapped/ obrazu kopii są tylko na dysku maszyny; bez nich pasm w %@ nie da się odtworzyć. Kopia (tm-meta-sync, co 15 min) trafia do %@. Sprawdź: cloudmachine-agent vm-status, potem w maszynie: journalctl -u tm-meta-sync",
    "Lima says the machine is running, but a command in it did not return. Without it nothing is known about Samba, rclone or the upload. Check: cloudmachine-agent vm-status":
      "Lima mówi, że maszyna działa, ale polecenie w niej nie wróciło. Bez tego nic nie wiadomo o Sambie, rclone ani wysyłce. Sprawdź: cloudmachine-agent vm-status",
    "Machine":
      "Maszyna",
    "Machine %@":
      "Maszyna %@",
    "Machine & Upload Status":
      "Stan maszyny i wysyłki",
    "Machine buffer":
      "Bufor maszyny",
    "No Time Machine destination is the machine's share (smb://tm@<address>/CloudMachine) - backups are not being made there. The command is printed by: cloudmachine-agent vm-setup":
      "Żaden cel Time Machine nie jest udziałem maszyny (smb://tm@<adres>/CloudMachine) - kopie nie trafiają tam. Polecenie wypisuje: cloudmachine-agent vm-setup",
    "Not running: %@":
      "Nie działa: %@",
    "Not set up":
      "Nieskonfigurowana",
    "Once it runs out, rclone stops uploading, the machine's buffer fills up and backups stop being made. At a growth of ~600 MB per hourly cycle that is about %@ days.":
      "Gdy się skończy, rclone przestaje wysyłać, bufor maszyny się zapełnia i kopie przestają powstawać. Przy przyroście ~600 MB na cykl godzinowy to około %@ dni.",
    "Or rclone.conf is missing: this Mac has already set up the CloudMachine machine, so it is not connected anew blindly. Restore the file from a backup (the machine keeps its own copy in %@). To connect anyway, create an empty file at the path `%@ config file` prints and run again - the existing folder is kept.":
      "Albo brakuje rclone.conf: ten Mac ma już skonfigurowaną maszynę CloudMachine, więc nie jest łączony od nowa na ślepo. Przywróć plik z kopii (maszyna trzyma własną kopię w %@). Żeby mimo to połączyć, utwórz pusty plik pod ścieżką, którą wypisuje `%@ config file`, i uruchom ponownie - istniejący folder zostanie zachowany.",
    "Point Time Machine at the machine: run this in Terminal (needs sudo; Copy includes the password)":
      "Skieruj Time Machine na maszynę: wykonaj to w Terminalu (wymaga sudo; Kopiuj zawiera hasło)",
    "Points to the machine":
      "Wskazuje na maszynę",
    "Prepares for a restart: stops the backup, waits a while for the upload, then stops the machine cleanly.":
      "Przygotowuje do restartu: zatrzymuje kopię, czeka chwilę na wysyłkę, potem czysto zatrzymuje maszynę.",
    "Reading the Time Machine destination did not return within %@ s. That is how tmutil behaves when its destination hangs.":
      "Odczyt celu Time Machine nie wrócił w %@ s. Tak zachowuje się tmutil, gdy jego cel wisi.",
    "Remote '%@' was NOT replaced. The new sign-in gets the 'drive.file' scope, which sees only files created under its own client_id. The existing backup was most likely created by the current connection and would become invisible to it. Before anything is written, the new token is checked against the existing backup, and the replacement is abandoned if it cannot see it. The machine keeps its own copy of the configuration until vm-setup --replace-rclone-config. To go ahead, run again with --replace-existing --accept-scope-change.":
      "Zdalny '%@' NIE został zastąpiony. Nowe logowanie dostaje zakres 'drive.file', który widzi tylko pliki utworzone pod własnym client_id. Istniejąca kopia najpewniej powstała przez obecne połączenie i stałaby się dla niego niewidoczna. Zanim cokolwiek zostanie zapisane, nowy token jest sprawdzany na istniejącej kopii, a zamiana jest porzucana, jeśli jej nie widzi. Maszyna trzyma własną kopię konfiguracji aż do vm-setup --replace-rclone-config. Żeby kontynuować, uruchom ponownie z --replace-existing --accept-scope-change.",
    "Remote control:   OPEN on the Mac at 127.0.0.1:5572 - any web page can send rclone commands; see vm/README.md (portForwards)":
      "Zdalne sterowanie: OTWARTE na Macu pod 127.0.0.1:5572 - każda strona może wysyłać polecenia rclone; patrz vm/README.md (portForwards)",
    "Running":
      "Działa",
    "Samba, rclone or punchfs in the machine is not active, so Time Machine has nowhere to write or the bands do not reach Google Drive. Check: cloudmachine-agent vm-status":
      "Samba, rclone albo punchfs w maszynie nie jest aktywna, więc Time Machine nie ma gdzie pisać albo pasma nie trafiają na Google Drive. Sprawdź: cloudmachine-agent vm-status",
    "Service %@":
      "Usługa %@",
    "Services":
      "Usługi",
    "Set up the CloudMachine machine (the first time it downloads Ubuntu - several minutes)":
      "Skonfiguruj maszynę CloudMachine (za pierwszym razem pobiera Ubuntu - kilka minut)",
    "Set up the CloudMachine machine again, so it prints the Time Machine command":
      "Skonfiguruj maszynę CloudMachine ponownie, żeby wypisała polecenie Time Machine",
    "Set up the machine":
      "Skonfiguruj maszynę",
    "Setting up the CloudMachine machine":
      "Konfigurowanie maszyny CloudMachine",
    "Start the CloudMachine machine":
      "Uruchom maszynę CloudMachine",
    "Start the machine":
      "Uruchom maszynę",
    "Starting the CloudMachine machine":
      "Uruchamianie maszyny CloudMachine",
    "Still to upload: %@ GiB":
      "Zostało do wysłania: %@ GiB",
    "Stopping the Time Machine backup...":
      "Zatrzymywanie kopii Time Machine...",
    "Stopping the machine %@...":
      "Zatrzymywanie maszyny %@...",
    "The CloudMachine machine does not answer":
      "Maszyna CloudMachine nie odpowiada",
    "The CloudMachine machine is not running":
      "Maszyna CloudMachine nie działa",
    "The CloudMachine machine is not set up yet":
      "Maszyna CloudMachine nie jest jeszcze skonfigurowana",
    "The CloudMachine machine is stopped":
      "Maszyna CloudMachine jest zatrzymana",
    "The backup is stopped, the upload gets up to 30 minutes, then the machine shuts down cleanly. It starts again at the next login.":
      "Kopia zostaje zatrzymana, wysyłka dostaje do 30 minut, potem maszyna czysto się wyłącza. Uruchomi się znowu przy następnym logowaniu.",
    "The machine %@ is not running - nothing to prepare.":
      "Maszyna %@ nie działa - nie ma czego przygotowywać.",
    "The machine is stopped and everything reached Google Drive. The Mac can be restarted; the machine starts again at login.":
      "Maszyna jest zatrzymana i wszystko dotarło na Google Drive. Można zrestartować Maca; maszyna uruchomi się znowu przy logowaniu.",
    "The machine is stopped. %@ GiB had not reached Google Drive yet - it is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "Maszyna jest zatrzymana. %@ GiB nie dotarło jeszcze na Google Drive - zostaje w buforze maszyny i zostanie wysłane po następnym starcie. Można zrestartować Maca.",
    "The machine is stopped. rclone did not say how much was still to upload; what was not uploaded is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "Maszyna jest zatrzymana. rclone nie powiedział, ile zostało do wysłania; to, co nie wyszło, zostaje w buforze maszyny i zostanie wysłane po następnym starcie. Można zrestartować Maca.",
    "The machine's disk is a file on this disk and grows as the upload buffer fills. With no space left the machine cannot write the buffer, and Time Machine's local snapshots have nowhere to go either.":
      "Dysk maszyny to plik na tym dysku i rośnie razem z buforem wysyłki. Bez wolnego miejsca maszyna nie zapisze bufora, a lokalne migawki Time Machine też nie mają gdzie trafić.",
    "The image's metadata has never been copied to Drive":
      "Metadane obrazu kopii nigdy nie trafiły na Drive",
    "The image's metadata was last copied to Drive %@ ago":
      "Metadane obrazu kopii trafiły na Drive ostatnio %@ temu",
    "The machine's disk is running out of space (%@ GB)":
      "Na dysku maszyny kończy się miejsce (%@ GB)",
    "The new sign-in does NOT see the existing backup (%@), so remote '%@' was NOT replaced and rclone.conf is unchanged. Keep the current connection, or sign in with the credential (client_id) that created the backup.":
      "Nowe logowanie NIE widzi istniejącej kopii (%@), więc zdalny '%@' NIE został zastąpiony, a rclone.conf jest bez zmian. Zostaw obecne połączenie albo zaloguj się poświadczeniem (client_id), które utworzyło kopię.",
    "The upload buffer lives on this disk. The guard pauses Time Machine before it fills; if the upload does not catch up, backups stay paused.":
      "Na tym dysku jest bufor wysyłki. Strażnik wstrzymuje Time Machine, zanim się zapełni; jeśli wysyłka nie nadgoni, kopie zostają wstrzymane.",
    "These bands exist only in the machine's buffer. The backup on Google Drive is INCOMPLETE and may not open.":
      "Te pasma istnieją tylko w buforze maszyny. Kopia na Google Drive jest NIEPEŁNA i może się nie otworzyć.",
    "Time Machine backs up to the machine, so without it no backup is made. Start it: limactl start %@ (or the Start button in the app).":
      "Time Machine robi kopię do maszyny, więc bez niej kopia nie powstaje. Uruchom ją: limactl start %@ (albo przyciskiem w aplikacji).",
    "Time Machine did not stop its backup within 2 minutes (or tmutil did not answer) - the machine was NOT stopped. Try again in a moment.":
      "Time Machine nie zatrzymał kopii w ciągu 2 minut (albo tmutil nie odpowiedział) - maszyna NIE została zatrzymana. Spróbuj za chwilę.",
    "Time Machine has created its image: stop the backup, then convert the image to 32 MB bands":
      "Time Machine utworzył obraz: zatrzymaj kopię, potem przerób obraz na pasma 32 MB",
    "To upload":
      "Do wysłania",
    "Unknown whether the CloudMachine machine is running":
      "Nie wiadomo, czy maszyna CloudMachine działa",
    "Waiting for the upload to Google Drive (at most %@ min)...":
      "Czekanie na wysyłkę na Google Drive (najwyżej %@ min)...",
    "With --replace-existing: confirms that the new sign-in (scope 'drive.file') may not see the existing backup. The new token is still checked against the backup first.":
      "Z --replace-existing: potwierdza, że nowe logowanie (zakres 'drive.file') może nie widzieć istniejącej kopii. Nowy token i tak jest najpierw sprawdzany na kopii.",
    "Without it there is no way to check whether anything reached the Drive - the machine's guard is blind then.":
      "Bez niego nie da się sprawdzić, czy cokolwiek dotarło na Drive - strażnik maszyny jest wtedy ślepy.",
    "limactl did not answer":
      "limactl nie odpowiedział",
    "limactl did not answer (or is not installed). That does not mean the machine is down - it means nobody has checked.":
      "limactl nie odpowiedział (albo nie jest zainstalowany). To nie znaczy, że maszyna nie działa - znaczy, że nikt tego nie sprawdził.",
    "limactl start failed: %@":
      "limactl start nie powiódł się: %@",
    "limactl stop failed: %@":
      "limactl stop nie powiódł się: %@",
    "punchfs is close to its open-file limit":
      "punchfs jest blisko limitu otwartych plików",
    "punchfs open files":
      "Otwarte pliki punchfs",
    "rclone's remote control is open on this Mac":
      "Zdalne sterowanie rclone jest otwarte na tym Macu",
    "statfs('/System/Volumes/Data') returned an error, so nobody knows whether the machine's disk can still grow on this Mac.":
      "statfs('/System/Volumes/Data') zwrócił błąd, więc nikt nie wie, czy dysk maszyny może jeszcze rosnąć na tym Macu.",
    "Google Drive's daily upload limit stops the upload":
      "Dzienny limit wysyłki Google Drive zatrzymał wysyłkę",
    "Google last refused an upload %@ ago (750 GB a day). Backups since then are only in the machine's buffer on this Mac. rclone retries every 5 min and resumes by itself when the limit passes; the guard pauses Time Machine if more than %@ GiB waits.":
      "Google ostatnio odrzucił wysyłkę %@ temu (750 GB na dobę). Kopie od tego czasu są tylko w buforze maszyny na tym Macu. rclone ponawia co 5 min i sam wznowi, gdy limit minie; strażnik wstrzyma Time Machine, jeśli czeka więcej niż %@ GiB.",
  ]
}
