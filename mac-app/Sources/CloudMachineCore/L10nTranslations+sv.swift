// Swedish translations, keyed by the English text passed to `L10n.tr`.
extension L10nTranslations {
  static let sv: [String: String] = [
    "Space limit:      %@":
      "Utrymmesgräns:    %@",
    "                  Time Machine quota not set to match - run: %@":
      "                  Time Machine-kvoten är inte inställd så att den passar - kör: %@",
    "Sets how much of Google Drive this Mac may use, and prints the Time Machine quota command.":
      "Anger hur mycket av Google Drive den här Macen får använda och skriver ut kommandot för Time Machine-kvoten.",
    "Limit in GB.":
      "Gräns i GB.",
    "Limit for this Mac: %@ GB.":
      "Gräns för den här Macen: %@ GB.",
    "Now set the Time Machine quota (needs an administrator password):":
      "Ange nu Time Machine-kvoten (kräver administratörslösenord):",
    "CloudMachine - verification, Google Drive setup and installation. Called by launchd on a schedule, or by hand from Terminal.":
      "CloudMachine - verifiering, konfiguration av Google Drive och installation. Anropas av launchd enligt schema eller manuellt från Terminal.",
    "Connects to Google Drive through rclone (OAuth in the browser) and creates this machine's folder.":
      "Ansluter till Google Drive via rclone (OAuth i webbläsaren) och skapar maskinens mapp.",
    "Overwrite the existing remote. RISKY: replaces the token and permissions.":
      "Skriv över den befintliga remoten. RISKABELT: ersätter token och behörigheter.",
    "Packs build/CloudMachine.app into build/CloudMachine-<version>.dmg.":
      "Paketerar build/CloudMachine.app till build/CloudMachine-<version>.dmg.",
    "ERROR: %@ is missing - run 'cloudmachine-agent build-app' first":
      "FEL: %@ saknas - kör först 'cloudmachine-agent build-app'",
    "==> Preparing the staging folder":
      "==> Förbereder mellanlagringsmappen",
    "==> Creating %@":
      "==> Skapar %@",
    "ERROR: hdiutil exited with code %@.":
      "FEL: hdiutil avslutades med kod %@.",
    "==> Done: %@":
      "==> Klart: %@",
    "On first launch (the app is not signed with an Apple Developer account):":
      "Vid första start (appen är inte signerad med ett Apple Developer-konto):",
    "1. Open %@ and drag CloudMachine.app to Applications.":
      "1. Öppna %@ och dra CloudMachine.app till Program.",
    "2. In Finder, RIGHT-click CloudMachine.app -> Open -> Open\n   (a plain double-click shows the Gatekeeper block \"unidentified developer\").":
      "2. HÖGERKLICKA på CloudMachine.app i Finder -> Öppna -> Öppna\n   (ett vanligt dubbelklick visar Gatekeeper-spärren ”oidentifierad utvecklare”).",
    "3. Later launches work normally, with a double-click.":
      "3. Senare starter fungerar som vanligt, med dubbelklick.",
    "Builds CloudMachine.app (Release) - GUI + cloudmachine-agent in Contents/MacOS/, plus launchd/, vm/ and config/ as Resources.":
      "Bygger CloudMachine.app (Release) - GUI + cloudmachine-agent i Contents/MacOS/, plus launchd/, vm/ och config/ som Resources.",
    "Binaries for Apple Silicon and Intel at once (how CI builds a release; unnecessary locally).":
      "Binärfiler för Apple Silicon och Intel samtidigt (så bygger CI en release; onödigt lokalt).",
    "==> Building CloudMachineApp + cloudmachine-agent (release) - version %@ (%@)":
      "==> Bygger CloudMachineApp + cloudmachine-agent (release) - version %@ (%@)",
    "ERROR: swift build exited with code %@.":
      "FEL: swift build avslutades med kod %@.",
    "ERROR: swift build --show-bin-path did not report the binaries directory.":
      "FEL: swift build --show-bin-path angav ingen katalog för binärfilerna.",
    "ERROR: no built binary found at %@":
      "FEL: ingen byggd binärfil hittades på %@",
    "==> Assembling the .app bundle in %@":
      "==> Sätter ihop .app-paketet i %@",
    "==> WARNING: you are building from a DIRTY tree - the version will not point to a commit.":
      "==> VARNING: du bygger från ett OSTÄDAT träd - versionen pekar inte på någon commit.",
    "ERROR: Resources/AppIcon.icns is missing - generate it: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns":
      "FEL: Resources/AppIcon.icns saknas - generera den: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns",
    "==> Signing with the local certificate '%@' (Full Disk Access will survive later rebuilds)":
      "==> Signerar med det lokala certifikatet '%@' (Full åtkomst till disken bevaras vid senare ombyggnader)",
    "==> Signing ad-hoc (no Apple Developer account) - run 'cloudmachine-agent setup-signing-cert' once so that TCC permissions survive later rebuilds":
      "==> Signerar ad hoc (inget Apple Developer-konto) - kör 'cloudmachine-agent setup-signing-cert' en gång så att TCC-behörigheter bevaras vid senare ombyggnader",
    "ERROR: codesign exited with code %@.":
      "FEL: codesign avslutades med kod %@.",
    "Next step: %@":
      "Nästa steg: %@",
    "Creates a local self-signed certificate so that Full Disk Access survives later rebuilds of the app.":
      "Skapar ett lokalt självsignerat certifikat så att Full åtkomst till disken bevaras vid senare ombyggnader av appen.",
    "Certificate '%@' already exists in %@, nothing to do.":
      "Certifikatet '%@' finns redan i %@, inget att göra.",
    "==> Generating the key and self-signed certificate '%@'...":
      "==> Genererar nyckeln och det självsignerade certifikatet '%@'...",
    "ERROR: openssl req exited with code %@.":
      "FEL: openssl req avslutades med kod %@.",
    "ERROR: openssl pkcs12 exited with code %@.":
      "FEL: openssl pkcs12 avslutades med kod %@.",
    "==> Importing the certificate into %@ (pre-authorizing /usr/bin/codesign, so it does not ask for the keychain password every time)...":
      "==> Importerar certifikatet till %@ (förauktoriserar /usr/bin/codesign, så att det inte frågar efter nyckelringens lösenord varje gång)...",
    "ERROR: security import exited with code %@.":
      "FEL: security import avslutades med kod %@.",
    "==> Trusting the certificate ONLY for code signing...":
      "==> Litar på certifikatet ENDAST för kodsignering...",
    "ERROR: security add-trusted-cert exited with code %@.":
      "FEL: security add-trusted-cert avslutades med kod %@.",
    "Done. Certificate '%@' is now available to codesign.":
      "Klart. Certifikatet '%@' är nu tillgängligt för codesign.",
    "The next 'cloudmachine-agent build-app' will use it automatically instead of an ad-hoc signature.":
      "Nästa 'cloudmachine-agent build-app' använder det automatiskt i stället för en ad hoc-signatur.",
    "After THAT ONE rebuild, grant Full Disk Access one last time - later\nrebuilds will no longer reset it, as long as you sign with the same certificate.":
      "Efter DEN HÄR ENA ombyggnaden ger du Full åtkomst till disken en sista gång - senare\nombyggnader återställer den inte längre, så länge du signerar med samma certifikat.",
    "Checks whether the hourly cycle STILL works (date of the last SUCCESSFUL backup) and reports failures.":
      "Kontrollerar om den timvisa cykeln FORTFARANDE fungerar (datum för den senaste LYCKADE säkerhetskopian) och rapporterar fel.",
    "After this many hours without a successful backup we consider the cycle broken.":
      "Efter så många timmar utan lyckad säkerhetskopia anser vi att cykeln är bruten.",
    "Only print the state, without a system notification.":
      "Skriv bara ut tillståndet, utan systemavisering.",
    "A different Time Machine preferences file - to test the watchdog on a known sample.":
      "En annan inställningsfil för Time Machine - för att testa bevakaren på ett känt prov.",
    "Last successful backup: %@":
      "Senaste lyckade säkerhetskopia: %@",
    "Last successful backup: NONE":
      "Senaste lyckade säkerhetskopia: INGEN",
    "Last attempt:           %@":
      "Senaste försök:         %@",
    "WAITING (system startup): %@":
      "VÄNTAR (systemstart): %@",
    "Backup cycle: OK":
      "Säkerhetskopieringscykel: OK",
    "FAILURE: %@":
      "HAVERI: %@",
    "         %@":
      "         %@",
    "Check the state:  %@":
      "Kontrollera tillståndet:  %@",
    "Preparing for restart":
      "Förbereder för omstart",
    "Prepare for restart":
      "Förbered för omstart",
    "Prepare":
      "Förbered",
    "==> WARNING: git rev-list failed (%@) - using the date as the build number.":
      "==> VARNING: git rev-list misslyckades (%@) - datumet används som byggnummer.",
    "Agents:           %@":
      "Agenter:          %@",
    "CANNOT START: %@ - open CloudMachine or run backup-health to reload them":
      "KAN INTE STARTA: %@ - öppna CloudMachine eller kör backup-health för att läsa in dem igen",
    "Reloaded agents that could not start: %@":
      "Agenter som inte kunde starta lästes in igen: %@",
    "Drive folder:     %@":
      "Drive-mapp:       %@",
    "Name of this Mac's folder on Google Drive (default: derived from the computer name). Set once; it cannot be changed later.":
      "Namnet på den här Macens mapp på Google Drive (standard: härlett från datornamnet). Anges en gång; kan inte ändras senare.",
    "Backup watchdog:  %@":
      "Bevakare:         %@",
    "Prints the version, the build number and the commit this binary was built from.":
      "Skriver ut versionen, byggnumret och den commit som den här binärfilen byggdes från.",
    "Only one line, without a description.":
      "Bara en rad, utan beskrivning.",
    "Build from the working tree (outside a bundle) - no version data.":
      "Bygge från arbetsträdet (utanför ett paket) - inga versionsuppgifter.",
    "Version: %@":
      "Version: %@",
    "Build:   %@":
      "Bygge:   %@",
    "Commit:  %@":
      "Commit:  %@",
    "WARNING: built from a DIRTY tree - the binary contains code that\n         is in no commit. The commit number does NOT describe\n         what actually runs.":
      "VARNING: byggd från ett OSTÄDAT träd - binärfilen innehåller kod som\n         inte finns i någon commit. Commit-numret beskriver INTE\n         vad som faktiskt körs.",
    "Saving the space limit":
      "Sparar utrymmesgränsen",
    "Measuring usage on Google Drive":
      "Mäter användningen på Google Drive",
    "Google Drive did not answer - try again later.":
      "Google Drive svarade inte - försök igen senare.",
    "Measured.":
      "Mätt.",
    "Space limit for this Mac":
      "Utrymmesgräns för den här Macen",
    "Used on Google Drive":
      "Använt på Google Drive",
    "Measured %@. The watchdog measures again every few hours.":
      "Mätt %@. Bevakaren mäter igen med några timmars mellanrum.",
    "Limit (GB)":
      "Gräns (GB)",
    "Save":
      "Spara",
    "Measure now":
      "Mät nu",
    "Time Machine quota: %@ GB (70%% of the limit - the copy on Drive is about a third larger than the backup inside it). Time Machine deletes the oldest backups to stay within it.":
      "Time Machine-kvot: %@ GB (70%% av gränsen - kopian på Drive är ungefär en tredjedel större än säkerhetskopian i den). Time Machine tar bort de äldsta säkerhetskopiorna för att hålla sig inom den.",
    "Set the Time Machine quota: run this in Terminal (needs sudo)":
      "Ange Time Machine-kvoten: kör det här i Terminal (kräver sudo)",
    "Connect Google Drive: run this in Terminal and approve in the browser":
      "Anslut Google Drive: kör det här i Terminal och godkänn i webbläsaren",
    "Grant Full Disk Access to CloudMachine, so it can tell whether backups complete":
      "Ge CloudMachine Full åtkomst till disken så att den kan se om säkerhetskopiorna slutförs",
    "Folder on Google Drive":
      "Mapp på Google Drive",
    "One folder per Mac. Set once - it cannot be changed after connecting.":
      "En mapp per Mac. Anges en gång - kan inte ändras efter anslutning.",
    "Use lowercase letters, digits and dashes.":
      "Använd små bokstäver, siffror och bindestreck.",
    "Install rclone":
      "Installera rclone",
    "Open System Settings":
      "Öppna Systeminställningar",
    "Install agents":
      "Installera agenter",
    "not checked":
      "inte kontrollerad",
    "none at all":
      "inga alls",
    "%@ ago":
      "%@ sedan",
    "Missing: %@":
      "Saknas: %@",
    "Google Drive not connected":
      "Google Drive är inte anslutet",
    "Time Machine does not point to CloudMachine":
      "Time Machine pekar inte på CloudMachine",
    "UNKNOWN whether Time Machine points to CloudMachine - tmutil did not answer":
      "OKLART om Time Machine pekar på CloudMachine - tmutil svarade inte",
    "Backup in progress":
      "Säkerhetskopiering pågår",
    "Unknown when the last backup was made":
      "Okänt när den senaste säkerhetskopian gjordes",
    "There is no completed backup at all":
      "Det finns ingen slutförd säkerhetskopia alls",
    "No completed backup for %@":
      "Ingen slutförd säkerhetskopia på %@",
    "Ready":
      "Redo",
    "Not saved: %@":
      "Inte sparad: %@",
    "Installing rclone":
      "Installerar rclone",
    "Installing launchd agents":
      "Installerar launchd-agenter",
    "Starting backup":
      "Startar säkerhetskopiering",
    "Backup started.":
      "Säkerhetskopieringen har startat.",
    "Could not start the backup.":
      "Det gick inte att starta säkerhetskopieringen.",
    "Stopping backup":
      "Stoppar säkerhetskopiering",
    "Backup stopped.":
      "Säkerhetskopieringen har stoppats.",
    "Could not stop the backup.":
      "Det gick inte att stoppa säkerhetskopieringen.",
    "Could not prepare the AppleScript.":
      "Det gick inte att förbereda AppleScript.",
    "Unknown authorization error.":
      "Okänt auktoriseringsfel.",
    "Waiting to upload":
      "Väntar på uppladdning",
    "%@ files":
      "Filer: %@",
    "nothing":
      "ingenting",
    "Back up now":
      "Säkerhetskopiera nu",
    "Stop backup":
      "Stoppa säkerhetskopiering",
    "Open CloudMachine":
      "Öppna CloudMachine",
    "Quit":
      "Avsluta",
    "Healthy":
      "Fungerar",
    "Attention":
      "Observera",
    "Refreshed %@":
      "Uppdaterad %@",
    "System Status":
      "Systemstatus",
    "Action needed":
      "Åtgärd krävs",
    "not measured":
      "inte mätt",
    "rclone did not answer":
      "rclone svarade inte",
    "Backup in Progress":
      "Säkerhetskopiering pågår",
    "Files processed":
      "Behandlade filer",
    "Write speed":
      "Skrivhastighet",
    "Operation phase":
      "Åtgärdsfas",
    "Required Setup Steps":
      "Nödvändiga installationssteg",
    "Copy":
      "Kopiera",
    "Last completed backup":
      "Senaste slutförda säkerhetskopia",
    "Last backup watchdog run":
      "Bevakarens senaste körning",
    "not read":
      "inte avläst",
    "Everything uploaded":
      "Allt uppladdat",
    "File upload errors":
      "Fel vid filuppladdning",
    "Google Drive Credentials (OAuth 2.0)":
      "Autentiseringsuppgifter för Google Drive (OAuth 2.0)",
    "Keychain OK":
      "Nyckelringen OK",
    "No custom keys":
      "Inga egna nycklar",
    "Paste client_id...":
      "Klistra in client_id...",
    "Paste client_secret...":
      "Klistra in client_secret...",
    "Save securely in the Keychain":
      "Spara säkert i Nyckelringen",
    "Refresh":
      "Uppdatera",
    "Overview":
      "Översikt",
    "Backups":
      "Säkerhetskopior",
    "Storage":
      "Lagring",
    "Settings":
      "Inställningar",
    "Current status: %@":
      "Aktuell status: %@",
    "Does not point to CloudMachine":
      "Pekar inte på CloudMachine",
    "tmutil did not answer":
      "tmutil svarade inte",
    "Backing up: %@ of %@":
      "Säkerhetskopierar: %@ av %@",
    "%@ of %@":
      "%@ av %@",
    "Copied":
      "Kopierat",
    "No backup is running":
      "Ingen säkerhetskopiering pågår",
    "Time Machine starts the next one on its own schedule.":
      "Time Machine startar nästa enligt sitt eget schema.",
    "Backup cycle":
      "Säkerhetskopieringscykel",
    "%@ GiB":
      "%@ GiB",
    "%@ GiB in %@ bands, %@ uploading":
      "%@ GiB i %@ band, %@ laddas upp",
    "%@ bands":
      "%@ band",
    "%@ fragments abandoned - only in the machine":
      "%@ övergivna fragment - finns bara i maskinen",
    "127.0.0.1:5572 answers on the Mac: Lima forwards the machine's rclone remote control, which has no password. Any web page open in a browser can send it commands - including deleting the backup on Google Drive. Add the portForwards rule from vm/cmsmb.yaml to the machine and restart it (see vm/README.md).":
      "127.0.0.1:5572 svarar på Macen: Lima vidarebefordrar maskinens fjärrstyrning av rclone, som saknar lösenord. Vilken webbsida som helst som är öppen i en webbläsare kan skicka kommandon till den - även radera säkerhetskopian på Google Drive. Lägg till portForwards-regeln från vm/cmsmb.yaml i maskinen och starta om den (se vm/README.md).",
    "A service in the CloudMachine machine is not running":
      "En tjänst i CloudMachine-maskinen körs inte",
    "Address":
      "Adress",
    "Agent installation INCOMPLETE - %@ of %@ did not go in:\n%@\n%@\nEvery missing agent is a function that has silently stopped working (vm-guard watches the machine's buffer, backup-health reports failures). Fix the cause and repeat the installation.":
      "Installationen av agenter är OFULLSTÄNDIG - %@ av %@ kom inte på plats:\n%@\n%@\nVarje saknad agent är en funktion som tyst har slutat fungera (vm-guard bevakar maskinens buffert, backup-health rapporterar fel). Åtgärda orsaken och upprepa installationen.",
    "All running":
      "Alla körs",
    "Also install the launchd agents (same as install-launchd).":
      "Installera även launchd-agenterna (samma som install-launchd).",
    "At most this many minutes of waiting for the upload.":
      "Väntar högst så många minuter på uppladdningen.",
    "At the limit every new band fails with EMFILE and the backup stops. Check: cloudmachine-agent vm-status":
      "Vid gränsen misslyckas varje nytt band med EMFILE och säkerhetskopieringen stannar. Kontrollera: cloudmachine-agent vm-status",
    "Cache on the machine's disk":
      "Cache på maskinens disk",
    "Connected to Google Drive, but could not create the folder '%@' - without it the machine has nowhere to keep the backup. Check the account permissions and try again.":
      "Ansluten till Google Drive, men kunde inte skapa mappen '%@' - utan den har maskinen ingenstans att förvara säkerhetskopian. Kontrollera kontots behörigheter och försök igen.",
    "Convert the image":
      "Konvertera avbilden",
    "Converting the image to 32 MB bands":
      "Konverterar avbilden till band på 32 MB",
    "Could not check with the current connection whether the backup is on Google Drive (%@), so remote '%@' was NOT replaced: without that answer the new sign-in cannot be checked against it.":
      "Kunde inte kontrollera med den nuvarande anslutningen om säkerhetskopian finns på Google Drive (%@), så remote '%@' ersattes INTE: utan det svaret går det inte att jämföra den nya inloggningen med den.",
    "Downloads the official rclone binary into ~/.cloudmachine/bin (Google sign-in and the machine's rclone.conf).":
      "Hämtar den officiella rclone-binärfilen till ~/.cloudmachine/bin (Google-inloggning och maskinens rclone.conf).",
    "Free in the machine":
      "Ledigt i maskinen",
    "Free in the machine: %@":
      "Ledigt i maskinen: %@",
    "Generates and installs the launchd agents (app, backup watchdog, machine start, machine guard).":
      "Genererar och installerar launchd-agenterna (appen, säkerhetskopieringsbevakaren, maskinstart, maskinvakten).",
    "Install Lima, which runs the CloudMachine machine: run this in Terminal":
      "Installera Lima, som kör CloudMachine-maskinen: kör det här i Terminal",
    "Install rclone (signs in to Google Drive for the machine)":
      "Installera rclone (loggar in maskinen på Google Drive)",
    "Install the background agents (machine start, buffer guard, backup watchdog)":
      "Installera bakgrundsagenterna (maskinstart, buffertvakt, säkerhetskopieringsbevakare)",
    "Installs rclone through Homebrew - CloudMachine itself uses the one from install-rclone.":
      "Installerar rclone via Homebrew - CloudMachine själv använder den från install-rclone.",
    "Info.plist, token and mapped/ of the backup image exist only on the machine's disk; without them the bands in %@ cannot be restored. The copy (tm-meta-sync, every 15 min) goes to %@. Check: cloudmachine-agent vm-status, then in the machine: journalctl -u tm-meta-sync":
      "Info.plist, token och mapped/ för säkerhetskopieavbilden finns bara på maskinens disk; utan dem går det inte att återställa banden i %@. Kopian (tm-meta-sync, var 15:e min) hamnar i %@. Kontrollera: cloudmachine-agent vm-status, sedan i maskinen: journalctl -u tm-meta-sync",
    "Lima says the machine is running, but a command in it did not return. Without it nothing is known about Samba, rclone or the upload. Check: cloudmachine-agent vm-status":
      "Lima säger att maskinen körs, men ett kommando i den returnerade inte. Utan det vet man inget om Samba, rclone eller uppladdningen. Kontrollera: cloudmachine-agent vm-status",
    "Machine":
      "Maskin",
    "Machine %@":
      "Maskin %@",
    "Machine & Upload Status":
      "Maskin och uppladdningsstatus",
    "Machine buffer":
      "Maskinens buffert",
    "No Time Machine destination is the machine's share (smb://tm@<address>/CloudMachine) - backups are not being made there. The command is printed by: cloudmachine-agent vm-setup":
      "Ingen Time Machine-destination är maskinens resurs (smb://tm@<adress>/CloudMachine) - säkerhetskopior görs inte dit. Kommandot skrivs ut av: cloudmachine-agent vm-setup",
    "Not running: %@":
      "Körs inte: %@",
    "Not set up":
      "Inte konfigurerad",
    "Once it runs out, rclone stops uploading, the machine's buffer fills up and backups stop being made. At a growth of ~600 MB per hourly cycle that is about %@ days.":
      "När det tar slut slutar rclone ladda upp, maskinens buffert fylls och säkerhetskopior slutar skapas. Vid en tillväxt på ~600 MB per timcykel är det cirka %@ dygn.",
    "Or rclone.conf is missing: this Mac has already set up the CloudMachine machine, so it is not connected anew blindly. Restore the file from a backup (the machine keeps its own copy in %@). To connect anyway, create an empty file at the path `%@ config file` prints and run again - the existing folder is kept.":
      "Eller så saknas rclone.conf: den här Macen har redan konfigurerat CloudMachine-maskinen, så den ansluts inte på nytt på måfå. Återställ filen från en säkerhetskopia (maskinen har en egen kopia i %@). För att ansluta ändå, skapa en tom fil på den sökväg som `%@ config file` skriver ut och kör igen - den befintliga mappen behålls.",
    "Point Time Machine at the machine: run this in Terminal (needs sudo; Copy includes the password)":
      "Rikta Time Machine mot maskinen: kör det här i Terminal (kräver sudo; Kopiera inkluderar lösenordet)",
    "Points to the machine":
      "Pekar på maskinen",
    "Prepares for a restart: stops the backup, waits a while for the upload, then stops the machine cleanly.":
      "Förbereder för omstart: stoppar säkerhetskopieringen, väntar en stund på uppladdningen och stoppar sedan maskinen på ett rent sätt.",
    "Reading the Time Machine destination did not return within %@ s. That is how tmutil behaves when its destination hangs.":
      "Avläsningen av Time Machine-destinationen returnerade inte inom %@ s. Så beter sig tmutil när dess destination hänger sig.",
    "Remote '%@' was NOT replaced. The new sign-in gets the 'drive.file' scope, which sees only files created under its own client_id. The existing backup was most likely created by the current connection and would become invisible to it. Before anything is written, the new token is checked against the existing backup, and the replacement is abandoned if it cannot see it. The machine keeps its own copy of the configuration until vm-setup --replace-rclone-config. To go ahead, run again with --replace-existing --accept-scope-change.":
      "Remote '%@' ersattes INTE. Den nya inloggningen får omfånget 'drive.file', som bara ser filer skapade under sitt eget client_id. Den befintliga säkerhetskopian skapades troligen av den nuvarande anslutningen och skulle bli osynlig för den. Innan något skrivs kontrolleras den nya token mot den befintliga säkerhetskopian, och ersättningen avbryts om den inte ser den. Maskinen behåller sin egen kopia av konfigurationen fram till vm-setup --replace-rclone-config. För att fortsätta, kör igen med --replace-existing --accept-scope-change.",
    "Remote control:   OPEN on the Mac at 127.0.0.1:5572 - any web page can send rclone commands; see vm/README.md (portForwards)":
      "Fjärrstyrning:    ÖPPEN på Macen på 127.0.0.1:5572 - vilken webbsida som helst kan skicka rclone-kommandon; se vm/README.md (portForwards)",
    "Running":
      "Körs",
    "Samba, rclone or punchfs in the machine is not active, so Time Machine has nowhere to write or the bands do not reach Google Drive. Check: cloudmachine-agent vm-status":
      "Samba, rclone eller punchfs i maskinen är inte aktiv, så Time Machine har ingenstans att skriva eller så når banden inte Google Drive. Kontrollera: cloudmachine-agent vm-status",
    "Service %@":
      "Tjänst %@",
    "Services":
      "Tjänster",
    "Set up the CloudMachine machine (the first time it downloads Ubuntu - several minutes)":
      "Konfigurera CloudMachine-maskinen (första gången hämtas Ubuntu - flera minuter)",
    "Set up the CloudMachine machine again, so it prints the Time Machine command":
      "Konfigurera CloudMachine-maskinen igen så att den skriver ut Time Machine-kommandot",
    "Set up the machine":
      "Konfigurera maskinen",
    "Setting up the CloudMachine machine":
      "Konfigurerar CloudMachine-maskinen",
    "Start the CloudMachine machine":
      "Starta CloudMachine-maskinen",
    "Start the machine":
      "Starta maskinen",
    "Starting the CloudMachine machine":
      "Startar CloudMachine-maskinen",
    "Still to upload: %@ GiB":
      "Kvar att ladda upp: %@ GiB",
    "Stopping the Time Machine backup...":
      "Stoppar Time Machine-säkerhetskopieringen...",
    "Stopping the machine %@...":
      "Stoppar maskinen %@...",
    "The CloudMachine machine does not answer":
      "CloudMachine-maskinen svarar inte",
    "The CloudMachine machine is not running":
      "CloudMachine-maskinen körs inte",
    "The CloudMachine machine is not set up yet":
      "CloudMachine-maskinen är inte konfigurerad än",
    "The CloudMachine machine is stopped":
      "CloudMachine-maskinen är stoppad",
    "The backup is stopped, the upload gets up to 30 minutes, then the machine shuts down cleanly. It starts again at the next login.":
      "Säkerhetskopieringen stoppas, uppladdningen får upp till 30 minuter, sedan stängs maskinen av på ett rent sätt. Den startar igen vid nästa inloggning.",
    "The machine %@ is not running - nothing to prepare.":
      "Maskinen %@ körs inte - inget att förbereda.",
    "The machine is stopped and everything reached Google Drive. The Mac can be restarted; the machine starts again at login.":
      "Maskinen är stoppad och allt har nått Google Drive. Macen kan startas om; maskinen startar igen vid inloggning.",
    "The machine is stopped. %@ GiB had not reached Google Drive yet - it is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "Maskinen är stoppad. %@ GiB hade ännu inte nått Google Drive - det finns kvar i maskinens buffert och laddas upp efter nästa start. Macen kan startas om.",
    "The machine is stopped. rclone did not say how much was still to upload; what was not uploaded is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "Maskinen är stoppad. rclone angav inte hur mycket som återstod att ladda upp; det som inte laddades upp finns kvar i maskinens buffert och laddas upp efter nästa start. Macen kan startas om.",
    "The machine's disk is a file on this disk and grows as the upload buffer fills. With no space left the machine cannot write the buffer, and Time Machine's local snapshots have nowhere to go either.":
      "Maskinens disk är en fil på den här disken och växer i takt med att uppladdningsbufferten fylls. Utan ledigt utrymme kan maskinen inte skriva bufferten, och Time Machines lokala ögonblicksbilder har inte heller någonstans att ta vägen.",
    "The image's metadata has never been copied to Drive":
      "Avbildens metadata har aldrig kopierats till Drive",
    "The image's metadata was last copied to Drive %@ ago":
      "Avbildens metadata kopierades senast till Drive för %@ sedan",
    "The machine's disk is running out of space (%@ GB)":
      "Maskinens disk håller på att ta slut på utrymme (%@ GB)",
    "The new sign-in does NOT see the existing backup (%@), so remote '%@' was NOT replaced and rclone.conf is unchanged. Keep the current connection, or sign in with the credential (client_id) that created the backup.":
      "Den nya inloggningen ser INTE den befintliga säkerhetskopian (%@), så remote '%@' ersattes INTE och rclone.conf är oförändrad. Behåll den nuvarande anslutningen eller logga in med den autentiseringsuppgift (client_id) som skapade säkerhetskopian.",
    "The upload buffer lives on this disk. The guard pauses Time Machine before it fills; if the upload does not catch up, backups stay paused.":
      "Uppladdningsbufferten ligger på den här disken. Vakten pausar Time Machine innan den fylls; om uppladdningen inte hinner ikapp förblir säkerhetskopieringen pausad.",
    "These bands exist only in the machine's buffer. The backup on Google Drive is INCOMPLETE and may not open.":
      "Dessa band finns bara i maskinens buffert. Säkerhetskopian på Google Drive är OFULLSTÄNDIG och går kanske inte att öppna.",
    "Time Machine backs up to the machine, so without it no backup is made. Start it: limactl start %@ (or the Start button in the app).":
      "Time Machine säkerhetskopierar till maskinen, så utan den görs ingen säkerhetskopia. Starta den: limactl start %@ (eller med knappen Starta maskinen i appen).",
    "Time Machine did not stop its backup within 2 minutes (or tmutil did not answer) - the machine was NOT stopped. Try again in a moment.":
      "Time Machine stoppade inte sin säkerhetskopiering inom 2 minuter (eller så svarade inte tmutil) - maskinen stoppades INTE. Försök igen om en stund.",
    "Time Machine has created its image: stop the backup, then convert the image to 32 MB bands":
      "Time Machine har skapat sin avbild: stoppa säkerhetskopieringen och konvertera sedan avbilden till band på 32 MB",
    "To upload":
      "Att ladda upp",
    "Unknown whether the CloudMachine machine is running":
      "Okänt om CloudMachine-maskinen körs",
    "Waiting for the upload to Google Drive (at most %@ min)...":
      "Väntar på uppladdningen till Google Drive (högst %@ min)...",
    "With --replace-existing: confirms that the new sign-in (scope 'drive.file') may not see the existing backup. The new token is still checked against the backup first.":
      "Med --replace-existing: bekräftar att den nya inloggningen (omfång 'drive.file') kanske inte ser den befintliga säkerhetskopian. Den nya token kontrolleras ändå först mot säkerhetskopian.",
    "Without it there is no way to check whether anything reached the Drive - the machine's guard is blind then.":
      "Utan den går det inte att kontrollera om något har nått Drive - maskinens vakt är då blind.",
    "limactl did not answer":
      "limactl svarade inte",
    "limactl did not answer (or is not installed). That does not mean the machine is down - it means nobody has checked.":
      "limactl svarade inte (eller är inte installerat). Det betyder inte att maskinen ligger nere - det betyder att ingen har kontrollerat.",
    "limactl start failed: %@":
      "limactl start misslyckades: %@",
    "limactl stop failed: %@":
      "limactl stop misslyckades: %@",
    "punchfs is close to its open-file limit":
      "punchfs närmar sig sin gräns för öppna filer",
    "punchfs open files":
      "Öppna filer i punchfs",
    "rclone's remote control is open on this Mac":
      "rclones fjärrstyrning är öppen på den här Macen",
    "statfs('/System/Volumes/Data') returned an error, so nobody knows whether the machine's disk can still grow on this Mac.":
      "statfs('/System/Volumes/Data') returnerade ett fel, så ingen vet om maskinens disk fortfarande kan växa på den här Macen.",
    "Google Drive's daily upload limit stops the upload":
      "Google Drives dagliga uppladdningsgräns stoppar uppladdningen",
    "Google last refused an upload %@ ago (750 GB a day). Backups since then are only in the machine's buffer on this Mac. rclone retries every 5 min and resumes by itself when the limit passes; the guard pauses Time Machine if more than %@ GiB waits.":
      "Google nekade senast en uppladdning för %@ sedan (750 GB per dygn). Säkerhetskopior sedan dess finns bara i maskinens buffert på den här Macen. rclone försöker igen var 5:e min och återupptar själv när gränsen har passerat; vakten pausar Time Machine om mer än %@ GiB väntar.",
    "Usage on Google Drive is not being measured":
      "Användningen på Google Drive mäts inte",
    "The last measurement (%@ GB) is from %@, %@ ago - rclone size has not answered since. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "Den senaste mätningen (%@ GB) är från %@, för %@ sedan - rclone size har inte svarat sedan dess. Tills det gör det bevakar ingen gränsen på %@ GB: larmen vid 90%% och 100%% förblir tysta. Kontrollera vm-status eller tryck på ”Mät nu” i fönstret.",
    "rclone size has not answered even once. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "rclone size har inte svarat en enda gång. Tills det gör det bevakar ingen gränsen på %@ GB: larmen vid 90%% och 100%% förblir tysta. Kontrollera vm-status eller tryck på ”Mät nu” i fönstret.",
    "Saved in the Keychain. Connecting Google Drive (configure-remote) will use them.":
      "Sparat i Nyckelringen. Anslutning till Google Drive (configure-remote) kommer att använda dem.",
    "Saved in the Keychain. The existing Google Drive connection keeps its old client_id, and on this Mac it should stay that way: a connection made with the new keys (the 'drive.file' scope) cannot see the backup created by the old one. Do not replace the connection here; the new keys are for a Mac that is not connected yet.":
      "Sparat i Nyckelringen. Den befintliga Google Drive-anslutningen behåller sitt gamla client_id, och på den här Macen bör det förbli så: en anslutning som gjorts med de nya nycklarna (omfånget 'drive.file') ser inte säkerhetskopian som skapades av den gamla. Ersätt inte anslutningen här; de nya nycklarna är till för en Mac som ännu inte är ansluten.",
    "it is not there for the new token":
      "den finns inte för den nya token",
    "Cancel":
      "Avbryt",
    "ACTION NEEDED":
      "ÅTGÄRD KRÄVS",
    "WILL PASS BY ITSELF — DO NOTHING":
      "GÅR ÖVER AV SIG SJÄLVT — GÖR INGENTING",
    "UNKNOWN — CHECK AGAIN SHORTLY":
      "OKLART — KONTROLLERA IGEN OM EN STUND",
    "ALL GOOD":
      "ALLT ÄR BRA",
    "Upload is not working":
      "Uppladdningen fungerar inte",
    "Upload stopped — no space left on Google Drive":
      "Uppladdningen har stannat — inget utrymme kvar på Google Drive",
    "%@ backup fragments not uploaded":
      "%@ säkerhetskopiefragment har inte laddats upp",
    "Upload cannot keep up with writes":
      "Uppladdningen hinner inte med skrivningarna",
    "Upload paused — Google daily limit":
      "Uppladdningen pausad — Googles dygnsgräns",
    "Uploading to Google Drive — %@ queued":
      "Laddar upp till Google Drive — %@ i kö",
    "Everything uploaded to Google Drive":
      "Allt har laddats upp till Google Drive",
    "Unknown what is waiting in the queue":
      "Okänt vad som väntar i kön",
    "There is no connection to Google Drive, so backups are only made on this Mac. If this does not pass by itself within a few minutes, check the network and the connection to Drive.":
      "Det finns ingen anslutning till Google Drive, så säkerhetskopior görs bara på den här Macen. Om det inte går över av sig självt inom några minuter, kontrollera nätverket och anslutningen till Drive.",
    "There is no space left on Google Drive. This will NOT pass by itself — you need to free up space on Drive. Until then Time Machine is paused, so that it does not fill up this Mac's disk.":
      "Det finns inget utrymme kvar på Google Drive. Det går INTE över av sig självt — du måste frigöra utrymme på Drive. Tills dess är Time Machine pausad, så att den inte fyller den här Macens disk.",
    "%@ backup fragments could not be uploaded and rclone stopped trying. These fragments exist only on this Mac, so the backup on Drive is incomplete. This needs checking.":
      "%@ säkerhetskopiefragment kunde inte laddas upp och rclone slutade försöka. Dessa fragment finns bara på den här Macen, så säkerhetskopian på Drive är ofullständig. Detta behöver kontrolleras.",
    "Time Machine is writing faster than the upload goes, and the buffer has filled up. The backup will be paused until the upload catches up — this is a safeguard against filling up the disk, not a failure.":
      "Time Machine skriver snabbare än uppladdningen går, och bufferten har fyllts. Säkerhetskopieringen pausas tills uppladdningen hinner ikapp — det är ett skydd mot att disken fylls, inte ett fel.",
    "Google accepts 750 GB per day and that limit has been used up. There is nothing to do: the limit renews by itself, usually within a few hours. Time Machine backups are made normally in the meantime and wait in the buffer — they will be uploaded as soon as Google starts accepting again.":
      "Google tar emot 750 GB per dygn och den gränsen är förbrukad. Det finns inget att göra: gränsen förnyas av sig själv, vanligtvis inom några timmar. Time Machine-säkerhetskopior görs som vanligt under tiden och väntar i bufferten — de laddas upp så fort Google tar emot igen.",
    "%@ backup fragments are queued and on their way to Drive.":
      "%@ säkerhetskopiefragment står i kö och är på väg till Drive.",
    "Nothing is waiting in the queue — the backup on Google Drive is complete.":
      "Inget väntar i kön — säkerhetskopian på Google Drive är komplett.",
    "rclone did not answer the question about the queue, so it is unknown how many backups are still waiting to be uploaded. This does not mean something broke — under load the answer can be late. It only means that right now nobody knows. If it persists, the backup cycle check will report it.":
      "rclone svarade inte på frågan om kön, så det är okänt hur många säkerhetskopior som ännu väntar på uppladdning. Det betyder inte att något har gått sönder — under belastning kan svaret dröja. Det betyder bara att ingen vet just nu. Om det består rapporterar kontrollen av säkerhetskopieringscykeln det.",
    "unknown error":
      "okänt fel",
    "rclone lsf ended with an error":
      "rclone lsf avslutades med ett fel",
    "This Mac is close to its space limit on Google Drive":
      "Den här Macen närmar sig sin utrymmesgräns på Google Drive",
    "%@ GB of %@ GB used. Time Machine deletes the oldest backups to stay within its quota; check that the quota is set (vm-status).":
      "%@ GB av %@ GB används. Time Machine tar bort de äldsta säkerhetskopiorna för att hålla sig inom sin kvot; kontrollera att kvoten är inställd (vm-status).",
    "This Mac is over its space limit on Google Drive":
      "Den här Macen har överskridit sin utrymmesgräns på Google Drive",
    "%@ GB of %@ GB used. Set the Time Machine quota (command in the app window or vm-status), or raise the limit.":
      "%@ GB av %@ GB används. Ange Time Machine-kvoten (kommando i appfönstret eller vm-status) eller höj gränsen.",
    "not set":
      "inte inställd",
    "%@ GB - usage not measured yet":
      "%@ GB - användningen är ännu inte mätt",
    "%@ of %@ GB used (%@%%)":
      "%@ av %@ GB används (%@%%)",
    "The limit must be a whole number of GB above zero.":
      "Gränsen måste vara ett heltal i GB större än noll.",
    "machines.json cannot be read, so it was not overwritten. Fix or remove it first.":
      "machines.json kan inte läsas, så den skrevs inte över. Åtgärda eller ta bort den först.",
    "'%@' is not a valid folder name: use lowercase letters, digits and dashes.":
      "'%@' är inte ett giltigt mappnamn: använd små bokstäver, siffror och bindestreck.",
    "This Mac already backs up to folder '%@'. Switching to '%@' would start a new, empty backup and orphan the existing one, so nothing was changed.":
      "Den här Macen säkerhetskopierar redan till mappen '%@'. Ett byte till '%@' skulle starta en ny, tom säkerhetskopia och göra den befintliga föräldralös, så ingenting ändrades.",
    "This Mac already has a CloudMachine installation, whose backup is in folder '%@'. Switching to '%@' would orphan it, so nothing was changed.":
      "Den här Macen har redan en CloudMachine-installation vars säkerhetskopia ligger i mappen '%@'. Ett byte till '%@' skulle göra den föräldralös, så ingenting ändrades.",
    "Could not save the folder name to %@: %@":
      "Kunde inte spara mappnamnet i %@: %@",
    "Homebrew is not installed. Install it manually: https://brew.sh":
      "Homebrew är inte installerat. Installera det manuellt: https://brew.sh",
    "Installing rclone failed: %@":
      "Installationen av rclone misslyckades: %@",
    "Installed rclone.":
      "rclone installerades.",
    "Own Google credentials: set.":
      "Egna Google-uppgifter: inställda.",
    "INCOMPLETE: %@ is missing - rclone will use rclone's shared client_id anyway.":
      "OFULLSTÄNDIGT: %@ saknas - rclone använder ändå rclones delade client_id.",
    "No own credentials - rclone uses the shared client_id, rate-limited jointly and being retired in 2026.":
      "Inga egna uppgifter - rclone använder det delade client_id, som har gemensam hastighetsbegränsning och fasas ut 2026.",
    "Empty value - not saving.":
      "Tomt värde - sparar inte.",
    "Keychain refused: %@":
      "Nyckelringen nekade: %@",
    "DIRTY-TREE":
      "OSTÄDAT-TRÄD",
    "Cannot create the working directory: %@":
      "Kan inte skapa arbetskatalogen: %@",
    "Could not read the rclone version number.":
      "Kunde inte läsa versionsnumret för rclone.",
    "Could not download %@.":
      "Kunde inte hämta %@.",
    "No entry for %@ in SHA256SUMS.":
      "Ingen post för %@ i SHA256SUMS.",
    "Could not compute the checksum.":
      "Kunde inte beräkna kontrollsumman.",
    "SHA256 checksum does not match - NOT installing.\n  expected: %@\n  computed: %@":
      "SHA256-kontrollsumman stämmer inte - installerar INTE.\n  förväntad: %@\n  beräknad: %@",
    "Could not unpack the archive.":
      "Kunde inte packa upp arkivet.",
    "Could not install the binary: %@":
      "Kunde inte installera binärfilen: %@",
    "Installed rclone %@ in %@ (SHA256 checksum matches).":
      "Installerade rclone %@ i %@ (SHA256-kontrollsumman stämmer).",
    "%@ did not respond within the allotted time (the process was left orphaned in the background).":
      "%@ svarade inte inom den angivna tiden (processen lämnades föräldralös i bakgrunden).",
    "Cannot launch %@: %@":
      "Kan inte starta %@: %@",
    "Remote '%@' already exists and was NOT touched.\nOverwriting it replaces the token and the permission scope; a credential with the 'drive.file' scope does not see files created by the previous one, so the existing backup becomes unreachable.\nIf you really want to replace it, first back up ~/.config/rclone/rclone.conf and run again with --replace-existing.":
      "Remote '%@' finns redan och rördes INTE.\nAtt skriva över den ersätter token och behörighetsomfånget; en autentiseringsuppgift med omfånget 'drive.file' ser inte filer som skapats av den föregående, så den befintliga säkerhetskopian blir oåtkomlig.\nOm du verkligen vill ersätta den, ta först en säkerhetskopia av ~/.config/rclone/rclone.conf och kör igen med --replace-existing.",
    "Could not check whether remote '%@' already exists (rclone listremotes did not answer or failed), so nothing was changed. Run `%@ listremotes` to see the error, then try again.":
      "Kunde inte kontrollera om remote '%@' redan finns (rclone listremotes svarade inte eller misslyckades), så ingenting ändrades. Kör `%@ listremotes` för att se felet och försök sedan igen.",
    "Could not check whether this Mac already has a CloudMachine installation (rclone did not answer), so no folder was chosen. Try again in a moment.":
      "Kunde inte kontrollera om den här Macen redan har en CloudMachine-installation (rclone svarade inte), så ingen mapp valdes. Försök igen om en stund.",
    "rclone authorize failed (%@). If that binary is missing, start with: cloudmachine-agent install-rclone.":
      "rclone authorize misslyckades (%@). Om den binärfilen saknas, börja med: cloudmachine-agent install-rclone.",
    "Could not read the token from the output of rclone authorize.":
      "Kunde inte läsa token från utdata från rclone authorize.",
    "rclone config create failed.":
      "rclone config create misslyckades.",
    "Connected to Google Drive as remote '%@', folder %@.":
      "Ansluten till Google Drive som remote '%@', mapp %@.",
    "tmutil is not responding - unknown where the backup goes":
      "tmutil svarar inte - okänt vart säkerhetskopian går",
    "No successful backup for %@":
      "Ingen lyckad säkerhetskopia på %@",
    "Last COMPLETED backup: %@. The cycle is hourly, so that is %@ missed runs.":
      "Senaste SLUTFÖRDA säkerhetskopia: %@. Cykeln är timvis, så det motsvarar %@ missade körningar.",
    "There is NOT A SINGLE successful backup":
      "Det finns INGEN ENDA lyckad säkerhetskopia",
    "The Time Machine preferences contain no date of a completed backup for this destination.":
      "Time Machines inställningar innehåller inget datum för en slutförd säkerhetskopia för den här destinationen.",
    "The last backup attempt did not end in a backup":
      "Det senaste säkerhetskopieringsförsöket slutade inte i en säkerhetskopia",
    "The attempt at %@ is newer than the last successful backup at %@.":
      "Försöket %@ är nyare än den senaste lyckade säkerhetskopian %@.",
    "Time Machine reports an error in the last run (RESULT=%@)":
      "Time Machine rapporterar ett fel i senaste körningen (RESULT=%@)",
    "A non-zero RESULT in the Time Machine preferences means the run did not succeed.":
      "Ett RESULT som inte är noll i Time Machines inställningar betyder att körningen inte lyckades.",
    "rclone failed to upload %@ files":
      "rclone kunde inte ladda upp %@ filer",
    "Buffer full of nothing but unsent data":
      "Bufferten full av bara ej uppladdad data",
    "rclone has nothing left to evict from the buffer - the upload cannot keep up or has stalled.":
      "rclone har inget kvar att rensa bort ur bufferten - uppladdningen hinner inte med eller har stannat.",
    "The rclone control interface is not responding":
      "rclones kontrollgränssnitt svarar inte",
    "Google Drive is running out of space (%@ GB)":
      "Utrymmet på Google Drive håller på att ta slut (%@ GB)",
    "The Mac's disk is running out of space (%@ GB)":
      "Macens disk håller på att ta slut på utrymme (%@ GB)",
    "Cannot read the Time Machine preferences":
      "Kan inte läsa Time Machines inställningar",
    "%@ is unreadable - most often Full Disk Access is missing. Without this file it is UNKNOWN when the last backup was made, so we treat it as a failure, not as the absence of a problem.":
      "%@ går inte att läsa - oftast saknas Full åtkomst till disken. Utan den här filen är det OKÄNT när den senaste säkerhetskopian gjordes, så vi behandlar det som ett fel, inte som att problem saknas.",
    "Cannot measure free space on the Mac's disk":
      "Kan inte mäta ledigt utrymme på Macens disk",
    "%@ days":
      "%@ dygn",
    "CloudMachine: backup is not working":
      "CloudMachine: säkerhetskopieringen fungerar inte",
    "unknown reason":
      "okänd orsak",
    "osascript did not show the notification (permissions or no graphical session)":
      "osascript visade inte aviseringen (behörigheter eller ingen grafisk session)",
    "UNDELIVERED ALARM: %@":
      "OLEVERERAT LARM: %@",
    "from %@, reason: %@":
      "från %@, orsak: %@",
    "The system notification was not delivered - you will see this alarm ONLY here.":
      "Systemaviseringen levererades inte - du ser det här larmet ENDAST här.",
    "%@ (%@ ago)":
      "%@ (%@ sedan)",
    "%@ - marker from the FUTURE":
      "%@ - markör från FRAMTIDEN",
    "%@ (%@ ago) - THE WATCHDOG MAY NOT BE RUNNING":
      "%@ (%@ sedan) - BEVAKAREN KÖRS KANSKE INTE",
    "NEVER - the watchdog has not recorded a single run":
      "ALDRIG - bevakaren har inte registrerat någon enda körning",
    "Could not find the launchd/ directory with templates.":
      "Hittade inte katalogen launchd/ med mallar.",
    "Could not find the compiled cloudmachine-agent binary.":
      "Hittade inte den kompilerade binärfilen cloudmachine-agent.",
    "ABORTED: could not put cloudmachine-agent in a stable location\n(%@) - most often a lack of space or permissions.\nNOT installing agents pointing at %@: that path\ndisappears on the next `swift build` or `git clean`, and backups stop\nwithout any visible signal.":
      "AVBRUTET: kunde inte lägga cloudmachine-agent på en stabil plats\n(%@) - oftast på grund av brist på utrymme eller behörigheter.\nInstallerar INTE agenter som pekar på %@: den sökvägen\nförsvinner vid nästa `swift build` eller `git clean`, och säkerhetskopieringen\nupphör utan någon synlig signal.",
    "ABORTED: %@":
      "AVBRUTET: %@",
    "Could not list the templates in %@.":
      "Kunde inte lista mallarna i %@.",
    "could not read the template %@":
      "kunde inte läsa mallen %@",
    "could not write %@ (lack of space or permissions)":
      "kunde inte skriva %@ (brist på utrymme eller behörigheter)",
    "launchctl load refused to load %@":
      "launchctl load vägrade läsa in %@",
    "NOT A SINGLE agent was loaded.":
      "INGEN ENDA agent lästes in.",
    "Only these went in: %@.":
      "Bara dessa kom på plats: %@.",
    "Could not load any launchd agent.":
      "Kunde inte läsa in någon launchd-agent.",
    "Installed agents: %@":
      "Installerade agenter: %@",
    "                  WARNING: close to the limit - new bands will fail with EMFILE":
      "                  VARNING: nära gränsen - nya band misslyckas med EMFILE",
    "%@/bands on Google Drive is not empty - it may hold another backup. NOT overwriting it; check it by hand.":
      "%@/bands på Google Drive är inte tom - den kan innehålla en annan säkerhetskopia. Skriver INTE över den; kontrollera manuellt.",
    "Address:          %@":
      "Adress:           %@",
    "Already prepared (%@ exists) - nothing to do.":
      "Redan förberedd (%@ finns) - inget att göra.",
    "Converts Time Machine's new, empty image in the machine to 32 MB bands and moves the bands to Google Drive.":
      "Konverterar Time Machines nya, tomma avbild i maskinen till band på 32 MB och flyttar banden till Google Drive.",
    "Copy rclone.conf into the machine even if it already has one.":
      "Kopiera rclone.conf till maskinen även om den redan har en.",
    "Copying the converted image into the machine failed: %@":
      "Kopieringen av den konverterade avbilden till maskinen misslyckades: %@",
    "Copying the image to the Mac failed: %@":
      "Kopieringen av avbilden till Macen misslyckades: %@",
    "Could not ask Lima about the machine: %@":
      "Kunde inte fråga Lima om maskinen: %@",
    "Could not carry the Time Machine files over: %@":
      "Kunde inte flytta över Time Machine-filerna: %@",
    "Could not check the image in the machine.":
      "Kunde inte kontrollera avbilden i maskinen.",
    "Could not copy the rclone configuration into the machine.":
      "Kunde inte kopiera rclone-konfigurationen till maskinen.",
    "Could not create %@ on Google Drive: %@":
      "Kunde inte skapa %@ på Google Drive: %@",
    "Could not create %@: %@":
      "Kunde inte skapa %@: %@",
    "Could not find the vm/ directory with the machine template.":
      "Hittade inte katalogen vm/ med maskinmallen.",
    "Could not read the image size.":
      "Kunde inte läsa avbildens storlek.",
    "Could not set the SMB password of user %@ in the machine.":
      "Kunde inte ange SMB-lösenordet för användaren %@ i maskinen.",
    "Could not stop smbd in the machine.":
      "Kunde inte stoppa smbd i maskinen.",
    "Could not write %@ in the machine.":
      "Kunde inte skriva %@ i maskinen.",
    "Could not write the password file %@.":
      "Kunde inte skriva lösenordsfilen %@.",
    "Creates or starts the CloudMachine machine (Lima), gives it rclone's configuration and an SMB password, and prints the Time Machine command.":
      "Skapar eller startar CloudMachine-maskinen (Lima), ger den rclones konfiguration och ett SMB-lösenord och skriver ut Time Machine-kommandot.",
    "Creating the machine %@ (first start downloads Ubuntu and installs packages - several minutes)...":
      "Skapar maskinen %@ (första starten hämtar Ubuntu och installerar paket - flera minuter)...",
    "Done: %@ has %@ MB bands on Google Drive; the original is kept in %@ in the machine. Start the backup: tmutil startbackup":
      "Klart: %@ har band på %@ MB på Google Drive; originalet finns kvar i %@ i maskinen. Starta säkerhetskopieringen: tmutil startbackup",
    "exit code %@, no message":
      "slutkod %@, inget meddelande",
    "Image metadata:   NEVER copied to %@ - check tm-meta-sync in the machine":
      "Avbildsmetadata:  ALDRIG kopierad till %@ - kontrollera tm-meta-sync i maskinen",
    "Image metadata:   copied %@ ago to %@":
      "Avbildsmetadata:  kopierad för %@ sedan till %@",
    "Image metadata:   last copied %@ ago - OVERDUE (%@)":
      "Avbildsmetadata:  senast kopierad för %@ sedan - FÖRSENAD (%@)",
    "Image metadata:   not copied yet - waits for vm-prepare-bundle":
      "Avbildsmetadata:  inte kopierad än - väntar på vm-prepare-bundle",
    "Backup %@, paused by the guard %@: %@":
      "Säkerhetskopia %@, pausad av vakten %@: %@",
    "Free in machine:  %@ GiB":
      "Ledigt i maskinen: %@ GiB",
    "fsck_apfs -n found problems: %@":
      "fsck_apfs -n hittade problem: %@",
    "Google Drive folder: %@":
      "Google Drive-mapp: %@",
    "hdiutil attach of the converted image failed: %@":
      "hdiutil attach av den konverterade avbilden misslyckades: %@",
    "hdiutil convert failed: %@":
      "hdiutil convert misslyckades: %@",
    "Image name in the machine (default: from the computer name).":
      "Avbildens namn i maskinen (standard: härlett från datornamnet).",
    "Installing the converted image FAILED: %@\nsmbd is left STOPPED so Time Machine does not open a half-installed image. The original is in %@ in the machine.":
      "Installationen av den konverterade avbilden MISSLYCKADES: %@\nsmbd lämnas STOPPAD så att Time Machine inte öppnar en halvinstallerad avbild. Originalet finns i %@ i maskinen.",
    "limactl create failed: %@":
      "limactl create misslyckades: %@",
    "limactl list failed: %@":
      "limactl list misslyckades: %@",
    "limactl not found - install Lima: brew install lima":
      "limactl hittades inte - installera Lima: brew install lima",
    "limactl start failed: %@\nThe machine's own log: %@":
      "limactl start misslyckades: %@\nMaskinens egen logg: %@",
    "Machine %@ is running.":
      "Maskinen %@ körs.",
    "Machine %@ was already running.":
      "Maskinen %@ körde redan.",
    "Machine:          %@ (%@)":
      "Maskin:           %@ (%@)",
    "Machine:          %@":
      "Maskin:           %@",
    "Machine:          not created - run: cloudmachine-agent vm-setup":
      "Maskin:           inte skapad - kör: cloudmachine-agent vm-setup",
    "no answer within the time limit":
      "inget svar inom tidsgränsen",
    "No image %@ in the machine.":
      "Ingen avbild %@ i maskinen.",
    "No image in the machine yet - point Time Machine at the share and let it create one first.":
      "Ingen avbild i maskinen än - rikta först Time Machine mot resursen och låt den skapa en.",
    "No rclone configuration at %@ - connect Google Drive first (configure-remote).":
      "Ingen rclone-konfiguration på %@ - anslut först Google Drive (configure-remote).",
    "no SMB destination":
      "ingen SMB-destination",
    "One check of the machine's upload buffer: pauses Time Machine when it fills, resumes what it paused.":
      "En kontroll av maskinens uppladdningsbuffert: pausar Time Machine när den fylls och återupptar det den pausade.",
    "Packing the converted image failed: %@":
      "Packningen av den konverterade avbilden misslyckades: %@",
    "Packing the image failed: %@":
      "Packningen av avbilden misslyckades: %@",
    "No answer from the machine (rclone rc) - the guard would do nothing.":
      "Inget svar från maskinen (rclone rc) - vakten skulle inte göra något.",
    "Only print what the guard would decide - for trying thresholds on a throwaway machine.":
      "Skriv bara ut vad vakten skulle besluta - för att pröva tröskelvärden på en engångsmaskin.",
    "Pause above this many GiB in the buffer.":
      "Pausa över så många GiB i bufferten.",
    "Pause when the machine has less free than this, in GiB.":
      "Pausa när maskinen har mindre ledigt utrymme än så här, i GiB.",
    "Point Time Machine at the machine (once, needs an administrator password):":
      "Rikta Time Machine mot maskinen (en gång, kräver administratörslösenord):",
    "punchfs files:    %@ open, limit %@":
      "punchfs-filer:    %@ öppna, gräns %@",
    "rclone configuration already in the machine - kept (--replace-rclone-config replaces it).":
      "rclone-konfigurationen finns redan i maskinen - behålls (--replace-rclone-config ersätter den).",
    "rclone configuration copied into the machine.":
      "rclone-konfigurationen kopierades till maskinen.",
    "rclone-tm or punchfs is not running in the machine - see cloudmachine-agent vm-status.":
      "rclone-tm eller punchfs körs inte i maskinen - se cloudmachine-agent vm-status.",
    "Resume below this many GiB (only a backup the guard paused).":
      "Återuppta under så många GiB (bara en säkerhetskopiering som vakten pausade).",
    "Service %@: %@":
      "Tjänst %@: %@",
    "Several images in the machine (%@) - choose one with --bundle.":
      "Flera avbilder i maskinen (%@) - välj en med --bundle.",
    "Shows the machine: address, services, upload buffer, free space and the Time Machine destination.":
      "Visar maskinen: adress, tjänster, uppladdningsbuffert, ledigt utrymme och Time Machine-destinationen.",
    "SMB password stored in %@ (mode 600).":
      "SMB-lösenordet sparat i %@ (läge 600).",
    "The converted image does not have %@-byte bands.":
      "Den konverterade avbilden har inte band på %@ byte.",
    "The converted image has no APFS partition.":
      "Den konverterade avbilden har ingen APFS-partition.",
    "The image already takes %@ MB - this command converts only a new, empty image (under %@ MB).":
      "Avbilden tar redan %@ MB - det här kommandot konverterar bara en ny, tom avbild (under %@ MB).",
    "The image is encrypted - converting encrypted images is not supported.":
      "Avbilden är krypterad - konvertering av krypterade avbilder stöds inte.",
    "The image was not changed; smbd started again.":
      "Avbilden ändrades inte; smbd startades igen.",
    "The machine does not answer - is it running? cloudmachine-agent vm-status":
      "Maskinen svarar inte - körs den? cloudmachine-agent vm-status",
    "The machine has no address on the vzNAT network.":
      "Maskinen har ingen adress i nätverket vzNAT.",
    "The services in the machine did not start - check: cloudmachine-agent vm-status":
      "Tjänsterna i maskinen startade inte - kontrollera: cloudmachine-agent vm-status",
    "Time Machine is backing up - stop it first: tmutil stopbackup":
      "Time Machine säkerhetskopierar - stoppa den först: tmutil stopbackup",
    "Time Machine:     %@":
      "Time Machine:     %@",
    "Time Machine:     NOT pointing at the machine (%@)":
      "Time Machine:     pekar INTE på maskinen (%@)",
    "Time Machine:     tmutil did not answer":
      "Time Machine:     tmutil svarade inte",
    "tmutil did not answer - not touching the image while its state is unknown.":
      "tmutil svarade inte - rör inte avbilden medan dess tillstånd är okänt.",
    "unknown":
      "okänd",
    "Unpacking the image failed: %@":
      "Uppackningen av avbilden misslyckades: %@",
    "Still to upload:  %@ GiB in %@ bands, uploading %@ (cache on disk %@ GiB)":
      "Kvar att ladda upp: %@ GiB i %@ band, %@ laddas upp (cache på disk %@ GiB)",
    "Excluded %@ (the machine and its upload buffer) from Time Machine.":
      "Uteslöt %@ (maskinen och dess uppladdningsbuffert) från Time Machine.",
    "WARNING: could not exclude %@ from Time Machine - run: tmutil addexclusion %@":
      "VARNING: kunde inte utesluta %@ från Time Machine - kör: tmutil addexclusion %@",
    "Upload buffer:    no answer from rclone (rc %@)":
      "Uppladdningsbuffert: inget svar från rclone (rc %@)",
    "When Time Machine has created its empty image, stop the backup (tmutil stopbackup) and run: cloudmachine-agent vm-prepare-bundle":
      "När Time Machine har skapat sin tomma avbild, stoppa säkerhetskopieringen (tmutil stopbackup) och kör: cloudmachine-agent vm-prepare-bundle",
    "Unsent %@ GiB, free %@ GiB (pause above %@ GiB unsent or below %@ GiB free, resume below %@ GiB).":
      "Ej uppladdat %@ GiB, ledigt %@ GiB (pausa över %@ GiB ej uppladdat eller under %@ GiB ledigt, återuppta under %@ GiB).",
    "Upload:           Google's daily limit refused an upload %@ ago - rclone retries every 5 min and resumes by itself":
      "Uppladdning:      Googles dygnsgräns nekade en uppladdning för %@ sedan - rclone försöker igen var 5:e min och återupptar själv",
    "no":
      "nej",
    "running":
      "pågår",
    "stopped":
      "stoppad",
    "yes":
      "ja",
    "%@\nThe previous template is in %@ - copy it back over lima.yaml and run limactl start %@.":
      "%@\nDen föregående mallen finns i %@ - kopiera tillbaka den över lima.yaml och kör limactl start %@.",
    "Could not read this app's machine template (limactl template copy).":
      "Kunde inte läsa den här appens maskinmall (limactl template copy).",
    "Could not replace %@: %@":
      "Kunde inte ersätta %@: %@",
    "Machine %@ already runs this app's template.":
      "Maskinen %@ kör redan den här appens mall.",
    "Machine %@ now runs this app's template; the previous one is in %@.":
      "Maskinen %@ kör nu den här appens mall; den föregående finns i %@.",
    "Moves the machine onto this app's template (two restarts, never during a backup).":
      "Flyttar maskinen till den här appens mall (två omstarter, aldrig under en säkerhetskopiering).",
    "No machine %@ - create it with: cloudmachine-agent vm-setup":
      "Ingen maskin %@ - skapa den med: cloudmachine-agent vm-setup",
    "Template:         OLDER than this app's - run: cloudmachine-agent vm-update":
      "Mall:             ÄLDRE än den här appens - kör: cloudmachine-agent vm-update",
    "Template:         not compared":
      "Mall:             inte jämförd",
    "Template:         this app's":
      "Mall:             den här appens",
    "The machine has no %@ - run cloudmachine-agent vm-setup first.":
      "Maskinen har ingen %@ - kör först cloudmachine-agent vm-setup.",
    "The machine restarted, but not every service is running - check: cloudmachine-agent vm-status. The previous template is in %@.":
      "Maskinen startade om, men inte alla tjänster körs - kontrollera: cloudmachine-agent vm-status. Den föregående mallen finns i %@.",
    "The template changes the machine itself (%@) - that needs a new machine, not an update.":
      "Mallen ändrar själva maskinen (%@) - det kräver en ny maskin, inte en uppdatering.",
    "The upload to Google Drive hangs":
      "Uppladdningen till Google Drive hänger sig",
    "Time Machine is backing up - try again when it has finished.":
      "Time Machine säkerhetskopierar - försök igen när den är klar.",
    "Upload:           HANGS - bands in progress, none uploaded for %@ (network?); see /var/log/rclone-tm.log in the machine":
      "Uppladdning:      HÄNGER - band pågår, inget uppladdat under %@ (nätverk?); se /var/log/rclone-tm.log i maskinen",
    "limactl stop failed - nothing was changed.":
      "limactl stop misslyckades - ingenting ändrades.",
    "rclone has bands in progress, but none has been uploaded for %@ - usually a broken network connection, which rclone does not report as an error. Backups since then are only in the machine's buffer. When the network comes back the upload resumes by itself (on 28.10.2026 within 80 s); if it does not, restarting the machine (prepare-shutdown, limactl start) drops the dead connections.":
      "rclone har band som pågår, men inget har laddats upp under %@ - oftast en bruten nätverksanslutning, som rclone inte rapporterar som ett fel. Säkerhetskopior sedan dess finns bara i maskinens buffert. När nätverket kommer tillbaka återupptas uppladdningen av sig själv (28.10.2026 inom 80 s); om inte, släpper en omstart av maskinen (prepare-shutdown, limactl start) de döda anslutningarna.",
    "tmutil did not answer - not restarting the machine while its state is unknown.":
      "tmutil svarade inte - startar inte om maskinen medan dess tillstånd är okänt.",
    "The machine's share cannot be read":
      "Maskinens delning går inte att läsa",
    "Unknown whether the machine's share can be read":
      "Okänt om maskinens delning går att läsa",
    "Samba in the machine does not answer this Mac":
      "Samba i maskinen svarar inte den här Macen",
    "Unknown whether Samba in the machine answers this Mac":
      "Okänt om Samba i maskinen svarar den här Macen",
    "Reading 1 byte of %@ in the machine failed: %@. Every service says it is active, yet Time Machine cannot use the image there. Nothing restarts it by itself. Check: cloudmachine-agent vm-status, then in the machine: journalctl -u punchfs -u tm-bands-bind -u rclone-tm":
      "Läsning av 1 byte från %@ i maskinen misslyckades: %@. Alla tjänster säger att de är aktiva, men Time Machine kan inte använda avbilden där. Inget startar om det av sig självt. Kontrollera: cloudmachine-agent vm-status, sedan i maskinen: journalctl -u punchfs -u tm-bands-bind -u rclone-tm",
    "Reading 1 byte of %@ in the machine has not returned for %@ s. That is how a hung punchfs or rclone mount behaves. Nothing is restarted while the state is unknown - a restart under a write still going could lose it. Check in the machine: journalctl -u punchfs -u rclone-tm":
      "Läsning av 1 byte från %@ i maskinen har inte kommit tillbaka på %@ s. Så beter sig en hängd punchfs- eller rclone-montering. Ingenting startas om så länge tillståndet är okänt - en omstart under en pågående skrivning kan förlora den. Kontrollera i maskinen: journalctl -u punchfs -u rclone-tm",
    "An SMB connection to %@ got no answer within %@ s. Time Machine reaches the machine at this address. Check the machine's network and smbd: cloudmachine-agent vm-status":
      "En SMB-anslutning till %@ fick inget svar inom %@ s. Time Machine når maskinen på den här adressen. Kontrollera maskinens nätverk och smbd: cloudmachine-agent vm-status",
    "The machine did not report its address, so nobody could try an SMB connection. Check: cloudmachine-agent vm-status":
      "Maskinen angav inte sin adress, så ingen kunde försöka med en SMB-anslutning. Kontrollera: cloudmachine-agent vm-status",
    "An SMB connection to %@ failed (%@). Time Machine reaches the machine at this address, so no backup is made. Check the machine's network and smbd: cloudmachine-agent vm-status":
      "En SMB-anslutning till %@ misslyckades (%@). Time Machine når maskinen på den här adressen, så ingen säkerhetskopia görs. Kontrollera maskinens nätverk och smbd: cloudmachine-agent vm-status",
    "readable":
      "läsbar",
    "no image yet":
      "ingen avbild än",
    "answers":
      "svarar",
    "Share read:       %@":
      "Läsning delning:  %@",
    "Samba from Mac:   %@":
      "Samba från Mac:   %@",
    "This Mac found no route to %@ (%@). Either the route to the machine is gone, or macOS Local Network privacy has not allowed CloudMachine - then allow it in System Settings > Privacy & Security > Local Network. Check: cloudmachine-agent vm-status":
      "Den här Macen hittade ingen väg till %@ (%@). Antingen är vägen till maskinen borta, eller så har integritetsskyddet för ”Lokalt nätverk” i macOS inte tillåtit CloudMachine – tillåt det då i Systeminställningar > Integritet och säkerhet > Lokalt nätverk. Kontrollera: cloudmachine-agent vm-status",
  ]
}
