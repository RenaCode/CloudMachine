// Dutch translations, keyed by the English text passed to `L10n.tr`.
extension L10nTranslations {
  static let nl: [String: String] = [
    "Space limit:      %@":
      "Ruimtelimiet:    %@",
    "                  Time Machine quota not set to match - run: %@":
      "                  Time Machine-quotum niet hierop afgestemd - voer uit: %@",
    "Sets how much of Google Drive this Mac may use, and prints the Time Machine quota command.":
      "Stelt in hoeveel van Google Drive deze Mac mag gebruiken en toont het commando voor het Time Machine-quotum.",
    "Limit in GB.":
      "Limiet in GB.",
    "Limit for this Mac: %@ GB.":
      "Limiet voor deze Mac: %@ GB.",
    "Now set the Time Machine quota (needs an administrator password):":
      "Stel nu het Time Machine-quotum in (beheerderswachtwoord vereist):",
    "CloudMachine - verification, Google Drive setup and installation. Called by launchd on a schedule, or by hand from Terminal.":
      "CloudMachine - controle, Google Drive-configuratie en installatie. Wordt volgens schema door launchd aangeroepen, of handmatig in Terminal.",
    "Connects to Google Drive through rclone (OAuth in the browser) and creates this machine's folder.":
      "Maakt via rclone verbinding met Google Drive (OAuth in de browser) en maakt de map van deze machine aan.",
    "Overwrite the existing remote. RISKY: replaces the token and permissions.":
      "Overschrijf de bestaande remote. RISKANT: vervangt het token en de rechten.",
    "Packs build/CloudMachine.app into build/CloudMachine-<version>.dmg.":
      "Verpakt build/CloudMachine.app in build/CloudMachine-<version>.dmg.",
    "ERROR: %@ is missing - run 'cloudmachine-agent build-app' first":
      "FOUT: %@ ontbreekt - voer eerst 'cloudmachine-agent build-app' uit",
    "==> Preparing the staging folder":
      "==> Opbouwmap voorbereiden",
    "==> Creating %@":
      "==> %@ aanmaken",
    "ERROR: hdiutil exited with code %@.":
      "FOUT: hdiutil is beëindigd met code %@.",
    "==> Done: %@":
      "==> Klaar: %@",
    "On first launch (the app is not signed with an Apple Developer account):":
      "Bij de eerste start (de app is niet ondertekend met een Apple Developer-account):",
    "1. Open %@ and drag CloudMachine.app to Applications.":
      "1. Open %@ en sleep CloudMachine.app naar Programma's.",
    "2. In Finder, RIGHT-click CloudMachine.app -> Open -> Open\n   (a plain double-click shows the Gatekeeper block \"unidentified developer\").":
      "2. Klik in de Finder met de RECHTERmuisknop op CloudMachine.app -> Open -> Open\n   (bij een gewone dubbelklik verschijnt de Gatekeeper-blokkade \"niet-geïdentificeerde ontwikkelaar\").",
    "3. Later launches work normally, with a double-click.":
      "3. Latere starts werken gewoon, met een dubbelklik.",
    "Builds CloudMachine.app (Release) - GUI + cloudmachine-agent in Contents/MacOS/, plus launchd/, vm/ and config/ as Resources.":
      "Bouwt CloudMachine.app (Release) - GUI + cloudmachine-agent in Contents/MacOS/, plus launchd/, vm/ en config/ als bronnen.",
    "Binaries for Apple Silicon and Intel at once (how CI builds a release; unnecessary locally).":
      "Binaire bestanden voor Apple Silicon en Intel tegelijk (zo bouwt CI een release; lokaal overbodig).",
    "==> Building CloudMachineApp + cloudmachine-agent (release) - version %@ (%@)":
      "==> CloudMachineApp + cloudmachine-agent bouwen (release) - versie %@ (%@)",
    "ERROR: swift build exited with code %@.":
      "FOUT: swift build is beëindigd met code %@.",
    "ERROR: swift build --show-bin-path did not report the binaries directory.":
      "FOUT: swift build --show-bin-path gaf de map met de binaire bestanden niet door.",
    "ERROR: no built binary found at %@":
      "FOUT: geen gebouwd binair bestand gevonden op %@",
    "==> Assembling the .app bundle in %@":
      "==> De .app-bundel samenstellen in %@",
    "==> WARNING: you are building from a DIRTY tree - the version will not point to a commit.":
      "==> WAARSCHUWING: je bouwt vanuit een VUILE boom - de versie verwijst niet naar een commit.",
    "ERROR: Resources/AppIcon.icns is missing - generate it: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns":
      "FOUT: Resources/AppIcon.icns ontbreekt - genereer het met: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns",
    "==> Signing with the local certificate '%@' (Full Disk Access will survive later rebuilds)":
      "==> Ondertekenen met het lokale certificaat '%@' (Volledige schijftoegang blijft behouden bij latere builds)",
    "==> Signing ad-hoc (no Apple Developer account) - run 'cloudmachine-agent setup-signing-cert' once so that TCC permissions survive later rebuilds":
      "==> Ad-hoc ondertekenen (geen Apple Developer-account) - voer eenmalig 'cloudmachine-agent setup-signing-cert' uit, zodat TCC-rechten latere builds overleven",
    "ERROR: codesign exited with code %@.":
      "FOUT: codesign is beëindigd met code %@.",
    "Next step: %@":
      "Volgende stap: %@",
    "Creates a local self-signed certificate so that Full Disk Access survives later rebuilds of the app.":
      "Maakt een lokaal zelfondertekend certificaat aan, zodat Volledige schijftoegang latere builds van de app overleeft.",
    "Certificate '%@' already exists in %@, nothing to do.":
      "Certificaat '%@' bestaat al in %@, niets te doen.",
    "==> Generating the key and self-signed certificate '%@'...":
      "==> Sleutel en zelfondertekend certificaat '%@' genereren...",
    "ERROR: openssl req exited with code %@.":
      "FOUT: openssl req is beëindigd met code %@.",
    "ERROR: openssl pkcs12 exited with code %@.":
      "FOUT: openssl pkcs12 is beëindigd met code %@.",
    "==> Importing the certificate into %@ (pre-authorizing /usr/bin/codesign, so it does not ask for the keychain password every time)...":
      "==> Certificaat importeren in %@ (/usr/bin/codesign vooraf autoriseren, zodat niet elke keer om het wachtwoord van de sleutelhanger wordt gevraagd)...",
    "ERROR: security import exited with code %@.":
      "FOUT: security import is beëindigd met code %@.",
    "==> Trusting the certificate ONLY for code signing...":
      "==> Certificaat ALLEEN vertrouwen voor het ondertekenen van code...",
    "ERROR: security add-trusted-cert exited with code %@.":
      "FOUT: security add-trusted-cert is beëindigd met code %@.",
    "Done. Certificate '%@' is now available to codesign.":
      "Klaar. Certificaat '%@' is nu beschikbaar voor codesign.",
    "The next 'cloudmachine-agent build-app' will use it automatically instead of an ad-hoc signature.":
      "De volgende 'cloudmachine-agent build-app' gebruikt het automatisch in plaats van een ad-hoc-handtekening.",
    "After THAT ONE rebuild, grant Full Disk Access one last time - later\nrebuilds will no longer reset it, as long as you sign with the same certificate.":
      "Geef na DIE ENE herbouw Volledige schijftoegang nog een laatste keer - latere\nherbouwen zetten het niet meer terug, zolang je met hetzelfde certificaat ondertekent.",
    "Checks whether the hourly cycle STILL works (date of the last SUCCESSFUL backup) and reports failures.":
      "Controleert of de uurlijkse cyclus NOG werkt (datum van de laatste GESLAAGDE back-up) en meldt fouten.",
    "After this many hours without a successful backup we consider the cycle broken.":
      "Na zoveel uur zonder geslaagde back-up beschouwen we de cyclus als stuk.",
    "Only print the state, without a system notification.":
      "Toon alleen de status, zonder systeemmelding.",
    "A different Time Machine preferences file - to test the watchdog on a known sample.":
      "Een ander voorkeurenbestand van Time Machine - om de waakhond op een bekend voorbeeld te testen.",
    "Last successful backup: %@":
      "Laatste geslaagde back-up: %@",
    "Last successful backup: NONE":
      "Laatste geslaagde back-up: GEEN",
    "Last attempt:           %@":
      "Laatste poging:          %@",
    "WAITING (system startup): %@":
      "WACHT (systeemstart): %@",
    "Backup cycle: OK":
      "Back-upcyclus: OK",
    "FAILURE: %@":
      "STORING: %@",
    "         %@":
      "        %@",
    "Check the state:  %@":
      "Status controleren: %@",
    "Preparing for restart":
      "Voorbereiden op herstart",
    "Prepare for restart":
      "Voorbereiden op herstart",
    "Prepare":
      "Voorbereiden",
    "==> WARNING: git rev-list failed (%@) - using the date as the build number.":
      "==> WAARSCHUWING: git rev-list is mislukt (%@) - de datum wordt als buildnummer gebruikt.",
    "Agents:           %@":
      "Agents:           %@",
    "CANNOT START: %@ - open CloudMachine or run backup-health to reload them":
      "KAN NIET STARTEN: %@ - open CloudMachine of voer backup-health uit om ze opnieuw te laden",
    "Reloaded agents that could not start: %@":
      "Agents opnieuw geladen die niet konden starten: %@",
    "Drive folder:     %@":
      "Drive-map:        %@",
    "Name of this Mac's folder on Google Drive (default: derived from the computer name). Set once; it cannot be changed later.":
      "Naam van de map van deze Mac op Google Drive (standaard afgeleid van de computernaam). Eenmalig in te stellen; later niet meer te wijzigen.",
    "Backup watchdog:  %@":
      "Back-upwaakhond:  %@",
    "Prints the version, the build number and the commit this binary was built from.":
      "Toont de versie, het buildnummer en de commit waaruit dit binaire bestand is gebouwd.",
    "Only one line, without a description.":
      "Slechts één regel, zonder beschrijving.",
    "Build from the working tree (outside a bundle) - no version data.":
      "Build vanuit de werkmap (buiten een bundel) - geen versiegegevens.",
    "Version: %@":
      "Versie: %@",
    "Build:   %@":
      "Build:  %@",
    "Commit:  %@":
      "Commit: %@",
    "WARNING: built from a DIRTY tree - the binary contains code that\n         is in no commit. The commit number does NOT describe\n         what actually runs.":
      "WAARSCHUWING: gebouwd vanuit een VUILE boom - het binaire bestand bevat code die\n         in geen enkele commit zit. Het commitnummer beschrijft NIET\n         wat er werkelijk draait.",
    "Saving the space limit":
      "Ruimtelimiet opslaan",
    "Measuring usage on Google Drive":
      "Gebruik op Google Drive meten",
    "Google Drive did not answer - try again later.":
      "Google Drive heeft niet geantwoord - probeer het later opnieuw.",
    "Measured.":
      "Gemeten.",
    "Space limit for this Mac":
      "Ruimtelimiet voor deze Mac",
    "Used on Google Drive":
      "Gebruikt op Google Drive",
    "Measured %@. The watchdog measures again every few hours.":
      "Gemeten %@. De waakhond meet om de paar uur opnieuw.",
    "Limit (GB)":
      "Limiet (GB)",
    "Save":
      "Bewaar",
    "Measure now":
      "Nu meten",
    "Time Machine quota: %@ GB (70%% of the limit - the copy on Drive is about a third larger than the backup inside it). Time Machine deletes the oldest backups to stay within it.":
      "Time Machine-quotum: %@ GB (70%% van de limiet - de kopie op Drive is ongeveer een derde groter dan de back-up erin). Time Machine verwijdert de oudste back-ups om daaronder te blijven.",
    "Set the Time Machine quota: run this in Terminal (needs sudo)":
      "Stel het Time Machine-quotum in: voer dit uit in Terminal (sudo vereist)",
    "Connect Google Drive: run this in Terminal and approve in the browser":
      "Verbind Google Drive: voer dit uit in Terminal en keur het goed in de browser",
    "Grant Full Disk Access to CloudMachine, so it can tell whether backups complete":
      "Geef CloudMachine Volledige schijftoegang, zodat het kan zien of back-ups voltooid zijn",
    "Folder on Google Drive":
      "Map op Google Drive",
    "One folder per Mac. Set once - it cannot be changed after connecting.":
      "Eén map per Mac. Eenmalig in te stellen - na het verbinden niet meer te wijzigen.",
    "Use lowercase letters, digits and dashes.":
      "Gebruik kleine letters, cijfers en streepjes.",
    "Install rclone":
      "rclone installeren",
    "Open System Settings":
      "Systeeminstellingen openen",
    "Install agents":
      "Agents installeren",
    "not checked":
      "niet gecontroleerd",
    "none at all":
      "helemaal geen",
    "%@ ago":
      "%@ geleden",
    "Missing: %@":
      "Ontbreekt: %@",
    "Google Drive not connected":
      "Google Drive niet verbonden",
    "Time Machine does not point to CloudMachine":
      "Time Machine verwijst niet naar CloudMachine",
    "UNKNOWN whether Time Machine points to CloudMachine - tmutil did not answer":
      "ONBEKEND of Time Machine naar CloudMachine verwijst - tmutil heeft niet geantwoord",
    "Backup in progress":
      "Back-up bezig",
    "Unknown when the last backup was made":
      "Onbekend wanneer de laatste back-up is gemaakt",
    "There is no completed backup at all":
      "Er is helemaal geen voltooide back-up",
    "No completed backup for %@":
      "Geen voltooide back-up sinds %@",
    "Ready":
      "Gereed",
    "Not saved: %@":
      "Niet bewaard: %@",
    "Installing rclone":
      "rclone installeren",
    "Installing launchd agents":
      "launchd-agents installeren",
    "Starting backup":
      "Back-up starten",
    "Backup started.":
      "Back-up gestart.",
    "Could not start the backup.":
      "Kon de back-up niet starten.",
    "Stopping backup":
      "Back-up stoppen",
    "Backup stopped.":
      "Back-up gestopt.",
    "Could not stop the backup.":
      "Kon de back-up niet stoppen.",
    "Could not prepare the AppleScript.":
      "Kon het AppleScript niet voorbereiden.",
    "Unknown authorization error.":
      "Onbekende autorisatiefout.",
    "Waiting to upload":
      "Wacht op upload",
    "%@ files":
      "%@ bestanden",
    "nothing":
      "niets",
    "Back up now":
      "Nu back-uppen",
    "Stop backup":
      "Back-up stoppen",
    "Open CloudMachine":
      "CloudMachine openen",
    "Quit":
      "Stop",
    "Healthy":
      "In orde",
    "Attention":
      "Let op",
    "Refreshed %@":
      "Vernieuwd %@",
    "System Status":
      "Systeemstatus",
    "Action needed":
      "Actie nodig",
    "not measured":
      "niet gemeten",
    "rclone did not answer":
      "rclone heeft niet geantwoord",
    "Backup in Progress":
      "Back-up bezig",
    "Files processed":
      "Verwerkte bestanden",
    "Write speed":
      "Schrijfsnelheid",
    "Operation phase":
      "Fase van de bewerking",
    "Required Setup Steps":
      "Vereiste configuratiestappen",
    "Copy":
      "Kopieer",
    "Last completed backup":
      "Laatste voltooide back-up",
    "Last backup watchdog run":
      "Laatste run van de back-upwaakhond",
    "not read":
      "niet gelezen",
    "Everything uploaded":
      "Alles geüpload",
    "File upload errors":
      "Fouten bij het uploaden van bestanden",
    "Google Drive Credentials (OAuth 2.0)":
      "Google Drive-inloggegevens (OAuth 2.0)",
    "Keychain OK":
      "Sleutelhanger OK",
    "No custom keys":
      "Geen eigen sleutels",
    "Paste client_id...":
      "Plak client_id...",
    "Paste client_secret...":
      "Plak client_secret...",
    "Save securely in the Keychain":
      "Veilig bewaren in de sleutelhanger",
    "Refresh":
      "Vernieuw",
    "Overview":
      "Overzicht",
    "Backups":
      "Back-ups",
    "Storage":
      "Opslag",
    "Settings":
      "Instellingen",
    "Current status: %@":
      "Huidige status: %@",
    "Does not point to CloudMachine":
      "Verwijst niet naar CloudMachine",
    "tmutil did not answer":
      "tmutil heeft niet geantwoord",
    "Backing up: %@ of %@":
      "Back-up: %@ van %@",
    "%@ of %@":
      "%@ van %@",
    "Copied":
      "Gekopieerd",
    "No backup is running":
      "Er loopt geen back-up",
    "Time Machine starts the next one on its own schedule.":
      "Time Machine start de volgende volgens zijn eigen schema.",
    "Backup cycle":
      "Back-upcyclus",
    "%@ GiB":
      "%@ GiB",
    "%@ GiB in %@ bands, %@ uploading":
      "%@ GiB in %@ bands, %@ worden geüpload",
    "%@ bands":
      "%@ bands",
    "%@ fragments abandoned - only in the machine":
      "%@ fragmenten opgegeven - alleen in de machine aanwezig",
    "127.0.0.1:5572 answers on the Mac: Lima forwards the machine's rclone remote control, which has no password. Any web page open in a browser can send it commands - including deleting the backup on Google Drive. Add the portForwards rule from vm/cmsmb.yaml to the machine and restart it (see vm/README.md).":
      "127.0.0.1:5572 antwoordt op de Mac: Lima stuurt de rclone-afstandsbediening van de machine door, die geen wachtwoord heeft. Elke webpagina die in een browser openstaat kan er commando's naartoe sturen - ook om de back-up op Google Drive te verwijderen. Voeg de portForwards-regel uit vm/cmsmb.yaml toe aan de machine en start hem opnieuw op (zie vm/README.md).",
    "A service in the CloudMachine machine is not running":
      "Een service in de CloudMachine-machine draait niet",
    "Address":
      "Adres",
    "Agent installation INCOMPLETE - %@ of %@ did not go in:\n%@\n%@\nEvery missing agent is a function that has silently stopped working (vm-guard watches the machine's buffer, backup-health reports failures). Fix the cause and repeat the installation.":
      "Installatie van agents ONVOLLEDIG - %@ van %@ zijn er niet in gekomen:\n%@\n%@\nElke ontbrekende agent is een functie die ongemerkt is gestopt (vm-guard bewaakt de buffer van de machine, backup-health meldt fouten). Los de oorzaak op en herhaal de installatie.",
    "All running":
      "Alles draait",
    "Also install the launchd agents (same as install-launchd).":
      "Installeer ook de launchd-agents (hetzelfde als install-launchd).",
    "At most this many minutes of waiting for the upload.":
      "Wacht hoogstens zoveel minuten op de upload.",
    "At the limit every new band fails with EMFILE and the backup stops. Check: cloudmachine-agent vm-status":
      "Bij de limiet mislukt elke nieuwe band met EMFILE en stopt de back-up. Controleer: cloudmachine-agent vm-status",
    "Cache on the machine's disk":
      "Cache op de schijf van de machine",
    "Connected to Google Drive, but could not create the folder '%@' - without it the machine has nowhere to keep the backup. Check the account permissions and try again.":
      "Verbonden met Google Drive, maar de map '%@' kon niet worden aangemaakt - zonder die map kan de machine de back-up nergens bewaren. Controleer de rechten van het account en probeer het opnieuw.",
    "Convert the image":
      "Image converteren",
    "Converting the image to 32 MB bands":
      "Image converteren naar bands van 32 MB",
    "Could not check with the current connection whether the backup is on Google Drive (%@), so remote '%@' was NOT replaced: without that answer the new sign-in cannot be checked against it.":
      "Met de huidige verbinding kon niet worden gecontroleerd of de back-up op Google Drive staat (%@), dus remote '%@' is NIET vervangen: zonder dat antwoord kan de nieuwe aanmelding er niet mee worden vergeleken.",
    "Downloads the official rclone binary into ~/.cloudmachine/bin (Google sign-in and the machine's rclone.conf).":
      "Downloadt het officiële rclone-binaire bestand naar ~/.cloudmachine/bin (Google-aanmelding en de rclone.conf van de machine).",
    "Free in the machine":
      "Vrij in de machine",
    "Free in the machine: %@":
      "Vrij in de machine: %@",
    "Generates and installs the launchd agents (app, backup watchdog, machine start, machine guard).":
      "Genereert en installeert de launchd-agents (app, back-upwaakhond, machinestart, machinebewaker).",
    "Install Lima, which runs the CloudMachine machine: run this in Terminal":
      "Installeer Lima, waarmee de CloudMachine-machine draait: voer dit uit in Terminal",
    "Install rclone (signs in to Google Drive for the machine)":
      "Installeer rclone (meldt de machine aan bij Google Drive)",
    "Install the background agents (machine start, buffer guard, backup watchdog)":
      "Installeer de achtergrondagents (machinestart, bufferbewaker, back-upwaakhond)",
    "Installs rclone through Homebrew - CloudMachine itself uses the one from install-rclone.":
      "Installeert rclone via Homebrew - CloudMachine zelf gebruikt de versie uit install-rclone.",
    "Info.plist, token and mapped/ of the backup image exist only on the machine's disk; without them the bands in %@ cannot be restored. The copy (tm-meta-sync, every 15 min) goes to %@. Check: cloudmachine-agent vm-status, then in the machine: journalctl -u tm-meta-sync":
      "Info.plist, token en mapped/ van de back-upimage bestaan alleen op de schijf van de machine; zonder die bestanden zijn de bands in %@ niet te herstellen. De kopie (tm-meta-sync, elke 15 min) gaat naar %@. Controleer: cloudmachine-agent vm-status, en daarna in de machine: journalctl -u tm-meta-sync",
    "Lima says the machine is running, but a command in it did not return. Without it nothing is known about Samba, rclone or the upload. Check: cloudmachine-agent vm-status":
      "Lima meldt dat de machine draait, maar een commando erin is niet teruggekeerd. Zonder dat commando is er niets bekend over Samba, rclone of de upload. Controleer: cloudmachine-agent vm-status",
    "Machine":
      "Machine",
    "Machine %@":
      "Machine %@",
    "Machine & Upload Status":
      "Status van machine en upload",
    "Machine buffer":
      "Buffer van de machine",
    "No Time Machine destination is the machine's share (smb://tm@<address>/CloudMachine) - backups are not being made there. The command is printed by: cloudmachine-agent vm-setup":
      "Geen enkele Time Machine-bestemming is de share van de machine (smb://tm@<address>/CloudMachine) - daar worden geen back-ups gemaakt. Het commando wordt getoond door: cloudmachine-agent vm-setup",
    "Not running: %@":
      "Draait niet: %@",
    "Not set up":
      "Niet ingesteld",
    "Once it runs out, rclone stops uploading, the machine's buffer fills up and backups stop being made. At a growth of ~600 MB per hourly cycle that is about %@ days.":
      "Zodra die op is, stopt rclone met uploaden, loopt de buffer van de machine vol en worden er geen back-ups meer gemaakt. Bij een groei van ~600 MB per uurlijkse cyclus is dat ongeveer %@ dagen.",
    "Or rclone.conf is missing: this Mac has already set up the CloudMachine machine, so it is not connected anew blindly. Restore the file from a backup (the machine keeps its own copy in %@). To connect anyway, create an empty file at the path `%@ config file` prints and run again - the existing folder is kept.":
      "Of rclone.conf ontbreekt: deze Mac heeft de CloudMachine-machine al ingesteld, dus er wordt niet blind opnieuw verbonden. Herstel het bestand uit een back-up (de machine bewaart een eigen kopie in %@). Om toch te verbinden, maak je een leeg bestand aan op het pad dat `%@ config file` toont en voer je het opnieuw uit - de bestaande map blijft behouden.",
    "Point Time Machine at the machine: run this in Terminal (needs sudo; Copy includes the password)":
      "Richt Time Machine op de machine: voer dit uit in Terminal (sudo vereist; Kopieer bevat het wachtwoord)",
    "Points to the machine":
      "Verwijst naar de machine",
    "Prepares for a restart: stops the backup, waits a while for the upload, then stops the machine cleanly.":
      "Bereidt een herstart voor: stopt de back-up, wacht even op de upload en zet de machine daarna netjes uit.",
    "Reading the Time Machine destination did not return within %@ s. That is how tmutil behaves when its destination hangs.":
      "Het lezen van de Time Machine-bestemming kwam niet binnen %@ s terug. Zo gedraagt tmutil zich als de bestemming blijft hangen.",
    "Remote '%@' was NOT replaced. The new sign-in gets the 'drive.file' scope, which sees only files created under its own client_id. The existing backup was most likely created by the current connection and would become invisible to it. Before anything is written, the new token is checked against the existing backup, and the replacement is abandoned if it cannot see it. The machine keeps its own copy of the configuration until vm-setup --replace-rclone-config. To go ahead, run again with --replace-existing --accept-scope-change.":
      "Remote '%@' is NIET vervangen. De nieuwe aanmelding krijgt de scope 'drive.file', die alleen bestanden ziet die onder zijn eigen client_id zijn gemaakt. De bestaande back-up is hoogstwaarschijnlijk door de huidige verbinding gemaakt en zou er onzichtbaar voor worden. Voordat er iets wordt geschreven, wordt het nieuwe token met de bestaande back-up vergeleken, en de vervanging wordt afgebroken als het die niet kan zien. De machine houdt een eigen kopie van de configuratie tot vm-setup --replace-rclone-config. Om door te gaan, voer je het opnieuw uit met --replace-existing --accept-scope-change.",
    "Remote control:   OPEN on the Mac at 127.0.0.1:5572 - any web page can send rclone commands; see vm/README.md (portForwards)":
      "Afstandsbediening: OPEN op de Mac op 127.0.0.1:5572 - elke webpagina kan rclone-commando's sturen; zie vm/README.md (portForwards)",
    "Running":
      "Draait",
    "Samba, rclone or punchfs in the machine is not active, so Time Machine has nowhere to write or the bands do not reach Google Drive. Check: cloudmachine-agent vm-status":
      "Samba, rclone of punchfs in de machine is niet actief, dus Time Machine kan nergens naartoe schrijven of de bands bereiken Google Drive niet. Controleer: cloudmachine-agent vm-status",
    "Service %@":
      "Service %@",
    "Services":
      "Services",
    "Set up the CloudMachine machine (the first time it downloads Ubuntu - several minutes)":
      "Stel de CloudMachine-machine in (de eerste keer wordt Ubuntu gedownload - enkele minuten)",
    "Set up the CloudMachine machine again, so it prints the Time Machine command":
      "Stel de CloudMachine-machine opnieuw in, zodat het Time Machine-commando wordt getoond",
    "Set up the machine":
      "Machine instellen",
    "Setting up the CloudMachine machine":
      "CloudMachine-machine instellen",
    "Start the CloudMachine machine":
      "Start de CloudMachine-machine",
    "Start the machine":
      "Machine starten",
    "Starting the CloudMachine machine":
      "CloudMachine-machine starten",
    "Still to upload: %@ GiB":
      "Nog te uploaden: %@ GiB",
    "Stopping the Time Machine backup...":
      "Time Machine-back-up stoppen...",
    "Stopping the machine %@...":
      "Machine %@ stoppen...",
    "The CloudMachine machine does not answer":
      "De CloudMachine-machine antwoordt niet",
    "The CloudMachine machine is not running":
      "De CloudMachine-machine draait niet",
    "The CloudMachine machine is not set up yet":
      "De CloudMachine-machine is nog niet ingesteld",
    "The CloudMachine machine is stopped":
      "De CloudMachine-machine is gestopt",
    "The backup is stopped, the upload gets up to 30 minutes, then the machine shuts down cleanly. It starts again at the next login.":
      "De back-up wordt gestopt, de upload krijgt maximaal 30 minuten en daarna wordt de machine netjes uitgezet. Bij de volgende aanmelding start hij weer.",
    "The machine %@ is not running - nothing to prepare.":
      "De machine %@ draait niet - er valt niets voor te bereiden.",
    "The machine is stopped and everything reached Google Drive. The Mac can be restarted; the machine starts again at login.":
      "De machine is gestopt en alles heeft Google Drive bereikt. De Mac kan opnieuw worden opgestart; de machine start weer bij het aanmelden.",
    "The machine is stopped. %@ GiB had not reached Google Drive yet - it is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "De machine is gestopt. %@ GiB had Google Drive nog niet bereikt - dit blijft in de buffer van de machine staan en wordt na de volgende start geüpload. De Mac kan opnieuw worden opgestart.",
    "The machine is stopped. rclone did not say how much was still to upload; what was not uploaded is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "De machine is gestopt. rclone meldde niet hoeveel er nog te uploaden was; wat niet is geüpload blijft in de buffer van de machine staan en wordt na de volgende start geüpload. De Mac kan opnieuw worden opgestart.",
    "The machine's disk is a file on this disk and grows as the upload buffer fills. With no space left the machine cannot write the buffer, and Time Machine's local snapshots have nowhere to go either.":
      "De schijf van de machine is een bestand op deze schijf en groeit naarmate de uploadbuffer vol raakt. Zonder vrije ruimte kan de machine de buffer niet schrijven, en ook de lokale snapshots van Time Machine kunnen nergens heen.",
    "The image's metadata has never been copied to Drive":
      "De metadata van de image zijn nog nooit naar Drive gekopieerd",
    "The image's metadata was last copied to Drive %@ ago":
      "De metadata van de image zijn voor het laatst %@ geleden naar Drive gekopieerd",
    "The machine's disk is running out of space (%@ GB)":
      "De schijf van de machine raakt vol (%@ GB)",
    "The new sign-in does NOT see the existing backup (%@), so remote '%@' was NOT replaced and rclone.conf is unchanged. Keep the current connection, or sign in with the credential (client_id) that created the backup.":
      "De nieuwe aanmelding ziet de bestaande back-up NIET (%@), dus remote '%@' is NIET vervangen en rclone.conf is ongewijzigd. Houd de huidige verbinding aan, of meld je aan met de inloggegevens (client_id) waarmee de back-up is gemaakt.",
    "The upload buffer lives on this disk. The guard pauses Time Machine before it fills; if the upload does not catch up, backups stay paused.":
      "De uploadbuffer staat op deze schijf. De bewaker pauzeert Time Machine voordat hij vol raakt; als de upload niet inhaalt, blijven back-ups gepauzeerd.",
    "These bands exist only in the machine's buffer. The backup on Google Drive is INCOMPLETE and may not open.":
      "Deze bands bestaan alleen in de buffer van de machine. De back-up op Google Drive is ONVOLLEDIG en is mogelijk niet te openen.",
    "Time Machine backs up to the machine, so without it no backup is made. Start it: limactl start %@ (or the Start button in the app).":
      "Time Machine maakt back-ups naar de machine, dus zonder de machine wordt er geen back-up gemaakt. Start hem met: limactl start %@ (of met de knop Machine starten in de app).",
    "Time Machine did not stop its backup within 2 minutes (or tmutil did not answer) - the machine was NOT stopped. Try again in a moment.":
      "Time Machine heeft zijn back-up niet binnen 2 minuten gestopt (of tmutil heeft niet geantwoord) - de machine is NIET gestopt. Probeer het zo meteen opnieuw.",
    "Time Machine has created its image: stop the backup, then convert the image to 32 MB bands":
      "Time Machine heeft zijn image gemaakt: stop de back-up en converteer de image daarna naar bands van 32 MB",
    "To upload":
      "Te uploaden",
    "Unknown whether the CloudMachine machine is running":
      "Onbekend of de CloudMachine-machine draait",
    "Waiting for the upload to Google Drive (at most %@ min)...":
      "Wachten op de upload naar Google Drive (hoogstens %@ min)...",
    "With --replace-existing: confirms that the new sign-in (scope 'drive.file') may not see the existing backup. The new token is still checked against the backup first.":
      "Met --replace-existing: bevestigt dat de nieuwe aanmelding (scope 'drive.file') de bestaande back-up mogelijk niet ziet. Het nieuwe token wordt eerst nog steeds met de back-up vergeleken.",
    "Without it there is no way to check whether anything reached the Drive - the machine's guard is blind then.":
      "Zonder dit is er geen manier om te controleren of er iets Drive heeft bereikt - de bewaker van de machine is dan blind.",
    "limactl did not answer":
      "limactl heeft niet geantwoord",
    "limactl did not answer (or is not installed). That does not mean the machine is down - it means nobody has checked.":
      "limactl heeft niet geantwoord (of is niet geïnstalleerd). Dat betekent niet dat de machine uit is - het betekent dat niemand het heeft gecontroleerd.",
    "limactl start failed: %@":
      "limactl start mislukt: %@",
    "limactl stop failed: %@":
      "limactl stop mislukt: %@",
    "punchfs is close to its open-file limit":
      "punchfs zit dicht tegen zijn limiet voor open bestanden aan",
    "punchfs open files":
      "Open bestanden van punchfs",
    "rclone's remote control is open on this Mac":
      "De afstandsbediening van rclone staat open op deze Mac",
    "statfs('/System/Volumes/Data') returned an error, so nobody knows whether the machine's disk can still grow on this Mac.":
      "statfs('/System/Volumes/Data') gaf een fout, dus het is onbekend of de schijf van de machine op deze Mac nog kan groeien.",
    "Google Drive's daily upload limit stops the upload":
      "De dagelijkse uploadlimiet van Google Drive stopt de upload",
    "Google last refused an upload %@ ago (750 GB a day). Backups since then are only in the machine's buffer on this Mac. rclone retries every 5 min and resumes by itself when the limit passes; the guard pauses Time Machine if more than %@ GiB waits.":
      "Google heeft %@ geleden voor het laatst een upload geweigerd (750 GB per dag). Back-ups sindsdien staan alleen in de buffer van de machine op deze Mac. rclone probeert het elke 5 min opnieuw en gaat vanzelf verder als de limiet voorbij is; de bewaker pauzeert Time Machine als er meer dan %@ GiB wacht.",
    "Usage on Google Drive is not being measured":
      "Het gebruik op Google Drive wordt niet gemeten",
    "The last measurement (%@ GB) is from %@, %@ ago - rclone size has not answered since. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "De laatste meting (%@ GB) is van %@, %@ geleden - rclone size heeft sindsdien niet geantwoord. Tot het weer antwoordt, bewaakt niets de limiet van %@ GB: de alarmen bij 90%% en 100%% blijven stil. Controleer vm-status, of klik in het venster op Nu meten.",
    "rclone size has not answered even once. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "rclone size heeft nog geen enkele keer geantwoord. Tot het antwoordt, bewaakt niets de limiet van %@ GB: de alarmen bij 90%% en 100%% blijven stil. Controleer vm-status, of klik in het venster op Nu meten.",
    "Saved in the Keychain. Connecting Google Drive (configure-remote) will use them.":
      "Bewaard in de sleutelhanger. Het verbinden van Google Drive (configure-remote) gebruikt ze.",
    "Saved in the Keychain. The existing Google Drive connection keeps its old client_id, and on this Mac it should stay that way: a connection made with the new keys (the 'drive.file' scope) cannot see the backup created by the old one. Do not replace the connection here; the new keys are for a Mac that is not connected yet.":
      "Bewaard in de sleutelhanger. De bestaande Google Drive-verbinding houdt zijn oude client_id, en op deze Mac hoort dat zo te blijven: een verbinding met de nieuwe sleutels (scope 'drive.file') kan de back-up die met de oude is gemaakt niet zien. Vervang de verbinding hier niet; de nieuwe sleutels zijn voor een Mac die nog niet is verbonden.",
    "it is not there for the new token":
      "die is er niet voor het nieuwe token",
    "Cancel":
      "Annuleer",
    "ACTION NEEDED":
      "ACTIE NODIG",
    "WILL PASS BY ITSELF — DO NOTHING":
      "LOST ZICHZELF OP - NIETS DOEN",
    "UNKNOWN — CHECK AGAIN SHORTLY":
      "ONBEKEND - STRAKS OPNIEUW CONTROLEREN",
    "ALL GOOD":
      "ALLES IN ORDE",
    "Upload is not working":
      "Upload werkt niet",
    "Upload stopped — no space left on Google Drive":
      "Upload gestopt - geen ruimte meer op Google Drive",
    "%@ backup fragments not uploaded":
      "%@ back-upfragmenten niet geüpload",
    "Upload cannot keep up with writes":
      "Upload kan het schrijven niet bijhouden",
    "Upload paused — Google daily limit":
      "Upload gepauzeerd - dagelijkse limiet van Google",
    "Uploading to Google Drive — %@ queued":
      "Uploaden naar Google Drive - %@ in de wachtrij",
    "Everything uploaded to Google Drive":
      "Alles geüpload naar Google Drive",
    "Unknown what is waiting in the queue":
      "Onbekend wat er in de wachtrij wacht",
    "There is no connection to Google Drive, so backups are only made on this Mac. If this does not pass by itself within a few minutes, check the network and the connection to Drive.":
      "Er is geen verbinding met Google Drive, dus back-ups worden alleen op deze Mac gemaakt. Als dit niet binnen een paar minuten vanzelf overgaat, controleer dan het netwerk en de verbinding met Drive.",
    "There is no space left on Google Drive. This will NOT pass by itself — you need to free up space on Drive. Until then Time Machine is paused, so that it does not fill up this Mac's disk.":
      "Er is geen ruimte meer op Google Drive. Dit gaat NIET vanzelf over - je moet ruimte op Drive vrijmaken. Tot die tijd is Time Machine gepauzeerd, zodat de schijf van deze Mac niet volloopt.",
    "%@ backup fragments could not be uploaded and rclone stopped trying. These fragments exist only on this Mac, so the backup on Drive is incomplete. This needs checking.":
      "%@ back-upfragmenten konden niet worden geüpload en rclone is opgehouden met proberen. Deze fragmenten bestaan alleen op deze Mac, dus de back-up op Drive is onvolledig. Dit moet worden nagekeken.",
    "Time Machine is writing faster than the upload goes, and the buffer has filled up. The backup will be paused until the upload catches up — this is a safeguard against filling up the disk, not a failure.":
      "Time Machine schrijft sneller dan de upload gaat, en de buffer is vol. De back-up wordt gepauzeerd totdat de upload is ingehaald - dit is een beveiliging tegen het volschrijven van de schijf, geen storing.",
    "Google accepts 750 GB per day and that limit has been used up. There is nothing to do: the limit renews by itself, usually within a few hours. Time Machine backups are made normally in the meantime and wait in the buffer — they will be uploaded as soon as Google starts accepting again.":
      "Google accepteert 750 GB per dag en die limiet is op. Je hoeft niets te doen: de limiet wordt vanzelf vernieuwd, meestal binnen een paar uur. Time Machine-back-ups worden intussen gewoon gemaakt en wachten in de buffer - ze worden geüpload zodra Google weer accepteert.",
    "%@ backup fragments are queued and on their way to Drive.":
      "%@ back-upfragmenten staan in de wachtrij en zijn onderweg naar Drive.",
    "Nothing is waiting in the queue — the backup on Google Drive is complete.":
      "Er wacht niets in de wachtrij - de back-up op Google Drive is compleet.",
    "rclone did not answer the question about the queue, so it is unknown how many backups are still waiting to be uploaded. This does not mean something broke — under load the answer can be late. It only means that right now nobody knows. If it persists, the backup cycle check will report it.":
      "rclone heeft de vraag over de wachtrij niet beantwoord, dus het is onbekend hoeveel back-ups nog op upload wachten. Dit betekent niet dat er iets kapot is - onder belasting kan het antwoord laat komen. Het betekent alleen dat niemand het op dit moment weet. Als het aanhoudt, meldt de controle van de back-upcyclus het.",
    "unknown error":
      "onbekende fout",
    "rclone lsf ended with an error":
      "rclone lsf is met een fout beëindigd",
    "This Mac is close to its space limit on Google Drive":
      "Deze Mac zit dicht tegen zijn ruimtelimiet op Google Drive aan",
    "%@ GB of %@ GB used. Time Machine deletes the oldest backups to stay within its quota; check that the quota is set (vm-status).":
      "%@ GB van %@ GB gebruikt. Time Machine verwijdert de oudste back-ups om binnen zijn quotum te blijven; controleer of het quotum is ingesteld (vm-status).",
    "This Mac is over its space limit on Google Drive":
      "Deze Mac zit boven zijn ruimtelimiet op Google Drive",
    "%@ GB of %@ GB used. Set the Time Machine quota (command in the app window or vm-status), or raise the limit.":
      "%@ GB van %@ GB gebruikt. Stel het Time Machine-quotum in (commando in het appvenster of in vm-status), of verhoog de limiet.",
    "not set":
      "niet ingesteld",
    "%@ GB - usage not measured yet":
      "%@ GB - gebruik nog niet gemeten",
    "%@ of %@ GB used (%@%%)":
      "%@ van %@ GB gebruikt (%@%%)",
    "The limit must be a whole number of GB above zero.":
      "De limiet moet een geheel aantal GB boven nul zijn.",
    "machines.json cannot be read, so it was not overwritten. Fix or remove it first.":
      "machines.json kan niet worden gelezen en is daarom niet overschreven. Herstel of verwijder het eerst.",
    "'%@' is not a valid folder name: use lowercase letters, digits and dashes.":
      "'%@' is geen geldige mapnaam: gebruik kleine letters, cijfers en streepjes.",
    "This Mac already backs up to folder '%@'. Switching to '%@' would start a new, empty backup and orphan the existing one, so nothing was changed.":
      "Deze Mac maakt al back-ups naar map '%@'. Overschakelen naar '%@' zou een nieuwe, lege back-up beginnen en de bestaande verweesd achterlaten, dus er is niets gewijzigd.",
    "This Mac already has a CloudMachine installation, whose backup is in folder '%@'. Switching to '%@' would orphan it, so nothing was changed.":
      "Deze Mac heeft al een CloudMachine-installatie, waarvan de back-up in map '%@' staat. Overschakelen naar '%@' zou die verweesd achterlaten, dus er is niets gewijzigd.",
    "Could not save the folder name to %@: %@":
      "Kon de mapnaam niet bewaren in %@: %@",
    "Homebrew is not installed. Install it manually: https://brew.sh":
      "Homebrew is niet geïnstalleerd. Installeer het handmatig: https://brew.sh",
    "Installing rclone failed: %@":
      "Installatie van rclone mislukt: %@",
    "Installed rclone.":
      "rclone geïnstalleerd.",
    "Own Google credentials: set.":
      "Eigen Google-inloggegevens: ingesteld.",
    "INCOMPLETE: %@ is missing - rclone will use rclone's shared client_id anyway.":
      "ONVOLLEDIG: %@ ontbreekt - rclone gebruikt toch de gedeelde client_id van rclone.",
    "No own credentials - rclone uses the shared client_id, rate-limited jointly and being retired in 2026.":
      "Geen eigen inloggegevens - rclone gebruikt de gedeelde client_id, die gezamenlijk aan een limiet is gebonden en in 2026 wordt uitgefaseerd.",
    "Empty value - not saving.":
      "Lege waarde - wordt niet bewaard.",
    "Keychain refused: %@":
      "Sleutelhanger weigerde: %@",
    "DIRTY-TREE":
      "VUILE-BOOM",
    "Cannot create the working directory: %@":
      "Kan de werkmap niet aanmaken: %@",
    "Could not read the rclone version number.":
      "Kon het versienummer van rclone niet lezen.",
    "Could not download %@.":
      "Kon %@ niet downloaden.",
    "No entry for %@ in SHA256SUMS.":
      "Geen vermelding voor %@ in SHA256SUMS.",
    "Could not compute the checksum.":
      "Kon de controlesom niet berekenen.",
    "SHA256 checksum does not match - NOT installing.\n  expected: %@\n  computed: %@":
      "SHA256-controlesom komt niet overeen - wordt NIET geïnstalleerd.\n  verwacht: %@\n  berekend: %@",
    "Could not unpack the archive.":
      "Kon het archief niet uitpakken.",
    "Could not install the binary: %@":
      "Kon het binaire bestand niet installeren: %@",
    "Installed rclone %@ in %@ (SHA256 checksum matches).":
      "rclone %@ geïnstalleerd in %@ (SHA256-controlesom komt overeen).",
    "%@ did not respond within the allotted time (the process was left orphaned in the background).":
      "%@ heeft niet binnen de toegestane tijd gereageerd (het proces is verweesd op de achtergrond achtergebleven).",
    "Cannot launch %@: %@":
      "Kan %@ niet starten: %@",
    "Remote '%@' already exists and was NOT touched.\nOverwriting it replaces the token and the permission scope; a credential with the 'drive.file' scope does not see files created by the previous one, so the existing backup becomes unreachable.\nIf you really want to replace it, first back up ~/.config/rclone/rclone.conf and run again with --replace-existing.":
      "Remote '%@' bestaat al en is NIET aangeraakt.\nOverschrijven vervangt het token en de rechtenscope; inloggegevens met de scope 'drive.file' zien geen bestanden die door de vorige zijn gemaakt, waardoor de bestaande back-up onbereikbaar wordt.\nAls je het echt wilt vervangen, maak dan eerst een back-up van ~/.config/rclone/rclone.conf en voer het opnieuw uit met --replace-existing.",
    "Could not check whether remote '%@' already exists (rclone listremotes did not answer or failed), so nothing was changed. Run `%@ listremotes` to see the error, then try again.":
      "Kon niet controleren of remote '%@' al bestaat (rclone listremotes antwoordde niet of mislukte), dus er is niets gewijzigd. Voer `%@ listremotes` uit om de fout te zien en probeer het daarna opnieuw.",
    "Could not check whether this Mac already has a CloudMachine installation (rclone did not answer), so no folder was chosen. Try again in a moment.":
      "Kon niet controleren of deze Mac al een CloudMachine-installatie heeft (rclone antwoordde niet), dus er is geen map gekozen. Probeer het zo meteen opnieuw.",
    "rclone authorize failed (%@). If that binary is missing, start with: cloudmachine-agent install-rclone.":
      "rclone authorize mislukt (%@). Als dat binaire bestand ontbreekt, begin dan met: cloudmachine-agent install-rclone.",
    "Could not read the token from the output of rclone authorize.":
      "Kon het token niet lezen uit de uitvoer van rclone authorize.",
    "rclone config create failed.":
      "rclone config create mislukt.",
    "Connected to Google Drive as remote '%@', folder %@.":
      "Verbonden met Google Drive als remote '%@', map %@.",
    "tmutil is not responding - unknown where the backup goes":
      "tmutil reageert niet - onbekend waarheen de back-up gaat",
    "No successful backup for %@":
      "Geen geslaagde back-up sinds %@",
    "Last COMPLETED backup: %@. The cycle is hourly, so that is %@ missed runs.":
      "Laatste VOLTOOIDE back-up: %@. De cyclus is uurlijks, dus dat zijn %@ gemiste runs.",
    "There is NOT A SINGLE successful backup":
      "Er is GEEN ENKELE geslaagde back-up",
    "The Time Machine preferences contain no date of a completed backup for this destination.":
      "De Time Machine-voorkeuren bevatten geen datum van een voltooide back-up voor deze bestemming.",
    "The last backup attempt did not end in a backup":
      "De laatste back-uppoging heeft niet tot een back-up geleid",
    "The attempt at %@ is newer than the last successful backup at %@.":
      "De poging van %@ is nieuwer dan de laatste geslaagde back-up van %@.",
    "Time Machine reports an error in the last run (RESULT=%@)":
      "Time Machine meldt een fout in de laatste run (RESULT=%@)",
    "A non-zero RESULT in the Time Machine preferences means the run did not succeed.":
      "Een RESULT ongelijk aan nul in de Time Machine-voorkeuren betekent dat de run niet is geslaagd.",
    "rclone failed to upload %@ files":
      "rclone kon %@ bestanden niet uploaden",
    "Buffer full of nothing but unsent data":
      "Buffer vol met alleen nog niet-verzonden gegevens",
    "rclone has nothing left to evict from the buffer - the upload cannot keep up or has stalled.":
      "rclone kan niets meer uit de buffer verwijderen - de upload kan het niet bijhouden of is vastgelopen.",
    "The rclone control interface is not responding":
      "De besturingsinterface van rclone reageert niet",
    "Google Drive is running out of space (%@ GB)":
      "Google Drive raakt vol (%@ GB)",
    "The Mac's disk is running out of space (%@ GB)":
      "De schijf van de Mac raakt vol (%@ GB)",
    "Cannot read the Time Machine preferences":
      "Kan de Time Machine-voorkeuren niet lezen",
    "%@ is unreadable - most often Full Disk Access is missing. Without this file it is UNKNOWN when the last backup was made, so we treat it as a failure, not as the absence of a problem.":
      "%@ is onleesbaar - meestal ontbreekt Volledige schijftoegang. Zonder dit bestand is het ONBEKEND wanneer de laatste back-up is gemaakt, dus behandelen we het als een storing, niet als de afwezigheid van een probleem.",
    "Cannot measure free space on the Mac's disk":
      "Kan de vrije ruimte op de schijf van de Mac niet meten",
    "%@ days":
      "%@ dagen",
    "CloudMachine: backup is not working":
      "CloudMachine: back-up werkt niet",
    "unknown reason":
      "onbekende reden",
    "osascript did not show the notification (permissions or no graphical session)":
      "osascript toonde de melding niet (rechten of geen grafische sessie)",
    "UNDELIVERED ALARM: %@":
      "NIET BEZORGD ALARM: %@",
    "from %@, reason: %@":
      "van %@, reden: %@",
    "The system notification was not delivered - you will see this alarm ONLY here.":
      "De systeemmelding is niet bezorgd - dit alarm zie je ALLEEN hier.",
    "%@ (%@ ago)":
      "%@ (%@ geleden)",
    "%@ - marker from the FUTURE":
      "%@ - markering uit de TOEKOMST",
    "%@ (%@ ago) - THE WATCHDOG MAY NOT BE RUNNING":
      "%@ (%@ geleden) - DE WAAKHOND DRAAIT MOGELIJK NIET",
    "NEVER - the watchdog has not recorded a single run":
      "NOOIT - de waakhond heeft geen enkele run vastgelegd",
    "Could not find the launchd/ directory with templates.":
      "Kon de map launchd/ met sjablonen niet vinden.",
    "Could not find the compiled cloudmachine-agent binary.":
      "Kon het gecompileerde binaire bestand cloudmachine-agent niet vinden.",
    "ABORTED: could not put cloudmachine-agent in a stable location\n(%@) - most often a lack of space or permissions.\nNOT installing agents pointing at %@: that path\ndisappears on the next `swift build` or `git clean`, and backups stop\nwithout any visible signal.":
      "AFGEBROKEN: kon cloudmachine-agent niet op een vaste locatie plaatsen\n(%@) - meestal door een gebrek aan ruimte of rechten.\nAgents die naar %@ verwijzen worden NIET geïnstalleerd: dat pad\nverdwijnt bij de volgende `swift build` of `git clean`, en back-ups stoppen\nzonder zichtbaar signaal.",
    "ABORTED: %@":
      "AFGEBROKEN: %@",
    "Could not list the templates in %@.":
      "Kon de sjablonen in %@ niet weergeven.",
    "could not read the template %@":
      "kon het sjabloon %@ niet lezen",
    "could not write %@ (lack of space or permissions)":
      "kon %@ niet schrijven (gebrek aan ruimte of rechten)",
    "launchctl load refused to load %@":
      "launchctl load weigerde %@ te laden",
    "NOT A SINGLE agent was loaded.":
      "GEEN ENKELE agent is geladen.",
    "Only these went in: %@.":
      "Alleen deze zijn erin gekomen: %@.",
    "Could not load any launchd agent.":
      "Kon geen enkele launchd-agent laden.",
    "Installed agents: %@":
      "Geïnstalleerde agents: %@",
    "                  WARNING: close to the limit - new bands will fail with EMFILE":
      "                  WAARSCHUWING: dicht bij de limiet - nieuwe bands mislukken met EMFILE",
    "%@/bands on Google Drive is not empty - it may hold another backup. NOT overwriting it; check it by hand.":
      "%@/bands op Google Drive is niet leeg - het bevat mogelijk een andere back-up. Wordt NIET overschreven; controleer het handmatig.",
    "Address:          %@":
      "Adres:            %@",
    "Already prepared (%@ exists) - nothing to do.":
      "Al voorbereid (%@ bestaat) - niets te doen.",
    "Converts Time Machine's new, empty image in the machine to 32 MB bands and moves the bands to Google Drive.":
      "Converteert de nieuwe, lege image van Time Machine in de machine naar bands van 32 MB en verplaatst de bands naar Google Drive.",
    "Copy rclone.conf into the machine even if it already has one.":
      "Kopieer rclone.conf naar de machine, ook als die er al een heeft.",
    "Copying the converted image into the machine failed: %@":
      "Het kopiëren van de geconverteerde image naar de machine is mislukt: %@",
    "Copying the image to the Mac failed: %@":
      "Het kopiëren van de image naar de Mac is mislukt: %@",
    "Could not ask Lima about the machine: %@":
      "Kon Lima niet naar de machine vragen: %@",
    "Could not carry the Time Machine files over: %@":
      "Kon de Time Machine-bestanden niet overzetten: %@",
    "Could not check the image in the machine.":
      "Kon de image in de machine niet controleren.",
    "Could not copy the rclone configuration into the machine.":
      "Kon de rclone-configuratie niet naar de machine kopiëren.",
    "Could not create %@ on Google Drive: %@":
      "Kon %@ niet aanmaken op Google Drive: %@",
    "Could not create %@: %@":
      "Kon %@ niet aanmaken: %@",
    "Could not find the vm/ directory with the machine template.":
      "Kon de map vm/ met het machinesjabloon niet vinden.",
    "Could not read the image size.":
      "Kon de grootte van de image niet lezen.",
    "Could not set the SMB password of user %@ in the machine.":
      "Kon het SMB-wachtwoord van gebruiker %@ in de machine niet instellen.",
    "Could not stop smbd in the machine.":
      "Kon smbd in de machine niet stoppen.",
    "Could not write %@ in the machine.":
      "Kon %@ niet schrijven in de machine.",
    "Could not write the password file %@.":
      "Kon het wachtwoordbestand %@ niet schrijven.",
    "Creates or starts the CloudMachine machine (Lima), gives it rclone's configuration and an SMB password, and prints the Time Machine command.":
      "Maakt de CloudMachine-machine (Lima) aan of start die, geeft hem de configuratie van rclone en een SMB-wachtwoord, en toont het Time Machine-commando.",
    "Creating the machine %@ (first start downloads Ubuntu and installs packages - several minutes)...":
      "Machine %@ aanmaken (bij de eerste start worden Ubuntu en pakketten gedownload - enkele minuten)...",
    "Done: %@ has %@ MB bands on Google Drive; the original is kept in %@ in the machine. Start the backup: tmutil startbackup":
      "Klaar: %@ heeft bands van %@ MB op Google Drive; het origineel blijft bewaard in %@ in de machine. Start de back-up: tmutil startbackup",
    "exit code %@, no message":
      "exitcode %@, geen melding",
    "Image metadata:   NEVER copied to %@ - check tm-meta-sync in the machine":
      "Image-metadata:   NOOIT gekopieerd naar %@ - controleer tm-meta-sync in de machine",
    "Image metadata:   copied %@ ago to %@":
      "Image-metadata:   %@ geleden gekopieerd naar %@",
    "Image metadata:   last copied %@ ago - OVERDUE (%@)":
      "Image-metadata:   laatst %@ geleden gekopieerd - ACHTERSTALLIG (%@)",
    "Image metadata:   not copied yet - waits for vm-prepare-bundle":
      "Image-metadata:   nog niet gekopieerd - wacht op vm-prepare-bundle",
    "Backup %@, paused by the guard %@: %@":
      "Back-up %@, gepauzeerd door de bewaker %@: %@",
    "Free in machine:  %@ GiB":
      "Vrij in machine:  %@ GiB",
    "fsck_apfs -n found problems: %@":
      "fsck_apfs -n vond problemen: %@",
    "Google Drive folder: %@":
      "Google Drive-map: %@",
    "hdiutil attach of the converted image failed: %@":
      "hdiutil attach van de geconverteerde image mislukt: %@",
    "hdiutil convert failed: %@":
      "hdiutil convert mislukt: %@",
    "Image name in the machine (default: from the computer name).":
      "Naam van de image in de machine (standaard: afgeleid van de computernaam).",
    "Installing the converted image FAILED: %@\nsmbd is left STOPPED so Time Machine does not open a half-installed image. The original is in %@ in the machine.":
      "Installeren van de geconverteerde image MISLUKT: %@\nsmbd blijft GESTOPT, zodat Time Machine geen half geïnstalleerde image opent. Het origineel staat in %@ in de machine.",
    "limactl create failed: %@":
      "limactl create mislukt: %@",
    "limactl list failed: %@":
      "limactl list mislukt: %@",
    "limactl not found - install Lima: brew install lima":
      "limactl niet gevonden - installeer Lima: brew install lima",
    "limactl start failed: %@\nThe machine's own log: %@":
      "limactl start mislukt: %@\nHet eigen logboek van de machine: %@",
    "Machine %@ is running.":
      "Machine %@ draait.",
    "Machine %@ was already running.":
      "Machine %@ draaide al.",
    "Machine:          %@ (%@)":
      "Machine:          %@ (%@)",
    "Machine:          %@":
      "Machine:          %@",
    "Machine:          not created - run: cloudmachine-agent vm-setup":
      "Machine:          niet aangemaakt - voer uit: cloudmachine-agent vm-setup",
    "no answer within the time limit":
      "geen antwoord binnen de tijdslimiet",
    "No image %@ in the machine.":
      "Geen image %@ in de machine.",
    "No image in the machine yet - point Time Machine at the share and let it create one first.":
      "Nog geen image in de machine - richt Time Machine op de share en laat eerst een image aanmaken.",
    "No rclone configuration at %@ - connect Google Drive first (configure-remote).":
      "Geen rclone-configuratie op %@ - verbind eerst Google Drive (configure-remote).",
    "no SMB destination":
      "geen SMB-bestemming",
    "One check of the machine's upload buffer: pauses Time Machine when it fills, resumes what it paused.":
      "Eén controle van de uploadbuffer van de machine: pauzeert Time Machine als die vol raakt en hervat wat het heeft gepauzeerd.",
    "Packing the converted image failed: %@":
      "Het verpakken van de geconverteerde image is mislukt: %@",
    "Packing the image failed: %@":
      "Het verpakken van de image is mislukt: %@",
    "No answer from the machine (rclone rc) - the guard would do nothing.":
      "Geen antwoord van de machine (rclone rc) - de bewaker zou niets doen.",
    "Only print what the guard would decide - for trying thresholds on a throwaway machine.":
      "Toon alleen wat de bewaker zou beslissen - om drempels uit te proberen op een wegwerpmachine.",
    "Pause above this many GiB in the buffer.":
      "Pauzeer boven zoveel GiB in de buffer.",
    "Pause when the machine has less free than this, in GiB.":
      "Pauzeer als de machine minder vrij heeft dan dit, in GiB.",
    "Point Time Machine at the machine (once, needs an administrator password):":
      "Richt Time Machine op de machine (eenmalig, beheerderswachtwoord vereist):",
    "punchfs files:    %@ open, limit %@":
      "punchfs-bestanden: %@ open, limiet %@",
    "rclone configuration already in the machine - kept (--replace-rclone-config replaces it).":
      "rclone-configuratie staat al in de machine - blijft behouden (--replace-rclone-config vervangt die).",
    "rclone configuration copied into the machine.":
      "rclone-configuratie naar de machine gekopieerd.",
    "rclone-tm or punchfs is not running in the machine - see cloudmachine-agent vm-status.":
      "rclone-tm of punchfs draait niet in de machine - zie cloudmachine-agent vm-status.",
    "Resume below this many GiB (only a backup the guard paused).":
      "Hervat onder zoveel GiB (alleen een back-up die de bewaker heeft gepauzeerd).",
    "Service %@: %@":
      "Service %@: %@",
    "Several images in the machine (%@) - choose one with --bundle.":
      "Meerdere images in de machine (%@) - kies er een met --bundle.",
    "Shows the machine: address, services, upload buffer, free space and the Time Machine destination.":
      "Toont de machine: adres, services, uploadbuffer, vrije ruimte en de Time Machine-bestemming.",
    "SMB password stored in %@ (mode 600).":
      "SMB-wachtwoord bewaard in %@ (modus 600).",
    "The converted image does not have %@-byte bands.":
      "De geconverteerde image heeft geen bands van %@ byte.",
    "The converted image has no APFS partition.":
      "De geconverteerde image heeft geen APFS-partitie.",
    "The image already takes %@ MB - this command converts only a new, empty image (under %@ MB).":
      "De image neemt al %@ MB in beslag - dit commando converteert alleen een nieuwe, lege image (onder %@ MB).",
    "The image is encrypted - converting encrypted images is not supported.":
      "De image is versleuteld - het converteren van versleutelde images wordt niet ondersteund.",
    "The image was not changed; smbd started again.":
      "De image is niet gewijzigd; smbd is weer gestart.",
    "The machine does not answer - is it running? cloudmachine-agent vm-status":
      "De machine antwoordt niet - draait hij? cloudmachine-agent vm-status",
    "The machine has no address on the vzNAT network.":
      "De machine heeft geen adres op het vzNAT-netwerk.",
    "The services in the machine did not start - check: cloudmachine-agent vm-status":
      "De services in de machine zijn niet gestart - controleer: cloudmachine-agent vm-status",
    "Time Machine is backing up - stop it first: tmutil stopbackup":
      "Time Machine maakt een back-up - stop die eerst: tmutil stopbackup",
    "Time Machine:     %@":
      "Time Machine:     %@",
    "Time Machine:     NOT pointing at the machine (%@)":
      "Time Machine:     wijst NIET naar de machine (%@)",
    "Time Machine:     tmutil did not answer":
      "Time Machine:     tmutil heeft niet geantwoord",
    "tmutil did not answer - not touching the image while its state is unknown.":
      "tmutil heeft niet geantwoord - de image wordt niet aangeraakt zolang de status onbekend is.",
    "unknown":
      "onbekend",
    "Unpacking the image failed: %@":
      "Het uitpakken van de image is mislukt: %@",
    "Still to upload:  %@ GiB in %@ bands, uploading %@ (cache on disk %@ GiB)":
      "Nog te uploaden:  %@ GiB in %@ bands, %@ worden geüpload (cache op schijf %@ GiB)",
    "Excluded %@ (the machine and its upload buffer) from Time Machine.":
      "%@ (de machine en de uploadbuffer ervan) uitgesloten van Time Machine.",
    "WARNING: could not exclude %@ from Time Machine - run: tmutil addexclusion %@":
      "WAARSCHUWING: kon %@ niet uitsluiten van Time Machine - voer uit: tmutil addexclusion %@",
    "Upload buffer:    no answer from rclone (rc %@)":
      "Uploadbuffer:     geen antwoord van rclone (rc %@)",
    "When Time Machine has created its empty image, stop the backup (tmutil stopbackup) and run: cloudmachine-agent vm-prepare-bundle":
      "Als Time Machine zijn lege image heeft gemaakt, stop dan de back-up (tmutil stopbackup) en voer uit: cloudmachine-agent vm-prepare-bundle",
    "Unsent %@ GiB, free %@ GiB (pause above %@ GiB unsent or below %@ GiB free, resume below %@ GiB).":
      "Niet verzonden %@ GiB, vrij %@ GiB (pauzeer boven %@ GiB niet verzonden of onder %@ GiB vrij, hervat onder %@ GiB).",
    "Upload:           Google's daily limit refused an upload %@ ago - rclone retries every 5 min and resumes by itself":
      "Upload:           de dagelijkse limiet van Google weigerde %@ geleden een upload - rclone probeert het elke 5 min opnieuw en gaat vanzelf verder",
    "no":
      "nee",
    "running":
      "draait",
    "stopped":
      "gestopt",
    "yes":
      "ja",
    "%@\nThe previous template is in %@ - copy it back over lima.yaml and run limactl start %@.":
      "%@\nHet vorige sjabloon staat in %@ - kopieer het terug over lima.yaml en voer limactl start %@ uit.",
    "Could not read this app's machine template (limactl template copy).":
      "Kon het machinesjabloon van deze app niet lezen (limactl template copy).",
    "Could not replace %@: %@":
      "Kon %@ niet vervangen: %@",
    "Machine %@ already runs this app's template.":
      "Machine %@ draait al met het sjabloon van deze app.",
    "Machine %@ now runs this app's template; the previous one is in %@.":
      "Machine %@ draait nu met het sjabloon van deze app; het vorige staat in %@.",
    "Moves the machine onto this app's template (two restarts, never during a backup).":
      "Zet de machine over op het sjabloon van deze app (twee herstarts, nooit tijdens een back-up).",
    "No machine %@ - create it with: cloudmachine-agent vm-setup":
      "Geen machine %@ - maak hem aan met: cloudmachine-agent vm-setup",
    "Template:         OLDER than this app's - run: cloudmachine-agent vm-update":
      "Sjabloon:         OUDER dan dat van deze app - voer uit: cloudmachine-agent vm-update",
    "Template:         not compared":
      "Sjabloon:         niet vergeleken",
    "Template:         this app's":
      "Sjabloon:         dat van deze app",
    "The machine has no %@ - run cloudmachine-agent vm-setup first.":
      "De machine heeft geen %@ - voer eerst cloudmachine-agent vm-setup uit.",
    "The machine restarted, but not every service is running - check: cloudmachine-agent vm-status. The previous template is in %@.":
      "De machine is opnieuw gestart, maar niet alle services draaien - controleer: cloudmachine-agent vm-status. Het vorige sjabloon staat in %@.",
    "The template changes the machine itself (%@) - that needs a new machine, not an update.":
      "Het sjabloon wijzigt de machine zelf (%@) - daarvoor is een nieuwe machine nodig, geen update.",
    "The upload to Google Drive hangs":
      "De upload naar Google Drive blijft hangen",
    "Time Machine is backing up - try again when it has finished.":
      "Time Machine maakt een back-up - probeer het opnieuw als die klaar is.",
    "Upload:           HANGS - bands in progress, none uploaded for %@ (network?); see /var/log/rclone-tm.log in the machine":
      "Upload:           BLIJFT HANGEN - bands in behandeling, al %@ geen geüpload (netwerk?); zie /var/log/rclone-tm.log in de machine",
    "limactl stop failed - nothing was changed.":
      "limactl stop mislukt - er is niets gewijzigd.",
    "rclone has bands in progress, but none has been uploaded for %@ - usually a broken network connection, which rclone does not report as an error. Backups since then are only in the machine's buffer. When the network comes back the upload resumes by itself (on 28.10.2026 within 80 s); if it does not, restarting the machine (prepare-shutdown, limactl start) drops the dead connections.":
      "rclone heeft bands in behandeling, maar al %@ is er geen geüpload - meestal een verbroken netwerkverbinding, die rclone niet als fout meldt. Back-ups sindsdien staan alleen in de buffer van de machine. Zodra het netwerk terug is, gaat de upload vanzelf verder (op 28.10.2026 binnen 80 s); zo niet, dan verwijdert een herstart van de machine (prepare-shutdown, limactl start) de dode verbindingen.",
    "tmutil did not answer - not restarting the machine while its state is unknown.":
      "tmutil heeft niet geantwoord - de machine wordt niet opnieuw gestart zolang de status onbekend is.",
    "The machine's share cannot be read":
      "De share van de machine kan niet worden gelezen",
    "Unknown whether the machine's share can be read":
      "Onbekend of de share van de machine leesbaar is",
    "Samba in the machine does not answer this Mac":
      "Samba in de machine antwoordt deze Mac niet",
    "Unknown whether Samba in the machine answers this Mac":
      "Onbekend of Samba in de machine deze Mac antwoordt",
    "Reading 1 byte of %@ in the machine failed: %@. Every service says it is active, yet Time Machine cannot use the image there. Nothing restarts it by itself. Check: cloudmachine-agent vm-status, then in the machine: journalctl -u punchfs -u tm-bands-bind -u rclone-tm":
      "Het lezen van 1 byte van %@ in de machine is mislukt: %@. Elke dienst zegt actief te zijn, maar Time Machine kan de image daar niet gebruiken. Niets herstart het vanzelf. Controleer: cloudmachine-agent vm-status, daarna in de machine: journalctl -u punchfs -u tm-bands-bind -u rclone-tm",
    "Reading 1 byte of %@ in the machine has not returned for %@ s. That is how a hung punchfs or rclone mount behaves. Nothing is restarted while the state is unknown - a restart under a write still going could lose it. Check in the machine: journalctl -u punchfs -u rclone-tm":
      "Het lezen van 1 byte van %@ in de machine is al %@ s niet teruggekomen. Zo gedraagt een vastgelopen punchfs- of rclone-mount zich. Zolang de toestand onbekend is, wordt niets herstart - een herstart onder een lopende schrijfactie kan die verliezen. Controleer in de machine: journalctl -u punchfs -u rclone-tm",
    "An SMB connection to %@ got no answer within %@ s. Time Machine reaches the machine at this address. Check the machine's network and smbd: cloudmachine-agent vm-status":
      "Een SMB-verbinding met %@ kreeg binnen %@ s geen antwoord. Time Machine bereikt de machine op dit adres. Controleer het netwerk van de machine en smbd: cloudmachine-agent vm-status",
    "The machine did not report its address, so nobody could try an SMB connection. Check: cloudmachine-agent vm-status":
      "De machine heeft haar adres niet gemeld, dus niemand kon een SMB-verbinding proberen. Controleer: cloudmachine-agent vm-status",
    "An SMB connection to %@ failed (%@). Time Machine reaches the machine at this address, so no backup is made. Check the machine's network and smbd: cloudmachine-agent vm-status":
      "Een SMB-verbinding met %@ is mislukt (%@). Time Machine bereikt de machine op dit adres, dus er wordt geen back-up gemaakt. Controleer het netwerk van de machine en smbd: cloudmachine-agent vm-status",
    "readable":
      "leesbaar",
    "no image yet":
      "nog geen image",
    "answers":
      "antwoordt",
    "Share read:       %@":
      "Share lezen:      %@",
    "Samba from Mac:   %@":
      "Samba vanaf Mac:  %@",
    "This Mac found no route to %@ (%@). Either the route to the machine is gone, or macOS Local Network privacy has not allowed CloudMachine - then allow it in System Settings > Privacy & Security > Local Network. Check: cloudmachine-agent vm-status":
      "Deze Mac vond geen route naar %@ (%@). Of de route naar de machine is weg, of de macOS-privacy 'Lokaal netwerk' heeft CloudMachine niet toegestaan - sta het dan toe in Systeeminstellingen > Privacy en beveiliging > Lokaal netwerk. Controleer: cloudmachine-agent vm-status",
  ]
}
