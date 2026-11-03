// Polish translations, keyed by the English text passed to `L10n.tr`.
// Encryption of the backup on Google Drive: vm-encrypt.
extension L10nPolish {
  static let encryption: [String: String] = [
    "%@ and its metadata are in Google Drive's bin (kept 30 days, still counted in the quota).":
      "%@ wraz z metadanymi jest w koszu Google Drive (trzymany 30 dni, nadal liczony do limitu miejsca).",
    "'%@' is already in %@ - not replacing its password.":
      "'%@' już jest w %@ - nie podmieniam jego hasła.",
    "'%@' is already in the machine's rclone.conf - not replacing its password.":
      "'%@' już jest w rclone.conf maszyny - nie podmieniam jego hasła.",
    "A file was restored from the encrypted backup.":
      "Plik został odtworzony z zaszyfrowanej kopii.",
    "Added '%@' (%@) on the Mac and in the machine; password and salt are in the Keychain (service %@).\nSALT: %@\nKeep the password AND this salt outside this Mac now - without both the encrypted backup cannot be read. Next: cloudmachine-agent vm-encrypt copy":
      "Dodano '%@' (%@) na Macu i w maszynie; hasło i sól są w pęku kluczy (usługa %@).\nSÓL: %@\nZapisz teraz hasło ORAZ tę sól poza tym Makiem - bez obu zaszyfrowanej kopii nie da się odczytać. Dalej: cloudmachine-agent vm-encrypt copy",
    "Adds the encrypted remote on the Mac and in the machine (asks for the password). Moves no data.":
      "Dodaje zaszyfrowany remote na Macu i w maszynie (pyta o hasło). Nie przenosi danych.",
    "Again: ":
      "Jeszcze raz: ",
    "Copies the plain backup into the encrypted folder, in the background; backups go on.":
      "Kopiuje niezaszyfrowaną kopię do zaszyfrowanego folderu, w tle; kopie trwają dalej.",
    "Copy:             %@":
      "Kopiowanie:      %@",
    "Could not add the remote to %@: %@":
      "Nie udało się dodać remote do %@: %@",
    "Could not add the remote to the machine's rclone.conf.":
      "Nie udało się dodać remote do rclone.conf maszyny.",
    "Could not read %@.":
      "Nie udało się odczytać %@.",
    "Could not read when Time Machine last finished a backup (Full Disk Access?) - not deleting.":
      "Nie udało się odczytać, kiedy Time Machine ostatnio skończył kopię (pełny dostęp do dysku?) - nie usuwam.",
    "Could not start the copy: %@":
      "Nie udało się uruchomić kopiowania: %@",
    "Could not write %@.":
      "Nie udało się zapisać %@.",
    "Deleting the plain folder failed: %@":
      "Usuwanie niezaszyfrowanego folderu nie powiodło się: %@",
    "Encrypted folder: %@":
      "Folder szyfrowany: %@",
    "Encryption password: ":
      "Hasło szyfrowania: ",
    "Machine uses:     %@":
      "Maszyna używa:   %@",
    "Moves the backup on Google Drive under rclone encryption: setup, copy, switch, then delete-plain.":
      "Przenosi kopię na Google Drive pod szyfrowanie rclone: setup, copy, switch, potem delete-plain.",
    "Moves the plain folder to Google Drive's bin - only after a backup has finished into the encrypted one.":
      "Przenosi niezaszyfrowany folder do kosza Google Drive - dopiero gdy kopia skończyła się do zaszyfrowanego.",
    "Moving the machine failed; it went back to %@: %@":
      "Przełączenie maszyny nie powiodło się; wróciła do %@: %@",
    "No answer from rclone in the machine - the upload queue is unknown.":
      "Brak odpowiedzi rclone w maszynie - kolejka wysyłki nieznana.",
    "No backup has finished into the encrypted folder yet (last one %@, switched %@) - not deleting.":
      "Żadna kopia nie skończyła się jeszcze do zaszyfrowanego folderu (ostatnia %@, przełączenie %@) - nie usuwam.",
    "Not everything is on Google Drive yet (%@ MB unsent, %@ uploading, %@ failed). Wait until the upload is done: cloudmachine-agent vm-status":
      "Nie wszystko jest jeszcze na Google Drive (%@ MB niewysłane, %@ w wysyłce, %@ z błędem). Poczekaj na koniec wysyłki: cloudmachine-agent vm-status",
    "Restore a file from the encrypted backup first (Time Machine, Browse), then confirm with --restore-checked.":
      "Najpierw odtwórz plik z zaszyfrowanej kopii (Time Machine, Przeglądaj), potem potwierdź przez --restore-checked.",
    "Shows which folder the machine uses and the copy.":
      "Pokazuje, którego folderu używa maszyna, i stan kopiowania.",
    "Switched:         %@":
      "Przełączono:     %@",
    "The copy is already running - see: cloudmachine-agent vm-encrypt status":
      "Kopiowanie już trwa - zobacz: cloudmachine-agent vm-encrypt status",
    "The copy runs in the machine (%@, log %@). Backups go on meanwhile. Check: cloudmachine-agent vm-encrypt status":
      "Kopiowanie trwa w maszynie (%@, log %@). Kopie w tym czasie trwają dalej. Sprawdzaj: cloudmachine-agent vm-encrypt status",
    "The copy to the encrypted folder has not finished well (%@) - run: cloudmachine-agent vm-encrypt copy, and wait for it.":
      "Kopiowanie do zaszyfrowanego folderu nie skończyło się dobrze (%@) - uruchom: cloudmachine-agent vm-encrypt copy i poczekaj na nie.",
    "The encryption password and salt are kept outside this Mac.":
      "Hasło szyfrowania i sól są zapisane poza tym Makiem.",
    "The guard holds Time Machine paused and would resume it during the switch. Wait until it resumes and the upload is done.":
      "Strażnik trzyma Time Machine wstrzymany i wznowiłby go w trakcie przełączania. Poczekaj, aż wznowi, a wysyłka się skończy.",
    "The image metadata has not been copied to the encrypted folder since the last backup - not deleting.":
      "Metadane obrazu nie zostały skopiowane do zaszyfrowanego folderu od ostatniej kopii - nie usuwam.",
    "The last sync or cryptcheck failed - the machine was NOT moved: %@":
      "Ostatnia synchronizacja albo cryptcheck nie powiodły się - maszyna NIE została przełączona: %@",
    "The machine already uses the encrypted folder - nothing to switch.":
      "Maszyna już używa zaszyfrowanego folderu - nie ma czego przełączać.",
    "The machine already uses the encrypted folder.":
      "Maszyna już używa zaszyfrowanego folderu.",
    "The machine does not use the encrypted folder - nothing to roll back.":
      "Maszyna nie używa zaszyfrowanego folderu - nie ma czego cofać.",
    "The machine does not use the encrypted folder - the plain folder is the backup. Not deleting it.":
      "Maszyna nie używa zaszyfrowanego folderu - kopią jest folder niezaszyfrowany. Nie usuwam go.",
    "The machine has no '%@' remote in its rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "Maszyna nie ma remote '%@' w rclone.conf - uruchom: cloudmachine-agent vm-encrypt setup",
    "The machine is not on this app's template or does not use %@ (cloudmachine-agent vm-update first): %@":
      "Maszyna nie jest na szablonie tej aplikacji albo nie używa %@ (najpierw cloudmachine-agent vm-update): %@",
    "The machine now uses %@, but %@ could not be updated (%@) - fix it before anything else runs vm-setup.":
      "Maszyna używa teraz %@, ale nie udało się zaktualizować %@ (%@) - popraw to, zanim cokolwiek uruchomi vm-setup.",
    "The machine now uses %@. %@ is kept. Turn automatic backups back on: sudo tmutil enable":
      "Maszyna używa teraz %@. %@ zostaje. Włącz z powrotem automatyczne kopie: sudo tmutil enable",
    "The password must have at least 12 characters.":
      "Hasło musi mieć co najmniej 12 znaków.",
    "The passwords differ - nothing was changed.":
      "Hasła się różnią - niczego nie zmieniono.",
    "The switch the other way: decrypts what changed back into the plain folder and uses it again.":
      "Przełączenie w drugą stronę: odszyfrowuje zmiany z powrotem do niezaszyfrowanego folderu i znów go używa.",
    "The upload to the encrypted folder is not finished (or rclone did not answer) - not deleting.":
      "Wysyłka do zaszyfrowanego folderu się nie skończyła (albo rclone nie odpowiedział) - nie usuwam.",
    "Time Machine is backing up. Turn automatic backups off (sudo tmutil disable), stop it (tmutil stopbackup), then run this again.":
      "Time Machine robi kopię. Wyłącz automatyczne kopie (sudo tmutil disable), zatrzymaj ją (tmutil stopbackup) i uruchom to ponownie.",
    "With Time Machine stopped: last sync, cryptcheck, then the machine uses the encrypted folder. The plain one stays.":
      "Przy zatrzymanym Time Machine: ostatnia synchronizacja, cryptcheck, potem maszyna używa zaszyfrowanego folderu. Niezaszyfrowany zostaje.",
    "Without the encryption password and salt the encrypted backup cannot be read. Keep both outside this Mac (a password manager, paper), then confirm with --secrets-saved-elsewhere.":
      "Bez hasła szyfrowania i soli zaszyfrowanej kopii nie da się odczytać. Zapisz oba poza tym Makiem (menedżer haseł, papier), potem potwierdź przez --secrets-saved-elsewhere.",
    "rclone obscure failed.":
      "rclone obscure nie powiodło się.",
    "tmutil did not answer - not switching while Time Machine's state is unknown.":
      "tmutil nie odpowiedział - nie przełączam, dopóki stan Time Machine jest nieznany.",
  ]
}
