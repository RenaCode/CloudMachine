// Finnish translations, keyed by the English text passed to `L10n.tr`.
extension L10nTranslations {
  static let fi: [String: String] = [
    "Space limit:      %@":
      "Tilaraja:         %@",
    "                  Time Machine quota not set to match - run: %@":
      "                  Time Machine -kiintiötä ei ole asetettu vastaamaan - suorita: %@",
    "Sets how much of Google Drive this Mac may use, and prints the Time Machine quota command.":
      "Määrittää, kuinka paljon Google Drivesta tämä Mac saa käyttää, ja tulostaa Time Machine -kiintiön komennon.",
    "Limit in GB.":
      "Raja GB:na.",
    "Limit for this Mac: %@ GB.":
      "Tämän Macin raja: %@ GB.",
    "Now set the Time Machine quota (needs an administrator password):":
      "Aseta nyt Time Machine -kiintiö (vaatii ylläpitäjän salasanan):",
    "CloudMachine - verification, Google Drive setup and installation. Called by launchd on a schedule, or by hand from Terminal.":
      "CloudMachine - tarkistus, Google Driven määritys ja asennus. launchd kutsuu sitä aikataulun mukaan, tai sen voi suorittaa itse Päätteessä.",
    "Connects to Google Drive through rclone (OAuth in the browser) and creates this machine's folder.":
      "Yhdistää Google Driveen rclonen kautta (OAuth selaimessa) ja luo tämän virtuaalikoneen kansion.",
    "Overwrite the existing remote. RISKY: replaces the token and permissions.":
      "Korvaa olemassa oleva remote. RISKIALTIS: korvaa tokenin ja käyttöoikeudet.",
    "Packs build/CloudMachine.app into build/CloudMachine-<version>.dmg.":
      "Pakkaa build/CloudMachine.app tiedostoksi build/CloudMachine-<versio>.dmg.",
    "ERROR: %@ is missing - run 'cloudmachine-agent build-app' first":
      "VIRHE: %@ puuttuu - suorita ensin 'cloudmachine-agent build-app'",
    "==> Preparing the staging folder":
      "==> Valmistellaan väliaikaista kansiota",
    "==> Creating %@":
      "==> Luodaan %@",
    "ERROR: hdiutil exited with code %@.":
      "VIRHE: hdiutil päättyi koodiin %@.",
    "==> Done: %@":
      "==> Valmis: %@",
    "On first launch (the app is not signed with an Apple Developer account):":
      "Ensimmäisellä käynnistyksellä (appia ei ole allekirjoitettu Apple Developer -tilillä):",
    "1. Open %@ and drag CloudMachine.app to Applications.":
      "1. Avaa %@ ja vedä CloudMachine.app Ohjelmat-kansioon.",
    "2. In Finder, RIGHT-click CloudMachine.app -> Open -> Open\n   (a plain double-click shows the Gatekeeper block \"unidentified developer\").":
      "2. Napsauta Finderissa CloudMachine.app-tiedostoa KAKKOSPAINIKKEELLA -> Avaa -> Avaa\n   (pelkkä kaksoisnapsautus näyttää Gatekeeperin eston ”tunnistamaton kehittäjä”).",
    "3. Later launches work normally, with a double-click.":
      "3. Myöhemmät käynnistykset toimivat normaalisti kaksoisnapsautuksella.",
    "Builds CloudMachine.app (Release) - GUI + cloudmachine-agent in Contents/MacOS/, plus launchd/, vm/ and config/ as Resources.":
      "Rakentaa CloudMachine.app-apin (Release) - GUI + cloudmachine-agent hakemistoon Contents/MacOS/, sekä launchd/, vm/ ja config/ Resources-kansioon.",
    "Binaries for Apple Silicon and Intel at once (how CI builds a release; unnecessary locally).":
      "Binäärit Apple Siliconille ja Intelille kerralla (näin CI rakentaa julkaisun; paikallisesti tarpeeton).",
    "==> Building CloudMachineApp + cloudmachine-agent (release) - version %@ (%@)":
      "==> Rakennetaan CloudMachineApp + cloudmachine-agent (release) - versio %@ (%@)",
    "ERROR: swift build exited with code %@.":
      "VIRHE: swift build päättyi koodiin %@.",
    "ERROR: swift build --show-bin-path did not report the binaries directory.":
      "VIRHE: swift build --show-bin-path ei ilmoittanut binäärien hakemistoa.",
    "ERROR: no built binary found at %@":
      "VIRHE: rakennettua binääriä ei löytynyt polusta %@",
    "==> Assembling the .app bundle in %@":
      "==> Kootaan .app-paketti kansioon %@",
    "==> WARNING: you are building from a DIRTY tree - the version will not point to a commit.":
      "==> VAROITUS: rakennat LIKAISESTA puusta - versio ei osoita mihinkään commitiin.",
    "ERROR: Resources/AppIcon.icns is missing - generate it: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns":
      "VIRHE: Resources/AppIcon.icns puuttuu - luo se: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns",
    "==> Signing with the local certificate '%@' (Full Disk Access will survive later rebuilds)":
      "==> Allekirjoitetaan paikallisella varmenteella '%@' (Täysi levyn käyttö säilyy myöhempien uudelleenrakennusten yli)",
    "==> Signing ad-hoc (no Apple Developer account) - run 'cloudmachine-agent setup-signing-cert' once so that TCC permissions survive later rebuilds":
      "==> Allekirjoitetaan ad hoc (ei Apple Developer -tiliä) - suorita kerran 'cloudmachine-agent setup-signing-cert', jotta TCC-oikeudet säilyvät myöhempien uudelleenrakennusten yli",
    "ERROR: codesign exited with code %@.":
      "VIRHE: codesign päättyi koodiin %@.",
    "Next step: %@":
      "Seuraava vaihe: %@",
    "Creates a local self-signed certificate so that Full Disk Access survives later rebuilds of the app.":
      "Luo paikallisen itse allekirjoitetun varmenteen, jotta Täysi levyn käyttö säilyy apin myöhempien uudelleenrakennusten yli.",
    "Certificate '%@' already exists in %@, nothing to do.":
      "Varmenne '%@' on jo kohteessa %@, ei tehtävää.",
    "==> Generating the key and self-signed certificate '%@'...":
      "==> Luodaan avain ja itse allekirjoitettu varmenne '%@'...",
    "ERROR: openssl req exited with code %@.":
      "VIRHE: openssl req päättyi koodiin %@.",
    "ERROR: openssl pkcs12 exited with code %@.":
      "VIRHE: openssl pkcs12 päättyi koodiin %@.",
    "==> Importing the certificate into %@ (pre-authorizing /usr/bin/codesign, so it does not ask for the keychain password every time)...":
      "==> Tuodaan varmenne kohteeseen %@ (esivaltuutetaan /usr/bin/codesign, jotta avainnipun salasanaa ei kysytä joka kerta)...",
    "ERROR: security import exited with code %@.":
      "VIRHE: security import päättyi koodiin %@.",
    "==> Trusting the certificate ONLY for code signing...":
      "==> Luotetaan varmenteeseen VAIN koodin allekirjoitukseen...",
    "ERROR: security add-trusted-cert exited with code %@.":
      "VIRHE: security add-trusted-cert päättyi koodiin %@.",
    "Done. Certificate '%@' is now available to codesign.":
      "Valmis. Varmenne '%@' on nyt codesignin käytettävissä.",
    "The next 'cloudmachine-agent build-app' will use it automatically instead of an ad-hoc signature.":
      "Seuraava 'cloudmachine-agent build-app' käyttää sitä automaattisesti ad hoc -allekirjoituksen sijaan.",
    "After THAT ONE rebuild, grant Full Disk Access one last time - later\nrebuilds will no longer reset it, as long as you sign with the same certificate.":
      "TÄMÄN YHDEN uudelleenrakennuksen jälkeen myönnä Täysi levyn käyttö vielä viimeisen kerran - myöhemmät\nuudelleenrakennukset eivät enää nollaa sitä, kunhan allekirjoitat samalla varmenteella.",
    "Checks whether the hourly cycle STILL works (date of the last SUCCESSFUL backup) and reports failures.":
      "Tarkistaa, toimiiko tuntikierto EDELLEEN (viimeisen ONNISTUNEEN varmuuskopion päivämäärä), ja ilmoittaa vioista.",
    "After this many hours without a successful backup we consider the cycle broken.":
      "Näin monen tunnin jälkeen ilman onnistunutta varmuuskopiota kierron katsotaan katkenneen.",
    "Only print the state, without a system notification.":
      "Tulosta vain tila, ilman järjestelmäilmoitusta.",
    "A different Time Machine preferences file - to test the watchdog on a known sample.":
      "Eri Time Machine -asetustiedosto - valvojan testaamiseen tunnetulla näytteellä.",
    "Last successful backup: %@":
      "Viimeisin onnistunut varmuuskopio: %@",
    "Last successful backup: NONE":
      "Viimeisin onnistunut varmuuskopio: EI YHTÄÄN",
    "Last attempt:           %@":
      "Viimeisin yritys:       %@",
    "WAITING (system startup): %@":
      "ODOTETAAN (järjestelmän käynnistys): %@",
    "Backup cycle: OK":
      "Varmuuskopiointikierto: OK",
    "FAILURE: %@":
      "VIKA: %@",
    "         %@":
      "         %@",
    "Check the state:  %@":
      "Tarkista tila:  %@",
    "Preparing for restart":
      "Valmistellaan uudelleenkäynnistystä",
    "Prepare for restart":
      "Valmistele uudelleenkäynnistystä varten",
    "Prepare":
      "Valmistele",
    "==> WARNING: git rev-list failed (%@) - using the date as the build number.":
      "==> VAROITUS: git rev-list epäonnistui (%@) - koontinumerona käytetään päivämäärää.",
    "Agents:           %@":
      "Agentit:          %@",
    "CANNOT START: %@ - open CloudMachine or run backup-health to reload them":
      "EI KÄYNNISTY: %@ - avaa CloudMachine tai suorita backup-health ladataksesi ne uudelleen",
    "Reloaded agents that could not start: %@":
      "Uudelleenladattiin agentit, jotka eivät käynnistyneet: %@",
    "Drive folder:     %@":
      "Drive-kansio:     %@",
    "Name of this Mac's folder on Google Drive (default: derived from the computer name). Set once; it cannot be changed later.":
      "Tämän Macin kansion nimi Google Drivessa (oletus: johdettu tietokoneen nimestä). Asetetaan kerran; sitä ei voi muuttaa myöhemmin.",
    "Backup watchdog:  %@":
      "Valvoja:          %@",
    "Prints the version, the build number and the commit this binary was built from.":
      "Tulostaa version, koontinumeron ja commitin, josta tämä binääri on rakennettu.",
    "Only one line, without a description.":
      "Vain yksi rivi, ilman kuvausta.",
    "Build from the working tree (outside a bundle) - no version data.":
      "Koonti työpuusta (paketin ulkopuolella) - ei versiotietoja.",
    "Version: %@":
      "Versio:  %@",
    "Build:   %@":
      "Koonti:  %@",
    "Commit:  %@":
      "Commit:  %@",
    "WARNING: built from a DIRTY tree - the binary contains code that\n         is in no commit. The commit number does NOT describe\n         what actually runs.":
      "VAROITUS: rakennettu LIKAISESTA puusta - binäärissä on koodia, jota\n          ei ole missään commitissa. Commitin numero EI kuvaa\n          sitä, mikä todella on käynnissä.",
    "Saving the space limit":
      "Tallennetaan tilarajaa",
    "Measuring usage on Google Drive":
      "Mitataan käyttöä Google Drivessa",
    "Google Drive did not answer - try again later.":
      "Google Drive ei vastannut - yritä myöhemmin uudelleen.",
    "Measured.":
      "Mitattu.",
    "Space limit for this Mac":
      "Tämän Macin tilaraja",
    "Used on Google Drive":
      "Käytössä Google Drivessa",
    "Measured %@. The watchdog measures again every few hours.":
      "Mitattu %@. Valvoja mittaa uudelleen muutaman tunnin välein.",
    "Limit (GB)":
      "Raja (GB)",
    "Save":
      "Tallenna",
    "Measure now":
      "Mittaa nyt",
    "Time Machine quota: %@ GB (70%% of the limit - the copy on Drive is about a third larger than the backup inside it). Time Machine deletes the oldest backups to stay within it.":
      "Time Machine -kiintiö: %@ GB (70 %% rajasta - Driven kopio on noin kolmanneksen suurempi kuin sen sisällä oleva varmuuskopio). Time Machine poistaa vanhimmat varmuuskopiot pysyäkseen sen sisällä.",
    "Set the Time Machine quota: run this in Terminal (needs sudo)":
      "Aseta Time Machine -kiintiö: suorita tämä Päätteessä (vaatii sudon)",
    "Connect Google Drive: run this in Terminal and approve in the browser":
      "Yhdistä Google Drive: suorita tämä Päätteessä ja hyväksy selaimessa",
    "Grant Full Disk Access to CloudMachine, so it can tell whether backups complete":
      "Myönnä CloudMachinelle Täysi levyn käyttö, jotta se voi tarkistaa, valmistuvatko varmuuskopiot",
    "Folder on Google Drive":
      "Kansio Google Drivessa",
    "One folder per Mac. Set once - it cannot be changed after connecting.":
      "Yksi kansio per Mac. Asetetaan kerran - sitä ei voi muuttaa yhdistämisen jälkeen.",
    "Use lowercase letters, digits and dashes.":
      "Käytä pieniä kirjaimia, numeroita ja tavuviivoja.",
    "Install rclone":
      "Asenna rclone",
    "Open System Settings":
      "Avaa Järjestelmäasetukset",
    "Install agents":
      "Asenna agentit",
    "not checked":
      "ei tarkistettu",
    "none at all":
      "ei yhtään",
    "%@ ago":
      "%@ sitten",
    "Missing: %@":
      "Puuttuu: %@",
    "Google Drive not connected":
      "Google Drivea ei ole yhdistetty",
    "Time Machine does not point to CloudMachine":
      "Time Machine ei osoita CloudMachineen",
    "UNKNOWN whether Time Machine points to CloudMachine - tmutil did not answer":
      "EI TIEDETÄ, osoittaako Time Machine CloudMachineen - tmutil ei vastannut",
    "Backup in progress":
      "Varmuuskopiointi käynnissä",
    "Unknown when the last backup was made":
      "Ei tiedetä, milloin viimeisin varmuuskopio tehtiin",
    "There is no completed backup at all":
      "Valmista varmuuskopiota ei ole lainkaan",
    "No completed backup for %@":
      "Ei valmista varmuuskopiota %@ aikana",
    "Ready":
      "Valmis",
    "Not saved: %@":
      "Ei tallennettu: %@",
    "Installing rclone":
      "Asennetaan rclonea",
    "Installing launchd agents":
      "Asennetaan launchd-agentteja",
    "Starting backup":
      "Käynnistetään varmuuskopiointi",
    "Backup started.":
      "Varmuuskopiointi käynnistetty.",
    "Could not start the backup.":
      "Varmuuskopiointia ei voitu käynnistää.",
    "Stopping backup":
      "Pysäytetään varmuuskopiointi",
    "Backup stopped.":
      "Varmuuskopiointi pysäytetty.",
    "Could not stop the backup.":
      "Varmuuskopiointia ei voitu pysäyttää.",
    "Could not prepare the AppleScript.":
      "AppleScriptiä ei voitu valmistella.",
    "Unknown authorization error.":
      "Tuntematon valtuutusvirhe.",
    "Waiting to upload":
      "Odottaa lähetystä",
    "%@ files":
      "Tiedostoja: %@",
    "nothing":
      "ei mitään",
    "Back up now":
      "Varmuuskopioi nyt",
    "Stop backup":
      "Pysäytä varmuuskopiointi",
    "Open CloudMachine":
      "Avaa CloudMachine",
    "Quit":
      "Lopeta",
    "Healthy":
      "Kunnossa",
    "Attention":
      "Huomio",
    "Refreshed %@":
      "Päivitetty %@",
    "System Status":
      "Järjestelmän tila",
    "Action needed":
      "Vaatii toimenpiteitä",
    "not measured":
      "ei mitattu",
    "rclone did not answer":
      "rclone ei vastannut",
    "Backup in Progress":
      "Varmuuskopiointi käynnissä",
    "Files processed":
      "Käsitellyt tiedostot",
    "Write speed":
      "Kirjoitusnopeus",
    "Operation phase":
      "Toiminnon vaihe",
    "Required Setup Steps":
      "Tarvittavat asennusvaiheet",
    "Copy":
      "Kopioi",
    "Last completed backup":
      "Viimeisin valmis varmuuskopio",
    "Last backup watchdog run":
      "Valvojan viimeisin ajo",
    "not read":
      "ei luettu",
    "Everything uploaded":
      "Kaikki lähetetty",
    "File upload errors":
      "Tiedostojen lähetysvirheet",
    "Google Drive Credentials (OAuth 2.0)":
      "Google Driven tunnistetiedot (OAuth 2.0)",
    "Keychain OK":
      "Avainnippu OK",
    "No custom keys":
      "Ei omia avaimia",
    "Paste client_id...":
      "Liitä client_id...",
    "Paste client_secret...":
      "Liitä client_secret...",
    "Save securely in the Keychain":
      "Tallenna turvallisesti Avainnippuun",
    "Refresh":
      "Päivitä",
    "Overview":
      "Yleiskatsaus",
    "Backups":
      "Varmuuskopiot",
    "Storage":
      "Tallennustila",
    "Settings":
      "Asetukset",
    "Current status: %@":
      "Nykyinen tila: %@",
    "Does not point to CloudMachine":
      "Ei osoita CloudMachineen",
    "tmutil did not answer":
      "tmutil ei vastannut",
    "Backing up: %@ of %@":
      "Varmuuskopioidaan: %@ / %@",
    "%@ of %@":
      "%@ / %@",
    "Copied":
      "Kopioitu",
    "No backup is running":
      "Varmuuskopiointia ei ole käynnissä",
    "Time Machine starts the next one on its own schedule.":
      "Time Machine käynnistää seuraavan oman aikataulunsa mukaan.",
    "Backup cycle":
      "Varmuuskopiointikierto",
    "%@ GiB":
      "%@ GiB",
    "%@ GiB in %@ bands, %@ uploading":
      "%@ GiB, paloja %@, lähetetään %@",
    "%@ bands":
      "Paloja: %@",
    "%@ fragments abandoned - only in the machine":
      "Hylättyjä osia: %@ - vain virtuaalikoneessa",
    "127.0.0.1:5572 answers on the Mac: Lima forwards the machine's rclone remote control, which has no password. Any web page open in a browser can send it commands - including deleting the backup on Google Drive. Add the portForwards rule from vm/cmsmb.yaml to the machine and restart it (see vm/README.md).":
      "127.0.0.1:5572 vastaa Macissa: Lima välittää virtuaalikoneen rclonen etähallinnan, jolla ei ole salasanaa. Mikä tahansa selaimessa avoinna oleva verkkosivu voi lähettää sille komentoja - myös poistaa varmuuskopion Google Drivesta. Lisää virtuaalikoneeseen portForwards-sääntö tiedostosta vm/cmsmb.yaml ja käynnistä se uudelleen (katso vm/README.md).",
    "A service in the CloudMachine machine is not running":
      "CloudMachine-virtuaalikoneen palvelu ei ole käynnissä",
    "Address":
      "Osoite",
    "Agent installation INCOMPLETE - %@ of %@ did not go in:\n%@\n%@\nEvery missing agent is a function that has silently stopped working (vm-guard watches the machine's buffer, backup-health reports failures). Fix the cause and repeat the installation.":
      "Agenttien asennus on EPÄTÄYDELLINEN - %@/%@ ei asentunut:\n%@\n%@\nJokainen puuttuva agentti on toiminto, joka on hiljaa lakannut toimimasta (vm-guard valvoo virtuaalikoneen puskuria, backup-health ilmoittaa vioista). Korjaa syy ja toista asennus.",
    "All running":
      "Kaikki käynnissä",
    "Also install the launchd agents (same as install-launchd).":
      "Asenna myös launchd-agentit (sama kuin install-launchd).",
    "At most this many minutes of waiting for the upload.":
      "Odottaa lähetystä enintään näin monta minuuttia.",
    "At the limit every new band fails with EMFILE and the backup stops. Check: cloudmachine-agent vm-status":
      "Rajalla jokainen uusi pala epäonnistuu virheeseen EMFILE ja varmuuskopiointi pysähtyy. Tarkista: cloudmachine-agent vm-status",
    "Cache on the machine's disk":
      "Välimuisti virtuaalikoneen levyllä",
    "Connected to Google Drive, but could not create the folder '%@' - without it the machine has nowhere to keep the backup. Check the account permissions and try again.":
      "Yhdistetty Google Driveen, mutta kansiota '%@' ei voitu luoda - ilman sitä virtuaalikoneella ei ole paikkaa varmuuskopiolle. Tarkista tilin oikeudet ja yritä uudelleen.",
    "Convert the image":
      "Muunna levykuva",
    "Converting the image to 32 MB bands":
      "Muunnetaan levykuva 32 MB:n paloiksi",
    "Could not check with the current connection whether the backup is on Google Drive (%@), so remote '%@' was NOT replaced: without that answer the new sign-in cannot be checked against it.":
      "Nykyisellä yhteydellä ei voitu tarkistaa, onko varmuuskopio Google Drivessa (%@), joten remote '%@' EI korvattu: ilman tätä vastausta uutta kirjautumista ei voi verrata siihen.",
    "Downloads the official rclone binary into ~/.cloudmachine/bin (Google sign-in and the machine's rclone.conf).":
      "Lataa virallisen rclone-binäärin kansioon ~/.cloudmachine/bin (Google-kirjautuminen ja virtuaalikoneen rclone.conf).",
    "Free in the machine":
      "Vapaana virtuaalikoneessa",
    "Free in the machine: %@":
      "Vapaana virtuaalikoneessa: %@",
    "Generates and installs the launchd agents (app, backup watchdog, machine start, machine guard).":
      "Luo ja asentaa launchd-agentit (appi, varmuuskopioinnin valvoja, virtuaalikoneen käynnistys, virtuaalikoneen vartija).",
    "Install Lima, which runs the CloudMachine machine: run this in Terminal":
      "Asenna Lima, joka ajaa CloudMachine-virtuaalikonetta: suorita tämä Päätteessä",
    "Install rclone (signs in to Google Drive for the machine)":
      "Asenna rclone (kirjaa virtuaalikoneen Google Driveen)",
    "Install the background agents (machine start, buffer guard, backup watchdog)":
      "Asenna taustaagentit (virtuaalikoneen käynnistys, puskurin vartija, varmuuskopioinnin valvoja)",
    "Installs rclone through Homebrew - CloudMachine itself uses the one from install-rclone.":
      "Asentaa rclonen Homebrew'n kautta - CloudMachine itse käyttää install-rclone-komennon asentamaa.",
    "Info.plist, token and mapped/ of the backup image exist only on the machine's disk; without them the bands in %@ cannot be restored. The copy (tm-meta-sync, every 15 min) goes to %@. Check: cloudmachine-agent vm-status, then in the machine: journalctl -u tm-meta-sync":
      "Varmuuskopion levykuvan Info.plist, token ja mapped/ ovat vain virtuaalikoneen levyllä; ilman niitä kansion %@ paloja ei voi palauttaa. Kopio (tm-meta-sync, 15 min välein) menee kohteeseen %@. Tarkista: cloudmachine-agent vm-status, sitten virtuaalikoneessa: journalctl -u tm-meta-sync",
    "Lima says the machine is running, but a command in it did not return. Without it nothing is known about Samba, rclone or the upload. Check: cloudmachine-agent vm-status":
      "Lima kertoo virtuaalikoneen olevan käynnissä, mutta sen komento ei palannut. Ilman sitä Sambasta, rclonesta tai lähetyksestä ei tiedetä mitään. Tarkista: cloudmachine-agent vm-status",
    "Machine":
      "Virtuaalikone",
    "Machine %@":
      "Virtuaalikone %@",
    "Machine & Upload Status":
      "Virtuaalikoneen ja lähetyksen tila",
    "Machine buffer":
      "Virtuaalikoneen puskuri",
    "No Time Machine destination is the machine's share (smb://tm@<address>/CloudMachine) - backups are not being made there. The command is printed by: cloudmachine-agent vm-setup":
      "Mikään Time Machinen kohde ei ole virtuaalikoneen jako (smb://tm@<osoite>/CloudMachine) - varmuuskopioita ei tehdä sinne. Komennon tulostaa: cloudmachine-agent vm-setup",
    "Not running: %@":
      "Ei käynnissä: %@",
    "Not set up":
      "Ei määritetty",
    "Once it runs out, rclone stops uploading, the machine's buffer fills up and backups stop being made. At a growth of ~600 MB per hourly cycle that is about %@ days.":
      "Kun se loppuu, rclone lopettaa lähetyksen, virtuaalikoneen puskuri täyttyy ja varmuuskopiointi loppuu. ~600 MB:n kasvulla tuntikierrosta se on noin %@ vrk.",
    "Or rclone.conf is missing: this Mac has already set up the CloudMachine machine, so it is not connected anew blindly. Restore the file from a backup (the machine keeps its own copy in %@). To connect anyway, create an empty file at the path `%@ config file` prints and run again - the existing folder is kept.":
      "Tai rclone.conf puuttuu: tämä Mac on jo määrittänyt CloudMachine-virtuaalikoneen, joten sitä ei yhdistetä uudelleen sokkona. Palauta tiedosto varmuuskopiosta (virtuaalikoneella on oma kopionsa kohteessa %@). Yhdistääksesi silti luo tyhjä tiedosto polkuun, jonka `%@ config file` tulostaa, ja suorita uudelleen - olemassa oleva kansio säilyy.",
    "Point Time Machine at the machine: run this in Terminal (needs sudo; Copy includes the password)":
      "Osoita Time Machine virtuaalikoneeseen: suorita tämä Päätteessä (vaatii sudon; Kopioi sisältää salasanan)",
    "Points to the machine":
      "Osoittaa virtuaalikoneeseen",
    "Prepares for a restart: stops the backup, waits a while for the upload, then stops the machine cleanly.":
      "Valmistelee uudelleenkäynnistystä: pysäyttää varmuuskopioinnin, odottaa hetken lähetystä ja pysäyttää sitten virtuaalikoneen siististi.",
    "Reading the Time Machine destination did not return within %@ s. That is how tmutil behaves when its destination hangs.":
      "Time Machinen kohteen luku ei palannut %@ s kuluessa. Näin tmutil käyttäytyy, kun sen kohde jumittuu.",
    "Remote '%@' was NOT replaced. The new sign-in gets the 'drive.file' scope, which sees only files created under its own client_id. The existing backup was most likely created by the current connection and would become invisible to it. Before anything is written, the new token is checked against the existing backup, and the replacement is abandoned if it cannot see it. The machine keeps its own copy of the configuration until vm-setup --replace-rclone-config. To go ahead, run again with --replace-existing --accept-scope-change.":
      "Remote '%@' EI korvattu. Uusi kirjautuminen saa laajuuden 'drive.file', joka näkee vain omalla client_id:llään luodut tiedostot. Olemassa oleva varmuuskopio luotiin todennäköisesti nykyisellä yhteydellä, ja se muuttuisi sille näkymättömäksi. Ennen kuin mitään kirjoitetaan, uusi token tarkistetaan olemassa olevaa varmuuskopiota vasten, ja korvaus keskeytetään, jos se ei näe sitä. Virtuaalikone säilyttää oman kopionsa kokoonpanosta, kunnes vm-setup --replace-rclone-config. Jatkaaksesi suorita uudelleen valinnoilla --replace-existing --accept-scope-change.",
    "Remote control:   OPEN on the Mac at 127.0.0.1:5572 - any web page can send rclone commands; see vm/README.md (portForwards)":
      "Etähallinta:      AVOIN Macissa osoitteessa 127.0.0.1:5572 - mikä tahansa verkkosivu voi lähettää rclone-komentoja; katso vm/README.md (portForwards)",
    "Running":
      "Käynnissä",
    "Samba, rclone or punchfs in the machine is not active, so Time Machine has nowhere to write or the bands do not reach Google Drive. Check: cloudmachine-agent vm-status":
      "Samba, rclone tai punchfs ei ole aktiivinen virtuaalikoneessa, joten Time Machinella ei ole minne kirjoittaa tai palat eivät pääse Google Driveen. Tarkista: cloudmachine-agent vm-status",
    "Service %@":
      "Palvelu %@",
    "Services":
      "Palvelut",
    "Set up the CloudMachine machine (the first time it downloads Ubuntu - several minutes)":
      "Määritä CloudMachine-virtuaalikone (ensimmäisellä kerralla ladataan Ubuntu - useita minuutteja)",
    "Set up the CloudMachine machine again, so it prints the Time Machine command":
      "Määritä CloudMachine-virtuaalikone uudelleen, jotta se tulostaa Time Machine -komennon",
    "Set up the machine":
      "Määritä virtuaalikone",
    "Setting up the CloudMachine machine":
      "Määritetään CloudMachine-virtuaalikonetta",
    "Start the CloudMachine machine":
      "Käynnistä CloudMachine-virtuaalikone",
    "Start the machine":
      "Käynnistä virtuaalikone",
    "Starting the CloudMachine machine":
      "Käynnistetään CloudMachine-virtuaalikonetta",
    "Still to upload: %@ GiB":
      "Lähetettävää jäljellä: %@ GiB",
    "Stopping the Time Machine backup...":
      "Pysäytetään Time Machine -varmuuskopiointia...",
    "Stopping the machine %@...":
      "Pysäytetään virtuaalikonetta %@...",
    "The CloudMachine machine does not answer":
      "CloudMachine-virtuaalikone ei vastaa",
    "The CloudMachine machine is not running":
      "CloudMachine-virtuaalikone ei ole käynnissä",
    "The CloudMachine machine is not set up yet":
      "CloudMachine-virtuaalikonetta ei ole vielä määritetty",
    "The CloudMachine machine is stopped":
      "CloudMachine-virtuaalikone on pysäytetty",
    "The backup is stopped, the upload gets up to 30 minutes, then the machine shuts down cleanly. It starts again at the next login.":
      "Varmuuskopiointi pysäytetään, lähetys saa aikaa enintään 30 minuuttia, sitten virtuaalikone sammutetaan siististi. Se käynnistyy uudelleen seuraavassa kirjautumisessa.",
    "The machine %@ is not running - nothing to prepare.":
      "Virtuaalikone %@ ei ole käynnissä - ei valmisteltavaa.",
    "The machine is stopped and everything reached Google Drive. The Mac can be restarted; the machine starts again at login.":
      "Virtuaalikone on pysäytetty ja kaikki on päässyt Google Driveen. Macin voi käynnistää uudelleen; virtuaalikone käynnistyy taas kirjautumisen yhteydessä.",
    "The machine is stopped. %@ GiB had not reached Google Drive yet - it is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "Virtuaalikone on pysäytetty. %@ GiB ei ollut vielä päässyt Google Driveen - se säilyy virtuaalikoneen puskurissa ja lähetetään seuraavan käynnistyksen jälkeen. Macin voi käynnistää uudelleen.",
    "The machine is stopped. rclone did not say how much was still to upload; what was not uploaded is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "Virtuaalikone on pysäytetty. rclone ei kertonut, kuinka paljon oli vielä lähettämättä; lähettämättä jäänyt säilyy virtuaalikoneen puskurissa ja lähetetään seuraavan käynnistyksen jälkeen. Macin voi käynnistää uudelleen.",
    "The machine's disk is a file on this disk and grows as the upload buffer fills. With no space left the machine cannot write the buffer, and Time Machine's local snapshots have nowhere to go either.":
      "Virtuaalikoneen levy on tiedosto tällä levyllä ja kasvaa lähetyspuskurin täyttyessä. Ilman vapaata tilaa virtuaalikone ei voi kirjoittaa puskuria, eikä Time Machinen paikallisillakaan tilannevedoksilla ole minne mennä.",
    "The image's metadata has never been copied to Drive":
      "Levykuvan metatietoja ei ole koskaan kopioitu Driveen",
    "The image's metadata was last copied to Drive %@ ago":
      "Levykuvan metatiedot kopioitiin Driveen viimeksi %@ sitten",
    "The machine's disk is running out of space (%@ GB)":
      "Virtuaalikoneen levyltä loppuu tila (%@ GB)",
    "The new sign-in does NOT see the existing backup (%@), so remote '%@' was NOT replaced and rclone.conf is unchanged. Keep the current connection, or sign in with the credential (client_id) that created the backup.":
      "Uusi kirjautuminen EI näe olemassa olevaa varmuuskopiota (%@), joten remote '%@' EI korvattu ja rclone.conf on muuttumaton. Pidä nykyinen yhteys tai kirjaudu tunnistetiedoilla (client_id), jotka loivat varmuuskopion.",
    "The upload buffer lives on this disk. The guard pauses Time Machine before it fills; if the upload does not catch up, backups stay paused.":
      "Lähetyspuskuri sijaitsee tällä levyllä. Vartija keskeyttää Time Machinen ennen kuin se täyttyy; jos lähetys ei pääse perässä, varmuuskopiointi pysyy keskeytettynä.",
    "These bands exist only in the machine's buffer. The backup on Google Drive is INCOMPLETE and may not open.":
      "Nämä palat ovat vain virtuaalikoneen puskurissa. Varmuuskopio Google Drivessa on EPÄTÄYDELLINEN eikä välttämättä aukea.",
    "Time Machine backs up to the machine, so without it no backup is made. Start it: limactl start %@ (or the Start button in the app).":
      "Time Machine varmuuskopioi virtuaalikoneeseen, joten ilman sitä varmuuskopiota ei synny. Käynnistä se: limactl start %@ (tai apin Käynnistä virtuaalikone -painikkeella).",
    "Time Machine did not stop its backup within 2 minutes (or tmutil did not answer) - the machine was NOT stopped. Try again in a moment.":
      "Time Machine ei pysäyttänyt varmuuskopiointiaan 2 minuutissa (tai tmutil ei vastannut) - virtuaalikonetta EI pysäytetty. Yritä hetken kuluttua uudelleen.",
    "Time Machine has created its image: stop the backup, then convert the image to 32 MB bands":
      "Time Machine on luonut levykuvansa: pysäytä varmuuskopiointi ja muunna sitten levykuva 32 MB:n paloiksi",
    "To upload":
      "Lähetettävää",
    "Unknown whether the CloudMachine machine is running":
      "Ei tiedetä, onko CloudMachine-virtuaalikone käynnissä",
    "Waiting for the upload to Google Drive (at most %@ min)...":
      "Odotetaan lähetystä Google Driveen (enintään %@ min)...",
    "With --replace-existing: confirms that the new sign-in (scope 'drive.file') may not see the existing backup. The new token is still checked against the backup first.":
      "Valinnan --replace-existing kanssa: vahvistaa, että uusi kirjautuminen (laajuus 'drive.file') ei ehkä näe olemassa olevaa varmuuskopiota. Uusi token tarkistetaan silti ensin varmuuskopiota vasten.",
    "Without it there is no way to check whether anything reached the Drive - the machine's guard is blind then.":
      "Ilman sitä ei voi tarkistaa, onko mitään päässyt Driveen - virtuaalikoneen vartija on silloin sokea.",
    "limactl did not answer":
      "limactl ei vastannut",
    "limactl did not answer (or is not installed). That does not mean the machine is down - it means nobody has checked.":
      "limactl ei vastannut (tai sitä ei ole asennettu). Se ei tarkoita, että virtuaalikone on alhaalla - se tarkoittaa, ettei kukaan ole tarkistanut.",
    "limactl start failed: %@":
      "limactl start epäonnistui: %@",
    "limactl stop failed: %@":
      "limactl stop epäonnistui: %@",
    "punchfs is close to its open-file limit":
      "punchfs on lähellä avointen tiedostojen rajaa",
    "punchfs open files":
      "punchfsn avoimet tiedostot",
    "rclone's remote control is open on this Mac":
      "rclonen etähallinta on auki tässä Macissa",
    "statfs('/System/Volumes/Data') returned an error, so nobody knows whether the machine's disk can still grow on this Mac.":
      "statfs('/System/Volumes/Data') palautti virheen, joten kukaan ei tiedä, voiko virtuaalikoneen levy vielä kasvaa tässä Macissa.",
    "Google Drive's daily upload limit stops the upload":
      "Google Driven päivittäinen lähetysraja pysäyttää lähetyksen",
    "Google last refused an upload %@ ago (750 GB a day). Backups since then are only in the machine's buffer on this Mac. rclone retries every 5 min and resumes by itself when the limit passes; the guard pauses Time Machine if more than %@ GiB waits.":
      "Google hylkäsi viimeksi lähetyksen %@ sitten (750 GB vuorokaudessa). Sen jälkeiset varmuuskopiot ovat vain virtuaalikoneen puskurissa tässä Macissa. rclone yrittää uudelleen 5 min välein ja jatkaa itse rajan mentyä ohi; vartija keskeyttää Time Machinen, jos yli %@ GiB odottaa.",
    "Usage on Google Drive is not being measured":
      "Google Driven käyttöä ei mitata",
    "The last measurement (%@ GB) is from %@, %@ ago - rclone size has not answered since. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "Viimeisin mittaus (%@ GB) on ajalta %@, %@ sitten - rclone size ei ole vastannut sen jälkeen. Siihen asti kukaan ei valvo %@ GB:n rajaa: 90 %%:n ja 100 %%:n hälytykset pysyvät hiljaa. Tarkista vm-status tai paina ikkunassa Mittaa nyt.",
    "rclone size has not answered even once. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "rclone size ei ole vastannut kertaakaan. Siihen asti kukaan ei valvo %@ GB:n rajaa: 90 %%:n ja 100 %%:n hälytykset pysyvät hiljaa. Tarkista vm-status tai paina ikkunassa Mittaa nyt.",
    "Saved in the Keychain. Connecting Google Drive (configure-remote) will use them.":
      "Tallennettu Avainnippuun. Google Driveen yhdistäminen (configure-remote) käyttää niitä.",
    "Saved in the Keychain. The existing Google Drive connection keeps its old client_id, and on this Mac it should stay that way: a connection made with the new keys (the 'drive.file' scope) cannot see the backup created by the old one. Do not replace the connection here; the new keys are for a Mac that is not connected yet.":
      "Tallennettu Avainnippuun. Olemassa oleva Google Drive -yhteys säilyttää vanhan client_id-tunnuksensa, ja tässä Macissa niin pitääkin olla: uusilla avaimilla (laajuus 'drive.file') tehty yhteys ei näe vanhalla luotua varmuuskopiota. Älä korvaa yhteyttä täällä; uudet avaimet ovat Macille, jota ei ole vielä yhdistetty.",
    "it is not there for the new token":
      "sitä ei ole uudelle tokenille",
    "Cancel":
      "Peruuta",
    "ACTION NEEDED":
      "VAATII TOIMENPITEITÄ",
    "WILL PASS BY ITSELF — DO NOTHING":
      "MENEE OHI ITSESTÄÄN — ÄLÄ TEE MITÄÄN",
    "UNKNOWN — CHECK AGAIN SHORTLY":
      "EI TIEDETÄ — TARKISTA PIAN UUDELLEEN",
    "ALL GOOD":
      "KAIKKI KUNNOSSA",
    "Upload is not working":
      "Lähetys ei toimi",
    "Upload stopped — no space left on Google Drive":
      "Lähetys pysähtyi — Google Drivessa ei ole tilaa",
    "%@ backup fragments not uploaded":
      "Varmuuskopion osia ei lähetetty: %@",
    "Upload cannot keep up with writes":
      "Lähetys ei pysy kirjoitusten tahdissa",
    "Upload paused — Google daily limit":
      "Lähetys keskeytetty — Googlen vuorokausiraja",
    "Uploading to Google Drive — %@ queued":
      "Lähetetään Google Driveen — jonossa %@",
    "Everything uploaded to Google Drive":
      "Kaikki lähetetty Google Driveen",
    "Unknown what is waiting in the queue":
      "Ei tiedetä, mikä jonossa odottaa",
    "There is no connection to Google Drive, so backups are only made on this Mac. If this does not pass by itself within a few minutes, check the network and the connection to Drive.":
      "Google Driveen ei ole yhteyttä, joten varmuuskopioita tehdään vain tässä Macissa. Jos tämä ei mene ohi itsestään muutamassa minuutissa, tarkista verkko ja yhteys Driveen.",
    "There is no space left on Google Drive. This will NOT pass by itself — you need to free up space on Drive. Until then Time Machine is paused, so that it does not fill up this Mac's disk.":
      "Google Drivessa ei ole enää tilaa. Tämä EI mene ohi itsestään — Driveen täytyy vapauttaa tilaa. Siihen asti Time Machine on keskeytetty, jotta se ei täytä tämän Macin levyä.",
    "%@ backup fragments could not be uploaded and rclone stopped trying. These fragments exist only on this Mac, so the backup on Drive is incomplete. This needs checking.":
      "Varmuuskopion osia (%@) ei voitu lähettää, ja rclone lopetti yrittämisen. Nämä osat ovat vain tässä Macissa, joten Driven varmuuskopio on epätäydellinen. Tämä pitää tarkistaa.",
    "Time Machine is writing faster than the upload goes, and the buffer has filled up. The backup will be paused until the upload catches up — this is a safeguard against filling up the disk, not a failure.":
      "Time Machine kirjoittaa nopeammin kuin lähetys etenee, ja puskuri on täyttynyt. Varmuuskopiointi keskeytetään, kunnes lähetys pääsee perässä — tämä on suoja levyn täyttymistä vastaan, ei vika.",
    "Google accepts 750 GB per day and that limit has been used up. There is nothing to do: the limit renews by itself, usually within a few hours. Time Machine backups are made normally in the meantime and wait in the buffer — they will be uploaded as soon as Google starts accepting again.":
      "Google ottaa vastaan 750 GB vuorokaudessa, ja tämä raja on käytetty. Mitään ei tarvitse tehdä: raja uusiutuu itsestään, yleensä muutamassa tunnissa. Time Machine -varmuuskopiot syntyvät sillä välin normaalisti ja odottavat puskurissa — ne lähetetään heti, kun Google alkaa taas vastaanottaa.",
    "%@ backup fragments are queued and on their way to Drive.":
      "Varmuuskopion osia jonossa matkalla Driveen: %@.",
    "Nothing is waiting in the queue — the backup on Google Drive is complete.":
      "Jonossa ei odota mitään — Google Driven varmuuskopio on täydellinen.",
    "rclone did not answer the question about the queue, so it is unknown how many backups are still waiting to be uploaded. This does not mean something broke — under load the answer can be late. It only means that right now nobody knows. If it persists, the backup cycle check will report it.":
      "rclone ei vastannut jonoa koskevaan kysymykseen, joten ei tiedetä, kuinka monta varmuuskopiota odottaa vielä lähetystä. Se ei tarkoita, että jokin olisi rikki — kuormituksessa vastaus voi myöhästyä. Se tarkoittaa vain, ettei kukaan tiedä sitä juuri nyt. Jos tilanne jatkuu, varmuuskopiointikierron tarkistus ilmoittaa siitä.",
    "unknown error":
      "tuntematon virhe",
    "rclone lsf ended with an error":
      "rclone lsf päättyi virheeseen",
    "This Mac is close to its space limit on Google Drive":
      "Tämä Mac lähestyy Google Driven tilarajaansa",
    "%@ GB of %@ GB used. Time Machine deletes the oldest backups to stay within its quota; check that the quota is set (vm-status).":
      "%@ GB / %@ GB käytössä. Time Machine poistaa vanhimmat varmuuskopiot pysyäkseen kiintiössään; tarkista, että kiintiö on asetettu (vm-status).",
    "This Mac is over its space limit on Google Drive":
      "Tämä Mac on ylittänyt Google Driven tilarajansa",
    "%@ GB of %@ GB used. Set the Time Machine quota (command in the app window or vm-status), or raise the limit.":
      "%@ GB / %@ GB käytössä. Aseta Time Machine -kiintiö (komento apin ikkunassa tai vm-status) tai nosta rajaa.",
    "not set":
      "ei asetettu",
    "%@ GB - usage not measured yet":
      "%@ GB - käyttöä ei ole vielä mitattu",
    "%@ of %@ GB used (%@%%)":
      "%@ / %@ GB käytössä (%@ %%)",
    "The limit must be a whole number of GB above zero.":
      "Rajan on oltava nollaa suurempi kokonaisluku GB:na.",
    "machines.json cannot be read, so it was not overwritten. Fix or remove it first.":
      "machines.json ei ole luettavissa, joten sitä ei korvattu. Korjaa tai poista se ensin.",
    "'%@' is not a valid folder name: use lowercase letters, digits and dashes.":
      "'%@' ei ole kelvollinen kansion nimi: käytä pieniä kirjaimia, numeroita ja tavuviivoja.",
    "This Mac already backs up to folder '%@'. Switching to '%@' would start a new, empty backup and orphan the existing one, so nothing was changed.":
      "Tämä Mac varmuuskopioi jo kansioon '%@'. Vaihtaminen kansioon '%@' aloittaisi uuden, tyhjän varmuuskopion ja jättäisi olemassa olevan orvoksi, joten mitään ei muutettu.",
    "This Mac already has a CloudMachine installation, whose backup is in folder '%@'. Switching to '%@' would orphan it, so nothing was changed.":
      "Tässä Macissa on jo CloudMachine-asennus, jonka varmuuskopio on kansiossa '%@'. Vaihtaminen kansioon '%@' jättäisi sen orvoksi, joten mitään ei muutettu.",
    "Could not save the folder name to %@: %@":
      "Kansion nimeä ei voitu tallentaa kohteeseen %@: %@",
    "Homebrew is not installed. Install it manually: https://brew.sh":
      "Homebrewta ei ole asennettu. Asenna se käsin: https://brew.sh",
    "Installing rclone failed: %@":
      "rclonen asennus epäonnistui: %@",
    "Installed rclone.":
      "rclone asennettu.",
    "Own Google credentials: set.":
      "Omat Google-tunnistetiedot: asetettu.",
    "INCOMPLETE: %@ is missing - rclone will use rclone's shared client_id anyway.":
      "EPÄTÄYDELLINEN: %@ puuttuu - rclone käyttää silti rclonen yhteistä client_id-tunnusta.",
    "No own credentials - rclone uses the shared client_id, rate-limited jointly and being retired in 2026.":
      "Ei omia tunnistetietoja - rclone käyttää yhteistä client_id-tunnusta, jonka nopeusrajoitus on yhteinen ja joka poistuu käytöstä vuonna 2026.",
    "Empty value - not saving.":
      "Tyhjä arvo - ei tallenneta.",
    "Keychain refused: %@":
      "Avainnippu kieltäytyi: %@",
    "DIRTY-TREE":
      "LIKAINEN-PUU",
    "Cannot create the working directory: %@":
      "Työhakemistoa ei voi luoda: %@",
    "Could not read the rclone version number.":
      "rclonen versionumeroa ei voitu lukea.",
    "Could not download %@.":
      "Kohdetta %@ ei voitu ladata.",
    "No entry for %@ in SHA256SUMS.":
      "Kohteelle %@ ei ole merkintää tiedostossa SHA256SUMS.",
    "Could not compute the checksum.":
      "Tarkistussummaa ei voitu laskea.",
    "SHA256 checksum does not match - NOT installing.\n  expected: %@\n  computed: %@":
      "SHA256-tarkistussumma ei täsmää - EI asenneta.\n  odotettu: %@\n  laskettu: %@",
    "Could not unpack the archive.":
      "Arkistoa ei voitu purkaa.",
    "Could not install the binary: %@":
      "Binääriä ei voitu asentaa: %@",
    "Installed rclone %@ in %@ (SHA256 checksum matches).":
      "Asennettu rclone %@ kohteeseen %@ (SHA256-tarkistussumma täsmää).",
    "%@ did not respond within the allotted time (the process was left orphaned in the background).":
      "%@ ei vastannut sallitussa ajassa (prosessi jäi orvoksi taustalle).",
    "Cannot launch %@: %@":
      "Kohdetta %@ ei voi käynnistää: %@",
    "Remote '%@' already exists and was NOT touched.\nOverwriting it replaces the token and the permission scope; a credential with the 'drive.file' scope does not see files created by the previous one, so the existing backup becomes unreachable.\nIf you really want to replace it, first back up ~/.config/rclone/rclone.conf and run again with --replace-existing.":
      "Remote '%@' on jo olemassa, eikä sitä KOSKETTU.\nSen korvaaminen vaihtaa tokenin ja oikeuksien laajuuden; tunniste, jonka laajuus on 'drive.file', ei näe edellisen luomia tiedostoja, joten olemassa oleva varmuuskopio muuttuu tavoittamattomaksi.\nJos todella haluat korvata sen, tee ensin varmuuskopio tiedostosta ~/.config/rclone/rclone.conf ja suorita uudelleen valinnalla --replace-existing.",
    "Could not check whether remote '%@' already exists (rclone listremotes did not answer or failed), so nothing was changed. Run `%@ listremotes` to see the error, then try again.":
      "Ei voitu tarkistaa, onko remote '%@' jo olemassa (rclone listremotes ei vastannut tai epäonnistui), joten mitään ei muutettu. Suorita `%@ listremotes` nähdäksesi virheen ja yritä sitten uudelleen.",
    "Could not check whether this Mac already has a CloudMachine installation (rclone did not answer), so no folder was chosen. Try again in a moment.":
      "Ei voitu tarkistaa, onko tässä Macissa jo CloudMachine-asennus (rclone ei vastannut), joten kansiota ei valittu. Yritä hetken kuluttua uudelleen.",
    "rclone authorize failed (%@). If that binary is missing, start with: cloudmachine-agent install-rclone.":
      "rclone authorize epäonnistui (%@). Jos tätä binääriä ei ole, aloita komennolla: cloudmachine-agent install-rclone.",
    "Could not read the token from the output of rclone authorize.":
      "Tokenia ei voitu lukea rclone authorize -komennon tulosteesta.",
    "rclone config create failed.":
      "rclone config create epäonnistui.",
    "Connected to Google Drive as remote '%@', folder %@.":
      "Yhdistetty Google Driveen remotena '%@', kansio %@.",
    "tmutil is not responding - unknown where the backup goes":
      "tmutil ei vastaa - ei tiedetä, minne varmuuskopio menee",
    "No successful backup for %@":
      "Ei onnistunutta varmuuskopiota %@ aikana",
    "Last COMPLETED backup: %@. The cycle is hourly, so that is %@ missed runs.":
      "Viimeisin VALMIS varmuuskopio: %@. Kierto on tunnin välein, joten väliin jääneitä ajoja on %@.",
    "There is NOT A SINGLE successful backup":
      "Yhtään onnistunutta varmuuskopiota EI OLE",
    "The Time Machine preferences contain no date of a completed backup for this destination.":
      "Time Machinen asetuksissa ei ole tämän kohteen valmiin varmuuskopion päivämäärää.",
    "The last backup attempt did not end in a backup":
      "Viimeisin varmuuskopiointiyritys ei johtanut varmuuskopioon",
    "The attempt at %@ is newer than the last successful backup at %@.":
      "Yritys %@ on uudempi kuin viimeisin onnistunut varmuuskopio %@.",
    "Time Machine reports an error in the last run (RESULT=%@)":
      "Time Machine ilmoittaa virheestä viimeisimmässä ajossa (RESULT=%@)",
    "A non-zero RESULT in the Time Machine preferences means the run did not succeed.":
      "Nollasta poikkeava RESULT Time Machinen asetuksissa tarkoittaa, että ajo ei onnistunut.",
    "rclone failed to upload %@ files":
      "Tiedostoja, joita rclone ei onnistunut lähettämään: %@",
    "Buffer full of nothing but unsent data":
      "Puskuri täynnä pelkkää lähettämätöntä dataa",
    "rclone has nothing left to evict from the buffer - the upload cannot keep up or has stalled.":
      "rclonella ei ole enää mitään poistettavaa puskurista - lähetys ei pysy mukana tai on pysähtynyt.",
    "The rclone control interface is not responding":
      "rclonen ohjausrajapinta ei vastaa",
    "Google Drive is running out of space (%@ GB)":
      "Google Driven tila on loppumassa (%@ GB)",
    "The Mac's disk is running out of space (%@ GB)":
      "Macin levyn tila on loppumassa (%@ GB)",
    "Cannot read the Time Machine preferences":
      "Time Machinen asetuksia ei voi lukea",
    "%@ is unreadable - most often Full Disk Access is missing. Without this file it is UNKNOWN when the last backup was made, so we treat it as a failure, not as the absence of a problem.":
      "%@ ei ole luettavissa - useimmiten Täysi levyn käyttö puuttuu. Ilman tätä tiedostoa EI TIEDETÄ, milloin viimeinen varmuuskopio tehtiin, joten käsittelemme sen vikana, emme ongelman puuttumisena.",
    "Cannot measure free space on the Mac's disk":
      "Macin levyn vapaata tilaa ei voi mitata",
    "%@ days":
      "%@ vrk",
    "CloudMachine: backup is not working":
      "CloudMachine: varmuuskopiointi ei toimi",
    "unknown reason":
      "tuntematon syy",
    "osascript did not show the notification (permissions or no graphical session)":
      "osascript ei näyttänyt ilmoitusta (oikeudet tai ei graafista istuntoa)",
    "UNDELIVERED ALARM: %@":
      "TOIMITTAMATON HÄLYTYS: %@",
    "from %@, reason: %@":
      "lähde %@, syy: %@",
    "The system notification was not delivered - you will see this alarm ONLY here.":
      "Järjestelmäilmoitus ei mennyt perille - näet tämän hälytyksen VAIN täällä.",
    "%@ (%@ ago)":
      "%@ (%@ sitten)",
    "%@ - marker from the FUTURE":
      "%@ - merkki TULEVAISUUDESTA",
    "%@ (%@ ago) - THE WATCHDOG MAY NOT BE RUNNING":
      "%@ (%@ sitten) - VALVOJA EI EHKÄ OLE KÄYNNISSÄ",
    "NEVER - the watchdog has not recorded a single run":
      "EI KOSKAAN - valvoja ei ole kirjannut yhtään ajoa",
    "Could not find the launchd/ directory with templates.":
      "Mallipohjien hakemistoa launchd/ ei löytynyt.",
    "Could not find the compiled cloudmachine-agent binary.":
      "Käännettyä cloudmachine-agent-binääriä ei löytynyt.",
    "ABORTED: could not put cloudmachine-agent in a stable location\n(%@) - most often a lack of space or permissions.\nNOT installing agents pointing at %@: that path\ndisappears on the next `swift build` or `git clean`, and backups stop\nwithout any visible signal.":
      "KESKEYTETTY: cloudmachine-agentia ei voitu sijoittaa vakaaseen paikkaan\n(%@) - useimmiten tilan tai oikeuksien puutteen vuoksi.\nEI asenneta agentteja, jotka osoittavat polkuun %@: se polku\nkatoaa seuraavalla `swift build`- tai `git clean` -komennolla, ja varmuuskopiointi loppuu\nilman mitään näkyvää merkkiä.",
    "ABORTED: %@":
      "KESKEYTETTY: %@",
    "Could not list the templates in %@.":
      "Kohteen %@ mallipohjia ei voitu listata.",
    "could not read the template %@":
      "mallipohjaa %@ ei voitu lukea",
    "could not write %@ (lack of space or permissions)":
      "kohdetta %@ ei voitu kirjoittaa (tilan tai oikeuksien puute)",
    "launchctl load refused to load %@":
      "launchctl load kieltäytyi lataamasta kohdetta %@",
    "NOT A SINGLE agent was loaded.":
      "YHTÄÄN agenttia EI ladattu.",
    "Only these went in: %@.":
      "Vain nämä asentuivat: %@.",
    "Could not load any launchd agent.":
      "Yhtään launchd-agenttia ei voitu ladata.",
    "Installed agents: %@":
      "Asennetut agentit: %@",
    "                  WARNING: close to the limit - new bands will fail with EMFILE":
      "                  VAROITUS: lähellä rajaa - uudet palat epäonnistuvat virheeseen EMFILE",
    "%@/bands on Google Drive is not empty - it may hold another backup. NOT overwriting it; check it by hand.":
      "%@/bands Google Drivessa ei ole tyhjä - siellä voi olla toinen varmuuskopio. EI ylikirjoiteta; tarkista käsin.",
    "Address:          %@":
      "Osoite:           %@",
    "Already prepared (%@ exists) - nothing to do.":
      "Jo valmisteltu (%@ on olemassa) - ei tehtävää.",
    "Converts Time Machine's new, empty image in the machine to 32 MB bands and moves the bands to Google Drive.":
      "Muuntaa Time Machinen uuden, tyhjän levykuvan virtuaalikoneessa 32 MB:n paloiksi ja siirtää palat Google Driveen.",
    "Copy rclone.conf into the machine even if it already has one.":
      "Kopioi rclone.conf virtuaalikoneeseen, vaikka siinä jo olisi sellainen.",
    "Copying the converted image into the machine failed: %@":
      "Muunnetun levykuvan kopiointi virtuaalikoneeseen epäonnistui: %@",
    "Copying the image to the Mac failed: %@":
      "Levykuvan kopiointi Maciin epäonnistui: %@",
    "Could not ask Lima about the machine: %@":
      "Limalta ei voitu kysyä virtuaalikoneesta: %@",
    "Could not carry the Time Machine files over: %@":
      "Time Machine -tiedostoja ei voitu siirtää: %@",
    "Could not check the image in the machine.":
      "Levykuvaa ei voitu tarkistaa virtuaalikoneessa.",
    "Could not copy the rclone configuration into the machine.":
      "rclone-kokoonpanoa ei voitu kopioida virtuaalikoneeseen.",
    "Could not create %@ on Google Drive: %@":
      "Kohdetta %@ ei voitu luoda Google Driveen: %@",
    "Could not create %@: %@":
      "Kohdetta %@ ei voitu luoda: %@",
    "Could not find the vm/ directory with the machine template.":
      "Virtuaalikoneen mallipohjan hakemistoa vm/ ei löytynyt.",
    "Could not read the image size.":
      "Levykuvan kokoa ei voitu lukea.",
    "Could not set the SMB password of user %@ in the machine.":
      "Käyttäjän %@ SMB-salasanaa ei voitu asettaa virtuaalikoneessa.",
    "Could not stop smbd in the machine.":
      "smbd:tä ei voitu pysäyttää virtuaalikoneessa.",
    "Could not write %@ in the machine.":
      "Kohdetta %@ ei voitu kirjoittaa virtuaalikoneessa.",
    "Could not write the password file %@.":
      "Salasanatiedostoa %@ ei voitu kirjoittaa.",
    "Creates or starts the CloudMachine machine (Lima), gives it rclone's configuration and an SMB password, and prints the Time Machine command.":
      "Luo tai käynnistää CloudMachine-virtuaalikoneen (Lima), antaa sille rclonen kokoonpanon ja SMB-salasanan ja tulostaa Time Machine -komennon.",
    "Creating the machine %@ (first start downloads Ubuntu and installs packages - several minutes)...":
      "Luodaan virtuaalikonetta %@ (ensimmäinen käynnistys lataa Ubuntun ja asentaa paketit - useita minuutteja)...",
    "Done: %@ has %@ MB bands on Google Drive; the original is kept in %@ in the machine. Start the backup: tmutil startbackup":
      "Valmis: kohteen %@ palat ovat %@ MB:n kokoisia Google Drivessa; alkuperäinen säilyy kohteessa %@ virtuaalikoneessa. Käynnistä varmuuskopiointi: tmutil startbackup",
    "exit code %@, no message":
      "poistumiskoodi %@, ei viestiä",
    "Image metadata:   NEVER copied to %@ - check tm-meta-sync in the machine":
      "Metatiedot:       EI KOSKAAN kopioitu kohteeseen %@ - tarkista tm-meta-sync virtuaalikoneessa",
    "Image metadata:   copied %@ ago to %@":
      "Metatiedot:       kopioitu %@ sitten kohteeseen %@",
    "Image metadata:   last copied %@ ago - OVERDUE (%@)":
      "Metatiedot:       viimeksi kopioitu %@ sitten - MYÖHÄSSÄ (%@)",
    "Image metadata:   not copied yet - waits for vm-prepare-bundle":
      "Metatiedot:       ei vielä kopioitu - odottaa vm-prepare-bundlea",
    "Backup %@, paused by the guard %@: %@":
      "Varmuuskopio %@, vartijan keskeyttämä %@: %@",
    "Free in machine:  %@ GiB":
      "Vapaana virtuaalikoneessa: %@ GiB",
    "fsck_apfs -n found problems: %@":
      "fsck_apfs -n löysi ongelmia: %@",
    "Google Drive folder: %@":
      "Google Drive -kansio: %@",
    "hdiutil attach of the converted image failed: %@":
      "muunnetun levykuvan hdiutil attach epäonnistui: %@",
    "hdiutil convert failed: %@":
      "hdiutil convert epäonnistui: %@",
    "Image name in the machine (default: from the computer name).":
      "Levykuvan nimi virtuaalikoneessa (oletus: johdettu tietokoneen nimestä).",
    "Installing the converted image FAILED: %@\nsmbd is left STOPPED so Time Machine does not open a half-installed image. The original is in %@ in the machine.":
      "Muunnetun levykuvan asennus EPÄONNISTUI: %@\nsmbd jätetään PYSÄYTETTYNÄ, jotta Time Machine ei avaa puoliksi asennettua levykuvaa. Alkuperäinen on kohteessa %@ virtuaalikoneessa.",
    "limactl create failed: %@":
      "limactl create epäonnistui: %@",
    "limactl list failed: %@":
      "limactl list epäonnistui: %@",
    "limactl not found - install Lima: brew install lima":
      "limactlia ei löytynyt - asenna Lima: brew install lima",
    "limactl start failed: %@\nThe machine's own log: %@":
      "limactl start epäonnistui: %@\nVirtuaalikoneen oma loki: %@",
    "Machine %@ is running.":
      "Virtuaalikone %@ on käynnissä.",
    "Machine %@ was already running.":
      "Virtuaalikone %@ oli jo käynnissä.",
    "Machine:          %@ (%@)":
      "Virtuaalikone:    %@ (%@)",
    "Machine:          %@":
      "Virtuaalikone:    %@",
    "Machine:          not created - run: cloudmachine-agent vm-setup":
      "Virtuaalikone:    ei luotu - suorita: cloudmachine-agent vm-setup",
    "no answer within the time limit":
      "ei vastausta aikarajan sisällä",
    "No image %@ in the machine.":
      "Virtuaalikoneessa ei ole levykuvaa %@.",
    "No image in the machine yet - point Time Machine at the share and let it create one first.":
      "Virtuaalikoneessa ei ole vielä levykuvaa - osoita ensin Time Machine jakoon ja anna sen luoda sellainen.",
    "No rclone configuration at %@ - connect Google Drive first (configure-remote).":
      "Ei rclone-kokoonpanoa polussa %@ - yhdistä ensin Google Drive (configure-remote).",
    "no SMB destination":
      "ei SMB-kohdetta",
    "One check of the machine's upload buffer: pauses Time Machine when it fills, resumes what it paused.":
      "Yksi virtuaalikoneen lähetyspuskurin tarkistus: keskeyttää Time Machinen sen täyttyessä ja jatkaa sen keskeyttämää.",
    "Packing the converted image failed: %@":
      "Muunnetun levykuvan pakkaus epäonnistui: %@",
    "Packing the image failed: %@":
      "Levykuvan pakkaus epäonnistui: %@",
    "No answer from the machine (rclone rc) - the guard would do nothing.":
      "Virtuaalikone ei vastaa (rclone rc) - vartija ei tekisi mitään.",
    "Only print what the guard would decide - for trying thresholds on a throwaway machine.":
      "Tulosta vain, mitä vartija päättäisi - rajojen kokeiluun kertakäyttöisellä virtuaalikoneella.",
    "Pause above this many GiB in the buffer.":
      "Keskeytä, kun puskurissa on yli näin monta GiB.",
    "Pause when the machine has less free than this, in GiB.":
      "Keskeytä, kun virtuaalikoneessa on vapaata alle näin monta GiB.",
    "Point Time Machine at the machine (once, needs an administrator password):":
      "Osoita Time Machine virtuaalikoneeseen (kerran, vaatii ylläpitäjän salasanan):",
    "punchfs files:    %@ open, limit %@":
      "punchfs-tiedostot: %@ auki, raja %@",
    "rclone configuration already in the machine - kept (--replace-rclone-config replaces it).":
      "rclone-kokoonpano on jo virtuaalikoneessa - säilytetty (--replace-rclone-config korvaa sen).",
    "rclone configuration copied into the machine.":
      "rclone-kokoonpano kopioitu virtuaalikoneeseen.",
    "rclone-tm or punchfs is not running in the machine - see cloudmachine-agent vm-status.":
      "rclone-tm tai punchfs ei ole käynnissä virtuaalikoneessa - katso cloudmachine-agent vm-status.",
    "Resume below this many GiB (only a backup the guard paused).":
      "Jatka, kun alle näin monta GiB (vain vartijan keskeyttämä varmuuskopiointi).",
    "Service %@: %@":
      "Palvelu %@: %@",
    "Several images in the machine (%@) - choose one with --bundle.":
      "Virtuaalikoneessa on useita levykuvia (%@) - valitse yksi valinnalla --bundle.",
    "Shows the machine: address, services, upload buffer, free space and the Time Machine destination.":
      "Näyttää virtuaalikoneen: osoite, palvelut, lähetyspuskuri, vapaa tila ja Time Machinen kohde.",
    "SMB password stored in %@ (mode 600).":
      "SMB-salasana tallennettu kohteeseen %@ (oikeudet 600).",
    "The converted image does not have %@-byte bands.":
      "Muunnetussa levykuvassa ei ole %@ tavun paloja.",
    "The converted image has no APFS partition.":
      "Muunnetussa levykuvassa ei ole APFS-osiota.",
    "The image already takes %@ MB - this command converts only a new, empty image (under %@ MB).":
      "Levykuva vie jo %@ MB - tämä komento muuntaa vain uuden, tyhjän levykuvan (alle %@ MB).",
    "The image is encrypted - converting encrypted images is not supported.":
      "Levykuva on salattu - salattujen levykuvien muuntamista ei tueta.",
    "The image was not changed; smbd started again.":
      "Levykuvaa ei muutettu; smbd käynnistettiin uudelleen.",
    "The machine does not answer - is it running? cloudmachine-agent vm-status":
      "Virtuaalikone ei vastaa - onko se käynnissä? cloudmachine-agent vm-status",
    "The machine has no address on the vzNAT network.":
      "Virtuaalikoneella ei ole osoitetta vzNAT-verkossa.",
    "The services in the machine did not start - check: cloudmachine-agent vm-status":
      "Virtuaalikoneen palvelut eivät käynnistyneet - tarkista: cloudmachine-agent vm-status",
    "Time Machine is backing up - stop it first: tmutil stopbackup":
      "Time Machine varmuuskopioi - pysäytä se ensin: tmutil stopbackup",
    "Time Machine:     %@":
      "Time Machine:     %@",
    "Time Machine:     NOT pointing at the machine (%@)":
      "Time Machine:     EI osoita virtuaalikoneeseen (%@)",
    "Time Machine:     tmutil did not answer":
      "Time Machine:     tmutil ei vastannut",
    "tmutil did not answer - not touching the image while its state is unknown.":
      "tmutil ei vastannut - levykuvaan ei kosketa, kun sen tila on tuntematon.",
    "unknown":
      "tuntematon",
    "Unpacking the image failed: %@":
      "Levykuvan purku epäonnistui: %@",
    "Still to upload:  %@ GiB in %@ bands, uploading %@ (cache on disk %@ GiB)":
      "Lähetettävää:     %@ GiB, paloja %@, lähetetään %@ (välimuisti levyllä %@ GiB)",
    "Excluded %@ (the machine and its upload buffer) from Time Machine.":
      "Suljettiin %@ (virtuaalikone ja sen lähetyspuskuri) pois Time Machinesta.",
    "WARNING: could not exclude %@ from Time Machine - run: tmutil addexclusion %@":
      "VAROITUS: kohdetta %@ ei voitu sulkea pois Time Machinesta - suorita: tmutil addexclusion %@",
    "Upload buffer:    no answer from rclone (rc %@)":
      "Lähetyspuskuri:   ei vastausta rclonelta (rc %@)",
    "When Time Machine has created its empty image, stop the backup (tmutil stopbackup) and run: cloudmachine-agent vm-prepare-bundle":
      "Kun Time Machine on luonut tyhjän levykuvansa, pysäytä varmuuskopiointi (tmutil stopbackup) ja suorita: cloudmachine-agent vm-prepare-bundle",
    "Unsent %@ GiB, free %@ GiB (pause above %@ GiB unsent or below %@ GiB free, resume below %@ GiB).":
      "Lähettämättä %@ GiB, vapaana %@ GiB (keskeytys, kun lähettämättä yli %@ GiB tai vapaana alle %@ GiB, jatko, kun alle %@ GiB).",
    "Upload:           Google's daily limit refused an upload %@ ago - rclone retries every 5 min and resumes by itself":
      "Lähetys:          Googlen vuorokausiraja hylkäsi lähetyksen %@ sitten - rclone yrittää uudelleen 5 min välein ja jatkaa itse",
    "no":
      "ei",
    "running":
      "käynnissä",
    "stopped":
      "pysäytetty",
    "yes":
      "kyllä",
    "%@\nThe previous template is in %@ - copy it back over lima.yaml and run limactl start %@.":
      "%@\nEdellinen mallipohja on kohteessa %@ - kopioi se takaisin tiedoston lima.yaml päälle ja suorita limactl start %@.",
    "Could not read this app's machine template (limactl template copy).":
      "Tämän apin virtuaalikoneen mallipohjaa ei voitu lukea (limactl template copy).",
    "Could not replace %@: %@":
      "Kohdetta %@ ei voitu korvata: %@",
    "Machine %@ already runs this app's template.":
      "Virtuaalikone %@ käyttää jo tämän apin mallipohjaa.",
    "Machine %@ now runs this app's template; the previous one is in %@.":
      "Virtuaalikone %@ käyttää nyt tämän apin mallipohjaa; edellinen on kohteessa %@.",
    "Moves the machine onto this app's template (two restarts, never during a backup).":
      "Siirtää virtuaalikoneen tämän apin mallipohjaan (kaksi uudelleenkäynnistystä, ei koskaan varmuuskopioinnin aikana).",
    "No machine %@ - create it with: cloudmachine-agent vm-setup":
      "Virtuaalikonetta %@ ei ole - luo se: cloudmachine-agent vm-setup",
    "Template:         OLDER than this app's - run: cloudmachine-agent vm-update":
      "Mallipohja:       VANHEMPI kuin tämän apin - suorita: cloudmachine-agent vm-update",
    "Template:         not compared":
      "Mallipohja:       ei verrattu",
    "Template:         this app's":
      "Mallipohja:       tämän apin",
    "The machine has no %@ - run cloudmachine-agent vm-setup first.":
      "Virtuaalikoneessa ei ole kohdetta %@ - suorita ensin cloudmachine-agent vm-setup.",
    "The machine restarted, but not every service is running - check: cloudmachine-agent vm-status. The previous template is in %@.":
      "Virtuaalikone käynnistyi uudelleen, mutta kaikki palvelut eivät ole käynnissä - tarkista: cloudmachine-agent vm-status. Edellinen mallipohja on kohteessa %@.",
    "The template changes the machine itself (%@) - that needs a new machine, not an update.":
      "Mallipohja muuttaa itse virtuaalikonetta (%@) - se vaatii uuden virtuaalikoneen, ei päivitystä.",
    "The upload to Google Drive hangs":
      "Lähetys Google Driveen jumittuu",
    "Time Machine is backing up - try again when it has finished.":
      "Time Machine varmuuskopioi - yritä uudelleen, kun se on valmis.",
    "Upload:           HANGS - bands in progress, none uploaded for %@ (network?); see /var/log/rclone-tm.log in the machine":
      "Lähetys:          JUMISSA - paloja käsittelyssä, mitään ei lähetetty %@ aikana (verkko?); katso /var/log/rclone-tm.log virtuaalikoneessa",
    "limactl stop failed - nothing was changed.":
      "limactl stop epäonnistui - mitään ei muutettu.",
    "rclone has bands in progress, but none has been uploaded for %@ - usually a broken network connection, which rclone does not report as an error. Backups since then are only in the machine's buffer. When the network comes back the upload resumes by itself (on 28.10.2026 within 80 s); if it does not, restarting the machine (prepare-shutdown, limactl start) drops the dead connections.":
      "rclonella on paloja käsittelyssä, mutta mitään ei ole lähetetty %@ aikana - yleensä katkennut verkkoyhteys, jota rclone ei ilmoita virheenä. Sen jälkeiset varmuuskopiot ovat vain virtuaalikoneen puskurissa. Kun verkko palaa, lähetys jatkuu itsestään (28.10.2026 80 s:ssa); jos ei, virtuaalikoneen uudelleenkäynnistys (prepare-shutdown, limactl start) katkaisee kuolleet yhteydet.",
    "tmutil did not answer - not restarting the machine while its state is unknown.":
      "tmutil ei vastannut - virtuaalikonetta ei käynnistetä uudelleen, kun sen tila on tuntematon.",
  ]
}
