// Brazilian Portuguese translations of vm-encrypt (DriveEncryption), keyed by the English text.
extension L10nTranslations {
  static let ptBREncryption: [String: String] = [
    "%@ and its metadata are in Google Drive's bin (kept 30 days, still counted in the quota).":
      "%@ e seus metadados estão na lixeira do Google Drive (mantidos por 30 dias, ainda contam na cota).",
    "'%@' is already in %@ - not replacing its password.":
      "'%@' já está em %@ - a senha não será substituída.",
    "'%@' is already in the machine's rclone.conf - not replacing its password.":
      "'%@' já está no rclone.conf da máquina - a senha não será substituída.",
    "%@ holds folders this key cannot read: another password or salt in the machine, or leftovers of an earlier try. Compare the machine's rclone.conf with the Mac's; leftovers have to be removed from %@ by hand.":
      "%@ contém pastas que esta chave não consegue ler: outra senha ou sal na máquina, ou restos de uma tentativa anterior. Compare o rclone.conf da máquina com o do Mac; os restos precisam ser removidos de %@ manualmente.",
    "'%@' is incomplete or missing in the Mac's rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "'%@' está incompleto ou ausente no rclone.conf do Mac - execute: cloudmachine-agent vm-encrypt setup",
    "CLOUDMACHINE_VM_INSTANCE=%@ needs its own rclone.conf - set RCLONE_CONFIG to a copy, not %@. Its Keychain entry is service %@.":
      "CLOUDMACHINE_VM_INSTANCE=%@ precisa do próprio rclone.conf - defina RCLONE_CONFIG como uma cópia, não %@. A entrada dela no Chaveiro é o serviço %@.",
    "Could not read the '%@' section on the Mac or in the machine.":
      "Não foi possível ler a seção '%@' no Mac ou na máquina.",
    "The machine's '%@' (password, salt or folder) differs from the Mac's - the copy would be readable only with the machine's key. Not moving anything.":
      "'%@' da máquina (senha, sal ou pasta) é diferente do que está no Mac - a cópia só poderia ser lida com a chave da máquina. Nada será movido.",
    "A file was restored from the encrypted backup.":
      "Um arquivo foi restaurado do backup criptografado.",
    "Added '%@' (%@) on the Mac and in the machine; password and salt are in the Keychain (service %@).\nSALT: %@\nKeep the password AND this salt outside this Mac now - without both the encrypted backup cannot be read. Next: cloudmachine-agent vm-encrypt copy":
      "'%@' (%@) adicionado no Mac e na máquina; a senha e o sal estão no Chaveiro (serviço %@).\nSAL: %@\nGuarde agora a senha E este sal fora deste Mac - sem os dois o backup criptografado não pode ser lido. Próximo: cloudmachine-agent vm-encrypt copy",
    "Adds the encrypted remote on the Mac and in the machine (asks for the password). Moves no data.":
      "Adiciona o remote criptografado no Mac e na máquina (pede a senha). Não move dados.",
    "Again: ":
      "De novo: ",
    "Copies the plain backup into the encrypted folder, in the background; backups go on.":
      "Copia o backup não criptografado para a pasta criptografada, em segundo plano; os backups continuam.",
    "Copy:             %@":
      "Cópia:            %@",
    "CLOUDMACHINE_VM_INSTANCE=%@ without CLOUDMACHINE_VM_REMOTE would use the live backup's folder - set both.":
      "CLOUDMACHINE_VM_INSTANCE=%@ sem CLOUDMACHINE_VM_REMOTE usaria a pasta do backup em uso - defina as duas.",
    "Could not add the remote to %@: %@":
      "Não foi possível adicionar o remote a %@: %@",
    "Could not add the remote to the machine's rclone.conf.":
      "Não foi possível adicionar o remote ao rclone.conf da máquina.",
    "Could not read %@.":
      "Não foi possível ler %@.",
    "Could not read when Time Machine last finished a backup (Full Disk Access?) - not deleting.":
      "Não foi possível saber quando o Time Machine concluiu o último backup (Acesso Total ao Disco?) - nada será apagado.",
    "Could not start the copy: %@":
      "Não foi possível iniciar a cópia: %@",
    "Could not write %@.":
      "Não foi possível gravar %@.",
    "Deleting the plain folder failed: %@":
      "Falha ao apagar a pasta não criptografada: %@",
    "Encrypted folder: %@":
      "Pasta cript.:     %@",
    "Encryption password: ":
      "Senha de criptografia: ",
    "Machine uses:     %@":
      "A máquina usa:    %@",
    "Moves the backup on Google Drive under rclone encryption: setup, copy, switch, then delete-plain.":
      "Coloca o backup no Google Drive sob a criptografia do rclone: setup, copy, switch e depois delete-plain.",
    "Moves the plain folder to Google Drive's bin - only after a backup has finished into the encrypted one.":
      "Move a pasta não criptografada para a lixeira do Google Drive - só depois que um backup terminar na criptografada.",
    "Moving the machine failed; it went back to %@: %@":
      "Falha ao mudar a máquina; ela voltou para %@: %@",
    "No answer from rclone in the machine - the upload queue is unknown.":
      "Sem resposta do rclone na máquina - a fila de envio é desconhecida.",
    "No backup has finished into the encrypted folder yet (last one %@, switched %@) - not deleting.":
      "Nenhum backup terminou ainda na pasta criptografada (último %@, mudança %@) - nada será apagado.",
    "Not everything is on Google Drive yet (%@ MB unsent, %@ uploading, %@ failed). Wait until the upload is done: cloudmachine-agent vm-status":
      "Ainda não está tudo no Google Drive (%@ MB não enviados, %@ enviando, %@ com falha). Aguarde o fim do envio: cloudmachine-agent vm-status",
    "Restore a file from the encrypted backup first (Time Machine, Browse), then confirm with --restore-checked.":
      "Restaure primeiro um arquivo do backup criptografado (Time Machine, Navegar) e depois confirme com --restore-checked.",
    "Shows which folder the machine uses and the copy.":
      "Mostra qual pasta a máquina usa e o estado da cópia.",
    "Switched:         %@":
      "Mudança:          %@",
    "The copy is already running - see: cloudmachine-agent vm-encrypt status":
      "A cópia já está em andamento - veja: cloudmachine-agent vm-encrypt status",
    "The copy runs in the machine (%@, log %@). Backups go on meanwhile. Check: cloudmachine-agent vm-encrypt status":
      "A cópia está sendo executada na máquina (%@, log %@). Enquanto isso, os backups continuam. Verificar: cloudmachine-agent vm-encrypt status",
    "The copy to the encrypted folder has not finished well (%@) - run: cloudmachine-agent vm-encrypt copy, and wait for it.":
      "A cópia para a pasta criptografada não terminou bem (%@) - execute: cloudmachine-agent vm-encrypt copy e aguarde.",
    "The encryption password and salt are kept outside this Mac.":
      "A senha de criptografia e o sal estão guardados fora deste Mac.",
    "The guard holds Time Machine paused and would resume it during the switch. Wait until it resumes and the upload is done.":
      "O guardião mantém o Time Machine em pausa e o retomaria durante a mudança. Aguarde até que ele seja retomado e o envio termine.",
    "The image metadata has not been copied to the encrypted folder since the last backup - not deleting.":
      "Os metadados da imagem não foram copiados para a pasta criptografada desde o último backup - nada será apagado.",
    "The last sync or cryptcheck failed - the machine was NOT moved: %@":
      "A última sincronização ou o cryptcheck falhou - a máquina NÃO foi mudada: %@",
    "The machine already uses the encrypted folder - nothing to switch.":
      "A máquina já usa a pasta criptografada - nada para mudar.",
    "The machine already uses the encrypted folder.":
      "A máquina já usa a pasta criptografada.",
    "The machine does not use the encrypted folder - nothing to roll back.":
      "A máquina não usa a pasta criptografada - nada para reverter.",
    "The machine does not use the encrypted folder - the plain folder is the backup. Not deleting it.":
      "A máquina não usa a pasta criptografada - a pasta não criptografada é o backup. Ela não será apagada.",
    "The machine has no '%@' remote in its rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "A máquina não tem o remote '%@' no seu rclone.conf - execute: cloudmachine-agent vm-encrypt setup",
    "The machine is not on this app's template or does not use %@ (cloudmachine-agent vm-update first): %@":
      "A máquina não está no modelo deste app ou não usa %@ (primeiro cloudmachine-agent vm-update): %@",
    "The machine now uses %@, but %@ could not be updated (%@) - fix it before anything else runs vm-setup.":
      "A máquina agora usa %@, mas não foi possível atualizar %@ (%@) - corrija isso antes que algo execute vm-setup.",
    "The machine now uses %@. %@ is kept. Turn automatic backups back on: sudo tmutil enable":
      "A máquina agora usa %@. %@ é mantida. Reative os backups automáticos: sudo tmutil enable",
    "The password must have at least 12 characters.":
      "A senha deve ter pelo menos 12 caracteres.",
    "The passwords differ - nothing was changed.":
      "As senhas são diferentes - nada foi alterado.",
    "The switch the other way: decrypts what changed back into the plain folder and uses it again.":
      "A mudança no sentido inverso: descriptografa o que mudou de volta para a pasta não criptografada e passa a usá-la de novo.",
    "The upload to the encrypted folder is not finished (or rclone did not answer) - not deleting.":
      "O envio para a pasta criptografada não terminou (ou o rclone não respondeu) - nada será apagado.",
    "Time Machine is backing up. Turn automatic backups off (sudo tmutil disable), stop it (tmutil stopbackup), then run this again.":
      "O Time Machine está fazendo backup. Desative os backups automáticos (sudo tmutil disable), pare-o (tmutil stopbackup) e execute isto de novo.",
    "With Time Machine stopped: last sync, cryptcheck, then the machine uses the encrypted folder. The plain one stays.":
      "Com o Time Machine parado: última sincronização, cryptcheck e depois a máquina usa a pasta criptografada. A não criptografada fica.",
    "Without the encryption password and salt the encrypted backup cannot be read. Keep both outside this Mac (a password manager, paper), then confirm with --secrets-saved-elsewhere.":
      "Sem a senha de criptografia e o sal o backup criptografado não pode ser lido. Guarde os dois fora deste Mac (um gerenciador de senhas, papel) e depois confirme com --secrets-saved-elsewhere.",
    "rclone obscure failed.":
      "Falha no rclone obscure.",
    "tmutil did not answer - not switching while Time Machine's state is unknown.":
      "O tmutil não respondeu - sem mudança enquanto o estado do Time Machine for desconhecido.",
  ]
}
