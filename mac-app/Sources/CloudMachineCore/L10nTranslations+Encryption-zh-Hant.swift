// Traditional Chinese translations of vm-encrypt (DriveEncryption), keyed by the English text.
extension L10nTranslations {
  static let zhHantEncryption: [String: String] = [
    "%@ and its metadata are in Google Drive's bin (kept 30 days, still counted in the quota).":
      "%@ 及其後設資料位於 Google Drive 的垃圾桶中（保留 30 天，仍計入配額）。",
    "'%@' is already in %@ - not replacing its password.":
      "'%@' 已在 %@ 中 - 不會取代其密碼。",
    "'%@' is already in the machine's rclone.conf - not replacing its password.":
      "'%@' 已在虛擬機器的 rclone.conf 中 - 不會取代其密碼。",
    "%@ holds folders this key cannot read: another password or salt in the machine, or leftovers of an earlier try. Compare the machine's rclone.conf with the Mac's; leftovers have to be removed from %@ by hand.":
      "%@ 中有此金鑰無法讀取的檔案夾：虛擬機器中的密碼或鹽不同，或是先前嘗試留下的殘餘。請比較虛擬機器的 rclone.conf 與 Mac 上的；殘餘需要手動從 %@ 中刪除。",
    "'%@' is incomplete or missing in the Mac's rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "Mac 的 rclone.conf 中 '%@' 不完整或不存在 - 請執行：cloudmachine-agent vm-encrypt setup",
    "CLOUDMACHINE_VM_INSTANCE=%@ needs its own rclone.conf - set RCLONE_CONFIG to a copy, not %@. Its Keychain entry is service %@.":
      "CLOUDMACHINE_VM_INSTANCE=%@ 需要自己的 rclone.conf - 請將 RCLONE_CONFIG 設為一份副本，而不是 %@。它在鑰匙圈中的項目是服務 %@。",
    "Could not read the '%@' section on the Mac or in the machine.":
      "無法在 Mac 或虛擬機器上讀取 '%@' 區段。",
    "The machine's '%@' (password, salt or folder) differs from the Mac's - the copy would be readable only with the machine's key. Not moving anything.":
      "虛擬機器的 '%@'（密碼、鹽或檔案夾）與 Mac 上的不同 - 副本將只能用虛擬機器的金鑰讀取。不會移動任何內容。",
    "A file was restored from the encrypted backup.":
      "已從加密備份中回復了一個檔案。",
    "Added '%@' (%@) on the Mac and in the machine; password and salt are in the Keychain (service %@).\nSALT: %@\nKeep the password AND this salt outside this Mac now - without both the encrypted backup cannot be read. Next: cloudmachine-agent vm-encrypt copy":
      "已在 Mac 和虛擬機器上加入 '%@'（%@）；密碼和鹽在鑰匙圈中（服務 %@）。\n鹽：%@\n請立即將密碼和這個鹽都保存在這台 Mac 之外 - 缺少任何一個都無法讀取加密備份。下一步：cloudmachine-agent vm-encrypt copy",
    "Adds the encrypted remote on the Mac and in the machine (asks for the password). Moves no data.":
      "在 Mac 和虛擬機器上加入加密的遠端儲存（會詢問密碼）。不移動資料。",
    "Again: ":
      "再輸入一次：",
    "Copies the plain backup into the encrypted folder, in the background; backups go on.":
      "在背景將未加密的備份拷貝到加密檔案夾；備份照常進行。",
    "Copy:             %@":
      "拷貝：            %@",
    "CLOUDMACHINE_VM_INSTANCE=%@ without CLOUDMACHINE_VM_REMOTE would use the live backup's folder - set both.":
      "未設定 CLOUDMACHINE_VM_REMOTE 的 CLOUDMACHINE_VM_INSTANCE=%@ 會使用正在使用的備份檔案夾 - 請兩者都設定。",
    "Could not add the remote to %@: %@":
      "無法將遠端儲存加入 %@：%@",
    "Could not add the remote to the machine's rclone.conf.":
      "無法將遠端儲存加入虛擬機器的 rclone.conf。",
    "Could not read %@.":
      "無法讀取 %@。",
    "Could not read when Time Machine last finished a backup (Full Disk Access?) - not deleting.":
      "無法讀取 Time Machine 上次完成備份的時間（「完整磁碟取用權限」？）- 不刪除。",
    "Could not start the copy: %@":
      "無法開始拷貝：%@",
    "Could not write %@.":
      "無法寫入 %@。",
    "Deleting the plain folder failed: %@":
      "刪除未加密檔案夾失敗：%@",
    "Encrypted folder: %@":
      "加密檔案夾：      %@",
    "Encryption password: ":
      "加密密碼：",
    "Machine uses:     %@":
      "虛擬機器使用：    %@",
    "Moves the backup on Google Drive under rclone encryption: setup, copy, switch, then delete-plain.":
      "將 Google Drive 上的備份移到 rclone 加密之下：setup、copy、switch，然後 delete-plain。",
    "Moves the plain folder to Google Drive's bin - only after a backup has finished into the encrypted one.":
      "將未加密檔案夾移到 Google Drive 的垃圾桶 - 僅在一次備份已完成到加密檔案夾之後。",
    "Moving the machine failed; it went back to %@: %@":
      "切換虛擬機器失敗；它已回到 %@：%@",
    "No answer from rclone in the machine - the upload queue is unknown.":
      "虛擬機器中的 rclone 沒有回應 - 上傳佇列未知。",
    "No backup has finished into the encrypted folder yet (last one %@, switched %@) - not deleting.":
      "尚無備份完成到加密檔案夾（最近一次 %@，切換於 %@）- 不刪除。",
    "Not everything is on Google Drive yet (%@ MB unsent, %@ uploading, %@ failed). Wait until the upload is done: cloudmachine-agent vm-status":
      "尚未全部上傳到 Google Drive（%@ MB 未傳送，%@ 個上傳中，%@ 個失敗）。請等待上傳完成：cloudmachine-agent vm-status",
    "Restore a file from the encrypted backup first (Time Machine, Browse), then confirm with --restore-checked.":
      "請先從加密備份中回復一個檔案（Time Machine，瀏覽），然後用 --restore-checked 確認。",
    "Shows which folder the machine uses and the copy.":
      "顯示虛擬機器使用哪個檔案夾以及拷貝狀態。",
    "Switched:         %@":
      "切換於：          %@",
    "The copy is already running - see: cloudmachine-agent vm-encrypt status":
      "拷貝已在執行 - 查看：cloudmachine-agent vm-encrypt status",
    "The copy runs in the machine (%@, log %@). Backups go on meanwhile. Check: cloudmachine-agent vm-encrypt status":
      "拷貝正在虛擬機器中執行（%@，記錄 %@）。在此期間備份照常進行。檢查：cloudmachine-agent vm-encrypt status",
    "The copy to the encrypted folder has not finished well (%@) - run: cloudmachine-agent vm-encrypt copy, and wait for it.":
      "拷貝到加密檔案夾未能順利完成（%@）- 請執行：cloudmachine-agent vm-encrypt copy，並等待其完成。",
    "The encryption password and salt are kept outside this Mac.":
      "加密密碼和鹽保存在這台 Mac 之外。",
    "The guard holds Time Machine paused and would resume it during the switch. Wait until it resumes and the upload is done.":
      "緩衝區守護程式讓 Time Machine 處於暫停狀態，並會在切換期間繼續它。請等到它繼續且上傳完成。",
    "The image metadata has not been copied to the encrypted folder since the last backup - not deleting.":
      "自上次備份以來，映像檔的後設資料尚未拷貝到加密檔案夾 - 不刪除。",
    "The last sync or cryptcheck failed - the machine was NOT moved: %@":
      "最後一次同步或 cryptcheck 失敗 - 虛擬機器未切換：%@",
    "The machine already uses the encrypted folder - nothing to switch.":
      "虛擬機器已在使用加密檔案夾 - 無需切換。",
    "The machine already uses the encrypted folder.":
      "虛擬機器已在使用加密檔案夾。",
    "The machine does not use the encrypted folder - nothing to roll back.":
      "虛擬機器未使用加密檔案夾 - 無可還原。",
    "The machine does not use the encrypted folder - the plain folder is the backup. Not deleting it.":
      "虛擬機器未使用加密檔案夾 - 未加密檔案夾就是備份。不刪除它。",
    "The machine has no '%@' remote in its rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "虛擬機器的 rclone.conf 中沒有遠端儲存 '%@' - 請執行：cloudmachine-agent vm-encrypt setup",
    "The machine is not on this app's template or does not use %@ (cloudmachine-agent vm-update first): %@":
      "虛擬機器不在此 App 的範本上，或未使用 %@（請先執行 cloudmachine-agent vm-update）：%@",
    "The machine now uses %@, but %@ could not be updated (%@) - fix it before anything else runs vm-setup.":
      "虛擬機器現在使用 %@，但無法更新 %@（%@）- 請在其他任何程式執行 vm-setup 之前修正。",
    "The machine now uses %@. %@ is kept. Turn automatic backups back on: sudo tmutil enable":
      "虛擬機器現在使用 %@。%@ 予以保留。請重新開啟自動備份：sudo tmutil enable",
    "The password must have at least 12 characters.":
      "密碼至少需要 12 個字元。",
    "The passwords differ - nothing was changed.":
      "兩次密碼不同 - 未做任何更改。",
    "The switch the other way: decrypts what changed back into the plain folder and uses it again.":
      "反向切換：把已更改的內容解密回未加密檔案夾，並重新使用它。",
    "The upload to the encrypted folder is not finished (or rclone did not answer) - not deleting.":
      "上傳到加密檔案夾尚未完成（或 rclone 沒有回應）- 不刪除。",
    "Time Machine is backing up. Turn automatic backups off (sudo tmutil disable), stop it (tmutil stopbackup), then run this again.":
      "Time Machine 正在備份。請關閉自動備份（sudo tmutil disable），停止它（tmutil stopbackup），然後再次執行此指令。",
    "With Time Machine stopped: last sync, cryptcheck, then the machine uses the encrypted folder. The plain one stays.":
      "在 Time Machine 停止時：最後一次同步、cryptcheck，然後虛擬機器使用加密檔案夾。未加密檔案夾保留。",
    "Without the encryption password and salt the encrypted backup cannot be read. Keep both outside this Mac (a password manager, paper), then confirm with --secrets-saved-elsewhere.":
      "沒有加密密碼和鹽就無法讀取加密備份。請將兩者都保存在這台 Mac 之外（密碼管理器、紙張），然後用 --secrets-saved-elsewhere 確認。",
    "rclone obscure failed.":
      "rclone obscure 失敗。",
    "tmutil did not answer - not switching while Time Machine's state is unknown.":
      "tmutil 沒有回應 - 在 Time Machine 狀態未知時不進行切換。",
  ]
}
