// Spanish translations, keyed by the English text passed to `L10n.tr`.
extension L10nTranslations {
  static let es: [String: String] = [
    "Space limit:      %@":
      "Límite de espacio: %@",
    "                  Time Machine quota not set to match - run: %@":
      "                  La cuota de Time Machine no coincide - ejecuta: %@",
    "Sets how much of Google Drive this Mac may use, and prints the Time Machine quota command.":
      "Define cuánto espacio de Google Drive puede usar este Mac e imprime el comando de la cuota de Time Machine.",
    "Limit in GB.":
      "Límite en GB.",
    "Limit for this Mac: %@ GB.":
      "Límite para este Mac: %@ GB.",
    "Now set the Time Machine quota (needs an administrator password):":
      "Ahora ajusta la cuota de Time Machine (requiere una contraseña de administrador):",
    "CloudMachine - verification, Google Drive setup and installation. Called by launchd on a schedule, or by hand from Terminal.":
      "CloudMachine - verificación, configuración de Google Drive e instalación. Lo ejecuta launchd de forma programada, o tú mismo desde Terminal.",
    "Connects to Google Drive through rclone (OAuth in the browser) and creates this machine's folder.":
      "Se conecta a Google Drive mediante rclone (OAuth en el navegador) y crea la carpeta de esta máquina.",
    "Overwrite the existing remote. RISKY: replaces the token and permissions.":
      "Sobrescribe el remote existente. ARRIESGADO: reemplaza el token y los permisos.",
    "Packs build/CloudMachine.app into build/CloudMachine-<version>.dmg.":
      "Empaqueta build/CloudMachine.app en build/CloudMachine-<version>.dmg.",
    "ERROR: %@ is missing - run 'cloudmachine-agent build-app' first":
      "ERROR: falta %@ - ejecuta antes 'cloudmachine-agent build-app'",
    "==> Preparing the staging folder":
      "==> Preparando la carpeta temporal",
    "==> Creating %@":
      "==> Creando %@",
    "ERROR: hdiutil exited with code %@.":
      "ERROR: hdiutil terminó con el código %@.",
    "==> Done: %@":
      "==> Listo: %@",
    "On first launch (the app is not signed with an Apple Developer account):":
      "La primera vez que la abras (la app no está firmada con una cuenta de Apple Developer):",
    "1. Open %@ and drag CloudMachine.app to Applications.":
      "1. Abre %@ y arrastra CloudMachine.app a la carpeta Aplicaciones.",
    "2. In Finder, RIGHT-click CloudMachine.app -> Open -> Open\n   (a plain double-click shows the Gatekeeper block \"unidentified developer\").":
      "2. En el Finder, haz clic DERECHO en CloudMachine.app -> Abrir -> Abrir\n   (un doble clic normal muestra el bloqueo de Gatekeeper \"desarrollador no identificado\").",
    "3. Later launches work normally, with a double-click.":
      "3. Las siguientes veces se abre con normalidad, con doble clic.",
    "Builds CloudMachine.app (Release) - GUI + cloudmachine-agent in Contents/MacOS/, plus launchd/, vm/ and config/ as Resources.":
      "Compila CloudMachine.app (Release) - interfaz + cloudmachine-agent en Contents/MacOS/, además de launchd/, vm/ y config/ como Resources.",
    "Binaries for Apple Silicon and Intel at once (how CI builds a release; unnecessary locally).":
      "Binarios para Apple Silicon e Intel a la vez (así compila CI una versión; innecesario en local).",
    "==> Building CloudMachineApp + cloudmachine-agent (release) - version %@ (%@)":
      "==> Compilando CloudMachineApp + cloudmachine-agent (release) - versión %@ (%@)",
    "ERROR: swift build exited with code %@.":
      "ERROR: swift build terminó con el código %@.",
    "ERROR: swift build --show-bin-path did not report the binaries directory.":
      "ERROR: swift build --show-bin-path no indicó el directorio de los binarios.",
    "ERROR: no built binary found at %@":
      "ERROR: no se encontró ningún binario compilado en %@",
    "==> Assembling the .app bundle in %@":
      "==> Montando el paquete .app en %@",
    "==> WARNING: you are building from a DIRTY tree - the version will not point to a commit.":
      "==> ADVERTENCIA: compilas desde un árbol SUCIO - la versión no apuntará a ningún commit.",
    "ERROR: Resources/AppIcon.icns is missing - generate it: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns":
      "ERROR: falta Resources/AppIcon.icns - genéralo: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns",
    "==> Signing with the local certificate '%@' (Full Disk Access will survive later rebuilds)":
      "==> Firmando con el certificado local '%@' (el Acceso total al disco se conservará en las próximas compilaciones)",
    "==> Signing ad-hoc (no Apple Developer account) - run 'cloudmachine-agent setup-signing-cert' once so that TCC permissions survive later rebuilds":
      "==> Firmando ad hoc (sin cuenta de Apple Developer) - ejecuta una vez 'cloudmachine-agent setup-signing-cert' para que los permisos de TCC se conserven en las próximas compilaciones",
    "ERROR: codesign exited with code %@.":
      "ERROR: codesign terminó con el código %@.",
    "Next step: %@":
      "Siguiente paso: %@",
    "Creates a local self-signed certificate so that Full Disk Access survives later rebuilds of the app.":
      "Crea un certificado local autofirmado para que el Acceso total al disco se conserve al recompilar la app.",
    "Certificate '%@' already exists in %@, nothing to do.":
      "El certificado '%@' ya existe en %@, no hay nada que hacer.",
    "==> Generating the key and self-signed certificate '%@'...":
      "==> Generando la clave y el certificado autofirmado '%@'...",
    "ERROR: openssl req exited with code %@.":
      "ERROR: openssl req terminó con el código %@.",
    "ERROR: openssl pkcs12 exited with code %@.":
      "ERROR: openssl pkcs12 terminó con el código %@.",
    "==> Importing the certificate into %@ (pre-authorizing /usr/bin/codesign, so it does not ask for the keychain password every time)...":
      "==> Importando el certificado en %@ (con autorización previa de /usr/bin/codesign, para que no pida la contraseña del llavero cada vez)...",
    "ERROR: security import exited with code %@.":
      "ERROR: security import terminó con el código %@.",
    "==> Trusting the certificate ONLY for code signing...":
      "==> Confiando en el certificado SOLO para firmar código...",
    "ERROR: security add-trusted-cert exited with code %@.":
      "ERROR: security add-trusted-cert terminó con el código %@.",
    "Done. Certificate '%@' is now available to codesign.":
      "Listo. El certificado '%@' ya está disponible para codesign.",
    "The next 'cloudmachine-agent build-app' will use it automatically instead of an ad-hoc signature.":
      "El próximo 'cloudmachine-agent build-app' lo usará automáticamente en lugar de una firma ad hoc.",
    "After THAT ONE rebuild, grant Full Disk Access one last time - later\nrebuilds will no longer reset it, as long as you sign with the same certificate.":
      "Tras ESA ÚNICA recompilación, concede el Acceso total al disco una última vez - las\nrecompilaciones posteriores ya no lo restablecerán, mientras firmes con el mismo certificado.",
    "Checks whether the hourly cycle STILL works (date of the last SUCCESSFUL backup) and reports failures.":
      "Comprueba si el ciclo cada hora SIGUE funcionando (fecha de la última copia CORRECTA) e informa de los fallos.",
    "After this many hours without a successful backup we consider the cycle broken.":
      "Pasadas tantas horas sin una copia correcta, consideramos que el ciclo está roto.",
    "Only print the state, without a system notification.":
      "Solo muestra el estado, sin notificación del sistema.",
    "A different Time Machine preferences file - to test the watchdog on a known sample.":
      "Otro archivo de preferencias de Time Machine - para probar el supervisor con una muestra conocida.",
    "Last successful backup: %@":
      "Última copia correcta: %@",
    "Last successful backup: NONE":
      "Última copia correcta: NINGUNA",
    "Last attempt:           %@":
      "Último intento:        %@",
    "WAITING (system startup): %@":
      "EN ESPERA (arranque del sistema): %@",
    "Backup cycle: OK":
      "Ciclo de copias: OK",
    "FAILURE: %@":
      "FALLO: %@",
    "         %@":
      "         %@",
    "Check the state:  %@":
      "Comprobar estado: %@",
    "Preparing for restart":
      "Preparando para reiniciar",
    "Prepare for restart":
      "Preparar para reiniciar",
    "Prepare":
      "Preparar",
    "==> WARNING: git rev-list failed (%@) - using the date as the build number.":
      "==> ADVERTENCIA: git rev-list falló (%@) - se usa la fecha como número de compilación.",
    "Agents:           %@":
      "Agentes:          %@",
    "CANNOT START: %@ - open CloudMachine or run backup-health to reload them":
      "NO PUEDEN INICIARSE: %@ - abre CloudMachine o ejecuta backup-health para volver a cargarlos",
    "Reloaded agents that could not start: %@":
      "Agentes recargados que no podían iniciarse: %@",
    "Drive folder:     %@":
      "Carpeta de Drive: %@",
    "Name of this Mac's folder on Google Drive (default: derived from the computer name). Set once; it cannot be changed later.":
      "Nombre de la carpeta de este Mac en Google Drive (por defecto, derivado del nombre del ordenador). Se define una sola vez; después no se puede cambiar.",
    "Backup watchdog:  %@":
      "Supervisor copias: %@",
    "Prints the version, the build number and the commit this binary was built from.":
      "Muestra la versión, el número de compilación y el commit a partir del cual se compiló este binario.",
    "Only one line, without a description.":
      "Solo una línea, sin descripción.",
    "Build from the working tree (outside a bundle) - no version data.":
      "Compilación desde el árbol de trabajo (fuera de un paquete) - sin datos de versión.",
    "Version: %@":
      "Versión: %@",
    "Build:   %@":
      "Compilación: %@",
    "Commit:  %@":
      "Commit: %@",
    "WARNING: built from a DIRTY tree - the binary contains code that\n         is in no commit. The commit number does NOT describe\n         what actually runs.":
      "ADVERTENCIA: compilado desde un árbol SUCIO - el binario contiene código que\n         no está en ningún commit. El número de commit NO describe\n         lo que realmente se ejecuta.",
    "Saving the space limit":
      "Guardando el límite de espacio",
    "Measuring usage on Google Drive":
      "Midiendo el uso en Google Drive",
    "Google Drive did not answer - try again later.":
      "Google Drive no respondió - inténtalo de nuevo más tarde.",
    "Measured.":
      "Medido.",
    "Space limit for this Mac":
      "Límite de espacio para este Mac",
    "Used on Google Drive":
      "Usado en Google Drive",
    "Measured %@. The watchdog measures again every few hours.":
      "Medido %@. El supervisor vuelve a medir cada pocas horas.",
    "Limit (GB)":
      "Límite (GB)",
    "Save":
      "Guardar",
    "Measure now":
      "Medir ahora",
    "Time Machine quota: %@ GB (70%% of the limit - the copy on Drive is about a third larger than the backup inside it). Time Machine deletes the oldest backups to stay within it.":
      "Cuota de Time Machine: %@ GB (70%% del límite - la copia en Drive es aproximadamente un tercio mayor que la copia de seguridad que contiene). Time Machine elimina las copias más antiguas para no superarla.",
    "Set the Time Machine quota: run this in Terminal (needs sudo)":
      "Ajusta la cuota de Time Machine: ejecuta esto en Terminal (requiere sudo)",
    "Connect Google Drive: run this in Terminal and approve in the browser":
      "Conecta Google Drive: ejecuta esto en Terminal y aprueba en el navegador",
    "Grant Full Disk Access to CloudMachine, so it can tell whether backups complete":
      "Concede a CloudMachine el Acceso total al disco para que pueda saber si las copias se completan",
    "Folder on Google Drive":
      "Carpeta en Google Drive",
    "One folder per Mac. Set once - it cannot be changed after connecting.":
      "Una carpeta por Mac. Se define una sola vez: no se puede cambiar después de conectar.",
    "Use lowercase letters, digits and dashes.":
      "Usa letras minúsculas, dígitos y guiones.",
    "Install rclone":
      "Instalar rclone",
    "Open System Settings":
      "Abrir Ajustes del Sistema",
    "Install agents":
      "Instalar agentes",
    "not checked":
      "sin comprobar",
    "none at all":
      "ninguna",
    "%@ ago":
      "hace %@",
    "Missing: %@":
      "Falta: %@",
    "Google Drive not connected":
      "Google Drive no conectado",
    "Time Machine does not point to CloudMachine":
      "Time Machine no apunta a CloudMachine",
    "UNKNOWN whether Time Machine points to CloudMachine - tmutil did not answer":
      "NO SE SABE si Time Machine apunta a CloudMachine - tmutil no respondió",
    "Backup in progress":
      "Copia en curso",
    "Unknown when the last backup was made":
      "Se desconoce cuándo se hizo la última copia",
    "There is no completed backup at all":
      "No hay ninguna copia completada",
    "No completed backup for %@":
      "Ninguna copia completada desde hace %@",
    "Ready":
      "Listo",
    "Not saved: %@":
      "No guardado: %@",
    "Installing rclone":
      "Instalando rclone",
    "Installing launchd agents":
      "Instalando agentes de launchd",
    "Starting backup":
      "Iniciando la copia",
    "Backup started.":
      "Copia iniciada.",
    "Could not start the backup.":
      "No se pudo iniciar la copia.",
    "Stopping backup":
      "Deteniendo la copia",
    "Backup stopped.":
      "Copia detenida.",
    "Could not stop the backup.":
      "No se pudo detener la copia.",
    "Could not prepare the AppleScript.":
      "No se pudo preparar el AppleScript.",
    "Unknown authorization error.":
      "Error de autorización desconocido.",
    "Waiting to upload":
      "Pendiente de subir",
    "%@ files":
      "%@ archivos",
    "nothing":
      "nada",
    "Back up now":
      "Hacer copia ahora",
    "Stop backup":
      "Detener copia",
    "Open CloudMachine":
      "Abrir CloudMachine",
    "Quit":
      "Salir",
    "Healthy":
      "Correcto",
    "Attention":
      "Atención",
    "Refreshed %@":
      "Actualizado %@",
    "System Status":
      "Estado del sistema",
    "Action needed":
      "Acción necesaria",
    "not measured":
      "sin medir",
    "rclone did not answer":
      "rclone no respondió",
    "Backup in Progress":
      "Copia en curso",
    "Files processed":
      "Archivos procesados",
    "Write speed":
      "Velocidad de escritura",
    "Operation phase":
      "Fase de la operación",
    "Required Setup Steps":
      "Pasos de configuración necesarios",
    "Copy":
      "Copiar",
    "Last completed backup":
      "Última copia completada",
    "Last backup watchdog run":
      "Última ejecución del supervisor de copias",
    "not read":
      "sin leer",
    "Everything uploaded":
      "Todo subido",
    "File upload errors":
      "Errores al subir archivos",
    "Google Drive Credentials (OAuth 2.0)":
      "Credenciales de Google Drive (OAuth 2.0)",
    "Keychain OK":
      "Llavero correcto",
    "No custom keys":
      "Sin claves propias",
    "Paste client_id...":
      "Pega client_id...",
    "Paste client_secret...":
      "Pega client_secret...",
    "Save securely in the Keychain":
      "Guardar de forma segura en el Llavero",
    "Refresh":
      "Actualizar",
    "Overview":
      "Resumen",
    "Backups":
      "Copias",
    "Storage":
      "Almacenamiento",
    "Settings":
      "Ajustes",
    "Current status: %@":
      "Estado actual: %@",
    "Does not point to CloudMachine":
      "No apunta a CloudMachine",
    "tmutil did not answer":
      "tmutil no respondió",
    "Backing up: %@ of %@":
      "Copiando: %@ de %@",
    "%@ of %@":
      "%@ de %@",
    "Copied":
      "Copiado",
    "No backup is running":
      "No hay ninguna copia en curso",
    "Time Machine starts the next one on its own schedule.":
      "Time Machine inicia la siguiente según su propio calendario.",
    "Backup cycle":
      "Ciclo de copias",
    "%@ GiB":
      "%@ GiB",
    "%@ GiB in %@ bands, %@ uploading":
      "%@ GiB en %@ bandas, %@ subiendo",
    "%@ bands":
      "%@ bandas",
    "%@ fragments abandoned - only in the machine":
      "%@ fragmentos abandonados - solo en la máquina",
    "127.0.0.1:5572 answers on the Mac: Lima forwards the machine's rclone remote control, which has no password. Any web page open in a browser can send it commands - including deleting the backup on Google Drive. Add the portForwards rule from vm/cmsmb.yaml to the machine and restart it (see vm/README.md).":
      "127.0.0.1:5572 responde en el Mac: Lima reenvía el control remoto de rclone de la máquina, que no tiene contraseña. Cualquier página web abierta en un navegador puede enviarle comandos, incluido borrar la copia en Google Drive. Añade a la máquina la regla portForwards de vm/cmsmb.yaml y reiníciala (consulta vm/README.md).",
    "A service in the CloudMachine machine is not running":
      "Un servicio de la máquina de CloudMachine no está en marcha",
    "Address":
      "Dirección",
    "Agent installation INCOMPLETE - %@ of %@ did not go in:\n%@\n%@\nEvery missing agent is a function that has silently stopped working (vm-guard watches the machine's buffer, backup-health reports failures). Fix the cause and repeat the installation.":
      "Instalación de agentes INCOMPLETA - %@ de %@ no se instalaron:\n%@\n%@\nCada agente que falta es una función que ha dejado de funcionar sin avisar (vm-guard vigila el búfer de la máquina, backup-health informa de los fallos). Corrige la causa y repite la instalación.",
    "All running":
      "Todo en marcha",
    "Also install the launchd agents (same as install-launchd).":
      "Instala también los agentes de launchd (igual que install-launchd).",
    "At most this many minutes of waiting for the upload.":
      "Como máximo, esta cantidad de minutos de espera por la subida.",
    "At the limit every new band fails with EMFILE and the backup stops. Check: cloudmachine-agent vm-status":
      "Al llegar al límite, cada banda nueva falla con EMFILE y la copia se detiene. Comprueba: cloudmachine-agent vm-status",
    "Cache on the machine's disk":
      "Caché en el disco de la máquina",
    "Connected to Google Drive, but could not create the folder '%@' - without it the machine has nowhere to keep the backup. Check the account permissions and try again.":
      "Conectado a Google Drive, pero no se pudo crear la carpeta '%@' - sin ella la máquina no tiene dónde guardar la copia. Revisa los permisos de la cuenta e inténtalo de nuevo.",
    "Convert the image":
      "Convertir la imagen",
    "Converting the image to 32 MB bands":
      "Convirtiendo la imagen a bandas de 32 MB",
    "Could not check with the current connection whether the backup is on Google Drive (%@), so remote '%@' was NOT replaced: without that answer the new sign-in cannot be checked against it.":
      "No se pudo comprobar con la conexión actual si la copia está en Google Drive (%@), así que el remote '%@' NO se reemplazó: sin esa respuesta no se puede contrastar el nuevo inicio de sesión.",
    "Downloads the official rclone binary into ~/.cloudmachine/bin (Google sign-in and the machine's rclone.conf).":
      "Descarga el binario oficial de rclone en ~/.cloudmachine/bin (inicio de sesión de Google y rclone.conf de la máquina).",
    "Free in the machine":
      "Libre en la máquina",
    "Free in the machine: %@":
      "Libre en la máquina: %@",
    "Generates and installs the launchd agents (app, backup watchdog, machine start, machine guard).":
      "Genera e instala los agentes de launchd (app, supervisor de copias, arranque de la máquina, guardián de la máquina).",
    "Install Lima, which runs the CloudMachine machine: run this in Terminal":
      "Instala Lima, que ejecuta la máquina de CloudMachine: ejecuta esto en Terminal",
    "Install rclone (signs in to Google Drive for the machine)":
      "Instalar rclone (inicia sesión en Google Drive para la máquina)",
    "Install the background agents (machine start, buffer guard, backup watchdog)":
      "Instalar los agentes en segundo plano (arranque de la máquina, guardián del búfer, supervisor de copias)",
    "Installs rclone through Homebrew - CloudMachine itself uses the one from install-rclone.":
      "Instala rclone mediante Homebrew - CloudMachine usa el de install-rclone.",
    "Info.plist, token and mapped/ of the backup image exist only on the machine's disk; without them the bands in %@ cannot be restored. The copy (tm-meta-sync, every 15 min) goes to %@. Check: cloudmachine-agent vm-status, then in the machine: journalctl -u tm-meta-sync":
      "Info.plist, token y mapped/ de la imagen de la copia existen solo en el disco de la máquina; sin ellos no se pueden restaurar las bandas de %@. La copia (tm-meta-sync, cada 15 min) va a %@. Comprueba: cloudmachine-agent vm-status y, en la máquina: journalctl -u tm-meta-sync",
    "Lima says the machine is running, but a command in it did not return. Without it nothing is known about Samba, rclone or the upload. Check: cloudmachine-agent vm-status":
      "Lima dice que la máquina está en marcha, pero un comando en ella no respondió. Sin él no se sabe nada de Samba, rclone ni de la subida. Comprueba: cloudmachine-agent vm-status",
    "Machine":
      "Máquina",
    "Machine %@":
      "Máquina %@",
    "Machine & Upload Status":
      "Estado de la máquina y la subida",
    "Machine buffer":
      "Búfer de la máquina",
    "No Time Machine destination is the machine's share (smb://tm@<address>/CloudMachine) - backups are not being made there. The command is printed by: cloudmachine-agent vm-setup":
      "Ningún destino de Time Machine es el recurso compartido de la máquina (smb://tm@<address>/CloudMachine) - no se hacen copias allí. El comando lo imprime: cloudmachine-agent vm-setup",
    "Not running: %@":
      "No está en marcha: %@",
    "Not set up":
      "Sin configurar",
    "Once it runs out, rclone stops uploading, the machine's buffer fills up and backups stop being made. At a growth of ~600 MB per hourly cycle that is about %@ days.":
      "Cuando se agote, rclone deja de subir, el búfer de la máquina se llena y se dejan de hacer copias. Con un crecimiento de ~600 MB por ciclo horario son unos %@ días.",
    "Or rclone.conf is missing: this Mac has already set up the CloudMachine machine, so it is not connected anew blindly. Restore the file from a backup (the machine keeps its own copy in %@). To connect anyway, create an empty file at the path `%@ config file` prints and run again - the existing folder is kept.":
      "O falta rclone.conf: este Mac ya configuró la máquina de CloudMachine, así que no se conecta de nuevo a ciegas. Restaura el archivo desde una copia (la máquina guarda la suya en %@). Para conectar de todos modos, crea un archivo vacío en la ruta que imprime `%@ config file` y ejecuta de nuevo - se conserva la carpeta existente.",
    "Point Time Machine at the machine: run this in Terminal (needs sudo; Copy includes the password)":
      "Apunta Time Machine a la máquina: ejecuta esto en Terminal (requiere sudo; Copiar incluye la contraseña)",
    "Points to the machine":
      "Apunta a la máquina",
    "Prepares for a restart: stops the backup, waits a while for the upload, then stops the machine cleanly.":
      "Prepara el reinicio: detiene la copia, espera un rato a que termine la subida y después detiene la máquina de forma limpia.",
    "Reading the Time Machine destination did not return within %@ s. That is how tmutil behaves when its destination hangs.":
      "La lectura del destino de Time Machine no respondió en %@ s. Así se comporta tmutil cuando su destino se queda colgado.",
    "Remote '%@' was NOT replaced. The new sign-in gets the 'drive.file' scope, which sees only files created under its own client_id. The existing backup was most likely created by the current connection and would become invisible to it. Before anything is written, the new token is checked against the existing backup, and the replacement is abandoned if it cannot see it. The machine keeps its own copy of the configuration until vm-setup --replace-rclone-config. To go ahead, run again with --replace-existing --accept-scope-change.":
      "El remote '%@' NO se reemplazó. El nuevo inicio de sesión recibe el alcance 'drive.file', que solo ve los archivos creados con su propio client_id. La copia existente probablemente la creó la conexión actual y dejaría de ser visible para ella. Antes de escribir nada, el nuevo token se contrasta con la copia existente y el reemplazo se cancela si no la ve. La máquina conserva su propia copia de la configuración hasta vm-setup --replace-rclone-config. Para continuar, ejecuta de nuevo con --replace-existing --accept-scope-change.",
    "Remote control:   OPEN on the Mac at 127.0.0.1:5572 - any web page can send rclone commands; see vm/README.md (portForwards)":
      "Control remoto:   ABIERTO en el Mac en 127.0.0.1:5572 - cualquier página web puede enviar comandos a rclone; consulta vm/README.md (portForwards)",
    "Running":
      "En marcha",
    "Samba, rclone or punchfs in the machine is not active, so Time Machine has nowhere to write or the bands do not reach Google Drive. Check: cloudmachine-agent vm-status":
      "Samba, rclone o punchfs de la máquina no está activo, así que Time Machine no tiene dónde escribir o las bandas no llegan a Google Drive. Comprueba: cloudmachine-agent vm-status",
    "Service %@":
      "Servicio %@",
    "Services":
      "Servicios",
    "Set up the CloudMachine machine (the first time it downloads Ubuntu - several minutes)":
      "Configurar la máquina de CloudMachine (la primera vez descarga Ubuntu - varios minutos)",
    "Set up the CloudMachine machine again, so it prints the Time Machine command":
      "Configurar de nuevo la máquina de CloudMachine, para que imprima el comando de Time Machine",
    "Set up the machine":
      "Configurar la máquina",
    "Setting up the CloudMachine machine":
      "Configurando la máquina de CloudMachine",
    "Start the CloudMachine machine":
      "Iniciar la máquina de CloudMachine",
    "Start the machine":
      "Iniciar la máquina",
    "Starting the CloudMachine machine":
      "Iniciando la máquina de CloudMachine",
    "Still to upload: %@ GiB":
      "Pendiente de subir: %@ GiB",
    "Stopping the Time Machine backup...":
      "Deteniendo la copia de Time Machine...",
    "Stopping the machine %@...":
      "Deteniendo la máquina %@...",
    "The CloudMachine machine does not answer":
      "La máquina de CloudMachine no responde",
    "The CloudMachine machine is not running":
      "La máquina de CloudMachine no está en marcha",
    "The CloudMachine machine is not set up yet":
      "La máquina de CloudMachine aún no está configurada",
    "The CloudMachine machine is stopped":
      "La máquina de CloudMachine está detenida",
    "The backup is stopped, the upload gets up to 30 minutes, then the machine shuts down cleanly. It starts again at the next login.":
      "La copia se detiene, la subida dispone de hasta 30 minutos y después la máquina se apaga de forma limpia. Vuelve a iniciarse en el próximo inicio de sesión.",
    "The machine %@ is not running - nothing to prepare.":
      "La máquina %@ no está en marcha - no hay nada que preparar.",
    "The machine is stopped and everything reached Google Drive. The Mac can be restarted; the machine starts again at login.":
      "La máquina está detenida y todo llegó a Google Drive. Puedes reiniciar el Mac; la máquina se inicia de nuevo al iniciar sesión.",
    "The machine is stopped. %@ GiB had not reached Google Drive yet - it is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "La máquina está detenida. %@ GiB aún no habían llegado a Google Drive - se conservan en el búfer de la máquina y se subirán tras el próximo inicio. Puedes reiniciar el Mac.",
    "The machine is stopped. rclone did not say how much was still to upload; what was not uploaded is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "La máquina está detenida. rclone no indicó cuánto quedaba por subir; lo que no se subió se conserva en el búfer de la máquina y se subirá tras el próximo inicio. Puedes reiniciar el Mac.",
    "The machine's disk is a file on this disk and grows as the upload buffer fills. With no space left the machine cannot write the buffer, and Time Machine's local snapshots have nowhere to go either.":
      "El disco de la máquina es un archivo de este disco y crece a medida que se llena el búfer de subida. Sin espacio libre, la máquina no puede escribir el búfer y las instantáneas locales de Time Machine tampoco tienen dónde guardarse.",
    "The image's metadata has never been copied to Drive":
      "Los metadatos de la imagen nunca se han copiado a Drive",
    "The image's metadata was last copied to Drive %@ ago":
      "Los metadatos de la imagen se copiaron a Drive por última vez hace %@",
    "The machine's disk is running out of space (%@ GB)":
      "Al disco de la máquina le queda poco espacio (%@ GB)",
    "The new sign-in does NOT see the existing backup (%@), so remote '%@' was NOT replaced and rclone.conf is unchanged. Keep the current connection, or sign in with the credential (client_id) that created the backup.":
      "El nuevo inicio de sesión NO ve la copia existente (%@), así que el remote '%@' NO se reemplazó y rclone.conf no ha cambiado. Conserva la conexión actual o inicia sesión con la credencial (client_id) que creó la copia.",
    "The upload buffer lives on this disk. The guard pauses Time Machine before it fills; if the upload does not catch up, backups stay paused.":
      "El búfer de subida está en este disco. El guardián pausa Time Machine antes de que se llene; si la subida no se pone al día, las copias siguen en pausa.",
    "These bands exist only in the machine's buffer. The backup on Google Drive is INCOMPLETE and may not open.":
      "Estas bandas existen solo en el búfer de la máquina. La copia en Google Drive está INCOMPLETA y puede que no se abra.",
    "Time Machine backs up to the machine, so without it no backup is made. Start it: limactl start %@ (or the Start button in the app).":
      "Time Machine hace la copia en la máquina, así que sin ella no se hace ninguna copia. Inicia la máquina: limactl start %@ (o con el botón «Iniciar la máquina» de la app).",
    "Time Machine did not stop its backup within 2 minutes (or tmutil did not answer) - the machine was NOT stopped. Try again in a moment.":
      "Time Machine no detuvo su copia en 2 minutos (o tmutil no respondió) - la máquina NO se detuvo. Inténtalo de nuevo en un momento.",
    "Time Machine has created its image: stop the backup, then convert the image to 32 MB bands":
      "Time Machine ha creado su imagen: detén la copia y convierte la imagen a bandas de 32 MB",
    "To upload":
      "Por subir",
    "Unknown whether the CloudMachine machine is running":
      "Se desconoce si la máquina de CloudMachine está en marcha",
    "Waiting for the upload to Google Drive (at most %@ min)...":
      "Esperando la subida a Google Drive (máximo %@ min)...",
    "With --replace-existing: confirms that the new sign-in (scope 'drive.file') may not see the existing backup. The new token is still checked against the backup first.":
      "Con --replace-existing: confirma que el nuevo inicio de sesión (alcance 'drive.file') puede no ver la copia existente. El nuevo token se sigue contrastando antes con la copia.",
    "Without it there is no way to check whether anything reached the Drive - the machine's guard is blind then.":
      "Sin él no hay forma de saber si algo llegó a Drive - el guardián de la máquina queda ciego.",
    "limactl did not answer":
      "limactl no respondió",
    "limactl did not answer (or is not installed). That does not mean the machine is down - it means nobody has checked.":
      "limactl no respondió (o no está instalado). Eso no significa que la máquina esté caída, sino que nadie lo ha comprobado.",
    "limactl start failed: %@":
      "limactl start falló: %@",
    "limactl stop failed: %@":
      "limactl stop falló: %@",
    "punchfs is close to its open-file limit":
      "punchfs está cerca de su límite de archivos abiertos",
    "punchfs open files":
      "Archivos abiertos de punchfs",
    "rclone's remote control is open on this Mac":
      "El control remoto de rclone está abierto en este Mac",
    "statfs('/System/Volumes/Data') returned an error, so nobody knows whether the machine's disk can still grow on this Mac.":
      "statfs('/System/Volumes/Data') devolvió un error, así que no se sabe si el disco de la máquina aún puede crecer en este Mac.",
    "Google Drive's daily upload limit stops the upload":
      "El límite diario de subida de Google Drive detiene la subida",
    "Google last refused an upload %@ ago (750 GB a day). Backups since then are only in the machine's buffer on this Mac. rclone retries every 5 min and resumes by itself when the limit passes; the guard pauses Time Machine if more than %@ GiB waits.":
      "Google rechazó una subida por última vez hace %@ (750 GB al día). Las copias desde entonces están solo en el búfer de la máquina de este Mac. rclone reintenta cada 5 min y se reanuda solo cuando pasa el límite; el guardián pausa Time Machine si esperan más de %@ GiB.",
    "Usage on Google Drive is not being measured":
      "No se está midiendo el uso de Google Drive",
    "The last measurement (%@ GB) is from %@, %@ ago - rclone size has not answered since. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "La última medición (%@ GB) es de %@, hace %@ - rclone size no ha respondido desde entonces. Hasta que lo haga, nada vigila el límite de %@ GB: las alarmas del 90%% y del 100%% quedan en silencio. Comprueba vm-status o pulsa Medir ahora en la ventana.",
    "rclone size has not answered even once. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "rclone size no ha respondido ni una sola vez. Hasta que lo haga, nada vigila el límite de %@ GB: las alarmas del 90%% y del 100%% quedan en silencio. Comprueba vm-status o pulsa Medir ahora en la ventana.",
    "Saved in the Keychain. Connecting Google Drive (configure-remote) will use them.":
      "Guardado en el Llavero. Se usarán al conectar Google Drive (configure-remote).",
    "Saved in the Keychain. The existing Google Drive connection keeps its old client_id, and on this Mac it should stay that way: a connection made with the new keys (the 'drive.file' scope) cannot see the backup created by the old one. Do not replace the connection here; the new keys are for a Mac that is not connected yet.":
      "Guardado en el Llavero. La conexión existente con Google Drive conserva su client_id anterior, y en este Mac debe seguir así: una conexión hecha con las claves nuevas (alcance 'drive.file') no puede ver la copia creada con la anterior. No reemplaces aquí la conexión; las claves nuevas son para un Mac que aún no está conectado.",
    "it is not there for the new token":
      "no está para el nuevo token",
    "Cancel":
      "Cancelar",
    "ACTION NEEDED":
      "ACCIÓN NECESARIA",
    "WILL PASS BY ITSELF — DO NOTHING":
      "SE RESOLVERÁ SOLO — NO HAGAS NADA",
    "UNKNOWN — CHECK AGAIN SHORTLY":
      "SE DESCONOCE — COMPRUEBA DE NUEVO EN BREVE",
    "ALL GOOD":
      "TODO BIEN",
    "Upload is not working":
      "La subida no funciona",
    "Upload stopped — no space left on Google Drive":
      "Subida detenida — no queda espacio en Google Drive",
    "%@ backup fragments not uploaded":
      "%@ fragmentos de copia sin subir",
    "Upload cannot keep up with writes":
      "La subida no puede seguir el ritmo de escritura",
    "Upload paused — Google daily limit":
      "Subida en pausa — límite diario de Google",
    "Uploading to Google Drive — %@ queued":
      "Subiendo a Google Drive — %@ en cola",
    "Everything uploaded to Google Drive":
      "Todo subido a Google Drive",
    "Unknown what is waiting in the queue":
      "Se desconoce qué hay en la cola",
    "There is no connection to Google Drive, so backups are only made on this Mac. If this does not pass by itself within a few minutes, check the network and the connection to Drive.":
      "No hay conexión con Google Drive, así que las copias solo se hacen en este Mac. Si esto no se resuelve solo en unos minutos, revisa la red y la conexión con Drive.",
    "There is no space left on Google Drive. This will NOT pass by itself — you need to free up space on Drive. Until then Time Machine is paused, so that it does not fill up this Mac's disk.":
      "No queda espacio en Google Drive. Esto NO se resolverá solo — tienes que liberar espacio en Drive. Hasta entonces Time Machine está en pausa para que no llene el disco de este Mac.",
    "%@ backup fragments could not be uploaded and rclone stopped trying. These fragments exist only on this Mac, so the backup on Drive is incomplete. This needs checking.":
      "%@ fragmentos de copia no se pudieron subir y rclone dejó de intentarlo. Estos fragmentos existen solo en este Mac, así que la copia en Drive está incompleta. Hay que revisarlo.",
    "Time Machine is writing faster than the upload goes, and the buffer has filled up. The backup will be paused until the upload catches up — this is a safeguard against filling up the disk, not a failure.":
      "Time Machine escribe más rápido de lo que sube, y el búfer se ha llenado. La copia se pausará hasta que la subida se ponga al día — es una protección para no llenar el disco, no un fallo.",
    "Google accepts 750 GB per day and that limit has been used up. There is nothing to do: the limit renews by itself, usually within a few hours. Time Machine backups are made normally in the meantime and wait in the buffer — they will be uploaded as soon as Google starts accepting again.":
      "Google acepta 750 GB al día y ese límite se ha agotado. No hay nada que hacer: el límite se renueva solo, normalmente en unas horas. Mientras tanto, las copias de Time Machine se hacen con normalidad y esperan en el búfer — se subirán en cuanto Google vuelva a aceptar.",
    "%@ backup fragments are queued and on their way to Drive.":
      "%@ fragmentos de copia están en cola y de camino a Drive.",
    "Nothing is waiting in the queue — the backup on Google Drive is complete.":
      "No hay nada en cola — la copia en Google Drive está completa.",
    "rclone did not answer the question about the queue, so it is unknown how many backups are still waiting to be uploaded. This does not mean something broke — under load the answer can be late. It only means that right now nobody knows. If it persists, the backup cycle check will report it.":
      "rclone no respondió a la consulta sobre la cola, así que se desconoce cuántas copias siguen esperando a subirse. Esto no significa que algo se haya roto — con carga la respuesta puede tardar. Solo significa que ahora mismo nadie lo sabe. Si persiste, la comprobación del ciclo de copias lo indicará.",
    "unknown error":
      "error desconocido",
    "rclone lsf ended with an error":
      "rclone lsf terminó con un error",
    "This Mac is close to its space limit on Google Drive":
      "Este Mac está cerca de su límite de espacio en Google Drive",
    "%@ GB of %@ GB used. Time Machine deletes the oldest backups to stay within its quota; check that the quota is set (vm-status).":
      "%@ GB de %@ GB usados. Time Machine elimina las copias más antiguas para no superar su cuota; comprueba que la cuota esté ajustada (vm-status).",
    "This Mac is over its space limit on Google Drive":
      "Este Mac ha superado su límite de espacio en Google Drive",
    "%@ GB of %@ GB used. Set the Time Machine quota (command in the app window or vm-status), or raise the limit.":
      "%@ GB de %@ GB usados. Ajusta la cuota de Time Machine (comando en la ventana de la app o en vm-status) o aumenta el límite.",
    "not set":
      "sin ajustar",
    "%@ GB - usage not measured yet":
      "%@ GB - uso aún sin medir",
    "%@ of %@ GB used (%@%%)":
      "%@ de %@ GB usados (%@%%)",
    "The limit must be a whole number of GB above zero.":
      "El límite debe ser un número entero de GB mayor que cero.",
    "machines.json cannot be read, so it was not overwritten. Fix or remove it first.":
      "No se puede leer machines.json, así que no se sobrescribió. Corrígelo o elimínalo primero.",
    "'%@' is not a valid folder name: use lowercase letters, digits and dashes.":
      "'%@' no es un nombre de carpeta válido: usa letras minúsculas, dígitos y guiones.",
    "This Mac already backs up to folder '%@'. Switching to '%@' would start a new, empty backup and orphan the existing one, so nothing was changed.":
      "Este Mac ya hace copias en la carpeta '%@'. Cambiar a '%@' iniciaría una copia nueva y vacía y dejaría huérfana la existente, así que no se cambió nada.",
    "This Mac already has a CloudMachine installation, whose backup is in folder '%@'. Switching to '%@' would orphan it, so nothing was changed.":
      "Este Mac ya tiene una instalación de CloudMachine, cuya copia está en la carpeta '%@'. Cambiar a '%@' la dejaría huérfana, así que no se cambió nada.",
    "Could not save the folder name to %@: %@":
      "No se pudo guardar el nombre de la carpeta en %@: %@",
    "Homebrew is not installed. Install it manually: https://brew.sh":
      "Homebrew no está instalado. Instálalo manualmente: https://brew.sh",
    "Installing rclone failed: %@":
      "Falló la instalación de rclone: %@",
    "Installed rclone.":
      "rclone instalado.",
    "Own Google credentials: set.":
      "Credenciales propias de Google: definidas.",
    "INCOMPLETE: %@ is missing - rclone will use rclone's shared client_id anyway.":
      "INCOMPLETO: falta %@ - rclone usará de todos modos el client_id compartido de rclone.",
    "No own credentials - rclone uses the shared client_id, rate-limited jointly and being retired in 2026.":
      "Sin credenciales propias - rclone usa el client_id compartido, con límite de uso conjunto y que se retirará en 2026.",
    "Empty value - not saving.":
      "Valor vacío - no se guarda.",
    "Keychain refused: %@":
      "El Llavero lo rechazó: %@",
    "DIRTY-TREE":
      "ÁRBOL-SUCIO",
    "Cannot create the working directory: %@":
      "No se puede crear el directorio de trabajo: %@",
    "Could not read the rclone version number.":
      "No se pudo leer el número de versión de rclone.",
    "Could not download %@.":
      "No se pudo descargar %@.",
    "No entry for %@ in SHA256SUMS.":
      "No hay ninguna entrada para %@ en SHA256SUMS.",
    "Could not compute the checksum.":
      "No se pudo calcular la suma de verificación.",
    "SHA256 checksum does not match - NOT installing.\n  expected: %@\n  computed: %@":
      "La suma de verificación SHA256 no coincide - NO se instala.\n  esperada: %@\n  calculada: %@",
    "Could not unpack the archive.":
      "No se pudo descomprimir el archivo.",
    "Could not install the binary: %@":
      "No se pudo instalar el binario: %@",
    "Installed rclone %@ in %@ (SHA256 checksum matches).":
      "rclone %@ instalado en %@ (la suma de verificación SHA256 coincide).",
    "%@ did not respond within the allotted time (the process was left orphaned in the background).":
      "%@ no respondió en el tiempo previsto (el proceso quedó huérfano en segundo plano).",
    "Cannot launch %@: %@":
      "No se puede iniciar %@: %@",
    "Remote '%@' already exists and was NOT touched.\nOverwriting it replaces the token and the permission scope; a credential with the 'drive.file' scope does not see files created by the previous one, so the existing backup becomes unreachable.\nIf you really want to replace it, first back up ~/.config/rclone/rclone.conf and run again with --replace-existing.":
      "El remote '%@' ya existe y NO se tocó.\nSobrescribirlo reemplaza el token y el alcance de permisos; una credencial con el alcance 'drive.file' no ve los archivos creados por la anterior, así que la copia existente quedaría inaccesible.\nSi de verdad quieres reemplazarlo, primero haz una copia de ~/.config/rclone/rclone.conf y ejecuta de nuevo con --replace-existing.",
    "Could not check whether remote '%@' already exists (rclone listremotes did not answer or failed), so nothing was changed. Run `%@ listremotes` to see the error, then try again.":
      "No se pudo comprobar si el remote '%@' ya existe (rclone listremotes no respondió o falló), así que no se cambió nada. Ejecuta `%@ listremotes` para ver el error y vuelve a intentarlo.",
    "Could not check whether this Mac already has a CloudMachine installation (rclone did not answer), so no folder was chosen. Try again in a moment.":
      "No se pudo comprobar si este Mac ya tiene una instalación de CloudMachine (rclone no respondió), así que no se eligió ninguna carpeta. Inténtalo de nuevo en un momento.",
    "rclone authorize failed (%@). If that binary is missing, start with: cloudmachine-agent install-rclone.":
      "rclone authorize falló (%@). Si falta ese binario, empieza con: cloudmachine-agent install-rclone.",
    "Could not read the token from the output of rclone authorize.":
      "No se pudo leer el token de la salida de rclone authorize.",
    "rclone config create failed.":
      "rclone config create falló.",
    "Connected to Google Drive as remote '%@', folder %@.":
      "Conectado a Google Drive como remote '%@', carpeta %@.",
    "tmutil is not responding - unknown where the backup goes":
      "tmutil no responde - se desconoce adónde va la copia",
    "No successful backup for %@":
      "Ninguna copia correcta desde hace %@",
    "Last COMPLETED backup: %@. The cycle is hourly, so that is %@ missed runs.":
      "Última copia COMPLETADA: %@. El ciclo es cada hora, así que son %@ ejecuciones perdidas.",
    "There is NOT A SINGLE successful backup":
      "NO HAY NINGUNA copia correcta",
    "The Time Machine preferences contain no date of a completed backup for this destination.":
      "Las preferencias de Time Machine no contienen la fecha de ninguna copia completada para este destino.",
    "The last backup attempt did not end in a backup":
      "El último intento de copia no terminó en una copia",
    "The attempt at %@ is newer than the last successful backup at %@.":
      "El intento de %@ es más reciente que la última copia correcta de %@.",
    "Time Machine reports an error in the last run (RESULT=%@)":
      "Time Machine informa de un error en la última ejecución (RESULT=%@)",
    "A non-zero RESULT in the Time Machine preferences means the run did not succeed.":
      "Un RESULT distinto de cero en las preferencias de Time Machine significa que la ejecución no tuvo éxito.",
    "rclone failed to upload %@ files":
      "rclone no pudo subir %@ archivos",
    "Buffer full of nothing but unsent data":
      "Búfer lleno solo de datos sin enviar",
    "rclone has nothing left to evict from the buffer - the upload cannot keep up or has stalled.":
      "rclone no tiene nada más que expulsar del búfer - la subida no puede seguir el ritmo o se ha atascado.",
    "The rclone control interface is not responding":
      "La interfaz de control de rclone no responde",
    "Google Drive is running out of space (%@ GB)":
      "A Google Drive le queda poco espacio (%@ GB)",
    "The Mac's disk is running out of space (%@ GB)":
      "Al disco del Mac le queda poco espacio (%@ GB)",
    "Cannot read the Time Machine preferences":
      "No se pueden leer las preferencias de Time Machine",
    "%@ is unreadable - most often Full Disk Access is missing. Without this file it is UNKNOWN when the last backup was made, so we treat it as a failure, not as the absence of a problem.":
      "%@ no se puede leer - lo más habitual es que falte el Acceso total al disco. Sin este archivo se DESCONOCE cuándo se hizo la última copia, así que lo tratamos como un fallo, no como ausencia de problema.",
    "Cannot measure free space on the Mac's disk":
      "No se puede medir el espacio libre en el disco del Mac",
    "%@ days":
      "%@ días",
    "CloudMachine: backup is not working":
      "CloudMachine: la copia no funciona",
    "unknown reason":
      "motivo desconocido",
    "osascript did not show the notification (permissions or no graphical session)":
      "osascript no mostró la notificación (permisos o sin sesión gráfica)",
    "UNDELIVERED ALARM: %@":
      "ALARMA SIN ENTREGAR: %@",
    "from %@, reason: %@":
      "de %@, motivo: %@",
    "The system notification was not delivered - you will see this alarm ONLY here.":
      "La notificación del sistema no se entregó - verás esta alarma SOLO aquí.",
    "%@ (%@ ago)":
      "%@ (hace %@)",
    "%@ - marker from the FUTURE":
      "%@ - marca del FUTURO",
    "%@ (%@ ago) - THE WATCHDOG MAY NOT BE RUNNING":
      "%@ (hace %@) - ES POSIBLE QUE EL SUPERVISOR NO ESTÉ EN MARCHA",
    "NEVER - the watchdog has not recorded a single run":
      "NUNCA - el supervisor no ha registrado ninguna ejecución",
    "Could not find the launchd/ directory with templates.":
      "No se encontró el directorio launchd/ con las plantillas.",
    "Could not find the compiled cloudmachine-agent binary.":
      "No se encontró el binario compilado de cloudmachine-agent.",
    "ABORTED: could not put cloudmachine-agent in a stable location\n(%@) - most often a lack of space or permissions.\nNOT installing agents pointing at %@: that path\ndisappears on the next `swift build` or `git clean`, and backups stop\nwithout any visible signal.":
      "ABORTADO: no se pudo colocar cloudmachine-agent en una ubicación estable\n(%@) - lo más habitual es falta de espacio o de permisos.\nNO se instalan agentes que apunten a %@: esa ruta\ndesaparece con el próximo `swift build` o `git clean`, y las copias se detienen\nsin ninguna señal visible.",
    "ABORTED: %@":
      "ABORTADO: %@",
    "Could not list the templates in %@.":
      "No se pudieron listar las plantillas en %@.",
    "could not read the template %@":
      "no se pudo leer la plantilla %@",
    "could not write %@ (lack of space or permissions)":
      "no se pudo escribir %@ (falta de espacio o de permisos)",
    "launchctl load refused to load %@":
      "launchctl load se negó a cargar %@",
    "NOT A SINGLE agent was loaded.":
      "NO se cargó NINGÚN agente.",
    "Only these went in: %@.":
      "Solo se instalaron estos: %@.",
    "Could not load any launchd agent.":
      "No se pudo cargar ningún agente de launchd.",
    "Installed agents: %@":
      "Agentes instalados: %@",
    "                  WARNING: close to the limit - new bands will fail with EMFILE":
      "                  ADVERTENCIA: cerca del límite - las bandas nuevas fallarán con EMFILE",
    "%@/bands on Google Drive is not empty - it may hold another backup. NOT overwriting it; check it by hand.":
      "%@/bands en Google Drive no está vacío - puede contener otra copia. NO se sobrescribe; compruébalo a mano.",
    "Address:          %@":
      "Dirección:        %@",
    "Already prepared (%@ exists) - nothing to do.":
      "Ya preparado (%@ existe) - no hay nada que hacer.",
    "Converts Time Machine's new, empty image in the machine to 32 MB bands and moves the bands to Google Drive.":
      "Convierte la imagen nueva y vacía de Time Machine en la máquina a bandas de 32 MB y las mueve a Google Drive.",
    "Copy rclone.conf into the machine even if it already has one.":
      "Copia rclone.conf en la máquina aunque ya tenga uno.",
    "Copying the converted image into the machine failed: %@":
      "Falló la copia de la imagen convertida en la máquina: %@",
    "Copying the image to the Mac failed: %@":
      "Falló la copia de la imagen al Mac: %@",
    "Could not ask Lima about the machine: %@":
      "No se pudo consultar a Lima sobre la máquina: %@",
    "Could not carry the Time Machine files over: %@":
      "No se pudieron trasladar los archivos de Time Machine: %@",
    "Could not check the image in the machine.":
      "No se pudo comprobar la imagen en la máquina.",
    "Could not copy the rclone configuration into the machine.":
      "No se pudo copiar la configuración de rclone en la máquina.",
    "Could not create %@ on Google Drive: %@":
      "No se pudo crear %@ en Google Drive: %@",
    "Could not create %@: %@":
      "No se pudo crear %@: %@",
    "Could not find the vm/ directory with the machine template.":
      "No se encontró el directorio vm/ con la plantilla de la máquina.",
    "Could not read the image size.":
      "No se pudo leer el tamaño de la imagen.",
    "Could not set the SMB password of user %@ in the machine.":
      "No se pudo establecer la contraseña SMB del usuario %@ en la máquina.",
    "Could not stop smbd in the machine.":
      "No se pudo detener smbd en la máquina.",
    "Could not write %@ in the machine.":
      "No se pudo escribir %@ en la máquina.",
    "Could not write the password file %@.":
      "No se pudo escribir el archivo de contraseña %@.",
    "Creates or starts the CloudMachine machine (Lima), gives it rclone's configuration and an SMB password, and prints the Time Machine command.":
      "Crea o inicia la máquina de CloudMachine (Lima), le da la configuración de rclone y una contraseña SMB, e imprime el comando de Time Machine.",
    "Creating the machine %@ (first start downloads Ubuntu and installs packages - several minutes)...":
      "Creando la máquina %@ (el primer inicio descarga Ubuntu e instala paquetes - varios minutos)...",
    "Done: %@ has %@ MB bands on Google Drive; the original is kept in %@ in the machine. Start the backup: tmutil startbackup":
      "Listo: %@ tiene bandas de %@ MB en Google Drive; el original se conserva en %@ en la máquina. Inicia la copia: tmutil startbackup",
    "exit code %@, no message":
      "código de salida %@, sin mensaje",
    "Image metadata:   NEVER copied to %@ - check tm-meta-sync in the machine":
      "Metadatos imagen: NUNCA copiados a %@ - comprueba tm-meta-sync en la máquina",
    "Image metadata:   copied %@ ago to %@":
      "Metadatos imagen: copiados hace %@ a %@",
    "Image metadata:   last copied %@ ago - OVERDUE (%@)":
      "Metadatos imagen: última copia hace %@ - RETRASADO (%@)",
    "Image metadata:   not copied yet - waits for vm-prepare-bundle":
      "Metadatos imagen: aún sin copiar - espera a vm-prepare-bundle",
    "Backup %@, paused by the guard %@: %@":
      "Copia %@, en pausa por el guardián %@: %@",
    "Free in machine:  %@ GiB":
      "Libre en máquina: %@ GiB",
    "fsck_apfs -n found problems: %@":
      "fsck_apfs -n encontró problemas: %@",
    "Google Drive folder: %@":
      "Carpeta de Google Drive: %@",
    "hdiutil attach of the converted image failed: %@":
      "Falló hdiutil attach de la imagen convertida: %@",
    "hdiutil convert failed: %@":
      "Falló hdiutil convert: %@",
    "Image name in the machine (default: from the computer name).":
      "Nombre de la imagen en la máquina (por defecto, derivado del nombre del ordenador).",
    "Installing the converted image FAILED: %@\nsmbd is left STOPPED so Time Machine does not open a half-installed image. The original is in %@ in the machine.":
      "FALLÓ la instalación de la imagen convertida: %@\nsmbd queda DETENIDO para que Time Machine no abra una imagen a medio instalar. El original está en %@ en la máquina.",
    "limactl create failed: %@":
      "limactl create falló: %@",
    "limactl list failed: %@":
      "limactl list falló: %@",
    "limactl not found - install Lima: brew install lima":
      "No se encontró limactl - instala Lima: brew install lima",
    "limactl start failed: %@\nThe machine's own log: %@":
      "limactl start falló: %@\nEl registro propio de la máquina: %@",
    "Machine %@ is running.":
      "La máquina %@ está en marcha.",
    "Machine %@ was already running.":
      "La máquina %@ ya estaba en marcha.",
    "Machine:          %@ (%@)":
      "Máquina:          %@ (%@)",
    "Machine:          %@":
      "Máquina:          %@",
    "Machine:          not created - run: cloudmachine-agent vm-setup":
      "Máquina:          sin crear - ejecuta: cloudmachine-agent vm-setup",
    "no answer within the time limit":
      "sin respuesta dentro del tiempo límite",
    "No image %@ in the machine.":
      "No hay imagen %@ en la máquina.",
    "No image in the machine yet - point Time Machine at the share and let it create one first.":
      "Aún no hay ninguna imagen en la máquina - apunta Time Machine al recurso compartido y deja que cree una primero.",
    "No rclone configuration at %@ - connect Google Drive first (configure-remote).":
      "No hay configuración de rclone en %@ - conecta primero Google Drive (configure-remote).",
    "no SMB destination":
      "sin destino SMB",
    "One check of the machine's upload buffer: pauses Time Machine when it fills, resumes what it paused.":
      "Una comprobación del búfer de subida de la máquina: pausa Time Machine cuando se llena y reanuda lo que pausó.",
    "Packing the converted image failed: %@":
      "Falló el empaquetado de la imagen convertida: %@",
    "Packing the image failed: %@":
      "Falló el empaquetado de la imagen: %@",
    "No answer from the machine (rclone rc) - the guard would do nothing.":
      "La máquina no responde (rclone rc) - el guardián no haría nada.",
    "Only print what the guard would decide - for trying thresholds on a throwaway machine.":
      "Solo imprime lo que decidiría el guardián - para probar umbrales en una máquina desechable.",
    "Pause above this many GiB in the buffer.":
      "Pausar por encima de esta cantidad de GiB en el búfer.",
    "Pause when the machine has less free than this, in GiB.":
      "Pausar cuando a la máquina le quede menos libre que esto, en GiB.",
    "Point Time Machine at the machine (once, needs an administrator password):":
      "Apunta Time Machine a la máquina (una sola vez, requiere una contraseña de administrador):",
    "punchfs files:    %@ open, limit %@":
      "Archivos punchfs: %@ abiertos, límite %@",
    "rclone configuration already in the machine - kept (--replace-rclone-config replaces it).":
      "La configuración de rclone ya está en la máquina - se conserva (--replace-rclone-config la reemplaza).",
    "rclone configuration copied into the machine.":
      "Configuración de rclone copiada en la máquina.",
    "rclone-tm or punchfs is not running in the machine - see cloudmachine-agent vm-status.":
      "rclone-tm o punchfs no está en marcha en la máquina - consulta cloudmachine-agent vm-status.",
    "Resume below this many GiB (only a backup the guard paused).":
      "Reanudar por debajo de esta cantidad de GiB (solo una copia que pausó el guardián).",
    "Service %@: %@":
      "Servicio %@: %@",
    "Several images in the machine (%@) - choose one with --bundle.":
      "Hay varias imágenes en la máquina (%@) - elige una con --bundle.",
    "Shows the machine: address, services, upload buffer, free space and the Time Machine destination.":
      "Muestra la máquina: dirección, servicios, búfer de subida, espacio libre y el destino de Time Machine.",
    "SMB password stored in %@ (mode 600).":
      "Contraseña SMB guardada en %@ (modo 600).",
    "The converted image does not have %@-byte bands.":
      "La imagen convertida no tiene bandas de %@ bytes.",
    "The converted image has no APFS partition.":
      "La imagen convertida no tiene partición APFS.",
    "The image already takes %@ MB - this command converts only a new, empty image (under %@ MB).":
      "La imagen ya ocupa %@ MB - este comando solo convierte una imagen nueva y vacía (de menos de %@ MB).",
    "The image is encrypted - converting encrypted images is not supported.":
      "La imagen está cifrada - no se admite convertir imágenes cifradas.",
    "The image was not changed; smbd started again.":
      "La imagen no se modificó; smbd se inició de nuevo.",
    "The machine does not answer - is it running? cloudmachine-agent vm-status":
      "La máquina no responde - ¿está en marcha? cloudmachine-agent vm-status",
    "The machine has no address on the vzNAT network.":
      "La máquina no tiene dirección en la red vzNAT.",
    "The services in the machine did not start - check: cloudmachine-agent vm-status":
      "Los servicios de la máquina no se iniciaron - comprueba: cloudmachine-agent vm-status",
    "Time Machine is backing up - stop it first: tmutil stopbackup":
      "Time Machine está haciendo una copia - deténla primero: tmutil stopbackup",
    "Time Machine:     %@":
      "Time Machine:     %@",
    "Time Machine:     NOT pointing at the machine (%@)":
      "Time Machine:     NO apunta a la máquina (%@)",
    "Time Machine:     tmutil did not answer":
      "Time Machine:     tmutil no respondió",
    "tmutil did not answer - not touching the image while its state is unknown.":
      "tmutil no respondió - no se toca la imagen mientras se desconozca su estado.",
    "unknown":
      "desconocido",
    "Unpacking the image failed: %@":
      "Falló la descompresión de la imagen: %@",
    "Still to upload:  %@ GiB in %@ bands, uploading %@ (cache on disk %@ GiB)":
      "Pendiente de subir: %@ GiB en %@ bandas, subiendo %@ (caché en disco %@ GiB)",
    "Excluded %@ (the machine and its upload buffer) from Time Machine.":
      "Se excluyó %@ (la máquina y su búfer de subida) de Time Machine.",
    "WARNING: could not exclude %@ from Time Machine - run: tmutil addexclusion %@":
      "ADVERTENCIA: no se pudo excluir %@ de Time Machine - ejecuta: tmutil addexclusion %@",
    "Upload buffer:    no answer from rclone (rc %@)":
      "Búfer de subida:  sin respuesta de rclone (rc %@)",
    "When Time Machine has created its empty image, stop the backup (tmutil stopbackup) and run: cloudmachine-agent vm-prepare-bundle":
      "Cuando Time Machine haya creado su imagen vacía, detén la copia (tmutil stopbackup) y ejecuta: cloudmachine-agent vm-prepare-bundle",
    "Unsent %@ GiB, free %@ GiB (pause above %@ GiB unsent or below %@ GiB free, resume below %@ GiB).":
      "Sin enviar %@ GiB, libres %@ GiB (pausa con más de %@ GiB sin enviar o menos de %@ GiB libres, reanuda por debajo de %@ GiB).",
    "Upload:           Google's daily limit refused an upload %@ ago - rclone retries every 5 min and resumes by itself":
      "Subida:           el límite diario de Google rechazó una subida hace %@ - rclone reintenta cada 5 min y se reanuda solo",
    "no":
      "no",
    "running":
      "en marcha",
    "stopped":
      "detenido",
    "yes":
      "sí",
    "%@\nThe previous template is in %@ - copy it back over lima.yaml and run limactl start %@.":
      "%@\nLa plantilla anterior está en %@ - cópiala de nuevo sobre lima.yaml y ejecuta limactl start %@.",
    "Could not read this app's machine template (limactl template copy).":
      "No se pudo leer la plantilla de máquina de esta app (limactl template copy).",
    "Could not replace %@: %@":
      "No se pudo reemplazar %@: %@",
    "Machine %@ already runs this app's template.":
      "La máquina %@ ya usa la plantilla de esta app.",
    "Machine %@ now runs this app's template; the previous one is in %@.":
      "La máquina %@ ahora usa la plantilla de esta app; la anterior está en %@.",
    "Moves the machine onto this app's template (two restarts, never during a backup).":
      "Pasa la máquina a la plantilla de esta app (dos reinicios, nunca durante una copia).",
    "No machine %@ - create it with: cloudmachine-agent vm-setup":
      "No existe la máquina %@ - créala con: cloudmachine-agent vm-setup",
    "Template:         OLDER than this app's - run: cloudmachine-agent vm-update":
      "Plantilla:        MÁS ANTIGUA que la de esta app - ejecuta: cloudmachine-agent vm-update",
    "Template:         not compared":
      "Plantilla:        sin comparar",
    "Template:         this app's":
      "Plantilla:        la de esta app",
    "The machine has no %@ - run cloudmachine-agent vm-setup first.":
      "La máquina no tiene %@ - ejecuta antes cloudmachine-agent vm-setup.",
    "The machine restarted, but not every service is running - check: cloudmachine-agent vm-status. The previous template is in %@.":
      "La máquina se reinició, pero no todos los servicios están en marcha - comprueba: cloudmachine-agent vm-status. La plantilla anterior está en %@.",
    "The template changes the machine itself (%@) - that needs a new machine, not an update.":
      "La plantilla cambia la propia máquina (%@) - eso requiere una máquina nueva, no una actualización.",
    "The upload to Google Drive hangs":
      "La subida a Google Drive está colgada",
    "Time Machine is backing up - try again when it has finished.":
      "Time Machine está haciendo una copia - inténtalo de nuevo cuando termine.",
    "Upload:           HANGS - bands in progress, none uploaded for %@ (network?); see /var/log/rclone-tm.log in the machine":
      "Subida:           COLGADA - bandas en curso, ninguna subida desde hace %@ (¿red?); consulta /var/log/rclone-tm.log en la máquina",
    "limactl stop failed - nothing was changed.":
      "limactl stop falló - no se cambió nada.",
    "rclone has bands in progress, but none has been uploaded for %@ - usually a broken network connection, which rclone does not report as an error. Backups since then are only in the machine's buffer. When the network comes back the upload resumes by itself (on 28.10.2026 within 80 s); if it does not, restarting the machine (prepare-shutdown, limactl start) drops the dead connections.":
      "rclone tiene bandas en curso, pero ninguna se ha subido desde hace %@ - normalmente una conexión de red rota, que rclone no notifica como error. Las copias desde entonces están solo en el búfer de la máquina. Cuando vuelva la red, la subida se reanuda sola (el 28.10.2026, en 80 s); si no, reiniciar la máquina (prepare-shutdown, limactl start) descarta las conexiones muertas.",
    "tmutil did not answer - not restarting the machine while its state is unknown.":
      "tmutil no respondió - no se reinicia la máquina mientras se desconozca su estado.",
  ]
}
