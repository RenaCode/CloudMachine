// Russian translations of vm-encrypt (DriveEncryption), keyed by the English text.
extension L10nTranslations {
  static let ruEncryption: [String: String] = [
    "%@ and its metadata are in Google Drive's bin (kept 30 days, still counted in the quota).":
      "%@ вместе с метаданными находится в корзине Google Drive (хранится 30 дней и по-прежнему учитывается в квоте).",
    "'%@' is already in %@ - not replacing its password.":
      "'%@' уже есть в %@ - его пароль не заменяется.",
    "'%@' is already in the machine's rclone.conf - not replacing its password.":
      "'%@' уже есть в rclone.conf машины - его пароль не заменяется.",
    "%@ holds folders this key cannot read: another password or salt in the machine, or leftovers of an earlier try. Compare the machine's rclone.conf with the Mac's; leftovers have to be removed from %@ by hand.":
      "В %@ есть папки, которые этот ключ не может прочитать: другой пароль или соль в машине либо остатки прежней попытки. Сравните rclone.conf машины с файлом на Mac; остатки нужно удалить из %@ вручную.",
    "'%@' is incomplete or missing in the Mac's rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "'%@' неполон или отсутствует в rclone.conf на Mac - выполните: cloudmachine-agent vm-encrypt setup",
    "CLOUDMACHINE_VM_INSTANCE=%@ needs its own rclone.conf - set RCLONE_CONFIG to a copy, not %@. Its Keychain entry is service %@.":
      "CLOUDMACHINE_VM_INSTANCE=%@ нужен собственный rclone.conf - укажите в RCLONE_CONFIG копию, а не %@. Запись этого экземпляра в Связке ключей — служба %@.",
    "Could not read the '%@' section on the Mac or in the machine.":
      "Не удалось прочитать раздел '%@' на Mac или в машине.",
    "The machine's '%@' (password, salt or folder) differs from the Mac's - the copy would be readable only with the machine's key. Not moving anything.":
      "'%@' в машине (пароль, соль или папка) отличается от раздела на Mac - копию можно было бы прочитать только ключом машины. Ничего не переносится.",
    "A file was restored from the encrypted backup.":
      "Файл восстановлен из зашифрованной резервной копии.",
    "Added '%@' (%@) on the Mac and in the machine; password and salt are in the Keychain (service %@).\nSALT: %@\nKeep the password AND this salt outside this Mac now - without both the encrypted backup cannot be read. Next: cloudmachine-agent vm-encrypt copy":
      "'%@' (%@) добавлен на Mac и в машину; пароль и соль в Связке ключей (служба %@).\nСОЛЬ: %@\nСохраните сейчас пароль И эту соль вне этого Mac - без обоих зашифрованную копию не прочитать. Далее: cloudmachine-agent vm-encrypt copy",
    "Adds the encrypted remote on the Mac and in the machine (asks for the password). Moves no data.":
      "Добавляет зашифрованный remote на Mac и в машину (запрашивает пароль). Данные не переносит.",
    "Again: ":
      "Ещё раз: ",
    "Copies the plain backup into the encrypted folder, in the background; backups go on.":
      "Копирует незашифрованную резервную копию в зашифрованную папку в фоне; резервное копирование продолжается.",
    "Copy:             %@":
      "Копирование:      %@",
    "CLOUDMACHINE_VM_INSTANCE=%@ without CLOUDMACHINE_VM_REMOTE would use the live backup's folder - set both.":
      "CLOUDMACHINE_VM_INSTANCE=%@ без CLOUDMACHINE_VM_REMOTE использовал бы папку действующей резервной копии - задайте обе.",
    "Could not add the remote to %@: %@":
      "Не удалось добавить remote в %@: %@",
    "Could not add the remote to the machine's rclone.conf.":
      "Не удалось добавить remote в rclone.conf машины.",
    "Could not read %@.":
      "Не удалось прочитать %@.",
    "Could not read when Time Machine last finished a backup (Full Disk Access?) - not deleting.":
      "Не удалось узнать, когда Time Machine в последний раз завершил резервное копирование (Полный доступ к диску?) - ничего не удаляется.",
    "Could not start the copy: %@":
      "Не удалось запустить копирование: %@",
    "Could not write %@.":
      "Не удалось записать %@.",
    "Deleting the plain folder failed: %@":
      "Не удалось удалить незашифрованную папку: %@",
    "Encrypted folder: %@":
      "Зашифр. папка:    %@",
    "Encryption password: ":
      "Пароль шифрования: ",
    "Machine uses:     %@":
      "Используется:     %@",
    "Moves the backup on Google Drive under rclone encryption: setup, copy, switch, then delete-plain.":
      "Переносит резервную копию на Google Drive под шифрование rclone: setup, copy, switch, затем delete-plain.",
    "Moves the plain folder to Google Drive's bin - only after a backup has finished into the encrypted one.":
      "Перемещает незашифрованную папку в корзину Google Drive - только после того, как резервная копия завершилась в зашифрованную.",
    "Moving the machine failed; it went back to %@: %@":
      "Не удалось переключить машину; она вернулась к %@: %@",
    "No answer from rclone in the machine - the upload queue is unknown.":
      "Нет ответа от rclone в машине - очередь отправки неизвестна.",
    "No backup has finished into the encrypted folder yet (last one %@, switched %@) - not deleting.":
      "В зашифрованную папку ещё не завершилась ни одна резервная копия (последняя %@, переключение %@) - ничего не удаляется.",
    "Not everything is on Google Drive yet (%@ MB unsent, %@ uploading, %@ failed). Wait until the upload is done: cloudmachine-agent vm-status":
      "Ещё не всё на Google Drive (%@ MB не отправлено, %@ отправляется, %@ с ошибкой). Дождитесь окончания отправки: cloudmachine-agent vm-status",
    "Restore a file from the encrypted backup first (Time Machine, Browse), then confirm with --restore-checked.":
      "Сначала восстановите файл из зашифрованной копии (Time Machine, Просмотреть), затем подтвердите с --restore-checked.",
    "Shows which folder the machine uses and the copy.":
      "Показывает, какую папку использует машина, и состояние копирования.",
    "Switched:         %@":
      "Переключено:      %@",
    "The copy is already running - see: cloudmachine-agent vm-encrypt status":
      "Копирование уже идёт - см.: cloudmachine-agent vm-encrypt status",
    "The copy runs in the machine (%@, log %@). Backups go on meanwhile. Check: cloudmachine-agent vm-encrypt status":
      "Копирование идёт в машине (%@, журнал %@). Резервное копирование тем временем продолжается. Проверьте: cloudmachine-agent vm-encrypt status",
    "The copy to the encrypted folder has not finished well (%@) - run: cloudmachine-agent vm-encrypt copy, and wait for it.":
      "Копирование в зашифрованную папку не завершилось успешно (%@) - выполните: cloudmachine-agent vm-encrypt copy и дождитесь его.",
    "The encryption password and salt are kept outside this Mac.":
      "Пароль шифрования и соль хранятся вне этого Mac.",
    "The guard holds Time Machine paused and would resume it during the switch. Wait until it resumes and the upload is done.":
      "Страж держит Time Machine на паузе и возобновил бы его во время переключения. Дождитесь возобновления и окончания отправки.",
    "The image metadata has not been copied to the encrypted folder since the last backup - not deleting.":
      "Метаданные образа не копировались в зашифрованную папку после последней резервной копии - ничего не удаляется.",
    "The last sync or cryptcheck failed - the machine was NOT moved: %@":
      "Последняя синхронизация или cryptcheck не удалась - машина НЕ переключена: %@",
    "The machine already uses the encrypted folder - nothing to switch.":
      "Машина уже использует зашифрованную папку - переключать нечего.",
    "The machine already uses the encrypted folder.":
      "Машина уже использует зашифрованную папку.",
    "The machine does not use the encrypted folder - nothing to roll back.":
      "Машина не использует зашифрованную папку - откатывать нечего.",
    "The machine does not use the encrypted folder - the plain folder is the backup. Not deleting it.":
      "Машина не использует зашифрованную папку - резервная копия находится в незашифрованной папке. Папка не удаляется.",
    "The machine has no '%@' remote in its rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "В rclone.conf машины нет remote '%@' - выполните: cloudmachine-agent vm-encrypt setup",
    "The machine is not on this app's template or does not use %@ (cloudmachine-agent vm-update first): %@":
      "Машина не на шаблоне этого приложения или не использует %@ (сначала cloudmachine-agent vm-update): %@",
    "The machine now uses %@, but %@ could not be updated (%@) - fix it before anything else runs vm-setup.":
      "Машина теперь использует %@, но %@ не удалось обновить (%@) - исправьте это, прежде чем что-либо запустит vm-setup.",
    "The machine now uses %@. %@ is kept. Turn automatic backups back on: sudo tmutil enable":
      "Машина теперь использует %@. %@ остаётся. Снова включите автоматическое резервное копирование: sudo tmutil enable",
    "The password must have at least 12 characters.":
      "Пароль должен содержать не менее 12 символов.",
    "The passwords differ - nothing was changed.":
      "Пароли различаются - ничего не изменено.",
    "The switch the other way: decrypts what changed back into the plain folder and uses it again.":
      "Переключение в обратную сторону: расшифровывает изменённое обратно в незашифрованную папку и снова использует её.",
    "The upload to the encrypted folder is not finished (or rclone did not answer) - not deleting.":
      "Отправка в зашифрованную папку не завершена (или rclone не ответил) - ничего не удаляется.",
    "Time Machine is backing up. Turn automatic backups off (sudo tmutil disable), stop it (tmutil stopbackup), then run this again.":
      "Time Machine выполняет резервное копирование. Отключите автоматическое копирование (sudo tmutil disable), остановите текущее копирование (tmutil stopbackup) и запустите это снова.",
    "With Time Machine stopped: last sync, cryptcheck, then the machine uses the encrypted folder. The plain one stays.":
      "При остановленном Time Machine: последняя синхронизация, cryptcheck, затем машина использует зашифрованную папку. Незашифрованная остаётся.",
    "Without the encryption password and salt the encrypted backup cannot be read. Keep both outside this Mac (a password manager, paper), then confirm with --secrets-saved-elsewhere.":
      "Без пароля шифрования и соли зашифрованную копию не прочитать. Храните оба вне этого Mac (менеджер паролей, бумага), затем подтвердите с --secrets-saved-elsewhere.",
    "rclone obscure failed.":
      "Ошибка rclone obscure.",
    "tmutil did not answer - not switching while Time Machine's state is unknown.":
      "tmutil не ответил - переключение не выполняется, пока состояние Time Machine неизвестно.",
  ]
}
