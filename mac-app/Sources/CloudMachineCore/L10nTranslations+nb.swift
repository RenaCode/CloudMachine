// Norwegian Bokmål translations, keyed by the English text passed to `L10n.tr`.
extension L10nTranslations {
  static let nb: [String: String] = [
    "Space limit:      %@":
      "Plassgrense:      %@",
    "                  Time Machine quota not set to match - run: %@":
      "                  Time Machine-kvoten er ikke satt til å samsvare - kjør: %@",
    "Sets how much of Google Drive this Mac may use, and prints the Time Machine quota command.":
      "Angir hvor mye av Google Drive denne Mac-en kan bruke, og skriver ut kommandoen for Time Machine-kvoten.",
    "Limit in GB.":
      "Grense i GB.",
    "Limit for this Mac: %@ GB.":
      "Grense for denne Mac-en: %@ GB.",
    "Now set the Time Machine quota (needs an administrator password):":
      "Angi nå Time Machine-kvoten (krever et administratorpassord):",
    "CloudMachine - verification, Google Drive setup and installation. Called by launchd on a schedule, or by hand from Terminal.":
      "CloudMachine - kontroll, oppsett av Google Drive og installasjon. Kalles av launchd etter en tidsplan, eller manuelt fra Terminal.",
    "Connects to Google Drive through rclone (OAuth in the browser) and creates this machine's folder.":
      "Kobler til Google Drive via rclone (OAuth i nettleseren) og oppretter mappen til denne maskinen.",
    "Overwrite the existing remote. RISKY: replaces the token and permissions.":
      "Overskriv den eksisterende remote. RISIKABELT: erstatter token og tillatelser.",
    "Packs build/CloudMachine.app into build/CloudMachine-<version>.dmg.":
      "Pakker build/CloudMachine.app til build/CloudMachine-<version>.dmg.",
    "ERROR: %@ is missing - run 'cloudmachine-agent build-app' first":
      "FEIL: %@ mangler - kjør 'cloudmachine-agent build-app' først",
    "==> Preparing the staging folder":
      "==> Klargjør staging-mappen",
    "==> Creating %@":
      "==> Oppretter %@",
    "ERROR: hdiutil exited with code %@.":
      "FEIL: hdiutil avsluttet med kode %@.",
    "==> Done: %@":
      "==> Ferdig: %@",
    "On first launch (the app is not signed with an Apple Developer account):":
      "Ved første åpning (appen er ikke signert med en Apple Developer-konto):",
    "1. Open %@ and drag CloudMachine.app to Applications.":
      "1. Åpne %@ og dra CloudMachine.app til Programmer.",
    "2. In Finder, RIGHT-click CloudMachine.app -> Open -> Open\n   (a plain double-click shows the Gatekeeper block \"unidentified developer\").":
      "2. Høyreklikk på CloudMachine.app i Finder -> Åpne -> Åpne\n   (et vanlig dobbeltklikk viser Gatekeeper-blokkeringen “ukjent utvikler”).",
    "3. Later launches work normally, with a double-click.":
      "3. Senere åpnes appen vanlig, med et dobbeltklikk.",
    "Builds CloudMachine.app (Release) - GUI + cloudmachine-agent in Contents/MacOS/, plus launchd/, vm/ and config/ as Resources.":
      "Bygger CloudMachine.app (Release) - GUI + cloudmachine-agent i Contents/MacOS/ samt launchd/, vm/ og config/ som Resources.",
    "Binaries for Apple Silicon and Intel at once (how CI builds a release; unnecessary locally).":
      "Binærfiler for både Apple Silicon og Intel (slik bygger CI en utgivelse; unødvendig lokalt).",
    "==> Building CloudMachineApp + cloudmachine-agent (release) - version %@ (%@)":
      "==> Bygger CloudMachineApp + cloudmachine-agent (release) - versjon %@ (%@)",
    "ERROR: swift build exited with code %@.":
      "FEIL: swift build avsluttet med kode %@.",
    "ERROR: swift build --show-bin-path did not report the binaries directory.":
      "FEIL: swift build --show-bin-path oppga ikke mappen med binærfilene.",
    "ERROR: no built binary found at %@":
      "FEIL: fant ingen bygd binærfil i %@",
    "==> Assembling the .app bundle in %@":
      "==> Setter sammen .app-pakken i %@",
    "==> WARNING: you are building from a DIRTY tree - the version will not point to a commit.":
      "==> ADVARSEL: du bygger fra et SKITTENT tre - versjonen peker ikke på en commit.",
    "ERROR: Resources/AppIcon.icns is missing - generate it: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns":
      "FEIL: Resources/AppIcon.icns mangler - opprett den: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns",
    "==> Signing with the local certificate '%@' (Full Disk Access will survive later rebuilds)":
      "==> Signerer med det lokale sertifikatet '%@' (Full disktilgang bevares ved senere ombygginger)",
    "==> Signing ad-hoc (no Apple Developer account) - run 'cloudmachine-agent setup-signing-cert' once so that TCC permissions survive later rebuilds":
      "==> Signerer ad hoc (ingen Apple Developer-konto) - kjør 'cloudmachine-agent setup-signing-cert' én gang, slik at TCC-tillatelser bevares ved senere ombygginger",
    "ERROR: codesign exited with code %@.":
      "FEIL: codesign avsluttet med kode %@.",
    "Next step: %@":
      "Neste trinn: %@",
    "Creates a local self-signed certificate so that Full Disk Access survives later rebuilds of the app.":
      "Oppretter et lokalt selvsignert sertifikat, slik at Full disktilgang bevares ved senere ombygginger av appen.",
    "Certificate '%@' already exists in %@, nothing to do.":
      "Sertifikatet '%@' finnes allerede i %@ - ingenting å gjøre.",
    "==> Generating the key and self-signed certificate '%@'...":
      "==> Genererer nøkkelen og det selvsignerte sertifikatet '%@'...",
    "ERROR: openssl req exited with code %@.":
      "FEIL: openssl req avsluttet med kode %@.",
    "ERROR: openssl pkcs12 exited with code %@.":
      "FEIL: openssl pkcs12 avsluttet med kode %@.",
    "==> Importing the certificate into %@ (pre-authorizing /usr/bin/codesign, so it does not ask for the keychain password every time)...":
      "==> Importerer sertifikatet i %@ (forhåndsgodkjenner /usr/bin/codesign, slik at den ikke spør om passordet til nøkkelringen hver gang)...",
    "ERROR: security import exited with code %@.":
      "FEIL: security import avsluttet med kode %@.",
    "==> Trusting the certificate ONLY for code signing...":
      "==> Stoler på sertifikatet KUN for kodesignering...",
    "ERROR: security add-trusted-cert exited with code %@.":
      "FEIL: security add-trusted-cert avsluttet med kode %@.",
    "Done. Certificate '%@' is now available to codesign.":
      "Ferdig. Sertifikatet '%@' er nå tilgjengelig for codesign.",
    "The next 'cloudmachine-agent build-app' will use it automatically instead of an ad-hoc signature.":
      "Neste 'cloudmachine-agent build-app' bruker det automatisk i stedet for en ad hoc-signatur.",
    "After THAT ONE rebuild, grant Full Disk Access one last time - later\nrebuilds will no longer reset it, as long as you sign with the same certificate.":
      "Etter DEN ENE ombyggingen må du gi Full disktilgang en siste gang - senere\nombygginger tilbakestiller den ikke lenger, så lenge du signerer med det samme sertifikatet.",
    "Checks whether the hourly cycle STILL works (date of the last SUCCESSFUL backup) and reports failures.":
      "Kontrollerer om den timevise syklusen FORTSATT fungerer (datoen for den siste VELLYKKEDE sikkerhetskopien) og melder feil.",
    "After this many hours without a successful backup we consider the cycle broken.":
      "Etter så mange timer uten en vellykket sikkerhetskopi anser vi syklusen som brutt.",
    "Only print the state, without a system notification.":
      "Skriv bare ut tilstanden, uten systemvarsel.",
    "A different Time Machine preferences file - to test the watchdog on a known sample.":
      "En annen innstillingsfil for Time Machine - for å teste vakthunden på et kjent utvalg.",
    "Last successful backup: %@":
      "Siste vellykkede sikkerhetskopi: %@",
    "Last successful backup: NONE":
      "Siste vellykkede sikkerhetskopi: INGEN",
    "Last attempt:           %@":
      "Siste forsøk:                    %@",
    "WAITING (system startup): %@":
      "VENTER (systemoppstart): %@",
    "Backup cycle: OK":
      "Sikkerhetskopisyklus: OK",
    "FAILURE: %@":
      "FEIL: %@",
    "         %@":
      "         %@",
    "Check the state:  %@":
      "Sjekk tilstanden:  %@",
    "Preparing for restart":
      "Forbereder omstart",
    "Prepare for restart":
      "Forbered til omstart",
    "Prepare":
      "Forbered",
    "==> WARNING: git rev-list failed (%@) - using the date as the build number.":
      "==> ADVARSEL: git rev-list mislyktes (%@) - datoen brukes som byggnummer.",
    "Agents:           %@":
      "Agenter:           %@",
    "CANNOT START: %@ - open CloudMachine or run backup-health to reload them":
      "KAN IKKE STARTE: %@ - åpne CloudMachine eller kjør backup-health for å laste dem på nytt",
    "Reloaded agents that could not start: %@":
      "Lastet på nytt agenter som ikke kunne starte: %@",
    "Drive folder:     %@":
      "Drive-mappe:       %@",
    "Name of this Mac's folder on Google Drive (default: derived from the computer name). Set once; it cannot be changed later.":
      "Navnet på mappen til denne Mac-en på Google Drive (standard: avledet av datamaskinens navn). Angis én gang; kan ikke endres senere.",
    "Backup watchdog:  %@":
      "Vakthund for sikkerhetskopi: %@",
    "Prints the version, the build number and the commit this binary was built from.":
      "Skriver ut versjonen, byggnummeret og commiten som denne binærfilen ble bygd fra.",
    "Only one line, without a description.":
      "Bare én linje, uten beskrivelse.",
    "Build from the working tree (outside a bundle) - no version data.":
      "Bygg fra arbeidstreet (utenfor en pakke) - ingen versjonsdata.",
    "Version: %@":
      "Versjon: %@",
    "Build:   %@":
      "Bygg:    %@",
    "Commit:  %@":
      "Commit:  %@",
    "WARNING: built from a DIRTY tree - the binary contains code that\n         is in no commit. The commit number does NOT describe\n         what actually runs.":
      "ADVARSEL: bygd fra et SKITTENT tre - binærfilen inneholder kode som\n         ikke er i noen commit. Commit-nummeret beskriver IKKE\n         hva som faktisk kjører.",
    "Saving the space limit":
      "Lagrer plassgrensen",
    "Measuring usage on Google Drive":
      "Måler forbruket på Google Drive",
    "Google Drive did not answer - try again later.":
      "Google Drive svarte ikke - prøv igjen senere.",
    "Measured.":
      "Målt.",
    "Space limit for this Mac":
      "Plassgrense for denne Mac-en",
    "Used on Google Drive":
      "Brukt på Google Drive",
    "Measured %@. The watchdog measures again every few hours.":
      "Målt %@. Vakthunden måler på nytt med noen timers mellomrom.",
    "Limit (GB)":
      "Grense (GB)",
    "Save":
      "Arkiver",
    "Measure now":
      "Mål nå",
    "Time Machine quota: %@ GB (70%% of the limit - the copy on Drive is about a third larger than the backup inside it). Time Machine deletes the oldest backups to stay within it.":
      "Time Machine-kvote: %@ GB (70%% av grensen - kopien på Drive er omtrent en tredel større enn sikkerhetskopien den inneholder). Time Machine sletter de eldste sikkerhetskopiene for å holde seg innenfor den.",
    "Set the Time Machine quota: run this in Terminal (needs sudo)":
      "Angi Time Machine-kvoten: kjør dette i Terminal (krever sudo)",
    "Connect Google Drive: run this in Terminal and approve in the browser":
      "Koble til Google Drive: kjør dette i Terminal, og godkjenn i nettleseren",
    "Grant Full Disk Access to CloudMachine, so it can tell whether backups complete":
      "Gi CloudMachine Full disktilgang, slik at den kan se om sikkerhetskopiene fullføres",
    "Folder on Google Drive":
      "Mappe på Google Drive",
    "One folder per Mac. Set once - it cannot be changed after connecting.":
      "Én mappe per Mac. Angis én gang - kan ikke endres etter tilkobling.",
    "Use lowercase letters, digits and dashes.":
      "Bruk små bokstaver, sifre og bindestreker.",
    "Install rclone":
      "Installer rclone",
    "Open System Settings":
      "Åpne Systeminnstillinger",
    "Install agents":
      "Installer agenter",
    "not checked":
      "ikke kontrollert",
    "none at all":
      "ikke én eneste",
    "%@ ago":
      "%@ siden",
    "Missing: %@":
      "Mangler: %@",
    "Google Drive not connected":
      "Google Drive er ikke tilkoblet",
    "Time Machine does not point to CloudMachine":
      "Time Machine peker ikke på CloudMachine",
    "UNKNOWN whether Time Machine points to CloudMachine - tmutil did not answer":
      "DET ER UKJENT om Time Machine peker på CloudMachine - tmutil svarte ikke",
    "Backup in progress":
      "Sikkerhetskopiering pågår",
    "Unknown when the last backup was made":
      "Det er ukjent når den siste sikkerhetskopien ble tatt",
    "There is no completed backup at all":
      "Det finnes ingen fullført sikkerhetskopi i det hele tatt",
    "No completed backup for %@":
      "Ingen fullført sikkerhetskopi på %@",
    "Ready":
      "Klar",
    "Not saved: %@":
      "Ikke arkivert: %@",
    "Installing rclone":
      "Installerer rclone",
    "Installing launchd agents":
      "Installerer launchd-agenter",
    "Starting backup":
      "Starter sikkerhetskopiering",
    "Backup started.":
      "Sikkerhetskopiering startet.",
    "Could not start the backup.":
      "Kunne ikke starte sikkerhetskopieringen.",
    "Stopping backup":
      "Stopper sikkerhetskopiering",
    "Backup stopped.":
      "Sikkerhetskopiering stoppet.",
    "Could not stop the backup.":
      "Kunne ikke stoppe sikkerhetskopieringen.",
    "Could not prepare the AppleScript.":
      "Kunne ikke klargjøre AppleScript.",
    "Unknown authorization error.":
      "Ukjent autorisasjonsfeil.",
    "Waiting to upload":
      "Venter på opplasting",
    "%@ files":
      "%@ filer",
    "nothing":
      "ingenting",
    "Back up now":
      "Sikkerhetskopier nå",
    "Stop backup":
      "Stopp sikkerhetskopiering",
    "Open CloudMachine":
      "Åpne CloudMachine",
    "Quit":
      "Avslutt",
    "Healthy":
      "Frisk",
    "Attention":
      "Obs",
    "Refreshed %@":
      "Oppdatert %@",
    "System Status":
      "Systemstatus",
    "Action needed":
      "Handling kreves",
    "not measured":
      "ikke målt",
    "rclone did not answer":
      "rclone svarte ikke",
    "Backup in Progress":
      "Sikkerhetskopiering pågår",
    "Files processed":
      "Behandlede filer",
    "Write speed":
      "Skrivehastighet",
    "Operation phase":
      "Operasjonsfase",
    "Required Setup Steps":
      "Nødvendige oppsettstrinn",
    "Copy":
      "Kopier",
    "Last completed backup":
      "Siste fullførte sikkerhetskopi",
    "Last backup watchdog run":
      "Siste kjøring av vakthunden for sikkerhetskopi",
    "not read":
      "ikke lest",
    "Everything uploaded":
      "Alt er lastet opp",
    "File upload errors":
      "Feil ved opplasting av filer",
    "Google Drive Credentials (OAuth 2.0)":
      "Legitimasjon for Google Drive (OAuth 2.0)",
    "Keychain OK":
      "Nøkkelring OK",
    "No custom keys":
      "Ingen egne nøkler",
    "Paste client_id...":
      "Lim inn client_id...",
    "Paste client_secret...":
      "Lim inn client_secret...",
    "Save securely in the Keychain":
      "Arkiver trygt i nøkkelringen",
    "Refresh":
      "Oppdater",
    "Overview":
      "Oversikt",
    "Backups":
      "Sikkerhetskopier",
    "Storage":
      "Lagring",
    "Settings":
      "Innstillinger",
    "Current status: %@":
      "Gjeldende status: %@",
    "Does not point to CloudMachine":
      "Peker ikke på CloudMachine",
    "tmutil did not answer":
      "tmutil svarte ikke",
    "Backing up: %@ of %@":
      "Sikkerhetskopierer: %@ av %@",
    "%@ of %@":
      "%@ av %@",
    "Copied":
      "Kopiert",
    "No backup is running":
      "Ingen sikkerhetskopiering pågår",
    "Time Machine starts the next one on its own schedule.":
      "Time Machine starter den neste etter sin egen tidsplan.",
    "Backup cycle":
      "Sikkerhetskopisyklus",
    "%@ GiB":
      "%@ GiB",
    "%@ GiB in %@ bands, %@ uploading":
      "%@ GiB i %@ bånd, %@ lastes opp",
    "%@ bands":
      "%@ bånd",
    "%@ fragments abandoned - only in the machine":
      "%@ oppgitte fragmenter - bare i maskinen",
    "127.0.0.1:5572 answers on the Mac: Lima forwards the machine's rclone remote control, which has no password. Any web page open in a browser can send it commands - including deleting the backup on Google Drive. Add the portForwards rule from vm/cmsmb.yaml to the machine and restart it (see vm/README.md).":
      "127.0.0.1:5572 svarer på Mac-en: Lima videresender maskinens fjernstyring av rclone, som ikke har noe passord. Enhver nettside som er åpen i en nettleser, kan sende kommandoer til den - også sletting av sikkerhetskopien på Google Drive. Legg regelen portForwards fra vm/cmsmb.yaml til i maskinen, og start den på nytt (se vm/README.md).",
    "A service in the CloudMachine machine is not running":
      "En tjeneste i CloudMachine-maskinen kjører ikke",
    "Address":
      "Adresse",
    "Agent installation INCOMPLETE - %@ of %@ did not go in:\n%@\n%@\nEvery missing agent is a function that has silently stopped working (vm-guard watches the machine's buffer, backup-health reports failures). Fix the cause and repeat the installation.":
      "Installasjonen av agenter er UFULLSTENDIG - %@ av %@ ble ikke installert:\n%@\n%@\nHver manglende agent er en funksjon som stille har sluttet å fungere (vm-guard overvåker maskinens buffer, backup-health melder feil). Rett opp årsaken, og gjenta installasjonen.",
    "All running":
      "Alle kjører",
    "Also install the launchd agents (same as install-launchd).":
      "Installer også launchd-agentene (samme som install-launchd).",
    "At most this many minutes of waiting for the upload.":
      "Maksimalt så mange minutter venting på opplasting.",
    "At the limit every new band fails with EMFILE and the backup stops. Check: cloudmachine-agent vm-status":
      "Ved grensen mislykkes hvert nye bånd med EMFILE, og sikkerhetskopieringen stopper. Kontroller: cloudmachine-agent vm-status",
    "Cache on the machine's disk":
      "Hurtigbuffer på maskinens disk",
    "Connected to Google Drive, but could not create the folder '%@' - without it the machine has nowhere to keep the backup. Check the account permissions and try again.":
      "Tilkoblet Google Drive, men kunne ikke opprette mappen '%@' - uten den har maskinen ingen steder å lagre sikkerhetskopien. Kontroller kontoens tillatelser, og prøv igjen.",
    "Convert the image":
      "Konverter diskbildet",
    "Converting the image to 32 MB bands":
      "Konverterer diskbildet til bånd på 32 MB",
    "Could not check with the current connection whether the backup is on Google Drive (%@), so remote '%@' was NOT replaced: without that answer the new sign-in cannot be checked against it.":
      "Det var ikke mulig å kontrollere med den gjeldende tilkoblingen om sikkerhetskopien finnes på Google Drive (%@), så remote '%@' ble IKKE erstattet: uten det svaret kan den nye påloggingen ikke kontrolleres mot den.",
    "Downloads the official rclone binary into ~/.cloudmachine/bin (Google sign-in and the machine's rclone.conf).":
      "Laster ned den offisielle rclone-binærfilen til ~/.cloudmachine/bin (Google-pålogging og maskinens rclone.conf).",
    "Free in the machine":
      "Ledig i maskinen",
    "Free in the machine: %@":
      "Ledig i maskinen: %@",
    "Generates and installs the launchd agents (app, backup watchdog, machine start, machine guard).":
      "Genererer og installerer launchd-agentene (appen, vakthund for sikkerhetskopi, maskinstart, maskinens vakt).",
    "Install Lima, which runs the CloudMachine machine: run this in Terminal":
      "Installer Lima, som kjører CloudMachine-maskinen: kjør dette i Terminal",
    "Install rclone (signs in to Google Drive for the machine)":
      "Installer rclone (logger maskinen på Google Drive)",
    "Install the background agents (machine start, buffer guard, backup watchdog)":
      "Installer bakgrunnsagentene (maskinstart, buffervakt, vakthund for sikkerhetskopi)",
    "Installs rclone through Homebrew - CloudMachine itself uses the one from install-rclone.":
      "Installerer rclone via Homebrew - CloudMachine selv bruker den som kommer fra install-rclone.",
    "Info.plist, token and mapped/ of the backup image exist only on the machine's disk; without them the bands in %@ cannot be restored. The copy (tm-meta-sync, every 15 min) goes to %@. Check: cloudmachine-agent vm-status, then in the machine: journalctl -u tm-meta-sync":
      "Info.plist, token og mapped/ fra diskbildet for sikkerhetskopien finnes bare på maskinens disk; uten dem kan ikke båndene i %@ gjenopprettes. Kopien (tm-meta-sync, hvert 15. minutt) legges i %@. Kontroller: cloudmachine-agent vm-status, og deretter i maskinen: journalctl -u tm-meta-sync",
    "Lima says the machine is running, but a command in it did not return. Without it nothing is known about Samba, rclone or the upload. Check: cloudmachine-agent vm-status":
      "Lima sier at maskinen kjører, men en kommando i den returnerte ikke. Uten den vet man ingenting om Samba, rclone eller opplasting. Kontroller: cloudmachine-agent vm-status",
    "Machine":
      "Maskin",
    "Machine %@":
      "Maskin %@",
    "Machine & Upload Status":
      "Status for maskin og opplasting",
    "Machine buffer":
      "Maskinens buffer",
    "No Time Machine destination is the machine's share (smb://tm@<address>/CloudMachine) - backups are not being made there. The command is printed by: cloudmachine-agent vm-setup":
      "Ingen Time Machine-destinasjon er maskinens deling (smb://tm@<adresse>/CloudMachine) - det tas ingen sikkerhetskopier der. Kommandoen skrives ut av: cloudmachine-agent vm-setup",
    "Not running: %@":
      "Kjører ikke: %@",
    "Not set up":
      "Ikke konfigurert",
    "Once it runs out, rclone stops uploading, the machine's buffer fills up and backups stop being made. At a growth of ~600 MB per hourly cycle that is about %@ days.":
      "Når den er brukt opp, slutter rclone å laste opp, maskinens buffer fylles, og det tas ikke flere sikkerhetskopier. Ved en vekst på ca. 600 MB per timesyklus er det omtrent %@ dager.",
    "Or rclone.conf is missing: this Mac has already set up the CloudMachine machine, so it is not connected anew blindly. Restore the file from a backup (the machine keeps its own copy in %@). To connect anyway, create an empty file at the path `%@ config file` prints and run again - the existing folder is kept.":
      "Eller rclone.conf mangler: denne Mac-en har allerede satt opp CloudMachine-maskinen, så den kobles ikke til på nytt i blinde. Gjenopprett filen fra en sikkerhetskopi (maskinen har sin egen kopi i %@). For å koble til likevel, opprett en tom fil på stien som `%@ config file` skriver ut, og kjør på nytt - den eksisterende mappen beholdes.",
    "Point Time Machine at the machine: run this in Terminal (needs sudo; Copy includes the password)":
      "Pek Time Machine på maskinen: kjør dette i Terminal (krever sudo; Kopier tar med passordet)",
    "Points to the machine":
      "Peker på maskinen",
    "Prepares for a restart: stops the backup, waits a while for the upload, then stops the machine cleanly.":
      "Forbereder en omstart: stopper sikkerhetskopieringen, venter en stund på opplasting og stopper deretter maskinen på en ryddig måte.",
    "Reading the Time Machine destination did not return within %@ s. That is how tmutil behaves when its destination hangs.":
      "Lesing av Time Machine-destinasjonen returnerte ikke innen %@ s. Slik oppfører tmutil seg når destinasjonen henger.",
    "Remote '%@' was NOT replaced. The new sign-in gets the 'drive.file' scope, which sees only files created under its own client_id. The existing backup was most likely created by the current connection and would become invisible to it. Before anything is written, the new token is checked against the existing backup, and the replacement is abandoned if it cannot see it. The machine keeps its own copy of the configuration until vm-setup --replace-rclone-config. To go ahead, run again with --replace-existing --accept-scope-change.":
      "Remote '%@' ble IKKE erstattet. Den nye påloggingen får omfanget 'drive.file', som bare ser filer opprettet under sitt eget client_id. Den eksisterende sikkerhetskopien ble mest sannsynlig opprettet av den gjeldende tilkoblingen og ville blitt usynlig for den. Før noe skrives, kontrolleres det nye tokenet mot den eksisterende sikkerhetskopien, og erstatningen oppgis hvis det ikke kan se den. Maskinen beholder sin egen kopi av konfigurasjonen til vm-setup --replace-rclone-config. For å gå videre, kjør på nytt med --replace-existing --accept-scope-change.",
    "Remote control:   OPEN on the Mac at 127.0.0.1:5572 - any web page can send rclone commands; see vm/README.md (portForwards)":
      "Fjernstyring:      ÅPEN på Mac-en på 127.0.0.1:5572 - enhver nettside kan sende rclone-kommandoer; se vm/README.md (portForwards)",
    "Running":
      "Kjører",
    "Samba, rclone or punchfs in the machine is not active, so Time Machine has nowhere to write or the bands do not reach Google Drive. Check: cloudmachine-agent vm-status":
      "Samba, rclone eller punchfs i maskinen er ikke aktiv, så Time Machine har ingen steder å skrive, eller båndene når ikke fram til Google Drive. Kontroller: cloudmachine-agent vm-status",
    "Service %@":
      "Tjeneste %@",
    "Services":
      "Tjenester",
    "Set up the CloudMachine machine (the first time it downloads Ubuntu - several minutes)":
      "Sett opp CloudMachine-maskinen (første gang lastes Ubuntu ned - flere minutter)",
    "Set up the CloudMachine machine again, so it prints the Time Machine command":
      "Sett opp CloudMachine-maskinen på nytt, slik at den skriver ut Time Machine-kommandoen",
    "Set up the machine":
      "Sett opp maskinen",
    "Setting up the CloudMachine machine":
      "Setter opp CloudMachine-maskinen",
    "Start the CloudMachine machine":
      "Start CloudMachine-maskinen",
    "Start the machine":
      "Start maskinen",
    "Starting the CloudMachine machine":
      "Starter CloudMachine-maskinen",
    "Still to upload: %@ GiB":
      "Gjenstår å laste opp: %@ GiB",
    "Stopping the Time Machine backup...":
      "Stopper sikkerhetskopieringen i Time Machine...",
    "Stopping the machine %@...":
      "Stopper maskinen %@...",
    "The CloudMachine machine does not answer":
      "CloudMachine-maskinen svarer ikke",
    "The CloudMachine machine is not running":
      "CloudMachine-maskinen kjører ikke",
    "The CloudMachine machine is not set up yet":
      "CloudMachine-maskinen er ikke satt opp ennå",
    "The CloudMachine machine is stopped":
      "CloudMachine-maskinen er stoppet",
    "The backup is stopped, the upload gets up to 30 minutes, then the machine shuts down cleanly. It starts again at the next login.":
      "Sikkerhetskopieringen stoppes, opplastingen får opptil 30 minutter, og deretter slås maskinen av på en ryddig måte. Den starter igjen ved neste pålogging.",
    "The machine %@ is not running - nothing to prepare.":
      "Maskinen %@ kjører ikke - ingenting å forberede.",
    "The machine is stopped and everything reached Google Drive. The Mac can be restarted; the machine starts again at login.":
      "Maskinen er stoppet, og alt nådde fram til Google Drive. Mac-en kan startes på nytt; maskinen starter igjen ved pålogging.",
    "The machine is stopped. %@ GiB had not reached Google Drive yet - it is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "Maskinen er stoppet. %@ GiB hadde ennå ikke nådd fram til Google Drive - de ligger i maskinens buffer og lastes opp etter neste start. Mac-en kan startes på nytt.",
    "The machine is stopped. rclone did not say how much was still to upload; what was not uploaded is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "Maskinen er stoppet. rclone oppga ikke hvor mye som gjensto å laste opp; det som ikke ble lastet opp, ligger i maskinens buffer og lastes opp etter neste start. Mac-en kan startes på nytt.",
    "The machine's disk is a file on this disk and grows as the upload buffer fills. With no space left the machine cannot write the buffer, and Time Machine's local snapshots have nowhere to go either.":
      "Maskinens disk er en fil på denne disken og vokser etter hvert som opplastingsbufferen fylles. Uten ledig plass kan ikke maskinen skrive bufferen, og lokale øyeblikksbilder fra Time Machine har heller ingen steder å gå.",
    "The image's metadata has never been copied to Drive":
      "Diskbildets metadata har aldri blitt kopiert til Drive",
    "The image's metadata was last copied to Drive %@ ago":
      "Diskbildets metadata ble sist kopiert til Drive for %@ siden",
    "The machine's disk is running out of space (%@ GB)":
      "Maskinens disk er i ferd med å gå tom for plass (%@ GB)",
    "The new sign-in does NOT see the existing backup (%@), so remote '%@' was NOT replaced and rclone.conf is unchanged. Keep the current connection, or sign in with the credential (client_id) that created the backup.":
      "Den nye påloggingen ser IKKE den eksisterende sikkerhetskopien (%@), så remote '%@' ble IKKE erstattet, og rclone.conf er uendret. Behold den gjeldende tilkoblingen, eller logg på med legitimasjonen (client_id) som opprettet sikkerhetskopien.",
    "The upload buffer lives on this disk. The guard pauses Time Machine before it fills; if the upload does not catch up, backups stay paused.":
      "Opplastingsbufferen ligger på denne disken. Vakten setter Time Machine på pause før den fylles; hvis opplastingen ikke tar igjen, forblir sikkerhetskopieringen på pause.",
    "These bands exist only in the machine's buffer. The backup on Google Drive is INCOMPLETE and may not open.":
      "Disse båndene finnes bare i maskinens buffer. Sikkerhetskopien på Google Drive er UFULLSTENDIG og kan hende den ikke kan åpnes.",
    "Time Machine backs up to the machine, so without it no backup is made. Start it: limactl start %@ (or the Start button in the app).":
      "Time Machine tar sikkerhetskopi til maskinen, så uten den tas det ingen sikkerhetskopi. Start den: limactl start %@ (eller Start-knappen i appen).",
    "Time Machine did not stop its backup within 2 minutes (or tmutil did not answer) - the machine was NOT stopped. Try again in a moment.":
      "Time Machine stoppet ikke sikkerhetskopieringen innen 2 minutter (eller tmutil svarte ikke) - maskinen ble IKKE stoppet. Prøv igjen om et øyeblikk.",
    "Time Machine has created its image: stop the backup, then convert the image to 32 MB bands":
      "Time Machine har opprettet diskbildet sitt: stopp sikkerhetskopieringen, og konverter deretter diskbildet til bånd på 32 MB",
    "To upload":
      "Skal lastes opp",
    "Unknown whether the CloudMachine machine is running":
      "Det er ukjent om CloudMachine-maskinen kjører",
    "Waiting for the upload to Google Drive (at most %@ min)...":
      "Venter på opplasting til Google Drive (maksimalt %@ min.)...",
    "With --replace-existing: confirms that the new sign-in (scope 'drive.file') may not see the existing backup. The new token is still checked against the backup first.":
      "Med --replace-existing: bekrefter at den nye påloggingen (omfanget 'drive.file') kanskje ikke ser den eksisterende sikkerhetskopien. Det nye tokenet kontrolleres fortsatt mot sikkerhetskopien først.",
    "Without it there is no way to check whether anything reached the Drive - the machine's guard is blind then.":
      "Uten den finnes det ingen måte å kontrollere om noe nådde fram til Drive - maskinens vakt er da blind.",
    "limactl did not answer":
      "limactl svarte ikke",
    "limactl did not answer (or is not installed). That does not mean the machine is down - it means nobody has checked.":
      "limactl svarte ikke (eller er ikke installert). Det betyr ikke at maskinen er nede - det betyr at ingen har kontrollert.",
    "limactl start failed: %@":
      "limactl start mislyktes: %@",
    "limactl stop failed: %@":
      "limactl stop mislyktes: %@",
    "punchfs is close to its open-file limit":
      "punchfs nærmer seg grensen for åpne filer",
    "punchfs open files":
      "Åpne filer i punchfs",
    "rclone's remote control is open on this Mac":
      "Fjernstyringen til rclone er åpen på denne Mac-en",
    "statfs('/System/Volumes/Data') returned an error, so nobody knows whether the machine's disk can still grow on this Mac.":
      "statfs('/System/Volumes/Data') returnerte en feil, så ingen vet om maskinens disk fortsatt kan vokse på denne Mac-en.",
    "Google Drive's daily upload limit stops the upload":
      "Googles daglige opplastingsgrense stopper opplastingen",
    "Google last refused an upload %@ ago (750 GB a day). Backups since then are only in the machine's buffer on this Mac. rclone retries every 5 min and resumes by itself when the limit passes; the guard pauses Time Machine if more than %@ GiB waits.":
      "Google avviste sist en opplasting for %@ siden (750 GB per dag). Sikkerhetskopier siden da ligger bare i maskinens buffer på denne Mac-en. rclone prøver på nytt hvert 5. minutt og fortsetter av seg selv når grensen er over; vakten setter Time Machine på pause hvis mer enn %@ GiB venter.",
    "Usage on Google Drive is not being measured":
      "Forbruket på Google Drive måles ikke",
    "The last measurement (%@ GB) is from %@, %@ ago - rclone size has not answered since. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "Den siste målingen (%@ GB) er fra %@, for %@ siden - rclone size har ikke svart siden. Inntil den gjør det, er det ingen som overvåker grensen på %@ GB: alarmene ved 90%% og 100%% forblir stille. Sjekk vm-status, eller trykk på Mål nå i vinduet.",
    "rclone size has not answered even once. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "rclone size har ikke svart en eneste gang. Inntil den gjør det, er det ingen som overvåker grensen på %@ GB: alarmene ved 90%% og 100%% forblir stille. Sjekk vm-status, eller trykk på Mål nå i vinduet.",
    "Saved in the Keychain. Connecting Google Drive (configure-remote) will use them.":
      "Arkivert i nøkkelringen. Tilkobling av Google Drive (configure-remote) vil bruke dem.",
    "Saved in the Keychain. The existing Google Drive connection keeps its old client_id, and on this Mac it should stay that way: a connection made with the new keys (the 'drive.file' scope) cannot see the backup created by the old one. Do not replace the connection here; the new keys are for a Mac that is not connected yet.":
      "Arkivert i nøkkelringen. Den eksisterende Google Drive-tilkoblingen beholder sitt gamle client_id, og på denne Mac-en bør det forbli slik: en tilkobling opprettet med de nye nøklene (omfanget 'drive.file') kan ikke se sikkerhetskopien som den gamle opprettet. Ikke erstatt tilkoblingen her; de nye nøklene er for en Mac som ikke er tilkoblet ennå.",
    "it is not there for the new token":
      "den finnes ikke for det nye tokenet",
    "Cancel":
      "Avbryt",
    "ACTION NEEDED":
      "HANDLING KREVES",
    "WILL PASS BY ITSELF — DO NOTHING":
      "GÅR OVER AV SEG SELV — IKKE GJØR NOE",
    "UNKNOWN — CHECK AGAIN SHORTLY":
      "UKJENT — SJEKK PÅ NYTT OM LITT",
    "ALL GOOD":
      "ALT ER BRA",
    "Upload is not working":
      "Opplastingen fungerer ikke",
    "Upload stopped — no space left on Google Drive":
      "Opplastingen er stoppet — ingen ledig plass på Google Drive",
    "%@ backup fragments not uploaded":
      "%@ fragmenter av sikkerhetskopien er ikke lastet opp",
    "Upload cannot keep up with writes":
      "Opplastingen klarer ikke å holde følge med skrivingen",
    "Upload paused — Google daily limit":
      "Opplastingen er satt på pause — Googles daglige grense",
    "Uploading to Google Drive — %@ queued":
      "Laster opp til Google Drive — %@ i kø",
    "Everything uploaded to Google Drive":
      "Alt er lastet opp til Google Drive",
    "Unknown what is waiting in the queue":
      "Det er ukjent hva som venter i køen",
    "There is no connection to Google Drive, so backups are only made on this Mac. If this does not pass by itself within a few minutes, check the network and the connection to Drive.":
      "Det er ingen tilkobling til Google Drive, så sikkerhetskopier tas bare på denne Mac-en. Hvis dette ikke går over av seg selv i løpet av noen få minutter, kontroller nettverket og tilkoblingen til Drive.",
    "There is no space left on Google Drive. This will NOT pass by itself — you need to free up space on Drive. Until then Time Machine is paused, so that it does not fill up this Mac's disk.":
      "Det er ingen ledig plass på Google Drive. Dette går IKKE over av seg selv — du må frigjøre plass på Drive. Inntil da er Time Machine satt på pause, slik at den ikke fyller opp disken på denne Mac-en.",
    "%@ backup fragments could not be uploaded and rclone stopped trying. These fragments exist only on this Mac, so the backup on Drive is incomplete. This needs checking.":
      "%@ fragmenter av sikkerhetskopien kunne ikke lastes opp, og rclone har sluttet å prøve. Disse fragmentene finnes bare på denne Mac-en, så sikkerhetskopien på Drive er ufullstendig. Dette må sjekkes.",
    "Time Machine is writing faster than the upload goes, and the buffer has filled up. The backup will be paused until the upload catches up — this is a safeguard against filling up the disk, not a failure.":
      "Time Machine skriver raskere enn opplastingen går, og bufferen er full. Sikkerhetskopieringen settes på pause til opplastingen tar igjen — dette er en sikring mot at disken fylles opp, ikke en feil.",
    "Google accepts 750 GB per day and that limit has been used up. There is nothing to do: the limit renews by itself, usually within a few hours. Time Machine backups are made normally in the meantime and wait in the buffer — they will be uploaded as soon as Google starts accepting again.":
      "Google godtar 750 GB per dag, og den grensen er brukt opp. Det er ingenting å gjøre: grensen nullstilles av seg selv, vanligvis i løpet av noen timer. Sikkerhetskopier fra Time Machine tas som normalt i mellomtiden og venter i bufferen — de lastes opp så snart Google godtar data igjen.",
    "%@ backup fragments are queued and on their way to Drive.":
      "%@ fragmenter av sikkerhetskopien står i kø og er på vei til Drive.",
    "Nothing is waiting in the queue — the backup on Google Drive is complete.":
      "Ingenting venter i køen — sikkerhetskopien på Google Drive er komplett.",
    "rclone did not answer the question about the queue, so it is unknown how many backups are still waiting to be uploaded. This does not mean something broke — under load the answer can be late. It only means that right now nobody knows. If it persists, the backup cycle check will report it.":
      "rclone svarte ikke på spørsmålet om køen, så det er ukjent hvor mange sikkerhetskopier som fortsatt venter på å lastes opp. Dette betyr ikke at noe er ødelagt — under belastning kan svaret komme for sent. Det betyr bare at ingen vet det akkurat nå. Hvis det vedvarer, melder kontrollen av sikkerhetskopisyklusen det.",
    "unknown error":
      "ukjent feil",
    "rclone lsf ended with an error":
      "rclone lsf avsluttet med en feil",
    "This Mac is close to its space limit on Google Drive":
      "Denne Mac-en nærmer seg plassgrensen sin på Google Drive",
    "%@ GB of %@ GB used. Time Machine deletes the oldest backups to stay within its quota; check that the quota is set (vm-status).":
      "%@ GB av %@ GB brukt. Time Machine sletter de eldste sikkerhetskopiene for å holde seg innenfor kvoten; kontroller at kvoten er satt (vm-status).",
    "This Mac is over its space limit on Google Drive":
      "Denne Mac-en har overskredet plassgrensen sin på Google Drive",
    "%@ GB of %@ GB used. Set the Time Machine quota (command in the app window or vm-status), or raise the limit.":
      "%@ GB av %@ GB brukt. Angi Time Machine-kvoten (kommandoen i appvinduet eller vm-status), eller øk grensen.",
    "not set":
      "ikke angitt",
    "%@ GB - usage not measured yet":
      "%@ GB - forbruket er ikke målt ennå",
    "%@ of %@ GB used (%@%%)":
      "%@ av %@ GB brukt (%@%%)",
    "The limit must be a whole number of GB above zero.":
      "Grensen må være et helt tall i GB over null.",
    "machines.json cannot be read, so it was not overwritten. Fix or remove it first.":
      "machines.json kan ikke leses, så den ble ikke overskrevet. Rett eller fjern den først.",
    "'%@' is not a valid folder name: use lowercase letters, digits and dashes.":
      "'%@' er ikke et gyldig mappenavn: bruk små bokstaver, sifre og bindestreker.",
    "This Mac already backs up to folder '%@'. Switching to '%@' would start a new, empty backup and orphan the existing one, so nothing was changed.":
      "Denne Mac-en tar allerede sikkerhetskopi til mappen '%@'. Et bytte til '%@' ville startet en ny, tom sikkerhetskopi og latt den eksisterende bli foreldreløs, så ingenting ble endret.",
    "This Mac already has a CloudMachine installation, whose backup is in folder '%@'. Switching to '%@' would orphan it, so nothing was changed.":
      "Denne Mac-en har allerede en CloudMachine-installasjon, med sikkerhetskopien i mappen '%@'. Et bytte til '%@' ville gjort den foreldreløs, så ingenting ble endret.",
    "Could not save the folder name to %@: %@":
      "Kunne ikke arkivere mappenavnet i %@: %@",
    "Homebrew is not installed. Install it manually: https://brew.sh":
      "Homebrew er ikke installert. Installer det manuelt: https://brew.sh",
    "Installing rclone failed: %@":
      "Installasjon av rclone mislyktes: %@",
    "Installed rclone.":
      "rclone er installert.",
    "Own Google credentials: set.":
      "Egen Google-legitimasjon: angitt.",
    "INCOMPLETE: %@ is missing - rclone will use rclone's shared client_id anyway.":
      "UFULLSTENDIG: %@ mangler - rclone bruker likevel rclones delte client_id.",
    "No own credentials - rclone uses the shared client_id, rate-limited jointly and being retired in 2026.":
      "Ingen egen legitimasjon - rclone bruker det delte client_id, som har felles hastighetsbegrensning og fases ut i 2026.",
    "Empty value - not saving.":
      "Tom verdi - arkiverer ikke.",
    "Keychain refused: %@":
      "Nøkkelringen avviste: %@",
    "DIRTY-TREE":
      "SKITTENT-TRE",
    "Cannot create the working directory: %@":
      "Kan ikke opprette arbeidsmappen: %@",
    "Could not read the rclone version number.":
      "Kunne ikke lese versjonsnummeret til rclone.",
    "Could not download %@.":
      "Kunne ikke laste ned %@.",
    "No entry for %@ in SHA256SUMS.":
      "Ingen oppføring for %@ i SHA256SUMS.",
    "Could not compute the checksum.":
      "Kunne ikke beregne sjekksummen.",
    "SHA256 checksum does not match - NOT installing.\n  expected: %@\n  computed: %@":
      "SHA256-sjekksummen stemmer ikke - installerer IKKE.\n  forventet: %@\n  beregnet: %@",
    "Could not unpack the archive.":
      "Kunne ikke pakke ut arkivet.",
    "Could not install the binary: %@":
      "Kunne ikke installere binærfilen: %@",
    "Installed rclone %@ in %@ (SHA256 checksum matches).":
      "rclone %@ er installert i %@ (SHA256-sjekksummen stemmer).",
    "%@ did not respond within the allotted time (the process was left orphaned in the background).":
      "%@ svarte ikke innen den tillatte tiden (prosessen ble liggende igjen som foreldreløs i bakgrunnen).",
    "Cannot launch %@: %@":
      "Kan ikke starte %@: %@",
    "Remote '%@' already exists and was NOT touched.\nOverwriting it replaces the token and the permission scope; a credential with the 'drive.file' scope does not see files created by the previous one, so the existing backup becomes unreachable.\nIf you really want to replace it, first back up ~/.config/rclone/rclone.conf and run again with --replace-existing.":
      "Remote '%@' finnes allerede og ble IKKE berørt.\nHvis den overskrives, erstattes token og tillatelsesomfang; en legitimasjon med omfanget 'drive.file' ser ikke filer opprettet av den forrige, så den eksisterende sikkerhetskopien blir utilgjengelig.\nHvis du virkelig vil erstatte den, ta først en sikkerhetskopi av ~/.config/rclone/rclone.conf og kjør på nytt med --replace-existing.",
    "Could not check whether remote '%@' already exists (rclone listremotes did not answer or failed), so nothing was changed. Run `%@ listremotes` to see the error, then try again.":
      "Kunne ikke kontrollere om remote '%@' allerede finnes (rclone listremotes svarte ikke eller mislyktes), så ingenting ble endret. Kjør `%@ listremotes` for å se feilen, og prøv deretter igjen.",
    "Could not check whether this Mac already has a CloudMachine installation (rclone did not answer), so no folder was chosen. Try again in a moment.":
      "Kunne ikke kontrollere om denne Mac-en allerede har en CloudMachine-installasjon (rclone svarte ikke), så ingen mappe ble valgt. Prøv igjen om et øyeblikk.",
    "rclone authorize failed (%@). If that binary is missing, start with: cloudmachine-agent install-rclone.":
      "rclone authorize mislyktes (%@). Hvis binærfilen mangler, start med: cloudmachine-agent install-rclone.",
    "Could not read the token from the output of rclone authorize.":
      "Kunne ikke lese tokenet fra utdataene til rclone authorize.",
    "rclone config create failed.":
      "rclone config create mislyktes.",
    "Connected to Google Drive as remote '%@', folder %@.":
      "Tilkoblet Google Drive som remote '%@', mappe %@.",
    "tmutil is not responding - unknown where the backup goes":
      "tmutil svarer ikke - det er ukjent hvor sikkerhetskopien havner",
    "No successful backup for %@":
      "Ingen vellykket sikkerhetskopi på %@",
    "Last COMPLETED backup: %@. The cycle is hourly, so that is %@ missed runs.":
      "Siste FULLFØRTE sikkerhetskopi: %@. Syklusen er hver time, så det er %@ oversette kjøringer.",
    "There is NOT A SINGLE successful backup":
      "Det finnes IKKE EN ENESTE vellykket sikkerhetskopi",
    "The Time Machine preferences contain no date of a completed backup for this destination.":
      "Time Machine-innstillingene inneholder ingen dato for en fullført sikkerhetskopi til denne destinasjonen.",
    "The last backup attempt did not end in a backup":
      "Det siste forsøket på sikkerhetskopiering endte ikke i en sikkerhetskopi",
    "The attempt at %@ is newer than the last successful backup at %@.":
      "Forsøket kl. %@ er nyere enn den siste vellykkede sikkerhetskopien kl. %@.",
    "Time Machine reports an error in the last run (RESULT=%@)":
      "Time Machine melder en feil i den siste kjøringen (RESULT=%@)",
    "A non-zero RESULT in the Time Machine preferences means the run did not succeed.":
      "Et RESULT som ikke er null i Time Machine-innstillingene betyr at kjøringen ikke lyktes.",
    "rclone failed to upload %@ files":
      "rclone klarte ikke å laste opp %@ filer",
    "Buffer full of nothing but unsent data":
      "Bufferen er full av data som ikke er sendt",
    "rclone has nothing left to evict from the buffer - the upload cannot keep up or has stalled.":
      "rclone har ingenting igjen å fjerne fra bufferen - opplastingen klarer ikke å holde følge eller har stoppet opp.",
    "The rclone control interface is not responding":
      "Kontrollgrensesnittet til rclone svarer ikke",
    "Google Drive is running out of space (%@ GB)":
      "Google Drive er i ferd med å gå tom for plass (%@ GB)",
    "The Mac's disk is running out of space (%@ GB)":
      "Disken på Mac-en er i ferd med å gå tom for plass (%@ GB)",
    "Cannot read the Time Machine preferences":
      "Kan ikke lese Time Machine-innstillingene",
    "%@ is unreadable - most often Full Disk Access is missing. Without this file it is UNKNOWN when the last backup was made, so we treat it as a failure, not as the absence of a problem.":
      "%@ kan ikke leses - oftest mangler Full disktilgang. Uten denne filen er det UKJENT når den siste sikkerhetskopien ble tatt, så vi behandler det som en feil og ikke som fravær av et problem.",
    "Cannot measure free space on the Mac's disk":
      "Kan ikke måle ledig plass på disken til Mac-en",
    "%@ days":
      "%@ dager",
    "CloudMachine: backup is not working":
      "CloudMachine: sikkerhetskopieringen fungerer ikke",
    "unknown reason":
      "ukjent årsak",
    "osascript did not show the notification (permissions or no graphical session)":
      "osascript viste ikke varselet (tillatelser eller ingen grafisk økt)",
    "UNDELIVERED ALARM: %@":
      "IKKE LEVERT ALARM: %@",
    "from %@, reason: %@":
      "fra %@, årsak: %@",
    "The system notification was not delivered - you will see this alarm ONLY here.":
      "Systemvarselet ble ikke levert - du ser denne alarmen KUN her.",
    "%@ (%@ ago)":
      "%@ (%@ siden)",
    "%@ - marker from the FUTURE":
      "%@ - markør fra FREMTIDEN",
    "%@ (%@ ago) - THE WATCHDOG MAY NOT BE RUNNING":
      "%@ (%@ siden) - VAKTHUNDEN KJØRER KANSKJE IKKE",
    "NEVER - the watchdog has not recorded a single run":
      "ALDRI - vakthunden har ikke registrert en eneste kjøring",
    "Could not find the launchd/ directory with templates.":
      "Kunne ikke finne mappen launchd/ med maler.",
    "Could not find the compiled cloudmachine-agent binary.":
      "Kunne ikke finne den kompilerte binærfilen cloudmachine-agent.",
    "ABORTED: could not put cloudmachine-agent in a stable location\n(%@) - most often a lack of space or permissions.\nNOT installing agents pointing at %@: that path\ndisappears on the next `swift build` or `git clean`, and backups stop\nwithout any visible signal.":
      "AVBRUTT: kunne ikke plassere cloudmachine-agent på et stabilt sted\n(%@) - oftest mangel på plass eller tillatelser.\nInstallerer IKKE agenter som peker på %@: den stien\nforsvinner ved neste `swift build` eller `git clean`, og sikkerhetskopieringen stopper\nuten noe synlig signal.",
    "ABORTED: %@":
      "AVBRUTT: %@",
    "Could not list the templates in %@.":
      "Kunne ikke liste malene i %@.",
    "could not read the template %@":
      "kunne ikke lese malen %@",
    "could not write %@ (lack of space or permissions)":
      "kunne ikke skrive %@ (mangel på plass eller tillatelser)",
    "launchctl load refused to load %@":
      "launchctl load nektet å laste %@",
    "NOT A SINGLE agent was loaded.":
      "INGEN ENESTE agent ble lastet.",
    "Only these went in: %@.":
      "Bare disse ble installert: %@.",
    "Could not load any launchd agent.":
      "Kunne ikke laste noen launchd-agent.",
    "Installed agents: %@":
      "Installerte agenter: %@",
    "                  WARNING: close to the limit - new bands will fail with EMFILE":
      "                  ADVARSEL: nær grensen - nye bånd vil mislykkes med EMFILE",
    "%@/bands on Google Drive is not empty - it may hold another backup. NOT overwriting it; check it by hand.":
      "%@/bands på Google Drive er ikke tom - den kan inneholde en annen sikkerhetskopi. Overskriver den IKKE; kontroller den manuelt.",
    "Address:          %@":
      "Adresse:          %@",
    "Already prepared (%@ exists) - nothing to do.":
      "Allerede forberedt (%@ finnes) - ingenting å gjøre.",
    "Converts Time Machine's new, empty image in the machine to 32 MB bands and moves the bands to Google Drive.":
      "Konverterer Time Machines nye, tomme diskbilde i maskinen til bånd på 32 MB og flytter båndene til Google Drive.",
    "Copy rclone.conf into the machine even if it already has one.":
      "Kopier rclone.conf inn i maskinen selv om den allerede har en.",
    "Copying the converted image into the machine failed: %@":
      "Kopiering av det konverterte diskbildet inn i maskinen mislyktes: %@",
    "Copying the image to the Mac failed: %@":
      "Kopiering av diskbildet til Mac-en mislyktes: %@",
    "Could not ask Lima about the machine: %@":
      "Kunne ikke spørre Lima om maskinen: %@",
    "Could not carry the Time Machine files over: %@":
      "Kunne ikke overføre Time Machine-filene: %@",
    "Could not check the image in the machine.":
      "Kunne ikke kontrollere diskbildet i maskinen.",
    "Could not copy the rclone configuration into the machine.":
      "Kunne ikke kopiere rclone-konfigurasjonen inn i maskinen.",
    "Could not create %@ on Google Drive: %@":
      "Kunne ikke opprette %@ på Google Drive: %@",
    "Could not create %@: %@":
      "Kunne ikke opprette %@: %@",
    "Could not find the vm/ directory with the machine template.":
      "Kunne ikke finne mappen vm/ med maskinmalen.",
    "Could not read the image size.":
      "Kunne ikke lese størrelsen på diskbildet.",
    "Could not set the SMB password of user %@ in the machine.":
      "Kunne ikke angi SMB-passordet til brukeren %@ i maskinen.",
    "Could not stop smbd in the machine.":
      "Kunne ikke stoppe smbd i maskinen.",
    "Could not write %@ in the machine.":
      "Kunne ikke skrive %@ i maskinen.",
    "Could not write the password file %@.":
      "Kunne ikke skrive passordfilen %@.",
    "Creates or starts the CloudMachine machine (Lima), gives it rclone's configuration and an SMB password, and prints the Time Machine command.":
      "Oppretter eller starter CloudMachine-maskinen (Lima), gir den rclones konfigurasjon og et SMB-passord og skriver ut Time Machine-kommandoen.",
    "Creating the machine %@ (first start downloads Ubuntu and installs packages - several minutes)...":
      "Oppretter maskinen %@ (første start laster ned Ubuntu og installerer pakker - flere minutter)...",
    "Done: %@ has %@ MB bands on Google Drive; the original is kept in %@ in the machine. Start the backup: tmutil startbackup":
      "Ferdig: %@ har bånd på %@ MB på Google Drive; originalen oppbevares i %@ i maskinen. Start sikkerhetskopieringen: tmutil startbackup",
    "exit code %@, no message":
      "avslutningskode %@, ingen melding",
    "Image metadata:   NEVER copied to %@ - check tm-meta-sync in the machine":
      "Diskbildemetadata: ALDRI kopiert til %@ - sjekk tm-meta-sync i maskinen",
    "Image metadata:   copied %@ ago to %@":
      "Diskbildemetadata: kopiert for %@ siden til %@",
    "Image metadata:   last copied %@ ago - OVERDUE (%@)":
      "Diskbildemetadata: sist kopiert for %@ siden - FORSINKET (%@)",
    "Image metadata:   not copied yet - waits for vm-prepare-bundle":
      "Diskbildemetadata: ikke kopiert ennå - venter på vm-prepare-bundle",
    "Backup %@, paused by the guard %@: %@":
      "Sikkerhetskopi %@, satt på pause av vakten %@: %@",
    "Free in machine:  %@ GiB":
      "Ledig i maskinen: %@ GiB",
    "fsck_apfs -n found problems: %@":
      "fsck_apfs -n fant problemer: %@",
    "Google Drive folder: %@":
      "Google Drive-mappe: %@",
    "hdiutil attach of the converted image failed: %@":
      "hdiutil attach av det konverterte diskbildet mislyktes: %@",
    "hdiutil convert failed: %@":
      "hdiutil convert mislyktes: %@",
    "Image name in the machine (default: from the computer name).":
      "Navnet på diskbildet i maskinen (standard: avledet av datamaskinens navn).",
    "Installing the converted image FAILED: %@\nsmbd is left STOPPED so Time Machine does not open a half-installed image. The original is in %@ in the machine.":
      "Installasjon av det konverterte diskbildet MISLYKTES: %@\nsmbd er lagt igjen STOPPET, slik at Time Machine ikke åpner et halvt installert diskbilde. Originalen ligger i %@ i maskinen.",
    "limactl create failed: %@":
      "limactl create mislyktes: %@",
    "limactl list failed: %@":
      "limactl list mislyktes: %@",
    "limactl not found - install Lima: brew install lima":
      "limactl ble ikke funnet - installer Lima: brew install lima",
    "limactl start failed: %@\nThe machine's own log: %@":
      "limactl start mislyktes: %@\nMaskinens egen logg: %@",
    "Machine %@ is running.":
      "Maskinen %@ kjører.",
    "Machine %@ was already running.":
      "Maskinen %@ kjørte allerede.",
    "Machine:          %@ (%@)":
      "Maskin:           %@ (%@)",
    "Machine:          %@":
      "Maskin:           %@",
    "Machine:          not created - run: cloudmachine-agent vm-setup":
      "Maskin:           ikke opprettet - kjør: cloudmachine-agent vm-setup",
    "no answer within the time limit":
      "ingen svar innen tidsgrensen",
    "No image %@ in the machine.":
      "Ingen diskbilde %@ i maskinen.",
    "No image in the machine yet - point Time Machine at the share and let it create one first.":
      "Ingen diskbilde i maskinen ennå - pek Time Machine på delingen, og la den opprette ett først.",
    "No rclone configuration at %@ - connect Google Drive first (configure-remote).":
      "Ingen rclone-konfigurasjon i %@ - koble først til Google Drive (configure-remote).",
    "no SMB destination":
      "ingen SMB-destinasjon",
    "One check of the machine's upload buffer: pauses Time Machine when it fills, resumes what it paused.":
      "Én kontroll av maskinens opplastingsbuffer: setter Time Machine på pause når den fylles, og gjenopptar det den satte på pause.",
    "Packing the converted image failed: %@":
      "Pakking av det konverterte diskbildet mislyktes: %@",
    "Packing the image failed: %@":
      "Pakking av diskbildet mislyktes: %@",
    "No answer from the machine (rclone rc) - the guard would do nothing.":
      "Ingen svar fra maskinen (rclone rc) - vakten ville ikke gjort noe.",
    "Only print what the guard would decide - for trying thresholds on a throwaway machine.":
      "Skriv bare ut hva vakten ville bestemt - for å prøve terskler på en engangsmaskin.",
    "Pause above this many GiB in the buffer.":
      "Sett på pause over så mange GiB i bufferen.",
    "Pause when the machine has less free than this, in GiB.":
      "Sett på pause når maskinen har mindre ledig plass enn dette, i GiB.",
    "Point Time Machine at the machine (once, needs an administrator password):":
      "Pek Time Machine på maskinen (én gang, krever et administratorpassord):",
    "punchfs files:    %@ open, limit %@":
      "punchfs-filer:    %@ åpne, grense %@",
    "rclone configuration already in the machine - kept (--replace-rclone-config replaces it).":
      "rclone-konfigurasjonen finnes allerede i maskinen - beholdt (--replace-rclone-config erstatter den).",
    "rclone configuration copied into the machine.":
      "rclone-konfigurasjonen er kopiert inn i maskinen.",
    "rclone-tm or punchfs is not running in the machine - see cloudmachine-agent vm-status.":
      "rclone-tm eller punchfs kjører ikke i maskinen - se cloudmachine-agent vm-status.",
    "Resume below this many GiB (only a backup the guard paused).":
      "Gjenoppta under så mange GiB (bare en sikkerhetskopi som vakten satte på pause).",
    "Service %@: %@":
      "Tjeneste %@: %@",
    "Several images in the machine (%@) - choose one with --bundle.":
      "Flere diskbilder i maskinen (%@) - velg ett med --bundle.",
    "Shows the machine: address, services, upload buffer, free space and the Time Machine destination.":
      "Viser maskinen: adresse, tjenester, opplastingsbuffer, ledig plass og Time Machine-destinasjonen.",
    "SMB password stored in %@ (mode 600).":
      "SMB-passordet er arkivert i %@ (modus 600).",
    "The converted image does not have %@-byte bands.":
      "Det konverterte diskbildet har ikke bånd på %@ byte.",
    "The converted image has no APFS partition.":
      "Det konverterte diskbildet har ingen APFS-partisjon.",
    "The image already takes %@ MB - this command converts only a new, empty image (under %@ MB).":
      "Diskbildet tar allerede %@ MB - denne kommandoen konverterer bare et nytt, tomt diskbilde (under %@ MB).",
    "The image is encrypted - converting encrypted images is not supported.":
      "Diskbildet er kryptert - konvertering av krypterte diskbilder støttes ikke.",
    "The image was not changed; smbd started again.":
      "Diskbildet ble ikke endret; smbd startet igjen.",
    "The machine does not answer - is it running? cloudmachine-agent vm-status":
      "Maskinen svarer ikke - kjører den? cloudmachine-agent vm-status",
    "The machine has no address on the vzNAT network.":
      "Maskinen har ingen adresse på vzNAT-nettverket.",
    "The services in the machine did not start - check: cloudmachine-agent vm-status":
      "Tjenestene i maskinen startet ikke - kontroller: cloudmachine-agent vm-status",
    "Time Machine is backing up - stop it first: tmutil stopbackup":
      "Time Machine tar sikkerhetskopi - stopp den først: tmutil stopbackup",
    "Time Machine:     %@":
      "Time Machine:      %@",
    "Time Machine:     NOT pointing at the machine (%@)":
      "Time Machine:      PEKER IKKE på maskinen (%@)",
    "Time Machine:     tmutil did not answer":
      "Time Machine:      tmutil svarte ikke",
    "tmutil did not answer - not touching the image while its state is unknown.":
      "tmutil svarte ikke - rører ikke diskbildet mens tilstanden er ukjent.",
    "unknown":
      "ukjent",
    "Unpacking the image failed: %@":
      "Utpakking av diskbildet mislyktes: %@",
    "Still to upload:  %@ GiB in %@ bands, uploading %@ (cache on disk %@ GiB)":
      "Gjenstår å laste opp: %@ GiB i %@ bånd, laster opp %@ (hurtigbuffer på disk %@ GiB)",
    "Excluded %@ (the machine and its upload buffer) from Time Machine.":
      "%@ (maskinen og opplastingsbufferen) er utelatt fra Time Machine.",
    "WARNING: could not exclude %@ from Time Machine - run: tmutil addexclusion %@":
      "ADVARSEL: kunne ikke utelate %@ fra Time Machine - kjør: tmutil addexclusion %@",
    "Upload buffer:    no answer from rclone (rc %@)":
      "Opplastingsbuffer: ingen svar fra rclone (rc %@)",
    "When Time Machine has created its empty image, stop the backup (tmutil stopbackup) and run: cloudmachine-agent vm-prepare-bundle":
      "Når Time Machine har opprettet det tomme diskbildet sitt, stopp sikkerhetskopieringen (tmutil stopbackup) og kjør: cloudmachine-agent vm-prepare-bundle",
    "Unsent %@ GiB, free %@ GiB (pause above %@ GiB unsent or below %@ GiB free, resume below %@ GiB).":
      "Ikke sendt %@ GiB, ledig %@ GiB (pause over %@ GiB ikke sendt eller under %@ GiB ledig, gjenoppta under %@ GiB).",
    "Upload:           Google's daily limit refused an upload %@ ago - rclone retries every 5 min and resumes by itself":
      "Opplasting:        Googles daglige grense avviste en opplasting for %@ siden - rclone prøver på nytt hvert 5. minutt og fortsetter av seg selv",
    "no":
      "nei",
    "running":
      "kjører",
    "stopped":
      "stoppet",
    "yes":
      "ja",
    "%@\nThe previous template is in %@ - copy it back over lima.yaml and run limactl start %@.":
      "%@\nDen forrige malen ligger i %@ - kopier den tilbake over lima.yaml, og kjør limactl start %@.",
    "Could not read this app's machine template (limactl template copy).":
      "Kunne ikke lese maskinmalen til denne appen (limactl template copy).",
    "Could not replace %@: %@":
      "Kunne ikke erstatte %@: %@",
    "Machine %@ already runs this app's template.":
      "Maskinen %@ kjører allerede malen til denne appen.",
    "Machine %@ now runs this app's template; the previous one is in %@.":
      "Maskinen %@ kjører nå malen til denne appen; den forrige ligger i %@.",
    "Moves the machine onto this app's template (two restarts, never during a backup).":
      "Flytter maskinen over til malen til denne appen (to omstarter, aldri under en sikkerhetskopiering).",
    "No machine %@ - create it with: cloudmachine-agent vm-setup":
      "Ingen maskin %@ - opprett den med: cloudmachine-agent vm-setup",
    "Template:         OLDER than this app's - run: cloudmachine-agent vm-update":
      "Mal:              ELDRE enn denne appens - kjør: cloudmachine-agent vm-update",
    "Template:         not compared":
      "Mal:              ikke sammenlignet",
    "Template:         this app's":
      "Mal:              denne appens",
    "The machine has no %@ - run cloudmachine-agent vm-setup first.":
      "Maskinen har ingen %@ - kjør cloudmachine-agent vm-setup først.",
    "The machine restarted, but not every service is running - check: cloudmachine-agent vm-status. The previous template is in %@.":
      "Maskinen ble startet på nytt, men ikke alle tjenester kjører - kontroller: cloudmachine-agent vm-status. Den forrige malen ligger i %@.",
    "The template changes the machine itself (%@) - that needs a new machine, not an update.":
      "Malen endrer selve maskinen (%@) - det krever en ny maskin, ikke en oppdatering.",
    "The upload to Google Drive hangs":
      "Opplastingen til Google Drive henger",
    "Time Machine is backing up - try again when it has finished.":
      "Time Machine tar sikkerhetskopi - prøv igjen når den er ferdig.",
    "Upload:           HANGS - bands in progress, none uploaded for %@ (network?); see /var/log/rclone-tm.log in the machine":
      "Opplasting:        HENGER - bånd pågår, ingen lastet opp på %@ (nettverk?); se /var/log/rclone-tm.log i maskinen",
    "limactl stop failed - nothing was changed.":
      "limactl stop mislyktes - ingenting ble endret.",
    "rclone has bands in progress, but none has been uploaded for %@ - usually a broken network connection, which rclone does not report as an error. Backups since then are only in the machine's buffer. When the network comes back the upload resumes by itself (on 28.10.2026 within 80 s); if it does not, restarting the machine (prepare-shutdown, limactl start) drops the dead connections.":
      "rclone har bånd under behandling, men ingen er lastet opp på %@ - vanligvis en brutt nettverkstilkobling, som rclone ikke melder som en feil. Sikkerhetskopier siden da ligger bare i maskinens buffer. Når nettverket kommer tilbake, fortsetter opplastingen av seg selv (den 28.10.2026 innen 80 s); hvis ikke, fjerner en omstart av maskinen (prepare-shutdown, limactl start) de døde tilkoblingene.",
    "tmutil did not answer - not restarting the machine while its state is unknown.":
      "tmutil svarte ikke - starter ikke maskinen på nytt mens tilstanden er ukjent.",
  ]
}
