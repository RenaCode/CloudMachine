// Polish translations, keyed by the English text passed to `L10n.tr`.
// The machine layout: vm-setup, vm-prepare-bundle, vm-guard, vm-status.
extension L10nPolish {
  static let vm: [String: String] = [
    "                  WARNING: close to the limit - new bands will fail with EMFILE":
      "                  UWAGA: blisko limitu - nowe pasma skończą się błędem EMFILE",
    "%@/bands on Google Drive is not empty - it may hold another backup. NOT overwriting it; check it by hand.":
      "%@/bands na Google Drive nie jest pusty - może tam być inna kopia. NIE nadpisuję; sprawdź ręcznie.",
    "Address:          %@":
      "Adres:            %@",
    "Already prepared (%@ exists) - nothing to do.":
      "Już przygotowany (istnieje %@) - nie ma nic do zrobienia.",
    "Also install the vm-start and vm-guard launchd agents.":
      "Zainstaluj też agentów launchd vm-start i vm-guard.",
    "Converts Time Machine's new, empty image in the machine to 32 MB bands and moves the bands to Google Drive.":
      "Przerabia nowy, pusty obraz Time Machine w maszynie na pasma 32 MB i przenosi pasma na Google Drive.",
    "Copy rclone.conf into the machine even if it already has one.":
      "Skopiuj rclone.conf do maszyny, nawet jeśli już go ma.",
    "Copying the converted image into the machine failed: %@":
      "Kopiowanie przerobionego obrazu do maszyny nie powiodło się: %@",
    "Copying the image to the Mac failed: %@":
      "Kopiowanie obrazu na Maca nie powiodło się: %@",
    "Could not ask Lima about the machine: %@":
      "Nie udało się zapytać Limy o maszynę: %@",
    "Could not carry the Time Machine files over: %@":
      "Nie udało się przenieść plików Time Machine: %@",
    "Could not check the image in the machine.":
      "Nie udało się sprawdzić obrazu w maszynie.",
    "Could not copy the rclone configuration into the machine.":
      "Nie udało się skopiować konfiguracji rclone do maszyny.",
    "Could not create %@ on Google Drive: %@":
      "Nie udało się założyć %@ na Google Drive: %@",
    "Could not create %@: %@":
      "Nie udało się utworzyć %@: %@",
    "Could not find the vm/ directory with the machine template.":
      "Nie znaleziono katalogu vm/ z szablonem maszyny.",
    "Could not read the image size.":
      "Nie udało się odczytać rozmiaru obrazu.",
    "Could not set the SMB password of user %@ in the machine.":
      "Nie udało się ustawić hasła SMB użytkownika %@ w maszynie.",
    "Could not stop smbd in the machine.":
      "Nie udało się zatrzymać smbd w maszynie.",
    "Could not write %@ in the machine.":
      "Nie udało się zapisać %@ w maszynie.",
    "Could not write the password file %@.":
      "Nie udało się zapisać pliku z hasłem %@.",
    "Creates or starts the CloudMachine machine (Lima), gives it rclone's configuration and an SMB password, and prints the Time Machine command.":
      "Tworzy albo uruchamia maszynę CloudMachine (Lima), przekazuje jej konfigurację rclone i hasło SMB, i wypisuje polecenie dla Time Machine.",
    "Creating the machine %@ (first start downloads Ubuntu and installs packages - several minutes)...":
      "Tworzę maszynę %@ (pierwszy start pobiera Ubuntu i instaluje pakiety - kilka minut)...",
    "Done: %@ has %@ MB bands on Google Drive; the original is kept in %@ in the machine. Start the backup: tmutil startbackup":
      "Gotowe: %@ ma pasma %@ MB na Google Drive; oryginał leży w %@ w maszynie. Uruchom kopię: tmutil startbackup",
    "exit code %@, no message":
      "kod wyjścia %@, bez komunikatu",
    "Free in machine:  %@ GiB":
      "Wolne w maszynie: %@ GiB",
    "fsck_apfs -n found problems: %@":
      "fsck_apfs -n znalazł problemy: %@",
    "Google Drive folder: %@":
      "Folder na Google Drive: %@",
    "hdiutil attach of the converted image failed: %@":
      "hdiutil attach przerobionego obrazu nie powiódł się: %@",
    "hdiutil convert failed: %@":
      "hdiutil convert nie powiódł się: %@",
    "Image name in the machine (default: from the computer name).":
      "Nazwa obrazu w maszynie (domyślnie: z nazwy komputera).",
    "Installing the converted image FAILED: %@\nsmbd is left STOPPED so Time Machine does not open a half-installed image. The original is in %@ in the machine.":
      "Instalacja przerobionego obrazu NIE POWIODŁA SIĘ: %@\nsmbd zostaje ZATRZYMANY, żeby Time Machine nie otworzył w połowie zainstalowanego obrazu. Oryginał leży w %@ w maszynie.",
    "limactl create failed: %@":
      "limactl create nie powiódł się: %@",
    "limactl list failed: %@":
      "limactl list nie powiódł się: %@",
    "limactl not found - install Lima: brew install lima":
      "Nie znaleziono limactl - zainstaluj Limę: brew install lima",
    "limactl start failed: %@\nThe machine's own log: %@":
      "limactl start nie powiódł się: %@\nWłasny dziennik maszyny: %@",
    "Machine %@ is running.":
      "Maszyna %@ działa.",
    "Machine %@ was already running.":
      "Maszyna %@ już działała.",
    "Machine:          %@ (%@)":
      "Maszyna:          %@ (%@)",
    "Machine:          %@":
      "Maszyna:          %@",
    "Machine:          not created - run: cloudmachine-agent vm-setup":
      "Maszyna:          nie utworzona - uruchom: cloudmachine-agent vm-setup",
    "no answer within the time limit":
      "brak odpowiedzi w limicie czasu",
    "No image %@ in the machine.":
      "W maszynie nie ma obrazu %@.",
    "No image in the machine yet - point Time Machine at the share and let it create one first.":
      "W maszynie nie ma jeszcze obrazu - najpierw wskaż Time Machine udział i pozwól mu go utworzyć.",
    "No rclone configuration at %@ - connect Google Drive first (configure-remote).":
      "Brak konfiguracji rclone w %@ - najpierw połącz Google Drive (configure-remote).",
    "no SMB destination":
      "brak celu SMB",
    "One check of the machine's upload buffer: pauses Time Machine when it fills, resumes what it paused.":
      "Jedno sprawdzenie bufora wysyłki maszyny: wstrzymuje Time Machine, gdy bufor się zapełnia, i wznawia to, co sam wstrzymał.",
    "Packing the converted image failed: %@":
      "Pakowanie przerobionego obrazu nie powiodło się: %@",
    "Packing the image failed: %@":
      "Pakowanie obrazu nie powiodło się: %@",
    "Pause above this many GiB in the buffer.":
      "Wstrzymaj powyżej tylu GiB w buforze.",
    "Pause when the machine has less free than this, in GiB.":
      "Wstrzymaj, gdy maszyna ma mniej wolnego miejsca niż tyle GiB.",
    "Point Time Machine at the machine (once, needs an administrator password):":
      "Wskaż Time Machine maszynę (raz, wymaga hasła administratora):",
    "punchfs files:    %@ open, limit %@":
      "Pliki punchfs:    %@ otwartych, limit %@",
    "rclone configuration already in the machine - kept (--replace-rclone-config replaces it).":
      "Konfiguracja rclone już jest w maszynie - zostawiona (--replace-rclone-config ją podmienia).",
    "rclone configuration copied into the machine.":
      "Konfiguracja rclone skopiowana do maszyny.",
    "rclone-tm or punchfs is not running in the machine - see cloudmachine-agent vm-status.":
      "rclone-tm albo punchfs nie działa w maszynie - patrz cloudmachine-agent vm-status.",
    "Resume below this many GiB (only a backup the guard paused).":
      "Wznów poniżej tylu GiB (tylko kopię wstrzymaną przez strażnika).",
    "Service %@: %@":
      "Usługa %@: %@",
    "Several images in the machine (%@) - choose one with --bundle.":
      "W maszynie jest kilka obrazów (%@) - wybierz jeden przez --bundle.",
    "Shows the machine: address, services, upload buffer, free space and the Time Machine destination.":
      "Pokazuje maszynę: adres, usługi, bufor wysyłki, wolne miejsce i cel Time Machine.",
    "SMB password stored in %@ (mode 600).":
      "Hasło SMB zapisane w %@ (uprawnienia 600).",
    "The converted image does not have %@-byte bands.":
      "Przerobiony obraz nie ma pasm po %@ bajtów.",
    "The converted image has no APFS partition.":
      "Przerobiony obraz nie ma partycji APFS.",
    "The image already takes %@ MB - this command converts only a new, empty image (under %@ MB).":
      "Obraz zajmuje już %@ MB - to polecenie przerabia tylko nowy, pusty obraz (poniżej %@ MB).",
    "The image is encrypted - converting encrypted images is not supported.":
      "Obraz jest zaszyfrowany - przerabianie zaszyfrowanych obrazów nie jest obsługiwane.",
    "The image was not changed; smbd started again.":
      "Obraz nie został zmieniony; smbd uruchomiony ponownie.",
    "The machine does not answer - is it running? cloudmachine-agent vm-status":
      "Maszyna nie odpowiada - czy działa? cloudmachine-agent vm-status",
    "The machine has no address on the vzNAT network.":
      "Maszyna nie ma adresu w sieci vzNAT.",
    "The services in the machine did not start - check: cloudmachine-agent vm-status":
      "Usługi w maszynie nie wystartowały - sprawdź: cloudmachine-agent vm-status",
    "Time Machine is backing up - stop it first: tmutil stopbackup":
      "Time Machine robi kopię - najpierw ją zatrzymaj: tmutil stopbackup",
    "Time Machine:     %@":
      "Time Machine:     %@",
    "Time Machine:     NOT pointing at the machine (%@)":
      "Time Machine:     NIE wskazuje maszyny (%@)",
    "Time Machine:     tmutil did not answer":
      "Time Machine:     tmutil nie odpowiedział",
    "tmutil did not answer - not touching the image while its state is unknown.":
      "tmutil nie odpowiedział - nie ruszam obrazu, dopóki jego stan jest nieznany.",
    "unknown":
      "nieznany",
    "Unpacking the image failed: %@":
      "Rozpakowanie obrazu nie powiodło się: %@",
    "Still to upload:  %@ GiB in %@ bands, uploading %@ (cache on disk %@ GiB)":
      "Do wysłania:      %@ GiB w %@ pasmach, wysyłane %@ (cache na dysku %@ GiB)",
    "Upload buffer:    no answer from rclone (rc %@)":
      "Bufor wysyłki:    brak odpowiedzi rclone (rc %@)",
    "When Time Machine has created its empty image, stop the backup (tmutil stopbackup) and run: cloudmachine-agent vm-prepare-bundle":
      "Gdy Time Machine utworzy pusty obraz, zatrzymaj kopię (tmutil stopbackup) i uruchom: cloudmachine-agent vm-prepare-bundle",
  ]
}
