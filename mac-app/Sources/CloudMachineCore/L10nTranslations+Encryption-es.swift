// Spanish translations of vm-encrypt (DriveEncryption), keyed by the English text.
extension L10nTranslations {
  static let esEncryption: [String: String] = [
    "%@ and its metadata are in Google Drive's bin (kept 30 days, still counted in the quota).":
      "%@ y sus metadatos están en la papelera de Google Drive (se guardan 30 días y siguen contando en la cuota).",
    "'%@' is already in %@ - not replacing its password.":
      "'%@' ya está en %@: no se sustituye su contraseña.",
    "'%@' is already in the machine's rclone.conf - not replacing its password.":
      "'%@' ya está en el rclone.conf de la máquina: no se sustituye su contraseña.",
    "%@ holds folders this key cannot read: another password or salt in the machine, or leftovers of an earlier try. Compare the machine's rclone.conf with the Mac's; leftovers have to be removed from %@ by hand.":
      "%@ contiene carpetas que esta clave no puede leer: otra contraseña o sal en la máquina, o restos de un intento anterior. Compara el rclone.conf de la máquina con el del Mac; los restos hay que eliminarlos de %@ a mano.",
    "'%@' is incomplete or missing in the Mac's rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "'%@' está incompleto o falta en el rclone.conf del Mac. Ejecuta: cloudmachine-agent vm-encrypt setup",
    "CLOUDMACHINE_VM_INSTANCE=%@ needs its own rclone.conf - set RCLONE_CONFIG to a copy, not %@. Its Keychain entry is service %@.":
      "CLOUDMACHINE_VM_INSTANCE=%@ necesita su propio rclone.conf: define RCLONE_CONFIG con una copia, no con %@. Su entrada del Llavero es el servicio %@.",
    "Could not read the '%@' section on the Mac or in the machine.":
      "No se pudo leer la sección '%@' en el Mac ni en la máquina.",
    "The machine's '%@' (password, salt or folder) differs from the Mac's - the copy would be readable only with the machine's key. Not moving anything.":
      "'%@' de la máquina (contraseña, sal o carpeta) es distinto del del Mac: la copia solo se podría leer con la clave de la máquina. No se mueve nada.",
    "A file was restored from the encrypted backup.":
      "Se restauró un archivo de la copia cifrada.",
    "Added '%@' (%@) on the Mac and in the machine; password and salt are in the Keychain (service %@).\nSALT: %@\nKeep the password AND this salt outside this Mac now - without both the encrypted backup cannot be read. Next: cloudmachine-agent vm-encrypt copy":
      "Se añadió '%@' (%@) en el Mac y en la máquina; la contraseña y la sal están en el Llavero (servicio %@).\nSAL: %@\nGuarda ahora la contraseña Y esta sal fuera de este Mac: sin ambas no se puede leer la copia cifrada. Siguiente: cloudmachine-agent vm-encrypt copy",
    "Adds the encrypted remote on the Mac and in the machine (asks for the password). Moves no data.":
      "Añade el remoto cifrado en el Mac y en la máquina (pide la contraseña). No mueve datos.",
    "Again: ":
      "Otra vez: ",
    "Copies the plain backup into the encrypted folder, in the background; backups go on.":
      "Copia la copia de seguridad sin cifrar a la carpeta cifrada, en segundo plano; las copias continúan.",
    "Copy:             %@":
      "Copia:            %@",
    "CLOUDMACHINE_VM_INSTANCE=%@ without CLOUDMACHINE_VM_REMOTE would use the live backup's folder - set both.":
      "CLOUDMACHINE_VM_INSTANCE=%@ sin CLOUDMACHINE_VM_REMOTE usaría la carpeta de la copia en uso: define ambas.",
    "Could not add the remote to %@: %@":
      "No se pudo añadir el remoto a %@: %@",
    "Could not add the remote to the machine's rclone.conf.":
      "No se pudo añadir el remoto al rclone.conf de la máquina.",
    "Could not read %@.":
      "No se pudo leer %@.",
    "Could not read when Time Machine last finished a backup (Full Disk Access?) - not deleting.":
      "No se pudo saber cuándo terminó Time Machine su última copia (¿Acceso total al disco?): no se elimina nada.",
    "Could not start the copy: %@":
      "No se pudo iniciar la copia: %@",
    "Could not write %@.":
      "No se pudo escribir %@.",
    "Deleting the plain folder failed: %@":
      "Falló la eliminación de la carpeta sin cifrar: %@",
    "Encrypted folder: %@":
      "Carpeta cifrada:  %@",
    "Encryption password: ":
      "Contraseña de cifrado: ",
    "Machine uses:     %@":
      "La máquina usa:   %@",
    "Moves the backup on Google Drive under rclone encryption: setup, copy, switch, then delete-plain.":
      "Pasa la copia de Google Drive al cifrado de rclone: setup, copy, switch y después delete-plain.",
    "Moves the plain folder to Google Drive's bin - only after a backup has finished into the encrypted one.":
      "Mueve la carpeta sin cifrar a la papelera de Google Drive, solo después de que una copia haya terminado en la cifrada.",
    "Moving the machine failed; it went back to %@: %@":
      "Falló el cambio de la máquina; volvió a %@: %@",
    "No answer from rclone in the machine - the upload queue is unknown.":
      "Sin respuesta de rclone en la máquina: la cola de subida es desconocida.",
    "No backup has finished into the encrypted folder yet (last one %@, switched %@) - not deleting.":
      "Todavía no ha terminado ninguna copia en la carpeta cifrada (la última %@, cambio %@): no se elimina nada.",
    "Not everything is on Google Drive yet (%@ MB unsent, %@ uploading, %@ failed). Wait until the upload is done: cloudmachine-agent vm-status":
      "Aún no está todo en Google Drive (%@ MB sin enviar, %@ subiendo, %@ con error). Espera a que termine la subida: cloudmachine-agent vm-status",
    "Restore a file from the encrypted backup first (Time Machine, Browse), then confirm with --restore-checked.":
      "Restaura primero un archivo de la copia cifrada (Time Machine, Explorar) y después confirma con --restore-checked.",
    "Shows which folder the machine uses and the copy.":
      "Muestra qué carpeta usa la máquina y el estado de la copia.",
    "Switched:         %@":
      "Cambiado:         %@",
    "The copy is already running - see: cloudmachine-agent vm-encrypt status":
      "La copia ya está en marcha. Consulta: cloudmachine-agent vm-encrypt status",
    "The copy runs in the machine (%@, log %@). Backups go on meanwhile. Check: cloudmachine-agent vm-encrypt status":
      "La copia se ejecuta en la máquina (%@, registro %@). Mientras tanto, las copias continúan. Comprobar: cloudmachine-agent vm-encrypt status",
    "The copy to the encrypted folder has not finished well (%@) - run: cloudmachine-agent vm-encrypt copy, and wait for it.":
      "La copia a la carpeta cifrada no terminó bien (%@). Ejecuta: cloudmachine-agent vm-encrypt copy y espera a que termine.",
    "The encryption password and salt are kept outside this Mac.":
      "La contraseña de cifrado y la sal se guardan fuera de este Mac.",
    "The guard holds Time Machine paused and would resume it during the switch. Wait until it resumes and the upload is done.":
      "El vigilante mantiene Time Machine en pausa y la reanudaría durante el cambio. Espera a que se reanude y termine la subida.",
    "The image metadata has not been copied to the encrypted folder since the last backup - not deleting.":
      "Los metadatos de la imagen no se han copiado a la carpeta cifrada desde la última copia: no se elimina nada.",
    "The last sync or cryptcheck failed - the machine was NOT moved: %@":
      "Falló la última sincronización o cryptcheck: la máquina NO se ha cambiado: %@",
    "The machine already uses the encrypted folder - nothing to switch.":
      "La máquina ya usa la carpeta cifrada: no hay nada que cambiar.",
    "The machine already uses the encrypted folder.":
      "La máquina ya usa la carpeta cifrada.",
    "The machine does not use the encrypted folder - nothing to roll back.":
      "La máquina no usa la carpeta cifrada: no hay nada que revertir.",
    "The machine does not use the encrypted folder - the plain folder is the backup. Not deleting it.":
      "La máquina no usa la carpeta cifrada: la carpeta sin cifrar es la copia. No se elimina.",
    "The machine has no '%@' remote in its rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "La máquina no tiene el remoto '%@' en su rclone.conf. Ejecuta: cloudmachine-agent vm-encrypt setup",
    "The machine is not on this app's template or does not use %@ (cloudmachine-agent vm-update first): %@":
      "La máquina no usa la plantilla de esta app o no usa %@ (primero cloudmachine-agent vm-update): %@",
    "The machine now uses %@, but %@ could not be updated (%@) - fix it before anything else runs vm-setup.":
      "La máquina usa ahora %@, pero no se pudo actualizar %@ (%@): corrígelo antes de que algo ejecute vm-setup.",
    "The machine now uses %@. %@ is kept. Turn automatic backups back on: sudo tmutil enable":
      "La máquina usa ahora %@. %@ se conserva. Vuelve a activar las copias automáticas: sudo tmutil enable",
    "The password must have at least 12 characters.":
      "La contraseña debe tener al menos 12 caracteres.",
    "The passwords differ - nothing was changed.":
      "Las contraseñas no coinciden: no se ha cambiado nada.",
    "The switch the other way: decrypts what changed back into the plain folder and uses it again.":
      "El cambio en sentido contrario: descifra lo que cambió de vuelta a la carpeta sin cifrar y vuelve a usarla.",
    "The upload to the encrypted folder is not finished (or rclone did not answer) - not deleting.":
      "La subida a la carpeta cifrada no ha terminado (o rclone no respondió): no se elimina nada.",
    "Time Machine is backing up. Turn automatic backups off (sudo tmutil disable), stop it (tmutil stopbackup), then run this again.":
      "Time Machine está haciendo una copia. Desactiva las copias automáticas (sudo tmutil disable), detenla (tmutil stopbackup) y vuelve a ejecutar esto.",
    "With Time Machine stopped: last sync, cryptcheck, then the machine uses the encrypted folder. The plain one stays.":
      "Con Time Machine detenida: última sincronización, cryptcheck y después la máquina usa la carpeta cifrada. La sin cifrar se conserva.",
    "Without the encryption password and salt the encrypted backup cannot be read. Keep both outside this Mac (a password manager, paper), then confirm with --secrets-saved-elsewhere.":
      "Sin la contraseña de cifrado y la sal no se puede leer la copia cifrada. Guarda ambas fuera de este Mac (un gestor de contraseñas, papel) y después confirma con --secrets-saved-elsewhere.",
    "rclone obscure failed.":
      "Falló rclone obscure.",
    "tmutil did not answer - not switching while Time Machine's state is unknown.":
      "tmutil no respondió: no se cambia mientras el estado de Time Machine sea desconocido.",
  ]
}
