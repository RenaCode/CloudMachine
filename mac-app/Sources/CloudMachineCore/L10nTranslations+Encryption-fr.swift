// French translations of vm-encrypt (DriveEncryption), keyed by the English text.
extension L10nTranslations {
  static let frEncryption: [String: String] = [
    "%@ and its metadata are in Google Drive's bin (kept 30 days, still counted in the quota).":
      "%@ et ses métadonnées sont dans la corbeille de Google Drive (conservés 30 jours, toujours comptés dans le quota).",
    "'%@' is already in %@ - not replacing its password.":
      "'%@' est déjà dans %@ - son mot de passe n'est pas remplacé.",
    "'%@' is already in the machine's rclone.conf - not replacing its password.":
      "'%@' est déjà dans le rclone.conf de la machine - son mot de passe n'est pas remplacé.",
    "%@ holds folders this key cannot read: another password or salt in the machine, or leftovers of an earlier try. Compare the machine's rclone.conf with the Mac's; leftovers have to be removed from %@ by hand.":
      "%@ contient des dossiers que cette clé ne peut pas lire : un autre mot de passe ou sel dans la machine, ou des restes d'un essai précédent. Comparez le rclone.conf de la machine avec celui du Mac ; les restes doivent être supprimés de %@ à la main.",
    "'%@' is incomplete or missing in the Mac's rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "'%@' est incomplet ou absent du rclone.conf du Mac - exécutez : cloudmachine-agent vm-encrypt setup",
    "CLOUDMACHINE_VM_INSTANCE=%@ needs its own rclone.conf - set RCLONE_CONFIG to a copy, not %@. Its Keychain entry is service %@.":
      "CLOUDMACHINE_VM_INSTANCE=%@ a besoin de son propre rclone.conf - réglez RCLONE_CONFIG sur une copie, pas sur %@. Son entrée du trousseau est le service %@.",
    "Could not read the '%@' section on the Mac or in the machine.":
      "Impossible de lire la section '%@' sur le Mac ou dans la machine.",
    "The machine's '%@' (password, salt or folder) differs from the Mac's - the copy would be readable only with the machine's key. Not moving anything.":
      "'%@' de la machine (mot de passe, sel ou dossier) diffère de celui du Mac - la copie ne serait lisible qu'avec la clé de la machine. Rien n'est déplacé.",
    "A file was restored from the encrypted backup.":
      "Un fichier a été restauré depuis la sauvegarde chiffrée.",
    "Added '%@' (%@) on the Mac and in the machine; password and salt are in the Keychain (service %@).\nSALT: %@\nKeep the password AND this salt outside this Mac now - without both the encrypted backup cannot be read. Next: cloudmachine-agent vm-encrypt copy":
      "'%@' (%@) ajouté sur le Mac et dans la machine ; le mot de passe et le sel sont dans le trousseau (service %@).\nSEL : %@\nConservez maintenant le mot de passe ET ce sel hors de ce Mac - sans les deux, la sauvegarde chiffrée est illisible. Ensuite : cloudmachine-agent vm-encrypt copy",
    "Adds the encrypted remote on the Mac and in the machine (asks for the password). Moves no data.":
      "Ajoute le remote chiffré sur le Mac et dans la machine (demande le mot de passe). Ne déplace aucune donnée.",
    "Again: ":
      "Encore une fois : ",
    "Copies the plain backup into the encrypted folder, in the background; backups go on.":
      "Copie la sauvegarde non chiffrée dans le dossier chiffré, en arrière-plan ; les sauvegardes continuent.",
    "Copy:             %@":
      "Copie :           %@",
    "CLOUDMACHINE_VM_INSTANCE=%@ without CLOUDMACHINE_VM_REMOTE would use the live backup's folder - set both.":
      "CLOUDMACHINE_VM_INSTANCE=%@ sans CLOUDMACHINE_VM_REMOTE utiliserait le dossier de la sauvegarde en service - définissez les deux.",
    "Could not add the remote to %@: %@":
      "Impossible d'ajouter le remote à %@ : %@",
    "Could not add the remote to the machine's rclone.conf.":
      "Impossible d'ajouter le remote au rclone.conf de la machine.",
    "Could not read %@.":
      "Impossible de lire %@.",
    "Could not read when Time Machine last finished a backup (Full Disk Access?) - not deleting.":
      "Impossible de savoir quand Time Machine a terminé sa dernière sauvegarde (Accès complet au disque ?) - aucune suppression.",
    "Could not start the copy: %@":
      "Impossible de lancer la copie : %@",
    "Could not write %@.":
      "Impossible d'écrire %@.",
    "Deleting the plain folder failed: %@":
      "La suppression du dossier non chiffré a échoué : %@",
    "Encrypted folder: %@":
      "Dossier chiffré : %@",
    "Encryption password: ":
      "Mot de passe de chiffrement : ",
    "Machine uses:     %@":
      "Machine utilise : %@",
    "Moves the backup on Google Drive under rclone encryption: setup, copy, switch, then delete-plain.":
      "Place la sauvegarde sur Google Drive sous le chiffrement de rclone : setup, copy, switch, puis delete-plain.",
    "Moves the plain folder to Google Drive's bin - only after a backup has finished into the encrypted one.":
      "Place le dossier non chiffré dans la corbeille de Google Drive - seulement après qu'une sauvegarde s'est terminée dans le dossier chiffré.",
    "Moving the machine failed; it went back to %@: %@":
      "Le basculement de la machine a échoué ; elle est revenue à %@ : %@",
    "No answer from rclone in the machine - the upload queue is unknown.":
      "Aucune réponse de rclone dans la machine - la file d'envoi est inconnue.",
    "No backup has finished into the encrypted folder yet (last one %@, switched %@) - not deleting.":
      "Aucune sauvegarde ne s'est encore terminée dans le dossier chiffré (dernière %@, basculement %@) - aucune suppression.",
    "Not everything is on Google Drive yet (%@ MB unsent, %@ uploading, %@ failed). Wait until the upload is done: cloudmachine-agent vm-status":
      "Tout n'est pas encore sur Google Drive (%@ MB non envoyés, %@ en cours d'envoi, %@ en échec). Attendez la fin de l'envoi : cloudmachine-agent vm-status",
    "Restore a file from the encrypted backup first (Time Machine, Browse), then confirm with --restore-checked.":
      "Restaurez d'abord un fichier depuis la sauvegarde chiffrée (Time Machine, Parcourir), puis confirmez avec --restore-checked.",
    "Shows which folder the machine uses and the copy.":
      "Indique quel dossier la machine utilise et où en est la copie.",
    "Switched:         %@":
      "Basculé :         %@",
    "The copy is already running - see: cloudmachine-agent vm-encrypt status":
      "La copie est déjà en cours - voir : cloudmachine-agent vm-encrypt status",
    "The copy runs in the machine (%@, log %@). Backups go on meanwhile. Check: cloudmachine-agent vm-encrypt status":
      "La copie s'exécute dans la machine (%@, journal %@). Les sauvegardes continuent pendant ce temps. Vérifier : cloudmachine-agent vm-encrypt status",
    "The copy to the encrypted folder has not finished well (%@) - run: cloudmachine-agent vm-encrypt copy, and wait for it.":
      "La copie vers le dossier chiffré ne s'est pas bien terminée (%@) - exécutez : cloudmachine-agent vm-encrypt copy, et attendez-la.",
    "The encryption password and salt are kept outside this Mac.":
      "Le mot de passe de chiffrement et le sel sont conservés hors de ce Mac.",
    "The guard holds Time Machine paused and would resume it during the switch. Wait until it resumes and the upload is done.":
      "Le gardien maintient Time Machine en pause et le relancerait pendant le basculement. Attendez qu'il reprenne et que l'envoi soit terminé.",
    "The image metadata has not been copied to the encrypted folder since the last backup - not deleting.":
      "Les métadonnées de l'image n'ont pas été copiées dans le dossier chiffré depuis la dernière sauvegarde - aucune suppression.",
    "The last sync or cryptcheck failed - the machine was NOT moved: %@":
      "La dernière synchronisation ou cryptcheck a échoué - la machine n'a PAS basculé : %@",
    "The machine already uses the encrypted folder - nothing to switch.":
      "La machine utilise déjà le dossier chiffré - rien à basculer.",
    "The machine already uses the encrypted folder.":
      "La machine utilise déjà le dossier chiffré.",
    "The machine does not use the encrypted folder - nothing to roll back.":
      "La machine n'utilise pas le dossier chiffré - rien à annuler.",
    "The machine does not use the encrypted folder - the plain folder is the backup. Not deleting it.":
      "La machine n'utilise pas le dossier chiffré - le dossier non chiffré est la sauvegarde. Il n'est pas supprimé.",
    "The machine has no '%@' remote in its rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "La machine n'a pas de remote '%@' dans son rclone.conf - exécutez : cloudmachine-agent vm-encrypt setup",
    "The machine is not on this app's template or does not use %@ (cloudmachine-agent vm-update first): %@":
      "La machine n'est pas sur le modèle de cette app ou n'utilise pas %@ (d'abord cloudmachine-agent vm-update) : %@",
    "The machine now uses %@, but %@ could not be updated (%@) - fix it before anything else runs vm-setup.":
      "La machine utilise maintenant %@, mais %@ n'a pas pu être mis à jour (%@) - corrigez-le avant que quoi que ce soit n'exécute vm-setup.",
    "The machine now uses %@. %@ is kept. Turn automatic backups back on: sudo tmutil enable":
      "La machine utilise maintenant %@. %@ est conservé. Réactivez les sauvegardes automatiques : sudo tmutil enable",
    "The password must have at least 12 characters.":
      "Le mot de passe doit comporter au moins 12 caractères.",
    "The passwords differ - nothing was changed.":
      "Les mots de passe diffèrent - rien n'a été modifié.",
    "The switch the other way: decrypts what changed back into the plain folder and uses it again.":
      "Le basculement dans l'autre sens : déchiffre ce qui a changé vers le dossier non chiffré et l'utilise à nouveau.",
    "The upload to the encrypted folder is not finished (or rclone did not answer) - not deleting.":
      "L'envoi vers le dossier chiffré n'est pas terminé (ou rclone n'a pas répondu) - aucune suppression.",
    "Time Machine is backing up. Turn automatic backups off (sudo tmutil disable), stop it (tmutil stopbackup), then run this again.":
      "Time Machine est en train de sauvegarder. Désactivez les sauvegardes automatiques (sudo tmutil disable), arrêtez la sauvegarde (tmutil stopbackup), puis relancez ceci.",
    "With Time Machine stopped: last sync, cryptcheck, then the machine uses the encrypted folder. The plain one stays.":
      "Time Machine arrêté : dernière synchronisation, cryptcheck, puis la machine utilise le dossier chiffré. Le dossier non chiffré reste.",
    "Without the encryption password and salt the encrypted backup cannot be read. Keep both outside this Mac (a password manager, paper), then confirm with --secrets-saved-elsewhere.":
      "Sans le mot de passe de chiffrement et le sel, la sauvegarde chiffrée est illisible. Conservez les deux hors de ce Mac (gestionnaire de mots de passe, papier), puis confirmez avec --secrets-saved-elsewhere.",
    "rclone obscure failed.":
      "rclone obscure a échoué.",
    "tmutil did not answer - not switching while Time Machine's state is unknown.":
      "tmutil n'a pas répondu - pas de basculement tant que l'état de Time Machine est inconnu.",
  ]
}
