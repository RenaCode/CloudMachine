// Brazilian Portuguese translations, keyed by the English text passed to `L10n.tr`.
extension L10nTranslations {
  static let ptBR: [String: String] = [
    "Space limit:      %@":
      "Limite de espaço: %@",
    "                  Time Machine quota not set to match - run: %@":
      "                  A cota do Time Machine não corresponde - execute: %@",
    "Sets how much of Google Drive this Mac may use, and prints the Time Machine quota command.":
      "Define quanto do Google Drive este Mac pode usar e imprime o comando da cota do Time Machine.",
    "Limit in GB.":
      "Limite em GB.",
    "Limit for this Mac: %@ GB.":
      "Limite para este Mac: %@ GB.",
    "Now set the Time Machine quota (needs an administrator password):":
      "Agora defina a cota do Time Machine (requer senha de administrador):",
    "CloudMachine - verification, Google Drive setup and installation. Called by launchd on a schedule, or by hand from Terminal.":
      "CloudMachine - verificação, configuração do Google Drive e instalação. Chamado pelo launchd em horários programados ou manualmente no Terminal.",
    "Connects to Google Drive through rclone (OAuth in the browser) and creates this machine's folder.":
      "Conecta ao Google Drive por meio do rclone (OAuth no navegador) e cria a pasta desta máquina.",
    "Overwrite the existing remote. RISKY: replaces the token and permissions.":
      "Sobrescreve o remote existente. ARRISCADO: substitui o token e as permissões.",
    "Packs build/CloudMachine.app into build/CloudMachine-<version>.dmg.":
      "Empacota build/CloudMachine.app em build/CloudMachine-<version>.dmg.",
    "ERROR: %@ is missing - run 'cloudmachine-agent build-app' first":
      "ERRO: %@ não existe - execute antes 'cloudmachine-agent build-app'",
    "==> Preparing the staging folder":
      "==> Preparando a pasta temporária",
    "==> Creating %@":
      "==> Criando %@",
    "ERROR: hdiutil exited with code %@.":
      "ERRO: hdiutil terminou com o código %@.",
    "==> Done: %@":
      "==> Concluído: %@",
    "On first launch (the app is not signed with an Apple Developer account):":
      "Na primeira abertura (o app não é assinado com uma conta Apple Developer):",
    "1. Open %@ and drag CloudMachine.app to Applications.":
      "1. Abra %@ e arraste CloudMachine.app para a pasta Aplicativos.",
    "2. In Finder, RIGHT-click CloudMachine.app -> Open -> Open\n   (a plain double-click shows the Gatekeeper block \"unidentified developer\").":
      "2. No Finder, clique com o botão DIREITO em CloudMachine.app -> Abrir -> Abrir\n   (um clique duplo simples mostra o bloqueio do Gatekeeper \"desenvolvedor não identificado\").",
    "3. Later launches work normally, with a double-click.":
      "3. As próximas aberturas funcionam normalmente, com clique duplo.",
    "Builds CloudMachine.app (Release) - GUI + cloudmachine-agent in Contents/MacOS/, plus launchd/, vm/ and config/ as Resources.":
      "Compila CloudMachine.app (Release) - interface + cloudmachine-agent em Contents/MacOS/, além de launchd/, vm/ e config/ como Resources.",
    "Binaries for Apple Silicon and Intel at once (how CI builds a release; unnecessary locally).":
      "Binários para Apple Silicon e Intel ao mesmo tempo (como o CI compila uma versão; desnecessário localmente).",
    "==> Building CloudMachineApp + cloudmachine-agent (release) - version %@ (%@)":
      "==> Compilando CloudMachineApp + cloudmachine-agent (release) - versão %@ (%@)",
    "ERROR: swift build exited with code %@.":
      "ERRO: swift build terminou com o código %@.",
    "ERROR: swift build --show-bin-path did not report the binaries directory.":
      "ERRO: swift build --show-bin-path não informou o diretório dos binários.",
    "ERROR: no built binary found at %@":
      "ERRO: nenhum binário compilado encontrado em %@",
    "==> Assembling the .app bundle in %@":
      "==> Montando o pacote .app em %@",
    "==> WARNING: you are building from a DIRTY tree - the version will not point to a commit.":
      "==> AVISO: você está compilando a partir de uma árvore SUJA - a versão não apontará para um commit.",
    "ERROR: Resources/AppIcon.icns is missing - generate it: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns":
      "ERRO: Resources/AppIcon.icns não existe - gere-o: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns",
    "==> Signing with the local certificate '%@' (Full Disk Access will survive later rebuilds)":
      "==> Assinando com o certificado local '%@' (o Acesso Total ao Disco será mantido nas próximas compilações)",
    "==> Signing ad-hoc (no Apple Developer account) - run 'cloudmachine-agent setup-signing-cert' once so that TCC permissions survive later rebuilds":
      "==> Assinando ad hoc (sem conta Apple Developer) - execute uma vez 'cloudmachine-agent setup-signing-cert' para que as permissões do TCC sejam mantidas nas próximas compilações",
    "ERROR: codesign exited with code %@.":
      "ERRO: codesign terminou com o código %@.",
    "Next step: %@":
      "Próximo passo: %@",
    "Creates a local self-signed certificate so that Full Disk Access survives later rebuilds of the app.":
      "Cria um certificado local autoassinado para que o Acesso Total ao Disco seja mantido ao recompilar o app.",
    "Certificate '%@' already exists in %@, nothing to do.":
      "O certificado '%@' já existe em %@, nada a fazer.",
    "==> Generating the key and self-signed certificate '%@'...":
      "==> Gerando a chave e o certificado autoassinado '%@'...",
    "ERROR: openssl req exited with code %@.":
      "ERRO: openssl req terminou com o código %@.",
    "ERROR: openssl pkcs12 exited with code %@.":
      "ERRO: openssl pkcs12 terminou com o código %@.",
    "==> Importing the certificate into %@ (pre-authorizing /usr/bin/codesign, so it does not ask for the keychain password every time)...":
      "==> Importando o certificado em %@ (com pré-autorização de /usr/bin/codesign, para que não peça a senha do chaveiro toda vez)...",
    "ERROR: security import exited with code %@.":
      "ERRO: security import terminou com o código %@.",
    "==> Trusting the certificate ONLY for code signing...":
      "==> Confiando no certificado SOMENTE para assinatura de código...",
    "ERROR: security add-trusted-cert exited with code %@.":
      "ERRO: security add-trusted-cert terminou com o código %@.",
    "Done. Certificate '%@' is now available to codesign.":
      "Pronto. O certificado '%@' agora está disponível para o codesign.",
    "The next 'cloudmachine-agent build-app' will use it automatically instead of an ad-hoc signature.":
      "O próximo 'cloudmachine-agent build-app' vai usá-lo automaticamente em vez de uma assinatura ad hoc.",
    "After THAT ONE rebuild, grant Full Disk Access one last time - later\nrebuilds will no longer reset it, as long as you sign with the same certificate.":
      "Depois DESSA ÚNICA recompilação, conceda o Acesso Total ao Disco mais uma vez - as\nrecompilações seguintes não vão mais redefini-lo, desde que você assine com o mesmo certificado.",
    "Checks whether the hourly cycle STILL works (date of the last SUCCESSFUL backup) and reports failures.":
      "Verifica se o ciclo de hora em hora AINDA funciona (data do último backup BEM-SUCEDIDO) e relata falhas.",
    "After this many hours without a successful backup we consider the cycle broken.":
      "Depois de tantas horas sem um backup bem-sucedido, consideramos o ciclo quebrado.",
    "Only print the state, without a system notification.":
      "Apenas mostra o estado, sem notificação do sistema.",
    "A different Time Machine preferences file - to test the watchdog on a known sample.":
      "Outro arquivo de preferências do Time Machine - para testar o supervisor com uma amostra conhecida.",
    "Last successful backup: %@":
      "Último backup bem-sucedido: %@",
    "Last successful backup: NONE":
      "Último backup bem-sucedido: NENHUM",
    "Last attempt:           %@":
      "Última tentativa:       %@",
    "WAITING (system startup): %@":
      "AGUARDANDO (inicialização do sistema): %@",
    "Backup cycle: OK":
      "Ciclo de backup: OK",
    "FAILURE: %@":
      "FALHA: %@",
    "         %@":
      "         %@",
    "Check the state:  %@":
      "Verificar o estado: %@",
    "Preparing for restart":
      "Preparando para reiniciar",
    "Prepare for restart":
      "Preparar para reiniciar",
    "Prepare":
      "Preparar",
    "==> WARNING: git rev-list failed (%@) - using the date as the build number.":
      "==> AVISO: git rev-list falhou (%@) - usando a data como número da compilação.",
    "Agents:           %@":
      "Agentes:          %@",
    "CANNOT START: %@ - open CloudMachine or run backup-health to reload them":
      "NÃO CONSEGUEM INICIAR: %@ - abra o CloudMachine ou execute backup-health para recarregá-los",
    "Reloaded agents that could not start: %@":
      "Agentes recarregados que não conseguiam iniciar: %@",
    "Drive folder:     %@":
      "Pasta no Drive:   %@",
    "Name of this Mac's folder on Google Drive (default: derived from the computer name). Set once; it cannot be changed later.":
      "Nome da pasta deste Mac no Google Drive (padrão: derivado do nome do computador). Definido uma só vez; não pode ser alterado depois.",
    "Backup watchdog:  %@":
      "Supervisor de backup: %@",
    "Prints the version, the build number and the commit this binary was built from.":
      "Imprime a versão, o número da compilação e o commit a partir do qual este binário foi compilado.",
    "Only one line, without a description.":
      "Apenas uma linha, sem descrição.",
    "Build from the working tree (outside a bundle) - no version data.":
      "Compilação a partir da árvore de trabalho (fora de um pacote) - sem dados de versão.",
    "Version: %@":
      "Versão: %@",
    "Build:   %@":
      "Compilação: %@",
    "Commit:  %@":
      "Commit: %@",
    "WARNING: built from a DIRTY tree - the binary contains code that\n         is in no commit. The commit number does NOT describe\n         what actually runs.":
      "AVISO: compilado a partir de uma árvore SUJA - o binário contém código que\n         não está em nenhum commit. O número do commit NÃO descreve\n         o que realmente está em execução.",
    "Saving the space limit":
      "Salvando o limite de espaço",
    "Measuring usage on Google Drive":
      "Medindo o uso no Google Drive",
    "Google Drive did not answer - try again later.":
      "O Google Drive não respondeu - tente novamente mais tarde.",
    "Measured.":
      "Medido.",
    "Space limit for this Mac":
      "Limite de espaço para este Mac",
    "Used on Google Drive":
      "Usado no Google Drive",
    "Measured %@. The watchdog measures again every few hours.":
      "Medido %@. O supervisor mede novamente a cada poucas horas.",
    "Limit (GB)":
      "Limite (GB)",
    "Save":
      "Salvar",
    "Measure now":
      "Medir agora",
    "Time Machine quota: %@ GB (70%% of the limit - the copy on Drive is about a third larger than the backup inside it). Time Machine deletes the oldest backups to stay within it.":
      "Cota do Time Machine: %@ GB (70%% do limite - a cópia no Drive é cerca de um terço maior que o backup que ela contém). O Time Machine apaga os backups mais antigos para ficar dentro dela.",
    "Set the Time Machine quota: run this in Terminal (needs sudo)":
      "Defina a cota do Time Machine: execute isto no Terminal (requer sudo)",
    "Connect Google Drive: run this in Terminal and approve in the browser":
      "Conecte o Google Drive: execute isto no Terminal e aprove no navegador",
    "Grant Full Disk Access to CloudMachine, so it can tell whether backups complete":
      "Conceda ao CloudMachine o Acesso Total ao Disco, para que ele possa saber se os backups são concluídos",
    "Folder on Google Drive":
      "Pasta no Google Drive",
    "One folder per Mac. Set once - it cannot be changed after connecting.":
      "Uma pasta por Mac. Definida uma só vez - não pode ser alterada após a conexão.",
    "Use lowercase letters, digits and dashes.":
      "Use letras minúsculas, dígitos e hifens.",
    "Install rclone":
      "Instalar rclone",
    "Open System Settings":
      "Abrir Ajustes do Sistema",
    "Install agents":
      "Instalar agentes",
    "not checked":
      "não verificado",
    "none at all":
      "nenhum",
    "%@ ago":
      "há %@",
    "Missing: %@":
      "Ausente: %@",
    "Google Drive not connected":
      "Google Drive não conectado",
    "Time Machine does not point to CloudMachine":
      "O Time Machine não aponta para o CloudMachine",
    "UNKNOWN whether Time Machine points to CloudMachine - tmutil did not answer":
      "NÃO SE SABE se o Time Machine aponta para o CloudMachine - o tmutil não respondeu",
    "Backup in progress":
      "Backup em andamento",
    "Unknown when the last backup was made":
      "Não se sabe quando foi feito o último backup",
    "There is no completed backup at all":
      "Não há nenhum backup concluído",
    "No completed backup for %@":
      "Nenhum backup concluído há %@",
    "Ready":
      "Pronto",
    "Not saved: %@":
      "Não salvo: %@",
    "Installing rclone":
      "Instalando rclone",
    "Installing launchd agents":
      "Instalando agentes do launchd",
    "Starting backup":
      "Iniciando o backup",
    "Backup started.":
      "Backup iniciado.",
    "Could not start the backup.":
      "Não foi possível iniciar o backup.",
    "Stopping backup":
      "Parando o backup",
    "Backup stopped.":
      "Backup parado.",
    "Could not stop the backup.":
      "Não foi possível parar o backup.",
    "Could not prepare the AppleScript.":
      "Não foi possível preparar o AppleScript.",
    "Unknown authorization error.":
      "Erro de autorização desconhecido.",
    "Waiting to upload":
      "Aguardando envio",
    "%@ files":
      "%@ arquivos",
    "nothing":
      "nada",
    "Back up now":
      "Fazer backup agora",
    "Stop backup":
      "Parar backup",
    "Open CloudMachine":
      "Abrir o CloudMachine",
    "Quit":
      "Sair",
    "Healthy":
      "Em ordem",
    "Attention":
      "Atenção",
    "Refreshed %@":
      "Atualizado %@",
    "System Status":
      "Status do sistema",
    "Action needed":
      "Ação necessária",
    "not measured":
      "não medido",
    "rclone did not answer":
      "O rclone não respondeu",
    "Backup in Progress":
      "Backup em andamento",
    "Files processed":
      "Arquivos processados",
    "Write speed":
      "Velocidade de gravação",
    "Operation phase":
      "Fase da operação",
    "Required Setup Steps":
      "Etapas de configuração necessárias",
    "Copy":
      "Copiar",
    "Last completed backup":
      "Último backup concluído",
    "Last backup watchdog run":
      "Última execução do supervisor de backup",
    "not read":
      "não lido",
    "Everything uploaded":
      "Tudo enviado",
    "File upload errors":
      "Erros no envio de arquivos",
    "Google Drive Credentials (OAuth 2.0)":
      "Credenciais do Google Drive (OAuth 2.0)",
    "Keychain OK":
      "Chaveiro OK",
    "No custom keys":
      "Sem chaves próprias",
    "Paste client_id...":
      "Cole o client_id...",
    "Paste client_secret...":
      "Cole o client_secret...",
    "Save securely in the Keychain":
      "Salvar com segurança no Chaveiro",
    "Refresh":
      "Atualizar",
    "Overview":
      "Visão geral",
    "Backups":
      "Backups",
    "Storage":
      "Armazenamento",
    "Settings":
      "Ajustes",
    "Current status: %@":
      "Status atual: %@",
    "Does not point to CloudMachine":
      "Não aponta para o CloudMachine",
    "tmutil did not answer":
      "O tmutil não respondeu",
    "Backing up: %@ of %@":
      "Fazendo backup: %@ de %@",
    "%@ of %@":
      "%@ de %@",
    "Copied":
      "Copiado",
    "No backup is running":
      "Nenhum backup em andamento",
    "Time Machine starts the next one on its own schedule.":
      "O Time Machine inicia o próximo conforme o próprio cronograma.",
    "Backup cycle":
      "Ciclo de backup",
    "%@ GiB":
      "%@ GiB",
    "%@ GiB in %@ bands, %@ uploading":
      "%@ GiB em %@ bandas, %@ em envio",
    "%@ bands":
      "%@ bandas",
    "%@ fragments abandoned - only in the machine":
      "%@ fragmentos abandonados - só na máquina",
    "127.0.0.1:5572 answers on the Mac: Lima forwards the machine's rclone remote control, which has no password. Any web page open in a browser can send it commands - including deleting the backup on Google Drive. Add the portForwards rule from vm/cmsmb.yaml to the machine and restart it (see vm/README.md).":
      "127.0.0.1:5572 responde no Mac: o Lima encaminha o controle remoto do rclone da máquina, que não tem senha. Qualquer página web aberta em um navegador pode enviar comandos a ele, inclusive apagar o backup no Google Drive. Adicione à máquina a regra portForwards de vm/cmsmb.yaml e reinicie-a (veja vm/README.md).",
    "A service in the CloudMachine machine is not running":
      "Um serviço da máquina do CloudMachine não está em execução",
    "Address":
      "Endereço",
    "Agent installation INCOMPLETE - %@ of %@ did not go in:\n%@\n%@\nEvery missing agent is a function that has silently stopped working (vm-guard watches the machine's buffer, backup-health reports failures). Fix the cause and repeat the installation.":
      "Instalação dos agentes INCOMPLETA - %@ de %@ não foram instalados:\n%@\n%@\nCada agente ausente é uma função que parou de funcionar silenciosamente (vm-guard vigia o buffer da máquina, backup-health relata as falhas). Corrija a causa e repita a instalação.",
    "All running":
      "Tudo em execução",
    "Also install the launchd agents (same as install-launchd).":
      "Instala também os agentes do launchd (igual a install-launchd).",
    "At most this many minutes of waiting for the upload.":
      "No máximo esta quantidade de minutos de espera pelo envio.",
    "At the limit every new band fails with EMFILE and the backup stops. Check: cloudmachine-agent vm-status":
      "No limite, cada banda nova falha com EMFILE e o backup para. Verifique: cloudmachine-agent vm-status",
    "Cache on the machine's disk":
      "Cache no disco da máquina",
    "Connected to Google Drive, but could not create the folder '%@' - without it the machine has nowhere to keep the backup. Check the account permissions and try again.":
      "Conectado ao Google Drive, mas não foi possível criar a pasta '%@' - sem ela a máquina não tem onde guardar o backup. Verifique as permissões da conta e tente novamente.",
    "Convert the image":
      "Converter a imagem",
    "Converting the image to 32 MB bands":
      "Convertendo a imagem em bandas de 32 MB",
    "Could not check with the current connection whether the backup is on Google Drive (%@), so remote '%@' was NOT replaced: without that answer the new sign-in cannot be checked against it.":
      "Não foi possível verificar, com a conexão atual, se o backup está no Google Drive (%@), então o remote '%@' NÃO foi substituído: sem essa resposta, o novo login não pode ser conferido.",
    "Downloads the official rclone binary into ~/.cloudmachine/bin (Google sign-in and the machine's rclone.conf).":
      "Baixa o binário oficial do rclone para ~/.cloudmachine/bin (login do Google e rclone.conf da máquina).",
    "Free in the machine":
      "Livre na máquina",
    "Free in the machine: %@":
      "Livre na máquina: %@",
    "Generates and installs the launchd agents (app, backup watchdog, machine start, machine guard).":
      "Gera e instala os agentes do launchd (app, supervisor de backup, inicialização da máquina, guardião da máquina).",
    "Install Lima, which runs the CloudMachine machine: run this in Terminal":
      "Instale o Lima, que executa a máquina do CloudMachine: execute isto no Terminal",
    "Install rclone (signs in to Google Drive for the machine)":
      "Instalar rclone (faz login no Google Drive para a máquina)",
    "Install the background agents (machine start, buffer guard, backup watchdog)":
      "Instalar os agentes em segundo plano (inicialização da máquina, guardião do buffer, supervisor de backup)",
    "Installs rclone through Homebrew - CloudMachine itself uses the one from install-rclone.":
      "Instala o rclone pelo Homebrew - o CloudMachine usa o de install-rclone.",
    "Info.plist, token and mapped/ of the backup image exist only on the machine's disk; without them the bands in %@ cannot be restored. The copy (tm-meta-sync, every 15 min) goes to %@. Check: cloudmachine-agent vm-status, then in the machine: journalctl -u tm-meta-sync":
      "Info.plist, token e mapped/ da imagem de backup existem apenas no disco da máquina; sem eles, as bandas em %@ não podem ser restauradas. A cópia (tm-meta-sync, a cada 15 min) vai para %@. Verifique: cloudmachine-agent vm-status e, na máquina: journalctl -u tm-meta-sync",
    "Lima says the machine is running, but a command in it did not return. Without it nothing is known about Samba, rclone or the upload. Check: cloudmachine-agent vm-status":
      "O Lima diz que a máquina está em execução, mas um comando nela não retornou. Sem ele, nada se sabe sobre Samba, rclone ou o envio. Verifique: cloudmachine-agent vm-status",
    "Machine":
      "Máquina",
    "Machine %@":
      "Máquina %@",
    "Machine & Upload Status":
      "Status da máquina e do envio",
    "Machine buffer":
      "Buffer da máquina",
    "No Time Machine destination is the machine's share (smb://tm@<address>/CloudMachine) - backups are not being made there. The command is printed by: cloudmachine-agent vm-setup":
      "Nenhum destino do Time Machine é o compartilhamento da máquina (smb://tm@<address>/CloudMachine) - os backups não estão sendo feitos lá. O comando é impresso por: cloudmachine-agent vm-setup",
    "Not running: %@":
      "Não está em execução: %@",
    "Not set up":
      "Não configurada",
    "Once it runs out, rclone stops uploading, the machine's buffer fills up and backups stop being made. At a growth of ~600 MB per hourly cycle that is about %@ days.":
      "Quando acabar, o rclone para de enviar, o buffer da máquina enche e os backups deixam de ser feitos. Com um crescimento de ~600 MB por ciclo de hora em hora, isso dá cerca de %@ dias.",
    "Or rclone.conf is missing: this Mac has already set up the CloudMachine machine, so it is not connected anew blindly. Restore the file from a backup (the machine keeps its own copy in %@). To connect anyway, create an empty file at the path `%@ config file` prints and run again - the existing folder is kept.":
      "Ou o rclone.conf está ausente: este Mac já configurou a máquina do CloudMachine, então não se conecta de novo às cegas. Restaure o arquivo de um backup (a máquina guarda uma cópia própria em %@). Para conectar mesmo assim, crie um arquivo vazio no caminho que `%@ config file` imprime e execute de novo - a pasta existente é mantida.",
    "Point Time Machine at the machine: run this in Terminal (needs sudo; Copy includes the password)":
      "Aponte o Time Machine para a máquina: execute isto no Terminal (requer sudo; Copiar inclui a senha)",
    "Points to the machine":
      "Aponta para a máquina",
    "Prepares for a restart: stops the backup, waits a while for the upload, then stops the machine cleanly.":
      "Prepara para reiniciar: para o backup, espera um pouco pelo envio e depois desliga a máquina de forma limpa.",
    "Reading the Time Machine destination did not return within %@ s. That is how tmutil behaves when its destination hangs.":
      "A leitura do destino do Time Machine não retornou em %@ s. É assim que o tmutil se comporta quando o destino trava.",
    "Remote '%@' was NOT replaced. The new sign-in gets the 'drive.file' scope, which sees only files created under its own client_id. The existing backup was most likely created by the current connection and would become invisible to it. Before anything is written, the new token is checked against the existing backup, and the replacement is abandoned if it cannot see it. The machine keeps its own copy of the configuration until vm-setup --replace-rclone-config. To go ahead, run again with --replace-existing --accept-scope-change.":
      "O remote '%@' NÃO foi substituído. O novo login recebe o escopo 'drive.file', que só enxerga arquivos criados sob o próprio client_id. O backup existente provavelmente foi criado pela conexão atual e ficaria invisível para ela. Antes de gravar qualquer coisa, o novo token é conferido com o backup existente, e a substituição é abandonada se ele não o enxergar. A máquina mantém uma cópia própria da configuração até vm-setup --replace-rclone-config. Para prosseguir, execute de novo com --replace-existing --accept-scope-change.",
    "Remote control:   OPEN on the Mac at 127.0.0.1:5572 - any web page can send rclone commands; see vm/README.md (portForwards)":
      "Controle remoto:  ABERTO no Mac em 127.0.0.1:5572 - qualquer página web pode enviar comandos ao rclone; veja vm/README.md (portForwards)",
    "Running":
      "Em execução",
    "Samba, rclone or punchfs in the machine is not active, so Time Machine has nowhere to write or the bands do not reach Google Drive. Check: cloudmachine-agent vm-status":
      "Samba, rclone ou punchfs na máquina não está ativo, então o Time Machine não tem onde gravar ou as bandas não chegam ao Google Drive. Verifique: cloudmachine-agent vm-status",
    "Service %@":
      "Serviço %@",
    "Services":
      "Serviços",
    "Set up the CloudMachine machine (the first time it downloads Ubuntu - several minutes)":
      "Configurar a máquina do CloudMachine (na primeira vez baixa o Ubuntu - vários minutos)",
    "Set up the CloudMachine machine again, so it prints the Time Machine command":
      "Configurar a máquina do CloudMachine de novo, para que imprima o comando do Time Machine",
    "Set up the machine":
      "Configurar a máquina",
    "Setting up the CloudMachine machine":
      "Configurando a máquina do CloudMachine",
    "Start the CloudMachine machine":
      "Iniciar a máquina do CloudMachine",
    "Start the machine":
      "Iniciar a máquina",
    "Starting the CloudMachine machine":
      "Iniciando a máquina do CloudMachine",
    "Still to upload: %@ GiB":
      "Ainda para enviar: %@ GiB",
    "Stopping the Time Machine backup...":
      "Parando o backup do Time Machine...",
    "Stopping the machine %@...":
      "Parando a máquina %@...",
    "The CloudMachine machine does not answer":
      "A máquina do CloudMachine não responde",
    "The CloudMachine machine is not running":
      "A máquina do CloudMachine não está em execução",
    "The CloudMachine machine is not set up yet":
      "A máquina do CloudMachine ainda não foi configurada",
    "The CloudMachine machine is stopped":
      "A máquina do CloudMachine está parada",
    "The backup is stopped, the upload gets up to 30 minutes, then the machine shuts down cleanly. It starts again at the next login.":
      "O backup é parado, o envio tem até 30 minutos e depois a máquina é desligada de forma limpa. Ela volta a iniciar no próximo login.",
    "The machine %@ is not running - nothing to prepare.":
      "A máquina %@ não está em execução - nada a preparar.",
    "The machine is stopped and everything reached Google Drive. The Mac can be restarted; the machine starts again at login.":
      "A máquina está parada e tudo chegou ao Google Drive. O Mac pode ser reiniciado; a máquina inicia de novo no login.",
    "The machine is stopped. %@ GiB had not reached Google Drive yet - it is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "A máquina está parada. %@ GiB ainda não tinham chegado ao Google Drive - ficam guardados no buffer da máquina e serão enviados após a próxima inicialização. O Mac pode ser reiniciado.",
    "The machine is stopped. rclone did not say how much was still to upload; what was not uploaded is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "A máquina está parada. O rclone não informou quanto ainda faltava enviar; o que não foi enviado fica guardado no buffer da máquina e será enviado após a próxima inicialização. O Mac pode ser reiniciado.",
    "The machine's disk is a file on this disk and grows as the upload buffer fills. With no space left the machine cannot write the buffer, and Time Machine's local snapshots have nowhere to go either.":
      "O disco da máquina é um arquivo neste disco e cresce conforme o buffer de envio enche. Sem espaço livre, a máquina não consegue gravar o buffer, e os snapshots locais do Time Machine também não têm para onde ir.",
    "The image's metadata has never been copied to Drive":
      "Os metadados da imagem nunca foram copiados para o Drive",
    "The image's metadata was last copied to Drive %@ ago":
      "Os metadados da imagem foram copiados para o Drive pela última vez há %@",
    "The machine's disk is running out of space (%@ GB)":
      "O disco da máquina está ficando sem espaço (%@ GB)",
    "The new sign-in does NOT see the existing backup (%@), so remote '%@' was NOT replaced and rclone.conf is unchanged. Keep the current connection, or sign in with the credential (client_id) that created the backup.":
      "O novo login NÃO enxerga o backup existente (%@), então o remote '%@' NÃO foi substituído e o rclone.conf não mudou. Mantenha a conexão atual ou faça login com a credencial (client_id) que criou o backup.",
    "The upload buffer lives on this disk. The guard pauses Time Machine before it fills; if the upload does not catch up, backups stay paused.":
      "O buffer de envio fica neste disco. O guardião pausa o Time Machine antes que ele encha; se o envio não alcançar, os backups continuam pausados.",
    "These bands exist only in the machine's buffer. The backup on Google Drive is INCOMPLETE and may not open.":
      "Estas bandas existem apenas no buffer da máquina. O backup no Google Drive está INCOMPLETO e pode não abrir.",
    "Time Machine backs up to the machine, so without it no backup is made. Start it: limactl start %@ (or the Start button in the app).":
      "O Time Machine faz backup na máquina, então sem ela nenhum backup é feito. Inicie a máquina: limactl start %@ (ou o botão \"Iniciar a máquina\" no app).",
    "Time Machine did not stop its backup within 2 minutes (or tmutil did not answer) - the machine was NOT stopped. Try again in a moment.":
      "O Time Machine não parou o backup em 2 minutos (ou o tmutil não respondeu) - a máquina NÃO foi parada. Tente de novo daqui a pouco.",
    "Time Machine has created its image: stop the backup, then convert the image to 32 MB bands":
      "O Time Machine criou a imagem: pare o backup e converta a imagem em bandas de 32 MB",
    "To upload":
      "Para enviar",
    "Unknown whether the CloudMachine machine is running":
      "Não se sabe se a máquina do CloudMachine está em execução",
    "Waiting for the upload to Google Drive (at most %@ min)...":
      "Aguardando o envio para o Google Drive (no máximo %@ min)...",
    "With --replace-existing: confirms that the new sign-in (scope 'drive.file') may not see the existing backup. The new token is still checked against the backup first.":
      "Com --replace-existing: confirma que o novo login (escopo 'drive.file') pode não enxergar o backup existente. O novo token ainda é conferido antes com o backup.",
    "Without it there is no way to check whether anything reached the Drive - the machine's guard is blind then.":
      "Sem ele não há como verificar se algo chegou ao Drive - o guardião da máquina fica cego.",
    "limactl did not answer":
      "O limactl não respondeu",
    "limactl did not answer (or is not installed). That does not mean the machine is down - it means nobody has checked.":
      "O limactl não respondeu (ou não está instalado). Isso não significa que a máquina esteja parada - significa que ninguém verificou.",
    "limactl start failed: %@":
      "limactl start falhou: %@",
    "limactl stop failed: %@":
      "limactl stop falhou: %@",
    "punchfs is close to its open-file limit":
      "O punchfs está perto do limite de arquivos abertos",
    "punchfs open files":
      "Arquivos abertos do punchfs",
    "rclone's remote control is open on this Mac":
      "O controle remoto do rclone está aberto neste Mac",
    "statfs('/System/Volumes/Data') returned an error, so nobody knows whether the machine's disk can still grow on this Mac.":
      "statfs('/System/Volumes/Data') retornou um erro, então não se sabe se o disco da máquina ainda pode crescer neste Mac.",
    "Google Drive's daily upload limit stops the upload":
      "O limite diário de envio do Google Drive interrompe o envio",
    "Google last refused an upload %@ ago (750 GB a day). Backups since then are only in the machine's buffer on this Mac. rclone retries every 5 min and resumes by itself when the limit passes; the guard pauses Time Machine if more than %@ GiB waits.":
      "O Google recusou um envio pela última vez há %@ (750 GB por dia). Os backups desde então estão apenas no buffer da máquina neste Mac. O rclone tenta de novo a cada 5 min e retoma sozinho quando o limite passa; o guardião pausa o Time Machine se mais de %@ GiB estiverem esperando.",
    "Usage on Google Drive is not being measured":
      "O uso do Google Drive não está sendo medido",
    "The last measurement (%@ GB) is from %@, %@ ago - rclone size has not answered since. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "A última medição (%@ GB) é de %@, há %@ - o rclone size não respondeu desde então. Até que responda, nada vigia o limite de %@ GB: os alarmes de 90%% e 100%% ficam em silêncio. Verifique vm-status ou clique em Medir agora na janela.",
    "rclone size has not answered even once. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "O rclone size não respondeu nenhuma vez. Até que responda, nada vigia o limite de %@ GB: os alarmes de 90%% e 100%% ficam em silêncio. Verifique vm-status ou clique em Medir agora na janela.",
    "Saved in the Keychain. Connecting Google Drive (configure-remote) will use them.":
      "Salvo no Chaveiro. A conexão do Google Drive (configure-remote) vai usá-las.",
    "Saved in the Keychain. The existing Google Drive connection keeps its old client_id, and on this Mac it should stay that way: a connection made with the new keys (the 'drive.file' scope) cannot see the backup created by the old one. Do not replace the connection here; the new keys are for a Mac that is not connected yet.":
      "Salvo no Chaveiro. A conexão existente com o Google Drive mantém o client_id antigo, e neste Mac deve continuar assim: uma conexão feita com as chaves novas (escopo 'drive.file') não enxerga o backup criado pela antiga. Não substitua a conexão aqui; as chaves novas são para um Mac que ainda não está conectado.",
    "it is not there for the new token":
      "não está lá para o novo token",
    "Cancel":
      "Cancelar",
    "ACTION NEEDED":
      "AÇÃO NECESSÁRIA",
    "WILL PASS BY ITSELF — DO NOTHING":
      "VAI PASSAR SOZINHO — NÃO FAÇA NADA",
    "UNKNOWN — CHECK AGAIN SHORTLY":
      "DESCONHECIDO — VERIFIQUE DE NOVO EM BREVE",
    "ALL GOOD":
      "TUDO CERTO",
    "Upload is not working":
      "O envio não está funcionando",
    "Upload stopped — no space left on Google Drive":
      "Envio parado — sem espaço no Google Drive",
    "%@ backup fragments not uploaded":
      "%@ fragmentos de backup não enviados",
    "Upload cannot keep up with writes":
      "O envio não acompanha a gravação",
    "Upload paused — Google daily limit":
      "Envio pausado — limite diário do Google",
    "Uploading to Google Drive — %@ queued":
      "Enviando para o Google Drive — %@ na fila",
    "Everything uploaded to Google Drive":
      "Tudo enviado para o Google Drive",
    "Unknown what is waiting in the queue":
      "Não se sabe o que está na fila",
    "There is no connection to Google Drive, so backups are only made on this Mac. If this does not pass by itself within a few minutes, check the network and the connection to Drive.":
      "Não há conexão com o Google Drive, então os backups são feitos apenas neste Mac. Se isso não passar sozinho em alguns minutos, verifique a rede e a conexão com o Drive.",
    "There is no space left on Google Drive. This will NOT pass by itself — you need to free up space on Drive. Until then Time Machine is paused, so that it does not fill up this Mac's disk.":
      "Não há mais espaço no Google Drive. Isso NÃO vai passar sozinho — você precisa liberar espaço no Drive. Até lá, o Time Machine fica pausado para não encher o disco deste Mac.",
    "%@ backup fragments could not be uploaded and rclone stopped trying. These fragments exist only on this Mac, so the backup on Drive is incomplete. This needs checking.":
      "%@ fragmentos de backup não puderam ser enviados e o rclone parou de tentar. Esses fragmentos existem apenas neste Mac, então o backup no Drive está incompleto. É preciso verificar.",
    "Time Machine is writing faster than the upload goes, and the buffer has filled up. The backup will be paused until the upload catches up — this is a safeguard against filling up the disk, not a failure.":
      "O Time Machine está gravando mais rápido do que o envio, e o buffer encheu. O backup ficará pausado até o envio alcançar — é uma proteção contra encher o disco, não uma falha.",
    "Google accepts 750 GB per day and that limit has been used up. There is nothing to do: the limit renews by itself, usually within a few hours. Time Machine backups are made normally in the meantime and wait in the buffer — they will be uploaded as soon as Google starts accepting again.":
      "O Google aceita 750 GB por dia e esse limite foi usado. Não há nada a fazer: o limite se renova sozinho, normalmente em poucas horas. Enquanto isso, os backups do Time Machine são feitos normalmente e esperam no buffer — serão enviados assim que o Google voltar a aceitar.",
    "%@ backup fragments are queued and on their way to Drive.":
      "%@ fragmentos de backup estão na fila, a caminho do Drive.",
    "Nothing is waiting in the queue — the backup on Google Drive is complete.":
      "Não há nada na fila — o backup no Google Drive está completo.",
    "rclone did not answer the question about the queue, so it is unknown how many backups are still waiting to be uploaded. This does not mean something broke — under load the answer can be late. It only means that right now nobody knows. If it persists, the backup cycle check will report it.":
      "O rclone não respondeu à pergunta sobre a fila, então não se sabe quantos backups ainda aguardam envio. Isso não significa que algo quebrou — sob carga, a resposta pode atrasar. Significa apenas que, neste momento, ninguém sabe. Se persistir, a verificação do ciclo de backup vai relatar.",
    "unknown error":
      "erro desconhecido",
    "rclone lsf ended with an error":
      "rclone lsf terminou com erro",
    "This Mac is close to its space limit on Google Drive":
      "Este Mac está perto do limite de espaço no Google Drive",
    "%@ GB of %@ GB used. Time Machine deletes the oldest backups to stay within its quota; check that the quota is set (vm-status).":
      "%@ GB de %@ GB usados. O Time Machine apaga os backups mais antigos para ficar dentro da cota; verifique se a cota está definida (vm-status).",
    "This Mac is over its space limit on Google Drive":
      "Este Mac ultrapassou o limite de espaço no Google Drive",
    "%@ GB of %@ GB used. Set the Time Machine quota (command in the app window or vm-status), or raise the limit.":
      "%@ GB de %@ GB usados. Defina a cota do Time Machine (comando na janela do app ou em vm-status) ou aumente o limite.",
    "not set":
      "não definida",
    "%@ GB - usage not measured yet":
      "%@ GB - uso ainda não medido",
    "%@ of %@ GB used (%@%%)":
      "%@ de %@ GB usados (%@%%)",
    "The limit must be a whole number of GB above zero.":
      "O limite deve ser um número inteiro de GB maior que zero.",
    "machines.json cannot be read, so it was not overwritten. Fix or remove it first.":
      "Não foi possível ler machines.json, então ele não foi sobrescrito. Corrija-o ou remova-o primeiro.",
    "'%@' is not a valid folder name: use lowercase letters, digits and dashes.":
      "'%@' não é um nome de pasta válido: use letras minúsculas, dígitos e hifens.",
    "This Mac already backs up to folder '%@'. Switching to '%@' would start a new, empty backup and orphan the existing one, so nothing was changed.":
      "Este Mac já faz backup na pasta '%@'. Mudar para '%@' iniciaria um backup novo e vazio e deixaria o existente órfão, então nada foi alterado.",
    "This Mac already has a CloudMachine installation, whose backup is in folder '%@'. Switching to '%@' would orphan it, so nothing was changed.":
      "Este Mac já tem uma instalação do CloudMachine, cujo backup está na pasta '%@'. Mudar para '%@' o deixaria órfão, então nada foi alterado.",
    "Could not save the folder name to %@: %@":
      "Não foi possível salvar o nome da pasta em %@: %@",
    "Homebrew is not installed. Install it manually: https://brew.sh":
      "O Homebrew não está instalado. Instale-o manualmente: https://brew.sh",
    "Installing rclone failed: %@":
      "Falha ao instalar o rclone: %@",
    "Installed rclone.":
      "rclone instalado.",
    "Own Google credentials: set.":
      "Credenciais próprias do Google: definidas.",
    "INCOMPLETE: %@ is missing - rclone will use rclone's shared client_id anyway.":
      "INCOMPLETO: %@ está ausente - o rclone usará o client_id compartilhado do rclone mesmo assim.",
    "No own credentials - rclone uses the shared client_id, rate-limited jointly and being retired in 2026.":
      "Sem credenciais próprias - o rclone usa o client_id compartilhado, com limite de uso conjunto e que será desativado em 2026.",
    "Empty value - not saving.":
      "Valor vazio - não será salvo.",
    "Keychain refused: %@":
      "O Chaveiro recusou: %@",
    "DIRTY-TREE":
      "ÁRVORE-SUJA",
    "Cannot create the working directory: %@":
      "Não foi possível criar o diretório de trabalho: %@",
    "Could not read the rclone version number.":
      "Não foi possível ler o número de versão do rclone.",
    "Could not download %@.":
      "Não foi possível baixar %@.",
    "No entry for %@ in SHA256SUMS.":
      "Não há entrada para %@ em SHA256SUMS.",
    "Could not compute the checksum.":
      "Não foi possível calcular o checksum.",
    "SHA256 checksum does not match - NOT installing.\n  expected: %@\n  computed: %@":
      "O checksum SHA256 não confere - NÃO será instalado.\n  esperado: %@\n  calculado: %@",
    "Could not unpack the archive.":
      "Não foi possível descompactar o arquivo.",
    "Could not install the binary: %@":
      "Não foi possível instalar o binário: %@",
    "Installed rclone %@ in %@ (SHA256 checksum matches).":
      "rclone %@ instalado em %@ (o checksum SHA256 confere).",
    "%@ did not respond within the allotted time (the process was left orphaned in the background).":
      "%@ não respondeu dentro do tempo previsto (o processo ficou órfão em segundo plano).",
    "Cannot launch %@: %@":
      "Não foi possível iniciar %@: %@",
    "Remote '%@' already exists and was NOT touched.\nOverwriting it replaces the token and the permission scope; a credential with the 'drive.file' scope does not see files created by the previous one, so the existing backup becomes unreachable.\nIf you really want to replace it, first back up ~/.config/rclone/rclone.conf and run again with --replace-existing.":
      "O remote '%@' já existe e NÃO foi alterado.\nSobrescrevê-lo substitui o token e o escopo de permissões; uma credencial com o escopo 'drive.file' não enxerga arquivos criados pela anterior, então o backup existente ficaria inacessível.\nSe você realmente quer substituí-lo, primeiro faça backup de ~/.config/rclone/rclone.conf e execute de novo com --replace-existing.",
    "Could not check whether remote '%@' already exists (rclone listremotes did not answer or failed), so nothing was changed. Run `%@ listremotes` to see the error, then try again.":
      "Não foi possível verificar se o remote '%@' já existe (rclone listremotes não respondeu ou falhou), então nada foi alterado. Execute `%@ listremotes` para ver o erro e tente de novo.",
    "Could not check whether this Mac already has a CloudMachine installation (rclone did not answer), so no folder was chosen. Try again in a moment.":
      "Não foi possível verificar se este Mac já tem uma instalação do CloudMachine (o rclone não respondeu), então nenhuma pasta foi escolhida. Tente de novo daqui a pouco.",
    "rclone authorize failed (%@). If that binary is missing, start with: cloudmachine-agent install-rclone.":
      "rclone authorize falhou (%@). Se esse binário estiver ausente, comece com: cloudmachine-agent install-rclone.",
    "Could not read the token from the output of rclone authorize.":
      "Não foi possível ler o token da saída de rclone authorize.",
    "rclone config create failed.":
      "rclone config create falhou.",
    "Connected to Google Drive as remote '%@', folder %@.":
      "Conectado ao Google Drive como remote '%@', pasta %@.",
    "tmutil is not responding - unknown where the backup goes":
      "O tmutil não está respondendo - não se sabe para onde vai o backup",
    "No successful backup for %@":
      "Nenhum backup bem-sucedido há %@",
    "Last COMPLETED backup: %@. The cycle is hourly, so that is %@ missed runs.":
      "Último backup CONCLUÍDO: %@. O ciclo é de hora em hora, então são %@ execuções perdidas.",
    "There is NOT A SINGLE successful backup":
      "NÃO HÁ NENHUM backup bem-sucedido",
    "The Time Machine preferences contain no date of a completed backup for this destination.":
      "As preferências do Time Machine não contêm a data de nenhum backup concluído para este destino.",
    "The last backup attempt did not end in a backup":
      "A última tentativa de backup não resultou em um backup",
    "The attempt at %@ is newer than the last successful backup at %@.":
      "A tentativa de %@ é mais recente que o último backup bem-sucedido, de %@.",
    "Time Machine reports an error in the last run (RESULT=%@)":
      "O Time Machine relata um erro na última execução (RESULT=%@)",
    "A non-zero RESULT in the Time Machine preferences means the run did not succeed.":
      "Um RESULT diferente de zero nas preferências do Time Machine significa que a execução não teve sucesso.",
    "rclone failed to upload %@ files":
      "O rclone não conseguiu enviar %@ arquivos",
    "Buffer full of nothing but unsent data":
      "Buffer cheio só de dados não enviados",
    "rclone has nothing left to evict from the buffer - the upload cannot keep up or has stalled.":
      "O rclone não tem mais nada a descartar do buffer - o envio não acompanha ou travou.",
    "The rclone control interface is not responding":
      "A interface de controle do rclone não responde",
    "Google Drive is running out of space (%@ GB)":
      "O Google Drive está ficando sem espaço (%@ GB)",
    "The Mac's disk is running out of space (%@ GB)":
      "O disco do Mac está ficando sem espaço (%@ GB)",
    "Cannot read the Time Machine preferences":
      "Não é possível ler as preferências do Time Machine",
    "%@ is unreadable - most often Full Disk Access is missing. Without this file it is UNKNOWN when the last backup was made, so we treat it as a failure, not as the absence of a problem.":
      "%@ não pode ser lido - o mais comum é faltar o Acesso Total ao Disco. Sem este arquivo, NÃO SE SABE quando foi feito o último backup, então tratamos isso como falha, e não como ausência de problema.",
    "Cannot measure free space on the Mac's disk":
      "Não é possível medir o espaço livre no disco do Mac",
    "%@ days":
      "%@ dias",
    "CloudMachine: backup is not working":
      "CloudMachine: o backup não está funcionando",
    "unknown reason":
      "motivo desconhecido",
    "osascript did not show the notification (permissions or no graphical session)":
      "O osascript não exibiu a notificação (permissões ou nenhuma sessão gráfica)",
    "UNDELIVERED ALARM: %@":
      "ALARME NÃO ENTREGUE: %@",
    "from %@, reason: %@":
      "de %@, motivo: %@",
    "The system notification was not delivered - you will see this alarm ONLY here.":
      "A notificação do sistema não foi entregue - você verá este alarme SOMENTE aqui.",
    "%@ (%@ ago)":
      "%@ (há %@)",
    "%@ - marker from the FUTURE":
      "%@ - marcador do FUTURO",
    "%@ (%@ ago) - THE WATCHDOG MAY NOT BE RUNNING":
      "%@ (há %@) - O SUPERVISOR PODE NÃO ESTAR EM EXECUÇÃO",
    "NEVER - the watchdog has not recorded a single run":
      "NUNCA - o supervisor não registrou nenhuma execução",
    "Could not find the launchd/ directory with templates.":
      "Não foi possível encontrar o diretório launchd/ com os modelos.",
    "Could not find the compiled cloudmachine-agent binary.":
      "Não foi possível encontrar o binário compilado do cloudmachine-agent.",
    "ABORTED: could not put cloudmachine-agent in a stable location\n(%@) - most often a lack of space or permissions.\nNOT installing agents pointing at %@: that path\ndisappears on the next `swift build` or `git clean`, and backups stop\nwithout any visible signal.":
      "ABORTADO: não foi possível colocar o cloudmachine-agent em um local estável\n(%@) - o mais comum é falta de espaço ou de permissões.\nNÃO serão instalados agentes apontando para %@: esse caminho\ndesaparece no próximo `swift build` ou `git clean`, e os backups param\nsem nenhum sinal visível.",
    "ABORTED: %@":
      "ABORTADO: %@",
    "Could not list the templates in %@.":
      "Não foi possível listar os modelos em %@.",
    "could not read the template %@":
      "não foi possível ler o modelo %@",
    "could not write %@ (lack of space or permissions)":
      "não foi possível gravar %@ (falta de espaço ou de permissões)",
    "launchctl load refused to load %@":
      "launchctl load recusou-se a carregar %@",
    "NOT A SINGLE agent was loaded.":
      "NENHUM agente foi carregado.",
    "Only these went in: %@.":
      "Só estes foram instalados: %@.",
    "Could not load any launchd agent.":
      "Não foi possível carregar nenhum agente do launchd.",
    "Installed agents: %@":
      "Agentes instalados: %@",
    "                  WARNING: close to the limit - new bands will fail with EMFILE":
      "                  AVISO: perto do limite - as novas bandas falharão com EMFILE",
    "%@/bands on Google Drive is not empty - it may hold another backup. NOT overwriting it; check it by hand.":
      "%@/bands no Google Drive não está vazio - pode conter outro backup. NÃO será sobrescrito; verifique manualmente.",
    "Address:          %@":
      "Endereço:         %@",
    "Already prepared (%@ exists) - nothing to do.":
      "Já preparado (%@ existe) - nada a fazer.",
    "Converts Time Machine's new, empty image in the machine to 32 MB bands and moves the bands to Google Drive.":
      "Converte a imagem nova e vazia do Time Machine na máquina em bandas de 32 MB e move as bandas para o Google Drive.",
    "Copy rclone.conf into the machine even if it already has one.":
      "Copia o rclone.conf para a máquina mesmo que ela já tenha um.",
    "Copying the converted image into the machine failed: %@":
      "Falha ao copiar a imagem convertida para a máquina: %@",
    "Copying the image to the Mac failed: %@":
      "Falha ao copiar a imagem para o Mac: %@",
    "Could not ask Lima about the machine: %@":
      "Não foi possível consultar o Lima sobre a máquina: %@",
    "Could not carry the Time Machine files over: %@":
      "Não foi possível transferir os arquivos do Time Machine: %@",
    "Could not check the image in the machine.":
      "Não foi possível verificar a imagem na máquina.",
    "Could not copy the rclone configuration into the machine.":
      "Não foi possível copiar a configuração do rclone para a máquina.",
    "Could not create %@ on Google Drive: %@":
      "Não foi possível criar %@ no Google Drive: %@",
    "Could not create %@: %@":
      "Não foi possível criar %@: %@",
    "Could not find the vm/ directory with the machine template.":
      "Não foi possível encontrar o diretório vm/ com o modelo da máquina.",
    "Could not read the image size.":
      "Não foi possível ler o tamanho da imagem.",
    "Could not set the SMB password of user %@ in the machine.":
      "Não foi possível definir a senha SMB do usuário %@ na máquina.",
    "Could not stop smbd in the machine.":
      "Não foi possível parar o smbd na máquina.",
    "Could not write %@ in the machine.":
      "Não foi possível gravar %@ na máquina.",
    "Could not write the password file %@.":
      "Não foi possível gravar o arquivo de senha %@.",
    "Creates or starts the CloudMachine machine (Lima), gives it rclone's configuration and an SMB password, and prints the Time Machine command.":
      "Cria ou inicia a máquina do CloudMachine (Lima), fornece a ela a configuração do rclone e uma senha SMB, e imprime o comando do Time Machine.",
    "Creating the machine %@ (first start downloads Ubuntu and installs packages - several minutes)...":
      "Criando a máquina %@ (a primeira inicialização baixa o Ubuntu e instala pacotes - vários minutos)...",
    "Done: %@ has %@ MB bands on Google Drive; the original is kept in %@ in the machine. Start the backup: tmutil startbackup":
      "Pronto: %@ tem bandas de %@ MB no Google Drive; o original fica em %@ na máquina. Inicie o backup: tmutil startbackup",
    "exit code %@, no message":
      "código de saída %@, sem mensagem",
    "Image metadata:   NEVER copied to %@ - check tm-meta-sync in the machine":
      "Metadados imagem: NUNCA copiados para %@ - verifique o tm-meta-sync na máquina",
    "Image metadata:   copied %@ ago to %@":
      "Metadados imagem: copiados há %@ para %@",
    "Image metadata:   last copied %@ ago - OVERDUE (%@)":
      "Metadados imagem: última cópia há %@ - ATRASADO (%@)",
    "Image metadata:   not copied yet - waits for vm-prepare-bundle":
      "Metadados imagem: ainda não copiados - aguardam vm-prepare-bundle",
    "Backup %@, paused by the guard %@: %@":
      "Backup %@, pausado pelo guardião %@: %@",
    "Free in machine:  %@ GiB":
      "Livre na máquina: %@ GiB",
    "fsck_apfs -n found problems: %@":
      "fsck_apfs -n encontrou problemas: %@",
    "Google Drive folder: %@":
      "Pasta do Google Drive: %@",
    "hdiutil attach of the converted image failed: %@":
      "hdiutil attach da imagem convertida falhou: %@",
    "hdiutil convert failed: %@":
      "hdiutil convert falhou: %@",
    "Image name in the machine (default: from the computer name).":
      "Nome da imagem na máquina (padrão: derivado do nome do computador).",
    "Installing the converted image FAILED: %@\nsmbd is left STOPPED so Time Machine does not open a half-installed image. The original is in %@ in the machine.":
      "A instalação da imagem convertida FALHOU: %@\nO smbd permanece PARADO para que o Time Machine não abra uma imagem instalada pela metade. O original está em %@ na máquina.",
    "limactl create failed: %@":
      "limactl create falhou: %@",
    "limactl list failed: %@":
      "limactl list falhou: %@",
    "limactl not found - install Lima: brew install lima":
      "limactl não encontrado - instale o Lima: brew install lima",
    "limactl start failed: %@\nThe machine's own log: %@":
      "limactl start falhou: %@\nO log da própria máquina: %@",
    "Machine %@ is running.":
      "A máquina %@ está em execução.",
    "Machine %@ was already running.":
      "A máquina %@ já estava em execução.",
    "Machine:          %@ (%@)":
      "Máquina:          %@ (%@)",
    "Machine:          %@":
      "Máquina:          %@",
    "Machine:          not created - run: cloudmachine-agent vm-setup":
      "Máquina:          não criada - execute: cloudmachine-agent vm-setup",
    "no answer within the time limit":
      "sem resposta dentro do limite de tempo",
    "No image %@ in the machine.":
      "Não há imagem %@ na máquina.",
    "No image in the machine yet - point Time Machine at the share and let it create one first.":
      "Ainda não há imagem na máquina - aponte o Time Machine para o compartilhamento e deixe que ele crie uma primeiro.",
    "No rclone configuration at %@ - connect Google Drive first (configure-remote).":
      "Não há configuração do rclone em %@ - conecte primeiro o Google Drive (configure-remote).",
    "no SMB destination":
      "sem destino SMB",
    "One check of the machine's upload buffer: pauses Time Machine when it fills, resumes what it paused.":
      "Uma verificação do buffer de envio da máquina: pausa o Time Machine quando ele enche e retoma o que pausou.",
    "Packing the converted image failed: %@":
      "Falha ao empacotar a imagem convertida: %@",
    "Packing the image failed: %@":
      "Falha ao empacotar a imagem: %@",
    "No answer from the machine (rclone rc) - the guard would do nothing.":
      "Sem resposta da máquina (rclone rc) - o guardião não faria nada.",
    "Only print what the guard would decide - for trying thresholds on a throwaway machine.":
      "Apenas imprime o que o guardião decidiria - para testar limites em uma máquina descartável.",
    "Pause above this many GiB in the buffer.":
      "Pausar acima desta quantidade de GiB no buffer.",
    "Pause when the machine has less free than this, in GiB.":
      "Pausar quando a máquina tiver menos livre do que isto, em GiB.",
    "Point Time Machine at the machine (once, needs an administrator password):":
      "Aponte o Time Machine para a máquina (uma só vez, requer senha de administrador):",
    "punchfs files:    %@ open, limit %@":
      "Arquivos punchfs: %@ abertos, limite %@",
    "rclone configuration already in the machine - kept (--replace-rclone-config replaces it).":
      "Configuração do rclone já está na máquina - mantida (--replace-rclone-config a substitui).",
    "rclone configuration copied into the machine.":
      "Configuração do rclone copiada para a máquina.",
    "rclone-tm or punchfs is not running in the machine - see cloudmachine-agent vm-status.":
      "rclone-tm ou punchfs não está em execução na máquina - veja cloudmachine-agent vm-status.",
    "Resume below this many GiB (only a backup the guard paused).":
      "Retomar abaixo desta quantidade de GiB (apenas um backup que o guardião pausou).",
    "Service %@: %@":
      "Serviço %@: %@",
    "Several images in the machine (%@) - choose one with --bundle.":
      "Várias imagens na máquina (%@) - escolha uma com --bundle.",
    "Shows the machine: address, services, upload buffer, free space and the Time Machine destination.":
      "Mostra a máquina: endereço, serviços, buffer de envio, espaço livre e o destino do Time Machine.",
    "SMB password stored in %@ (mode 600).":
      "Senha SMB armazenada em %@ (modo 600).",
    "The converted image does not have %@-byte bands.":
      "A imagem convertida não tem bandas de %@ bytes.",
    "The converted image has no APFS partition.":
      "A imagem convertida não tem partição APFS.",
    "The image already takes %@ MB - this command converts only a new, empty image (under %@ MB).":
      "A imagem já ocupa %@ MB - este comando converte apenas uma imagem nova e vazia (abaixo de %@ MB).",
    "The image is encrypted - converting encrypted images is not supported.":
      "A imagem está criptografada - converter imagens criptografadas não é suportado.",
    "The image was not changed; smbd started again.":
      "A imagem não foi alterada; o smbd foi iniciado de novo.",
    "The machine does not answer - is it running? cloudmachine-agent vm-status":
      "A máquina não responde - ela está em execução? cloudmachine-agent vm-status",
    "The machine has no address on the vzNAT network.":
      "A máquina não tem endereço na rede vzNAT.",
    "The services in the machine did not start - check: cloudmachine-agent vm-status":
      "Os serviços da máquina não iniciaram - verifique: cloudmachine-agent vm-status",
    "Time Machine is backing up - stop it first: tmutil stopbackup":
      "O Time Machine está fazendo backup - pare-o primeiro: tmutil stopbackup",
    "Time Machine:     %@":
      "Time Machine:     %@",
    "Time Machine:     NOT pointing at the machine (%@)":
      "Time Machine:     NÃO aponta para a máquina (%@)",
    "Time Machine:     tmutil did not answer":
      "Time Machine:     o tmutil não respondeu",
    "tmutil did not answer - not touching the image while its state is unknown.":
      "O tmutil não respondeu - a imagem não será tocada enquanto o estado for desconhecido.",
    "unknown":
      "desconhecido",
    "Unpacking the image failed: %@":
      "Falha ao descompactar a imagem: %@",
    "Still to upload:  %@ GiB in %@ bands, uploading %@ (cache on disk %@ GiB)":
      "Ainda para enviar: %@ GiB em %@ bandas, enviando %@ (cache no disco %@ GiB)",
    "Excluded %@ (the machine and its upload buffer) from Time Machine.":
      "%@ (a máquina e seu buffer de envio) foi excluído do Time Machine.",
    "WARNING: could not exclude %@ from Time Machine - run: tmutil addexclusion %@":
      "AVISO: não foi possível excluir %@ do Time Machine - execute: tmutil addexclusion %@",
    "Upload buffer:    no answer from rclone (rc %@)":
      "Buffer de envio:  sem resposta do rclone (rc %@)",
    "When Time Machine has created its empty image, stop the backup (tmutil stopbackup) and run: cloudmachine-agent vm-prepare-bundle":
      "Quando o Time Machine tiver criado a imagem vazia, pare o backup (tmutil stopbackup) e execute: cloudmachine-agent vm-prepare-bundle",
    "Unsent %@ GiB, free %@ GiB (pause above %@ GiB unsent or below %@ GiB free, resume below %@ GiB).":
      "Não enviados %@ GiB, livres %@ GiB (pausa acima de %@ GiB não enviados ou abaixo de %@ GiB livres, retoma abaixo de %@ GiB).",
    "Upload:           Google's daily limit refused an upload %@ ago - rclone retries every 5 min and resumes by itself":
      "Envio:            o limite diário do Google recusou um envio há %@ - o rclone tenta de novo a cada 5 min e retoma sozinho",
    "no":
      "não",
    "running":
      "em execução",
    "stopped":
      "parado",
    "yes":
      "sim",
    "%@\nThe previous template is in %@ - copy it back over lima.yaml and run limactl start %@.":
      "%@\nO modelo anterior está em %@ - copie-o de volta sobre lima.yaml e execute limactl start %@.",
    "Could not read this app's machine template (limactl template copy).":
      "Não foi possível ler o modelo de máquina deste app (limactl template copy).",
    "Could not replace %@: %@":
      "Não foi possível substituir %@: %@",
    "Machine %@ already runs this app's template.":
      "A máquina %@ já usa o modelo deste app.",
    "Machine %@ now runs this app's template; the previous one is in %@.":
      "A máquina %@ agora usa o modelo deste app; o anterior está em %@.",
    "Moves the machine onto this app's template (two restarts, never during a backup).":
      "Move a máquina para o modelo deste app (duas reinicializações, nunca durante um backup).",
    "No machine %@ - create it with: cloudmachine-agent vm-setup":
      "Não existe a máquina %@ - crie-a com: cloudmachine-agent vm-setup",
    "Template:         OLDER than this app's - run: cloudmachine-agent vm-update":
      "Modelo:           MAIS ANTIGO que o deste app - execute: cloudmachine-agent vm-update",
    "Template:         not compared":
      "Modelo:           não comparado",
    "Template:         this app's":
      "Modelo:           o deste app",
    "The machine has no %@ - run cloudmachine-agent vm-setup first.":
      "A máquina não tem %@ - execute antes cloudmachine-agent vm-setup.",
    "The machine restarted, but not every service is running - check: cloudmachine-agent vm-status. The previous template is in %@.":
      "A máquina reiniciou, mas nem todos os serviços estão em execução - verifique: cloudmachine-agent vm-status. O modelo anterior está em %@.",
    "The template changes the machine itself (%@) - that needs a new machine, not an update.":
      "O modelo altera a própria máquina (%@) - isso exige uma máquina nova, não uma atualização.",
    "The upload to Google Drive hangs":
      "O envio para o Google Drive está travado",
    "Time Machine is backing up - try again when it has finished.":
      "O Time Machine está fazendo backup - tente de novo quando terminar.",
    "Upload:           HANGS - bands in progress, none uploaded for %@ (network?); see /var/log/rclone-tm.log in the machine":
      "Envio:            TRAVADO - bandas em andamento, nenhuma enviada há %@ (rede?); veja /var/log/rclone-tm.log na máquina",
    "limactl stop failed - nothing was changed.":
      "limactl stop falhou - nada foi alterado.",
    "rclone has bands in progress, but none has been uploaded for %@ - usually a broken network connection, which rclone does not report as an error. Backups since then are only in the machine's buffer. When the network comes back the upload resumes by itself (on 28.10.2026 within 80 s); if it does not, restarting the machine (prepare-shutdown, limactl start) drops the dead connections.":
      "O rclone tem bandas em andamento, mas nenhuma foi enviada há %@ - normalmente uma conexão de rede interrompida, que o rclone não relata como erro. Os backups desde então estão apenas no buffer da máquina. Quando a rede voltar, o envio retoma sozinho (em 28.10.2026, em 80 s); se não retomar, reiniciar a máquina (prepare-shutdown, limactl start) descarta as conexões mortas.",
    "tmutil did not answer - not restarting the machine while its state is unknown.":
      "O tmutil não respondeu - a máquina não será reiniciada enquanto o estado for desconhecido.",
    "The machine's share cannot be read":
      "Não é possível ler o compartilhamento da máquina",
    "Unknown whether the machine's share can be read":
      "Não se sabe se o compartilhamento da máquina pode ser lido",
    "Samba in the machine does not answer this Mac":
      "O Samba na máquina não responde a este Mac",
    "Unknown whether Samba in the machine answers this Mac":
      "Não se sabe se o Samba na máquina responde a este Mac",
    "Reading 1 byte of %@ in the machine failed: %@. Every service says it is active, yet Time Machine cannot use the image there. Nothing restarts it by itself. Check: cloudmachine-agent vm-status, then in the machine: journalctl -u punchfs -u tm-bands-bind -u rclone-tm":
      "A leitura de 1 byte de %@ na máquina falhou: %@. Todos os serviços dizem estar ativos, mas o Time Machine não consegue usar a imagem ali. Nada o reinicia sozinho. Verifique: cloudmachine-agent vm-status e depois, na máquina: journalctl -u punchfs -u tm-bands-bind -u rclone-tm",
    "Reading 1 byte of %@ in the machine has not returned for %@ s. That is how a hung punchfs or rclone mount behaves. Nothing is restarted while the state is unknown - a restart under a write still going could lose it. Check in the machine: journalctl -u punchfs -u rclone-tm":
      "A leitura de 1 byte de %@ na máquina não retornou há %@ s. É assim que se comporta uma montagem do punchfs ou do rclone travada. Nada é reiniciado enquanto o estado for desconhecido - um reinício durante uma gravação em andamento poderia perdê-la. Verifique na máquina: journalctl -u punchfs -u rclone-tm",
    "An SMB connection to %@ got no answer within %@ s. Time Machine reaches the machine at this address. Check the machine's network and smbd: cloudmachine-agent vm-status":
      "Uma conexão SMB com %@ não obteve resposta em %@ s. O Time Machine acessa a máquina neste endereço. Verifique a rede da máquina e o smbd: cloudmachine-agent vm-status",
    "The machine did not report its address, so nobody could try an SMB connection. Check: cloudmachine-agent vm-status":
      "A máquina não informou seu endereço, então ninguém pôde tentar uma conexão SMB. Verifique: cloudmachine-agent vm-status",
    "An SMB connection to %@ failed (%@). Time Machine reaches the machine at this address, so no backup is made. Check the machine's network and smbd: cloudmachine-agent vm-status":
      "Uma conexão SMB com %@ falhou (%@). O Time Machine acessa a máquina neste endereço, então nenhum backup é feito. Verifique a rede da máquina e o smbd: cloudmachine-agent vm-status",
    "readable":
      "legível",
    "no image yet":
      "ainda sem imagem",
    "answers":
      "responde",
    "Share read:       %@":
      "Leitura compart.: %@",
    "Samba from Mac:   %@":
      "Samba do Mac:     %@",
    "This Mac found no route to %@ (%@). Either the route to the machine is gone, or macOS Local Network privacy has not allowed CloudMachine - then allow it in System Settings > Privacy & Security > Local Network. Check: cloudmachine-agent vm-status":
      "Este Mac não encontrou rota para %@ (%@). Ou a rota até a máquina sumiu, ou a privacidade de \"Rede Local\" do macOS não permitiu o CloudMachine - nesse caso, permita em Ajustes do Sistema > Privacidade e Segurança > Rede Local. Verifique: cloudmachine-agent vm-status",
  ]
}
