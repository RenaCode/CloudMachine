// Dutch translations of vm-encrypt (DriveEncryption), keyed by the English text.
extension L10nTranslations {
  static let nlEncryption: [String: String] = [
    "%@ and its metadata are in Google Drive's bin (kept 30 days, still counted in the quota).":
      "%@ en de metadata staan in de prullenbak van Google Drive (30 dagen bewaard, tellen nog mee voor de quota).",
    "'%@' is already in %@ - not replacing its password.":
      "'%@' staat al in %@ – het wachtwoord wordt niet vervangen.",
    "'%@' is already in the machine's rclone.conf - not replacing its password.":
      "'%@' staat al in de rclone.conf van de machine – het wachtwoord wordt niet vervangen.",
    "%@ holds folders this key cannot read: another password or salt in the machine, or leftovers of an earlier try. Compare the machine's rclone.conf with the Mac's; leftovers have to be removed from %@ by hand.":
      "%@ bevat mappen die deze sleutel niet kan lezen: een ander wachtwoord of andere salt in de machine, of resten van een eerdere poging. Vergelijk de rclone.conf van de machine met die van de Mac; resten moeten met de hand uit %@ worden verwijderd.",
    "'%@' is incomplete or missing in the Mac's rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "'%@' is onvolledig of ontbreekt in de rclone.conf van de Mac – voer uit: cloudmachine-agent vm-encrypt setup",
    "CLOUDMACHINE_VM_INSTANCE=%@ needs its own rclone.conf - set RCLONE_CONFIG to a copy, not %@. Its Keychain entry is service %@.":
      "CLOUDMACHINE_VM_INSTANCE=%@ heeft een eigen rclone.conf nodig – stel RCLONE_CONFIG in op een kopie, niet op %@. Het sleutelhangeronderdeel is de dienst %@.",
    "Could not read the '%@' section on the Mac or in the machine.":
      "Het gedeelte '%@' kon niet worden gelezen op de Mac of in de machine.",
    "The machine's '%@' (password, salt or folder) differs from the Mac's - the copy would be readable only with the machine's key. Not moving anything.":
      "'%@' van de machine (wachtwoord, salt of map) wijkt af van dat van de Mac – de kopie zou alleen met de sleutel van de machine leesbaar zijn. Er wordt niets verplaatst.",
    "A file was restored from the encrypted backup.":
      "Er is een bestand hersteld uit de versleutelde reservekopie.",
    "Added '%@' (%@) on the Mac and in the machine; password and salt are in the Keychain (service %@).\nSALT: %@\nKeep the password AND this salt outside this Mac now - without both the encrypted backup cannot be read. Next: cloudmachine-agent vm-encrypt copy":
      "'%@' (%@) toegevoegd op de Mac en in de machine; wachtwoord en salt staan in de sleutelhanger (dienst %@).\nSALT: %@\nBewaar nu het wachtwoord EN deze salt buiten deze Mac – zonder beide is de versleutelde reservekopie niet leesbaar. Volgende: cloudmachine-agent vm-encrypt copy",
    "Adds the encrypted remote on the Mac and in the machine (asks for the password). Moves no data.":
      "Voegt de versleutelde remote toe op de Mac en in de machine (vraagt om het wachtwoord). Verplaatst geen gegevens.",
    "Again: ":
      "Nogmaals: ",
    "Copies the plain backup into the encrypted folder, in the background; backups go on.":
      "Kopieert de onversleutelde reservekopie op de achtergrond naar de versleutelde map; reservekopieën gaan door.",
    "Copy:             %@":
      "Kopie:            %@",
    "CLOUDMACHINE_VM_INSTANCE=%@ without CLOUDMACHINE_VM_REMOTE would use the live backup's folder - set both.":
      "CLOUDMACHINE_VM_INSTANCE=%@ zonder CLOUDMACHINE_VM_REMOTE zou de map van de actieve reservekopie gebruiken – stel beide in.",
    "Could not add the remote to %@: %@":
      "Kon de remote niet toevoegen aan %@: %@",
    "Could not add the remote to the machine's rclone.conf.":
      "Kon de remote niet toevoegen aan de rclone.conf van de machine.",
    "Could not read %@.":
      "Kon %@ niet lezen.",
    "Could not read when Time Machine last finished a backup (Full Disk Access?) - not deleting.":
      "Kon niet lezen wanneer Time Machine voor het laatst een reservekopie heeft voltooid (Volledige schijftoegang?) – er wordt niets verwijderd.",
    "Could not start the copy: %@":
      "Kon de kopie niet starten: %@",
    "Could not write %@.":
      "Kon %@ niet schrijven.",
    "Deleting the plain folder failed: %@":
      "Verwijderen van de onversleutelde map mislukt: %@",
    "Encrypted folder: %@":
      "Versleutelde map: %@",
    "Encryption password: ":
      "Versleutelingswachtwoord: ",
    "Machine uses:     %@":
      "Machine gebruikt: %@",
    "Moves the backup on Google Drive under rclone encryption: setup, copy, switch, then delete-plain.":
      "Brengt de reservekopie op Google Drive onder de versleuteling van rclone: setup, copy, switch en daarna delete-plain.",
    "Moves the plain folder to Google Drive's bin - only after a backup has finished into the encrypted one.":
      "Verplaatst de onversleutelde map naar de prullenbak van Google Drive – pas nadat een reservekopie in de versleutelde is voltooid.",
    "Moving the machine failed; it went back to %@: %@":
      "Het omzetten van de machine is mislukt; ze gebruikt weer %@: %@",
    "No answer from rclone in the machine - the upload queue is unknown.":
      "Geen antwoord van rclone in de machine – de uploadwachtrij is onbekend.",
    "No backup has finished into the encrypted folder yet (last one %@, switched %@) - not deleting.":
      "Er is nog geen reservekopie in de versleutelde map voltooid (laatste %@, omgezet %@) – er wordt niets verwijderd.",
    "Not everything is on Google Drive yet (%@ MB unsent, %@ uploading, %@ failed). Wait until the upload is done: cloudmachine-agent vm-status":
      "Nog niet alles staat op Google Drive (%@ MB niet verzonden, %@ bezig met uploaden, %@ mislukt). Wacht tot de upload klaar is: cloudmachine-agent vm-status",
    "Restore a file from the encrypted backup first (Time Machine, Browse), then confirm with --restore-checked.":
      "Herstel eerst een bestand uit de versleutelde reservekopie (Time Machine, Blader) en bevestig daarna met --restore-checked.",
    "Shows which folder the machine uses and the copy.":
      "Toont welke map de machine gebruikt en hoe de kopie ervoor staat.",
    "Switched:         %@":
      "Omgezet:          %@",
    "The copy is already running - see: cloudmachine-agent vm-encrypt status":
      "De kopie loopt al – zie: cloudmachine-agent vm-encrypt status",
    "The copy runs in the machine (%@, log %@). Backups go on meanwhile. Check: cloudmachine-agent vm-encrypt status":
      "De kopie loopt in de machine (%@, log %@). Reservekopieën gaan ondertussen door. Controleren: cloudmachine-agent vm-encrypt status",
    "The copy to the encrypted folder has not finished well (%@) - run: cloudmachine-agent vm-encrypt copy, and wait for it.":
      "De kopie naar de versleutelde map is niet goed afgerond (%@) – voer uit: cloudmachine-agent vm-encrypt copy, en wacht erop.",
    "The encryption password and salt are kept outside this Mac.":
      "Het versleutelingswachtwoord en de salt worden buiten deze Mac bewaard.",
    "The guard holds Time Machine paused and would resume it during the switch. Wait until it resumes and the upload is done.":
      "De bewaker houdt Time Machine gepauzeerd en zou die tijdens het omzetten hervatten. Wacht tot die is hervat en de upload klaar is.",
    "The image metadata has not been copied to the encrypted folder since the last backup - not deleting.":
      "De metadata van de schijfkopie zijn sinds de laatste reservekopie niet naar de versleutelde map gekopieerd – er wordt niets verwijderd.",
    "The last sync or cryptcheck failed - the machine was NOT moved: %@":
      "De laatste synchronisatie of cryptcheck is mislukt – de machine is NIET verplaatst: %@",
    "The machine already uses the encrypted folder - nothing to switch.":
      "De machine gebruikt de versleutelde map al – niets om te zetten.",
    "The machine already uses the encrypted folder.":
      "De machine gebruikt de versleutelde map al.",
    "The machine does not use the encrypted folder - nothing to roll back.":
      "De machine gebruikt de versleutelde map niet – niets terug te draaien.",
    "The machine does not use the encrypted folder - the plain folder is the backup. Not deleting it.":
      "De machine gebruikt de versleutelde map niet – de onversleutelde map is de reservekopie. Die wordt niet verwijderd.",
    "The machine has no '%@' remote in its rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "De machine heeft geen remote '%@' in haar rclone.conf – voer uit: cloudmachine-agent vm-encrypt setup",
    "The machine is not on this app's template or does not use %@ (cloudmachine-agent vm-update first): %@":
      "De machine draait niet op het sjabloon van deze app of gebruikt %@ niet (eerst cloudmachine-agent vm-update): %@",
    "The machine now uses %@, but %@ could not be updated (%@) - fix it before anything else runs vm-setup.":
      "De machine gebruikt nu %@, maar %@ kon niet worden bijgewerkt (%@) – herstel dat voordat iets anders vm-setup uitvoert.",
    "The machine now uses %@. %@ is kept. Turn automatic backups back on: sudo tmutil enable":
      "De machine gebruikt nu %@. %@ blijft behouden. Zet automatische reservekopieën weer aan: sudo tmutil enable",
    "The password must have at least 12 characters.":
      "Het wachtwoord moet minstens 12 tekens hebben.",
    "The passwords differ - nothing was changed.":
      "De wachtwoorden verschillen – er is niets gewijzigd.",
    "The switch the other way: decrypts what changed back into the plain folder and uses it again.":
      "Het omzetten de andere kant op: ontsleutelt wat er veranderd is terug naar de onversleutelde map en gebruikt die weer.",
    "The upload to the encrypted folder is not finished (or rclone did not answer) - not deleting.":
      "De upload naar de versleutelde map is niet klaar (of rclone antwoordde niet) – er wordt niets verwijderd.",
    "Time Machine is backing up. Turn automatic backups off (sudo tmutil disable), stop it (tmutil stopbackup), then run this again.":
      "Time Machine maakt een reservekopie. Zet automatische reservekopieën uit (sudo tmutil disable), stop die (tmutil stopbackup) en voer dit daarna opnieuw uit.",
    "With Time Machine stopped: last sync, cryptcheck, then the machine uses the encrypted folder. The plain one stays.":
      "Met Time Machine gestopt: laatste synchronisatie, cryptcheck, daarna gebruikt de machine de versleutelde map. De onversleutelde blijft.",
    "Without the encryption password and salt the encrypted backup cannot be read. Keep both outside this Mac (a password manager, paper), then confirm with --secrets-saved-elsewhere.":
      "Zonder het versleutelingswachtwoord en de salt is de versleutelde reservekopie niet leesbaar. Bewaar beide buiten deze Mac (een wachtwoordbeheerder, papier) en bevestig daarna met --secrets-saved-elsewhere.",
    "rclone obscure failed.":
      "rclone obscure is mislukt.",
    "tmutil did not answer - not switching while Time Machine's state is unknown.":
      "tmutil antwoordde niet – geen omzetting zolang de status van Time Machine onbekend is.",
  ]
}
