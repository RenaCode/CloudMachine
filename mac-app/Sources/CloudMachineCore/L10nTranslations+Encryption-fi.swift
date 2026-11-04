// Finnish translations of vm-encrypt (DriveEncryption), keyed by the English text.
extension L10nTranslations {
  static let fiEncryption: [String: String] = [
    "%@ and its metadata are in Google Drive's bin (kept 30 days, still counted in the quota).":
      "%@ ja sen metatiedot ovat Google Driven roskakorissa (säilytetään 30 päivää, lasketaan edelleen kiintiöön).",
    "'%@' is already in %@ - not replacing its password.":
      "'%@' on jo kohteessa %@ - sen salasanaa ei korvata.",
    "'%@' is already in the machine's rclone.conf - not replacing its password.":
      "'%@' on jo virtuaalikoneen rclone.conf-tiedostossa - sen salasanaa ei korvata.",
    "%@ holds folders this key cannot read: another password or salt in the machine, or leftovers of an earlier try. Compare the machine's rclone.conf with the Mac's; leftovers have to be removed from %@ by hand.":
      "%@ sisältää kansioita, joita tämä avain ei pysty lukemaan: virtuaalikoneessa on eri salasana tai suola, tai jäänteitä aiemmasta yrityksestä. Vertaa virtuaalikoneen rclone.conf-tiedostoa Macin tiedostoon; jäänteet on poistettava kohteesta %@ käsin.",
    "'%@' is incomplete or missing in the Mac's rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "'%@' on puutteellinen tai puuttuu Macin rclone.conf-tiedostosta - suorita: cloudmachine-agent vm-encrypt setup",
    "CLOUDMACHINE_VM_INSTANCE=%@ needs its own rclone.conf - set RCLONE_CONFIG to a copy, not %@. Its Keychain entry is service %@.":
      "CLOUDMACHINE_VM_INSTANCE=%@ tarvitsee oman rclone.conf-tiedoston - aseta RCLONE_CONFIG osoittamaan kopioon, ei tiedostoon %@. Sen merkintä Avainnipussa on palvelu %@.",
    "Could not read the '%@' section on the Mac or in the machine.":
      "Osiota '%@' ei voitu lukea Macissa tai virtuaalikoneessa.",
    "The machine's '%@' (password, salt or folder) differs from the Mac's - the copy would be readable only with the machine's key. Not moving anything.":
      "Virtuaalikoneen '%@' (salasana, suola tai kansio) eroaa Macin vastaavasta - kopion voisi lukea vain virtuaalikoneen avaimella. Mitään ei siirretä.",
    "A file was restored from the encrypted backup.":
      "Tiedosto palautettiin salatusta varmuuskopiosta.",
    "Added '%@' (%@) on the Mac and in the machine; password and salt are in the Keychain (service %@).\nSALT: %@\nKeep the password AND this salt outside this Mac now - without both the encrypted backup cannot be read. Next: cloudmachine-agent vm-encrypt copy":
      "'%@' (%@) lisättiin Maciin ja virtuaalikoneeseen; salasana ja suola ovat Avainnipussa (palvelu %@).\nSUOLA: %@\nSäilytä nyt salasana JA tämä suola tämän Macin ulkopuolella - ilman molempia salattua varmuuskopiota ei voi lukea. Seuraavaksi: cloudmachine-agent vm-encrypt copy",
    "Adds the encrypted remote on the Mac and in the machine (asks for the password). Moves no data.":
      "Lisää salatun remoten Maciin ja virtuaalikoneeseen (kysyy salasanaa). Ei siirrä tietoja.",
    "Again: ":
      "Uudelleen: ",
    "Copies the plain backup into the encrypted folder, in the background; backups go on.":
      "Kopioi salaamattoman varmuuskopion salattuun kansioon taustalla; varmuuskopiointi jatkuu.",
    "Copy:             %@":
      "Kopio:            %@",
    "CLOUDMACHINE_VM_INSTANCE=%@ without CLOUDMACHINE_VM_REMOTE would use the live backup's folder - set both.":
      "CLOUDMACHINE_VM_INSTANCE=%@ ilman CLOUDMACHINE_VM_REMOTE-muuttujaa käyttäisi käytössä olevan varmuuskopion kansiota - aseta molemmat.",
    "Could not add the remote to %@: %@":
      "Remotea ei voitu lisätä kohteeseen %@: %@",
    "Could not add the remote to the machine's rclone.conf.":
      "Remotea ei voitu lisätä virtuaalikoneen rclone.conf-tiedostoon.",
    "Could not read %@.":
      "Kohdetta %@ ei voitu lukea.",
    "Could not read when Time Machine last finished a backup (Full Disk Access?) - not deleting.":
      "Ei voitu lukea, milloin Time Machine viimeksi sai varmuuskopion valmiiksi (Täysi levyn käyttö?) - mitään ei poisteta.",
    "Could not start the copy: %@":
      "Kopiointia ei voitu käynnistää: %@",
    "Could not write %@.":
      "Kohteeseen %@ ei voitu kirjoittaa.",
    "Deleting the plain folder failed: %@":
      "Salaamattoman kansion poistaminen epäonnistui: %@",
    "Encrypted folder: %@":
      "Salattu kansio:   %@",
    "Encryption password: ":
      "Salauksen salasana: ",
    "Machine uses:     %@":
      "Kone käyttää:     %@",
    "Moves the backup on Google Drive under rclone encryption: setup, copy, switch, then delete-plain.":
      "Siirtää Google Driven varmuuskopion rclonen salauksen alle: setup, copy, switch ja sitten delete-plain.",
    "Moves the plain folder to Google Drive's bin - only after a backup has finished into the encrypted one.":
      "Siirtää salaamattoman kansion Google Driven roskakoriin - vasta kun varmuuskopio on valmistunut salattuun kansioon.",
    "Moving the machine failed; it went back to %@: %@":
      "Virtuaalikoneen siirto epäonnistui; se palasi kohteeseen %@: %@",
    "No answer from rclone in the machine - the upload queue is unknown.":
      "Ei vastausta virtuaalikoneen rclonelta - lähetysjonon tila on tuntematon.",
    "No backup has finished into the encrypted folder yet (last one %@, switched %@) - not deleting.":
      "Yksikään varmuuskopio ei ole vielä valmistunut salattuun kansioon (viimeisin %@, siirretty %@) - mitään ei poisteta.",
    "Not everything is on Google Drive yet (%@ MB unsent, %@ uploading, %@ failed). Wait until the upload is done: cloudmachine-agent vm-status":
      "Kaikki ei ole vielä Google Drivessa (%@ MB lähettämättä, %@ lähetyksessä, %@ epäonnistui). Odota, että lähetys valmistuu: cloudmachine-agent vm-status",
    "Restore a file from the encrypted backup first (Time Machine, Browse), then confirm with --restore-checked.":
      "Palauta ensin tiedosto salatusta varmuuskopiosta (Time Machine, Selaa) ja vahvista sitten valinnalla --restore-checked.",
    "Shows which folder the machine uses and the copy.":
      "Näyttää, mitä kansiota virtuaalikone käyttää, ja kopioinnin tilan.",
    "Switched:         %@":
      "Siirretty:        %@",
    "The copy is already running - see: cloudmachine-agent vm-encrypt status":
      "Kopiointi on jo käynnissä - katso: cloudmachine-agent vm-encrypt status",
    "The copy runs in the machine (%@, log %@). Backups go on meanwhile. Check: cloudmachine-agent vm-encrypt status":
      "Kopiointi on käynnissä virtuaalikoneessa (%@, loki %@). Varmuuskopiointi jatkuu sillä aikaa. Tarkista: cloudmachine-agent vm-encrypt status",
    "The copy to the encrypted folder has not finished well (%@) - run: cloudmachine-agent vm-encrypt copy, and wait for it.":
      "Kopiointi salattuun kansioon ei päättynyt onnistuneesti (%@) - suorita: cloudmachine-agent vm-encrypt copy ja odota sen valmistumista.",
    "The encryption password and salt are kept outside this Mac.":
      "Salauksen salasana ja suola säilytetään tämän Macin ulkopuolella.",
    "The guard holds Time Machine paused and would resume it during the switch. Wait until it resumes and the upload is done.":
      "Vartija pitää Time Machinen keskeytettynä ja jatkaisi sitä siirron aikana. Odota, että se jatkuu ja lähetys valmistuu.",
    "The image metadata has not been copied to the encrypted folder since the last backup - not deleting.":
      "Levykuvan metatietoja ei ole kopioitu salattuun kansioon viimeisimmän varmuuskopion jälkeen - mitään ei poisteta.",
    "The last sync or cryptcheck failed - the machine was NOT moved: %@":
      "Viimeinen synkronointi tai cryptcheck epäonnistui - virtuaalikonetta EI siirretty: %@",
    "The machine already uses the encrypted folder - nothing to switch.":
      "Virtuaalikone käyttää jo salattua kansiota - ei siirrettävää.",
    "The machine already uses the encrypted folder.":
      "Virtuaalikone käyttää jo salattua kansiota.",
    "The machine does not use the encrypted folder - nothing to roll back.":
      "Virtuaalikone ei käytä salattua kansiota - ei peruttavaa.",
    "The machine does not use the encrypted folder - the plain folder is the backup. Not deleting it.":
      "Virtuaalikone ei käytä salattua kansiota - salaamaton kansio on varmuuskopio. Sitä ei poisteta.",
    "The machine has no '%@' remote in its rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "Virtuaalikoneen rclone.conf-tiedostossa ei ole remotea '%@' - suorita: cloudmachine-agent vm-encrypt setup",
    "The machine is not on this app's template or does not use %@ (cloudmachine-agent vm-update first): %@":
      "Virtuaalikone ei ole tämän sovelluksen mallin mukainen tai ei käytä kohdetta %@ (ensin cloudmachine-agent vm-update): %@",
    "The machine now uses %@, but %@ could not be updated (%@) - fix it before anything else runs vm-setup.":
      "Virtuaalikone käyttää nyt kohdetta %@, mutta kohdetta %@ ei voitu päivittää (%@) - korjaa se, ennen kuin mikään muu suorittaa vm-setupin.",
    "The machine now uses %@. %@ is kept. Turn automatic backups back on: sudo tmutil enable":
      "Virtuaalikone käyttää nyt kohdetta %@. %@ säilytetään. Ota automaattiset varmuuskopiot taas käyttöön: sudo tmutil enable",
    "The password must have at least 12 characters.":
      "Salasanassa on oltava vähintään 12 merkkiä.",
    "The passwords differ - nothing was changed.":
      "Salasanat eroavat - mitään ei muutettu.",
    "The switch the other way: decrypts what changed back into the plain folder and uses it again.":
      "Siirto toiseen suuntaan: purkaa muuttuneiden tietojen salauksen takaisin salaamattomaan kansioon ja ottaa sen uudelleen käyttöön.",
    "The upload to the encrypted folder is not finished (or rclone did not answer) - not deleting.":
      "Lähetys salattuun kansioon ei ole valmis (tai rclone ei vastannut) - mitään ei poisteta.",
    "Time Machine is backing up. Turn automatic backups off (sudo tmutil disable), stop it (tmutil stopbackup), then run this again.":
      "Time Machine varmuuskopioi parhaillaan. Poista automaattiset varmuuskopiot käytöstä (sudo tmutil disable), pysäytä se (tmutil stopbackup) ja suorita tämä sitten uudelleen.",
    "With Time Machine stopped: last sync, cryptcheck, then the machine uses the encrypted folder. The plain one stays.":
      "Kun Time Machine on pysäytetty: viimeinen synkronointi, cryptcheck, sitten virtuaalikone käyttää salattua kansiota. Salaamaton jää.",
    "Without the encryption password and salt the encrypted backup cannot be read. Keep both outside this Mac (a password manager, paper), then confirm with --secrets-saved-elsewhere.":
      "Ilman salauksen salasanaa ja suolaa salattua varmuuskopiota ei voi lukea. Säilytä molemmat tämän Macin ulkopuolella (salasanojen hallinta, paperi) ja vahvista sitten valinnalla --secrets-saved-elsewhere.",
    "rclone obscure failed.":
      "rclone obscure epäonnistui.",
    "tmutil did not answer - not switching while Time Machine's state is unknown.":
      "tmutil ei vastannut - siirtoa ei tehdä, kun Time Machinen tila on tuntematon.",
  ]
}
