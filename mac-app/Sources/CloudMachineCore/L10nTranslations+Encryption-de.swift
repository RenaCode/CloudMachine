// German translations of vm-encrypt (DriveEncryption), keyed by the English text.
extension L10nTranslations {
  static let deEncryption: [String: String] = [
    "%@ and its metadata are in Google Drive's bin (kept 30 days, still counted in the quota).":
      "%@ und seine Metadaten liegen im Papierkorb von Google Drive (30 Tage aufbewahrt, zählen weiter zum Speicherkontingent).",
    "'%@' is already in %@ - not replacing its password.":
      "'%@' ist bereits in %@ – sein Kennwort wird nicht ersetzt.",
    "'%@' is already in the machine's rclone.conf - not replacing its password.":
      "'%@' ist bereits in der rclone.conf der Maschine – sein Kennwort wird nicht ersetzt.",
    "%@ holds folders this key cannot read: another password or salt in the machine, or leftovers of an earlier try. Compare the machine's rclone.conf with the Mac's; leftovers have to be removed from %@ by hand.":
      "%@ enthält Ordner, die dieser Schlüssel nicht lesen kann: ein anderes Kennwort oder Salt in der Maschine oder Reste eines früheren Versuchs. Die rclone.conf der Maschine mit der des Macs vergleichen; Reste müssen von Hand aus %@ entfernt werden.",
    "'%@' is incomplete or missing in the Mac's rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "'%@' fehlt oder ist unvollständig in der rclone.conf des Macs – ausführen: cloudmachine-agent vm-encrypt setup",
    "CLOUDMACHINE_VM_INSTANCE=%@ needs its own rclone.conf - set RCLONE_CONFIG to a copy, not %@. Its Keychain entry is service %@.":
      "CLOUDMACHINE_VM_INSTANCE=%@ braucht eine eigene rclone.conf – RCLONE_CONFIG auf eine Kopie setzen, nicht auf %@. Ihr Schlüsselbund-Eintrag ist der Dienst %@.",
    "Could not read the '%@' section on the Mac or in the machine.":
      "Der Abschnitt '%@' konnte auf dem Mac oder in der Maschine nicht gelesen werden.",
    "The machine's '%@' (password, salt or folder) differs from the Mac's - the copy would be readable only with the machine's key. Not moving anything.":
      "'%@' der Maschine (Kennwort, Salt oder Ordner) weicht von dem des Macs ab – die Kopie wäre nur mit dem Schlüssel der Maschine lesbar. Es wird nichts verschoben.",
    "A file was restored from the encrypted backup.":
      "Eine Datei wurde aus dem verschlüsselten Backup wiederhergestellt.",
    "Added '%@' (%@) on the Mac and in the machine; password and salt are in the Keychain (service %@).\nSALT: %@\nKeep the password AND this salt outside this Mac now - without both the encrypted backup cannot be read. Next: cloudmachine-agent vm-encrypt copy":
      "'%@' (%@) wurde auf dem Mac und in der Maschine hinzugefügt; Kennwort und Salt liegen im Schlüsselbund (Dienst %@).\nSALT: %@\nDas Kennwort UND dieses Salt jetzt außerhalb dieses Macs aufbewahren – ohne beide lässt sich das verschlüsselte Backup nicht lesen. Weiter: cloudmachine-agent vm-encrypt copy",
    "Adds the encrypted remote on the Mac and in the machine (asks for the password). Moves no data.":
      "Fügt das verschlüsselte Remote auf dem Mac und in der Maschine hinzu (fragt nach dem Kennwort). Verschiebt keine Daten.",
    "Again: ":
      "Noch einmal: ",
    "Copies the plain backup into the encrypted folder, in the background; backups go on.":
      "Kopiert das unverschlüsselte Backup im Hintergrund in den verschlüsselten Ordner; Backups laufen weiter.",
    "Copy:             %@":
      "Kopie:            %@",
    "CLOUDMACHINE_VM_INSTANCE=%@ without CLOUDMACHINE_VM_REMOTE would use the live backup's folder - set both.":
      "CLOUDMACHINE_VM_INSTANCE=%@ ohne CLOUDMACHINE_VM_REMOTE würde den Ordner des laufenden Backups verwenden – beide setzen.",
    "Could not add the remote to %@: %@":
      "Das Remote konnte nicht zu %@ hinzugefügt werden: %@",
    "Could not add the remote to the machine's rclone.conf.":
      "Das Remote konnte nicht zur rclone.conf der Maschine hinzugefügt werden.",
    "Could not read %@.":
      "%@ konnte nicht gelesen werden.",
    "Could not read when Time Machine last finished a backup (Full Disk Access?) - not deleting.":
      "Es ließ sich nicht lesen, wann Time Machine zuletzt ein Backup abgeschlossen hat (Festplattenvollzugriff?) – es wird nichts gelöscht.",
    "Could not start the copy: %@":
      "Die Kopie konnte nicht gestartet werden: %@",
    "Could not write %@.":
      "%@ konnte nicht geschrieben werden.",
    "Deleting the plain folder failed: %@":
      "Löschen des unverschlüsselten Ordners fehlgeschlagen: %@",
    "Encrypted folder: %@":
      "Verschl. Ordner:  %@",
    "Encryption password: ":
      "Verschlüsselungskennwort: ",
    "Machine uses:     %@":
      "Maschine nutzt:   %@",
    "Moves the backup on Google Drive under rclone encryption: setup, copy, switch, then delete-plain.":
      "Verschiebt das Backup auf Google Drive unter die Verschlüsselung von rclone: setup, copy, switch, dann delete-plain.",
    "Moves the plain folder to Google Drive's bin - only after a backup has finished into the encrypted one.":
      "Verschiebt den unverschlüsselten Ordner in den Papierkorb von Google Drive – erst nachdem ein Backup im verschlüsselten abgeschlossen wurde.",
    "Moving the machine failed; it went back to %@: %@":
      "Das Umstellen der Maschine ist fehlgeschlagen; sie nutzt wieder %@: %@",
    "No answer from rclone in the machine - the upload queue is unknown.":
      "Keine Antwort von rclone in der Maschine – die Upload-Warteschlange ist unbekannt.",
    "No backup has finished into the encrypted folder yet (last one %@, switched %@) - not deleting.":
      "Noch kein Backup wurde im verschlüsselten Ordner abgeschlossen (letztes %@, umgestellt %@) – es wird nichts gelöscht.",
    "Not everything is on Google Drive yet (%@ MB unsent, %@ uploading, %@ failed). Wait until the upload is done: cloudmachine-agent vm-status":
      "Noch ist nicht alles auf Google Drive (%@ MB nicht gesendet, %@ im Upload, %@ fehlgeschlagen). Warten, bis der Upload fertig ist: cloudmachine-agent vm-status",
    "Restore a file from the encrypted backup first (Time Machine, Browse), then confirm with --restore-checked.":
      "Zuerst eine Datei aus dem verschlüsselten Backup wiederherstellen (Time Machine, Durchsuchen) und dann mit --restore-checked bestätigen.",
    "Shows which folder the machine uses and the copy.":
      "Zeigt, welchen Ordner die Maschine nutzt, und den Stand der Kopie.",
    "Switched:         %@":
      "Umgestellt:       %@",
    "The copy is already running - see: cloudmachine-agent vm-encrypt status":
      "Die Kopie läuft bereits – siehe: cloudmachine-agent vm-encrypt status",
    "The copy runs in the machine (%@, log %@). Backups go on meanwhile. Check: cloudmachine-agent vm-encrypt status":
      "Die Kopie läuft in der Maschine (%@, Protokoll %@). Backups laufen währenddessen weiter. Prüfen: cloudmachine-agent vm-encrypt status",
    "The copy to the encrypted folder has not finished well (%@) - run: cloudmachine-agent vm-encrypt copy, and wait for it.":
      "Die Kopie in den verschlüsselten Ordner wurde nicht erfolgreich beendet (%@) – ausführen: cloudmachine-agent vm-encrypt copy, dann das Ende abwarten.",
    "The encryption password and salt are kept outside this Mac.":
      "Verschlüsselungskennwort und Salt werden außerhalb dieses Macs aufbewahrt.",
    "The guard holds Time Machine paused and would resume it during the switch. Wait until it resumes and the upload is done.":
      "Der Pufferwächter hält Time Machine angehalten und würde es während der Umstellung fortsetzen. Warten, bis es fortgesetzt und der Upload fertig ist.",
    "The image metadata has not been copied to the encrypted folder since the last backup - not deleting.":
      "Die Metadaten des Images wurden seit dem letzten Backup nicht in den verschlüsselten Ordner kopiert – es wird nichts gelöscht.",
    "The last sync or cryptcheck failed - the machine was NOT moved: %@":
      "Die letzte Synchronisierung oder cryptcheck ist fehlgeschlagen – die Maschine wurde NICHT umgestellt: %@",
    "The machine already uses the encrypted folder - nothing to switch.":
      "Die Maschine nutzt bereits den verschlüsselten Ordner – nichts umzustellen.",
    "The machine already uses the encrypted folder.":
      "Die Maschine nutzt bereits den verschlüsselten Ordner.",
    "The machine does not use the encrypted folder - nothing to roll back.":
      "Die Maschine nutzt den verschlüsselten Ordner nicht – nichts zurückzunehmen.",
    "The machine does not use the encrypted folder - the plain folder is the backup. Not deleting it.":
      "Die Maschine nutzt den verschlüsselten Ordner nicht – der unverschlüsselte Ordner ist das Backup. Er wird nicht gelöscht.",
    "The machine has no '%@' remote in its rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "Die Maschine hat kein Remote '%@' in ihrer rclone.conf – ausführen: cloudmachine-agent vm-encrypt setup",
    "The machine is not on this app's template or does not use %@ (cloudmachine-agent vm-update first): %@":
      "Die Maschine nutzt nicht die Vorlage dieser App oder nicht %@ (zuerst cloudmachine-agent vm-update): %@",
    "The machine now uses %@, but %@ could not be updated (%@) - fix it before anything else runs vm-setup.":
      "Die Maschine nutzt jetzt %@, aber %@ konnte nicht aktualisiert werden (%@) – das beheben, bevor irgendetwas vm-setup ausführt.",
    "The machine now uses %@. %@ is kept. Turn automatic backups back on: sudo tmutil enable":
      "Die Maschine nutzt jetzt %@. %@ bleibt erhalten. Automatische Backups wieder einschalten: sudo tmutil enable",
    "The password must have at least 12 characters.":
      "Das Kennwort muss mindestens 12 Zeichen haben.",
    "The passwords differ - nothing was changed.":
      "Die Kennwörter stimmen nicht überein – nichts wurde geändert.",
    "The switch the other way: decrypts what changed back into the plain folder and uses it again.":
      "Die Umstellung in die andere Richtung: entschlüsselt das Geänderte zurück in den unverschlüsselten Ordner und nutzt ihn wieder.",
    "The upload to the encrypted folder is not finished (or rclone did not answer) - not deleting.":
      "Der Upload in den verschlüsselten Ordner ist nicht fertig (oder rclone hat nicht geantwortet) – es wird nichts gelöscht.",
    "Time Machine is backing up. Turn automatic backups off (sudo tmutil disable), stop it (tmutil stopbackup), then run this again.":
      "Time Machine erstellt gerade ein Backup. Automatische Backups ausschalten (sudo tmutil disable), das Backup stoppen (tmutil stopbackup) und dies dann erneut ausführen.",
    "With Time Machine stopped: last sync, cryptcheck, then the machine uses the encrypted folder. The plain one stays.":
      "Bei gestopptem Time Machine: letzte Synchronisierung, cryptcheck, dann nutzt die Maschine den verschlüsselten Ordner. Der unverschlüsselte bleibt.",
    "Without the encryption password and salt the encrypted backup cannot be read. Keep both outside this Mac (a password manager, paper), then confirm with --secrets-saved-elsewhere.":
      "Ohne Verschlüsselungskennwort und Salt lässt sich das verschlüsselte Backup nicht lesen. Beides außerhalb dieses Macs aufbewahren (Passwortmanager, Papier) und dann mit --secrets-saved-elsewhere bestätigen.",
    "rclone obscure failed.":
      "rclone obscure ist fehlgeschlagen.",
    "tmutil did not answer - not switching while Time Machine's state is unknown.":
      "tmutil hat nicht geantwortet – keine Umstellung, solange der Zustand von Time Machine unbekannt ist.",
  ]
}
