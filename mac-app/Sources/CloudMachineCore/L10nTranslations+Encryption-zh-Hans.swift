// Simplified Chinese translations of vm-encrypt (DriveEncryption), keyed by the English text.
extension L10nTranslations {
  static let zhHansEncryption: [String: String] = [
    "%@ and its metadata are in Google Drive's bin (kept 30 days, still counted in the quota).":
      "%@ 及其元数据位于 Google Drive 的回收站中（保留 30 天，仍计入配额）。",
    "'%@' is already in %@ - not replacing its password.":
      "'%@' 已在 %@ 中 - 不会替换其密码。",
    "'%@' is already in the machine's rclone.conf - not replacing its password.":
      "'%@' 已在虚拟机的 rclone.conf 中 - 不会替换其密码。",
    "%@ holds folders this key cannot read: another password or salt in the machine, or leftovers of an earlier try. Compare the machine's rclone.conf with the Mac's; leftovers have to be removed from %@ by hand.":
      "%@ 中有此密钥无法读取的文件夹：虚拟机中的密码或盐不同，或是之前尝试留下的残余。请比较虚拟机的 rclone.conf 与 Mac 上的；残余需要手动从 %@ 中删除。",
    "'%@' is incomplete or missing in the Mac's rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "Mac 的 rclone.conf 中 '%@' 不完整或不存在 - 请运行：cloudmachine-agent vm-encrypt setup",
    "CLOUDMACHINE_VM_INSTANCE=%@ needs its own rclone.conf - set RCLONE_CONFIG to a copy, not %@. Its Keychain entry is service %@.":
      "CLOUDMACHINE_VM_INSTANCE=%@ 需要自己的 rclone.conf - 请将 RCLONE_CONFIG 设为一份副本，而不是 %@。它在钥匙串中的条目是服务 %@。",
    "Could not read the '%@' section on the Mac or in the machine.":
      "无法在 Mac 或虚拟机上读取 '%@' 部分。",
    "The machine's '%@' (password, salt or folder) differs from the Mac's - the copy would be readable only with the machine's key. Not moving anything.":
      "虚拟机的 '%@'（密码、盐或文件夹）与 Mac 上的不同 - 副本将只能用虚拟机的密钥读取。不会移动任何内容。",
    "A file was restored from the encrypted backup.":
      "已从加密备份中恢复了一个文件。",
    "Added '%@' (%@) on the Mac and in the machine; password and salt are in the Keychain (service %@).\nSALT: %@\nKeep the password AND this salt outside this Mac now - without both the encrypted backup cannot be read. Next: cloudmachine-agent vm-encrypt copy":
      "已在 Mac 和虚拟机上添加 '%@'（%@）；密码和盐在钥匙串中（服务 %@）。\n盐：%@\n请立即将密码和这个盐都保存在这台 Mac 之外 - 缺少任何一个都无法读取加密备份。下一步：cloudmachine-agent vm-encrypt copy",
    "Adds the encrypted remote on the Mac and in the machine (asks for the password). Moves no data.":
      "在 Mac 和虚拟机上添加加密的远程存储（会询问密码）。不移动数据。",
    "Again: ":
      "再输入一次：",
    "Copies the plain backup into the encrypted folder, in the background; backups go on.":
      "在后台将未加密的备份复制到加密文件夹；备份照常进行。",
    "Copy:             %@":
      "复制：            %@",
    "CLOUDMACHINE_VM_INSTANCE=%@ without CLOUDMACHINE_VM_REMOTE would use the live backup's folder - set both.":
      "不设置 CLOUDMACHINE_VM_REMOTE 的 CLOUDMACHINE_VM_INSTANCE=%@ 会使用正在使用的备份文件夹 - 请两者都设置。",
    "Could not add the remote to %@: %@":
      "无法将远程存储添加到 %@：%@",
    "Could not add the remote to the machine's rclone.conf.":
      "无法将远程存储添加到虚拟机的 rclone.conf。",
    "Could not read %@.":
      "无法读取 %@。",
    "Could not read when Time Machine last finished a backup (Full Disk Access?) - not deleting.":
      "无法读取 Time Machine 上次完成备份的时间（完全磁盘访问权限？）- 不删除。",
    "Could not start the copy: %@":
      "无法开始复制：%@",
    "Could not write %@.":
      "无法写入 %@。",
    "Deleting the plain folder failed: %@":
      "删除未加密文件夹失败：%@",
    "Encrypted folder: %@":
      "加密文件夹：      %@",
    "Encryption password: ":
      "加密密码：",
    "Machine uses:     %@":
      "虚拟机使用：      %@",
    "Moves the backup on Google Drive under rclone encryption: setup, copy, switch, then delete-plain.":
      "将 Google Drive 上的备份移到 rclone 加密之下：setup、copy、switch，然后 delete-plain。",
    "Moves the plain folder to Google Drive's bin - only after a backup has finished into the encrypted one.":
      "将未加密文件夹移到 Google Drive 的回收站 - 仅在一次备份已完成到加密文件夹之后。",
    "Moving the machine failed; it went back to %@: %@":
      "切换虚拟机失败；它已回到 %@：%@",
    "No answer from rclone in the machine - the upload queue is unknown.":
      "虚拟机中的 rclone 没有响应 - 上传队列未知。",
    "No backup has finished into the encrypted folder yet (last one %@, switched %@) - not deleting.":
      "尚无备份完成到加密文件夹（最近一次 %@，切换于 %@）- 不删除。",
    "Not everything is on Google Drive yet (%@ MB unsent, %@ uploading, %@ failed). Wait until the upload is done: cloudmachine-agent vm-status":
      "尚未全部上传到 Google Drive（%@ MB 未发送，%@ 个上传中，%@ 个失败）。请等待上传完成：cloudmachine-agent vm-status",
    "Restore a file from the encrypted backup first (Time Machine, Browse), then confirm with --restore-checked.":
      "请先从加密备份中恢复一个文件（Time Machine，浏览），然后用 --restore-checked 确认。",
    "Shows which folder the machine uses and the copy.":
      "显示虚拟机使用哪个文件夹以及复制状态。",
    "Switched:         %@":
      "切换于：          %@",
    "The copy is already running - see: cloudmachine-agent vm-encrypt status":
      "复制已在运行 - 查看：cloudmachine-agent vm-encrypt status",
    "The copy runs in the machine (%@, log %@). Backups go on meanwhile. Check: cloudmachine-agent vm-encrypt status":
      "复制正在虚拟机中运行（%@，日志 %@）。在此期间备份照常进行。检查：cloudmachine-agent vm-encrypt status",
    "The copy to the encrypted folder has not finished well (%@) - run: cloudmachine-agent vm-encrypt copy, and wait for it.":
      "复制到加密文件夹未能顺利完成（%@）- 请运行：cloudmachine-agent vm-encrypt copy，并等待其完成。",
    "The encryption password and salt are kept outside this Mac.":
      "加密密码和盐保存在这台 Mac 之外。",
    "The guard holds Time Machine paused and would resume it during the switch. Wait until it resumes and the upload is done.":
      "缓冲区守护程序让 Time Machine 处于暂停状态，并会在切换期间恢复它。请等到它恢复且上传完成。",
    "The image metadata has not been copied to the encrypted folder since the last backup - not deleting.":
      "自上次备份以来，映像的元数据尚未复制到加密文件夹 - 不删除。",
    "The last sync or cryptcheck failed - the machine was NOT moved: %@":
      "最后一次同步或 cryptcheck 失败 - 虚拟机未切换：%@",
    "The machine already uses the encrypted folder - nothing to switch.":
      "虚拟机已在使用加密文件夹 - 无需切换。",
    "The machine already uses the encrypted folder.":
      "虚拟机已在使用加密文件夹。",
    "The machine does not use the encrypted folder - nothing to roll back.":
      "虚拟机未使用加密文件夹 - 无可回滚。",
    "The machine does not use the encrypted folder - the plain folder is the backup. Not deleting it.":
      "虚拟机未使用加密文件夹 - 未加密文件夹就是备份。不删除它。",
    "The machine has no '%@' remote in its rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "虚拟机的 rclone.conf 中没有远程存储 '%@' - 请运行：cloudmachine-agent vm-encrypt setup",
    "The machine is not on this app's template or does not use %@ (cloudmachine-agent vm-update first): %@":
      "虚拟机不在此应用的模板上，或未使用 %@（请先运行 cloudmachine-agent vm-update）：%@",
    "The machine now uses %@, but %@ could not be updated (%@) - fix it before anything else runs vm-setup.":
      "虚拟机现在使用 %@，但无法更新 %@（%@）- 请在其他任何程序运行 vm-setup 之前修正。",
    "The machine now uses %@. %@ is kept. Turn automatic backups back on: sudo tmutil enable":
      "虚拟机现在使用 %@。%@ 予以保留。请重新打开自动备份：sudo tmutil enable",
    "The password must have at least 12 characters.":
      "密码至少需要 12 个字符。",
    "The passwords differ - nothing was changed.":
      "两次密码不同 - 未做任何更改。",
    "The switch the other way: decrypts what changed back into the plain folder and uses it again.":
      "反向切换：把已更改的内容解密回未加密文件夹，并重新使用它。",
    "The upload to the encrypted folder is not finished (or rclone did not answer) - not deleting.":
      "上传到加密文件夹尚未完成（或 rclone 没有响应）- 不删除。",
    "Time Machine is backing up. Turn automatic backups off (sudo tmutil disable), stop it (tmutil stopbackup), then run this again.":
      "Time Machine 正在备份。请关闭自动备份（sudo tmutil disable），停止它（tmutil stopbackup），然后再次运行此命令。",
    "With Time Machine stopped: last sync, cryptcheck, then the machine uses the encrypted folder. The plain one stays.":
      "在 Time Machine 停止时：最后一次同步、cryptcheck，然后虚拟机使用加密文件夹。未加密文件夹保留。",
    "Without the encryption password and salt the encrypted backup cannot be read. Keep both outside this Mac (a password manager, paper), then confirm with --secrets-saved-elsewhere.":
      "没有加密密码和盐就无法读取加密备份。请将两者都保存在这台 Mac 之外（密码管理器、纸张），然后用 --secrets-saved-elsewhere 确认。",
    "rclone obscure failed.":
      "rclone obscure 失败。",
    "tmutil did not answer - not switching while Time Machine's state is unknown.":
      "tmutil 没有响应 - 在 Time Machine 状态未知时不进行切换。",
  ]
}
