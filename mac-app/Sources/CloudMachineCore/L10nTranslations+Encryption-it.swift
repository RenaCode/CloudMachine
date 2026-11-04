// Italian translations of vm-encrypt (DriveEncryption), keyed by the English text.
extension L10nTranslations {
  static let itEncryption: [String: String] = [
    "%@ and its metadata are in Google Drive's bin (kept 30 days, still counted in the quota).":
      "%@ e i suoi metadati sono nel cestino di Google Drive (conservati 30 giorni, ancora conteggiati nella quota).",
    "'%@' is already in %@ - not replacing its password.":
      "'%@' è già in %@ – la sua password non viene sostituita.",
    "'%@' is already in the machine's rclone.conf - not replacing its password.":
      "'%@' è già nel rclone.conf della macchina – la sua password non viene sostituita.",
    "%@ holds folders this key cannot read: another password or salt in the machine, or leftovers of an earlier try. Compare the machine's rclone.conf with the Mac's; leftovers have to be removed from %@ by hand.":
      "%@ contiene cartelle che questa chiave non può leggere: un'altra password o sale nella macchina, oppure resti di un tentativo precedente. Confronta il rclone.conf della macchina con quello del Mac; i resti vanno rimossi a mano da %@.",
    "'%@' is incomplete or missing in the Mac's rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "'%@' è incompleto o manca nel rclone.conf del Mac – esegui: cloudmachine-agent vm-encrypt setup",
    "CLOUDMACHINE_VM_INSTANCE=%@ needs its own rclone.conf - set RCLONE_CONFIG to a copy, not %@. Its Keychain entry is service %@.":
      "CLOUDMACHINE_VM_INSTANCE=%@ ha bisogno di un proprio rclone.conf – imposta RCLONE_CONFIG su una copia, non su %@. La sua voce nel portachiavi è il servizio %@.",
    "Could not read the '%@' section on the Mac or in the machine.":
      "Impossibile leggere la sezione '%@' sul Mac o nella macchina.",
    "The machine's '%@' (password, salt or folder) differs from the Mac's - the copy would be readable only with the machine's key. Not moving anything.":
      "'%@' della macchina (password, sale o cartella) è diverso da quello del Mac – la copia sarebbe leggibile solo con la chiave della macchina. Non viene spostato nulla.",
    "A file was restored from the encrypted backup.":
      "Un file è stato ripristinato dal backup cifrato.",
    "Added '%@' (%@) on the Mac and in the machine; password and salt are in the Keychain (service %@).\nSALT: %@\nKeep the password AND this salt outside this Mac now - without both the encrypted backup cannot be read. Next: cloudmachine-agent vm-encrypt copy":
      "Aggiunto '%@' (%@) sul Mac e nella macchina; password e sale sono nel portachiavi (servizio %@).\nSALE: %@\nConserva ora la password E questo sale fuori da questo Mac – senza entrambi il backup cifrato non si può leggere. Poi: cloudmachine-agent vm-encrypt copy",
    "Adds the encrypted remote on the Mac and in the machine (asks for the password). Moves no data.":
      "Aggiunge il remoto cifrato sul Mac e nella macchina (chiede la password). Non sposta dati.",
    "Again: ":
      "Ancora: ",
    "Copies the plain backup into the encrypted folder, in the background; backups go on.":
      "Copia il backup non cifrato nella cartella cifrata, in background; i backup continuano.",
    "Copy:             %@":
      "Copia:            %@",
    "CLOUDMACHINE_VM_INSTANCE=%@ without CLOUDMACHINE_VM_REMOTE would use the live backup's folder - set both.":
      "CLOUDMACHINE_VM_INSTANCE=%@ senza CLOUDMACHINE_VM_REMOTE userebbe la cartella del backup in uso – impostale entrambe.",
    "Could not add the remote to %@: %@":
      "Impossibile aggiungere il remoto a %@: %@",
    "Could not add the remote to the machine's rclone.conf.":
      "Impossibile aggiungere il remoto al rclone.conf della macchina.",
    "Could not read %@.":
      "Impossibile leggere %@.",
    "Could not read when Time Machine last finished a backup (Full Disk Access?) - not deleting.":
      "Impossibile sapere quando Time Machine ha completato l'ultimo backup (Accesso completo al disco?) – nessuna eliminazione.",
    "Could not start the copy: %@":
      "Impossibile avviare la copia: %@",
    "Could not write %@.":
      "Impossibile scrivere %@.",
    "Deleting the plain folder failed: %@":
      "Eliminazione della cartella non cifrata non riuscita: %@",
    "Encrypted folder: %@":
      "Cartella cifrata: %@",
    "Encryption password: ":
      "Password di cifratura: ",
    "Machine uses:     %@":
      "La macchina usa:  %@",
    "Moves the backup on Google Drive under rclone encryption: setup, copy, switch, then delete-plain.":
      "Porta il backup su Google Drive sotto la cifratura di rclone: setup, copy, switch, poi delete-plain.",
    "Moves the plain folder to Google Drive's bin - only after a backup has finished into the encrypted one.":
      "Sposta la cartella non cifrata nel cestino di Google Drive – solo dopo che un backup è terminato in quella cifrata.",
    "Moving the machine failed; it went back to %@: %@":
      "Il passaggio della macchina non è riuscito; è tornata a %@: %@",
    "No answer from rclone in the machine - the upload queue is unknown.":
      "Nessuna risposta da rclone nella macchina – la coda di caricamento è sconosciuta.",
    "No backup has finished into the encrypted folder yet (last one %@, switched %@) - not deleting.":
      "Nessun backup è ancora terminato nella cartella cifrata (l'ultimo %@, passaggio %@) – nessuna eliminazione.",
    "Not everything is on Google Drive yet (%@ MB unsent, %@ uploading, %@ failed). Wait until the upload is done: cloudmachine-agent vm-status":
      "Non è ancora tutto su Google Drive (%@ MB non inviati, %@ in caricamento, %@ non riusciti). Attendi la fine del caricamento: cloudmachine-agent vm-status",
    "Restore a file from the encrypted backup first (Time Machine, Browse), then confirm with --restore-checked.":
      "Ripristina prima un file dal backup cifrato (Time Machine, Sfoglia), poi conferma con --restore-checked.",
    "Shows which folder the machine uses and the copy.":
      "Mostra quale cartella usa la macchina e lo stato della copia.",
    "Switched:         %@":
      "Passaggio:        %@",
    "The copy is already running - see: cloudmachine-agent vm-encrypt status":
      "La copia è già in corso – vedi: cloudmachine-agent vm-encrypt status",
    "The copy runs in the machine (%@, log %@). Backups go on meanwhile. Check: cloudmachine-agent vm-encrypt status":
      "La copia è in esecuzione nella macchina (%@, log %@). Nel frattempo i backup continuano. Controlla: cloudmachine-agent vm-encrypt status",
    "The copy to the encrypted folder has not finished well (%@) - run: cloudmachine-agent vm-encrypt copy, and wait for it.":
      "La copia nella cartella cifrata non è terminata correttamente (%@) – esegui: cloudmachine-agent vm-encrypt copy, e attendila.",
    "The encryption password and salt are kept outside this Mac.":
      "La password di cifratura e il sale sono conservati fuori da questo Mac.",
    "The guard holds Time Machine paused and would resume it during the switch. Wait until it resumes and the upload is done.":
      "Il guardiano tiene Time Machine in pausa e la riprenderebbe durante il passaggio. Attendi che riprenda e che il caricamento sia terminato.",
    "The image metadata has not been copied to the encrypted folder since the last backup - not deleting.":
      "I metadati dell'immagine non sono stati copiati nella cartella cifrata dall'ultimo backup – nessuna eliminazione.",
    "The last sync or cryptcheck failed - the machine was NOT moved: %@":
      "L'ultima sincronizzazione o cryptcheck non è riuscita – la macchina NON è stata spostata: %@",
    "The machine already uses the encrypted folder - nothing to switch.":
      "La macchina usa già la cartella cifrata – nulla da spostare.",
    "The machine already uses the encrypted folder.":
      "La macchina usa già la cartella cifrata.",
    "The machine does not use the encrypted folder - nothing to roll back.":
      "La macchina non usa la cartella cifrata – nulla da annullare.",
    "The machine does not use the encrypted folder - the plain folder is the backup. Not deleting it.":
      "La macchina non usa la cartella cifrata – la cartella non cifrata è il backup. Non viene eliminata.",
    "The machine has no '%@' remote in its rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "La macchina non ha il remoto '%@' nel suo rclone.conf – esegui: cloudmachine-agent vm-encrypt setup",
    "The machine is not on this app's template or does not use %@ (cloudmachine-agent vm-update first): %@":
      "La macchina non usa il modello di questa app o non usa %@ (prima cloudmachine-agent vm-update): %@",
    "The machine now uses %@, but %@ could not be updated (%@) - fix it before anything else runs vm-setup.":
      "La macchina ora usa %@, ma non è stato possibile aggiornare %@ (%@) – correggilo prima che qualcosa esegua vm-setup.",
    "The machine now uses %@. %@ is kept. Turn automatic backups back on: sudo tmutil enable":
      "La macchina ora usa %@. %@ viene conservata. Riattiva i backup automatici: sudo tmutil enable",
    "The password must have at least 12 characters.":
      "La password deve avere almeno 12 caratteri.",
    "The passwords differ - nothing was changed.":
      "Le password non coincidono – non è stato modificato nulla.",
    "The switch the other way: decrypts what changed back into the plain folder and uses it again.":
      "Il passaggio nell'altro senso: decifra ciò che è cambiato nella cartella non cifrata e torna a usarla.",
    "The upload to the encrypted folder is not finished (or rclone did not answer) - not deleting.":
      "Il caricamento nella cartella cifrata non è terminato (o rclone non ha risposto) – nessuna eliminazione.",
    "Time Machine is backing up. Turn automatic backups off (sudo tmutil disable), stop it (tmutil stopbackup), then run this again.":
      "Time Machine sta eseguendo un backup. Disattiva i backup automatici (sudo tmutil disable), fermala (tmutil stopbackup), poi esegui di nuovo questo comando.",
    "With Time Machine stopped: last sync, cryptcheck, then the machine uses the encrypted folder. The plain one stays.":
      "Con Time Machine ferma: ultima sincronizzazione, cryptcheck, poi la macchina usa la cartella cifrata. Quella non cifrata resta.",
    "Without the encryption password and salt the encrypted backup cannot be read. Keep both outside this Mac (a password manager, paper), then confirm with --secrets-saved-elsewhere.":
      "Senza password di cifratura e sale il backup cifrato non si può leggere. Conservali entrambi fuori da questo Mac (gestore di password, carta), poi conferma con --secrets-saved-elsewhere.",
    "rclone obscure failed.":
      "rclone obscure non è riuscito.",
    "tmutil did not answer - not switching while Time Machine's state is unknown.":
      "tmutil non ha risposto – nessun passaggio finché lo stato di Time Machine è sconosciuto.",
  ]
}
