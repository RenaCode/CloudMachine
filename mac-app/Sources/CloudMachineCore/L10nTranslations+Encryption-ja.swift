// Japanese translations of vm-encrypt (DriveEncryption), keyed by the English text.
extension L10nTranslations {
  static let jaEncryption: [String: String] = [
    "%@ and its metadata are in Google Drive's bin (kept 30 days, still counted in the quota).":
      "%@ とそのメタデータは Google Drive のゴミ箱にあります(30日間保持され、引き続き容量に含まれます)。",
    "'%@' is already in %@ - not replacing its password.":
      "'%@' はすでに %@ にあります - パスワードは置き換えません。",
    "'%@' is already in the machine's rclone.conf - not replacing its password.":
      "'%@' はすでにマシンの rclone.conf にあります - パスワードは置き換えません。",
    "%@ holds folders this key cannot read: another password or salt in the machine, or leftovers of an earlier try. Compare the machine's rclone.conf with the Mac's; leftovers have to be removed from %@ by hand.":
      "%@ には、このキーで読めないフォルダがあります: マシン内のパスワードまたはソルトが異なるか、以前の試行の残りです。マシンの rclone.conf と Mac のものを比較してください。残りは %@ から手動で削除する必要があります。",
    "'%@' is incomplete or missing in the Mac's rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "'%@' が Mac の rclone.conf にないか不完全です - 次を実行してください: cloudmachine-agent vm-encrypt setup",
    "CLOUDMACHINE_VM_INSTANCE=%@ needs its own rclone.conf - set RCLONE_CONFIG to a copy, not %@. Its Keychain entry is service %@.":
      "CLOUDMACHINE_VM_INSTANCE=%@ には専用の rclone.conf が必要です - RCLONE_CONFIG を %@ ではなくコピーに設定してください。キーチェーンの項目はサービス %@ です。",
    "Could not read the '%@' section on the Mac or in the machine.":
      "Mac またはマシンで '%@' セクションを読み取れませんでした。",
    "The machine's '%@' (password, salt or folder) differs from the Mac's - the copy would be readable only with the machine's key. Not moving anything.":
      "マシンの '%@'(パスワード、ソルト、フォルダ)が Mac のものと異なります - コピーはマシンのキーでしか読めなくなります。何も移動しません。",
    "A file was restored from the encrypted backup.":
      "暗号化されたバックアップからファイルを復元しました。",
    "Added '%@' (%@) on the Mac and in the machine; password and salt are in the Keychain (service %@).\nSALT: %@\nKeep the password AND this salt outside this Mac now - without both the encrypted backup cannot be read. Next: cloudmachine-agent vm-encrypt copy":
      "'%@'(%@)を Mac とマシンに追加しました。パスワードとソルトはキーチェーンにあります(サービス %@)。\nソルト: %@\n今すぐパスワードとこのソルトの両方をこの Mac の外に保管してください - 両方がないと暗号化されたバックアップは読めません。次: cloudmachine-agent vm-encrypt copy",
    "Adds the encrypted remote on the Mac and in the machine (asks for the password). Moves no data.":
      "暗号化された remote を Mac とマシンに追加します(パスワードを尋ねます)。データは移動しません。",
    "Again: ":
      "もう一度: ",
    "Copies the plain backup into the encrypted folder, in the background; backups go on.":
      "暗号化されていないバックアップを暗号化フォルダへバックグラウンドでコピーします。バックアップは続行します。",
    "Copy:             %@":
      "コピー:           %@",
    "CLOUDMACHINE_VM_INSTANCE=%@ without CLOUDMACHINE_VM_REMOTE would use the live backup's folder - set both.":
      "CLOUDMACHINE_VM_INSTANCE=%@ を CLOUDMACHINE_VM_REMOTE なしで使うと、稼働中のバックアップのフォルダを使ってしまいます - 両方を設定してください。",
    "Could not add the remote to %@: %@":
      "%@ に remote を追加できませんでした: %@",
    "Could not add the remote to the machine's rclone.conf.":
      "マシンの rclone.conf に remote を追加できませんでした。",
    "Could not read %@.":
      "%@ を読み取れませんでした。",
    "Could not read when Time Machine last finished a backup (Full Disk Access?) - not deleting.":
      "Time Machine が最後にバックアップを完了した日時を読み取れませんでした(フルディスクアクセス?) - 削除しません。",
    "Could not start the copy: %@":
      "コピーを開始できませんでした: %@",
    "Could not write %@.":
      "%@ に書き込めませんでした。",
    "Deleting the plain folder failed: %@":
      "暗号化されていないフォルダの削除に失敗しました: %@",
    "Encrypted folder: %@":
      "暗号化フォルダ:   %@",
    "Encryption password: ":
      "暗号化パスワード: ",
    "Machine uses:     %@":
      "マシンの使用先:   %@",
    "Moves the backup on Google Drive under rclone encryption: setup, copy, switch, then delete-plain.":
      "Google Drive 上のバックアップを rclone の暗号化の下に移します: setup、copy、switch、その後 delete-plain。",
    "Moves the plain folder to Google Drive's bin - only after a backup has finished into the encrypted one.":
      "暗号化されていないフォルダを Google Drive のゴミ箱に移します - 暗号化フォルダへのバックアップが完了した後のみ。",
    "Moving the machine failed; it went back to %@: %@":
      "マシンの切り替えに失敗しました。%@ に戻りました: %@",
    "No answer from rclone in the machine - the upload queue is unknown.":
      "マシン内の rclone から応答がありません - アップロードキューの状態は不明です。",
    "No backup has finished into the encrypted folder yet (last one %@, switched %@) - not deleting.":
      "暗号化フォルダへのバックアップはまだ1回も完了していません(最後 %@、切り替え %@) - 削除しません。",
    "Not everything is on Google Drive yet (%@ MB unsent, %@ uploading, %@ failed). Wait until the upload is done: cloudmachine-agent vm-status":
      "まだすべてが Google Drive にあるわけではありません(未送信 %@ MB、アップロード中 %@、失敗 %@)。アップロードが終わるまで待ってください: cloudmachine-agent vm-status",
    "Restore a file from the encrypted backup first (Time Machine, Browse), then confirm with --restore-checked.":
      "まず暗号化されたバックアップからファイルを1つ復元し(Time Machine、ブラウズ)、その後 --restore-checked で確認してください。",
    "Shows which folder the machine uses and the copy.":
      "マシンが使っているフォルダとコピーの状態を表示します。",
    "Switched:         %@":
      "切り替え:         %@",
    "The copy is already running - see: cloudmachine-agent vm-encrypt status":
      "コピーはすでに実行中です - 確認: cloudmachine-agent vm-encrypt status",
    "The copy runs in the machine (%@, log %@). Backups go on meanwhile. Check: cloudmachine-agent vm-encrypt status":
      "コピーはマシン内で実行中です(%@、ログ %@)。その間もバックアップは続行します。確認: cloudmachine-agent vm-encrypt status",
    "The copy to the encrypted folder has not finished well (%@) - run: cloudmachine-agent vm-encrypt copy, and wait for it.":
      "暗号化フォルダへのコピーが正常に終わっていません(%@) - 次を実行し、完了するまで待ってください: cloudmachine-agent vm-encrypt copy",
    "The encryption password and salt are kept outside this Mac.":
      "暗号化パスワードとソルトはこの Mac の外に保管されています。",
    "The guard holds Time Machine paused and would resume it during the switch. Wait until it resumes and the upload is done.":
      "ガードが Time Machine を一時停止しており、切り替え中に再開してしまいます。再開してアップロードが終わるまで待ってください。",
    "The image metadata has not been copied to the encrypted folder since the last backup - not deleting.":
      "前回のバックアップ以降、イメージのメタデータが暗号化フォルダにコピーされていません - 削除しません。",
    "The last sync or cryptcheck failed - the machine was NOT moved: %@":
      "最後の同期または cryptcheck に失敗しました - マシンは切り替えられていません: %@",
    "The machine already uses the encrypted folder - nothing to switch.":
      "マシンはすでに暗号化フォルダを使っています - 切り替えるものはありません。",
    "The machine already uses the encrypted folder.":
      "マシンはすでに暗号化フォルダを使っています。",
    "The machine does not use the encrypted folder - nothing to roll back.":
      "マシンは暗号化フォルダを使っていません - 戻すものはありません。",
    "The machine does not use the encrypted folder - the plain folder is the backup. Not deleting it.":
      "マシンは暗号化フォルダを使っていません - 暗号化されていないフォルダがバックアップです。削除しません。",
    "The machine has no '%@' remote in its rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "マシンの rclone.conf に remote '%@' がありません - 次を実行してください: cloudmachine-agent vm-encrypt setup",
    "The machine is not on this app's template or does not use %@ (cloudmachine-agent vm-update first): %@":
      "マシンがこのAppのテンプレートではないか、%@ を使っていません(先に cloudmachine-agent vm-update を実行してください): %@",
    "The machine now uses %@, but %@ could not be updated (%@) - fix it before anything else runs vm-setup.":
      "マシンは現在 %@ を使っていますが、%@ を更新できませんでした(%@) - 他の何かが vm-setup を実行する前に修正してください。",
    "The machine now uses %@. %@ is kept. Turn automatic backups back on: sudo tmutil enable":
      "マシンは現在 %@ を使っています。%@ は残してあります。自動バックアップを再びオンにしてください: sudo tmutil enable",
    "The password must have at least 12 characters.":
      "パスワードは12文字以上にしてください。",
    "The passwords differ - nothing was changed.":
      "パスワードが一致しません - 何も変更していません。",
    "The switch the other way: decrypts what changed back into the plain folder and uses it again.":
      "逆方向の切り替え: 変更された分を暗号化されていないフォルダへ復号し、再びそれを使います。",
    "The upload to the encrypted folder is not finished (or rclone did not answer) - not deleting.":
      "暗号化フォルダへのアップロードが終わっていません(または rclone が応答しませんでした) - 削除しません。",
    "Time Machine is backing up. Turn automatic backups off (sudo tmutil disable), stop it (tmutil stopbackup), then run this again.":
      "Time Machine がバックアップ中です。自動バックアップをオフにし(sudo tmutil disable)、停止して(tmutil stopbackup)から、もう一度実行してください。",
    "With Time Machine stopped: last sync, cryptcheck, then the machine uses the encrypted folder. The plain one stays.":
      "Time Machine を停止した状態で: 最後の同期、cryptcheck、その後マシンが暗号化フォルダを使います。暗号化されていないフォルダは残ります。",
    "Without the encryption password and salt the encrypted backup cannot be read. Keep both outside this Mac (a password manager, paper), then confirm with --secrets-saved-elsewhere.":
      "暗号化パスワードとソルトがないと、暗号化されたバックアップは読めません。両方をこの Mac の外(パスワードマネージャ、紙)に保管し、その後 --secrets-saved-elsewhere で確認してください。",
    "rclone obscure failed.":
      "rclone obscure に失敗しました。",
    "tmutil did not answer - not switching while Time Machine's state is unknown.":
      "tmutil から応答がありません - Time Machine の状態が不明な間は切り替えません。",
  ]
}
