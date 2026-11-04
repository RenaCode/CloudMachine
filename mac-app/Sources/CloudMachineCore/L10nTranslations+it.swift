// Italian translations, keyed by the English text passed to `L10n.tr`.
extension L10nTranslations {
  static let it: [String: String] = [
    "Space limit:      %@":
      "Limite di spazio: %@",
    "                  Time Machine quota not set to match - run: %@":
      "                  Quota di Time Machine non impostata di conseguenza - esegui: %@",
    "Sets how much of Google Drive this Mac may use, and prints the Time Machine quota command.":
      "Imposta quanto spazio su Google Drive può usare questo Mac e stampa il comando per la quota di Time Machine.",
    "Limit in GB.":
      "Limite in GB.",
    "Limit for this Mac: %@ GB.":
      "Limite per questo Mac: %@ GB.",
    "Now set the Time Machine quota (needs an administrator password):":
      "Ora imposta la quota di Time Machine (serve la password di un amministratore):",
    "CloudMachine - verification, Google Drive setup and installation. Called by launchd on a schedule, or by hand from Terminal.":
      "CloudMachine - verifica, configurazione di Google Drive e installazione. Chiamato da launchd a intervalli regolari, o a mano da Terminale.",
    "Connects to Google Drive through rclone (OAuth in the browser) and creates this machine's folder.":
      "Si collega a Google Drive tramite rclone (OAuth nel browser) e crea la cartella di questa macchina.",
    "Overwrite the existing remote. RISKY: replaces the token and permissions.":
      "Sovrascrivi il remote esistente. RISCHIOSO: sostituisce il token e i permessi.",
    "Packs build/CloudMachine.app into build/CloudMachine-<version>.dmg.":
      "Impacchetta build/CloudMachine.app in build/CloudMachine-<versione>.dmg.",
    "ERROR: %@ is missing - run 'cloudmachine-agent build-app' first":
      "ERRORE: %@ non c'è - esegui prima 'cloudmachine-agent build-app'",
    "==> Preparing the staging folder":
      "==> Preparazione della cartella temporanea",
    "==> Creating %@":
      "==> Creazione di %@",
    "ERROR: hdiutil exited with code %@.":
      "ERRORE: hdiutil è terminato con il codice %@.",
    "==> Done: %@":
      "==> Fatto: %@",
    "On first launch (the app is not signed with an Apple Developer account):":
      "Al primo avvio (l'app non è firmata con un account Apple Developer):",
    "1. Open %@ and drag CloudMachine.app to Applications.":
      "1. Apri %@ e trascina CloudMachine.app nella cartella Applicazioni.",
    "2. In Finder, RIGHT-click CloudMachine.app -> Open -> Open\n   (a plain double-click shows the Gatekeeper block \"unidentified developer\").":
      "2. Nel Finder, fai clic con il tasto DESTRO su CloudMachine.app -> Apri -> Apri\n   (un semplice doppio clic mostra il blocco di Gatekeeper «sviluppatore non identificato»).",
    "3. Later launches work normally, with a double-click.":
      "3. Gli avvii successivi funzionano normalmente, con un doppio clic.",
    "Builds CloudMachine.app (Release) - GUI + cloudmachine-agent in Contents/MacOS/, plus launchd/, vm/ and config/ as Resources.":
      "Compila CloudMachine.app (Release) - interfaccia + cloudmachine-agent in Contents/MacOS/, più launchd/, vm/ e config/ come risorse.",
    "Binaries for Apple Silicon and Intel at once (how CI builds a release; unnecessary locally).":
      "Binari per Apple Silicon e Intel insieme (così il CI compila una versione; superfluo in locale).",
    "==> Building CloudMachineApp + cloudmachine-agent (release) - version %@ (%@)":
      "==> Compilazione di CloudMachineApp + cloudmachine-agent (release) - versione %@ (%@)",
    "ERROR: swift build exited with code %@.":
      "ERRORE: swift build è terminato con il codice %@.",
    "ERROR: swift build --show-bin-path did not report the binaries directory.":
      "ERRORE: swift build --show-bin-path non ha indicato la cartella dei binari.",
    "ERROR: no built binary found at %@":
      "ERRORE: nessun binario compilato trovato in %@",
    "==> Assembling the .app bundle in %@":
      "==> Assemblaggio del pacchetto .app in %@",
    "==> WARNING: you are building from a DIRTY tree - the version will not point to a commit.":
      "==> ATTENZIONE: stai compilando da un albero MODIFICATO - la versione non punterà a nessun commit.",
    "ERROR: Resources/AppIcon.icns is missing - generate it: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns":
      "ERRORE: Resources/AppIcon.icns non c'è - generalo: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns",
    "==> Signing with the local certificate '%@' (Full Disk Access will survive later rebuilds)":
      "==> Firma con il certificato locale '%@' (l'Accesso completo al disco sopravviverà alle ricompilazioni)",
    "==> Signing ad-hoc (no Apple Developer account) - run 'cloudmachine-agent setup-signing-cert' once so that TCC permissions survive later rebuilds":
      "==> Firma ad-hoc (senza account Apple Developer) - esegui una volta 'cloudmachine-agent setup-signing-cert' così i permessi TCC sopravvivono alle ricompilazioni",
    "ERROR: codesign exited with code %@.":
      "ERRORE: codesign è terminato con il codice %@.",
    "Next step: %@":
      "Passo successivo: %@",
    "Creates a local self-signed certificate so that Full Disk Access survives later rebuilds of the app.":
      "Crea un certificato locale autofirmato così l'Accesso completo al disco sopravvive alle ricompilazioni dell'app.",
    "Certificate '%@' already exists in %@, nothing to do.":
      "Il certificato '%@' esiste già in %@, non c'è nulla da fare.",
    "==> Generating the key and self-signed certificate '%@'...":
      "==> Generazione della chiave e del certificato autofirmato '%@'...",
    "ERROR: openssl req exited with code %@.":
      "ERRORE: openssl req è terminato con il codice %@.",
    "ERROR: openssl pkcs12 exited with code %@.":
      "ERRORE: openssl pkcs12 è terminato con il codice %@.",
    "==> Importing the certificate into %@ (pre-authorizing /usr/bin/codesign, so it does not ask for the keychain password every time)...":
      "==> Importazione del certificato in %@ (autorizzazione preventiva di /usr/bin/codesign, per non chiedere ogni volta la password del portachiavi)...",
    "ERROR: security import exited with code %@.":
      "ERRORE: security import è terminato con il codice %@.",
    "==> Trusting the certificate ONLY for code signing...":
      "==> Certificato considerato attendibile SOLO per la firma del codice...",
    "ERROR: security add-trusted-cert exited with code %@.":
      "ERRORE: security add-trusted-cert è terminato con il codice %@.",
    "Done. Certificate '%@' is now available to codesign.":
      "Fatto. Il certificato '%@' è ora disponibile per codesign.",
    "The next 'cloudmachine-agent build-app' will use it automatically instead of an ad-hoc signature.":
      "Il prossimo 'cloudmachine-agent build-app' lo userà automaticamente al posto di una firma ad-hoc.",
    "After THAT ONE rebuild, grant Full Disk Access one last time - later\nrebuilds will no longer reset it, as long as you sign with the same certificate.":
      "Dopo QUELLA UNICA ricompilazione, concedi l'Accesso completo al disco un'ultima volta - le\nricompilazioni successive non lo reimposteranno più, finché firmi con lo stesso certificato.",
    "Checks whether the hourly cycle STILL works (date of the last SUCCESSFUL backup) and reports failures.":
      "Controlla se il ciclo orario FUNZIONA ANCORA (data dell'ultimo backup RIUSCITO) e segnala i guasti.",
    "After this many hours without a successful backup we consider the cycle broken.":
      "Dopo questo numero di ore senza un backup riuscito consideriamo il ciclo interrotto.",
    "Only print the state, without a system notification.":
      "Stampa solo lo stato, senza notifica di sistema.",
    "A different Time Machine preferences file - to test the watchdog on a known sample.":
      "Un altro file delle preferenze di Time Machine - per provare il controllo su un campione noto.",
    "Last successful backup: %@":
      "Ultimo backup riuscito: %@",
    "Last successful backup: NONE":
      "Ultimo backup riuscito: NESSUNO",
    "Last attempt:           %@":
      "Ultimo tentativo:       %@",
    "WAITING (system startup): %@":
      "IN ATTESA (avvio del sistema): %@",
    "Backup cycle: OK":
      "Ciclo di backup: OK",
    "FAILURE: %@":
      "GUASTO: %@",
    "         %@":
      "        %@",
    "Check the state:  %@":
      "Controlla lo stato:  %@",
    "Preparing for restart":
      "Preparazione al riavvio",
    "Prepare for restart":
      "Prepara al riavvio",
    "Prepare":
      "Prepara",
    "==> WARNING: git rev-list failed (%@) - using the date as the build number.":
      "==> ATTENZIONE: git rev-list non è riuscito (%@) - come numero di build viene usata la data.",
    "Agents:           %@":
      "Agenti:           %@",
    "CANNOT START: %@ - open CloudMachine or run backup-health to reload them":
      "IMPOSSIBILE AVVIARE: %@ - apri CloudMachine o esegui backup-health per ricaricarli",
    "Reloaded agents that could not start: %@":
      "Agenti ricaricati che non erano riusciti ad avviarsi: %@",
    "Drive folder:     %@":
      "Cartella su Drive: %@",
    "Name of this Mac's folder on Google Drive (default: derived from the computer name). Set once; it cannot be changed later.":
      "Nome della cartella di questo Mac su Google Drive (predefinito: ricavato dal nome del computer). Si imposta una sola volta; non si può cambiare in seguito.",
    "Backup watchdog:  %@":
      "Controllo backup: %@",
    "Prints the version, the build number and the commit this binary was built from.":
      "Stampa la versione, il numero di build e il commit da cui è stato compilato questo binario.",
    "Only one line, without a description.":
      "Solo una riga, senza descrizione.",
    "Build from the working tree (outside a bundle) - no version data.":
      "Build dall'albero di lavoro (fuori da un pacchetto) - nessun dato sulla versione.",
    "Version: %@":
      "Versione: %@",
    "Build:   %@":
      "Build:    %@",
    "Commit:  %@":
      "Commit:   %@",
    "WARNING: built from a DIRTY tree - the binary contains code that\n         is in no commit. The commit number does NOT describe\n         what actually runs.":
      "ATTENZIONE: compilato da un albero MODIFICATO - il binario contiene codice che\n            non è in nessun commit. Il numero del commit NON descrive\n            ciò che viene davvero eseguito.",
    "Saving the space limit":
      "Salvataggio del limite di spazio",
    "Measuring usage on Google Drive":
      "Misurazione dello spazio usato su Google Drive",
    "Google Drive did not answer - try again later.":
      "Google Drive non ha risposto - riprova più tardi.",
    "Measured.":
      "Misurazione completata.",
    "Space limit for this Mac":
      "Limite di spazio per questo Mac",
    "Used on Google Drive":
      "Usato su Google Drive",
    "Measured %@. The watchdog measures again every few hours.":
      "Misurato %@. Il controllo misura di nuovo ogni poche ore.",
    "Limit (GB)":
      "Limite (GB)",
    "Save":
      "Salva",
    "Measure now":
      "Misura ora",
    "Time Machine quota: %@ GB (70%% of the limit - the copy on Drive is about a third larger than the backup inside it). Time Machine deletes the oldest backups to stay within it.":
      "Quota di Time Machine: %@ GB (70%% del limite - la copia su Drive è circa un terzo più grande del backup che contiene). Time Machine elimina i backup più vecchi per restare entro la quota.",
    "Set the Time Machine quota: run this in Terminal (needs sudo)":
      "Imposta la quota di Time Machine: esegui questo in Terminale (serve sudo)",
    "Connect Google Drive: run this in Terminal and approve in the browser":
      "Collega Google Drive: esegui questo in Terminale e approva nel browser",
    "Grant Full Disk Access to CloudMachine, so it can tell whether backups complete":
      "Concedi a CloudMachine l'Accesso completo al disco, così può capire se i backup vengono completati",
    "Folder on Google Drive":
      "Cartella su Google Drive",
    "One folder per Mac. Set once - it cannot be changed after connecting.":
      "Una cartella per Mac. Si imposta una sola volta - non si può cambiare dopo il collegamento.",
    "Use lowercase letters, digits and dashes.":
      "Usa lettere minuscole, cifre e trattini.",
    "Install rclone":
      "Installa rclone",
    "Open System Settings":
      "Apri Impostazioni di Sistema",
    "Install agents":
      "Installa gli agenti",
    "not checked":
      "non verificato",
    "none at all":
      "nessuno",
    "%@ ago":
      "%@ fa",
    "Missing: %@":
      "Manca: %@",
    "Google Drive not connected":
      "Google Drive non collegato",
    "Time Machine does not point to CloudMachine":
      "Time Machine non punta a CloudMachine",
    "UNKNOWN whether Time Machine points to CloudMachine - tmutil did not answer":
      "NON SI SA se Time Machine punti a CloudMachine - tmutil non ha risposto",
    "Backup in progress":
      "Backup in corso",
    "Unknown when the last backup was made":
      "Non si sa quando è stato fatto l'ultimo backup",
    "There is no completed backup at all":
      "Non c'è nessun backup completato",
    "No completed backup for %@":
      "Nessun backup completato da %@",
    "Ready":
      "Pronto",
    "Not saved: %@":
      "Non salvato: %@",
    "Installing rclone":
      "Installazione di rclone",
    "Installing launchd agents":
      "Installazione degli agenti launchd",
    "Starting backup":
      "Avvio del backup",
    "Backup started.":
      "Backup avviato.",
    "Could not start the backup.":
      "Impossibile avviare il backup.",
    "Stopping backup":
      "Arresto del backup",
    "Backup stopped.":
      "Backup arrestato.",
    "Could not stop the backup.":
      "Impossibile arrestare il backup.",
    "Could not prepare the AppleScript.":
      "Impossibile preparare l'AppleScript.",
    "Unknown authorization error.":
      "Errore di autorizzazione sconosciuto.",
    "Waiting to upload":
      "In attesa di invio",
    "%@ files":
      "%@ file",
    "nothing":
      "niente",
    "Back up now":
      "Esegui backup ora",
    "Stop backup":
      "Arresta backup",
    "Open CloudMachine":
      "Apri CloudMachine",
    "Quit":
      "Esci",
    "Healthy":
      "In buono stato",
    "Attention":
      "Attenzione",
    "Refreshed %@":
      "Aggiornato %@",
    "System Status":
      "Stato del sistema",
    "Action needed":
      "Azione richiesta",
    "not measured":
      "non misurato",
    "rclone did not answer":
      "rclone non ha risposto",
    "Backup in Progress":
      "Backup in corso",
    "Files processed":
      "File elaborati",
    "Write speed":
      "Velocità di scrittura",
    "Operation phase":
      "Fase dell'operazione",
    "Required Setup Steps":
      "Passi di configurazione richiesti",
    "Copy":
      "Copia",
    "Last completed backup":
      "Ultimo backup completato",
    "Last backup watchdog run":
      "Ultima esecuzione del controllo backup",
    "not read":
      "non letto",
    "Everything uploaded":
      "Tutto inviato",
    "File upload errors":
      "Errori di invio dei file",
    "Google Drive Credentials (OAuth 2.0)":
      "Credenziali di Google Drive (OAuth 2.0)",
    "Keychain OK":
      "Portachiavi OK",
    "No custom keys":
      "Nessuna chiave personalizzata",
    "Paste client_id...":
      "Incolla client_id...",
    "Paste client_secret...":
      "Incolla client_secret...",
    "Save securely in the Keychain":
      "Salva in modo sicuro nel Portachiavi",
    "Refresh":
      "Aggiorna",
    "Overview":
      "Panoramica",
    "Backups":
      "Backup",
    "Storage":
      "Archiviazione",
    "Settings":
      "Impostazioni",
    "Current status: %@":
      "Stato attuale: %@",
    "Does not point to CloudMachine":
      "Non punta a CloudMachine",
    "tmutil did not answer":
      "tmutil non ha risposto",
    "Backing up: %@ of %@":
      "Backup in corso: %@ di %@",
    "%@ of %@":
      "%@ di %@",
    "Copied":
      "Copiato",
    "No backup is running":
      "Nessun backup in corso",
    "Time Machine starts the next one on its own schedule.":
      "Time Machine avvierà il successivo secondo il proprio programma.",
    "Backup cycle":
      "Ciclo di backup",
    "%@ GiB":
      "%@ GiB",
    "%@ GiB in %@ bands, %@ uploading":
      "%@ GiB in %@ bande, %@ in invio",
    "%@ bands":
      "%@ bande",
    "%@ fragments abandoned - only in the machine":
      "%@ frammenti abbandonati - solo nella macchina",
    "127.0.0.1:5572 answers on the Mac: Lima forwards the machine's rclone remote control, which has no password. Any web page open in a browser can send it commands - including deleting the backup on Google Drive. Add the portForwards rule from vm/cmsmb.yaml to the machine and restart it (see vm/README.md).":
      "127.0.0.1:5572 risponde sul Mac: Lima inoltra il controllo remoto di rclone della macchina, che non ha password. Qualsiasi pagina web aperta in un browser può inviargli comandi - compresa l'eliminazione del backup su Google Drive. Aggiungi alla macchina la regola portForwards di vm/cmsmb.yaml e riavviala (vedi vm/README.md).",
    "A service in the CloudMachine machine is not running":
      "Un servizio nella macchina CloudMachine non è in esecuzione",
    "Address":
      "Indirizzo",
    "Agent installation INCOMPLETE - %@ of %@ did not go in:\n%@\n%@\nEvery missing agent is a function that has silently stopped working (vm-guard watches the machine's buffer, backup-health reports failures). Fix the cause and repeat the installation.":
      "Installazione degli agenti INCOMPLETA - %@ su %@ non sono stati installati:\n%@\n%@\nOgni agente mancante è una funzione che ha smesso di funzionare in silenzio (vm-guard controlla il buffer della macchina, backup-health segnala i guasti). Rimuovi la causa e ripeti l'installazione.",
    "All running":
      "Tutti in esecuzione",
    "Also install the launchd agents (same as install-launchd).":
      "Installa anche gli agenti launchd (come install-launchd).",
    "At most this many minutes of waiting for the upload.":
      "Al massimo questi minuti di attesa per l'invio.",
    "At the limit every new band fails with EMFILE and the backup stops. Check: cloudmachine-agent vm-status":
      "Al limite ogni nuova banda fallisce con EMFILE e il backup si ferma. Controlla: cloudmachine-agent vm-status",
    "Cache on the machine's disk":
      "Cache sul disco della macchina",
    "Connected to Google Drive, but could not create the folder '%@' - without it the machine has nowhere to keep the backup. Check the account permissions and try again.":
      "Collegato a Google Drive, ma non è stato possibile creare la cartella '%@' - senza di essa la macchina non ha dove conservare il backup. Controlla i permessi dell'account e riprova.",
    "Convert the image":
      "Converti l'immagine",
    "Converting the image to 32 MB bands":
      "Conversione dell'immagine in bande da 32 MB",
    "Could not check with the current connection whether the backup is on Google Drive (%@), so remote '%@' was NOT replaced: without that answer the new sign-in cannot be checked against it.":
      "Con la connessione attuale non è stato possibile verificare se il backup è su Google Drive (%@), quindi il remote '%@' NON è stato sostituito: senza questa risposta il nuovo accesso non può essere controllato.",
    "Downloads the official rclone binary into ~/.cloudmachine/bin (Google sign-in and the machine's rclone.conf).":
      "Scarica il binario ufficiale di rclone in ~/.cloudmachine/bin (accesso a Google e rclone.conf della macchina).",
    "Free in the machine":
      "Libero nella macchina",
    "Free in the machine: %@":
      "Libero nella macchina: %@",
    "Generates and installs the launchd agents (app, backup watchdog, machine start, machine guard).":
      "Genera e installa gli agenti launchd (app, controllo dei backup, avvio della macchina, guardia della macchina).",
    "Install Lima, which runs the CloudMachine machine: run this in Terminal":
      "Installa Lima, che esegue la macchina CloudMachine: esegui questo in Terminale",
    "Install rclone (signs in to Google Drive for the machine)":
      "Installa rclone (collega la macchina a Google Drive)",
    "Install the background agents (machine start, buffer guard, backup watchdog)":
      "Installa gli agenti in background (avvio della macchina, guardia del buffer, controllo dei backup)",
    "Installs rclone through Homebrew - CloudMachine itself uses the one from install-rclone.":
      "Installa rclone tramite Homebrew - CloudMachine stesso usa quello di install-rclone.",
    "Info.plist, token and mapped/ of the backup image exist only on the machine's disk; without them the bands in %@ cannot be restored. The copy (tm-meta-sync, every 15 min) goes to %@. Check: cloudmachine-agent vm-status, then in the machine: journalctl -u tm-meta-sync":
      "Info.plist, il token e mapped/ dell'immagine di backup esistono solo sul disco della macchina; senza di essi le bande in %@ non possono essere ripristinate. La copia (tm-meta-sync, ogni 15 min) va in %@. Controlla: cloudmachine-agent vm-status, poi nella macchina: journalctl -u tm-meta-sync",
    "Lima says the machine is running, but a command in it did not return. Without it nothing is known about Samba, rclone or the upload. Check: cloudmachine-agent vm-status":
      "Lima dice che la macchina è in esecuzione, ma un comando al suo interno non è tornato. Senza di esso non si sa nulla di Samba, rclone o dell'invio. Controlla: cloudmachine-agent vm-status",
    "Machine":
      "Macchina",
    "Machine %@":
      "Macchina %@",
    "Machine & Upload Status":
      "Stato della macchina e dell'invio",
    "Machine buffer":
      "Buffer della macchina",
    "No Time Machine destination is the machine's share (smb://tm@<address>/CloudMachine) - backups are not being made there. The command is printed by: cloudmachine-agent vm-setup":
      "Nessuna destinazione di Time Machine è la condivisione della macchina (smb://tm@<indirizzo>/CloudMachine) - lì non vengono fatti backup. Il comando viene stampato da: cloudmachine-agent vm-setup",
    "Not running: %@":
      "Non in esecuzione: %@",
    "Not set up":
      "Non configurata",
    "Once it runs out, rclone stops uploading, the machine's buffer fills up and backups stop being made. At a growth of ~600 MB per hourly cycle that is about %@ days.":
      "Quando lo spazio finisce, rclone smette di inviare, il buffer della macchina si riempie e i backup non vengono più fatti. Con una crescita di circa 600 MB per ciclo orario sono circa %@ giorni.",
    "Or rclone.conf is missing: this Mac has already set up the CloudMachine machine, so it is not connected anew blindly. Restore the file from a backup (the machine keeps its own copy in %@). To connect anyway, create an empty file at the path `%@ config file` prints and run again - the existing folder is kept.":
      "Oppure manca rclone.conf: questo Mac ha già configurato la macchina CloudMachine, quindi non viene ricollegato alla cieca. Ripristina il file da un backup (la macchina ne tiene una copia propria in %@). Per collegare comunque, crea un file vuoto nel percorso stampato da `%@ config file` ed esegui di nuovo - la cartella esistente viene mantenuta.",
    "Point Time Machine at the machine: run this in Terminal (needs sudo; Copy includes the password)":
      "Punta Time Machine alla macchina: esegui questo in Terminale (serve sudo; Copia include la password)",
    "Points to the machine":
      "Punta alla macchina",
    "Prepares for a restart: stops the backup, waits a while for the upload, then stops the machine cleanly.":
      "Prepara al riavvio: arresta il backup, attende un po' l'invio, poi arresta la macchina in modo pulito.",
    "Reading the Time Machine destination did not return within %@ s. That is how tmutil behaves when its destination hangs.":
      "La lettura della destinazione di Time Machine non è tornata entro %@ s. Così si comporta tmutil quando la sua destinazione si blocca.",
    "Remote '%@' was NOT replaced. The new sign-in gets the 'drive.file' scope, which sees only files created under its own client_id. The existing backup was most likely created by the current connection and would become invisible to it. Before anything is written, the new token is checked against the existing backup, and the replacement is abandoned if it cannot see it. The machine keeps its own copy of the configuration until vm-setup --replace-rclone-config. To go ahead, run again with --replace-existing --accept-scope-change.":
      "Il remote '%@' NON è stato sostituito. Il nuovo accesso riceve l'ambito 'drive.file', che vede solo i file creati con il proprio client_id. Il backup esistente è stato molto probabilmente creato dalla connessione attuale e diventerebbe invisibile. Prima di scrivere qualsiasi cosa, il nuovo token viene controllato rispetto al backup esistente, e la sostituzione viene annullata se non lo vede. La macchina conserva una propria copia della configurazione fino a vm-setup --replace-rclone-config. Per procedere, esegui di nuovo con --replace-existing --accept-scope-change.",
    "Remote control:   OPEN on the Mac at 127.0.0.1:5572 - any web page can send rclone commands; see vm/README.md (portForwards)":
      "Controllo remoto: APERTO sul Mac a 127.0.0.1:5572 - qualsiasi pagina web può inviare comandi a rclone; vedi vm/README.md (portForwards)",
    "Running":
      "In esecuzione",
    "Samba, rclone or punchfs in the machine is not active, so Time Machine has nowhere to write or the bands do not reach Google Drive. Check: cloudmachine-agent vm-status":
      "Samba, rclone o punchfs nella macchina non è attivo, quindi Time Machine non ha dove scrivere oppure le bande non arrivano su Google Drive. Controlla: cloudmachine-agent vm-status",
    "Service %@":
      "Servizio %@",
    "Services":
      "Servizi",
    "Set up the CloudMachine machine (the first time it downloads Ubuntu - several minutes)":
      "Configura la macchina CloudMachine (la prima volta scarica Ubuntu - alcuni minuti)",
    "Set up the CloudMachine machine again, so it prints the Time Machine command":
      "Configura di nuovo la macchina CloudMachine, così stampa il comando di Time Machine",
    "Set up the machine":
      "Configura la macchina",
    "Setting up the CloudMachine machine":
      "Configurazione della macchina CloudMachine",
    "Start the CloudMachine machine":
      "Avvia la macchina CloudMachine",
    "Start the machine":
      "Avvia la macchina",
    "Starting the CloudMachine machine":
      "Avvio della macchina CloudMachine",
    "Still to upload: %@ GiB":
      "Ancora da inviare: %@ GiB",
    "Stopping the Time Machine backup...":
      "Arresto del backup di Time Machine...",
    "Stopping the machine %@...":
      "Arresto della macchina %@...",
    "The CloudMachine machine does not answer":
      "La macchina CloudMachine non risponde",
    "The CloudMachine machine is not running":
      "La macchina CloudMachine non è in esecuzione",
    "The CloudMachine machine is not set up yet":
      "La macchina CloudMachine non è ancora configurata",
    "The CloudMachine machine is stopped":
      "La macchina CloudMachine è arrestata",
    "The backup is stopped, the upload gets up to 30 minutes, then the machine shuts down cleanly. It starts again at the next login.":
      "Il backup è arrestato, all'invio vengono concessi fino a 30 minuti, poi la macchina si arresta in modo pulito. Riparte al prossimo login.",
    "The machine %@ is not running - nothing to prepare.":
      "La macchina %@ non è in esecuzione - niente da preparare.",
    "The machine is stopped and everything reached Google Drive. The Mac can be restarted; the machine starts again at login.":
      "La macchina è arrestata e tutto è arrivato su Google Drive. Puoi riavviare il Mac; la macchina riparte al login.",
    "The machine is stopped. %@ GiB had not reached Google Drive yet - it is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "La macchina è arrestata. %@ GiB non erano ancora arrivati su Google Drive - sono conservati nel buffer della macchina e verranno inviati dopo il prossimo avvio. Puoi riavviare il Mac.",
    "The machine is stopped. rclone did not say how much was still to upload; what was not uploaded is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "La macchina è arrestata. rclone non ha detto quanto restava da inviare; ciò che non è stato inviato è conservato nel buffer della macchina e verrà inviato dopo il prossimo avvio. Puoi riavviare il Mac.",
    "The machine's disk is a file on this disk and grows as the upload buffer fills. With no space left the machine cannot write the buffer, and Time Machine's local snapshots have nowhere to go either.":
      "Il disco della macchina è un file su questo disco e cresce man mano che il buffer di invio si riempie. Senza spazio libero la macchina non può scrivere il buffer, e nemmeno gli snapshot locali di Time Machine hanno dove andare.",
    "The image's metadata has never been copied to Drive":
      "I metadati dell'immagine non sono mai stati copiati su Drive",
    "The image's metadata was last copied to Drive %@ ago":
      "I metadati dell'immagine sono stati copiati su Drive l'ultima volta %@ fa",
    "The machine's disk is running out of space (%@ GB)":
      "Il disco della macchina sta finendo lo spazio (%@ GB)",
    "The new sign-in does NOT see the existing backup (%@), so remote '%@' was NOT replaced and rclone.conf is unchanged. Keep the current connection, or sign in with the credential (client_id) that created the backup.":
      "Il nuovo accesso NON vede il backup esistente (%@), quindi il remote '%@' NON è stato sostituito e rclone.conf è invariato. Mantieni la connessione attuale, oppure accedi con la credenziale (client_id) che ha creato il backup.",
    "The upload buffer lives on this disk. The guard pauses Time Machine before it fills; if the upload does not catch up, backups stay paused.":
      "Il buffer di invio si trova su questo disco. La guardia mette in pausa Time Machine prima che si riempia; se l'invio non recupera, i backup restano in pausa.",
    "These bands exist only in the machine's buffer. The backup on Google Drive is INCOMPLETE and may not open.":
      "Queste bande esistono solo nel buffer della macchina. Il backup su Google Drive è INCOMPLETO e potrebbe non aprirsi.",
    "Time Machine backs up to the machine, so without it no backup is made. Start it: limactl start %@ (or the Start button in the app).":
      "Time Machine fa il backup sulla macchina, quindi senza di essa non viene fatto alcun backup. Avviala: limactl start %@ (o il pulsante Avvia nell'app).",
    "Time Machine did not stop its backup within 2 minutes (or tmutil did not answer) - the machine was NOT stopped. Try again in a moment.":
      "Time Machine non ha arrestato il backup entro 2 minuti (oppure tmutil non ha risposto) - la macchina NON è stata arrestata. Riprova tra poco.",
    "Time Machine has created its image: stop the backup, then convert the image to 32 MB bands":
      "Time Machine ha creato la sua immagine: arresta il backup, poi converti l'immagine in bande da 32 MB",
    "To upload":
      "Da inviare",
    "Unknown whether the CloudMachine machine is running":
      "Non si sa se la macchina CloudMachine sia in esecuzione",
    "Waiting for the upload to Google Drive (at most %@ min)...":
      "In attesa dell'invio a Google Drive (al massimo %@ min)...",
    "With --replace-existing: confirms that the new sign-in (scope 'drive.file') may not see the existing backup. The new token is still checked against the backup first.":
      "Con --replace-existing: conferma che il nuovo accesso (ambito 'drive.file') potrebbe non vedere il backup esistente. Il nuovo token viene comunque prima controllato rispetto al backup.",
    "Without it there is no way to check whether anything reached the Drive - the machine's guard is blind then.":
      "Senza di esso non c'è modo di verificare se qualcosa è arrivato su Drive - la guardia della macchina è allora cieca.",
    "limactl did not answer":
      "limactl non ha risposto",
    "limactl did not answer (or is not installed). That does not mean the machine is down - it means nobody has checked.":
      "limactl non ha risposto (o non è installato). Questo non significa che la macchina sia ferma - significa che nessuno ha controllato.",
    "limactl start failed: %@":
      "limactl start non è riuscito: %@",
    "limactl stop failed: %@":
      "limactl stop non è riuscito: %@",
    "punchfs is close to its open-file limit":
      "punchfs è vicino al limite di file aperti",
    "punchfs open files":
      "File aperti di punchfs",
    "rclone's remote control is open on this Mac":
      "Il controllo remoto di rclone è aperto su questo Mac",
    "statfs('/System/Volumes/Data') returned an error, so nobody knows whether the machine's disk can still grow on this Mac.":
      "statfs('/System/Volumes/Data') ha restituito un errore, quindi non si sa se il disco della macchina possa ancora crescere su questo Mac.",
    "Google Drive's daily upload limit stops the upload":
      "Il limite giornaliero di invio di Google Drive blocca l'invio",
    "Google last refused an upload %@ ago (750 GB a day). Backups since then are only in the machine's buffer on this Mac. rclone retries every 5 min and resumes by itself when the limit passes; the guard pauses Time Machine if more than %@ GiB waits.":
      "Google ha rifiutato un invio l'ultima volta %@ fa (750 GB al giorno). Da allora i backup sono solo nel buffer della macchina su questo Mac. rclone riprova ogni 5 min e riprende da solo quando il limite passa; la guardia mette in pausa Time Machine se in attesa ci sono più di %@ GiB.",
    "Usage on Google Drive is not being measured":
      "L'utilizzo di Google Drive non viene misurato",
    "The last measurement (%@ GB) is from %@, %@ ago - rclone size has not answered since. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "L'ultima misurazione (%@ GB) è del %@, %@ fa - da allora rclone size non ha risposto. Finché non risponde, nulla controlla il limite di %@ GB: gli avvisi al 90%% e al 100%% restano muti. Controlla vm-status, oppure premi Misura ora nella finestra.",
    "rclone size has not answered even once. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "rclone size non ha risposto nemmeno una volta. Finché non risponde, nulla controlla il limite di %@ GB: gli avvisi al 90%% e al 100%% restano muti. Controlla vm-status, oppure premi Misura ora nella finestra.",
    "Saved in the Keychain. Connecting Google Drive (configure-remote) will use them.":
      "Salvato nel Portachiavi. Il collegamento a Google Drive (configure-remote) le userà.",
    "Saved in the Keychain. The existing Google Drive connection keeps its old client_id, and on this Mac it should stay that way: a connection made with the new keys (the 'drive.file' scope) cannot see the backup created by the old one. Do not replace the connection here; the new keys are for a Mac that is not connected yet.":
      "Salvato nel Portachiavi. Il collegamento esistente a Google Drive mantiene il vecchio client_id, e su questo Mac conviene che resti così: un collegamento fatto con le nuove chiavi (ambito 'drive.file') non può vedere il backup creato dal vecchio. Non sostituire qui il collegamento; le nuove chiavi servono per un Mac non ancora collegato.",
    "it is not there for the new token":
      "non c'è per il nuovo token",
    "Cancel":
      "Annulla",
    "ACTION NEEDED":
      "AZIONE RICHIESTA",
    "WILL PASS BY ITSELF — DO NOTHING":
      "SI RISOLVERÀ DA SOLO — NON FARE NULLA",
    "UNKNOWN — CHECK AGAIN SHORTLY":
      "NON SI SA — CONTROLLA DI NUOVO TRA POCO",
    "ALL GOOD":
      "TUTTO OK",
    "Upload is not working":
      "L'invio non funziona",
    "Upload stopped — no space left on Google Drive":
      "Invio interrotto — spazio esaurito su Google Drive",
    "%@ backup fragments not uploaded":
      "%@ frammenti di backup non inviati",
    "Upload cannot keep up with writes":
      "L'invio non sta al passo con le scritture",
    "Upload paused — Google daily limit":
      "Invio in pausa — limite giornaliero di Google",
    "Uploading to Google Drive — %@ queued":
      "Invio a Google Drive — %@ in coda",
    "Everything uploaded to Google Drive":
      "Tutto inviato a Google Drive",
    "Unknown what is waiting in the queue":
      "Non si sa cosa c'è in attesa nella coda",
    "There is no connection to Google Drive, so backups are only made on this Mac. If this does not pass by itself within a few minutes, check the network and the connection to Drive.":
      "Non c'è connessione a Google Drive, quindi i backup vengono fatti solo su questo Mac. Se non passa da solo entro pochi minuti, controlla la rete e il collegamento a Drive.",
    "There is no space left on Google Drive. This will NOT pass by itself — you need to free up space on Drive. Until then Time Machine is paused, so that it does not fill up this Mac's disk.":
      "Su Google Drive non c'è più spazio. Questo NON passerà da solo — devi liberare spazio su Drive. Fino ad allora Time Machine è in pausa, per non riempire il disco di questo Mac.",
    "%@ backup fragments could not be uploaded and rclone stopped trying. These fragments exist only on this Mac, so the backup on Drive is incomplete. This needs checking.":
      "%@ frammenti di backup non hanno potuto essere inviati e rclone ha smesso di provare. Questi frammenti esistono solo su questo Mac, quindi il backup su Drive è incompleto. Serve un controllo.",
    "Time Machine is writing faster than the upload goes, and the buffer has filled up. The backup will be paused until the upload catches up — this is a safeguard against filling up the disk, not a failure.":
      "Time Machine scrive più velocemente di quanto proceda l'invio, e il buffer si è riempito. Il backup resterà in pausa finché l'invio non recupera — è una protezione contro il riempimento del disco, non un guasto.",
    "Google accepts 750 GB per day and that limit has been used up. There is nothing to do: the limit renews by itself, usually within a few hours. Time Machine backups are made normally in the meantime and wait in the buffer — they will be uploaded as soon as Google starts accepting again.":
      "Google accetta 750 GB al giorno e questo limite è stato esaurito. Non c'è nulla da fare: il limite si rinnova da solo, di solito entro poche ore. Nel frattempo i backup di Time Machine vengono fatti normalmente e restano in attesa nel buffer — verranno inviati appena Google tornerà ad accettare.",
    "%@ backup fragments are queued and on their way to Drive.":
      "%@ frammenti di backup sono in coda e in viaggio verso Drive.",
    "Nothing is waiting in the queue — the backup on Google Drive is complete.":
      "Niente è in attesa nella coda — il backup su Google Drive è completo.",
    "rclone did not answer the question about the queue, so it is unknown how many backups are still waiting to be uploaded. This does not mean something broke — under load the answer can be late. It only means that right now nobody knows. If it persists, the backup cycle check will report it.":
      "rclone non ha risposto alla domanda sulla coda, quindi non si sa quanti backup siano ancora in attesa di invio. Questo non significa che qualcosa si sia rotto — sotto carico la risposta può arrivare in ritardo. Significa solo che al momento nessuno lo sa. Se persiste, il controllo del ciclo di backup lo segnalerà.",
    "unknown error":
      "errore sconosciuto",
    "rclone lsf ended with an error":
      "rclone lsf è terminato con un errore",
    "This Mac is close to its space limit on Google Drive":
      "Questo Mac è vicino al suo limite di spazio su Google Drive",
    "%@ GB of %@ GB used. Time Machine deletes the oldest backups to stay within its quota; check that the quota is set (vm-status).":
      "%@ GB usati su %@ GB. Time Machine elimina i backup più vecchi per restare entro la quota; controlla che la quota sia impostata (vm-status).",
    "This Mac is over its space limit on Google Drive":
      "Questo Mac ha superato il suo limite di spazio su Google Drive",
    "%@ GB of %@ GB used. Set the Time Machine quota (command in the app window or vm-status), or raise the limit.":
      "%@ GB usati su %@ GB. Imposta la quota di Time Machine (comando nella finestra dell'app o in vm-status), oppure alza il limite.",
    "not set":
      "non impostato",
    "%@ GB - usage not measured yet":
      "%@ GB - utilizzo non ancora misurato",
    "%@ of %@ GB used (%@%%)":
      "%@ di %@ GB usati (%@%%)",
    "The limit must be a whole number of GB above zero.":
      "Il limite deve essere un numero intero di GB maggiore di zero.",
    "machines.json cannot be read, so it was not overwritten. Fix or remove it first.":
      "machines.json non si può leggere, quindi non è stato sovrascritto. Correggilo o rimuovilo prima.",
    "'%@' is not a valid folder name: use lowercase letters, digits and dashes.":
      "'%@' non è un nome di cartella valido: usa lettere minuscole, cifre e trattini.",
    "This Mac already backs up to folder '%@'. Switching to '%@' would start a new, empty backup and orphan the existing one, so nothing was changed.":
      "Questo Mac fa già il backup nella cartella '%@'. Passare a '%@' avvierebbe un nuovo backup vuoto e lascerebbe orfano quello esistente, quindi non è stato cambiato nulla.",
    "This Mac already has a CloudMachine installation, whose backup is in folder '%@'. Switching to '%@' would orphan it, so nothing was changed.":
      "Questo Mac ha già un'installazione di CloudMachine, il cui backup è nella cartella '%@'. Passare a '%@' la lascerebbe orfana, quindi non è stato cambiato nulla.",
    "Could not save the folder name to %@: %@":
      "Impossibile salvare il nome della cartella in %@: %@",
    "Homebrew is not installed. Install it manually: https://brew.sh":
      "Homebrew non è installato. Installalo manualmente: https://brew.sh",
    "Installing rclone failed: %@":
      "Installazione di rclone non riuscita: %@",
    "Installed rclone.":
      "rclone installato.",
    "Own Google credentials: set.":
      "Credenziali Google personali: impostate.",
    "INCOMPLETE: %@ is missing - rclone will use rclone's shared client_id anyway.":
      "INCOMPLETO: %@ manca - rclone userà comunque il client_id condiviso di rclone.",
    "No own credentials - rclone uses the shared client_id, rate-limited jointly and being retired in 2026.":
      "Nessuna credenziale personale - rclone usa il client_id condiviso, soggetto a un limite di frequenza comune e in dismissione nel 2026.",
    "Empty value - not saving.":
      "Valore vuoto - non salvato.",
    "Keychain refused: %@":
      "Portachiavi ha rifiutato: %@",
    "DIRTY-TREE":
      "ALBERO-MODIFICATO",
    "Cannot create the working directory: %@":
      "Impossibile creare la cartella di lavoro: %@",
    "Could not read the rclone version number.":
      "Impossibile leggere il numero di versione di rclone.",
    "Could not download %@.":
      "Impossibile scaricare %@.",
    "No entry for %@ in SHA256SUMS.":
      "Nessuna voce per %@ in SHA256SUMS.",
    "Could not compute the checksum.":
      "Impossibile calcolare il checksum.",
    "SHA256 checksum does not match - NOT installing.\n  expected: %@\n  computed: %@":
      "Il checksum SHA256 non corrisponde - installazione ANNULLATA.\n  atteso:    %@\n  calcolato: %@",
    "Could not unpack the archive.":
      "Impossibile decomprimere l'archivio.",
    "Could not install the binary: %@":
      "Impossibile installare il binario: %@",
    "Installed rclone %@ in %@ (SHA256 checksum matches).":
      "rclone %@ installato in %@ (il checksum SHA256 corrisponde).",
    "%@ did not respond within the allotted time (the process was left orphaned in the background).":
      "%@ non ha risposto nel tempo concesso (il processo è stato lasciato orfano in background).",
    "Cannot launch %@: %@":
      "Impossibile avviare %@: %@",
    "Remote '%@' already exists and was NOT touched.\nOverwriting it replaces the token and the permission scope; a credential with the 'drive.file' scope does not see files created by the previous one, so the existing backup becomes unreachable.\nIf you really want to replace it, first back up ~/.config/rclone/rclone.conf and run again with --replace-existing.":
      "Il remote '%@' esiste già e NON è stato toccato.\nSovrascriverlo sostituisce il token e l'ambito dei permessi; una credenziale con l'ambito 'drive.file' non vede i file creati da quella precedente, quindi il backup esistente diventerebbe irraggiungibile.\nSe vuoi davvero sostituirlo, fai prima un backup di ~/.config/rclone/rclone.conf ed esegui di nuovo con --replace-existing.",
    "Could not check whether remote '%@' already exists (rclone listremotes did not answer or failed), so nothing was changed. Run `%@ listremotes` to see the error, then try again.":
      "Impossibile verificare se il remote '%@' esiste già (rclone listremotes non ha risposto o è fallito), quindi non è stato cambiato nulla. Esegui `%@ listremotes` per vedere l'errore, poi riprova.",
    "Could not check whether this Mac already has a CloudMachine installation (rclone did not answer), so no folder was chosen. Try again in a moment.":
      "Impossibile verificare se questo Mac ha già un'installazione di CloudMachine (rclone non ha risposto), quindi non è stata scelta alcuna cartella. Riprova tra poco.",
    "rclone authorize failed (%@). If that binary is missing, start with: cloudmachine-agent install-rclone.":
      "rclone authorize non è riuscito (%@). Se manca quel binario, comincia con: cloudmachine-agent install-rclone.",
    "Could not read the token from the output of rclone authorize.":
      "Impossibile leggere il token dall'output di rclone authorize.",
    "rclone config create failed.":
      "rclone config create non è riuscito.",
    "Connected to Google Drive as remote '%@', folder %@.":
      "Collegato a Google Drive come remote '%@', cartella %@.",
    "tmutil is not responding - unknown where the backup goes":
      "tmutil non risponde - non si sa dove vada il backup",
    "No successful backup for %@":
      "Nessun backup riuscito da %@",
    "Last COMPLETED backup: %@. The cycle is hourly, so that is %@ missed runs.":
      "Ultimo backup COMPLETATO: %@. Il ciclo è orario, quindi sono %@ esecuzioni saltate.",
    "There is NOT A SINGLE successful backup":
      "Non c'è NEMMENO UN backup riuscito",
    "The Time Machine preferences contain no date of a completed backup for this destination.":
      "Le preferenze di Time Machine non contengono alcuna data di un backup completato per questa destinazione.",
    "The last backup attempt did not end in a backup":
      "L'ultimo tentativo di backup non è sfociato in un backup",
    "The attempt at %@ is newer than the last successful backup at %@.":
      "Il tentativo del %@ è più recente dell'ultimo backup riuscito del %@.",
    "Time Machine reports an error in the last run (RESULT=%@)":
      "Time Machine segnala un errore nell'ultima esecuzione (RESULT=%@)",
    "A non-zero RESULT in the Time Machine preferences means the run did not succeed.":
      "Un RESULT diverso da zero nelle preferenze di Time Machine significa che l'esecuzione non è riuscita.",
    "rclone failed to upload %@ files":
      "rclone non è riuscito a inviare %@ file",
    "Buffer full of nothing but unsent data":
      "Buffer pieno di soli dati non inviati",
    "rclone has nothing left to evict from the buffer - the upload cannot keep up or has stalled.":
      "rclone non ha più nulla da rimuovere dal buffer - l'invio non sta al passo o si è fermato.",
    "The rclone control interface is not responding":
      "L'interfaccia di controllo di rclone non risponde",
    "Google Drive is running out of space (%@ GB)":
      "Google Drive sta finendo lo spazio (%@ GB)",
    "The Mac's disk is running out of space (%@ GB)":
      "Il disco del Mac sta finendo lo spazio (%@ GB)",
    "Cannot read the Time Machine preferences":
      "Impossibile leggere le preferenze di Time Machine",
    "%@ is unreadable - most often Full Disk Access is missing. Without this file it is UNKNOWN when the last backup was made, so we treat it as a failure, not as the absence of a problem.":
      "%@ non è leggibile - più spesso manca l'Accesso completo al disco. Senza questo file NON SI SA quando è stato fatto l'ultimo backup, quindi lo trattiamo come un guasto, non come l'assenza di un problema.",
    "Cannot measure free space on the Mac's disk":
      "Impossibile misurare lo spazio libero sul disco del Mac",
    "%@ days":
      "%@ giorni",
    "CloudMachine: backup is not working":
      "CloudMachine: il backup non funziona",
    "unknown reason":
      "motivo sconosciuto",
    "osascript did not show the notification (permissions or no graphical session)":
      "osascript non ha mostrato la notifica (permessi o nessuna sessione grafica)",
    "UNDELIVERED ALARM: %@":
      "AVVISO NON CONSEGNATO: %@",
    "from %@, reason: %@":
      "da %@, motivo: %@",
    "The system notification was not delivered - you will see this alarm ONLY here.":
      "La notifica di sistema non è stata consegnata - vedrai questo avviso SOLO qui.",
    "%@ (%@ ago)":
      "%@ (%@ fa)",
    "%@ - marker from the FUTURE":
      "%@ - indicatore dal FUTURO",
    "%@ (%@ ago) - THE WATCHDOG MAY NOT BE RUNNING":
      "%@ (%@ fa) - IL CONTROLLO POTREBBE NON ESSERE IN ESECUZIONE",
    "NEVER - the watchdog has not recorded a single run":
      "MAI - il controllo non ha registrato alcuna esecuzione",
    "Could not find the launchd/ directory with templates.":
      "Impossibile trovare la cartella launchd/ con i modelli.",
    "Could not find the compiled cloudmachine-agent binary.":
      "Impossibile trovare il binario cloudmachine-agent compilato.",
    "ABORTED: could not put cloudmachine-agent in a stable location\n(%@) - most often a lack of space or permissions.\nNOT installing agents pointing at %@: that path\ndisappears on the next `swift build` or `git clean`, and backups stop\nwithout any visible signal.":
      "ANNULLATO: impossibile mettere cloudmachine-agent in una posizione stabile\n(%@) - più spesso per mancanza di spazio o di permessi.\nNON installo agenti che puntano a %@: quel percorso\nscompare al prossimo `swift build` o `git clean`, e i backup si fermano\nsenza alcun segnale visibile.",
    "ABORTED: %@":
      "ANNULLATO: %@",
    "Could not list the templates in %@.":
      "Impossibile elencare i modelli in %@.",
    "could not read the template %@":
      "impossibile leggere il modello %@",
    "could not write %@ (lack of space or permissions)":
      "impossibile scrivere %@ (mancanza di spazio o di permessi)",
    "launchctl load refused to load %@":
      "launchctl load ha rifiutato di caricare %@",
    "NOT A SINGLE agent was loaded.":
      "NESSUN agente è stato caricato.",
    "Only these went in: %@.":
      "Sono stati installati solo: %@.",
    "Could not load any launchd agent.":
      "Impossibile caricare alcun agente launchd.",
    "Installed agents: %@":
      "Agenti installati: %@",
    "                  WARNING: close to the limit - new bands will fail with EMFILE":
      "                  ATTENZIONE: vicino al limite - le nuove bande falliranno con EMFILE",
    "%@/bands on Google Drive is not empty - it may hold another backup. NOT overwriting it; check it by hand.":
      "%@/bands su Google Drive non è vuoto - potrebbe contenere un altro backup. NON lo sovrascrivo; controllalo a mano.",
    "Address:          %@":
      "Indirizzo:        %@",
    "Already prepared (%@ exists) - nothing to do.":
      "Già preparato (%@ esiste) - niente da fare.",
    "Converts Time Machine's new, empty image in the machine to 32 MB bands and moves the bands to Google Drive.":
      "Converte la nuova immagine vuota di Time Machine nella macchina in bande da 32 MB e sposta le bande su Google Drive.",
    "Copy rclone.conf into the machine even if it already has one.":
      "Copia rclone.conf nella macchina anche se ne ha già uno.",
    "Copying the converted image into the machine failed: %@":
      "La copia dell'immagine convertita nella macchina non è riuscita: %@",
    "Copying the image to the Mac failed: %@":
      "La copia dell'immagine sul Mac non è riuscita: %@",
    "Could not ask Lima about the machine: %@":
      "Impossibile interrogare Lima sulla macchina: %@",
    "Could not carry the Time Machine files over: %@":
      "Impossibile trasferire i file di Time Machine: %@",
    "Could not check the image in the machine.":
      "Impossibile controllare l'immagine nella macchina.",
    "Could not copy the rclone configuration into the machine.":
      "Impossibile copiare la configurazione di rclone nella macchina.",
    "Could not create %@ on Google Drive: %@":
      "Impossibile creare %@ su Google Drive: %@",
    "Could not create %@: %@":
      "Impossibile creare %@: %@",
    "Could not find the vm/ directory with the machine template.":
      "Impossibile trovare la cartella vm/ con il modello della macchina.",
    "Could not read the image size.":
      "Impossibile leggere la dimensione dell'immagine.",
    "Could not set the SMB password of user %@ in the machine.":
      "Impossibile impostare la password SMB dell'utente %@ nella macchina.",
    "Could not stop smbd in the machine.":
      "Impossibile arrestare smbd nella macchina.",
    "Could not write %@ in the machine.":
      "Impossibile scrivere %@ nella macchina.",
    "Could not write the password file %@.":
      "Impossibile scrivere il file della password %@.",
    "Creates or starts the CloudMachine machine (Lima), gives it rclone's configuration and an SMB password, and prints the Time Machine command.":
      "Crea o avvia la macchina CloudMachine (Lima), le dà la configurazione di rclone e una password SMB, e stampa il comando di Time Machine.",
    "Creating the machine %@ (first start downloads Ubuntu and installs packages - several minutes)...":
      "Creazione della macchina %@ (il primo avvio scarica Ubuntu e installa pacchetti - alcuni minuti)...",
    "Done: %@ has %@ MB bands on Google Drive; the original is kept in %@ in the machine. Start the backup: tmutil startbackup":
      "Fatto: %@ ha bande da %@ MB su Google Drive; l'originale è conservato in %@ nella macchina. Avvia il backup: tmutil startbackup",
    "exit code %@, no message":
      "codice di uscita %@, nessun messaggio",
    "Image metadata:   NEVER copied to %@ - check tm-meta-sync in the machine":
      "Metadati immagine: MAI copiati in %@ - controlla tm-meta-sync nella macchina",
    "Image metadata:   copied %@ ago to %@":
      "Metadati immagine: copiati %@ fa in %@",
    "Image metadata:   last copied %@ ago - OVERDUE (%@)":
      "Metadati immagine: ultima copia %@ fa - IN RITARDO (%@)",
    "Image metadata:   not copied yet - waits for vm-prepare-bundle":
      "Metadati immagine: non ancora copiati - attende vm-prepare-bundle",
    "Backup %@, paused by the guard %@: %@":
      "Backup %@, messo in pausa dalla guardia %@: %@",
    "Free in machine:  %@ GiB":
      "Libero nella macchina: %@ GiB",
    "fsck_apfs -n found problems: %@":
      "fsck_apfs -n ha trovato problemi: %@",
    "Google Drive folder: %@":
      "Cartella su Google Drive: %@",
    "hdiutil attach of the converted image failed: %@":
      "hdiutil attach dell'immagine convertita non è riuscito: %@",
    "hdiutil convert failed: %@":
      "hdiutil convert non è riuscito: %@",
    "Image name in the machine (default: from the computer name).":
      "Nome dell'immagine nella macchina (predefinito: ricavato dal nome del computer).",
    "Installing the converted image FAILED: %@\nsmbd is left STOPPED so Time Machine does not open a half-installed image. The original is in %@ in the machine.":
      "L'installazione dell'immagine convertita NON è RIUSCITA: %@\nsmbd resta ARRESTATO perché Time Machine non apra un'immagine installata a metà. L'originale è in %@ nella macchina.",
    "limactl create failed: %@":
      "limactl create non è riuscito: %@",
    "limactl list failed: %@":
      "limactl list non è riuscito: %@",
    "limactl not found - install Lima: brew install lima":
      "limactl non trovato - installa Lima: brew install lima",
    "limactl start failed: %@\nThe machine's own log: %@":
      "limactl start non è riuscito: %@\nIl registro della macchina stessa: %@",
    "Machine %@ is running.":
      "La macchina %@ è in esecuzione.",
    "Machine %@ was already running.":
      "La macchina %@ era già in esecuzione.",
    "Machine:          %@ (%@)":
      "Macchina:         %@ (%@)",
    "Machine:          %@":
      "Macchina:         %@",
    "Machine:          not created - run: cloudmachine-agent vm-setup":
      "Macchina:         non creata - esegui: cloudmachine-agent vm-setup",
    "no answer within the time limit":
      "nessuna risposta entro il limite di tempo",
    "No image %@ in the machine.":
      "Nessuna immagine %@ nella macchina.",
    "No image in the machine yet - point Time Machine at the share and let it create one first.":
      "Ancora nessuna immagine nella macchina - prima punta Time Machine alla condivisione e lascia che ne crei una.",
    "No rclone configuration at %@ - connect Google Drive first (configure-remote).":
      "Nessuna configurazione di rclone in %@ - collega prima Google Drive (configure-remote).",
    "no SMB destination":
      "nessuna destinazione SMB",
    "One check of the machine's upload buffer: pauses Time Machine when it fills, resumes what it paused.":
      "Un controllo del buffer di invio della macchina: mette in pausa Time Machine quando si riempie, riprende ciò che ha messo in pausa.",
    "Packing the converted image failed: %@":
      "Il confezionamento dell'immagine convertita non è riuscito: %@",
    "Packing the image failed: %@":
      "Il confezionamento dell'immagine non è riuscito: %@",
    "No answer from the machine (rclone rc) - the guard would do nothing.":
      "Nessuna risposta dalla macchina (rclone rc) - la guardia non farebbe nulla.",
    "Only print what the guard would decide - for trying thresholds on a throwaway machine.":
      "Stampa solo ciò che la guardia deciderebbe - per provare le soglie su una macchina usa e getta.",
    "Pause above this many GiB in the buffer.":
      "Metti in pausa sopra questi GiB nel buffer.",
    "Pause when the machine has less free than this, in GiB.":
      "Metti in pausa quando alla macchina restano meno di questi GiB liberi.",
    "Point Time Machine at the machine (once, needs an administrator password):":
      "Punta Time Machine alla macchina (una volta, serve la password di un amministratore):",
    "punchfs files:    %@ open, limit %@":
      "File punchfs:     %@ aperti, limite %@",
    "rclone configuration already in the machine - kept (--replace-rclone-config replaces it).":
      "La configurazione di rclone è già nella macchina - mantenuta (--replace-rclone-config la sostituisce).",
    "rclone configuration copied into the machine.":
      "Configurazione di rclone copiata nella macchina.",
    "rclone-tm or punchfs is not running in the machine - see cloudmachine-agent vm-status.":
      "rclone-tm o punchfs non è in esecuzione nella macchina - vedi cloudmachine-agent vm-status.",
    "Resume below this many GiB (only a backup the guard paused).":
      "Riprendi sotto questi GiB (solo un backup messo in pausa dalla guardia).",
    "Service %@: %@":
      "Servizio %@: %@",
    "Several images in the machine (%@) - choose one with --bundle.":
      "Più immagini nella macchina (%@) - scegline una con --bundle.",
    "Shows the machine: address, services, upload buffer, free space and the Time Machine destination.":
      "Mostra la macchina: indirizzo, servizi, buffer di invio, spazio libero e destinazione di Time Machine.",
    "SMB password stored in %@ (mode 600).":
      "Password SMB salvata in %@ (modo 600).",
    "The converted image does not have %@-byte bands.":
      "L'immagine convertita non ha bande da %@ byte.",
    "The converted image has no APFS partition.":
      "L'immagine convertita non ha una partizione APFS.",
    "The image already takes %@ MB - this command converts only a new, empty image (under %@ MB).":
      "L'immagine occupa già %@ MB - questo comando converte solo un'immagine nuova e vuota (sotto %@ MB).",
    "The image is encrypted - converting encrypted images is not supported.":
      "L'immagine è cifrata - la conversione di immagini cifrate non è supportata.",
    "The image was not changed; smbd started again.":
      "L'immagine non è stata modificata; smbd è ripartito.",
    "The machine does not answer - is it running? cloudmachine-agent vm-status":
      "La macchina non risponde - è in esecuzione? cloudmachine-agent vm-status",
    "The machine has no address on the vzNAT network.":
      "La macchina non ha un indirizzo nella rete vzNAT.",
    "The services in the machine did not start - check: cloudmachine-agent vm-status":
      "I servizi nella macchina non si sono avviati - controlla: cloudmachine-agent vm-status",
    "Time Machine is backing up - stop it first: tmutil stopbackup":
      "Time Machine sta facendo un backup - fermalo prima: tmutil stopbackup",
    "Time Machine:     %@":
      "Time Machine:     %@",
    "Time Machine:     NOT pointing at the machine (%@)":
      "Time Machine:     NON punta alla macchina (%@)",
    "Time Machine:     tmutil did not answer":
      "Time Machine:     tmutil non ha risposto",
    "tmutil did not answer - not touching the image while its state is unknown.":
      "tmutil non ha risposto - non tocco l'immagine finché il suo stato è sconosciuto.",
    "unknown":
      "sconosciuto",
    "Unpacking the image failed: %@":
      "La decompressione dell'immagine non è riuscita: %@",
    "Still to upload:  %@ GiB in %@ bands, uploading %@ (cache on disk %@ GiB)":
      "Ancora da inviare: %@ GiB in %@ bande, in invio %@ (cache su disco %@ GiB)",
    "Excluded %@ (the machine and its upload buffer) from Time Machine.":
      "Escluso %@ (la macchina e il suo buffer di invio) da Time Machine.",
    "WARNING: could not exclude %@ from Time Machine - run: tmutil addexclusion %@":
      "ATTENZIONE: impossibile escludere %@ da Time Machine - esegui: tmutil addexclusion %@",
    "Upload buffer:    no answer from rclone (rc %@)":
      "Buffer di invio:  nessuna risposta da rclone (rc %@)",
    "When Time Machine has created its empty image, stop the backup (tmutil stopbackup) and run: cloudmachine-agent vm-prepare-bundle":
      "Quando Time Machine ha creato la sua immagine vuota, arresta il backup (tmutil stopbackup) ed esegui: cloudmachine-agent vm-prepare-bundle",
    "Unsent %@ GiB, free %@ GiB (pause above %@ GiB unsent or below %@ GiB free, resume below %@ GiB).":
      "Non inviati %@ GiB, liberi %@ GiB (pausa sopra %@ GiB non inviati o sotto %@ GiB liberi, ripresa sotto %@ GiB).",
    "Upload:           Google's daily limit refused an upload %@ ago - rclone retries every 5 min and resumes by itself":
      "Invio:            il limite giornaliero di Google ha rifiutato un invio %@ fa - rclone riprova ogni 5 min e riprende da solo",
    "no":
      "no",
    "running":
      "in esecuzione",
    "stopped":
      "arrestato",
    "yes":
      "sì",
    "%@\nThe previous template is in %@ - copy it back over lima.yaml and run limactl start %@.":
      "%@\nIl modello precedente è in %@ - ricopialo su lima.yaml ed esegui limactl start %@.",
    "Could not read this app's machine template (limactl template copy).":
      "Impossibile leggere il modello di macchina di questa app (limactl template copy).",
    "Could not replace %@: %@":
      "Impossibile sostituire %@: %@",
    "Machine %@ already runs this app's template.":
      "La macchina %@ usa già il modello di questa app.",
    "Machine %@ now runs this app's template; the previous one is in %@.":
      "La macchina %@ ora usa il modello di questa app; quello precedente è in %@.",
    "Moves the machine onto this app's template (two restarts, never during a backup).":
      "Porta la macchina sul modello di questa app (due riavvii, mai durante un backup).",
    "No machine %@ - create it with: cloudmachine-agent vm-setup":
      "Nessuna macchina %@ - creala con: cloudmachine-agent vm-setup",
    "Template:         OLDER than this app's - run: cloudmachine-agent vm-update":
      "Modello:          PIÙ VECCHIO di quello di questa app - esegui: cloudmachine-agent vm-update",
    "Template:         not compared":
      "Modello:          non confrontato",
    "Template:         this app's":
      "Modello:          quello di questa app",
    "The machine has no %@ - run cloudmachine-agent vm-setup first.":
      "La macchina non ha %@ - esegui prima cloudmachine-agent vm-setup.",
    "The machine restarted, but not every service is running - check: cloudmachine-agent vm-status. The previous template is in %@.":
      "La macchina è ripartita, ma non tutti i servizi sono in esecuzione - controlla: cloudmachine-agent vm-status. Il modello precedente è in %@.",
    "The template changes the machine itself (%@) - that needs a new machine, not an update.":
      "Il modello modifica la macchina stessa (%@) - serve una macchina nuova, non un aggiornamento.",
    "The upload to Google Drive hangs":
      "L'invio a Google Drive è bloccato",
    "Time Machine is backing up - try again when it has finished.":
      "Time Machine sta facendo un backup - riprova quando ha finito.",
    "Upload:           HANGS - bands in progress, none uploaded for %@ (network?); see /var/log/rclone-tm.log in the machine":
      "Invio:            BLOCCATO - bande in corso, nessuna inviata da %@ (rete?); vedi /var/log/rclone-tm.log nella macchina",
    "limactl stop failed - nothing was changed.":
      "limactl stop non è riuscito - nulla è stato modificato.",
    "rclone has bands in progress, but none has been uploaded for %@ - usually a broken network connection, which rclone does not report as an error. Backups since then are only in the machine's buffer. When the network comes back the upload resumes by itself (on 28.10.2026 within 80 s); if it does not, restarting the machine (prepare-shutdown, limactl start) drops the dead connections.":
      "rclone ha bande in corso, ma nessuna è stata inviata da %@ - di solito una connessione di rete interrotta, che rclone non segnala come errore. I backup da allora sono solo nel buffer della macchina. Quando la rete torna, l'invio riprende da solo (il 28.10.2026 entro 80 s); se non succede, riavviare la macchina (prepare-shutdown, limactl start) chiude le connessioni morte.",
    "tmutil did not answer - not restarting the machine while its state is unknown.":
      "tmutil non ha risposto - non riavvio la macchina finché il suo stato è sconosciuto.",
    "The machine's share cannot be read":
      "Impossibile leggere la condivisione della macchina",
    "Unknown whether the machine's share can be read":
      "Non si sa se la condivisione della macchina sia leggibile",
    "Samba in the machine does not answer this Mac":
      "Samba nella macchina non risponde a questo Mac",
    "Unknown whether Samba in the machine answers this Mac":
      "Non si sa se Samba nella macchina risponda a questo Mac",
    "Reading 1 byte of %@ in the machine failed: %@. Every service says it is active, yet Time Machine cannot use the image there. Nothing restarts it by itself. Check: cloudmachine-agent vm-status, then in the machine: journalctl -u punchfs -u tm-bands-bind -u rclone-tm":
      "La lettura di 1 byte di %@ nella macchina non è riuscita: %@. Ogni servizio risulta attivo, eppure Time Machine non può usare l'immagine lì. Nulla lo riavvia da solo. Controlla: cloudmachine-agent vm-status, poi nella macchina: journalctl -u punchfs -u tm-bands-bind -u rclone-tm",
    "Reading 1 byte of %@ in the machine has not returned for %@ s. That is how a hung punchfs or rclone mount behaves. Nothing is restarted while the state is unknown - a restart under a write still going could lose it. Check in the machine: journalctl -u punchfs -u rclone-tm":
      "La lettura di 1 byte di %@ nella macchina non è tornata da %@ s. Così si comporta un mount punchfs o rclone bloccato. Finché lo stato è sconosciuto non si riavvia nulla: un riavvio durante una scrittura in corso potrebbe perderla. Controlla nella macchina: journalctl -u punchfs -u rclone-tm",
    "An SMB connection to %@ got no answer within %@ s. Time Machine reaches the machine at this address. Check the machine's network and smbd: cloudmachine-agent vm-status":
      "Una connessione SMB a %@ non ha ricevuto risposta entro %@ s. Time Machine raggiunge la macchina a questo indirizzo. Controlla la rete della macchina e smbd: cloudmachine-agent vm-status",
    "The machine did not report its address, so nobody could try an SMB connection. Check: cloudmachine-agent vm-status":
      "La macchina non ha comunicato il suo indirizzo, quindi nessuno ha potuto tentare una connessione SMB. Controlla: cloudmachine-agent vm-status",
    "An SMB connection to %@ failed (%@). Time Machine reaches the machine at this address, so no backup is made. Check the machine's network and smbd: cloudmachine-agent vm-status":
      "Una connessione SMB a %@ non è riuscita (%@). Time Machine raggiunge la macchina a questo indirizzo, quindi non viene fatto alcun backup. Controlla la rete della macchina e smbd: cloudmachine-agent vm-status",
    "readable":
      "leggibile",
    "no image yet":
      "ancora nessuna immagine",
    "answers":
      "risponde",
    "Share read:       %@":
      "Lettura condiv.:  %@",
    "Samba from Mac:   %@":
      "Samba dal Mac:    %@",
    "This Mac found no route to %@ (%@). Either the route to the machine is gone, or macOS Local Network privacy has not allowed CloudMachine - then allow it in System Settings > Privacy & Security > Local Network. Check: cloudmachine-agent vm-status":
      "Questo Mac non ha trovato alcun percorso verso %@ (%@). O il percorso verso la macchina non c'è più, oppure la privacy «Rete locale» di macOS non ha consentito CloudMachine: in tal caso consentilo in Impostazioni di Sistema > Privacy e sicurezza > Rete locale. Controlla: cloudmachine-agent vm-status",
  ]
}
