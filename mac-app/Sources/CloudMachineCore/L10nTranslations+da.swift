// Danish translations, keyed by the English text passed to `L10n.tr`.
extension L10nTranslations {
  static let da: [String: String] = [
    "Space limit:      %@":
      "Pladsgrænse:     %@",
    "                  Time Machine quota not set to match - run: %@":
      "                  Time Machine-kvoten er ikke indstillet til at passe - kør: %@",
    "Sets how much of Google Drive this Mac may use, and prints the Time Machine quota command.":
      "Angiver, hvor meget af Google Drive denne Mac må bruge, og udskriver kommandoen til Time Machine-kvoten.",
    "Limit in GB.":
      "Grænse i GB.",
    "Limit for this Mac: %@ GB.":
      "Grænse for denne Mac: %@ GB.",
    "Now set the Time Machine quota (needs an administrator password):":
      "Indstil nu Time Machine-kvoten (kræver en administratoradgangskode):",
    "CloudMachine - verification, Google Drive setup and installation. Called by launchd on a schedule, or by hand from Terminal.":
      "CloudMachine - kontrol, konfiguration af Google Drive og installation. Kaldes af launchd efter en tidsplan eller manuelt fra Terminal.",
    "Connects to Google Drive through rclone (OAuth in the browser) and creates this machine's folder.":
      "Opretter forbindelse til Google Drive via rclone (OAuth i browseren) og opretter denne maskines mappe.",
    "Overwrite the existing remote. RISKY: replaces the token and permissions.":
      "Overskriv den eksisterende remote. RISIKABELT: erstatter token og tilladelser.",
    "Packs build/CloudMachine.app into build/CloudMachine-<version>.dmg.":
      "Pakker build/CloudMachine.app til build/CloudMachine-<version>.dmg.",
    "ERROR: %@ is missing - run 'cloudmachine-agent build-app' first":
      "FEJL: %@ mangler - kør først 'cloudmachine-agent build-app'",
    "==> Preparing the staging folder":
      "==> Forbereder staging-mappen",
    "==> Creating %@":
      "==> Opretter %@",
    "ERROR: hdiutil exited with code %@.":
      "FEJL: hdiutil afsluttede med kode %@.",
    "==> Done: %@":
      "==> Færdig: %@",
    "On first launch (the app is not signed with an Apple Developer account):":
      "Ved første start (appen er ikke signeret med en Apple Developer-konto):",
    "1. Open %@ and drag CloudMachine.app to Applications.":
      "1. Åbn %@ og træk CloudMachine.app til Programmer.",
    "2. In Finder, RIGHT-click CloudMachine.app -> Open -> Open\n   (a plain double-click shows the Gatekeeper block \"unidentified developer\").":
      "2. Højreklik på CloudMachine.app i Finder -> Åbn -> Åbn\n   (et almindeligt dobbeltklik viser Gatekeeper-blokeringen “ikke-identificeret udvikler”).",
    "3. Later launches work normally, with a double-click.":
      "3. Senere starter appen normalt med et dobbeltklik.",
    "Builds CloudMachine.app (Release) - GUI + cloudmachine-agent in Contents/MacOS/, plus launchd/, vm/ and config/ as Resources.":
      "Bygger CloudMachine.app (Release) - GUI + cloudmachine-agent i Contents/MacOS/ samt launchd/, vm/ og config/ som Resources.",
    "Binaries for Apple Silicon and Intel at once (how CI builds a release; unnecessary locally).":
      "Binære filer til både Apple Silicon og Intel (sådan bygger CI en udgivelse; unødvendigt lokalt).",
    "==> Building CloudMachineApp + cloudmachine-agent (release) - version %@ (%@)":
      "==> Bygger CloudMachineApp + cloudmachine-agent (release) - version %@ (%@)",
    "ERROR: swift build exited with code %@.":
      "FEJL: swift build afsluttede med kode %@.",
    "ERROR: swift build --show-bin-path did not report the binaries directory.":
      "FEJL: swift build --show-bin-path angav ikke mappen med de binære filer.",
    "ERROR: no built binary found at %@":
      "FEJL: ingen bygget binær fil fundet i %@",
    "==> Assembling the .app bundle in %@":
      "==> Samler .app-pakken i %@",
    "==> WARNING: you are building from a DIRTY tree - the version will not point to a commit.":
      "==> ADVARSEL: du bygger fra et SNAVSET træ - versionen peger ikke på en commit.",
    "ERROR: Resources/AppIcon.icns is missing - generate it: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns":
      "FEJL: Resources/AppIcon.icns mangler - opret den: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns",
    "==> Signing with the local certificate '%@' (Full Disk Access will survive later rebuilds)":
      "==> Signerer med det lokale certifikat '%@' (Fuld diskadgang bevares ved senere ombygninger)",
    "==> Signing ad-hoc (no Apple Developer account) - run 'cloudmachine-agent setup-signing-cert' once so that TCC permissions survive later rebuilds":
      "==> Signerer ad hoc (ingen Apple Developer-konto) - kør 'cloudmachine-agent setup-signing-cert' én gang, så TCC-tilladelser bevares ved senere ombygninger",
    "ERROR: codesign exited with code %@.":
      "FEJL: codesign afsluttede med kode %@.",
    "Next step: %@":
      "Næste trin: %@",
    "Creates a local self-signed certificate so that Full Disk Access survives later rebuilds of the app.":
      "Opretter et lokalt selvsigneret certifikat, så Fuld diskadgang bevares ved senere ombygninger af appen.",
    "Certificate '%@' already exists in %@, nothing to do.":
      "Certifikatet '%@' findes allerede i %@ - der er intet at gøre.",
    "==> Generating the key and self-signed certificate '%@'...":
      "==> Opretter nøgle og selvsigneret certifikat '%@'...",
    "ERROR: openssl req exited with code %@.":
      "FEJL: openssl req afsluttede med kode %@.",
    "ERROR: openssl pkcs12 exited with code %@.":
      "FEJL: openssl pkcs12 afsluttede med kode %@.",
    "==> Importing the certificate into %@ (pre-authorizing /usr/bin/codesign, so it does not ask for the keychain password every time)...":
      "==> Importerer certifikatet i %@ (forhåndsgodkender /usr/bin/codesign, så den ikke spørger om adgangskoden til nøgleringen hver gang)...",
    "ERROR: security import exited with code %@.":
      "FEJL: security import afsluttede med kode %@.",
    "==> Trusting the certificate ONLY for code signing...":
      "==> Giver kun certifikatet tillid til kodesignering...",
    "ERROR: security add-trusted-cert exited with code %@.":
      "FEJL: security add-trusted-cert afsluttede med kode %@.",
    "Done. Certificate '%@' is now available to codesign.":
      "Færdig. Certifikatet '%@' er nu tilgængeligt for codesign.",
    "The next 'cloudmachine-agent build-app' will use it automatically instead of an ad-hoc signature.":
      "Næste 'cloudmachine-agent build-app' bruger det automatisk i stedet for en ad hoc-signatur.",
    "After THAT ONE rebuild, grant Full Disk Access one last time - later\nrebuilds will no longer reset it, as long as you sign with the same certificate.":
      "Efter DEN ENE ombygning skal du give Fuld diskadgang en sidste gang - senere\nombygninger nulstiller den ikke mere, så længe du signerer med det samme certifikat.",
    "Checks whether the hourly cycle STILL works (date of the last SUCCESSFUL backup) and reports failures.":
      "Kontrollerer, om den timevise cyklus STADIG virker (datoen for den sidste VELLYKKEDE backup), og melder fejl.",
    "After this many hours without a successful backup we consider the cycle broken.":
      "Efter så mange timer uden en vellykket backup anser vi cyklussen for brudt.",
    "Only print the state, without a system notification.":
      "Udskriv kun tilstanden, uden en systemnotifikation.",
    "A different Time Machine preferences file - to test the watchdog on a known sample.":
      "En anden præferencefil til Time Machine - til at teste vagthunden på en kendt prøve.",
    "Last successful backup: %@":
      "Sidste vellykkede backup: %@",
    "Last successful backup: NONE":
      "Sidste vellykkede backup: INGEN",
    "Last attempt:           %@":
      "Sidste forsøg:           %@",
    "WAITING (system startup): %@":
      "VENTER (systemstart): %@",
    "Backup cycle: OK":
      "Backupcyklus: OK",
    "FAILURE: %@":
      "FEJL: %@",
    "         %@":
      "         %@",
    "Check the state:  %@":
      "Tjek tilstanden:  %@",
    "Preparing for restart":
      "Forbereder genstart",
    "Prepare for restart":
      "Forbered til genstart",
    "Prepare":
      "Forbered",
    "==> WARNING: git rev-list failed (%@) - using the date as the build number.":
      "==> ADVARSEL: git rev-list mislykkedes (%@) - datoen bruges som buildnummer.",
    "Agents:           %@":
      "Agenter:           %@",
    "CANNOT START: %@ - open CloudMachine or run backup-health to reload them":
      "KAN IKKE STARTE: %@ - åbn CloudMachine eller kør backup-health for at indlæse dem igen",
    "Reloaded agents that could not start: %@":
      "Genindlæste agenter, der ikke kunne starte: %@",
    "Drive folder:     %@":
      "Drive-mappe:       %@",
    "Name of this Mac's folder on Google Drive (default: derived from the computer name). Set once; it cannot be changed later.":
      "Navnet på denne Macs mappe på Google Drive (standard: afledt af computerens navn). Angives én gang; kan ikke ændres senere.",
    "Backup watchdog:  %@":
      "Backup-vagthund:   %@",
    "Prints the version, the build number and the commit this binary was built from.":
      "Udskriver versionen, buildnummeret og den commit, som denne binære fil blev bygget fra.",
    "Only one line, without a description.":
      "Kun én linje, uden beskrivelse.",
    "Build from the working tree (outside a bundle) - no version data.":
      "Build fra arbejdstræet (uden for en pakke) - ingen versionsdata.",
    "Version: %@":
      "Version: %@",
    "Build:   %@":
      "Build:   %@",
    "Commit:  %@":
      "Commit:  %@",
    "WARNING: built from a DIRTY tree - the binary contains code that\n         is in no commit. The commit number does NOT describe\n         what actually runs.":
      "ADVARSEL: bygget fra et SNAVSET træ - den binære fil indeholder kode, der\n         ikke er i nogen commit. Commit-nummeret beskriver IKKE,\n         hvad der faktisk kører.",
    "Saving the space limit":
      "Gemmer pladsgrænsen",
    "Measuring usage on Google Drive":
      "Måler forbruget på Google Drive",
    "Google Drive did not answer - try again later.":
      "Google Drive svarede ikke - prøv igen senere.",
    "Measured.":
      "Målt.",
    "Space limit for this Mac":
      "Pladsgrænse for denne Mac",
    "Used on Google Drive":
      "Brugt på Google Drive",
    "Measured %@. The watchdog measures again every few hours.":
      "Målt %@. Vagthunden måler igen med få timers mellemrum.",
    "Limit (GB)":
      "Grænse (GB)",
    "Save":
      "Gem",
    "Measure now":
      "Mål nu",
    "Time Machine quota: %@ GB (70%% of the limit - the copy on Drive is about a third larger than the backup inside it). Time Machine deletes the oldest backups to stay within it.":
      "Time Machine-kvote: %@ GB (70%% af grænsen - kopien på Drive er cirka en tredjedel større end den backup, den indeholder). Time Machine sletter de ældste backups for at holde sig inden for den.",
    "Set the Time Machine quota: run this in Terminal (needs sudo)":
      "Indstil Time Machine-kvoten: kør dette i Terminal (kræver sudo)",
    "Connect Google Drive: run this in Terminal and approve in the browser":
      "Tilslut Google Drive: kør dette i Terminal, og godkend i browseren",
    "Grant Full Disk Access to CloudMachine, so it can tell whether backups complete":
      "Giv CloudMachine Fuld diskadgang, så den kan se, om backups bliver færdige",
    "Folder on Google Drive":
      "Mappe på Google Drive",
    "One folder per Mac. Set once - it cannot be changed after connecting.":
      "Én mappe pr. Mac. Angives én gang - kan ikke ændres efter tilslutning.",
    "Use lowercase letters, digits and dashes.":
      "Brug små bogstaver, cifre og bindestreger.",
    "Install rclone":
      "Installer rclone",
    "Open System Settings":
      "Åbn Systemindstillinger",
    "Install agents":
      "Installer agenter",
    "not checked":
      "ikke kontrolleret",
    "none at all":
      "slet ingen",
    "%@ ago":
      "%@ siden",
    "Missing: %@":
      "Mangler: %@",
    "Google Drive not connected":
      "Google Drive er ikke tilsluttet",
    "Time Machine does not point to CloudMachine":
      "Time Machine peger ikke på CloudMachine",
    "UNKNOWN whether Time Machine points to CloudMachine - tmutil did not answer":
      "DET ER UKENDT, om Time Machine peger på CloudMachine - tmutil svarede ikke",
    "Backup in progress":
      "Backup i gang",
    "Unknown when the last backup was made":
      "Det er ukendt, hvornår den sidste backup blev lavet",
    "There is no completed backup at all":
      "Der er slet ingen gennemført backup",
    "No completed backup for %@":
      "Ingen gennemført backup i %@",
    "Ready":
      "Klar",
    "Not saved: %@":
      "Ikke gemt: %@",
    "Installing rclone":
      "Installerer rclone",
    "Installing launchd agents":
      "Installerer launchd-agenter",
    "Starting backup":
      "Starter backup",
    "Backup started.":
      "Backup startet.",
    "Could not start the backup.":
      "Kunne ikke starte backuppen.",
    "Stopping backup":
      "Stopper backup",
    "Backup stopped.":
      "Backup stoppet.",
    "Could not stop the backup.":
      "Kunne ikke stoppe backuppen.",
    "Could not prepare the AppleScript.":
      "Kunne ikke klargøre AppleScript.",
    "Unknown authorization error.":
      "Ukendt godkendelsesfejl.",
    "Waiting to upload":
      "Venter på upload",
    "%@ files":
      "%@ filer",
    "nothing":
      "intet",
    "Back up now":
      "Tag backup nu",
    "Stop backup":
      "Stop backup",
    "Open CloudMachine":
      "Åbn CloudMachine",
    "Quit":
      "Afslut",
    "Healthy":
      "Sund",
    "Attention":
      "Obs",
    "Refreshed %@":
      "Opdateret %@",
    "System Status":
      "Systemstatus",
    "Action needed":
      "Handling påkrævet",
    "not measured":
      "ikke målt",
    "rclone did not answer":
      "rclone svarede ikke",
    "Backup in Progress":
      "Backup i gang",
    "Files processed":
      "Behandlede filer",
    "Write speed":
      "Skrivehastighed",
    "Operation phase":
      "Handlingsfase",
    "Required Setup Steps":
      "Nødvendige konfigurationstrin",
    "Copy":
      "Kopiér",
    "Last completed backup":
      "Sidste gennemførte backup",
    "Last backup watchdog run":
      "Seneste kørsel af backup-vagthunden",
    "not read":
      "ikke læst",
    "Everything uploaded":
      "Alt er uploadet",
    "File upload errors":
      "Fejl ved upload af filer",
    "Google Drive Credentials (OAuth 2.0)":
      "Google Drive-legitimationsoplysninger (OAuth 2.0)",
    "Keychain OK":
      "Nøglering OK",
    "No custom keys":
      "Ingen egne nøgler",
    "Paste client_id...":
      "Indsæt client_id...",
    "Paste client_secret...":
      "Indsæt client_secret...",
    "Save securely in the Keychain":
      "Gem sikkert i nøgleringen",
    "Refresh":
      "Opdater",
    "Overview":
      "Oversigt",
    "Backups":
      "Backups",
    "Storage":
      "Lager",
    "Settings":
      "Indstillinger",
    "Current status: %@":
      "Aktuel status: %@",
    "Does not point to CloudMachine":
      "Peger ikke på CloudMachine",
    "tmutil did not answer":
      "tmutil svarede ikke",
    "Backing up: %@ of %@":
      "Tager backup: %@ af %@",
    "%@ of %@":
      "%@ af %@",
    "Copied":
      "Kopieret",
    "No backup is running":
      "Ingen backup kører",
    "Time Machine starts the next one on its own schedule.":
      "Time Machine starter den næste efter sin egen tidsplan.",
    "Backup cycle":
      "Backupcyklus",
    "%@ GiB":
      "%@ GiB",
    "%@ GiB in %@ bands, %@ uploading":
      "%@ GiB i %@ bånd, %@ uploades",
    "%@ bands":
      "%@ bånd",
    "%@ fragments abandoned - only in the machine":
      "%@ opgivne fragmenter - kun i maskinen",
    "127.0.0.1:5572 answers on the Mac: Lima forwards the machine's rclone remote control, which has no password. Any web page open in a browser can send it commands - including deleting the backup on Google Drive. Add the portForwards rule from vm/cmsmb.yaml to the machine and restart it (see vm/README.md).":
      "127.0.0.1:5572 svarer på Mac'en: Lima videresender maskinens fjernstyring af rclone, som ikke har nogen adgangskode. Enhver webside, der er åben i en browser, kan sende kommandoer til den - også sletning af backuppen på Google Drive. Føj portForwards-reglen fra vm/cmsmb.yaml til maskinen, og genstart den (se vm/README.md).",
    "A service in the CloudMachine machine is not running":
      "En tjeneste i CloudMachine-maskinen kører ikke",
    "Address":
      "Adresse",
    "Agent installation INCOMPLETE - %@ of %@ did not go in:\n%@\n%@\nEvery missing agent is a function that has silently stopped working (vm-guard watches the machine's buffer, backup-health reports failures). Fix the cause and repeat the installation.":
      "Installationen af agenter er UFULDSTÆNDIG - %@ af %@ blev ikke installeret:\n%@\n%@\nHver manglende agent er en funktion, der lydløst er holdt op med at virke (vm-guard overvåger maskinens buffer, backup-health melder fejl). Ret årsagen, og gentag installationen.",
    "All running":
      "Alle kører",
    "Also install the launchd agents (same as install-launchd).":
      "Installer også launchd-agenterne (samme som install-launchd).",
    "At most this many minutes of waiting for the upload.":
      "Højst så mange minutters ventetid på upload.",
    "At the limit every new band fails with EMFILE and the backup stops. Check: cloudmachine-agent vm-status":
      "Ved grænsen mislykkes hvert nyt bånd med EMFILE, og backuppen stopper. Kontrollér: cloudmachine-agent vm-status",
    "Cache on the machine's disk":
      "Cache på maskinens disk",
    "Connected to Google Drive, but could not create the folder '%@' - without it the machine has nowhere to keep the backup. Check the account permissions and try again.":
      "Forbundet til Google Drive, men kunne ikke oprette mappen '%@' - uden den har maskinen ingen steder at gemme backuppen. Kontrollér kontoens tilladelser, og prøv igen.",
    "Convert the image":
      "Konvertér diskbilledet",
    "Converting the image to 32 MB bands":
      "Konverterer diskbilledet til bånd på 32 MB",
    "Could not check with the current connection whether the backup is on Google Drive (%@), so remote '%@' was NOT replaced: without that answer the new sign-in cannot be checked against it.":
      "Det var ikke muligt at kontrollere med den nuværende forbindelse, om backuppen findes på Google Drive (%@), så remote '%@' blev IKKE erstattet: uden det svar kan den nye login ikke kontrolleres mod den.",
    "Downloads the official rclone binary into ~/.cloudmachine/bin (Google sign-in and the machine's rclone.conf).":
      "Henter den officielle rclone-binære fil til ~/.cloudmachine/bin (Google-login og maskinens rclone.conf).",
    "Free in the machine":
      "Ledig plads i maskinen",
    "Free in the machine: %@":
      "Ledig plads i maskinen: %@",
    "Generates and installs the launchd agents (app, backup watchdog, machine start, machine guard).":
      "Opretter og installerer launchd-agenterne (appen, backup-vagthunden, maskinstart, maskinens vagt).",
    "Install Lima, which runs the CloudMachine machine: run this in Terminal":
      "Installer Lima, som kører CloudMachine-maskinen: kør dette i Terminal",
    "Install rclone (signs in to Google Drive for the machine)":
      "Installer rclone (logger maskinen ind på Google Drive)",
    "Install the background agents (machine start, buffer guard, backup watchdog)":
      "Installer baggrundsagenterne (maskinstart, buffervagt, backup-vagthund)",
    "Installs rclone through Homebrew - CloudMachine itself uses the one from install-rclone.":
      "Installerer rclone via Homebrew - CloudMachine selv bruger den, der kommer fra install-rclone.",
    "Info.plist, token and mapped/ of the backup image exist only on the machine's disk; without them the bands in %@ cannot be restored. The copy (tm-meta-sync, every 15 min) goes to %@. Check: cloudmachine-agent vm-status, then in the machine: journalctl -u tm-meta-sync":
      "Info.plist, token og mapped/ fra backup-diskbilledet findes kun på maskinens disk; uden dem kan båndene i %@ ikke gendannes. Kopien (tm-meta-sync, hvert 15. minut) lægges i %@. Kontrollér: cloudmachine-agent vm-status, og derefter i maskinen: journalctl -u tm-meta-sync",
    "Lima says the machine is running, but a command in it did not return. Without it nothing is known about Samba, rclone or the upload. Check: cloudmachine-agent vm-status":
      "Lima siger, at maskinen kører, men en kommando i den vendte ikke tilbage. Uden den ved man intet om Samba, rclone eller upload. Kontrollér: cloudmachine-agent vm-status",
    "Machine":
      "Maskine",
    "Machine %@":
      "Maskine %@",
    "Machine & Upload Status":
      "Status for maskine og upload",
    "Machine buffer":
      "Maskinens buffer",
    "No Time Machine destination is the machine's share (smb://tm@<address>/CloudMachine) - backups are not being made there. The command is printed by: cloudmachine-agent vm-setup":
      "Ingen Time Machine-destination er maskinens deling (smb://tm@<adresse>/CloudMachine) - der bliver ikke lavet backups dér. Kommandoen udskrives af: cloudmachine-agent vm-setup",
    "Not running: %@":
      "Kører ikke: %@",
    "Not set up":
      "Ikke konfigureret",
    "Once it runs out, rclone stops uploading, the machine's buffer fills up and backups stop being made. At a growth of ~600 MB per hourly cycle that is about %@ days.":
      "Når den er opbrugt, holder rclone op med at uploade, maskinens buffer fyldes, og der bliver ikke lavet flere backups. Ved en vækst på ca. 600 MB pr. timecyklus er det omkring %@ dage.",
    "Or rclone.conf is missing: this Mac has already set up the CloudMachine machine, so it is not connected anew blindly. Restore the file from a backup (the machine keeps its own copy in %@). To connect anyway, create an empty file at the path `%@ config file` prints and run again - the existing folder is kept.":
      "Eller også mangler rclone.conf: denne Mac har allerede konfigureret CloudMachine-maskinen, så den tilsluttes ikke påny i blinde. Gendan filen fra en backup (maskinen har sin egen kopi i %@). For alligevel at tilslutte skal du oprette en tom fil på den sti, som `%@ config file` udskriver, og køre igen - den eksisterende mappe bevares.",
    "Point Time Machine at the machine: run this in Terminal (needs sudo; Copy includes the password)":
      "Peg Time Machine på maskinen: kør dette i Terminal (kræver sudo; Kopiér medtager adgangskoden)",
    "Points to the machine":
      "Peger på maskinen",
    "Prepares for a restart: stops the backup, waits a while for the upload, then stops the machine cleanly.":
      "Forbereder en genstart: stopper backuppen, venter et stykke tid på upload og stopper derefter maskinen rent.",
    "Reading the Time Machine destination did not return within %@ s. That is how tmutil behaves when its destination hangs.":
      "Aflæsning af Time Machine-destinationen vendte ikke tilbage inden for %@ s. Sådan opfører tmutil sig, når dens destination hænger.",
    "Remote '%@' was NOT replaced. The new sign-in gets the 'drive.file' scope, which sees only files created under its own client_id. The existing backup was most likely created by the current connection and would become invisible to it. Before anything is written, the new token is checked against the existing backup, and the replacement is abandoned if it cannot see it. The machine keeps its own copy of the configuration until vm-setup --replace-rclone-config. To go ahead, run again with --replace-existing --accept-scope-change.":
      "Remote '%@' blev IKKE erstattet. Det nye login får omfanget 'drive.file', som kun kan se filer oprettet under sit eget client_id. Den eksisterende backup blev højst sandsynligt oprettet af den nuværende forbindelse og ville blive usynlig for den. Før noget skrives, kontrolleres det nye token mod den eksisterende backup, og udskiftningen opgives, hvis det ikke kan se den. Maskinen beholder sin egen kopi af konfigurationen indtil vm-setup --replace-rclone-config. For at fortsætte skal du køre igen med --replace-existing --accept-scope-change.",
    "Remote control:   OPEN on the Mac at 127.0.0.1:5572 - any web page can send rclone commands; see vm/README.md (portForwards)":
      "Fjernstyring:      ÅBEN på Mac'en på 127.0.0.1:5572 - enhver webside kan sende rclone-kommandoer; se vm/README.md (portForwards)",
    "Running":
      "Kører",
    "Samba, rclone or punchfs in the machine is not active, so Time Machine has nowhere to write or the bands do not reach Google Drive. Check: cloudmachine-agent vm-status":
      "Samba, rclone eller punchfs i maskinen er ikke aktiv, så Time Machine har ingen steder at skrive, eller båndene når ikke frem til Google Drive. Kontrollér: cloudmachine-agent vm-status",
    "Service %@":
      "Tjeneste %@",
    "Services":
      "Tjenester",
    "Set up the CloudMachine machine (the first time it downloads Ubuntu - several minutes)":
      "Konfigurer CloudMachine-maskinen (første gang hentes Ubuntu - det tager flere minutter)",
    "Set up the CloudMachine machine again, so it prints the Time Machine command":
      "Konfigurer CloudMachine-maskinen igen, så den udskriver Time Machine-kommandoen",
    "Set up the machine":
      "Konfigurer maskinen",
    "Setting up the CloudMachine machine":
      "Konfigurerer CloudMachine-maskinen",
    "Start the CloudMachine machine":
      "Start CloudMachine-maskinen",
    "Start the machine":
      "Start maskinen",
    "Starting the CloudMachine machine":
      "Starter CloudMachine-maskinen",
    "Still to upload: %@ GiB":
      "Mangler at uploade: %@ GiB",
    "Stopping the Time Machine backup...":
      "Stopper Time Machine-backuppen...",
    "Stopping the machine %@...":
      "Stopper maskinen %@...",
    "The CloudMachine machine does not answer":
      "CloudMachine-maskinen svarer ikke",
    "The CloudMachine machine is not running":
      "CloudMachine-maskinen kører ikke",
    "The CloudMachine machine is not set up yet":
      "CloudMachine-maskinen er endnu ikke konfigureret",
    "The CloudMachine machine is stopped":
      "CloudMachine-maskinen er stoppet",
    "The backup is stopped, the upload gets up to 30 minutes, then the machine shuts down cleanly. It starts again at the next login.":
      "Backuppen stoppes, upload får op til 30 minutter, og derefter lukker maskinen rent ned. Den starter igen ved næste login.",
    "The machine %@ is not running - nothing to prepare.":
      "Maskinen %@ kører ikke - der er intet at forberede.",
    "The machine is stopped and everything reached Google Drive. The Mac can be restarted; the machine starts again at login.":
      "Maskinen er stoppet, og alt nåede frem til Google Drive. Mac'en kan genstartes; maskinen starter igen ved login.",
    "The machine is stopped. %@ GiB had not reached Google Drive yet - it is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "Maskinen er stoppet. %@ GiB var endnu ikke nået frem til Google Drive - de ligger i maskinens buffer og uploades efter næste start. Mac'en kan genstartes.",
    "The machine is stopped. rclone did not say how much was still to upload; what was not uploaded is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "Maskinen er stoppet. rclone oplyste ikke, hvor meget der manglede at blive uploadet; det, der ikke blev uploadet, ligger i maskinens buffer og uploades efter næste start. Mac'en kan genstartes.",
    "The machine's disk is a file on this disk and grows as the upload buffer fills. With no space left the machine cannot write the buffer, and Time Machine's local snapshots have nowhere to go either.":
      "Maskinens disk er en fil på denne disk og vokser, efterhånden som uploadbufferen fyldes. Uden ledig plads kan maskinen ikke skrive bufferen, og Time Machines lokale snapshots har heller ingen steder at gå hen.",
    "The image's metadata has never been copied to Drive":
      "Diskbilledets metadata er aldrig blevet kopieret til Drive",
    "The image's metadata was last copied to Drive %@ ago":
      "Diskbilledets metadata blev sidst kopieret til Drive for %@ siden",
    "The machine's disk is running out of space (%@ GB)":
      "Maskinens disk er ved at løbe tør for plads (%@ GB)",
    "The new sign-in does NOT see the existing backup (%@), so remote '%@' was NOT replaced and rclone.conf is unchanged. Keep the current connection, or sign in with the credential (client_id) that created the backup.":
      "Det nye login kan IKKE se den eksisterende backup (%@), så remote '%@' blev IKKE erstattet, og rclone.conf er uændret. Behold den nuværende forbindelse, eller log ind med den legitimation (client_id), der oprettede backuppen.",
    "The upload buffer lives on this disk. The guard pauses Time Machine before it fills; if the upload does not catch up, backups stay paused.":
      "Uploadbufferen ligger på denne disk. Vagten sætter Time Machine på pause, før den fyldes; hvis upload ikke indhenter det, forbliver backups sat på pause.",
    "These bands exist only in the machine's buffer. The backup on Google Drive is INCOMPLETE and may not open.":
      "Disse bånd findes kun i maskinens buffer. Backuppen på Google Drive er UFULDSTÆNDIG og kan muligvis ikke åbnes.",
    "Time Machine backs up to the machine, so without it no backup is made. Start it: limactl start %@ (or the Start button in the app).":
      "Time Machine tager backup til maskinen, så uden den bliver der ikke lavet nogen backup. Start den: limactl start %@ (eller knappen Start i appen).",
    "Time Machine did not stop its backup within 2 minutes (or tmutil did not answer) - the machine was NOT stopped. Try again in a moment.":
      "Time Machine stoppede ikke sin backup inden for 2 minutter (eller tmutil svarede ikke) - maskinen blev IKKE stoppet. Prøv igen om et øjeblik.",
    "Time Machine has created its image: stop the backup, then convert the image to 32 MB bands":
      "Time Machine har oprettet sit diskbillede: stop backuppen, og konvertér derefter diskbilledet til bånd på 32 MB",
    "To upload":
      "Skal uploades",
    "Unknown whether the CloudMachine machine is running":
      "Det er ukendt, om CloudMachine-maskinen kører",
    "Waiting for the upload to Google Drive (at most %@ min)...":
      "Venter på upload til Google Drive (højst %@ min.)...",
    "With --replace-existing: confirms that the new sign-in (scope 'drive.file') may not see the existing backup. The new token is still checked against the backup first.":
      "Med --replace-existing: bekræfter, at det nye login (omfanget 'drive.file') muligvis ikke kan se den eksisterende backup. Det nye token kontrolleres stadig først mod backuppen.",
    "Without it there is no way to check whether anything reached the Drive - the machine's guard is blind then.":
      "Uden den er der ingen måde at kontrollere, om noget nåede frem til Drive - maskinens vagt er så blind.",
    "limactl did not answer":
      "limactl svarede ikke",
    "limactl did not answer (or is not installed). That does not mean the machine is down - it means nobody has checked.":
      "limactl svarede ikke (eller er ikke installeret). Det betyder ikke, at maskinen er nede - det betyder, at ingen har kontrolleret det.",
    "limactl start failed: %@":
      "limactl start mislykkedes: %@",
    "limactl stop failed: %@":
      "limactl stop mislykkedes: %@",
    "punchfs is close to its open-file limit":
      "punchfs nærmer sig grænsen for åbne filer",
    "punchfs open files":
      "Åbne filer i punchfs",
    "rclone's remote control is open on this Mac":
      "rclones fjernstyring er åben på denne Mac",
    "statfs('/System/Volumes/Data') returned an error, so nobody knows whether the machine's disk can still grow on this Mac.":
      "statfs('/System/Volumes/Data') returnerede en fejl, så ingen ved, om maskinens disk stadig kan vokse på denne Mac.",
    "Google Drive's daily upload limit stops the upload":
      "Googles daglige uploadgrænse stopper upload",
    "Google last refused an upload %@ ago (750 GB a day). Backups since then are only in the machine's buffer on this Mac. rclone retries every 5 min and resumes by itself when the limit passes; the guard pauses Time Machine if more than %@ GiB waits.":
      "Google afviste sidst en upload for %@ siden (750 GB om dagen). Backups siden da ligger kun i maskinens buffer på denne Mac. rclone forsøger igen hvert 5. minut og genoptager af sig selv, når grænsen er overstået; vagten sætter Time Machine på pause, hvis mere end %@ GiB venter.",
    "Usage on Google Drive is not being measured":
      "Forbruget på Google Drive måles ikke",
    "The last measurement (%@ GB) is from %@, %@ ago - rclone size has not answered since. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "Den seneste måling (%@ GB) er fra %@, for %@ siden - rclone size har ikke svaret siden. Indtil det gør, er der ingen, der overvåger grænsen på %@ GB: alarmerne ved 90%% og 100%% forbliver tavse. Tjek vm-status, eller tryk på Mål nu i vinduet.",
    "rclone size has not answered even once. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "rclone size har ikke svaret en eneste gang. Indtil det gør, er der ingen, der overvåger grænsen på %@ GB: alarmerne ved 90%% og 100%% forbliver tavse. Tjek vm-status, eller tryk på Mål nu i vinduet.",
    "Saved in the Keychain. Connecting Google Drive (configure-remote) will use them.":
      "Gemt i nøgleringen. Tilslutning af Google Drive (configure-remote) bruger dem.",
    "Saved in the Keychain. The existing Google Drive connection keeps its old client_id, and on this Mac it should stay that way: a connection made with the new keys (the 'drive.file' scope) cannot see the backup created by the old one. Do not replace the connection here; the new keys are for a Mac that is not connected yet.":
      "Gemt i nøgleringen. Den eksisterende Google Drive-forbindelse beholder sit gamle client_id, og på denne Mac bør det forblive sådan: en forbindelse oprettet med de nye nøgler (omfanget 'drive.file') kan ikke se den backup, som den gamle oprettede. Udskift ikke forbindelsen her; de nye nøgler er til en Mac, der endnu ikke er tilsluttet.",
    "it is not there for the new token":
      "den findes ikke for det nye token",
    "Cancel":
      "Annuller",
    "ACTION NEEDED":
      "HANDLING PÅKRÆVET",
    "WILL PASS BY ITSELF — DO NOTHING":
      "GÅR OVER AF SIG SELV — GØR INTET",
    "UNKNOWN — CHECK AGAIN SHORTLY":
      "UKENDT — TJEK IGEN OM LIDT",
    "ALL GOOD":
      "ALT ER I ORDEN",
    "Upload is not working":
      "Upload virker ikke",
    "Upload stopped — no space left on Google Drive":
      "Upload stoppet — ingen ledig plads på Google Drive",
    "%@ backup fragments not uploaded":
      "%@ backupfragmenter er ikke uploadet",
    "Upload cannot keep up with writes":
      "Upload kan ikke følge med skrivningerne",
    "Upload paused — Google daily limit":
      "Upload sat på pause — Googles daglige grænse",
    "Uploading to Google Drive — %@ queued":
      "Uploader til Google Drive — %@ i kø",
    "Everything uploaded to Google Drive":
      "Alt er uploadet til Google Drive",
    "Unknown what is waiting in the queue":
      "Det er ukendt, hvad der venter i køen",
    "There is no connection to Google Drive, so backups are only made on this Mac. If this does not pass by itself within a few minutes, check the network and the connection to Drive.":
      "Der er ingen forbindelse til Google Drive, så backups laves kun på denne Mac. Hvis det ikke går over af sig selv inden for få minutter, skal du kontrollere netværket og forbindelsen til Drive.",
    "There is no space left on Google Drive. This will NOT pass by itself — you need to free up space on Drive. Until then Time Machine is paused, so that it does not fill up this Mac's disk.":
      "Der er ingen ledig plads på Google Drive. Det går IKKE over af sig selv — du skal frigøre plads på Drive. Indtil da er Time Machine sat på pause, så den ikke fylder denne Macs disk.",
    "%@ backup fragments could not be uploaded and rclone stopped trying. These fragments exist only on this Mac, so the backup on Drive is incomplete. This needs checking.":
      "%@ backupfragmenter kunne ikke uploades, og rclone er holdt op med at prøve. Disse fragmenter findes kun på denne Mac, så backuppen på Drive er ufuldstændig. Det skal undersøges.",
    "Time Machine is writing faster than the upload goes, and the buffer has filled up. The backup will be paused until the upload catches up — this is a safeguard against filling up the disk, not a failure.":
      "Time Machine skriver hurtigere, end upload går, og bufferen er fyldt op. Backuppen sættes på pause, indtil upload har indhentet det — det er en sikring mod at fylde disken, ikke en fejl.",
    "Google accepts 750 GB per day and that limit has been used up. There is nothing to do: the limit renews by itself, usually within a few hours. Time Machine backups are made normally in the meantime and wait in the buffer — they will be uploaded as soon as Google starts accepting again.":
      "Google accepterer 750 GB om dagen, og den grænse er brugt op. Der er intet at gøre: grænsen nulstilles af sig selv, som regel inden for få timer. Time Machine-backups laves normalt i mellemtiden og venter i bufferen — de uploades, så snart Google igen modtager data.",
    "%@ backup fragments are queued and on their way to Drive.":
      "%@ backupfragmenter er i kø og på vej til Drive.",
    "Nothing is waiting in the queue — the backup on Google Drive is complete.":
      "Intet venter i køen — backuppen på Google Drive er komplet.",
    "rclone did not answer the question about the queue, so it is unknown how many backups are still waiting to be uploaded. This does not mean something broke — under load the answer can be late. It only means that right now nobody knows. If it persists, the backup cycle check will report it.":
      "rclone svarede ikke på spørgsmålet om køen, så det er ukendt, hvor mange backups der stadig venter på at blive uploadet. Det betyder ikke, at noget er gået i stykker — under belastning kan svaret komme for sent. Det betyder blot, at ingen ved det lige nu. Hvis det fortsætter, melder kontrollen af backupcyklussen det.",
    "unknown error":
      "ukendt fejl",
    "rclone lsf ended with an error":
      "rclone lsf sluttede med en fejl",
    "This Mac is close to its space limit on Google Drive":
      "Denne Mac nærmer sig sin pladsgrænse på Google Drive",
    "%@ GB of %@ GB used. Time Machine deletes the oldest backups to stay within its quota; check that the quota is set (vm-status).":
      "%@ GB af %@ GB brugt. Time Machine sletter de ældste backups for at holde sig inden for sin kvote; kontrollér, at kvoten er indstillet (vm-status).",
    "This Mac is over its space limit on Google Drive":
      "Denne Mac har overskredet sin pladsgrænse på Google Drive",
    "%@ GB of %@ GB used. Set the Time Machine quota (command in the app window or vm-status), or raise the limit.":
      "%@ GB af %@ GB brugt. Indstil Time Machine-kvoten (kommandoen i appens vindue eller vm-status), eller hæv grænsen.",
    "not set":
      "ikke angivet",
    "%@ GB - usage not measured yet":
      "%@ GB - forbruget er endnu ikke målt",
    "%@ of %@ GB used (%@%%)":
      "%@ af %@ GB brugt (%@%%)",
    "The limit must be a whole number of GB above zero.":
      "Grænsen skal være et helt tal i GB over nul.",
    "machines.json cannot be read, so it was not overwritten. Fix or remove it first.":
      "machines.json kan ikke læses, så den blev ikke overskrevet. Ret eller fjern den først.",
    "'%@' is not a valid folder name: use lowercase letters, digits and dashes.":
      "'%@' er ikke et gyldigt mappenavn: brug små bogstaver, cifre og bindestreger.",
    "This Mac already backs up to folder '%@'. Switching to '%@' would start a new, empty backup and orphan the existing one, so nothing was changed.":
      "Denne Mac tager allerede backup til mappen '%@'. Et skift til '%@' ville starte en ny, tom backup og efterlade den eksisterende forladt, så intet blev ændret.",
    "This Mac already has a CloudMachine installation, whose backup is in folder '%@'. Switching to '%@' would orphan it, so nothing was changed.":
      "Denne Mac har allerede en CloudMachine-installation, hvis backup ligger i mappen '%@'. Et skift til '%@' ville efterlade den forladt, så intet blev ændret.",
    "Could not save the folder name to %@: %@":
      "Kunne ikke gemme mappenavnet i %@: %@",
    "Homebrew is not installed. Install it manually: https://brew.sh":
      "Homebrew er ikke installeret. Installer det manuelt: https://brew.sh",
    "Installing rclone failed: %@":
      "Installation af rclone mislykkedes: %@",
    "Installed rclone.":
      "rclone er installeret.",
    "Own Google credentials: set.":
      "Egne Google-legitimationsoplysninger: angivet.",
    "INCOMPLETE: %@ is missing - rclone will use rclone's shared client_id anyway.":
      "UFULDSTÆNDIGT: %@ mangler - rclone bruger alligevel rclones delte client_id.",
    "No own credentials - rclone uses the shared client_id, rate-limited jointly and being retired in 2026.":
      "Ingen egne legitimationsoplysninger - rclone bruger det delte client_id, som har fælles hastighedsbegrænsning og udfases i 2026.",
    "Empty value - not saving.":
      "Tom værdi - gemmer ikke.",
    "Keychain refused: %@":
      "Nøgleringen afviste: %@",
    "DIRTY-TREE":
      "SNAVSET-TRÆ",
    "Cannot create the working directory: %@":
      "Kan ikke oprette arbejdsmappen: %@",
    "Could not read the rclone version number.":
      "Kunne ikke læse rclones versionsnummer.",
    "Could not download %@.":
      "Kunne ikke hente %@.",
    "No entry for %@ in SHA256SUMS.":
      "Ingen post for %@ i SHA256SUMS.",
    "Could not compute the checksum.":
      "Kunne ikke beregne kontrolsummen.",
    "SHA256 checksum does not match - NOT installing.\n  expected: %@\n  computed: %@":
      "SHA256-kontrolsummen stemmer ikke - installerer IKKE.\n  forventet: %@\n  beregnet: %@",
    "Could not unpack the archive.":
      "Kunne ikke udpakke arkivet.",
    "Could not install the binary: %@":
      "Kunne ikke installere den binære fil: %@",
    "Installed rclone %@ in %@ (SHA256 checksum matches).":
      "rclone %@ er installeret i %@ (SHA256-kontrolsummen stemmer).",
    "%@ did not respond within the allotted time (the process was left orphaned in the background).":
      "%@ svarede ikke inden for den tilladte tid (processen blev efterladt som forældreløs i baggrunden).",
    "Cannot launch %@: %@":
      "Kan ikke starte %@: %@",
    "Remote '%@' already exists and was NOT touched.\nOverwriting it replaces the token and the permission scope; a credential with the 'drive.file' scope does not see files created by the previous one, so the existing backup becomes unreachable.\nIf you really want to replace it, first back up ~/.config/rclone/rclone.conf and run again with --replace-existing.":
      "Remote '%@' findes allerede og blev IKKE rørt.\nHvis den overskrives, erstattes token og tilladelsesomfang; en legitimation med omfanget 'drive.file' kan ikke se filer oprettet af den forrige, så den eksisterende backup bliver utilgængelig.\nHvis du virkelig vil erstatte den, så tag først en backup af ~/.config/rclone/rclone.conf og kør igen med --replace-existing.",
    "Could not check whether remote '%@' already exists (rclone listremotes did not answer or failed), so nothing was changed. Run `%@ listremotes` to see the error, then try again.":
      "Kunne ikke kontrollere, om remote '%@' allerede findes (rclone listremotes svarede ikke eller mislykkedes), så intet blev ændret. Kør `%@ listremotes` for at se fejlen, og prøv derefter igen.",
    "Could not check whether this Mac already has a CloudMachine installation (rclone did not answer), so no folder was chosen. Try again in a moment.":
      "Kunne ikke kontrollere, om denne Mac allerede har en CloudMachine-installation (rclone svarede ikke), så der blev ikke valgt nogen mappe. Prøv igen om et øjeblik.",
    "rclone authorize failed (%@). If that binary is missing, start with: cloudmachine-agent install-rclone.":
      "rclone authorize mislykkedes (%@). Hvis den binære fil mangler, så start med: cloudmachine-agent install-rclone.",
    "Could not read the token from the output of rclone authorize.":
      "Kunne ikke læse tokenet fra outputtet fra rclone authorize.",
    "rclone config create failed.":
      "rclone config create mislykkedes.",
    "Connected to Google Drive as remote '%@', folder %@.":
      "Tilsluttet Google Drive som remote '%@', mappe %@.",
    "tmutil is not responding - unknown where the backup goes":
      "tmutil svarer ikke - det er ukendt, hvor backuppen havner",
    "No successful backup for %@":
      "Ingen vellykket backup i %@",
    "Last COMPLETED backup: %@. The cycle is hourly, so that is %@ missed runs.":
      "Sidste GENNEMFØRTE backup: %@. Cyklussen er time-baseret, så det er %@ oversprungne kørsler.",
    "There is NOT A SINGLE successful backup":
      "Der er INGEN ENESTE vellykket backup",
    "The Time Machine preferences contain no date of a completed backup for this destination.":
      "Time Machine-præferencerne indeholder ingen dato for en gennemført backup til denne destination.",
    "The last backup attempt did not end in a backup":
      "Det sidste backupforsøg endte ikke i en backup",
    "The attempt at %@ is newer than the last successful backup at %@.":
      "Forsøget kl. %@ er nyere end den sidste vellykkede backup kl. %@.",
    "Time Machine reports an error in the last run (RESULT=%@)":
      "Time Machine melder en fejl i den sidste kørsel (RESULT=%@)",
    "A non-zero RESULT in the Time Machine preferences means the run did not succeed.":
      "Et RESULT forskelligt fra nul i Time Machine-præferencerne betyder, at kørslen ikke lykkedes.",
    "rclone failed to upload %@ files":
      "rclone kunne ikke uploade %@ filer",
    "Buffer full of nothing but unsent data":
      "Bufferen er fuld af ikke-sendte data",
    "rclone has nothing left to evict from the buffer - the upload cannot keep up or has stalled.":
      "rclone har intet tilbage at fjerne fra bufferen - upload kan ikke følge med eller er gået i stå.",
    "The rclone control interface is not responding":
      "rclones kontrolgrænseflade svarer ikke",
    "Google Drive is running out of space (%@ GB)":
      "Google Drive er ved at løbe tør for plads (%@ GB)",
    "The Mac's disk is running out of space (%@ GB)":
      "Mac'ens disk er ved at løbe tør for plads (%@ GB)",
    "Cannot read the Time Machine preferences":
      "Kan ikke læse Time Machine-præferencerne",
    "%@ is unreadable - most often Full Disk Access is missing. Without this file it is UNKNOWN when the last backup was made, so we treat it as a failure, not as the absence of a problem.":
      "%@ kan ikke læses - oftest mangler Fuld diskadgang. Uden denne fil er det UKENDT, hvornår den sidste backup blev lavet, så vi behandler det som en fejl og ikke som fravær af et problem.",
    "Cannot measure free space on the Mac's disk":
      "Kan ikke måle ledig plads på Mac'ens disk",
    "%@ days":
      "%@ dage",
    "CloudMachine: backup is not working":
      "CloudMachine: backup virker ikke",
    "unknown reason":
      "ukendt årsag",
    "osascript did not show the notification (permissions or no graphical session)":
      "osascript viste ikke notifikationen (tilladelser eller ingen grafisk session)",
    "UNDELIVERED ALARM: %@":
      "UDELEVERET ALARM: %@",
    "from %@, reason: %@":
      "fra %@, årsag: %@",
    "The system notification was not delivered - you will see this alarm ONLY here.":
      "Systemnotifikationen blev ikke leveret - du ser denne alarm KUN her.",
    "%@ (%@ ago)":
      "%@ (%@ siden)",
    "%@ - marker from the FUTURE":
      "%@ - markør fra FREMTIDEN",
    "%@ (%@ ago) - THE WATCHDOG MAY NOT BE RUNNING":
      "%@ (%@ siden) - VAGTHUNDEN KØRER MULIGVIS IKKE",
    "NEVER - the watchdog has not recorded a single run":
      "ALDRIG - vagthunden har ikke registreret en eneste kørsel",
    "Could not find the launchd/ directory with templates.":
      "Kunne ikke finde mappen launchd/ med skabeloner.",
    "Could not find the compiled cloudmachine-agent binary.":
      "Kunne ikke finde den kompilerede binære fil cloudmachine-agent.",
    "ABORTED: could not put cloudmachine-agent in a stable location\n(%@) - most often a lack of space or permissions.\nNOT installing agents pointing at %@: that path\ndisappears on the next `swift build` or `git clean`, and backups stop\nwithout any visible signal.":
      "AFBRUDT: kunne ikke placere cloudmachine-agent et stabilt sted\n(%@) - oftest mangel på plads eller tilladelser.\nInstallerer IKKE agenter, der peger på %@: den sti\nforsvinder ved næste `swift build` eller `git clean`, og backups stopper\nuden noget synligt signal.",
    "ABORTED: %@":
      "AFBRUDT: %@",
    "Could not list the templates in %@.":
      "Kunne ikke vise skabelonerne i %@.",
    "could not read the template %@":
      "kunne ikke læse skabelonen %@",
    "could not write %@ (lack of space or permissions)":
      "kunne ikke skrive %@ (mangel på plads eller tilladelser)",
    "launchctl load refused to load %@":
      "launchctl load nægtede at indlæse %@",
    "NOT A SINGLE agent was loaded.":
      "INGEN ENESTE agent blev indlæst.",
    "Only these went in: %@.":
      "Kun disse blev installeret: %@.",
    "Could not load any launchd agent.":
      "Kunne ikke indlæse nogen launchd-agent.",
    "Installed agents: %@":
      "Installerede agenter: %@",
    "                  WARNING: close to the limit - new bands will fail with EMFILE":
      "                  ADVARSEL: tæt på grænsen - nye bånd mislykkes med EMFILE",
    "%@/bands on Google Drive is not empty - it may hold another backup. NOT overwriting it; check it by hand.":
      "%@/bands på Google Drive er ikke tom - den kan indeholde en anden backup. Overskriver den IKKE; kontrollér den manuelt.",
    "Address:          %@":
      "Adresse:          %@",
    "Already prepared (%@ exists) - nothing to do.":
      "Allerede forberedt (%@ findes) - der er intet at gøre.",
    "Converts Time Machine's new, empty image in the machine to 32 MB bands and moves the bands to Google Drive.":
      "Konverterer Time Machines nye, tomme diskbillede i maskinen til bånd på 32 MB og flytter båndene til Google Drive.",
    "Copy rclone.conf into the machine even if it already has one.":
      "Kopiér rclone.conf ind i maskinen, selv om den allerede har en.",
    "Copying the converted image into the machine failed: %@":
      "Kopiering af det konverterede diskbillede ind i maskinen mislykkedes: %@",
    "Copying the image to the Mac failed: %@":
      "Kopiering af diskbilledet til Mac'en mislykkedes: %@",
    "Could not ask Lima about the machine: %@":
      "Kunne ikke spørge Lima om maskinen: %@",
    "Could not carry the Time Machine files over: %@":
      "Kunne ikke overføre Time Machine-filerne: %@",
    "Could not check the image in the machine.":
      "Kunne ikke kontrollere diskbilledet i maskinen.",
    "Could not copy the rclone configuration into the machine.":
      "Kunne ikke kopiere rclone-konfigurationen ind i maskinen.",
    "Could not create %@ on Google Drive: %@":
      "Kunne ikke oprette %@ på Google Drive: %@",
    "Could not create %@: %@":
      "Kunne ikke oprette %@: %@",
    "Could not find the vm/ directory with the machine template.":
      "Kunne ikke finde mappen vm/ med maskinens skabelon.",
    "Could not read the image size.":
      "Kunne ikke læse diskbilledets størrelse.",
    "Could not set the SMB password of user %@ in the machine.":
      "Kunne ikke angive SMB-adgangskoden for brugeren %@ i maskinen.",
    "Could not stop smbd in the machine.":
      "Kunne ikke stoppe smbd i maskinen.",
    "Could not write %@ in the machine.":
      "Kunne ikke skrive %@ i maskinen.",
    "Could not write the password file %@.":
      "Kunne ikke skrive adgangskodefilen %@.",
    "Creates or starts the CloudMachine machine (Lima), gives it rclone's configuration and an SMB password, and prints the Time Machine command.":
      "Opretter eller starter CloudMachine-maskinen (Lima), giver den rclones konfiguration og en SMB-adgangskode og udskriver Time Machine-kommandoen.",
    "Creating the machine %@ (first start downloads Ubuntu and installs packages - several minutes)...":
      "Opretter maskinen %@ (første start henter Ubuntu og installerer pakker - det tager flere minutter)...",
    "Done: %@ has %@ MB bands on Google Drive; the original is kept in %@ in the machine. Start the backup: tmutil startbackup":
      "Færdig: %@ har bånd på %@ MB på Google Drive; originalen opbevares i %@ i maskinen. Start backuppen: tmutil startbackup",
    "exit code %@, no message":
      "afslutningskode %@, ingen meddelelse",
    "Image metadata:   NEVER copied to %@ - check tm-meta-sync in the machine":
      "Diskbilledmetadata: ALDRIG kopieret til %@ - tjek tm-meta-sync i maskinen",
    "Image metadata:   copied %@ ago to %@":
      "Diskbilledmetadata: kopieret for %@ siden til %@",
    "Image metadata:   last copied %@ ago - OVERDUE (%@)":
      "Diskbilledmetadata: sidst kopieret for %@ siden - FORSINKET (%@)",
    "Image metadata:   not copied yet - waits for vm-prepare-bundle":
      "Diskbilledmetadata: endnu ikke kopieret - venter på vm-prepare-bundle",
    "Backup %@, paused by the guard %@: %@":
      "Backup %@, sat på pause af vagten %@: %@",
    "Free in machine:  %@ GiB":
      "Ledig i maskinen: %@ GiB",
    "fsck_apfs -n found problems: %@":
      "fsck_apfs -n fandt problemer: %@",
    "Google Drive folder: %@":
      "Google Drive-mappe: %@",
    "hdiutil attach of the converted image failed: %@":
      "hdiutil attach af det konverterede diskbillede mislykkedes: %@",
    "hdiutil convert failed: %@":
      "hdiutil convert mislykkedes: %@",
    "Image name in the machine (default: from the computer name).":
      "Diskbilledets navn i maskinen (standard: afledt af computerens navn).",
    "Installing the converted image FAILED: %@\nsmbd is left STOPPED so Time Machine does not open a half-installed image. The original is in %@ in the machine.":
      "Installation af det konverterede diskbillede MISLYKKEDES: %@\nsmbd er efterladt STOPPET, så Time Machine ikke åbner et halvt installeret diskbillede. Originalen ligger i %@ i maskinen.",
    "limactl create failed: %@":
      "limactl create mislykkedes: %@",
    "limactl list failed: %@":
      "limactl list mislykkedes: %@",
    "limactl not found - install Lima: brew install lima":
      "limactl blev ikke fundet - installer Lima: brew install lima",
    "limactl start failed: %@\nThe machine's own log: %@":
      "limactl start mislykkedes: %@\nMaskinens egen log: %@",
    "Machine %@ is running.":
      "Maskinen %@ kører.",
    "Machine %@ was already running.":
      "Maskinen %@ kørte allerede.",
    "Machine:          %@ (%@)":
      "Maskine:          %@ (%@)",
    "Machine:          %@":
      "Maskine:          %@",
    "Machine:          not created - run: cloudmachine-agent vm-setup":
      "Maskine:          ikke oprettet - kør: cloudmachine-agent vm-setup",
    "no answer within the time limit":
      "intet svar inden for tidsgrænsen",
    "No image %@ in the machine.":
      "Intet diskbillede %@ i maskinen.",
    "No image in the machine yet - point Time Machine at the share and let it create one first.":
      "Endnu intet diskbillede i maskinen - peg Time Machine på delingen, og lad den først oprette et.",
    "No rclone configuration at %@ - connect Google Drive first (configure-remote).":
      "Ingen rclone-konfiguration i %@ - tilslut først Google Drive (configure-remote).",
    "no SMB destination":
      "ingen SMB-destination",
    "One check of the machine's upload buffer: pauses Time Machine when it fills, resumes what it paused.":
      "Én kontrol af maskinens uploadbuffer: sætter Time Machine på pause, når den fyldes, og genoptager det, den satte på pause.",
    "Packing the converted image failed: %@":
      "Pakning af det konverterede diskbillede mislykkedes: %@",
    "Packing the image failed: %@":
      "Pakning af diskbilledet mislykkedes: %@",
    "No answer from the machine (rclone rc) - the guard would do nothing.":
      "Intet svar fra maskinen (rclone rc) - vagten ville ikke gøre noget.",
    "Only print what the guard would decide - for trying thresholds on a throwaway machine.":
      "Udskriv kun, hvad vagten ville beslutte - til afprøvning af tærskler på en engangsmaskine.",
    "Pause above this many GiB in the buffer.":
      "Sæt på pause over så mange GiB i bufferen.",
    "Pause when the machine has less free than this, in GiB.":
      "Sæt på pause, når maskinen har mindre ledig plads end dette, i GiB.",
    "Point Time Machine at the machine (once, needs an administrator password):":
      "Peg Time Machine på maskinen (én gang, kræver en administratoradgangskode):",
    "punchfs files:    %@ open, limit %@":
      "punchfs-filer:    %@ åbne, grænse %@",
    "rclone configuration already in the machine - kept (--replace-rclone-config replaces it).":
      "rclone-konfigurationen findes allerede i maskinen - beholdt (--replace-rclone-config erstatter den).",
    "rclone configuration copied into the machine.":
      "rclone-konfigurationen er kopieret ind i maskinen.",
    "rclone-tm or punchfs is not running in the machine - see cloudmachine-agent vm-status.":
      "rclone-tm eller punchfs kører ikke i maskinen - se cloudmachine-agent vm-status.",
    "Resume below this many GiB (only a backup the guard paused).":
      "Genoptag under så mange GiB (kun en backup, som vagten satte på pause).",
    "Service %@: %@":
      "Tjeneste %@: %@",
    "Several images in the machine (%@) - choose one with --bundle.":
      "Flere diskbilleder i maskinen (%@) - vælg ét med --bundle.",
    "Shows the machine: address, services, upload buffer, free space and the Time Machine destination.":
      "Viser maskinen: adresse, tjenester, uploadbuffer, ledig plads og Time Machine-destinationen.",
    "SMB password stored in %@ (mode 600).":
      "SMB-adgangskoden er gemt i %@ (tilstand 600).",
    "The converted image does not have %@-byte bands.":
      "Det konverterede diskbillede har ikke bånd på %@ byte.",
    "The converted image has no APFS partition.":
      "Det konverterede diskbillede har ingen APFS-partition.",
    "The image already takes %@ MB - this command converts only a new, empty image (under %@ MB).":
      "Diskbilledet fylder allerede %@ MB - denne kommando konverterer kun et nyt, tomt diskbillede (under %@ MB).",
    "The image is encrypted - converting encrypted images is not supported.":
      "Diskbilledet er krypteret - konvertering af krypterede diskbilleder understøttes ikke.",
    "The image was not changed; smbd started again.":
      "Diskbilledet blev ikke ændret; smbd startede igen.",
    "The machine does not answer - is it running? cloudmachine-agent vm-status":
      "Maskinen svarer ikke - kører den? cloudmachine-agent vm-status",
    "The machine has no address on the vzNAT network.":
      "Maskinen har ingen adresse på vzNAT-netværket.",
    "The services in the machine did not start - check: cloudmachine-agent vm-status":
      "Tjenesterne i maskinen startede ikke - kontrollér: cloudmachine-agent vm-status",
    "Time Machine is backing up - stop it first: tmutil stopbackup":
      "Time Machine tager backup - stop den først: tmutil stopbackup",
    "Time Machine:     %@":
      "Time Machine:      %@",
    "Time Machine:     NOT pointing at the machine (%@)":
      "Time Machine:      PEGER IKKE på maskinen (%@)",
    "Time Machine:     tmutil did not answer":
      "Time Machine:      tmutil svarede ikke",
    "tmutil did not answer - not touching the image while its state is unknown.":
      "tmutil svarede ikke - rører ikke ved diskbilledet, mens dets tilstand er ukendt.",
    "unknown":
      "ukendt",
    "Unpacking the image failed: %@":
      "Udpakning af diskbilledet mislykkedes: %@",
    "Still to upload:  %@ GiB in %@ bands, uploading %@ (cache on disk %@ GiB)":
      "Mangler at uploade: %@ GiB i %@ bånd, uploader %@ (cache på disk %@ GiB)",
    "Excluded %@ (the machine and its upload buffer) from Time Machine.":
      "%@ (maskinen og dens uploadbuffer) er udelukket fra Time Machine.",
    "WARNING: could not exclude %@ from Time Machine - run: tmutil addexclusion %@":
      "ADVARSEL: kunne ikke udelukke %@ fra Time Machine - kør: tmutil addexclusion %@",
    "Upload buffer:    no answer from rclone (rc %@)":
      "Uploadbuffer:     intet svar fra rclone (rc %@)",
    "When Time Machine has created its empty image, stop the backup (tmutil stopbackup) and run: cloudmachine-agent vm-prepare-bundle":
      "Når Time Machine har oprettet sit tomme diskbillede, skal du stoppe backuppen (tmutil stopbackup) og køre: cloudmachine-agent vm-prepare-bundle",
    "Unsent %@ GiB, free %@ GiB (pause above %@ GiB unsent or below %@ GiB free, resume below %@ GiB).":
      "Ikke sendt %@ GiB, ledig %@ GiB (pause over %@ GiB ikke sendt eller under %@ GiB ledig, genoptag under %@ GiB).",
    "Upload:           Google's daily limit refused an upload %@ ago - rclone retries every 5 min and resumes by itself":
      "Upload:           Googles daglige grænse afviste en upload for %@ siden - rclone forsøger igen hvert 5. minut og genoptager af sig selv",
    "no":
      "nej",
    "running":
      "kører",
    "stopped":
      "stoppet",
    "yes":
      "ja",
    "%@\nThe previous template is in %@ - copy it back over lima.yaml and run limactl start %@.":
      "%@\nDen forrige skabelon ligger i %@ - kopiér den tilbage over lima.yaml, og kør limactl start %@.",
    "Could not read this app's machine template (limactl template copy).":
      "Kunne ikke læse denne apps maskinskabelon (limactl template copy).",
    "Could not replace %@: %@":
      "Kunne ikke erstatte %@: %@",
    "Machine %@ already runs this app's template.":
      "Maskinen %@ kører allerede denne apps skabelon.",
    "Machine %@ now runs this app's template; the previous one is in %@.":
      "Maskinen %@ kører nu denne apps skabelon; den forrige ligger i %@.",
    "Moves the machine onto this app's template (two restarts, never during a backup).":
      "Flytter maskinen over på denne apps skabelon (to genstarter, aldrig under en backup).",
    "No machine %@ - create it with: cloudmachine-agent vm-setup":
      "Ingen maskine %@ - opret den med: cloudmachine-agent vm-setup",
    "Template:         OLDER than this app's - run: cloudmachine-agent vm-update":
      "Skabelon:         ÆLDRE end denne apps - kør: cloudmachine-agent vm-update",
    "Template:         not compared":
      "Skabelon:         ikke sammenlignet",
    "Template:         this app's":
      "Skabelon:         denne apps",
    "The machine has no %@ - run cloudmachine-agent vm-setup first.":
      "Maskinen har ingen %@ - kør først cloudmachine-agent vm-setup.",
    "The machine restarted, but not every service is running - check: cloudmachine-agent vm-status. The previous template is in %@.":
      "Maskinen blev genstartet, men ikke alle tjenester kører - kontrollér: cloudmachine-agent vm-status. Den forrige skabelon ligger i %@.",
    "The template changes the machine itself (%@) - that needs a new machine, not an update.":
      "Skabelonen ændrer selve maskinen (%@) - det kræver en ny maskine, ikke en opdatering.",
    "The upload to Google Drive hangs":
      "Upload til Google Drive hænger",
    "Time Machine is backing up - try again when it has finished.":
      "Time Machine tager backup - prøv igen, når den er færdig.",
    "Upload:           HANGS - bands in progress, none uploaded for %@ (network?); see /var/log/rclone-tm.log in the machine":
      "Upload:           HÆNGER - bånd i gang, ingen uploadet i %@ (netværk?); se /var/log/rclone-tm.log i maskinen",
    "limactl stop failed - nothing was changed.":
      "limactl stop mislykkedes - intet blev ændret.",
    "rclone has bands in progress, but none has been uploaded for %@ - usually a broken network connection, which rclone does not report as an error. Backups since then are only in the machine's buffer. When the network comes back the upload resumes by itself (on 28.10.2026 within 80 s); if it does not, restarting the machine (prepare-shutdown, limactl start) drops the dead connections.":
      "rclone har bånd i gang, men ingen er blevet uploadet i %@ - som regel en afbrudt netværksforbindelse, som rclone ikke melder som en fejl. Backups siden da ligger kun i maskinens buffer. Når netværket vender tilbage, genoptages upload af sig selv (den 28.10.2026 inden for 80 s); hvis det ikke sker, fjerner en genstart af maskinen (prepare-shutdown, limactl start) de døde forbindelser.",
    "tmutil did not answer - not restarting the machine while its state is unknown.":
      "tmutil svarede ikke - genstarter ikke maskinen, mens dens tilstand er ukendt.",
  ]
}
