// Danish translations of vm-encrypt (DriveEncryption), keyed by the English text.
extension L10nTranslations {
  static let daEncryption: [String: String] = [
    "%@ and its metadata are in Google Drive's bin (kept 30 days, still counted in the quota).":
      "%@ og dets metadata ligger i Google Drives papirkurv (gemmes i 30 dage og tæller stadig med i kvoten).",
    "'%@' is already in %@ - not replacing its password.":
      "'%@' findes allerede i %@ – adgangskoden erstattes ikke.",
    "'%@' is already in the machine's rclone.conf - not replacing its password.":
      "'%@' findes allerede i maskinens rclone.conf – adgangskoden erstattes ikke.",
    "%@ holds folders this key cannot read: another password or salt in the machine, or leftovers of an earlier try. Compare the machine's rclone.conf with the Mac's; leftovers have to be removed from %@ by hand.":
      "%@ indeholder mapper, som denne nøgle ikke kan læse: en anden adgangskode eller salt i maskinen eller rester fra et tidligere forsøg. Sammenlign maskinens rclone.conf med Mac'ens; rester skal fjernes fra %@ manuelt.",
    "'%@' is incomplete or missing in the Mac's rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "'%@' er ufuldstændig eller mangler i Mac'ens rclone.conf – kør: cloudmachine-agent vm-encrypt setup",
    "CLOUDMACHINE_VM_INSTANCE=%@ needs its own rclone.conf - set RCLONE_CONFIG to a copy, not %@. Its Keychain entry is service %@.":
      "CLOUDMACHINE_VM_INSTANCE=%@ skal have sin egen rclone.conf – sæt RCLONE_CONFIG til en kopi, ikke %@. Dens post i nøgleringen er tjenesten %@.",
    "Could not read the '%@' section on the Mac or in the machine.":
      "Afsnittet '%@' kunne ikke læses på Mac'en eller i maskinen.",
    "The machine's '%@' (password, salt or folder) differs from the Mac's - the copy would be readable only with the machine's key. Not moving anything.":
      "Maskinens '%@' (adgangskode, salt eller mappe) afviger fra Mac'ens – kopien ville kun kunne læses med maskinens nøgle. Intet flyttes.",
    "A file was restored from the encrypted backup.":
      "En fil blev gendannet fra den krypterede sikkerhedskopi.",
    "Added '%@' (%@) on the Mac and in the machine; password and salt are in the Keychain (service %@).\nSALT: %@\nKeep the password AND this salt outside this Mac now - without both the encrypted backup cannot be read. Next: cloudmachine-agent vm-encrypt copy":
      "'%@' (%@) er tilføjet på Mac'en og i maskinen; adgangskode og salt ligger i nøgleringen (tjeneste %@).\nSALT: %@\nGem nu adgangskoden OG dette salt uden for denne Mac – uden begge kan den krypterede sikkerhedskopi ikke læses. Næste: cloudmachine-agent vm-encrypt copy",
    "Adds the encrypted remote on the Mac and in the machine (asks for the password). Moves no data.":
      "Tilføjer det krypterede remote på Mac'en og i maskinen (spørger om adgangskoden). Flytter ingen data.",
    "Again: ":
      "Igen: ",
    "Copies the plain backup into the encrypted folder, in the background; backups go on.":
      "Kopierer den ukrypterede sikkerhedskopi til den krypterede mappe i baggrunden; sikkerhedskopieringen fortsætter.",
    "Copy:             %@":
      "Kopi:             %@",
    "CLOUDMACHINE_VM_INSTANCE=%@ without CLOUDMACHINE_VM_REMOTE would use the live backup's folder - set both.":
      "CLOUDMACHINE_VM_INSTANCE=%@ uden CLOUDMACHINE_VM_REMOTE ville bruge mappen med den aktive sikkerhedskopi – sæt begge.",
    "Could not add the remote to %@: %@":
      "Kunne ikke tilføje remote til %@: %@",
    "Could not add the remote to the machine's rclone.conf.":
      "Kunne ikke tilføje remote til maskinens rclone.conf.",
    "Could not read %@.":
      "Kunne ikke læse %@.",
    "Could not read when Time Machine last finished a backup (Full Disk Access?) - not deleting.":
      "Kunne ikke læse, hvornår Time Machine sidst gennemførte en sikkerhedskopi (Fuld diskadgang?) – intet slettes.",
    "Could not start the copy: %@":
      "Kunne ikke starte kopieringen: %@",
    "Could not write %@.":
      "Kunne ikke skrive %@.",
    "Deleting the plain folder failed: %@":
      "Sletning af den ukrypterede mappe mislykkedes: %@",
    "Encrypted folder: %@":
      "Krypteret mappe:  %@",
    "Encryption password: ":
      "Krypteringsadgangskode: ",
    "Machine uses:     %@":
      "Maskinen bruger:  %@",
    "Moves the backup on Google Drive under rclone encryption: setup, copy, switch, then delete-plain.":
      "Flytter sikkerhedskopien på Google Drive ind under rclones kryptering: setup, copy, switch og derefter delete-plain.",
    "Moves the plain folder to Google Drive's bin - only after a backup has finished into the encrypted one.":
      "Flytter den ukrypterede mappe til Google Drives papirkurv – først når en sikkerhedskopi er gennemført i den krypterede.",
    "Moving the machine failed; it went back to %@: %@":
      "Omstillingen af maskinen mislykkedes; den er tilbage på %@: %@",
    "No answer from rclone in the machine - the upload queue is unknown.":
      "Intet svar fra rclone i maskinen – uploadkøen er ukendt.",
    "No backup has finished into the encrypted folder yet (last one %@, switched %@) - not deleting.":
      "Endnu ingen sikkerhedskopi er gennemført i den krypterede mappe (seneste %@, omstillet %@) – intet slettes.",
    "Not everything is on Google Drive yet (%@ MB unsent, %@ uploading, %@ failed). Wait until the upload is done: cloudmachine-agent vm-status":
      "Ikke alt er på Google Drive endnu (%@ MB ikke sendt, %@ uploades, %@ mislykkedes). Vent, til uploaden er færdig: cloudmachine-agent vm-status",
    "Restore a file from the encrypted backup first (Time Machine, Browse), then confirm with --restore-checked.":
      "Gendan først en fil fra den krypterede sikkerhedskopi (Time Machine, Gennemse), og bekræft derefter med --restore-checked.",
    "Shows which folder the machine uses and the copy.":
      "Viser, hvilken mappe maskinen bruger, og hvordan kopieringen står.",
    "Switched:         %@":
      "Omstillet:        %@",
    "The copy is already running - see: cloudmachine-agent vm-encrypt status":
      "Kopieringen kører allerede – se: cloudmachine-agent vm-encrypt status",
    "The copy runs in the machine (%@, log %@). Backups go on meanwhile. Check: cloudmachine-agent vm-encrypt status":
      "Kopieringen kører i maskinen (%@, log %@). Sikkerhedskopieringen fortsætter imens. Tjek: cloudmachine-agent vm-encrypt status",
    "The copy to the encrypted folder has not finished well (%@) - run: cloudmachine-agent vm-encrypt copy, and wait for it.":
      "Kopieringen til den krypterede mappe er ikke afsluttet korrekt (%@) – kør: cloudmachine-agent vm-encrypt copy, og vent på den.",
    "The encryption password and salt are kept outside this Mac.":
      "Krypteringsadgangskoden og saltet opbevares uden for denne Mac.",
    "The guard holds Time Machine paused and would resume it during the switch. Wait until it resumes and the upload is done.":
      "Vagten holder Time Machine sat på pause og ville genoptage den under omstillingen. Vent, til den er genoptaget, og uploaden er færdig.",
    "The image metadata has not been copied to the encrypted folder since the last backup - not deleting.":
      "Billedets metadata er ikke kopieret til den krypterede mappe siden seneste sikkerhedskopi – intet slettes.",
    "The last sync or cryptcheck failed - the machine was NOT moved: %@":
      "Den sidste synkronisering eller cryptcheck mislykkedes – maskinen blev IKKE flyttet: %@",
    "The machine already uses the encrypted folder - nothing to switch.":
      "Maskinen bruger allerede den krypterede mappe – intet at omstille.",
    "The machine already uses the encrypted folder.":
      "Maskinen bruger allerede den krypterede mappe.",
    "The machine does not use the encrypted folder - nothing to roll back.":
      "Maskinen bruger ikke den krypterede mappe – intet at rulle tilbage.",
    "The machine does not use the encrypted folder - the plain folder is the backup. Not deleting it.":
      "Maskinen bruger ikke den krypterede mappe – den ukrypterede mappe er sikkerhedskopien. Den slettes ikke.",
    "The machine has no '%@' remote in its rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "Maskinen har intet remote '%@' i sin rclone.conf – kør: cloudmachine-agent vm-encrypt setup",
    "The machine is not on this app's template or does not use %@ (cloudmachine-agent vm-update first): %@":
      "Maskinen bruger ikke denne apps skabelon eller bruger ikke %@ (først cloudmachine-agent vm-update): %@",
    "The machine now uses %@, but %@ could not be updated (%@) - fix it before anything else runs vm-setup.":
      "Maskinen bruger nu %@, men %@ kunne ikke opdateres (%@) – ret det, før noget andet kører vm-setup.",
    "The machine now uses %@. %@ is kept. Turn automatic backups back on: sudo tmutil enable":
      "Maskinen bruger nu %@. %@ bevares. Slå automatisk sikkerhedskopiering til igen: sudo tmutil enable",
    "The password must have at least 12 characters.":
      "Adgangskoden skal have mindst 12 tegn.",
    "The passwords differ - nothing was changed.":
      "Adgangskoderne er forskellige – intet blev ændret.",
    "The switch the other way: decrypts what changed back into the plain folder and uses it again.":
      "Omstillingen den anden vej: dekrypterer det ændrede tilbage i den ukrypterede mappe og bruger den igen.",
    "The upload to the encrypted folder is not finished (or rclone did not answer) - not deleting.":
      "Uploaden til den krypterede mappe er ikke færdig (eller rclone svarede ikke) – intet slettes.",
    "Time Machine is backing up. Turn automatic backups off (sudo tmutil disable), stop it (tmutil stopbackup), then run this again.":
      "Time Machine er ved at sikkerhedskopiere. Slå automatisk sikkerhedskopiering fra (sudo tmutil disable), stop den (tmutil stopbackup), og kør derefter dette igen.",
    "With Time Machine stopped: last sync, cryptcheck, then the machine uses the encrypted folder. The plain one stays.":
      "Med Time Machine stoppet: sidste synkronisering, cryptcheck, derefter bruger maskinen den krypterede mappe. Den ukrypterede bliver.",
    "Without the encryption password and salt the encrypted backup cannot be read. Keep both outside this Mac (a password manager, paper), then confirm with --secrets-saved-elsewhere.":
      "Uden krypteringsadgangskoden og saltet kan den krypterede sikkerhedskopi ikke læses. Gem begge uden for denne Mac (en adgangskodeadministrator, papir), og bekræft derefter med --secrets-saved-elsewhere.",
    "rclone obscure failed.":
      "rclone obscure mislykkedes.",
    "tmutil did not answer - not switching while Time Machine's state is unknown.":
      "tmutil svarede ikke – ingen omstilling, så længe Time Machines tilstand er ukendt.",
  ]
}
