// Norwegian Bokmal translations of vm-encrypt (DriveEncryption), keyed by the English text.
extension L10nTranslations {
  static let nbEncryption: [String: String] = [
    "%@ and its metadata are in Google Drive's bin (kept 30 days, still counted in the quota).":
      "%@ og metadataene ligger i papirkurven i Google Drive (beholdes i 30 dager og teller fortsatt med i kvoten).",
    "'%@' is already in %@ - not replacing its password.":
      "'%@' finnes allerede i %@ – passordet erstattes ikke.",
    "'%@' is already in the machine's rclone.conf - not replacing its password.":
      "'%@' finnes allerede i maskinens rclone.conf – passordet erstattes ikke.",
    "%@ holds folders this key cannot read: another password or salt in the machine, or leftovers of an earlier try. Compare the machine's rclone.conf with the Mac's; leftovers have to be removed from %@ by hand.":
      "%@ inneholder mapper denne nøkkelen ikke kan lese: et annet passord eller salt i maskinen, eller rester fra et tidligere forsøk. Sammenlign maskinens rclone.conf med Mac-ens; rester må fjernes fra %@ for hånd.",
    "'%@' is incomplete or missing in the Mac's rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "'%@' er ufullstendig eller mangler i Mac-ens rclone.conf – kjør: cloudmachine-agent vm-encrypt setup",
    "CLOUDMACHINE_VM_INSTANCE=%@ needs its own rclone.conf - set RCLONE_CONFIG to a copy, not %@. Its Keychain entry is service %@.":
      "CLOUDMACHINE_VM_INSTANCE=%@ trenger sin egen rclone.conf – sett RCLONE_CONFIG til en kopi, ikke %@. Oppføringen i nøkkelringen er tjenesten %@.",
    "Could not read the '%@' section on the Mac or in the machine.":
      "Kunne ikke lese delen '%@' på Mac-en eller i maskinen.",
    "The machine's '%@' (password, salt or folder) differs from the Mac's - the copy would be readable only with the machine's key. Not moving anything.":
      "Maskinens '%@' (passord, salt eller mappe) avviker fra Mac-ens – kopien ville bare kunne leses med maskinens nøkkel. Ingenting flyttes.",
    "A file was restored from the encrypted backup.":
      "En fil ble gjenopprettet fra den krypterte sikkerhetskopien.",
    "Added '%@' (%@) on the Mac and in the machine; password and salt are in the Keychain (service %@).\nSALT: %@\nKeep the password AND this salt outside this Mac now - without both the encrypted backup cannot be read. Next: cloudmachine-agent vm-encrypt copy":
      "La til '%@' (%@) på Mac-en og i maskinen; passord og salt ligger i nøkkelringen (tjeneste %@).\nSALT: %@\nOppbevar passordet OG dette saltet utenfor denne Mac-en nå – uten begge kan den krypterte sikkerhetskopien ikke leses. Neste: cloudmachine-agent vm-encrypt copy",
    "Adds the encrypted remote on the Mac and in the machine (asks for the password). Moves no data.":
      "Legger til det krypterte fjernlageret på Mac-en og i maskinen (spør om passordet). Flytter ingen data.",
    "Again: ":
      "En gang til: ",
    "Copies the plain backup into the encrypted folder, in the background; backups go on.":
      "Kopierer den ukrypterte sikkerhetskopien til den krypterte mappen i bakgrunnen; sikkerhetskopieringen fortsetter.",
    "Copy:             %@":
      "Kopi:             %@",
    "CLOUDMACHINE_VM_INSTANCE=%@ without CLOUDMACHINE_VM_REMOTE would use the live backup's folder - set both.":
      "CLOUDMACHINE_VM_INSTANCE=%@ uten CLOUDMACHINE_VM_REMOTE ville brukt mappen til den aktive sikkerhetskopien – sett begge.",
    "Could not add the remote to %@: %@":
      "Kunne ikke legge til fjernlageret i %@: %@",
    "Could not add the remote to the machine's rclone.conf.":
      "Kunne ikke legge til fjernlageret i maskinens rclone.conf.",
    "Could not read %@.":
      "Kunne ikke lese %@.",
    "Could not read when Time Machine last finished a backup (Full Disk Access?) - not deleting.":
      "Kunne ikke lese når Time Machine sist fullførte en sikkerhetskopi (Full disktilgang?) – ingenting slettes.",
    "Could not start the copy: %@":
      "Kunne ikke starte kopieringen: %@",
    "Could not write %@.":
      "Kunne ikke skrive %@.",
    "Deleting the plain folder failed: %@":
      "Sletting av den ukrypterte mappen mislyktes: %@",
    "Encrypted folder: %@":
      "Kryptert mappe:   %@",
    "Encryption password: ":
      "Krypteringspassord: ",
    "Machine uses:     %@":
      "Maskinen bruker:  %@",
    "Moves the backup on Google Drive under rclone encryption: setup, copy, switch, then delete-plain.":
      "Flytter sikkerhetskopien på Google Drive inn under rclones kryptering: setup, copy, switch og deretter delete-plain.",
    "Moves the plain folder to Google Drive's bin - only after a backup has finished into the encrypted one.":
      "Flytter den ukrypterte mappen til papirkurven i Google Drive – først etter at en sikkerhetskopi er fullført i den krypterte.",
    "Moving the machine failed; it went back to %@: %@":
      "Omleggingen av maskinen mislyktes; den er tilbake på %@: %@",
    "No answer from rclone in the machine - the upload queue is unknown.":
      "Ingen svar fra rclone i maskinen – opplastingskøen er ukjent.",
    "No backup has finished into the encrypted folder yet (last one %@, switched %@) - not deleting.":
      "Ingen sikkerhetskopi er fullført i den krypterte mappen ennå (siste %@, lagt om %@) – ingenting slettes.",
    "Not everything is on Google Drive yet (%@ MB unsent, %@ uploading, %@ failed). Wait until the upload is done: cloudmachine-agent vm-status":
      "Ikke alt er på Google Drive ennå (%@ MB ikke sendt, %@ lastes opp, %@ mislyktes). Vent til opplastingen er ferdig: cloudmachine-agent vm-status",
    "Restore a file from the encrypted backup first (Time Machine, Browse), then confirm with --restore-checked.":
      "Gjenopprett først en fil fra den krypterte sikkerhetskopien (Time Machine, Bla gjennom), og bekreft deretter med --restore-checked.",
    "Shows which folder the machine uses and the copy.":
      "Viser hvilken mappe maskinen bruker, og hvordan kopieringen ligger an.",
    "Switched:         %@":
      "Lagt om:          %@",
    "The copy is already running - see: cloudmachine-agent vm-encrypt status":
      "Kopieringen kjører allerede – se: cloudmachine-agent vm-encrypt status",
    "The copy runs in the machine (%@, log %@). Backups go on meanwhile. Check: cloudmachine-agent vm-encrypt status":
      "Kopieringen kjører i maskinen (%@, logg %@). Sikkerhetskopieringen fortsetter imens. Sjekk: cloudmachine-agent vm-encrypt status",
    "The copy to the encrypted folder has not finished well (%@) - run: cloudmachine-agent vm-encrypt copy, and wait for it.":
      "Kopieringen til den krypterte mappen ble ikke fullført riktig (%@) – kjør: cloudmachine-agent vm-encrypt copy, og vent på den.",
    "The encryption password and salt are kept outside this Mac.":
      "Krypteringspassordet og saltet oppbevares utenfor denne Mac-en.",
    "The guard holds Time Machine paused and would resume it during the switch. Wait until it resumes and the upload is done.":
      "Vakten holder Time Machine på pause og ville gjenopptatt den under omleggingen. Vent til den er gjenopptatt og opplastingen er ferdig.",
    "The image metadata has not been copied to the encrypted folder since the last backup - not deleting.":
      "Bildets metadata er ikke kopiert til den krypterte mappen siden siste sikkerhetskopi – ingenting slettes.",
    "The last sync or cryptcheck failed - the machine was NOT moved: %@":
      "Den siste synkroniseringen eller cryptcheck mislyktes – maskinen ble IKKE flyttet: %@",
    "The machine already uses the encrypted folder - nothing to switch.":
      "Maskinen bruker allerede den krypterte mappen – ingenting å legge om.",
    "The machine already uses the encrypted folder.":
      "Maskinen bruker allerede den krypterte mappen.",
    "The machine does not use the encrypted folder - nothing to roll back.":
      "Maskinen bruker ikke den krypterte mappen – ingenting å rulle tilbake.",
    "The machine does not use the encrypted folder - the plain folder is the backup. Not deleting it.":
      "Maskinen bruker ikke den krypterte mappen – den ukrypterte mappen er sikkerhetskopien. Den slettes ikke.",
    "The machine has no '%@' remote in its rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "Maskinen har ikke fjernlageret '%@' i sin rclone.conf – kjør: cloudmachine-agent vm-encrypt setup",
    "The machine is not on this app's template or does not use %@ (cloudmachine-agent vm-update first): %@":
      "Maskinen bruker ikke denne appens mal eller bruker ikke %@ (først cloudmachine-agent vm-update): %@",
    "The machine now uses %@, but %@ could not be updated (%@) - fix it before anything else runs vm-setup.":
      "Maskinen bruker nå %@, men %@ kunne ikke oppdateres (%@) – rett det før noe annet kjører vm-setup.",
    "The machine now uses %@. %@ is kept. Turn automatic backups back on: sudo tmutil enable":
      "Maskinen bruker nå %@. %@ beholdes. Slå på automatisk sikkerhetskopiering igjen: sudo tmutil enable",
    "The password must have at least 12 characters.":
      "Passordet må ha minst 12 tegn.",
    "The passwords differ - nothing was changed.":
      "Passordene er forskjellige – ingenting ble endret.",
    "The switch the other way: decrypts what changed back into the plain folder and uses it again.":
      "Omleggingen den andre veien: dekrypterer det som er endret tilbake til den ukrypterte mappen og bruker den igjen.",
    "The upload to the encrypted folder is not finished (or rclone did not answer) - not deleting.":
      "Opplastingen til den krypterte mappen er ikke ferdig (eller rclone svarte ikke) – ingenting slettes.",
    "Time Machine is backing up. Turn automatic backups off (sudo tmutil disable), stop it (tmutil stopbackup), then run this again.":
      "Time Machine sikkerhetskopierer nå. Slå av automatisk sikkerhetskopiering (sudo tmutil disable), stopp den (tmutil stopbackup), og kjør dette igjen.",
    "With Time Machine stopped: last sync, cryptcheck, then the machine uses the encrypted folder. The plain one stays.":
      "Med Time Machine stoppet: siste synkronisering, cryptcheck, så bruker maskinen den krypterte mappen. Den ukrypterte blir værende.",
    "Without the encryption password and salt the encrypted backup cannot be read. Keep both outside this Mac (a password manager, paper), then confirm with --secrets-saved-elsewhere.":
      "Uten krypteringspassordet og saltet kan den krypterte sikkerhetskopien ikke leses. Oppbevar begge utenfor denne Mac-en (en passordbehandler, papir), og bekreft deretter med --secrets-saved-elsewhere.",
    "rclone obscure failed.":
      "rclone obscure mislyktes.",
    "tmutil did not answer - not switching while Time Machine's state is unknown.":
      "tmutil svarte ikke – ingen omlegging så lenge tilstanden til Time Machine er ukjent.",
  ]
}
