// Swedish translations of vm-encrypt (DriveEncryption), keyed by the English text.
extension L10nTranslations {
  static let svEncryption: [String: String] = [
    "%@ and its metadata are in Google Drive's bin (kept 30 days, still counted in the quota).":
      "%@ och dess metadata ligger i papperskorgen i Google Drive (sparas i 30 dagar och räknas fortfarande in i kvoten).",
    "'%@' is already in %@ - not replacing its password.":
      "'%@' finns redan i %@ – lösenordet ersätts inte.",
    "'%@' is already in the machine's rclone.conf - not replacing its password.":
      "'%@' finns redan i maskinens rclone.conf – lösenordet ersätts inte.",
    "%@ holds folders this key cannot read: another password or salt in the machine, or leftovers of an earlier try. Compare the machine's rclone.conf with the Mac's; leftovers have to be removed from %@ by hand.":
      "%@ innehåller mappar som den här nyckeln inte kan läsa: ett annat lösenord eller salt i maskinen, eller rester från ett tidigare försök. Jämför maskinens rclone.conf med Macens; rester måste tas bort från %@ för hand.",
    "'%@' is incomplete or missing in the Mac's rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "'%@' är ofullständig eller saknas i Macens rclone.conf – kör: cloudmachine-agent vm-encrypt setup",
    "CLOUDMACHINE_VM_INSTANCE=%@ needs its own rclone.conf - set RCLONE_CONFIG to a copy, not %@. Its Keychain entry is service %@.":
      "CLOUDMACHINE_VM_INSTANCE=%@ behöver en egen rclone.conf – sätt RCLONE_CONFIG till en kopia, inte %@. Dess post i nyckelringen är tjänsten %@.",
    "Could not read the '%@' section on the Mac or in the machine.":
      "Avsnittet '%@' kunde inte läsas på Macen eller i maskinen.",
    "The machine's '%@' (password, salt or folder) differs from the Mac's - the copy would be readable only with the machine's key. Not moving anything.":
      "Maskinens '%@' (lösenord, salt eller mapp) skiljer sig från Macens – kopian skulle bara kunna läsas med maskinens nyckel. Inget flyttas.",
    "A file was restored from the encrypted backup.":
      "En fil återställdes från den krypterade säkerhetskopian.",
    "Added '%@' (%@) on the Mac and in the machine; password and salt are in the Keychain (service %@).\nSALT: %@\nKeep the password AND this salt outside this Mac now - without both the encrypted backup cannot be read. Next: cloudmachine-agent vm-encrypt copy":
      "'%@' (%@) har lagts till på Macen och i maskinen; lösenord och salt finns i nyckelringen (tjänst %@).\nSALT: %@\nSpara nu lösenordet OCH detta salt utanför den här Macen – utan båda går den krypterade säkerhetskopian inte att läsa. Nästa: cloudmachine-agent vm-encrypt copy",
    "Adds the encrypted remote on the Mac and in the machine (asks for the password). Moves no data.":
      "Lägger till den krypterade fjärrplatsen på Macen och i maskinen (frågar efter lösenordet). Flyttar inga data.",
    "Again: ":
      "Igen: ",
    "Copies the plain backup into the encrypted folder, in the background; backups go on.":
      "Kopierar den okrypterade säkerhetskopian till den krypterade mappen i bakgrunden; säkerhetskopieringen fortsätter.",
    "Copy:             %@":
      "Kopia:            %@",
    "CLOUDMACHINE_VM_INSTANCE=%@ without CLOUDMACHINE_VM_REMOTE would use the live backup's folder - set both.":
      "CLOUDMACHINE_VM_INSTANCE=%@ utan CLOUDMACHINE_VM_REMOTE skulle använda mappen för den aktiva säkerhetskopian – sätt båda.",
    "Could not add the remote to %@: %@":
      "Kunde inte lägga till fjärrplatsen i %@: %@",
    "Could not add the remote to the machine's rclone.conf.":
      "Kunde inte lägga till fjärrplatsen i maskinens rclone.conf.",
    "Could not read %@.":
      "Kunde inte läsa %@.",
    "Could not read when Time Machine last finished a backup (Full Disk Access?) - not deleting.":
      "Kunde inte läsa när Time Machine senast slutförde en säkerhetskopia (Full åtkomst till disken?) – inget raderas.",
    "Could not start the copy: %@":
      "Kunde inte starta kopieringen: %@",
    "Could not write %@.":
      "Kunde inte skriva %@.",
    "Deleting the plain folder failed: %@":
      "Radering av den okrypterade mappen misslyckades: %@",
    "Encrypted folder: %@":
      "Krypterad mapp:   %@",
    "Encryption password: ":
      "Krypteringslösenord: ",
    "Machine uses:     %@":
      "Maskinen använder: %@",
    "Moves the backup on Google Drive under rclone encryption: setup, copy, switch, then delete-plain.":
      "Flyttar säkerhetskopian på Google Drive till rclones kryptering: setup, copy, switch och sedan delete-plain.",
    "Moves the plain folder to Google Drive's bin - only after a backup has finished into the encrypted one.":
      "Flyttar den okrypterade mappen till papperskorgen i Google Drive – först när en säkerhetskopia har slutförts i den krypterade.",
    "Moving the machine failed; it went back to %@: %@":
      "Omläggningen av maskinen misslyckades; den är tillbaka på %@: %@",
    "No answer from rclone in the machine - the upload queue is unknown.":
      "Inget svar från rclone i maskinen – uppladdningskön är okänd.",
    "No backup has finished into the encrypted folder yet (last one %@, switched %@) - not deleting.":
      "Ingen säkerhetskopia har slutförts i den krypterade mappen än (senaste %@, omlagd %@) – inget raderas.",
    "Not everything is on Google Drive yet (%@ MB unsent, %@ uploading, %@ failed). Wait until the upload is done: cloudmachine-agent vm-status":
      "Allt finns inte på Google Drive än (%@ MB inte skickade, %@ laddas upp, %@ misslyckade). Vänta tills uppladdningen är klar: cloudmachine-agent vm-status",
    "Restore a file from the encrypted backup first (Time Machine, Browse), then confirm with --restore-checked.":
      "Återställ först en fil från den krypterade säkerhetskopian (Time Machine, Bläddra) och bekräfta sedan med --restore-checked.",
    "Shows which folder the machine uses and the copy.":
      "Visar vilken mapp maskinen använder och hur kopieringen går.",
    "Switched:         %@":
      "Omlagd:           %@",
    "The copy is already running - see: cloudmachine-agent vm-encrypt status":
      "Kopieringen körs redan – se: cloudmachine-agent vm-encrypt status",
    "The copy runs in the machine (%@, log %@). Backups go on meanwhile. Check: cloudmachine-agent vm-encrypt status":
      "Kopieringen körs i maskinen (%@, logg %@). Säkerhetskopieringen fortsätter under tiden. Kontrollera: cloudmachine-agent vm-encrypt status",
    "The copy to the encrypted folder has not finished well (%@) - run: cloudmachine-agent vm-encrypt copy, and wait for it.":
      "Kopieringen till den krypterade mappen avslutades inte korrekt (%@) – kör: cloudmachine-agent vm-encrypt copy, och vänta på den.",
    "The encryption password and salt are kept outside this Mac.":
      "Krypteringslösenordet och saltet förvaras utanför den här Macen.",
    "The guard holds Time Machine paused and would resume it during the switch. Wait until it resumes and the upload is done.":
      "Vakten håller Time Machine pausad och skulle återuppta den under omläggningen. Vänta tills den har återupptagits och uppladdningen är klar.",
    "The image metadata has not been copied to the encrypted folder since the last backup - not deleting.":
      "Avbildningens metadata har inte kopierats till den krypterade mappen sedan senaste säkerhetskopian – inget raderas.",
    "The last sync or cryptcheck failed - the machine was NOT moved: %@":
      "Den sista synkroniseringen eller cryptcheck misslyckades – maskinen flyttades INTE: %@",
    "The machine already uses the encrypted folder - nothing to switch.":
      "Maskinen använder redan den krypterade mappen – inget att lägga om.",
    "The machine already uses the encrypted folder.":
      "Maskinen använder redan den krypterade mappen.",
    "The machine does not use the encrypted folder - nothing to roll back.":
      "Maskinen använder inte den krypterade mappen – inget att rulla tillbaka.",
    "The machine does not use the encrypted folder - the plain folder is the backup. Not deleting it.":
      "Maskinen använder inte den krypterade mappen – den okrypterade mappen är säkerhetskopian. Den raderas inte.",
    "The machine has no '%@' remote in its rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "Maskinen har ingen fjärrplats '%@' i sin rclone.conf – kör: cloudmachine-agent vm-encrypt setup",
    "The machine is not on this app's template or does not use %@ (cloudmachine-agent vm-update first): %@":
      "Maskinen använder inte appens mall eller använder inte %@ (först cloudmachine-agent vm-update): %@",
    "The machine now uses %@, but %@ could not be updated (%@) - fix it before anything else runs vm-setup.":
      "Maskinen använder nu %@, men %@ kunde inte uppdateras (%@) – åtgärda det innan något annat kör vm-setup.",
    "The machine now uses %@. %@ is kept. Turn automatic backups back on: sudo tmutil enable":
      "Maskinen använder nu %@. %@ behålls. Slå på automatisk säkerhetskopiering igen: sudo tmutil enable",
    "The password must have at least 12 characters.":
      "Lösenordet måste ha minst 12 tecken.",
    "The passwords differ - nothing was changed.":
      "Lösenorden skiljer sig åt – inget har ändrats.",
    "The switch the other way: decrypts what changed back into the plain folder and uses it again.":
      "Omläggningen åt andra hållet: dekrypterar det som ändrats tillbaka till den okrypterade mappen och använder den igen.",
    "The upload to the encrypted folder is not finished (or rclone did not answer) - not deleting.":
      "Uppladdningen till den krypterade mappen är inte klar (eller rclone svarade inte) – inget raderas.",
    "Time Machine is backing up. Turn automatic backups off (sudo tmutil disable), stop it (tmutil stopbackup), then run this again.":
      "Time Machine säkerhetskopierar just nu. Stäng av automatisk säkerhetskopiering (sudo tmutil disable), stoppa den (tmutil stopbackup) och kör sedan detta igen.",
    "With Time Machine stopped: last sync, cryptcheck, then the machine uses the encrypted folder. The plain one stays.":
      "Med Time Machine stoppad: sista synkronisering, cryptcheck, sedan använder maskinen den krypterade mappen. Den okrypterade finns kvar.",
    "Without the encryption password and salt the encrypted backup cannot be read. Keep both outside this Mac (a password manager, paper), then confirm with --secrets-saved-elsewhere.":
      "Utan krypteringslösenordet och saltet går den krypterade säkerhetskopian inte att läsa. Förvara båda utanför den här Macen (en lösenordshanterare, papper) och bekräfta sedan med --secrets-saved-elsewhere.",
    "rclone obscure failed.":
      "rclone obscure misslyckades.",
    "tmutil did not answer - not switching while Time Machine's state is unknown.":
      "tmutil svarade inte – ingen omläggning så länge Time Machines tillstånd är okänt.",
  ]
}
