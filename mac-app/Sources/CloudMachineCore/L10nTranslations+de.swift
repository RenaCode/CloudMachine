// German translations, keyed by the English text passed to `L10n.tr`.
extension L10nTranslations {
  static let de: [String: String] = [
    "Space limit:      %@":
      "Speicherlimit:    %@",
    "                  Time Machine quota not set to match - run: %@":
      "                  Kontingent für Time Machine nicht passend gesetzt – ausführen: %@",
    "Sets how much of Google Drive this Mac may use, and prints the Time Machine quota command.":
      "Legt fest, wie viel von Google Drive dieser Mac nutzen darf, und gibt den Befehl für das Time-Machine-Kontingent aus.",
    "Limit in GB.":
      "Limit in GB.",
    "Limit for this Mac: %@ GB.":
      "Limit für diesen Mac: %@ GB.",
    "Now set the Time Machine quota (needs an administrator password):":
      "Jetzt das Kontingent für Time Machine festlegen (Administratorkennwort erforderlich):",
    "CloudMachine - verification, Google Drive setup and installation. Called by launchd on a schedule, or by hand from Terminal.":
      "CloudMachine – Prüfung, Einrichtung von Google Drive und Installation. Wird von launchd nach Zeitplan oder manuell im Terminal aufgerufen.",
    "Connects to Google Drive through rclone (OAuth in the browser) and creates this machine's folder.":
      "Verbindet sich über rclone mit Google Drive (OAuth im Browser) und legt den Ordner dieser Maschine an.",
    "Overwrite the existing remote. RISKY: replaces the token and permissions.":
      "Vorhandenes Remote überschreiben. RISKANT: ersetzt Token und Berechtigungen.",
    "Packs build/CloudMachine.app into build/CloudMachine-<version>.dmg.":
      "Packt build/CloudMachine.app in build/CloudMachine-<version>.dmg.",
    "ERROR: %@ is missing - run 'cloudmachine-agent build-app' first":
      "FEHLER: %@ fehlt – zuerst 'cloudmachine-agent build-app' ausführen",
    "==> Preparing the staging folder":
      "==> Bereitstellungsordner wird vorbereitet",
    "==> Creating %@":
      "==> %@ wird erstellt",
    "ERROR: hdiutil exited with code %@.":
      "FEHLER: hdiutil wurde mit Code %@ beendet.",
    "==> Done: %@":
      "==> Fertig: %@",
    "On first launch (the app is not signed with an Apple Developer account):":
      "Beim ersten Start (die App ist nicht mit einem Apple-Developer-Account signiert):",
    "1. Open %@ and drag CloudMachine.app to Applications.":
      "1. %@ öffnen und CloudMachine.app in den Ordner „Programme“ ziehen.",
    "2. In Finder, RIGHT-click CloudMachine.app -> Open -> Open\n   (a plain double-click shows the Gatekeeper block \"unidentified developer\").":
      "2. Im Finder CloudMachine.app mit der RECHTEN Maustaste anklicken -> Öffnen -> Öffnen\n   (ein einfacher Doppelklick zeigt die Gatekeeper-Sperre „nicht identifizierter Entwickler“).",
    "3. Later launches work normally, with a double-click.":
      "3. Spätere Starts funktionieren normal, per Doppelklick.",
    "Builds CloudMachine.app (Release) - GUI + cloudmachine-agent in Contents/MacOS/, plus launchd/, vm/ and config/ as Resources.":
      "Erstellt CloudMachine.app (Release) – GUI + cloudmachine-agent in Contents/MacOS/, dazu launchd/, vm/ und config/ als Ressourcen.",
    "Binaries for Apple Silicon and Intel at once (how CI builds a release; unnecessary locally).":
      "Programmdateien für Apple Silicon und Intel zugleich (so baut CI ein Release; lokal unnötig).",
    "==> Building CloudMachineApp + cloudmachine-agent (release) - version %@ (%@)":
      "==> CloudMachineApp + cloudmachine-agent werden erstellt (Release) – Version %@ (%@)",
    "ERROR: swift build exited with code %@.":
      "FEHLER: swift build wurde mit Code %@ beendet.",
    "ERROR: swift build --show-bin-path did not report the binaries directory.":
      "FEHLER: swift build --show-bin-path hat das Verzeichnis der Programmdateien nicht gemeldet.",
    "ERROR: no built binary found at %@":
      "FEHLER: keine erstellte Programmdatei unter %@ gefunden",
    "==> Assembling the .app bundle in %@":
      "==> .app-Bundle wird in %@ zusammengestellt",
    "==> WARNING: you are building from a DIRTY tree - the version will not point to a commit.":
      "==> WARNUNG: Build aus einem UNSAUBEREN Verzeichnisbaum – die Version verweist nicht auf einen Commit.",
    "ERROR: Resources/AppIcon.icns is missing - generate it: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns":
      "FEHLER: Resources/AppIcon.icns fehlt – erzeugen mit: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns",
    "==> Signing with the local certificate '%@' (Full Disk Access will survive later rebuilds)":
      "==> Signierung mit dem lokalen Zertifikat '%@' (Festplattenvollzugriff bleibt bei späteren Builds erhalten)",
    "==> Signing ad-hoc (no Apple Developer account) - run 'cloudmachine-agent setup-signing-cert' once so that TCC permissions survive later rebuilds":
      "==> Ad-hoc-Signierung (kein Apple-Developer-Account) – einmal 'cloudmachine-agent setup-signing-cert' ausführen, damit TCC-Berechtigungen spätere Builds überdauern",
    "ERROR: codesign exited with code %@.":
      "FEHLER: codesign wurde mit Code %@ beendet.",
    "Next step: %@":
      "Nächster Schritt: %@",
    "Creates a local self-signed certificate so that Full Disk Access survives later rebuilds of the app.":
      "Erstellt ein lokales selbstsigniertes Zertifikat, damit der Festplattenvollzugriff spätere Builds der App überdauert.",
    "Certificate '%@' already exists in %@, nothing to do.":
      "Zertifikat '%@' ist bereits in %@ vorhanden, nichts zu tun.",
    "==> Generating the key and self-signed certificate '%@'...":
      "==> Schlüssel und selbstsigniertes Zertifikat '%@' werden erzeugt ...",
    "ERROR: openssl req exited with code %@.":
      "FEHLER: openssl req wurde mit Code %@ beendet.",
    "ERROR: openssl pkcs12 exited with code %@.":
      "FEHLER: openssl pkcs12 wurde mit Code %@ beendet.",
    "==> Importing the certificate into %@ (pre-authorizing /usr/bin/codesign, so it does not ask for the keychain password every time)...":
      "==> Zertifikat wird in %@ importiert (/usr/bin/codesign wird vorab autorisiert, damit nicht jedes Mal nach dem Schlüsselbund-Kennwort gefragt wird) ...",
    "ERROR: security import exited with code %@.":
      "FEHLER: security import wurde mit Code %@ beendet.",
    "==> Trusting the certificate ONLY for code signing...":
      "==> Zertifikat wird NUR für die Codesignierung als vertrauenswürdig markiert ...",
    "ERROR: security add-trusted-cert exited with code %@.":
      "FEHLER: security add-trusted-cert wurde mit Code %@ beendet.",
    "Done. Certificate '%@' is now available to codesign.":
      "Fertig. Zertifikat '%@' steht jetzt für codesign zur Verfügung.",
    "The next 'cloudmachine-agent build-app' will use it automatically instead of an ad-hoc signature.":
      "Der nächste 'cloudmachine-agent build-app' verwendet es automatisch statt einer Ad-hoc-Signatur.",
    "After THAT ONE rebuild, grant Full Disk Access one last time - later\nrebuilds will no longer reset it, as long as you sign with the same certificate.":
      "Nach DIESEM EINEN Neubau den Festplattenvollzugriff ein letztes Mal erteilen – spätere\nNeubauten setzen ihn nicht mehr zurück, solange mit demselben Zertifikat signiert wird.",
    "Checks whether the hourly cycle STILL works (date of the last SUCCESSFUL backup) and reports failures.":
      "Prüft, ob der stündliche Zyklus NOCH funktioniert (Datum des letzten ERFOLGREICHEN Backups), und meldet Fehler.",
    "After this many hours without a successful backup we consider the cycle broken.":
      "Nach so vielen Stunden ohne erfolgreiches Backup gilt der Zyklus als defekt.",
    "Only print the state, without a system notification.":
      "Nur den Status ausgeben, ohne Systemmitteilung.",
    "A different Time Machine preferences file - to test the watchdog on a known sample.":
      "Eine andere Time-Machine-Einstellungsdatei – um den Wächter an einer bekannten Probe zu testen.",
    "Last successful backup: %@":
      "Letztes erfolgreiches Backup: %@",
    "Last successful backup: NONE":
      "Letztes erfolgreiches Backup: KEINES",
    "Last attempt:           %@":
      "Letzter Versuch:         %@",
    "WAITING (system startup): %@":
      "WARTET (Systemstart): %@",
    "Backup cycle: OK":
      "Backup-Zyklus: OK",
    "FAILURE: %@":
      "FEHLER: %@",
    "         %@":
      "        %@",
    "Check the state:  %@":
      "Status prüfen:    %@",
    "Preparing for restart":
      "Vorbereitung auf Neustart",
    "Prepare for restart":
      "Auf Neustart vorbereiten",
    "Prepare":
      "Vorbereiten",
    "==> WARNING: git rev-list failed (%@) - using the date as the build number.":
      "==> WARNUNG: git rev-list ist fehlgeschlagen (%@) – das Datum wird als Build-Nummer verwendet.",
    "Agents:           %@":
      "Agents:           %@",
    "CANNOT START: %@ - open CloudMachine or run backup-health to reload them":
      "KANN NICHT STARTEN: %@ – CloudMachine öffnen oder backup-health ausführen, um sie neu zu laden",
    "Reloaded agents that could not start: %@":
      "Agents neu geladen, die nicht starten konnten: %@",
    "Drive folder:     %@":
      "Drive-Ordner:     %@",
    "Name of this Mac's folder on Google Drive (default: derived from the computer name). Set once; it cannot be changed later.":
      "Name des Ordners dieses Macs in Google Drive (Standard: vom Computernamen abgeleitet). Wird einmal festgelegt und lässt sich später nicht ändern.",
    "Backup watchdog:  %@":
      "Backup-Wächter:   %@",
    "Prints the version, the build number and the commit this binary was built from.":
      "Gibt die Version, die Build-Nummer und den Commit aus, aus dem diese Programmdatei gebaut wurde.",
    "Only one line, without a description.":
      "Nur eine Zeile, ohne Beschreibung.",
    "Build from the working tree (outside a bundle) - no version data.":
      "Build aus dem Arbeitsverzeichnis (außerhalb eines Bundles) – keine Versionsdaten.",
    "Version: %@":
      "Version: %@",
    "Build:   %@":
      "Build:   %@",
    "Commit:  %@":
      "Commit:  %@",
    "WARNING: built from a DIRTY tree - the binary contains code that\n         is in no commit. The commit number does NOT describe\n         what actually runs.":
      "WARNUNG: aus einem UNSAUBEREN Verzeichnisbaum gebaut – die Programmdatei enthält Code,\n         der in keinem Commit steht. Die Commit-Nummer beschreibt NICHT,\n         was tatsächlich läuft.",
    "Saving the space limit":
      "Speicherlimit wird gesichert",
    "Measuring usage on Google Drive":
      "Nutzung auf Google Drive wird gemessen",
    "Google Drive did not answer - try again later.":
      "Google Drive hat nicht geantwortet – später erneut versuchen.",
    "Measured.":
      "Gemessen.",
    "Space limit for this Mac":
      "Speicherlimit für diesen Mac",
    "Used on Google Drive":
      "Auf Google Drive belegt",
    "Measured %@. The watchdog measures again every few hours.":
      "Gemessen %@. Der Wächter misst alle paar Stunden erneut.",
    "Limit (GB)":
      "Limit (GB)",
    "Save":
      "Sichern",
    "Measure now":
      "Jetzt messen",
    "Time Machine quota: %@ GB (70%% of the limit - the copy on Drive is about a third larger than the backup inside it). Time Machine deletes the oldest backups to stay within it.":
      "Kontingent für Time Machine: %@ GB (70%% des Limits – die Kopie auf Drive ist etwa ein Drittel größer als das darin enthaltene Backup). Time Machine löscht die ältesten Backups, um darunter zu bleiben.",
    "Set the Time Machine quota: run this in Terminal (needs sudo)":
      "Kontingent für Time Machine festlegen: im Terminal ausführen (erfordert sudo)",
    "Connect Google Drive: run this in Terminal and approve in the browser":
      "Google Drive verbinden: im Terminal ausführen und im Browser bestätigen",
    "Grant Full Disk Access to CloudMachine, so it can tell whether backups complete":
      "CloudMachine den Festplattenvollzugriff erteilen, damit erkannt wird, ob Backups abgeschlossen sind",
    "Folder on Google Drive":
      "Ordner auf Google Drive",
    "One folder per Mac. Set once - it cannot be changed after connecting.":
      "Ein Ordner pro Mac. Wird einmal festgelegt und lässt sich nach dem Verbinden nicht mehr ändern.",
    "Use lowercase letters, digits and dashes.":
      "Nur Kleinbuchstaben, Ziffern und Bindestriche verwenden.",
    "Install rclone":
      "rclone installieren",
    "Open System Settings":
      "Systemeinstellungen öffnen",
    "Install agents":
      "Agents installieren",
    "not checked":
      "nicht geprüft",
    "none at all":
      "überhaupt keine",
    "%@ ago":
      "vor %@",
    "Missing: %@":
      "Fehlt: %@",
    "Google Drive not connected":
      "Google Drive nicht verbunden",
    "Time Machine does not point to CloudMachine":
      "Time Machine verweist nicht auf CloudMachine",
    "UNKNOWN whether Time Machine points to CloudMachine - tmutil did not answer":
      "UNKLAR, ob Time Machine auf CloudMachine verweist – tmutil hat nicht geantwortet",
    "Backup in progress":
      "Backup läuft",
    "Unknown when the last backup was made":
      "Unbekannt, wann das letzte Backup erstellt wurde",
    "There is no completed backup at all":
      "Es gibt überhaupt kein abgeschlossenes Backup",
    "No completed backup for %@":
      "Seit %@ kein abgeschlossenes Backup",
    "Ready":
      "Bereit",
    "Not saved: %@":
      "Nicht gesichert: %@",
    "Installing rclone":
      "rclone wird installiert",
    "Installing launchd agents":
      "launchd-Agents werden installiert",
    "Starting backup":
      "Backup wird gestartet",
    "Backup started.":
      "Backup gestartet.",
    "Could not start the backup.":
      "Das Backup konnte nicht gestartet werden.",
    "Stopping backup":
      "Backup wird angehalten",
    "Backup stopped.":
      "Backup angehalten.",
    "Could not stop the backup.":
      "Das Backup konnte nicht angehalten werden.",
    "Could not prepare the AppleScript.":
      "Das AppleScript konnte nicht vorbereitet werden.",
    "Unknown authorization error.":
      "Unbekannter Autorisierungsfehler.",
    "Waiting to upload":
      "Wartet auf Upload",
    "%@ files":
      "%@ Dateien",
    "nothing":
      "nichts",
    "Back up now":
      "Jetzt sichern",
    "Stop backup":
      "Backup anhalten",
    "Open CloudMachine":
      "CloudMachine öffnen",
    "Quit":
      "Beenden",
    "Healthy":
      "Einwandfrei",
    "Attention":
      "Achtung",
    "Refreshed %@":
      "Aktualisiert %@",
    "System Status":
      "Systemstatus",
    "Action needed":
      "Handlung erforderlich",
    "not measured":
      "nicht gemessen",
    "rclone did not answer":
      "rclone hat nicht geantwortet",
    "Backup in Progress":
      "Backup läuft",
    "Files processed":
      "Verarbeitete Dateien",
    "Write speed":
      "Schreibgeschwindigkeit",
    "Operation phase":
      "Vorgangsphase",
    "Required Setup Steps":
      "Erforderliche Einrichtungsschritte",
    "Copy":
      "Kopieren",
    "Last completed backup":
      "Letztes abgeschlossenes Backup",
    "Last backup watchdog run":
      "Letzter Lauf des Backup-Wächters",
    "not read":
      "nicht gelesen",
    "Everything uploaded":
      "Alles hochgeladen",
    "File upload errors":
      "Fehler beim Datei-Upload",
    "Google Drive Credentials (OAuth 2.0)":
      "Google-Drive-Zugangsdaten (OAuth 2.0)",
    "Keychain OK":
      "Schlüsselbund OK",
    "No custom keys":
      "Keine eigenen Schlüssel",
    "Paste client_id...":
      "client_id einsetzen ...",
    "Paste client_secret...":
      "client_secret einsetzen ...",
    "Save securely in the Keychain":
      "Sicher im Schlüsselbund sichern",
    "Refresh":
      "Aktualisieren",
    "Overview":
      "Übersicht",
    "Backups":
      "Backups",
    "Storage":
      "Speicher",
    "Settings":
      "Einstellungen",
    "Current status: %@":
      "Aktueller Status: %@",
    "Does not point to CloudMachine":
      "Verweist nicht auf CloudMachine",
    "tmutil did not answer":
      "tmutil hat nicht geantwortet",
    "Backing up: %@ of %@":
      "Backup: %@ von %@",
    "%@ of %@":
      "%@ von %@",
    "Copied":
      "Kopiert",
    "No backup is running":
      "Es läuft kein Backup",
    "Time Machine starts the next one on its own schedule.":
      "Time Machine startet das nächste nach eigenem Zeitplan.",
    "Backup cycle":
      "Backup-Zyklus",
    "%@ GiB":
      "%@ GiB",
    "%@ GiB in %@ bands, %@ uploading":
      "%@ GiB in %@ Bändern, %@ werden hochgeladen",
    "%@ bands":
      "%@ Bänder",
    "%@ fragments abandoned - only in the machine":
      "%@ Fragmente aufgegeben – nur in der Maschine vorhanden",
    "127.0.0.1:5572 answers on the Mac: Lima forwards the machine's rclone remote control, which has no password. Any web page open in a browser can send it commands - including deleting the backup on Google Drive. Add the portForwards rule from vm/cmsmb.yaml to the machine and restart it (see vm/README.md).":
      "127.0.0.1:5572 antwortet auf dem Mac: Lima leitet die rclone-Fernsteuerung der Maschine weiter, die kein Kennwort hat. Jede im Browser geöffnete Webseite kann ihr Befehle senden – auch zum Löschen des Backups auf Google Drive. Die portForwards-Regel aus vm/cmsmb.yaml zur Maschine hinzufügen und sie neu starten (siehe vm/README.md).",
    "A service in the CloudMachine machine is not running":
      "Ein Dienst in der CloudMachine-Maschine läuft nicht",
    "Address":
      "Adresse",
    "Agent installation INCOMPLETE - %@ of %@ did not go in:\n%@\n%@\nEvery missing agent is a function that has silently stopped working (vm-guard watches the machine's buffer, backup-health reports failures). Fix the cause and repeat the installation.":
      "Installation der Agents UNVOLLSTÄNDIG – %@ von %@ wurden nicht installiert:\n%@\n%@\nJeder fehlende Agent ist eine Funktion, die unbemerkt ausgefallen ist (vm-guard überwacht den Puffer der Maschine, backup-health meldet Fehler). Ursache beheben und die Installation wiederholen.",
    "All running":
      "Alle laufen",
    "Also install the launchd agents (same as install-launchd).":
      "Auch die launchd-Agents installieren (wie install-launchd).",
    "At most this many minutes of waiting for the upload.":
      "Höchstens so viele Minuten auf den Upload warten.",
    "At the limit every new band fails with EMFILE and the backup stops. Check: cloudmachine-agent vm-status":
      "Am Limit schlägt jedes neue Band mit EMFILE fehl und das Backup hält an. Prüfen: cloudmachine-agent vm-status",
    "Cache on the machine's disk":
      "Cache auf der Festplatte der Maschine",
    "Connected to Google Drive, but could not create the folder '%@' - without it the machine has nowhere to keep the backup. Check the account permissions and try again.":
      "Mit Google Drive verbunden, aber der Ordner '%@' konnte nicht angelegt werden – ohne ihn kann die Maschine das Backup nirgends ablegen. Berechtigungen des Kontos prüfen und erneut versuchen.",
    "Convert the image":
      "Image konvertieren",
    "Converting the image to 32 MB bands":
      "Image wird in 32-MB-Bänder konvertiert",
    "Could not check with the current connection whether the backup is on Google Drive (%@), so remote '%@' was NOT replaced: without that answer the new sign-in cannot be checked against it.":
      "Mit der aktuellen Verbindung konnte nicht geprüft werden, ob das Backup auf Google Drive liegt (%@); Remote '%@' wurde daher NICHT ersetzt: ohne diese Antwort lässt sich die neue Anmeldung nicht dagegen prüfen.",
    "Downloads the official rclone binary into ~/.cloudmachine/bin (Google sign-in and the machine's rclone.conf).":
      "Lädt die offizielle rclone-Programmdatei nach ~/.cloudmachine/bin herunter (Google-Anmeldung und rclone.conf der Maschine).",
    "Free in the machine":
      "Frei in der Maschine",
    "Free in the machine: %@":
      "Frei in der Maschine: %@",
    "Generates and installs the launchd agents (app, backup watchdog, machine start, machine guard).":
      "Erzeugt und installiert die launchd-Agents (App, Backup-Wächter, Maschinenstart, Maschinenwächter).",
    "Install Lima, which runs the CloudMachine machine: run this in Terminal":
      "Lima installieren, das die CloudMachine-Maschine ausführt: im Terminal ausführen",
    "Install rclone (signs in to Google Drive for the machine)":
      "rclone installieren (meldet die Maschine bei Google Drive an)",
    "Install the background agents (machine start, buffer guard, backup watchdog)":
      "Die Hintergrund-Agents installieren (Maschinenstart, Pufferwächter, Backup-Wächter)",
    "Installs rclone through Homebrew - CloudMachine itself uses the one from install-rclone.":
      "Installiert rclone über Homebrew – CloudMachine selbst verwendet die Version aus install-rclone.",
    "Info.plist, token and mapped/ of the backup image exist only on the machine's disk; without them the bands in %@ cannot be restored. The copy (tm-meta-sync, every 15 min) goes to %@. Check: cloudmachine-agent vm-status, then in the machine: journalctl -u tm-meta-sync":
      "Info.plist, Token und mapped/ des Backup-Images existieren nur auf der Festplatte der Maschine; ohne sie lassen sich die Bänder in %@ nicht wiederherstellen. Die Kopie (tm-meta-sync, alle 15 Min.) geht nach %@. Prüfen: cloudmachine-agent vm-status, dann in der Maschine: journalctl -u tm-meta-sync",
    "Lima says the machine is running, but a command in it did not return. Without it nothing is known about Samba, rclone or the upload. Check: cloudmachine-agent vm-status":
      "Lima meldet, dass die Maschine läuft, aber ein Befehl darin ist nicht zurückgekehrt. Ohne ihn ist nichts über Samba, rclone oder den Upload bekannt. Prüfen: cloudmachine-agent vm-status",
    "Machine":
      "Maschine",
    "Machine %@":
      "Maschine %@",
    "Machine & Upload Status":
      "Status von Maschine und Upload",
    "Machine buffer":
      "Puffer der Maschine",
    "No Time Machine destination is the machine's share (smb://tm@<address>/CloudMachine) - backups are not being made there. The command is printed by: cloudmachine-agent vm-setup":
      "Kein Time-Machine-Ziel ist die Freigabe der Maschine (smb://tm@<address>/CloudMachine) – dort werden keine Backups erstellt. Der Befehl wird ausgegeben von: cloudmachine-agent vm-setup",
    "Not running: %@":
      "Läuft nicht: %@",
    "Not set up":
      "Nicht eingerichtet",
    "Once it runs out, rclone stops uploading, the machine's buffer fills up and backups stop being made. At a growth of ~600 MB per hourly cycle that is about %@ days.":
      "Sobald er erschöpft ist, lädt rclone nichts mehr hoch, der Puffer der Maschine füllt sich und es werden keine Backups mehr erstellt. Bei einem Zuwachs von ca. 600 MB pro stündlichem Zyklus sind das etwa %@ Tage.",
    "Or rclone.conf is missing: this Mac has already set up the CloudMachine machine, so it is not connected anew blindly. Restore the file from a backup (the machine keeps its own copy in %@). To connect anyway, create an empty file at the path `%@ config file` prints and run again - the existing folder is kept.":
      "Oder rclone.conf fehlt: Dieser Mac hat die CloudMachine-Maschine bereits eingerichtet, daher wird nicht blind neu verbunden. Die Datei aus einem Backup wiederherstellen (die Maschine hält eine eigene Kopie in %@). Um trotzdem zu verbinden, eine leere Datei am Pfad anlegen, den `%@ config file` ausgibt, und erneut ausführen – der vorhandene Ordner bleibt erhalten.",
    "Point Time Machine at the machine: run this in Terminal (needs sudo; Copy includes the password)":
      "Time Machine auf die Maschine ausrichten: im Terminal ausführen (erfordert sudo; „Kopieren“ enthält das Kennwort)",
    "Points to the machine":
      "Verweist auf die Maschine",
    "Prepares for a restart: stops the backup, waits a while for the upload, then stops the machine cleanly.":
      "Bereitet einen Neustart vor: hält das Backup an, wartet eine Weile auf den Upload und fährt dann die Maschine sauber herunter.",
    "Reading the Time Machine destination did not return within %@ s. That is how tmutil behaves when its destination hangs.":
      "Das Lesen des Time-Machine-Ziels kam innerhalb von %@ s nicht zurück. So verhält sich tmutil, wenn sein Ziel hängt.",
    "Remote '%@' was NOT replaced. The new sign-in gets the 'drive.file' scope, which sees only files created under its own client_id. The existing backup was most likely created by the current connection and would become invisible to it. Before anything is written, the new token is checked against the existing backup, and the replacement is abandoned if it cannot see it. The machine keeps its own copy of the configuration until vm-setup --replace-rclone-config. To go ahead, run again with --replace-existing --accept-scope-change.":
      "Remote '%@' wurde NICHT ersetzt. Die neue Anmeldung erhält den Bereich 'drive.file', der nur Dateien sieht, die unter ihrer eigenen client_id erstellt wurden. Das vorhandene Backup wurde höchstwahrscheinlich von der aktuellen Verbindung erstellt und würde für sie unsichtbar. Bevor etwas geschrieben wird, wird das neue Token am vorhandenen Backup geprüft, und der Austausch wird abgebrochen, wenn es dieses nicht sehen kann. Die Maschine behält ihre eigene Kopie der Konfiguration bis vm-setup --replace-rclone-config. Um fortzufahren, erneut mit --replace-existing --accept-scope-change ausführen.",
    "Remote control:   OPEN on the Mac at 127.0.0.1:5572 - any web page can send rclone commands; see vm/README.md (portForwards)":
      "Fernsteuerung:    OFFEN auf dem Mac unter 127.0.0.1:5572 – jede Webseite kann rclone-Befehle senden; siehe vm/README.md (portForwards)",
    "Running":
      "Läuft",
    "Samba, rclone or punchfs in the machine is not active, so Time Machine has nowhere to write or the bands do not reach Google Drive. Check: cloudmachine-agent vm-status":
      "Samba, rclone oder punchfs in der Maschine ist nicht aktiv, daher kann Time Machine nirgends schreiben oder die Bänder erreichen Google Drive nicht. Prüfen: cloudmachine-agent vm-status",
    "Service %@":
      "Dienst %@",
    "Services":
      "Dienste",
    "Set up the CloudMachine machine (the first time it downloads Ubuntu - several minutes)":
      "Die CloudMachine-Maschine einrichten (beim ersten Mal wird Ubuntu geladen – mehrere Minuten)",
    "Set up the CloudMachine machine again, so it prints the Time Machine command":
      "Die CloudMachine-Maschine erneut einrichten, damit sie den Time-Machine-Befehl ausgibt",
    "Set up the machine":
      "Maschine einrichten",
    "Setting up the CloudMachine machine":
      "CloudMachine-Maschine wird eingerichtet",
    "Start the CloudMachine machine":
      "Die CloudMachine-Maschine starten",
    "Start the machine":
      "Maschine starten",
    "Starting the CloudMachine machine":
      "CloudMachine-Maschine wird gestartet",
    "Still to upload: %@ GiB":
      "Noch hochzuladen: %@ GiB",
    "Stopping the Time Machine backup...":
      "Time-Machine-Backup wird angehalten ...",
    "Stopping the machine %@...":
      "Maschine %@ wird angehalten ...",
    "The CloudMachine machine does not answer":
      "Die CloudMachine-Maschine antwortet nicht",
    "The CloudMachine machine is not running":
      "Die CloudMachine-Maschine läuft nicht",
    "The CloudMachine machine is not set up yet":
      "Die CloudMachine-Maschine ist noch nicht eingerichtet",
    "The CloudMachine machine is stopped":
      "Die CloudMachine-Maschine ist angehalten",
    "The backup is stopped, the upload gets up to 30 minutes, then the machine shuts down cleanly. It starts again at the next login.":
      "Das Backup wird angehalten, der Upload erhält bis zu 30 Minuten, dann fährt die Maschine sauber herunter. Sie startet bei der nächsten Anmeldung wieder.",
    "The machine %@ is not running - nothing to prepare.":
      "Die Maschine %@ läuft nicht – nichts vorzubereiten.",
    "The machine is stopped and everything reached Google Drive. The Mac can be restarted; the machine starts again at login.":
      "Die Maschine ist angehalten und alles hat Google Drive erreicht. Der Mac kann neu gestartet werden; die Maschine startet bei der Anmeldung wieder.",
    "The machine is stopped. %@ GiB had not reached Google Drive yet - it is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "Die Maschine ist angehalten. %@ GiB hatten Google Drive noch nicht erreicht – sie bleiben im Puffer der Maschine und werden nach dem nächsten Start hochgeladen. Der Mac kann neu gestartet werden.",
    "The machine is stopped. rclone did not say how much was still to upload; what was not uploaded is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "Die Maschine ist angehalten. rclone hat nicht gemeldet, wie viel noch hochzuladen war; was nicht hochgeladen wurde, bleibt im Puffer der Maschine und wird nach dem nächsten Start hochgeladen. Der Mac kann neu gestartet werden.",
    "The machine's disk is a file on this disk and grows as the upload buffer fills. With no space left the machine cannot write the buffer, and Time Machine's local snapshots have nowhere to go either.":
      "Die Festplatte der Maschine ist eine Datei auf diesem Volume und wächst, während sich der Upload-Puffer füllt. Ohne freien Platz kann die Maschine den Puffer nicht schreiben, und auch die lokalen Schnappschüsse von Time Machine haben keinen Platz.",
    "The image's metadata has never been copied to Drive":
      "Die Metadaten des Images wurden noch nie nach Drive kopiert",
    "The image's metadata was last copied to Drive %@ ago":
      "Die Metadaten des Images wurden zuletzt vor %@ nach Drive kopiert",
    "The machine's disk is running out of space (%@ GB)":
      "Der Festplatte der Maschine geht der Speicherplatz aus (%@ GB)",
    "The new sign-in does NOT see the existing backup (%@), so remote '%@' was NOT replaced and rclone.conf is unchanged. Keep the current connection, or sign in with the credential (client_id) that created the backup.":
      "Die neue Anmeldung sieht das vorhandene Backup NICHT (%@), daher wurde Remote '%@' NICHT ersetzt und rclone.conf ist unverändert. Die aktuelle Verbindung beibehalten oder sich mit den Zugangsdaten (client_id) anmelden, mit denen das Backup erstellt wurde.",
    "The upload buffer lives on this disk. The guard pauses Time Machine before it fills; if the upload does not catch up, backups stay paused.":
      "Der Upload-Puffer liegt auf dieser Festplatte. Der Wächter hält Time Machine an, bevor er sich füllt; holt der Upload nicht auf, bleiben die Backups angehalten.",
    "These bands exist only in the machine's buffer. The backup on Google Drive is INCOMPLETE and may not open.":
      "Diese Bänder existieren nur im Puffer der Maschine. Das Backup auf Google Drive ist UNVOLLSTÄNDIG und lässt sich eventuell nicht öffnen.",
    "Time Machine backs up to the machine, so without it no backup is made. Start it: limactl start %@ (or the Start button in the app).":
      "Time Machine sichert auf die Maschine, ohne sie wird also kein Backup erstellt. Starten mit: limactl start %@ (oder mit dem Button „Maschine starten“ in der App).",
    "Time Machine did not stop its backup within 2 minutes (or tmutil did not answer) - the machine was NOT stopped. Try again in a moment.":
      "Time Machine hat sein Backup nicht innerhalb von 2 Minuten angehalten (oder tmutil hat nicht geantwortet) – die Maschine wurde NICHT angehalten. In einem Moment erneut versuchen.",
    "Time Machine has created its image: stop the backup, then convert the image to 32 MB bands":
      "Time Machine hat sein Image erstellt: das Backup anhalten, dann das Image in 32-MB-Bänder konvertieren",
    "To upload":
      "Hochzuladen",
    "Unknown whether the CloudMachine machine is running":
      "Unklar, ob die CloudMachine-Maschine läuft",
    "Waiting for the upload to Google Drive (at most %@ min)...":
      "Warten auf den Upload zu Google Drive (höchstens %@ Min.) ...",
    "With --replace-existing: confirms that the new sign-in (scope 'drive.file') may not see the existing backup. The new token is still checked against the backup first.":
      "Mit --replace-existing: bestätigt, dass die neue Anmeldung (Bereich 'drive.file') das vorhandene Backup eventuell nicht sieht. Das neue Token wird zuvor trotzdem am Backup geprüft.",
    "Without it there is no way to check whether anything reached the Drive - the machine's guard is blind then.":
      "Ohne ihn lässt sich nicht prüfen, ob etwas Drive erreicht hat – der Wächter der Maschine ist dann blind.",
    "limactl did not answer":
      "limactl hat nicht geantwortet",
    "limactl did not answer (or is not installed). That does not mean the machine is down - it means nobody has checked.":
      "limactl hat nicht geantwortet (oder ist nicht installiert). Das heißt nicht, dass die Maschine ausgefallen ist – es heißt, dass es niemand geprüft hat.",
    "limactl start failed: %@":
      "limactl start fehlgeschlagen: %@",
    "limactl stop failed: %@":
      "limactl stop fehlgeschlagen: %@",
    "punchfs is close to its open-file limit":
      "punchfs nähert sich seinem Limit für offene Dateien",
    "punchfs open files":
      "Offene Dateien von punchfs",
    "rclone's remote control is open on this Mac":
      "Die Fernsteuerung von rclone ist auf diesem Mac offen",
    "statfs('/System/Volumes/Data') returned an error, so nobody knows whether the machine's disk can still grow on this Mac.":
      "statfs('/System/Volumes/Data') hat einen Fehler zurückgegeben, daher ist unklar, ob die Festplatte der Maschine auf diesem Mac noch wachsen kann.",
    "Google Drive's daily upload limit stops the upload":
      "Das tägliche Upload-Limit von Google Drive stoppt den Upload",
    "Google last refused an upload %@ ago (750 GB a day). Backups since then are only in the machine's buffer on this Mac. rclone retries every 5 min and resumes by itself when the limit passes; the guard pauses Time Machine if more than %@ GiB waits.":
      "Google hat vor %@ zuletzt einen Upload abgelehnt (750 GB pro Tag). Backups seitdem liegen nur im Puffer der Maschine auf diesem Mac. rclone versucht es alle 5 Min. erneut und macht von selbst weiter, sobald das Limit vorbei ist; der Wächter hält Time Machine an, wenn mehr als %@ GiB warten.",
    "Usage on Google Drive is not being measured":
      "Die Nutzung auf Google Drive wird nicht gemessen",
    "The last measurement (%@ GB) is from %@, %@ ago - rclone size has not answered since. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "Die letzte Messung (%@ GB) stammt von %@, vor %@ – rclone size hat seitdem nicht geantwortet. Bis dahin überwacht nichts das Limit von %@ GB: die Alarme bei 90%% und 100%% bleiben stumm. vm-status prüfen oder im Fenster auf „Jetzt messen“ klicken.",
    "rclone size has not answered even once. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "rclone size hat noch kein einziges Mal geantwortet. Bis dahin überwacht nichts das Limit von %@ GB: die Alarme bei 90%% und 100%% bleiben stumm. vm-status prüfen oder im Fenster auf „Jetzt messen“ klicken.",
    "Saved in the Keychain. Connecting Google Drive (configure-remote) will use them.":
      "Im Schlüsselbund gesichert. Die Verbindung zu Google Drive (configure-remote) verwendet sie.",
    "Saved in the Keychain. The existing Google Drive connection keeps its old client_id, and on this Mac it should stay that way: a connection made with the new keys (the 'drive.file' scope) cannot see the backup created by the old one. Do not replace the connection here; the new keys are for a Mac that is not connected yet.":
      "Im Schlüsselbund gesichert. Die vorhandene Verbindung zu Google Drive behält ihre alte client_id, und auf diesem Mac sollte das so bleiben: Eine mit den neuen Schlüsseln hergestellte Verbindung (Bereich 'drive.file') kann das mit der alten erstellte Backup nicht sehen. Die Verbindung hier nicht ersetzen; die neuen Schlüssel sind für einen Mac, der noch nicht verbunden ist.",
    "it is not there for the new token":
      "für das neue Token ist es nicht vorhanden",
    "Cancel":
      "Abbrechen",
    "ACTION NEEDED":
      "HANDLUNG ERFORDERLICH",
    "WILL PASS BY ITSELF — DO NOTHING":
      "ERLEDIGT SICH VON SELBST – NICHTS TUN",
    "UNKNOWN — CHECK AGAIN SHORTLY":
      "UNKLAR – BALD ERNEUT PRÜFEN",
    "ALL GOOD":
      "ALLES IN ORDNUNG",
    "Upload is not working":
      "Upload funktioniert nicht",
    "Upload stopped — no space left on Google Drive":
      "Upload angehalten – kein Speicherplatz mehr auf Google Drive",
    "%@ backup fragments not uploaded":
      "%@ Backup-Fragmente nicht hochgeladen",
    "Upload cannot keep up with writes":
      "Upload kommt mit dem Schreiben nicht mit",
    "Upload paused — Google daily limit":
      "Upload pausiert – Tageslimit von Google",
    "Uploading to Google Drive — %@ queued":
      "Upload zu Google Drive – %@ in der Warteschlange",
    "Everything uploaded to Google Drive":
      "Alles zu Google Drive hochgeladen",
    "Unknown what is waiting in the queue":
      "Unklar, was in der Warteschlange wartet",
    "There is no connection to Google Drive, so backups are only made on this Mac. If this does not pass by itself within a few minutes, check the network and the connection to Drive.":
      "Es besteht keine Verbindung zu Google Drive, daher werden Backups nur auf diesem Mac erstellt. Falls sich das nicht innerhalb weniger Minuten von selbst löst, das Netzwerk und die Verbindung zu Drive prüfen.",
    "There is no space left on Google Drive. This will NOT pass by itself — you need to free up space on Drive. Until then Time Machine is paused, so that it does not fill up this Mac's disk.":
      "Auf Google Drive ist kein Speicherplatz mehr frei. Das erledigt sich NICHT von selbst – auf Drive muss Speicherplatz freigegeben werden. Bis dahin ist Time Machine angehalten, damit es die Festplatte dieses Macs nicht füllt.",
    "%@ backup fragments could not be uploaded and rclone stopped trying. These fragments exist only on this Mac, so the backup on Drive is incomplete. This needs checking.":
      "%@ Backup-Fragmente konnten nicht hochgeladen werden und rclone hat aufgegeben. Diese Fragmente existieren nur auf diesem Mac, das Backup auf Drive ist also unvollständig. Das muss geprüft werden.",
    "Time Machine is writing faster than the upload goes, and the buffer has filled up. The backup will be paused until the upload catches up — this is a safeguard against filling up the disk, not a failure.":
      "Time Machine schreibt schneller, als der Upload läuft, und der Puffer ist voll. Das Backup wird angehalten, bis der Upload aufgeholt hat – das ist ein Schutz vor dem Füllen der Festplatte, kein Fehler.",
    "Google accepts 750 GB per day and that limit has been used up. There is nothing to do: the limit renews by itself, usually within a few hours. Time Machine backups are made normally in the meantime and wait in the buffer — they will be uploaded as soon as Google starts accepting again.":
      "Google akzeptiert 750 GB pro Tag und dieses Limit ist ausgeschöpft. Es gibt nichts zu tun: Das Limit erneuert sich von selbst, meist innerhalb weniger Stunden. Time-Machine-Backups werden in der Zwischenzeit normal erstellt und warten im Puffer – sie werden hochgeladen, sobald Google wieder annimmt.",
    "%@ backup fragments are queued and on their way to Drive.":
      "%@ Backup-Fragmente sind in der Warteschlange und auf dem Weg zu Drive.",
    "Nothing is waiting in the queue — the backup on Google Drive is complete.":
      "In der Warteschlange wartet nichts – das Backup auf Google Drive ist vollständig.",
    "rclone did not answer the question about the queue, so it is unknown how many backups are still waiting to be uploaded. This does not mean something broke — under load the answer can be late. It only means that right now nobody knows. If it persists, the backup cycle check will report it.":
      "rclone hat die Frage nach der Warteschlange nicht beantwortet, daher ist unklar, wie viele Backups noch auf den Upload warten. Das heißt nicht, dass etwas kaputt ist – unter Last kann die Antwort verspätet kommen. Es heißt nur, dass es im Moment niemand weiß. Besteht das Problem fort, meldet es die Prüfung des Backup-Zyklus.",
    "unknown error":
      "unbekannter Fehler",
    "rclone lsf ended with an error":
      "rclone lsf wurde mit einem Fehler beendet",
    "This Mac is close to its space limit on Google Drive":
      "Dieser Mac nähert sich seinem Speicherlimit auf Google Drive",
    "%@ GB of %@ GB used. Time Machine deletes the oldest backups to stay within its quota; check that the quota is set (vm-status).":
      "%@ GB von %@ GB belegt. Time Machine löscht die ältesten Backups, um sein Kontingent einzuhalten; prüfen, ob das Kontingent gesetzt ist (vm-status).",
    "This Mac is over its space limit on Google Drive":
      "Dieser Mac hat sein Speicherlimit auf Google Drive überschritten",
    "%@ GB of %@ GB used. Set the Time Machine quota (command in the app window or vm-status), or raise the limit.":
      "%@ GB von %@ GB belegt. Das Kontingent für Time Machine festlegen (Befehl im App-Fenster oder in vm-status) oder das Limit erhöhen.",
    "not set":
      "nicht gesetzt",
    "%@ GB - usage not measured yet":
      "%@ GB – Nutzung noch nicht gemessen",
    "%@ of %@ GB used (%@%%)":
      "%@ von %@ GB belegt (%@%%)",
    "The limit must be a whole number of GB above zero.":
      "Das Limit muss eine ganze Zahl von GB größer als null sein.",
    "machines.json cannot be read, so it was not overwritten. Fix or remove it first.":
      "machines.json kann nicht gelesen werden und wurde daher nicht überschrieben. Zuerst korrigieren oder entfernen.",
    "'%@' is not a valid folder name: use lowercase letters, digits and dashes.":
      "'%@' ist kein gültiger Ordnername: Kleinbuchstaben, Ziffern und Bindestriche verwenden.",
    "This Mac already backs up to folder '%@'. Switching to '%@' would start a new, empty backup and orphan the existing one, so nothing was changed.":
      "Dieser Mac sichert bereits in den Ordner '%@'. Der Wechsel zu '%@' würde ein neues, leeres Backup beginnen und das vorhandene verwaisen lassen, daher wurde nichts geändert.",
    "This Mac already has a CloudMachine installation, whose backup is in folder '%@'. Switching to '%@' would orphan it, so nothing was changed.":
      "Dieser Mac hat bereits eine CloudMachine-Installation, deren Backup im Ordner '%@' liegt. Der Wechsel zu '%@' würde es verwaisen lassen, daher wurde nichts geändert.",
    "Could not save the folder name to %@: %@":
      "Der Ordnername konnte nicht in %@ gesichert werden: %@",
    "Homebrew is not installed. Install it manually: https://brew.sh":
      "Homebrew ist nicht installiert. Manuell installieren: https://brew.sh",
    "Installing rclone failed: %@":
      "Installation von rclone fehlgeschlagen: %@",
    "Installed rclone.":
      "rclone installiert.",
    "Own Google credentials: set.":
      "Eigene Google-Zugangsdaten: gesetzt.",
    "INCOMPLETE: %@ is missing - rclone will use rclone's shared client_id anyway.":
      "UNVOLLSTÄNDIG: %@ fehlt – rclone verwendet trotzdem die gemeinsame client_id von rclone.",
    "No own credentials - rclone uses the shared client_id, rate-limited jointly and being retired in 2026.":
      "Keine eigenen Zugangsdaten – rclone verwendet die gemeinsame client_id, die gemeinsam ratenbegrenzt ist und 2026 eingestellt wird.",
    "Empty value - not saving.":
      "Leerer Wert – wird nicht gesichert.",
    "Keychain refused: %@":
      "Schlüsselbund hat abgelehnt: %@",
    "DIRTY-TREE":
      "UNSAUBERER-BAUM",
    "Cannot create the working directory: %@":
      "Das Arbeitsverzeichnis kann nicht angelegt werden: %@",
    "Could not read the rclone version number.":
      "Die Versionsnummer von rclone konnte nicht gelesen werden.",
    "Could not download %@.":
      "%@ konnte nicht geladen werden.",
    "No entry for %@ in SHA256SUMS.":
      "Kein Eintrag für %@ in SHA256SUMS.",
    "Could not compute the checksum.":
      "Die Prüfsumme konnte nicht berechnet werden.",
    "SHA256 checksum does not match - NOT installing.\n  expected: %@\n  computed: %@":
      "SHA256-Prüfsumme stimmt nicht überein – wird NICHT installiert.\n  erwartet: %@\n  berechnet: %@",
    "Could not unpack the archive.":
      "Das Archiv konnte nicht entpackt werden.",
    "Could not install the binary: %@":
      "Die Programmdatei konnte nicht installiert werden: %@",
    "Installed rclone %@ in %@ (SHA256 checksum matches).":
      "rclone %@ in %@ installiert (SHA256-Prüfsumme stimmt überein).",
    "%@ did not respond within the allotted time (the process was left orphaned in the background).":
      "%@ hat nicht innerhalb der vorgesehenen Zeit geantwortet (der Prozess blieb verwaist im Hintergrund).",
    "Cannot launch %@: %@":
      "%@ kann nicht gestartet werden: %@",
    "Remote '%@' already exists and was NOT touched.\nOverwriting it replaces the token and the permission scope; a credential with the 'drive.file' scope does not see files created by the previous one, so the existing backup becomes unreachable.\nIf you really want to replace it, first back up ~/.config/rclone/rclone.conf and run again with --replace-existing.":
      "Remote '%@' existiert bereits und wurde NICHT angetastet.\nDas Überschreiben ersetzt Token und Berechtigungsbereich; Zugangsdaten mit dem Bereich 'drive.file' sehen keine Dateien, die von den vorherigen erstellt wurden, das vorhandene Backup wäre also nicht mehr erreichbar.\nUm es wirklich zu ersetzen, zuerst ~/.config/rclone/rclone.conf sichern und erneut mit --replace-existing ausführen.",
    "Could not check whether remote '%@' already exists (rclone listremotes did not answer or failed), so nothing was changed. Run `%@ listremotes` to see the error, then try again.":
      "Es konnte nicht geprüft werden, ob Remote '%@' bereits existiert (rclone listremotes hat nicht geantwortet oder ist fehlgeschlagen), daher wurde nichts geändert. `%@ listremotes` ausführen, um den Fehler zu sehen, und dann erneut versuchen.",
    "Could not check whether this Mac already has a CloudMachine installation (rclone did not answer), so no folder was chosen. Try again in a moment.":
      "Es konnte nicht geprüft werden, ob dieser Mac bereits eine CloudMachine-Installation hat (rclone hat nicht geantwortet), daher wurde kein Ordner gewählt. In einem Moment erneut versuchen.",
    "rclone authorize failed (%@). If that binary is missing, start with: cloudmachine-agent install-rclone.":
      "rclone authorize fehlgeschlagen (%@). Falls die Programmdatei fehlt, zuerst ausführen: cloudmachine-agent install-rclone.",
    "Could not read the token from the output of rclone authorize.":
      "Das Token konnte aus der Ausgabe von rclone authorize nicht gelesen werden.",
    "rclone config create failed.":
      "rclone config create fehlgeschlagen.",
    "Connected to Google Drive as remote '%@', folder %@.":
      "Mit Google Drive als Remote '%@' verbunden, Ordner %@.",
    "tmutil is not responding - unknown where the backup goes":
      "tmutil antwortet nicht – unklar, wohin das Backup geht",
    "No successful backup for %@":
      "Seit %@ kein erfolgreiches Backup",
    "Last COMPLETED backup: %@. The cycle is hourly, so that is %@ missed runs.":
      "Letztes ABGESCHLOSSENES Backup: %@. Der Zyklus ist stündlich, das sind also %@ verpasste Läufe.",
    "There is NOT A SINGLE successful backup":
      "Es gibt KEIN EINZIGES erfolgreiches Backup",
    "The Time Machine preferences contain no date of a completed backup for this destination.":
      "Die Time-Machine-Einstellungen enthalten kein Datum eines abgeschlossenen Backups für dieses Ziel.",
    "The last backup attempt did not end in a backup":
      "Der letzte Backup-Versuch hat nicht zu einem Backup geführt",
    "The attempt at %@ is newer than the last successful backup at %@.":
      "Der Versuch um %@ ist neuer als das letzte erfolgreiche Backup um %@.",
    "Time Machine reports an error in the last run (RESULT=%@)":
      "Time Machine meldet einen Fehler im letzten Lauf (RESULT=%@)",
    "A non-zero RESULT in the Time Machine preferences means the run did not succeed.":
      "Ein RESULT ungleich null in den Time-Machine-Einstellungen bedeutet, dass der Lauf nicht erfolgreich war.",
    "rclone failed to upload %@ files":
      "rclone konnte %@ Dateien nicht hochladen",
    "Buffer full of nothing but unsent data":
      "Puffer nur noch voll mit ungesendeten Daten",
    "rclone has nothing left to evict from the buffer - the upload cannot keep up or has stalled.":
      "rclone kann nichts mehr aus dem Puffer verdrängen – der Upload kommt nicht mit oder ist ins Stocken geraten.",
    "The rclone control interface is not responding":
      "Die rclone-Steuerschnittstelle antwortet nicht",
    "Google Drive is running out of space (%@ GB)":
      "Auf Google Drive wird der Speicherplatz knapp (%@ GB)",
    "The Mac's disk is running out of space (%@ GB)":
      "Auf der Festplatte des Macs wird der Speicherplatz knapp (%@ GB)",
    "Cannot read the Time Machine preferences":
      "Die Time-Machine-Einstellungen können nicht gelesen werden",
    "%@ is unreadable - most often Full Disk Access is missing. Without this file it is UNKNOWN when the last backup was made, so we treat it as a failure, not as the absence of a problem.":
      "%@ ist nicht lesbar – meistens fehlt der Festplattenvollzugriff. Ohne diese Datei ist UNKLAR, wann das letzte Backup erstellt wurde, daher wird es als Fehler behandelt und nicht als Abwesenheit eines Problems.",
    "Cannot measure free space on the Mac's disk":
      "Freier Speicherplatz auf der Festplatte des Macs kann nicht gemessen werden",
    "%@ days":
      "%@ Tage",
    "CloudMachine: backup is not working":
      "CloudMachine: Backup funktioniert nicht",
    "unknown reason":
      "unbekannter Grund",
    "osascript did not show the notification (permissions or no graphical session)":
      "osascript hat die Mitteilung nicht angezeigt (Berechtigungen oder keine grafische Sitzung)",
    "UNDELIVERED ALARM: %@":
      "NICHT ZUGESTELLTER ALARM: %@",
    "from %@, reason: %@":
      "von %@, Grund: %@",
    "The system notification was not delivered - you will see this alarm ONLY here.":
      "Die Systemmitteilung wurde nicht zugestellt – dieser Alarm ist NUR hier zu sehen.",
    "%@ (%@ ago)":
      "%@ (vor %@)",
    "%@ - marker from the FUTURE":
      "%@ – Markierung aus der ZUKUNFT",
    "%@ (%@ ago) - THE WATCHDOG MAY NOT BE RUNNING":
      "%@ (vor %@) – DER WÄCHTER LÄUFT EVENTUELL NICHT",
    "NEVER - the watchdog has not recorded a single run":
      "NIE – der Wächter hat keinen einzigen Lauf aufgezeichnet",
    "Could not find the launchd/ directory with templates.":
      "Das launchd/-Verzeichnis mit den Vorlagen wurde nicht gefunden.",
    "Could not find the compiled cloudmachine-agent binary.":
      "Die kompilierte Programmdatei cloudmachine-agent wurde nicht gefunden.",
    "ABORTED: could not put cloudmachine-agent in a stable location\n(%@) - most often a lack of space or permissions.\nNOT installing agents pointing at %@: that path\ndisappears on the next `swift build` or `git clean`, and backups stop\nwithout any visible signal.":
      "ABGEBROCHEN: cloudmachine-agent konnte nicht an einen stabilen Ort gelegt werden\n(%@) – meistens fehlt Speicherplatz oder eine Berechtigung.\nAgents, die auf %@ verweisen, werden NICHT installiert: dieser Pfad\nverschwindet beim nächsten `swift build` oder `git clean`, und Backups enden\nohne jedes sichtbare Signal.",
    "ABORTED: %@":
      "ABGEBROCHEN: %@",
    "Could not list the templates in %@.":
      "Die Vorlagen in %@ konnten nicht aufgelistet werden.",
    "could not read the template %@":
      "Die Vorlage %@ konnte nicht gelesen werden",
    "could not write %@ (lack of space or permissions)":
      "%@ konnte nicht geschrieben werden (Speicherplatz oder Berechtigung fehlt)",
    "launchctl load refused to load %@":
      "launchctl load hat das Laden von %@ abgelehnt",
    "NOT A SINGLE agent was loaded.":
      "KEIN EINZIGER Agent wurde geladen.",
    "Only these went in: %@.":
      "Nur diese wurden installiert: %@.",
    "Could not load any launchd agent.":
      "Kein launchd-Agent konnte geladen werden.",
    "Installed agents: %@":
      "Installierte Agents: %@",
    "                  WARNING: close to the limit - new bands will fail with EMFILE":
      "                  WARNUNG: nahe am Limit – neue Bänder schlagen mit EMFILE fehl",
    "%@/bands on Google Drive is not empty - it may hold another backup. NOT overwriting it; check it by hand.":
      "%@/bands auf Google Drive ist nicht leer – es enthält eventuell ein anderes Backup. Wird NICHT überschrieben; von Hand prüfen.",
    "Address:          %@":
      "Adresse:          %@",
    "Already prepared (%@ exists) - nothing to do.":
      "Bereits vorbereitet (%@ existiert) – nichts zu tun.",
    "Converts Time Machine's new, empty image in the machine to 32 MB bands and moves the bands to Google Drive.":
      "Konvertiert das neue, leere Image von Time Machine in der Maschine in 32-MB-Bänder und verschiebt die Bänder nach Google Drive.",
    "Copy rclone.conf into the machine even if it already has one.":
      "rclone.conf in die Maschine kopieren, auch wenn sie bereits eine hat.",
    "Copying the converted image into the machine failed: %@":
      "Das Kopieren des konvertierten Images in die Maschine ist fehlgeschlagen: %@",
    "Copying the image to the Mac failed: %@":
      "Das Kopieren des Images auf den Mac ist fehlgeschlagen: %@",
    "Could not ask Lima about the machine: %@":
      "Lima konnte nicht zur Maschine befragt werden: %@",
    "Could not carry the Time Machine files over: %@":
      "Die Time-Machine-Dateien konnten nicht übertragen werden: %@",
    "Could not check the image in the machine.":
      "Das Image in der Maschine konnte nicht geprüft werden.",
    "Could not copy the rclone configuration into the machine.":
      "Die rclone-Konfiguration konnte nicht in die Maschine kopiert werden.",
    "Could not create %@ on Google Drive: %@":
      "%@ konnte nicht auf Google Drive angelegt werden: %@",
    "Could not create %@: %@":
      "%@ konnte nicht angelegt werden: %@",
    "Could not find the vm/ directory with the machine template.":
      "Das vm/-Verzeichnis mit der Maschinenvorlage wurde nicht gefunden.",
    "Could not read the image size.":
      "Die Größe des Images konnte nicht gelesen werden.",
    "Could not set the SMB password of user %@ in the machine.":
      "Das SMB-Kennwort des Benutzers %@ in der Maschine konnte nicht gesetzt werden.",
    "Could not stop smbd in the machine.":
      "smbd in der Maschine konnte nicht angehalten werden.",
    "Could not write %@ in the machine.":
      "%@ konnte in der Maschine nicht geschrieben werden.",
    "Could not write the password file %@.":
      "Die Kennwortdatei %@ konnte nicht geschrieben werden.",
    "Creates or starts the CloudMachine machine (Lima), gives it rclone's configuration and an SMB password, and prints the Time Machine command.":
      "Erstellt oder startet die CloudMachine-Maschine (Lima), gibt ihr die Konfiguration von rclone und ein SMB-Kennwort und gibt den Time-Machine-Befehl aus.",
    "Creating the machine %@ (first start downloads Ubuntu and installs packages - several minutes)...":
      "Maschine %@ wird erstellt (beim ersten Start werden Ubuntu und Pakete geladen – mehrere Minuten) ...",
    "Done: %@ has %@ MB bands on Google Drive; the original is kept in %@ in the machine. Start the backup: tmutil startbackup":
      "Fertig: %@ hat %@-MB-Bänder auf Google Drive; das Original bleibt in %@ in der Maschine erhalten. Backup starten: tmutil startbackup",
    "exit code %@, no message":
      "Exit-Code %@, keine Meldung",
    "Image metadata:   NEVER copied to %@ - check tm-meta-sync in the machine":
      "Image-Metadaten:   NIE nach %@ kopiert – tm-meta-sync in der Maschine prüfen",
    "Image metadata:   copied %@ ago to %@":
      "Image-Metadaten:   vor %@ nach %@ kopiert",
    "Image metadata:   last copied %@ ago - OVERDUE (%@)":
      "Image-Metadaten:   zuletzt vor %@ kopiert – ÜBERFÄLLIG (%@)",
    "Image metadata:   not copied yet - waits for vm-prepare-bundle":
      "Image-Metadaten:   noch nicht kopiert – wartet auf vm-prepare-bundle",
    "Backup %@, paused by the guard %@: %@":
      "Backup %@, vom Wächter angehalten %@: %@",
    "Free in machine:  %@ GiB":
      "Frei in Maschine: %@ GiB",
    "fsck_apfs -n found problems: %@":
      "fsck_apfs -n hat Probleme gefunden: %@",
    "Google Drive folder: %@":
      "Google-Drive-Ordner: %@",
    "hdiutil attach of the converted image failed: %@":
      "hdiutil attach des konvertierten Images fehlgeschlagen: %@",
    "hdiutil convert failed: %@":
      "hdiutil convert fehlgeschlagen: %@",
    "Image name in the machine (default: from the computer name).":
      "Name des Images in der Maschine (Standard: vom Computernamen abgeleitet).",
    "Installing the converted image FAILED: %@\nsmbd is left STOPPED so Time Machine does not open a half-installed image. The original is in %@ in the machine.":
      "Installation des konvertierten Images FEHLGESCHLAGEN: %@\nsmbd bleibt ANGEHALTEN, damit Time Machine kein halb installiertes Image öffnet. Das Original liegt in %@ in der Maschine.",
    "limactl create failed: %@":
      "limactl create fehlgeschlagen: %@",
    "limactl list failed: %@":
      "limactl list fehlgeschlagen: %@",
    "limactl not found - install Lima: brew install lima":
      "limactl nicht gefunden – Lima installieren: brew install lima",
    "limactl start failed: %@\nThe machine's own log: %@":
      "limactl start fehlgeschlagen: %@\nDas eigene Protokoll der Maschine: %@",
    "Machine %@ is running.":
      "Maschine %@ läuft.",
    "Machine %@ was already running.":
      "Maschine %@ lief bereits.",
    "Machine:          %@ (%@)":
      "Maschine:         %@ (%@)",
    "Machine:          %@":
      "Maschine:         %@",
    "Machine:          not created - run: cloudmachine-agent vm-setup":
      "Maschine:         nicht angelegt – ausführen: cloudmachine-agent vm-setup",
    "no answer within the time limit":
      "keine Antwort innerhalb des Zeitlimits",
    "No image %@ in the machine.":
      "Kein Image %@ in der Maschine.",
    "No image in the machine yet - point Time Machine at the share and let it create one first.":
      "Noch kein Image in der Maschine – Time Machine auf die Freigabe ausrichten und zuerst eines erstellen lassen.",
    "No rclone configuration at %@ - connect Google Drive first (configure-remote).":
      "Keine rclone-Konfiguration unter %@ – zuerst Google Drive verbinden (configure-remote).",
    "no SMB destination":
      "kein SMB-Ziel",
    "One check of the machine's upload buffer: pauses Time Machine when it fills, resumes what it paused.":
      "Eine Prüfung des Upload-Puffers der Maschine: hält Time Machine an, wenn er sich füllt, und setzt fort, was angehalten wurde.",
    "Packing the converted image failed: %@":
      "Das Packen des konvertierten Images ist fehlgeschlagen: %@",
    "Packing the image failed: %@":
      "Das Packen des Images ist fehlgeschlagen: %@",
    "No answer from the machine (rclone rc) - the guard would do nothing.":
      "Keine Antwort der Maschine (rclone rc) – der Wächter würde nichts tun.",
    "Only print what the guard would decide - for trying thresholds on a throwaway machine.":
      "Nur ausgeben, was der Wächter entscheiden würde – zum Ausprobieren von Schwellenwerten auf einer Wegwerf-Maschine.",
    "Pause above this many GiB in the buffer.":
      "Anhalten, wenn mehr als so viele GiB im Puffer liegen.",
    "Pause when the machine has less free than this, in GiB.":
      "Anhalten, wenn die Maschine weniger als so viel frei hat, in GiB.",
    "Point Time Machine at the machine (once, needs an administrator password):":
      "Time Machine auf die Maschine ausrichten (einmalig, erfordert ein Administratorkennwort):",
    "punchfs files:    %@ open, limit %@":
      "punchfs-Dateien:  %@ offen, Limit %@",
    "rclone configuration already in the machine - kept (--replace-rclone-config replaces it).":
      "rclone-Konfiguration ist bereits in der Maschine – bleibt erhalten (--replace-rclone-config ersetzt sie).",
    "rclone configuration copied into the machine.":
      "rclone-Konfiguration in die Maschine kopiert.",
    "rclone-tm or punchfs is not running in the machine - see cloudmachine-agent vm-status.":
      "rclone-tm oder punchfs läuft nicht in der Maschine – siehe cloudmachine-agent vm-status.",
    "Resume below this many GiB (only a backup the guard paused).":
      "Fortsetzen unterhalb von so vielen GiB (nur bei einem vom Wächter angehaltenen Backup).",
    "Service %@: %@":
      "Dienst %@: %@",
    "Several images in the machine (%@) - choose one with --bundle.":
      "Mehrere Images in der Maschine (%@) – eines mit --bundle wählen.",
    "Shows the machine: address, services, upload buffer, free space and the Time Machine destination.":
      "Zeigt die Maschine: Adresse, Dienste, Upload-Puffer, freien Speicherplatz und das Time-Machine-Ziel.",
    "SMB password stored in %@ (mode 600).":
      "SMB-Kennwort in %@ gesichert (Modus 600).",
    "The converted image does not have %@-byte bands.":
      "Das konvertierte Image hat keine Bänder mit %@ Byte.",
    "The converted image has no APFS partition.":
      "Das konvertierte Image hat keine APFS-Partition.",
    "The image already takes %@ MB - this command converts only a new, empty image (under %@ MB).":
      "Das Image belegt bereits %@ MB – dieser Befehl konvertiert nur ein neues, leeres Image (unter %@ MB).",
    "The image is encrypted - converting encrypted images is not supported.":
      "Das Image ist verschlüsselt – das Konvertieren verschlüsselter Images wird nicht unterstützt.",
    "The image was not changed; smbd started again.":
      "Das Image wurde nicht geändert; smbd wurde wieder gestartet.",
    "The machine does not answer - is it running? cloudmachine-agent vm-status":
      "Die Maschine antwortet nicht – läuft sie? cloudmachine-agent vm-status",
    "The machine has no address on the vzNAT network.":
      "Die Maschine hat keine Adresse im vzNAT-Netzwerk.",
    "The services in the machine did not start - check: cloudmachine-agent vm-status":
      "Die Dienste in der Maschine sind nicht gestartet – prüfen: cloudmachine-agent vm-status",
    "Time Machine is backing up - stop it first: tmutil stopbackup":
      "Time Machine sichert gerade – zuerst anhalten: tmutil stopbackup",
    "Time Machine:     %@":
      "Time Machine:     %@",
    "Time Machine:     NOT pointing at the machine (%@)":
      "Time Machine:     zeigt NICHT auf die Maschine (%@)",
    "Time Machine:     tmutil did not answer":
      "Time Machine:     tmutil hat nicht geantwortet",
    "tmutil did not answer - not touching the image while its state is unknown.":
      "tmutil hat nicht geantwortet – das Image wird nicht angefasst, solange sein Zustand unbekannt ist.",
    "unknown":
      "unbekannt",
    "Unpacking the image failed: %@":
      "Das Entpacken des Images ist fehlgeschlagen: %@",
    "Still to upload:  %@ GiB in %@ bands, uploading %@ (cache on disk %@ GiB)":
      "Noch hochzuladen: %@ GiB in %@ Bändern, %@ werden hochgeladen (Cache auf Festplatte %@ GiB)",
    "Excluded %@ (the machine and its upload buffer) from Time Machine.":
      "%@ (die Maschine und ihr Upload-Puffer) von Time Machine ausgeschlossen.",
    "WARNING: could not exclude %@ from Time Machine - run: tmutil addexclusion %@":
      "WARNUNG: %@ konnte nicht von Time Machine ausgeschlossen werden – ausführen: tmutil addexclusion %@",
    "Upload buffer:    no answer from rclone (rc %@)":
      "Upload-Puffer:    keine Antwort von rclone (rc %@)",
    "When Time Machine has created its empty image, stop the backup (tmutil stopbackup) and run: cloudmachine-agent vm-prepare-bundle":
      "Wenn Time Machine sein leeres Image erstellt hat, das Backup anhalten (tmutil stopbackup) und ausführen: cloudmachine-agent vm-prepare-bundle",
    "Unsent %@ GiB, free %@ GiB (pause above %@ GiB unsent or below %@ GiB free, resume below %@ GiB).":
      "Ungesendet %@ GiB, frei %@ GiB (Anhalten bei mehr als %@ GiB ungesendet oder weniger als %@ GiB frei, Fortsetzen unterhalb von %@ GiB).",
    "Upload:           Google's daily limit refused an upload %@ ago - rclone retries every 5 min and resumes by itself":
      "Upload:           Das Tageslimit von Google hat vor %@ einen Upload abgelehnt – rclone versucht es alle 5 Min. erneut und macht von selbst weiter",
    "no":
      "nein",
    "running":
      "läuft",
    "stopped":
      "angehalten",
    "yes":
      "ja",
    "%@\nThe previous template is in %@ - copy it back over lima.yaml and run limactl start %@.":
      "%@\nDie vorherige Vorlage liegt in %@ – über lima.yaml zurückkopieren und limactl start %@ ausführen.",
    "Could not read this app's machine template (limactl template copy).":
      "Die Maschinenvorlage dieser App konnte nicht gelesen werden (limactl template copy).",
    "Could not replace %@: %@":
      "%@ konnte nicht ersetzt werden: %@",
    "Machine %@ already runs this app's template.":
      "Maschine %@ läuft bereits mit der Vorlage dieser App.",
    "Machine %@ now runs this app's template; the previous one is in %@.":
      "Maschine %@ läuft jetzt mit der Vorlage dieser App; die vorherige liegt in %@.",
    "Moves the machine onto this app's template (two restarts, never during a backup).":
      "Stellt die Maschine auf die Vorlage dieser App um (zwei Neustarts, nie während eines Backups).",
    "No machine %@ - create it with: cloudmachine-agent vm-setup":
      "Keine Maschine %@ – anlegen mit: cloudmachine-agent vm-setup",
    "Template:         OLDER than this app's - run: cloudmachine-agent vm-update":
      "Vorlage:          ÄLTER als die dieser App – ausführen: cloudmachine-agent vm-update",
    "Template:         not compared":
      "Vorlage:          nicht verglichen",
    "Template:         this app's":
      "Vorlage:          die dieser App",
    "The machine has no %@ - run cloudmachine-agent vm-setup first.":
      "Die Maschine hat kein %@ – zuerst cloudmachine-agent vm-setup ausführen.",
    "The machine restarted, but not every service is running - check: cloudmachine-agent vm-status. The previous template is in %@.":
      "Die Maschine wurde neu gestartet, aber nicht alle Dienste laufen – prüfen: cloudmachine-agent vm-status. Die vorherige Vorlage liegt in %@.",
    "The template changes the machine itself (%@) - that needs a new machine, not an update.":
      "Die Vorlage ändert die Maschine selbst (%@) – dafür ist eine neue Maschine nötig, kein Update.",
    "The upload to Google Drive hangs":
      "Der Upload zu Google Drive hängt",
    "Time Machine is backing up - try again when it has finished.":
      "Time Machine sichert gerade – erneut versuchen, wenn es fertig ist.",
    "Upload:           HANGS - bands in progress, none uploaded for %@ (network?); see /var/log/rclone-tm.log in the machine":
      "Upload:           HÄNGT – Bänder in Bearbeitung, seit %@ keines hochgeladen (Netzwerk?); siehe /var/log/rclone-tm.log in der Maschine",
    "limactl stop failed - nothing was changed.":
      "limactl stop fehlgeschlagen – nichts wurde geändert.",
    "rclone has bands in progress, but none has been uploaded for %@ - usually a broken network connection, which rclone does not report as an error. Backups since then are only in the machine's buffer. When the network comes back the upload resumes by itself (on 28.10.2026 within 80 s); if it does not, restarting the machine (prepare-shutdown, limactl start) drops the dead connections.":
      "rclone hat Bänder in Bearbeitung, aber seit %@ wurde keines hochgeladen – meist eine unterbrochene Netzwerkverbindung, die rclone nicht als Fehler meldet. Backups seitdem liegen nur im Puffer der Maschine. Sobald das Netzwerk wieder da ist, macht der Upload von selbst weiter (am 28.10.2026 innerhalb von 80 s); falls nicht, verwirft ein Neustart der Maschine (prepare-shutdown, limactl start) die toten Verbindungen.",
    "tmutil did not answer - not restarting the machine while its state is unknown.":
      "tmutil hat nicht geantwortet – die Maschine wird nicht neu gestartet, solange ihr Zustand unbekannt ist.",
  ]
}
