// French translations, keyed by the English text passed to `L10n.tr`.
extension L10nTranslations {
  static let fr: [String: String] = [
    "Space limit:      %@":
      "Limite d'espace :  %@",
    "                  Time Machine quota not set to match - run: %@":
      "                  Quota Time Machine non réglé en conséquence - exécutez : %@",
    "Sets how much of Google Drive this Mac may use, and prints the Time Machine quota command.":
      "Définit l'espace Google Drive que ce Mac peut utiliser et affiche la commande du quota Time Machine.",
    "Limit in GB.":
      "Limite en GB.",
    "Limit for this Mac: %@ GB.":
      "Limite pour ce Mac : %@ GB.",
    "Now set the Time Machine quota (needs an administrator password):":
      "Réglez maintenant le quota Time Machine (mot de passe administrateur requis) :",
    "CloudMachine - verification, Google Drive setup and installation. Called by launchd on a schedule, or by hand from Terminal.":
      "CloudMachine - vérification, configuration de Google Drive et installation. Appelé par launchd selon un calendrier, ou à la main depuis Terminal.",
    "Connects to Google Drive through rclone (OAuth in the browser) and creates this machine's folder.":
      "Se connecte à Google Drive via rclone (OAuth dans le navigateur) et crée le dossier de cette machine.",
    "Overwrite the existing remote. RISKY: replaces the token and permissions.":
      "Écraser le remote existant. RISQUÉ : remplace le jeton et les autorisations.",
    "Packs build/CloudMachine.app into build/CloudMachine-<version>.dmg.":
      "Empaquette build/CloudMachine.app dans build/CloudMachine-<version>.dmg.",
    "ERROR: %@ is missing - run 'cloudmachine-agent build-app' first":
      "ERREUR : %@ est introuvable - exécutez d'abord 'cloudmachine-agent build-app'",
    "==> Preparing the staging folder":
      "==> Préparation du dossier temporaire",
    "==> Creating %@":
      "==> Création de %@",
    "ERROR: hdiutil exited with code %@.":
      "ERREUR : hdiutil s'est terminé avec le code %@.",
    "==> Done: %@":
      "==> Terminé : %@",
    "On first launch (the app is not signed with an Apple Developer account):":
      "Au premier lancement (l'app n'est pas signée avec un compte Apple Developer) :",
    "1. Open %@ and drag CloudMachine.app to Applications.":
      "1. Ouvrez %@ et faites glisser CloudMachine.app dans le dossier Applications.",
    "2. In Finder, RIGHT-click CloudMachine.app -> Open -> Open\n   (a plain double-click shows the Gatekeeper block \"unidentified developer\").":
      "2. Dans le Finder, faites un clic DROIT sur CloudMachine.app -> Ouvrir -> Ouvrir\n   (un simple double-clic affiche le blocage Gatekeeper « développeur non identifié »).",
    "3. Later launches work normally, with a double-click.":
      "3. Les lancements suivants se font normalement, par double-clic.",
    "Builds CloudMachine.app (Release) - GUI + cloudmachine-agent in Contents/MacOS/, plus launchd/, vm/ and config/ as Resources.":
      "Compile CloudMachine.app (Release) - interface + cloudmachine-agent dans Contents/MacOS/, plus launchd/, vm/ et config/ comme ressources.",
    "Binaries for Apple Silicon and Intel at once (how CI builds a release; unnecessary locally).":
      "Binaires pour Apple Silicon et Intel à la fois (ainsi que le CI compile une version ; inutile en local).",
    "==> Building CloudMachineApp + cloudmachine-agent (release) - version %@ (%@)":
      "==> Compilation de CloudMachineApp + cloudmachine-agent (release) - version %@ (%@)",
    "ERROR: swift build exited with code %@.":
      "ERREUR : swift build s'est terminé avec le code %@.",
    "ERROR: swift build --show-bin-path did not report the binaries directory.":
      "ERREUR : swift build --show-bin-path n'a pas indiqué le dossier des binaires.",
    "ERROR: no built binary found at %@":
      "ERREUR : aucun binaire compilé trouvé dans %@",
    "==> Assembling the .app bundle in %@":
      "==> Assemblage du paquet .app dans %@",
    "==> WARNING: you are building from a DIRTY tree - the version will not point to a commit.":
      "==> ATTENTION : vous compilez depuis une arborescence MODIFIÉE - la version ne pointera vers aucun commit.",
    "ERROR: Resources/AppIcon.icns is missing - generate it: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns":
      "ERREUR : Resources/AppIcon.icns est introuvable - générez-le : swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns",
    "==> Signing with the local certificate '%@' (Full Disk Access will survive later rebuilds)":
      "==> Signature avec le certificat local '%@' (l'Accès complet au disque survivra aux recompilations)",
    "==> Signing ad-hoc (no Apple Developer account) - run 'cloudmachine-agent setup-signing-cert' once so that TCC permissions survive later rebuilds":
      "==> Signature ad hoc (sans compte Apple Developer) - exécutez une fois 'cloudmachine-agent setup-signing-cert' pour que les autorisations TCC survivent aux recompilations",
    "ERROR: codesign exited with code %@.":
      "ERREUR : codesign s'est terminé avec le code %@.",
    "Next step: %@":
      "Étape suivante : %@",
    "Creates a local self-signed certificate so that Full Disk Access survives later rebuilds of the app.":
      "Crée un certificat local auto-signé pour que l'Accès complet au disque survive aux recompilations de l'app.",
    "Certificate '%@' already exists in %@, nothing to do.":
      "Le certificat '%@' existe déjà dans %@, rien à faire.",
    "==> Generating the key and self-signed certificate '%@'...":
      "==> Génération de la clé et du certificat auto-signé '%@'...",
    "ERROR: openssl req exited with code %@.":
      "ERREUR : openssl req s'est terminé avec le code %@.",
    "ERROR: openssl pkcs12 exited with code %@.":
      "ERREUR : openssl pkcs12 s'est terminé avec le code %@.",
    "==> Importing the certificate into %@ (pre-authorizing /usr/bin/codesign, so it does not ask for the keychain password every time)...":
      "==> Importation du certificat dans %@ (autorisation préalable de /usr/bin/codesign, pour ne pas redemander le mot de passe du trousseau à chaque fois)...",
    "ERROR: security import exited with code %@.":
      "ERREUR : security import s'est terminé avec le code %@.",
    "==> Trusting the certificate ONLY for code signing...":
      "==> Certificat approuvé UNIQUEMENT pour la signature de code...",
    "ERROR: security add-trusted-cert exited with code %@.":
      "ERREUR : security add-trusted-cert s'est terminé avec le code %@.",
    "Done. Certificate '%@' is now available to codesign.":
      "Terminé. Le certificat '%@' est maintenant disponible pour codesign.",
    "The next 'cloudmachine-agent build-app' will use it automatically instead of an ad-hoc signature.":
      "Le prochain 'cloudmachine-agent build-app' l'utilisera automatiquement à la place d'une signature ad hoc.",
    "After THAT ONE rebuild, grant Full Disk Access one last time - later\nrebuilds will no longer reset it, as long as you sign with the same certificate.":
      "Après CETTE UNIQUE recompilation, accordez une dernière fois l'Accès complet au disque - les\nrecompilations suivantes ne le réinitialiseront plus, tant que vous signez avec le même certificat.",
    "Checks whether the hourly cycle STILL works (date of the last SUCCESSFUL backup) and reports failures.":
      "Vérifie que le cycle horaire fonctionne TOUJOURS (date de la dernière sauvegarde RÉUSSIE) et signale les pannes.",
    "After this many hours without a successful backup we consider the cycle broken.":
      "Au bout de ce nombre d'heures sans sauvegarde réussie, le cycle est considéré comme interrompu.",
    "Only print the state, without a system notification.":
      "Affiche seulement l'état, sans notification système.",
    "A different Time Machine preferences file - to test the watchdog on a known sample.":
      "Un autre fichier de préférences Time Machine - pour tester la surveillance sur un échantillon connu.",
    "Last successful backup: %@":
      "Dernière sauvegarde réussie : %@",
    "Last successful backup: NONE":
      "Dernière sauvegarde réussie : AUCUNE",
    "Last attempt:           %@":
      "Dernière tentative :            %@",
    "WAITING (system startup): %@":
      "EN ATTENTE (démarrage du système) : %@",
    "Backup cycle: OK":
      "Cycle de sauvegarde : OK",
    "FAILURE: %@":
      "PANNE : %@",
    "         %@":
      "        %@",
    "Check the state:  %@":
      "Vérifier l'état :  %@",
    "Preparing for restart":
      "Préparation du redémarrage",
    "Prepare for restart":
      "Préparer le redémarrage",
    "Prepare":
      "Préparer",
    "==> WARNING: git rev-list failed (%@) - using the date as the build number.":
      "==> ATTENTION : git rev-list a échoué (%@) - la date sert de numéro de build.",
    "Agents:           %@":
      "Agents :          %@",
    "CANNOT START: %@ - open CloudMachine or run backup-health to reload them":
      "DÉMARRAGE IMPOSSIBLE : %@ - ouvrez CloudMachine ou exécutez backup-health pour les recharger",
    "Reloaded agents that could not start: %@":
      "Agents rechargés qui n'avaient pas pu démarrer : %@",
    "Drive folder:     %@":
      "Dossier Drive :   %@",
    "Name of this Mac's folder on Google Drive (default: derived from the computer name). Set once; it cannot be changed later.":
      "Nom du dossier de ce Mac sur Google Drive (par défaut : dérivé du nom de l'ordinateur). Défini une seule fois ; impossible à modifier ensuite.",
    "Backup watchdog:  %@":
      "Surveillance :    %@",
    "Prints the version, the build number and the commit this binary was built from.":
      "Affiche la version, le numéro de build et le commit à partir duquel ce binaire a été compilé.",
    "Only one line, without a description.":
      "Une seule ligne, sans description.",
    "Build from the working tree (outside a bundle) - no version data.":
      "Build depuis l'arborescence de travail (hors paquet) - aucune donnée de version.",
    "Version: %@":
      "Version : %@",
    "Build:   %@":
      "Build :   %@",
    "Commit:  %@":
      "Commit :  %@",
    "WARNING: built from a DIRTY tree - the binary contains code that\n         is in no commit. The commit number does NOT describe\n         what actually runs.":
      "ATTENTION : compilé depuis une arborescence MODIFIÉE - le binaire contient du code\n            qui n'est dans aucun commit. Le numéro de commit NE décrit PAS\n            ce qui s'exécute réellement.",
    "Saving the space limit":
      "Enregistrement de la limite d'espace",
    "Measuring usage on Google Drive":
      "Mesure de l'espace utilisé sur Google Drive",
    "Google Drive did not answer - try again later.":
      "Google Drive n'a pas répondu - réessayez plus tard.",
    "Measured.":
      "Mesure effectuée.",
    "Space limit for this Mac":
      "Limite d'espace pour ce Mac",
    "Used on Google Drive":
      "Utilisé sur Google Drive",
    "Measured %@. The watchdog measures again every few hours.":
      "Mesuré le %@. La surveillance mesure de nouveau toutes les quelques heures.",
    "Limit (GB)":
      "Limite (GB)",
    "Save":
      "Enregistrer",
    "Measure now":
      "Mesurer maintenant",
    "Time Machine quota: %@ GB (70%% of the limit - the copy on Drive is about a third larger than the backup inside it). Time Machine deletes the oldest backups to stay within it.":
      "Quota Time Machine : %@ GB (70 %% de la limite - la copie sur Drive est environ un tiers plus grande que la sauvegarde qu'elle contient). Time Machine supprime les plus anciennes sauvegardes pour rester dans ce quota.",
    "Set the Time Machine quota: run this in Terminal (needs sudo)":
      "Réglez le quota Time Machine : exécutez ceci dans Terminal (sudo requis)",
    "Connect Google Drive: run this in Terminal and approve in the browser":
      "Connectez Google Drive : exécutez ceci dans Terminal et validez dans le navigateur",
    "Grant Full Disk Access to CloudMachine, so it can tell whether backups complete":
      "Accordez l'Accès complet au disque à CloudMachine pour qu'il puisse savoir si les sauvegardes se terminent",
    "Folder on Google Drive":
      "Dossier sur Google Drive",
    "One folder per Mac. Set once - it cannot be changed after connecting.":
      "Un dossier par Mac. Défini une seule fois - impossible à modifier après la connexion.",
    "Use lowercase letters, digits and dashes.":
      "Utilisez des lettres minuscules, des chiffres et des tirets.",
    "Install rclone":
      "Installer rclone",
    "Open System Settings":
      "Ouvrir Réglages Système",
    "Install agents":
      "Installer les agents",
    "not checked":
      "non vérifié",
    "none at all":
      "aucune",
    "%@ ago":
      "il y a %@",
    "Missing: %@":
      "Manquant : %@",
    "Google Drive not connected":
      "Google Drive non connecté",
    "Time Machine does not point to CloudMachine":
      "Time Machine ne pointe pas vers CloudMachine",
    "UNKNOWN whether Time Machine points to CloudMachine - tmutil did not answer":
      "On ignore si Time Machine pointe vers CloudMachine - tmutil n'a pas répondu",
    "Backup in progress":
      "Sauvegarde en cours",
    "Unknown when the last backup was made":
      "Date de la dernière sauvegarde inconnue",
    "There is no completed backup at all":
      "Aucune sauvegarde terminée",
    "No completed backup for %@":
      "Aucune sauvegarde terminée depuis %@",
    "Ready":
      "Prêt",
    "Not saved: %@":
      "Non enregistré : %@",
    "Installing rclone":
      "Installation de rclone",
    "Installing launchd agents":
      "Installation des agents launchd",
    "Starting backup":
      "Démarrage de la sauvegarde",
    "Backup started.":
      "Sauvegarde démarrée.",
    "Could not start the backup.":
      "Impossible de démarrer la sauvegarde.",
    "Stopping backup":
      "Arrêt de la sauvegarde",
    "Backup stopped.":
      "Sauvegarde arrêtée.",
    "Could not stop the backup.":
      "Impossible d'arrêter la sauvegarde.",
    "Could not prepare the AppleScript.":
      "Impossible de préparer l'AppleScript.",
    "Unknown authorization error.":
      "Erreur d'autorisation inconnue.",
    "Waiting to upload":
      "En attente d'envoi",
    "%@ files":
      "%@ fichiers",
    "nothing":
      "rien",
    "Back up now":
      "Sauvegarder maintenant",
    "Stop backup":
      "Arrêter la sauvegarde",
    "Open CloudMachine":
      "Ouvrir CloudMachine",
    "Quit":
      "Quitter",
    "Healthy":
      "En bon état",
    "Attention":
      "Attention",
    "Refreshed %@":
      "Actualisé à %@",
    "System Status":
      "État du système",
    "Action needed":
      "Action requise",
    "not measured":
      "non mesuré",
    "rclone did not answer":
      "rclone n'a pas répondu",
    "Backup in Progress":
      "Sauvegarde en cours",
    "Files processed":
      "Fichiers traités",
    "Write speed":
      "Vitesse d'écriture",
    "Operation phase":
      "Phase de l'opération",
    "Required Setup Steps":
      "Étapes de configuration requises",
    "Copy":
      "Copier",
    "Last completed backup":
      "Dernière sauvegarde terminée",
    "Last backup watchdog run":
      "Dernière exécution de la surveillance",
    "not read":
      "non lu",
    "Everything uploaded":
      "Tout est envoyé",
    "File upload errors":
      "Erreurs d'envoi de fichiers",
    "Google Drive Credentials (OAuth 2.0)":
      "Identifiants Google Drive (OAuth 2.0)",
    "Keychain OK":
      "Trousseau OK",
    "No custom keys":
      "Aucune clé personnalisée",
    "Paste client_id...":
      "Collez client_id...",
    "Paste client_secret...":
      "Collez client_secret...",
    "Save securely in the Keychain":
      "Enregistrer en sécurité dans le trousseau",
    "Refresh":
      "Actualiser",
    "Overview":
      "Aperçu",
    "Backups":
      "Sauvegardes",
    "Storage":
      "Stockage",
    "Settings":
      "Réglages",
    "Current status: %@":
      "État actuel : %@",
    "Does not point to CloudMachine":
      "Ne pointe pas vers CloudMachine",
    "tmutil did not answer":
      "tmutil n'a pas répondu",
    "Backing up: %@ of %@":
      "Sauvegarde : %@ sur %@",
    "%@ of %@":
      "%@ sur %@",
    "Copied":
      "Copié",
    "No backup is running":
      "Aucune sauvegarde en cours",
    "Time Machine starts the next one on its own schedule.":
      "Time Machine lancera la suivante selon son propre calendrier.",
    "Backup cycle":
      "Cycle de sauvegarde",
    "%@ GiB":
      "%@ GiB",
    "%@ GiB in %@ bands, %@ uploading":
      "%@ GiB en %@ bandes, %@ en cours d'envoi",
    "%@ bands":
      "%@ bandes",
    "%@ fragments abandoned - only in the machine":
      "%@ fragments abandonnés - uniquement dans la machine",
    "127.0.0.1:5572 answers on the Mac: Lima forwards the machine's rclone remote control, which has no password. Any web page open in a browser can send it commands - including deleting the backup on Google Drive. Add the portForwards rule from vm/cmsmb.yaml to the machine and restart it (see vm/README.md).":
      "127.0.0.1:5572 répond sur le Mac : Lima transmet la télécommande rclone de la machine, qui n'a pas de mot de passe. N'importe quelle page web ouverte dans un navigateur peut lui envoyer des commandes - y compris supprimer la sauvegarde sur Google Drive. Ajoutez à la machine la règle portForwards de vm/cmsmb.yaml et redémarrez-la (voir vm/README.md).",
    "A service in the CloudMachine machine is not running":
      "Un service de la machine CloudMachine ne fonctionne pas",
    "Address":
      "Adresse",
    "Agent installation INCOMPLETE - %@ of %@ did not go in:\n%@\n%@\nEvery missing agent is a function that has silently stopped working (vm-guard watches the machine's buffer, backup-health reports failures). Fix the cause and repeat the installation.":
      "Installation des agents INCOMPLÈTE - %@ sur %@ n'ont pas été installés :\n%@\n%@\nChaque agent manquant est une fonction qui s'est arrêtée en silence (vm-guard surveille le tampon de la machine, backup-health signale les pannes). Corrigez la cause et relancez l'installation.",
    "All running":
      "Tous en fonctionnement",
    "Also install the launchd agents (same as install-launchd).":
      "Installe aussi les agents launchd (comme install-launchd).",
    "At most this many minutes of waiting for the upload.":
      "Attendre l'envoi pendant ce nombre de minutes au maximum.",
    "At the limit every new band fails with EMFILE and the backup stops. Check: cloudmachine-agent vm-status":
      "À la limite, chaque nouvelle bande échoue avec EMFILE et la sauvegarde s'arrête. Vérifiez : cloudmachine-agent vm-status",
    "Cache on the machine's disk":
      "Cache sur le disque de la machine",
    "Connected to Google Drive, but could not create the folder '%@' - without it the machine has nowhere to keep the backup. Check the account permissions and try again.":
      "Connecté à Google Drive, mais impossible de créer le dossier '%@' - sans lui, la machine n'a nulle part où conserver la sauvegarde. Vérifiez les autorisations du compte et réessayez.",
    "Convert the image":
      "Convertir l'image disque",
    "Converting the image to 32 MB bands":
      "Conversion de l'image en bandes de 32 MB",
    "Could not check with the current connection whether the backup is on Google Drive (%@), so remote '%@' was NOT replaced: without that answer the new sign-in cannot be checked against it.":
      "Impossible de vérifier avec la connexion actuelle si la sauvegarde se trouve sur Google Drive (%@), donc le remote '%@' n'a PAS été remplacé : sans cette réponse, la nouvelle connexion ne peut pas être vérifiée.",
    "Downloads the official rclone binary into ~/.cloudmachine/bin (Google sign-in and the machine's rclone.conf).":
      "Télécharge le binaire rclone officiel dans ~/.cloudmachine/bin (connexion Google et rclone.conf de la machine).",
    "Free in the machine":
      "Libre dans la machine",
    "Free in the machine: %@":
      "Libre dans la machine : %@",
    "Generates and installs the launchd agents (app, backup watchdog, machine start, machine guard).":
      "Génère et installe les agents launchd (app, surveillance des sauvegardes, démarrage de la machine, gardien de la machine).",
    "Install Lima, which runs the CloudMachine machine: run this in Terminal":
      "Installez Lima, qui exécute la machine CloudMachine : exécutez ceci dans Terminal",
    "Install rclone (signs in to Google Drive for the machine)":
      "Installez rclone (connecte la machine à Google Drive)",
    "Install the background agents (machine start, buffer guard, backup watchdog)":
      "Installez les agents en arrière-plan (démarrage de la machine, gardien du tampon, surveillance des sauvegardes)",
    "Installs rclone through Homebrew - CloudMachine itself uses the one from install-rclone.":
      "Installe rclone via Homebrew - CloudMachine utilise lui-même celui d'install-rclone.",
    "Info.plist, token and mapped/ of the backup image exist only on the machine's disk; without them the bands in %@ cannot be restored. The copy (tm-meta-sync, every 15 min) goes to %@. Check: cloudmachine-agent vm-status, then in the machine: journalctl -u tm-meta-sync":
      "Info.plist, le jeton et mapped/ de l'image de sauvegarde n'existent que sur le disque de la machine ; sans eux, les bandes de %@ ne peuvent pas être restaurées. La copie (tm-meta-sync, toutes les 15 min) va vers %@. Vérifiez : cloudmachine-agent vm-status, puis dans la machine : journalctl -u tm-meta-sync",
    "Lima says the machine is running, but a command in it did not return. Without it nothing is known about Samba, rclone or the upload. Check: cloudmachine-agent vm-status":
      "Lima indique que la machine fonctionne, mais une commande exécutée dedans n'a pas répondu. Sans elle, on ne sait rien de Samba, de rclone ni de l'envoi. Vérifiez : cloudmachine-agent vm-status",
    "Machine":
      "Machine",
    "Machine %@":
      "Machine %@",
    "Machine & Upload Status":
      "État de la machine et de l'envoi",
    "Machine buffer":
      "Tampon de la machine",
    "No Time Machine destination is the machine's share (smb://tm@<address>/CloudMachine) - backups are not being made there. The command is printed by: cloudmachine-agent vm-setup":
      "Aucune destination Time Machine n'est le partage de la machine (smb://tm@<adresse>/CloudMachine) - aucune sauvegarde n'y est effectuée. La commande est affichée par : cloudmachine-agent vm-setup",
    "Not running: %@":
      "Arrêté : %@",
    "Not set up":
      "Non configurée",
    "Once it runs out, rclone stops uploading, the machine's buffer fills up and backups stop being made. At a growth of ~600 MB per hourly cycle that is about %@ days.":
      "Une fois cet espace épuisé, rclone cesse d'envoyer, le tampon de la machine se remplit et les sauvegardes ne sont plus effectuées. Avec une croissance d'environ 600 MB par cycle horaire, cela représente environ %@ jours.",
    "Or rclone.conf is missing: this Mac has already set up the CloudMachine machine, so it is not connected anew blindly. Restore the file from a backup (the machine keeps its own copy in %@). To connect anyway, create an empty file at the path `%@ config file` prints and run again - the existing folder is kept.":
      "Ou rclone.conf est manquant : ce Mac a déjà configuré la machine CloudMachine, elle n'est donc pas reconnectée à l'aveugle. Restaurez le fichier depuis une sauvegarde (la machine en garde sa propre copie dans %@). Pour vous connecter malgré tout, créez un fichier vide à l'emplacement affiché par `%@ config file` et relancez - le dossier existant est conservé.",
    "Point Time Machine at the machine: run this in Terminal (needs sudo; Copy includes the password)":
      "Faites pointer Time Machine vers la machine : exécutez ceci dans Terminal (sudo requis ; Copier inclut le mot de passe)",
    "Points to the machine":
      "Pointe vers la machine",
    "Prepares for a restart: stops the backup, waits a while for the upload, then stops the machine cleanly.":
      "Prépare un redémarrage : arrête la sauvegarde, attend un moment la fin de l'envoi, puis arrête proprement la machine.",
    "Reading the Time Machine destination did not return within %@ s. That is how tmutil behaves when its destination hangs.":
      "La lecture de la destination Time Machine n'a pas abouti en %@ s. C'est le comportement de tmutil lorsque sa destination se bloque.",
    "Remote '%@' was NOT replaced. The new sign-in gets the 'drive.file' scope, which sees only files created under its own client_id. The existing backup was most likely created by the current connection and would become invisible to it. Before anything is written, the new token is checked against the existing backup, and the replacement is abandoned if it cannot see it. The machine keeps its own copy of the configuration until vm-setup --replace-rclone-config. To go ahead, run again with --replace-existing --accept-scope-change.":
      "Le remote '%@' n'a PAS été remplacé. La nouvelle connexion reçoit l'étendue 'drive.file', qui ne voit que les fichiers créés avec son propre client_id. La sauvegarde existante a très probablement été créée par la connexion actuelle et deviendrait invisible pour elle. Avant toute écriture, le nouveau jeton est vérifié par rapport à la sauvegarde existante, et le remplacement est abandonné s'il ne la voit pas. La machine garde sa propre copie de la configuration jusqu'à vm-setup --replace-rclone-config. Pour continuer, relancez avec --replace-existing --accept-scope-change.",
    "Remote control:   OPEN on the Mac at 127.0.0.1:5572 - any web page can send rclone commands; see vm/README.md (portForwards)":
      "Télécommande :    OUVERTE sur le Mac à 127.0.0.1:5572 - n'importe quelle page web peut envoyer des commandes rclone ; voir vm/README.md (portForwards)",
    "Running":
      "En fonctionnement",
    "Samba, rclone or punchfs in the machine is not active, so Time Machine has nowhere to write or the bands do not reach Google Drive. Check: cloudmachine-agent vm-status":
      "Samba, rclone ou punchfs n'est pas actif dans la machine : Time Machine ne peut donc pas écrire, ou les bandes n'arrivent pas sur Google Drive. Vérifiez : cloudmachine-agent vm-status",
    "Service %@":
      "Service %@",
    "Services":
      "Services",
    "Set up the CloudMachine machine (the first time it downloads Ubuntu - several minutes)":
      "Configurez la machine CloudMachine (la première fois, elle télécharge Ubuntu - plusieurs minutes)",
    "Set up the CloudMachine machine again, so it prints the Time Machine command":
      "Reconfigurer la machine CloudMachine pour qu'elle affiche la commande Time Machine",
    "Set up the machine":
      "Configurer la machine",
    "Setting up the CloudMachine machine":
      "Configuration de la machine CloudMachine",
    "Start the CloudMachine machine":
      "Démarrez la machine CloudMachine",
    "Start the machine":
      "Démarrer la machine",
    "Starting the CloudMachine machine":
      "Démarrage de la machine CloudMachine",
    "Still to upload: %@ GiB":
      "Reste à envoyer : %@ GiB",
    "Stopping the Time Machine backup...":
      "Arrêt de la sauvegarde Time Machine...",
    "Stopping the machine %@...":
      "Arrêt de la machine %@...",
    "The CloudMachine machine does not answer":
      "La machine CloudMachine ne répond pas",
    "The CloudMachine machine is not running":
      "La machine CloudMachine n'est pas en fonctionnement",
    "The CloudMachine machine is not set up yet":
      "La machine CloudMachine n'est pas encore configurée",
    "The CloudMachine machine is stopped":
      "La machine CloudMachine est arrêtée",
    "The backup is stopped, the upload gets up to 30 minutes, then the machine shuts down cleanly. It starts again at the next login.":
      "La sauvegarde est arrêtée, l'envoi dispose de 30 minutes au maximum, puis la machine s'arrête proprement. Elle redémarre à la prochaine ouverture de session.",
    "The machine %@ is not running - nothing to prepare.":
      "La machine %@ n'est pas en fonctionnement - rien à préparer.",
    "The machine is stopped and everything reached Google Drive. The Mac can be restarted; the machine starts again at login.":
      "La machine est arrêtée et tout est arrivé sur Google Drive. Vous pouvez redémarrer le Mac ; la machine redémarre à l'ouverture de session.",
    "The machine is stopped. %@ GiB had not reached Google Drive yet - it is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "La machine est arrêtée. %@ GiB n'étaient pas encore arrivés sur Google Drive - ils sont conservés dans le tampon de la machine et seront envoyés après le prochain démarrage. Vous pouvez redémarrer le Mac.",
    "The machine is stopped. rclone did not say how much was still to upload; what was not uploaded is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "La machine est arrêtée. rclone n'a pas indiqué ce qui restait à envoyer ; ce qui n'a pas été envoyé est conservé dans le tampon de la machine et sera envoyé après le prochain démarrage. Vous pouvez redémarrer le Mac.",
    "The machine's disk is a file on this disk and grows as the upload buffer fills. With no space left the machine cannot write the buffer, and Time Machine's local snapshots have nowhere to go either.":
      "Le disque de la machine est un fichier sur ce disque et il grandit à mesure que le tampon d'envoi se remplit. Sans espace libre, la machine ne peut pas écrire dans le tampon, et les instantanés locaux de Time Machine n'ont plus de place non plus.",
    "The image's metadata has never been copied to Drive":
      "Les métadonnées de l'image n'ont jamais été copiées sur Drive",
    "The image's metadata was last copied to Drive %@ ago":
      "Les métadonnées de l'image ont été copiées sur Drive pour la dernière fois il y a %@",
    "The machine's disk is running out of space (%@ GB)":
      "Le disque de la machine manque d'espace (%@ GB)",
    "The new sign-in does NOT see the existing backup (%@), so remote '%@' was NOT replaced and rclone.conf is unchanged. Keep the current connection, or sign in with the credential (client_id) that created the backup.":
      "La nouvelle connexion NE voit PAS la sauvegarde existante (%@), donc le remote '%@' n'a PAS été remplacé et rclone.conf est inchangé. Gardez la connexion actuelle, ou connectez-vous avec l'identifiant (client_id) qui a créé la sauvegarde.",
    "The upload buffer lives on this disk. The guard pauses Time Machine before it fills; if the upload does not catch up, backups stay paused.":
      "Le tampon d'envoi se trouve sur ce disque. Le gardien met Time Machine en pause avant qu'il ne soit plein ; si l'envoi ne rattrape pas son retard, les sauvegardes restent en pause.",
    "These bands exist only in the machine's buffer. The backup on Google Drive is INCOMPLETE and may not open.":
      "Ces bandes n'existent que dans le tampon de la machine. La sauvegarde sur Google Drive est INCOMPLÈTE et risque de ne pas s'ouvrir.",
    "Time Machine backs up to the machine, so without it no backup is made. Start it: limactl start %@ (or the Start button in the app).":
      "Time Machine sauvegarde vers la machine ; sans elle, aucune sauvegarde n'est effectuée. Démarrez-la : limactl start %@ (ou le bouton « Démarrer la machine » de l'app).",
    "Time Machine did not stop its backup within 2 minutes (or tmutil did not answer) - the machine was NOT stopped. Try again in a moment.":
      "Time Machine n'a pas arrêté sa sauvegarde en 2 minutes (ou tmutil n'a pas répondu) - la machine n'a PAS été arrêtée. Réessayez dans un instant.",
    "Time Machine has created its image: stop the backup, then convert the image to 32 MB bands":
      "Time Machine a créé son image : arrêtez la sauvegarde, puis convertissez l'image en bandes de 32 MB",
    "To upload":
      "À envoyer",
    "Unknown whether the CloudMachine machine is running":
      "On ignore si la machine CloudMachine fonctionne",
    "Waiting for the upload to Google Drive (at most %@ min)...":
      "Attente de l'envoi vers Google Drive (%@ min au maximum)...",
    "With --replace-existing: confirms that the new sign-in (scope 'drive.file') may not see the existing backup. The new token is still checked against the backup first.":
      "Avec --replace-existing : confirme que la nouvelle connexion (étendue 'drive.file') peut ne pas voir la sauvegarde existante. Le nouveau jeton est tout de même vérifié d'abord par rapport à la sauvegarde.",
    "Without it there is no way to check whether anything reached the Drive - the machine's guard is blind then.":
      "Sans lui, il est impossible de vérifier si quoi que ce soit est arrivé sur Drive - le gardien de la machine est alors aveugle.",
    "limactl did not answer":
      "limactl n'a pas répondu",
    "limactl did not answer (or is not installed). That does not mean the machine is down - it means nobody has checked.":
      "limactl n'a pas répondu (ou n'est pas installé). Cela ne signifie pas que la machine est en panne - cela signifie que personne n'a vérifié.",
    "limactl start failed: %@":
      "Échec de limactl start : %@",
    "limactl stop failed: %@":
      "Échec de limactl stop : %@",
    "punchfs is close to its open-file limit":
      "punchfs approche de sa limite de fichiers ouverts",
    "punchfs open files":
      "Fichiers ouverts de punchfs",
    "rclone's remote control is open on this Mac":
      "La télécommande de rclone est ouverte sur ce Mac",
    "statfs('/System/Volumes/Data') returned an error, so nobody knows whether the machine's disk can still grow on this Mac.":
      "statfs('/System/Volumes/Data') a renvoyé une erreur : on ignore donc si le disque de la machine peut encore grandir sur ce Mac.",
    "Google Drive's daily upload limit stops the upload":
      "La limite d'envoi quotidienne de Google Drive bloque l'envoi",
    "Google last refused an upload %@ ago (750 GB a day). Backups since then are only in the machine's buffer on this Mac. rclone retries every 5 min and resumes by itself when the limit passes; the guard pauses Time Machine if more than %@ GiB waits.":
      "Google a refusé un envoi pour la dernière fois il y a %@ (750 GB par jour). Depuis, les sauvegardes ne sont que dans le tampon de la machine sur ce Mac. rclone réessaie toutes les 5 min et reprend tout seul quand la limite est levée ; la garde met Time Machine en pause si plus de %@ GiB attendent.",
    "Usage on Google Drive is not being measured":
      "L'espace utilisé sur Google Drive n'est pas mesuré",
    "The last measurement (%@ GB) is from %@, %@ ago - rclone size has not answered since. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "La dernière mesure (%@ GB) date du %@, il y a %@ - rclone size n'a pas répondu depuis. Tant qu'il ne répond pas, rien ne surveille la limite de %@ GB : les alertes à 90 %% et 100 %% restent muettes. Vérifiez vm-status, ou cliquez sur Mesurer maintenant dans la fenêtre.",
    "rclone size has not answered even once. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "rclone size n'a pas répondu une seule fois. Tant qu'il ne répond pas, rien ne surveille la limite de %@ GB : les alertes à 90 %% et 100 %% restent muettes. Vérifiez vm-status, ou cliquez sur Mesurer maintenant dans la fenêtre.",
    "Saved in the Keychain. Connecting Google Drive (configure-remote) will use them.":
      "Enregistré dans le trousseau. La connexion à Google Drive (configure-remote) les utilisera.",
    "Saved in the Keychain. The existing Google Drive connection keeps its old client_id, and on this Mac it should stay that way: a connection made with the new keys (the 'drive.file' scope) cannot see the backup created by the old one. Do not replace the connection here; the new keys are for a Mac that is not connected yet.":
      "Enregistré dans le trousseau. La connexion Google Drive existante garde son ancien client_id, et sur ce Mac il vaut mieux qu'il en reste ainsi : une connexion établie avec les nouvelles clés (étendue 'drive.file') ne peut pas voir la sauvegarde créée par l'ancienne. Ne remplacez pas la connexion ici ; les nouvelles clés sont destinées à un Mac qui n'est pas encore connecté.",
    "it is not there for the new token":
      "elle n'y figure pas pour le nouveau jeton",
    "Cancel":
      "Annuler",
    "ACTION NEEDED":
      "ACTION REQUISE",
    "WILL PASS BY ITSELF — DO NOTHING":
      "SE RÉSOUDRA TOUT SEUL — NE RIEN FAIRE",
    "UNKNOWN — CHECK AGAIN SHORTLY":
      "INCONNU — VÉRIFIEZ DE NOUVEAU BIENTÔT",
    "ALL GOOD":
      "TOUT VA BIEN",
    "Upload is not working":
      "L'envoi ne fonctionne pas",
    "Upload stopped — no space left on Google Drive":
      "Envoi arrêté — plus d'espace sur Google Drive",
    "%@ backup fragments not uploaded":
      "%@ fragments de sauvegarde non envoyés",
    "Upload cannot keep up with writes":
      "L'envoi ne suit pas les écritures",
    "Upload paused — Google daily limit":
      "Envoi en pause — limite quotidienne de Google",
    "Uploading to Google Drive — %@ queued":
      "Envoi vers Google Drive — %@ en attente",
    "Everything uploaded to Google Drive":
      "Tout est envoyé vers Google Drive",
    "Unknown what is waiting in the queue":
      "On ignore ce qui est en attente dans la file",
    "There is no connection to Google Drive, so backups are only made on this Mac. If this does not pass by itself within a few minutes, check the network and the connection to Drive.":
      "Il n'y a pas de connexion à Google Drive, les sauvegardes ne sont donc effectuées que sur ce Mac. Si cela ne se règle pas tout seul en quelques minutes, vérifiez le réseau et la connexion à Drive.",
    "There is no space left on Google Drive. This will NOT pass by itself — you need to free up space on Drive. Until then Time Machine is paused, so that it does not fill up this Mac's disk.":
      "Il n'y a plus d'espace sur Google Drive. Cela ne se réglera PAS tout seul — vous devez libérer de l'espace sur Drive. D'ici là, Time Machine est en pause, afin de ne pas remplir le disque de ce Mac.",
    "%@ backup fragments could not be uploaded and rclone stopped trying. These fragments exist only on this Mac, so the backup on Drive is incomplete. This needs checking.":
      "%@ fragments de sauvegarde n'ont pas pu être envoyés et rclone a cessé d'essayer. Ces fragments n'existent que sur ce Mac, donc la sauvegarde sur Drive est incomplète. Une vérification est nécessaire.",
    "Time Machine is writing faster than the upload goes, and the buffer has filled up. The backup will be paused until the upload catches up — this is a safeguard against filling up the disk, not a failure.":
      "Time Machine écrit plus vite que l'envoi n'avance, et le tampon est plein. La sauvegarde sera mise en pause jusqu'à ce que l'envoi rattrape son retard — c'est une protection contre le remplissage du disque, pas une panne.",
    "Google accepts 750 GB per day and that limit has been used up. There is nothing to do: the limit renews by itself, usually within a few hours. Time Machine backups are made normally in the meantime and wait in the buffer — they will be uploaded as soon as Google starts accepting again.":
      "Google accepte 750 GB par jour et cette limite est atteinte. Il n'y a rien à faire : la limite se renouvelle toute seule, généralement en quelques heures. Entre-temps, les sauvegardes Time Machine se font normalement et attendent dans le tampon — elles seront envoyées dès que Google acceptera de nouveau.",
    "%@ backup fragments are queued and on their way to Drive.":
      "%@ fragments de sauvegarde sont en file d'attente et en route vers Drive.",
    "Nothing is waiting in the queue — the backup on Google Drive is complete.":
      "Rien n'est en attente dans la file — la sauvegarde sur Google Drive est complète.",
    "rclone did not answer the question about the queue, so it is unknown how many backups are still waiting to be uploaded. This does not mean something broke — under load the answer can be late. It only means that right now nobody knows. If it persists, the backup cycle check will report it.":
      "rclone n'a pas répondu à la question sur la file, on ignore donc combien de sauvegardes attendent encore d'être envoyées. Cela ne signifie pas que quelque chose est cassé — sous charge, la réponse peut arriver en retard. Cela signifie seulement que, pour l'instant, personne ne le sait. Si cela persiste, la vérification du cycle de sauvegarde le signalera.",
    "unknown error":
      "erreur inconnue",
    "rclone lsf ended with an error":
      "rclone lsf s'est terminé avec une erreur",
    "This Mac is close to its space limit on Google Drive":
      "Ce Mac approche de sa limite d'espace sur Google Drive",
    "%@ GB of %@ GB used. Time Machine deletes the oldest backups to stay within its quota; check that the quota is set (vm-status).":
      "%@ GB utilisés sur %@ GB. Time Machine supprime les plus anciennes sauvegardes pour rester dans son quota ; vérifiez que le quota est réglé (vm-status).",
    "This Mac is over its space limit on Google Drive":
      "Ce Mac a dépassé sa limite d'espace sur Google Drive",
    "%@ GB of %@ GB used. Set the Time Machine quota (command in the app window or vm-status), or raise the limit.":
      "%@ GB utilisés sur %@ GB. Réglez le quota Time Machine (commande dans la fenêtre de l'app ou vm-status), ou augmentez la limite.",
    "not set":
      "non défini",
    "%@ GB - usage not measured yet":
      "%@ GB - utilisation pas encore mesurée",
    "%@ of %@ GB used (%@%%)":
      "%@ sur %@ GB utilisés (%@ %%)",
    "The limit must be a whole number of GB above zero.":
      "La limite doit être un nombre entier de GB supérieur à zéro.",
    "machines.json cannot be read, so it was not overwritten. Fix or remove it first.":
      "machines.json est illisible, il n'a donc pas été écrasé. Corrigez-le ou supprimez-le d'abord.",
    "'%@' is not a valid folder name: use lowercase letters, digits and dashes.":
      "'%@' n'est pas un nom de dossier valide : utilisez des lettres minuscules, des chiffres et des tirets.",
    "This Mac already backs up to folder '%@'. Switching to '%@' would start a new, empty backup and orphan the existing one, so nothing was changed.":
      "Ce Mac sauvegarde déjà dans le dossier '%@'. Passer à '%@' démarrerait une nouvelle sauvegarde vide et abandonnerait l'existante, donc rien n'a été modifié.",
    "This Mac already has a CloudMachine installation, whose backup is in folder '%@'. Switching to '%@' would orphan it, so nothing was changed.":
      "Ce Mac a déjà une installation CloudMachine, dont la sauvegarde est dans le dossier '%@'. Passer à '%@' l'abandonnerait, donc rien n'a été modifié.",
    "Could not save the folder name to %@: %@":
      "Impossible d'enregistrer le nom du dossier dans %@ : %@",
    "Homebrew is not installed. Install it manually: https://brew.sh":
      "Homebrew n'est pas installé. Installez-le manuellement : https://brew.sh",
    "Installing rclone failed: %@":
      "Échec de l'installation de rclone : %@",
    "Installed rclone.":
      "rclone installé.",
    "Own Google credentials: set.":
      "Identifiants Google personnels : définis.",
    "INCOMPLETE: %@ is missing - rclone will use rclone's shared client_id anyway.":
      "INCOMPLET : %@ est manquant - rclone utilisera quand même le client_id partagé de rclone.",
    "No own credentials - rclone uses the shared client_id, rate-limited jointly and being retired in 2026.":
      "Aucun identifiant personnel - rclone utilise le client_id partagé, soumis à une limite de débit commune et retiré en 2026.",
    "Empty value - not saving.":
      "Valeur vide - non enregistrée.",
    "Keychain refused: %@":
      "Trousseau a refusé : %@",
    "DIRTY-TREE":
      "ARBORESCENCE-MODIFIÉE",
    "Cannot create the working directory: %@":
      "Impossible de créer le dossier de travail : %@",
    "Could not read the rclone version number.":
      "Impossible de lire le numéro de version de rclone.",
    "Could not download %@.":
      "Impossible de télécharger %@.",
    "No entry for %@ in SHA256SUMS.":
      "Aucune entrée pour %@ dans SHA256SUMS.",
    "Could not compute the checksum.":
      "Impossible de calculer la somme de contrôle.",
    "SHA256 checksum does not match - NOT installing.\n  expected: %@\n  computed: %@":
      "La somme de contrôle SHA256 ne correspond pas - installation ANNULÉE.\n  attendue : %@\n  calculée : %@",
    "Could not unpack the archive.":
      "Impossible de décompresser l'archive.",
    "Could not install the binary: %@":
      "Impossible d'installer le binaire : %@",
    "Installed rclone %@ in %@ (SHA256 checksum matches).":
      "rclone %@ installé dans %@ (la somme de contrôle SHA256 correspond).",
    "%@ did not respond within the allotted time (the process was left orphaned in the background).":
      "%@ n'a pas répondu dans le délai imparti (le processus a été laissé orphelin en arrière-plan).",
    "Cannot launch %@: %@":
      "Impossible de lancer %@ : %@",
    "Remote '%@' already exists and was NOT touched.\nOverwriting it replaces the token and the permission scope; a credential with the 'drive.file' scope does not see files created by the previous one, so the existing backup becomes unreachable.\nIf you really want to replace it, first back up ~/.config/rclone/rclone.conf and run again with --replace-existing.":
      "Le remote '%@' existe déjà et n'a PAS été modifié.\nLe remplacer change le jeton et l'étendue des autorisations ; un identifiant avec l'étendue 'drive.file' ne voit pas les fichiers créés par le précédent, la sauvegarde existante deviendrait donc inaccessible.\nSi vous voulez vraiment le remplacer, sauvegardez d'abord ~/.config/rclone/rclone.conf puis relancez avec --replace-existing.",
    "Could not check whether remote '%@' already exists (rclone listremotes did not answer or failed), so nothing was changed. Run `%@ listremotes` to see the error, then try again.":
      "Impossible de vérifier si le remote '%@' existe déjà (rclone listremotes n'a pas répondu ou a échoué), donc rien n'a été modifié. Exécutez `%@ listremotes` pour voir l'erreur, puis réessayez.",
    "Could not check whether this Mac already has a CloudMachine installation (rclone did not answer), so no folder was chosen. Try again in a moment.":
      "Impossible de vérifier si ce Mac a déjà une installation CloudMachine (rclone n'a pas répondu), donc aucun dossier n'a été choisi. Réessayez dans un instant.",
    "rclone authorize failed (%@). If that binary is missing, start with: cloudmachine-agent install-rclone.":
      "Échec de rclone authorize (%@). Si ce binaire est manquant, commencez par : cloudmachine-agent install-rclone.",
    "Could not read the token from the output of rclone authorize.":
      "Impossible de lire le jeton dans la sortie de rclone authorize.",
    "rclone config create failed.":
      "Échec de rclone config create.",
    "Connected to Google Drive as remote '%@', folder %@.":
      "Connecté à Google Drive en tant que remote '%@', dossier %@.",
    "tmutil is not responding - unknown where the backup goes":
      "tmutil ne répond pas - on ignore où va la sauvegarde",
    "No successful backup for %@":
      "Aucune sauvegarde réussie depuis %@",
    "Last COMPLETED backup: %@. The cycle is hourly, so that is %@ missed runs.":
      "Dernière sauvegarde TERMINÉE : %@. Le cycle étant horaire, cela fait %@ exécutions manquées.",
    "There is NOT A SINGLE successful backup":
      "Il n'y a AUCUNE sauvegarde réussie",
    "The Time Machine preferences contain no date of a completed backup for this destination.":
      "Les préférences de Time Machine ne contiennent aucune date de sauvegarde terminée pour cette destination.",
    "The last backup attempt did not end in a backup":
      "La dernière tentative de sauvegarde n'a pas abouti à une sauvegarde",
    "The attempt at %@ is newer than the last successful backup at %@.":
      "La tentative du %@ est plus récente que la dernière sauvegarde réussie du %@.",
    "Time Machine reports an error in the last run (RESULT=%@)":
      "Time Machine signale une erreur lors de la dernière exécution (RESULT=%@)",
    "A non-zero RESULT in the Time Machine preferences means the run did not succeed.":
      "Un RESULT différent de zéro dans les préférences de Time Machine signifie que l'exécution a échoué.",
    "rclone failed to upload %@ files":
      "rclone n'a pas pu envoyer %@ fichiers",
    "Buffer full of nothing but unsent data":
      "Tampon rempli uniquement de données non envoyées",
    "rclone has nothing left to evict from the buffer - the upload cannot keep up or has stalled.":
      "rclone n'a plus rien à évincer du tampon - l'envoi ne suit pas ou est bloqué.",
    "The rclone control interface is not responding":
      "L'interface de contrôle de rclone ne répond pas",
    "Google Drive is running out of space (%@ GB)":
      "Google Drive manque d'espace (%@ GB)",
    "The Mac's disk is running out of space (%@ GB)":
      "Le disque du Mac manque d'espace (%@ GB)",
    "Cannot read the Time Machine preferences":
      "Impossible de lire les préférences de Time Machine",
    "%@ is unreadable - most often Full Disk Access is missing. Without this file it is UNKNOWN when the last backup was made, so we treat it as a failure, not as the absence of a problem.":
      "%@ est illisible - le plus souvent, l'Accès complet au disque est manquant. Sans ce fichier, il est IMPOSSIBLE de savoir quand la dernière sauvegarde a été faite ; nous le traitons donc comme une panne, et non comme l'absence de problème.",
    "Cannot measure free space on the Mac's disk":
      "Impossible de mesurer l'espace libre sur le disque du Mac",
    "%@ days":
      "%@ jours",
    "CloudMachine: backup is not working":
      "CloudMachine : la sauvegarde ne fonctionne pas",
    "unknown reason":
      "raison inconnue",
    "osascript did not show the notification (permissions or no graphical session)":
      "osascript n'a pas affiché la notification (autorisations ou aucune session graphique)",
    "UNDELIVERED ALARM: %@":
      "ALERTE NON DISTRIBUÉE : %@",
    "from %@, reason: %@":
      "de %@, raison : %@",
    "The system notification was not delivered - you will see this alarm ONLY here.":
      "La notification système n'a pas été distribuée - vous ne verrez cette alerte QU'ICI.",
    "%@ (%@ ago)":
      "%@ (il y a %@)",
    "%@ - marker from the FUTURE":
      "%@ - repère situé dans le FUTUR",
    "%@ (%@ ago) - THE WATCHDOG MAY NOT BE RUNNING":
      "%@ (il y a %@) - LA SURVEILLANCE NE FONCTIONNE PEUT-ÊTRE PAS",
    "NEVER - the watchdog has not recorded a single run":
      "JAMAIS - la surveillance n'a enregistré aucune exécution",
    "Could not find the launchd/ directory with templates.":
      "Impossible de trouver le dossier launchd/ contenant les modèles.",
    "Could not find the compiled cloudmachine-agent binary.":
      "Impossible de trouver le binaire cloudmachine-agent compilé.",
    "ABORTED: could not put cloudmachine-agent in a stable location\n(%@) - most often a lack of space or permissions.\nNOT installing agents pointing at %@: that path\ndisappears on the next `swift build` or `git clean`, and backups stop\nwithout any visible signal.":
      "ANNULÉ : impossible de placer cloudmachine-agent à un emplacement stable\n(%@) - le plus souvent par manque d'espace ou d'autorisations.\nAgents pointant vers %@ NON installés : ce chemin\ndisparaît au prochain `swift build` ou `git clean`, et les sauvegardes s'arrêtent\nsans aucun signal visible.",
    "ABORTED: %@":
      "ANNULÉ : %@",
    "Could not list the templates in %@.":
      "Impossible de lister les modèles dans %@.",
    "could not read the template %@":
      "impossible de lire le modèle %@",
    "could not write %@ (lack of space or permissions)":
      "impossible d'écrire %@ (manque d'espace ou d'autorisations)",
    "launchctl load refused to load %@":
      "launchctl load a refusé de charger %@",
    "NOT A SINGLE agent was loaded.":
      "AUCUN agent n'a été chargé.",
    "Only these went in: %@.":
      "Seuls ceux-ci ont été installés : %@.",
    "Could not load any launchd agent.":
      "Impossible de charger un agent launchd.",
    "Installed agents: %@":
      "Agents installés : %@",
    "                  WARNING: close to the limit - new bands will fail with EMFILE":
      "                  ATTENTION : proche de la limite - les nouvelles bandes échoueront avec EMFILE",
    "%@/bands on Google Drive is not empty - it may hold another backup. NOT overwriting it; check it by hand.":
      "%@/bands sur Google Drive n'est pas vide - il peut contenir une autre sauvegarde. Il n'est PAS écrasé ; vérifiez-le à la main.",
    "Address:          %@":
      "Adresse :         %@",
    "Already prepared (%@ exists) - nothing to do.":
      "Déjà préparé (%@ existe) - rien à faire.",
    "Converts Time Machine's new, empty image in the machine to 32 MB bands and moves the bands to Google Drive.":
      "Convertit la nouvelle image vide de Time Machine dans la machine en bandes de 32 MB et déplace les bandes vers Google Drive.",
    "Copy rclone.conf into the machine even if it already has one.":
      "Copie rclone.conf dans la machine même si elle en a déjà un.",
    "Copying the converted image into the machine failed: %@":
      "La copie de l'image convertie dans la machine a échoué : %@",
    "Copying the image to the Mac failed: %@":
      "La copie de l'image vers le Mac a échoué : %@",
    "Could not ask Lima about the machine: %@":
      "Impossible d'interroger Lima au sujet de la machine : %@",
    "Could not carry the Time Machine files over: %@":
      "Impossible de transférer les fichiers Time Machine : %@",
    "Could not check the image in the machine.":
      "Impossible de vérifier l'image dans la machine.",
    "Could not copy the rclone configuration into the machine.":
      "Impossible de copier la configuration de rclone dans la machine.",
    "Could not create %@ on Google Drive: %@":
      "Impossible de créer %@ sur Google Drive : %@",
    "Could not create %@: %@":
      "Impossible de créer %@ : %@",
    "Could not find the vm/ directory with the machine template.":
      "Impossible de trouver le dossier vm/ contenant le modèle de machine.",
    "Could not read the image size.":
      "Impossible de lire la taille de l'image.",
    "Could not set the SMB password of user %@ in the machine.":
      "Impossible de définir le mot de passe SMB de l'utilisateur %@ dans la machine.",
    "Could not stop smbd in the machine.":
      "Impossible d'arrêter smbd dans la machine.",
    "Could not write %@ in the machine.":
      "Impossible d'écrire %@ dans la machine.",
    "Could not write the password file %@.":
      "Impossible d'écrire le fichier de mot de passe %@.",
    "Creates or starts the CloudMachine machine (Lima), gives it rclone's configuration and an SMB password, and prints the Time Machine command.":
      "Crée ou démarre la machine CloudMachine (Lima), lui transmet la configuration de rclone et un mot de passe SMB, et affiche la commande Time Machine.",
    "Creating the machine %@ (first start downloads Ubuntu and installs packages - several minutes)...":
      "Création de la machine %@ (le premier démarrage télécharge Ubuntu et installe des paquets - plusieurs minutes)...",
    "Done: %@ has %@ MB bands on Google Drive; the original is kept in %@ in the machine. Start the backup: tmutil startbackup":
      "Terminé : %@ a des bandes de %@ MB sur Google Drive ; l'original est conservé dans %@ dans la machine. Lancez la sauvegarde : tmutil startbackup",
    "exit code %@, no message":
      "code de sortie %@, aucun message",
    "Image metadata:   NEVER copied to %@ - check tm-meta-sync in the machine":
      "Métadonnées image : JAMAIS copiées vers %@ - vérifiez tm-meta-sync dans la machine",
    "Image metadata:   copied %@ ago to %@":
      "Métadonnées image : copiées il y a %@ vers %@",
    "Image metadata:   last copied %@ ago - OVERDUE (%@)":
      "Métadonnées image : dernière copie il y a %@ - EN RETARD (%@)",
    "Image metadata:   not copied yet - waits for vm-prepare-bundle":
      "Métadonnées image : pas encore copiées - attend vm-prepare-bundle",
    "Backup %@, paused by the guard %@: %@":
      "Sauvegarde %@, mise en pause par le gardien %@ : %@",
    "Free in machine:  %@ GiB":
      "Libre machine :   %@ GiB",
    "fsck_apfs -n found problems: %@":
      "fsck_apfs -n a trouvé des problèmes : %@",
    "Google Drive folder: %@":
      "Dossier Google Drive : %@",
    "hdiutil attach of the converted image failed: %@":
      "Échec de hdiutil attach sur l'image convertie : %@",
    "hdiutil convert failed: %@":
      "Échec de hdiutil convert : %@",
    "Image name in the machine (default: from the computer name).":
      "Nom de l'image dans la machine (par défaut : dérivé du nom de l'ordinateur).",
    "Installing the converted image FAILED: %@\nsmbd is left STOPPED so Time Machine does not open a half-installed image. The original is in %@ in the machine.":
      "L'installation de l'image convertie a ÉCHOUÉ : %@\nsmbd reste ARRÊTÉ pour que Time Machine n'ouvre pas une image à moitié installée. L'original est dans %@ dans la machine.",
    "limactl create failed: %@":
      "Échec de limactl create : %@",
    "limactl list failed: %@":
      "Échec de limactl list : %@",
    "limactl not found - install Lima: brew install lima":
      "limactl introuvable - installez Lima : brew install lima",
    "limactl start failed: %@\nThe machine's own log: %@":
      "Échec de limactl start : %@\nJournal propre à la machine : %@",
    "Machine %@ is running.":
      "La machine %@ est en fonctionnement.",
    "Machine %@ was already running.":
      "La machine %@ était déjà en fonctionnement.",
    "Machine:          %@ (%@)":
      "Machine :         %@ (%@)",
    "Machine:          %@":
      "Machine :         %@",
    "Machine:          not created - run: cloudmachine-agent vm-setup":
      "Machine :         non créée - exécutez : cloudmachine-agent vm-setup",
    "no answer within the time limit":
      "aucune réponse dans le délai imparti",
    "No image %@ in the machine.":
      "Aucune image %@ dans la machine.",
    "No image in the machine yet - point Time Machine at the share and let it create one first.":
      "Aucune image dans la machine pour l'instant - faites d'abord pointer Time Machine vers le partage et laissez-le en créer une.",
    "No rclone configuration at %@ - connect Google Drive first (configure-remote).":
      "Aucune configuration rclone dans %@ - connectez d'abord Google Drive (configure-remote).",
    "no SMB destination":
      "aucune destination SMB",
    "One check of the machine's upload buffer: pauses Time Machine when it fills, resumes what it paused.":
      "Une vérification du tampon d'envoi de la machine : met Time Machine en pause quand il se remplit, reprend ce qu'elle a mis en pause.",
    "Packing the converted image failed: %@":
      "L'empaquetage de l'image convertie a échoué : %@",
    "Packing the image failed: %@":
      "L'empaquetage de l'image a échoué : %@",
    "No answer from the machine (rclone rc) - the guard would do nothing.":
      "Aucune réponse de la machine (rclone rc) - le gardien ne ferait rien.",
    "Only print what the guard would decide - for trying thresholds on a throwaway machine.":
      "Affiche seulement ce que le gardien déciderait - pour essayer des seuils sur une machine jetable.",
    "Pause above this many GiB in the buffer.":
      "Mettre en pause au-dessus de ce nombre de GiB dans le tampon.",
    "Pause when the machine has less free than this, in GiB.":
      "Mettre en pause quand la machine a moins d'espace libre que ce nombre de GiB.",
    "Point Time Machine at the machine (once, needs an administrator password):":
      "Faites pointer Time Machine vers la machine (une seule fois, mot de passe administrateur requis) :",
    "punchfs files:    %@ open, limit %@":
      "Fichiers punchfs : %@ ouverts, limite %@",
    "rclone configuration already in the machine - kept (--replace-rclone-config replaces it).":
      "La configuration de rclone est déjà dans la machine - conservée (--replace-rclone-config la remplace).",
    "rclone configuration copied into the machine.":
      "Configuration de rclone copiée dans la machine.",
    "rclone-tm or punchfs is not running in the machine - see cloudmachine-agent vm-status.":
      "rclone-tm ou punchfs ne fonctionne pas dans la machine - voir cloudmachine-agent vm-status.",
    "Resume below this many GiB (only a backup the guard paused).":
      "Reprendre en dessous de ce nombre de GiB (uniquement une sauvegarde mise en pause par le gardien).",
    "Service %@: %@":
      "Service %@ : %@",
    "Several images in the machine (%@) - choose one with --bundle.":
      "Plusieurs images dans la machine (%@) - choisissez-en une avec --bundle.",
    "Shows the machine: address, services, upload buffer, free space and the Time Machine destination.":
      "Affiche la machine : adresse, services, tampon d'envoi, espace libre et destination Time Machine.",
    "SMB password stored in %@ (mode 600).":
      "Mot de passe SMB enregistré dans %@ (mode 600).",
    "The converted image does not have %@-byte bands.":
      "L'image convertie n'a pas de bandes de %@ octets.",
    "The converted image has no APFS partition.":
      "L'image convertie n'a pas de partition APFS.",
    "The image already takes %@ MB - this command converts only a new, empty image (under %@ MB).":
      "L'image occupe déjà %@ MB - cette commande ne convertit qu'une image neuve et vide (moins de %@ MB).",
    "The image is encrypted - converting encrypted images is not supported.":
      "L'image est chiffrée - la conversion d'images chiffrées n'est pas prise en charge.",
    "The image was not changed; smbd started again.":
      "L'image n'a pas été modifiée ; smbd a redémarré.",
    "The machine does not answer - is it running? cloudmachine-agent vm-status":
      "La machine ne répond pas - est-elle en fonctionnement ? cloudmachine-agent vm-status",
    "The machine has no address on the vzNAT network.":
      "La machine n'a pas d'adresse sur le réseau vzNAT.",
    "The services in the machine did not start - check: cloudmachine-agent vm-status":
      "Les services de la machine n'ont pas démarré - vérifiez : cloudmachine-agent vm-status",
    "Time Machine is backing up - stop it first: tmutil stopbackup":
      "Time Machine est en train de sauvegarder - arrêtez-le d'abord : tmutil stopbackup",
    "Time Machine:     %@":
      "Time Machine :    %@",
    "Time Machine:     NOT pointing at the machine (%@)":
      "Time Machine :    ne pointe PAS vers la machine (%@)",
    "Time Machine:     tmutil did not answer":
      "Time Machine :    tmutil n'a pas répondu",
    "tmutil did not answer - not touching the image while its state is unknown.":
      "tmutil n'a pas répondu - l'image n'est pas modifiée tant que son état est inconnu.",
    "unknown":
      "inconnu",
    "Unpacking the image failed: %@":
      "La décompression de l'image a échoué : %@",
    "Still to upload:  %@ GiB in %@ bands, uploading %@ (cache on disk %@ GiB)":
      "Reste à envoyer : %@ GiB en %@ bandes, %@ en cours d'envoi (cache sur disque %@ GiB)",
    "Excluded %@ (the machine and its upload buffer) from Time Machine.":
      "%@ (la machine et son tampon d'envoi) exclu de Time Machine.",
    "WARNING: could not exclude %@ from Time Machine - run: tmutil addexclusion %@":
      "ATTENTION : impossible d'exclure %@ de Time Machine - exécutez : tmutil addexclusion %@",
    "Upload buffer:    no answer from rclone (rc %@)":
      "Tampon d'envoi :  aucune réponse de rclone (rc %@)",
    "When Time Machine has created its empty image, stop the backup (tmutil stopbackup) and run: cloudmachine-agent vm-prepare-bundle":
      "Quand Time Machine a créé son image vide, arrêtez la sauvegarde (tmutil stopbackup) et exécutez : cloudmachine-agent vm-prepare-bundle",
    "Unsent %@ GiB, free %@ GiB (pause above %@ GiB unsent or below %@ GiB free, resume below %@ GiB).":
      "%@ GiB non envoyés, %@ GiB libres (pause au-dessus de %@ GiB non envoyés ou en dessous de %@ GiB libres, reprise en dessous de %@ GiB).",
    "Upload:           Google's daily limit refused an upload %@ ago - rclone retries every 5 min and resumes by itself":
      "Envoi :           la limite quotidienne de Google a refusé un envoi il y a %@ - rclone réessaie toutes les 5 min et reprendra tout seul",
    "no":
      "non",
    "running":
      "en cours",
    "stopped":
      "arrêté",
    "yes":
      "oui",
    "%@\nThe previous template is in %@ - copy it back over lima.yaml and run limactl start %@.":
      "%@\nLe modèle précédent est dans %@ - recopiez-le sur lima.yaml et exécutez limactl start %@.",
    "Could not read this app's machine template (limactl template copy).":
      "Impossible de lire le modèle de machine de cette app (limactl template copy).",
    "Could not replace %@: %@":
      "Impossible de remplacer %@ : %@",
    "Machine %@ already runs this app's template.":
      "La machine %@ utilise déjà le modèle de cette app.",
    "Machine %@ now runs this app's template; the previous one is in %@.":
      "La machine %@ utilise maintenant le modèle de cette app ; le précédent est dans %@.",
    "Moves the machine onto this app's template (two restarts, never during a backup).":
      "Fait passer la machine au modèle de cette app (deux redémarrages, jamais pendant une sauvegarde).",
    "No machine %@ - create it with: cloudmachine-agent vm-setup":
      "Aucune machine %@ - créez-la avec : cloudmachine-agent vm-setup",
    "Template:         OLDER than this app's - run: cloudmachine-agent vm-update":
      "Modèle :          PLUS ANCIEN que celui de cette app - exécutez : cloudmachine-agent vm-update",
    "Template:         not compared":
      "Modèle :          non comparé",
    "Template:         this app's":
      "Modèle :          celui de cette app",
    "The machine has no %@ - run cloudmachine-agent vm-setup first.":
      "La machine n'a pas de %@ - exécutez d'abord cloudmachine-agent vm-setup.",
    "The machine restarted, but not every service is running - check: cloudmachine-agent vm-status. The previous template is in %@.":
      "La machine a redémarré, mais tous les services ne fonctionnent pas - vérifiez : cloudmachine-agent vm-status. Le modèle précédent est dans %@.",
    "The template changes the machine itself (%@) - that needs a new machine, not an update.":
      "Le modèle modifie la machine elle-même (%@) - cela demande une nouvelle machine, pas une mise à jour.",
    "The upload to Google Drive hangs":
      "L'envoi vers Google Drive est bloqué",
    "Time Machine is backing up - try again when it has finished.":
      "Time Machine est en train de sauvegarder - réessayez quand elle sera terminée.",
    "Upload:           HANGS - bands in progress, none uploaded for %@ (network?); see /var/log/rclone-tm.log in the machine":
      "Envoi :           BLOQUÉ - bandes en cours, aucune envoyée depuis %@ (réseau ?) ; voir /var/log/rclone-tm.log dans la machine",
    "limactl stop failed - nothing was changed.":
      "Échec de limactl stop - rien n'a été modifié.",
    "rclone has bands in progress, but none has been uploaded for %@ - usually a broken network connection, which rclone does not report as an error. Backups since then are only in the machine's buffer. When the network comes back the upload resumes by itself (on 28.10.2026 within 80 s); if it does not, restarting the machine (prepare-shutdown, limactl start) drops the dead connections.":
      "rclone a des bandes en cours, mais aucune n'a été envoyée depuis %@ - généralement une connexion réseau coupée, que rclone ne signale pas comme une erreur. Les sauvegardes depuis ce moment ne sont que dans le tampon de la machine. Quand le réseau revient, l'envoi reprend tout seul (le 28.10.2026 en 80 s) ; sinon, redémarrer la machine (prepare-shutdown, limactl start) coupe les connexions mortes.",
    "tmutil did not answer - not restarting the machine while its state is unknown.":
      "tmutil n'a pas répondu - la machine n'est pas redémarrée tant que son état est inconnu.",
    "The machine's share cannot be read":
      "Impossible de lire le partage de la machine",
    "Unknown whether the machine's share can be read":
      "On ne sait pas si le partage de la machine est lisible",
    "Samba in the machine does not answer this Mac":
      "Samba dans la machine ne répond pas à ce Mac",
    "Unknown whether Samba in the machine answers this Mac":
      "On ne sait pas si Samba dans la machine répond à ce Mac",
    "Reading 1 byte of %@ in the machine failed: %@. Every service says it is active, yet Time Machine cannot use the image there. Nothing restarts it by itself. Check: cloudmachine-agent vm-status, then in the machine: journalctl -u punchfs -u tm-bands-bind -u rclone-tm":
      "La lecture de 1 octet de %@ dans la machine a échoué : %@. Chaque service se dit actif, mais Time Machine ne peut pas utiliser l'image à cet endroit. Rien ne le redémarre automatiquement. Vérifier : cloudmachine-agent vm-status, puis dans la machine : journalctl -u punchfs -u tm-bands-bind -u rclone-tm",
    "Reading 1 byte of %@ in the machine has not returned for %@ s. That is how a hung punchfs or rclone mount behaves. Nothing is restarted while the state is unknown - a restart under a write still going could lose it. Check in the machine: journalctl -u punchfs -u rclone-tm":
      "La lecture de 1 octet de %@ dans la machine n'est pas revenue depuis %@ s. C'est ainsi que se comporte un montage punchfs ou rclone bloqué. Rien n'est redémarré tant que l'état est inconnu - un redémarrage pendant une écriture en cours pourrait la perdre. Vérifier dans la machine : journalctl -u punchfs -u rclone-tm",
    "An SMB connection to %@ got no answer within %@ s. Time Machine reaches the machine at this address. Check the machine's network and smbd: cloudmachine-agent vm-status":
      "Une connexion SMB à %@ n'a reçu aucune réponse en %@ s. Time Machine joint la machine à cette adresse. Vérifiez le réseau de la machine et smbd : cloudmachine-agent vm-status",
    "The machine did not report its address, so nobody could try an SMB connection. Check: cloudmachine-agent vm-status":
      "La machine n'a pas indiqué son adresse, personne n'a donc pu tenter de connexion SMB. Vérifier : cloudmachine-agent vm-status",
    "An SMB connection to %@ failed (%@). Time Machine reaches the machine at this address, so no backup is made. Check the machine's network and smbd: cloudmachine-agent vm-status":
      "Une connexion SMB à %@ a échoué (%@). Time Machine joint la machine à cette adresse, donc aucune sauvegarde n'est faite. Vérifiez le réseau de la machine et smbd : cloudmachine-agent vm-status",
    "readable":
      "lisible",
    "no image yet":
      "pas encore d'image",
    "answers":
      "répond",
    "Share read:       %@":
      "Lecture partage : %@",
    "Samba from Mac:   %@":
      "Samba (Mac) :     %@",
    "This Mac found no route to %@ (%@). Either the route to the machine is gone, or macOS Local Network privacy has not allowed CloudMachine - then allow it in System Settings > Privacy & Security > Local Network. Check: cloudmachine-agent vm-status":
      "Ce Mac n'a trouvé aucune route vers %@ (%@). Soit la route vers la machine a disparu, soit la confidentialité « Réseau local » de macOS n'a pas autorisé CloudMachine - autorisez-le alors dans Réglages Système > Confidentialité et sécurité > Réseau local. Vérifier : cloudmachine-agent vm-status",
  ]
}
