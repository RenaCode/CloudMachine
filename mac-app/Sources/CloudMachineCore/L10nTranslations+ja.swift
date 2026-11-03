// Japanese translations, keyed by the English text passed to `L10n.tr`.
extension L10nTranslations {
  static let ja: [String: String] = [
    "Space limit:      %@":
      "容量の上限:       %@",
    "                  Time Machine quota not set to match - run: %@":
      "                  Time Machineの容量制限が一致していません - 次を実行してください: %@",
    "Sets how much of Google Drive this Mac may use, and prints the Time Machine quota command.":
      "このMacが使用できるGoogle Driveの容量を設定し、Time Machineの容量制限を設定するコマンドを表示します。",
    "Limit in GB.":
      "上限(GB単位)。",
    "Limit for this Mac: %@ GB.":
      "このMacの上限: %@ GB。",
    "Now set the Time Machine quota (needs an administrator password):":
      "続いて、Time Machineの容量制限を設定してください(管理者パスワードが必要です):",
    "CloudMachine - verification, Google Drive setup and installation. Called by launchd on a schedule, or by hand from Terminal.":
      "CloudMachine - 検証、Google Driveの設定、インストールを行います。launchdにより定期的に実行されるか、ターミナルから手動で実行します。",
    "Connects to Google Drive through rclone (OAuth in the browser) and creates this machine's folder.":
      "rclone(ブラウザでOAuth)を使ってGoogle Driveに接続し、このマシンのフォルダを作成します。",
    "Overwrite the existing remote. RISKY: replaces the token and permissions.":
      "既存のremoteを上書きします。危険: トークンと権限が置き換えられます。",
    "Packs build/CloudMachine.app into build/CloudMachine-<version>.dmg.":
      "build/CloudMachine.appをbuild/CloudMachine-<バージョン>.dmgにまとめます。",
    "ERROR: %@ is missing - run 'cloudmachine-agent build-app' first":
      "エラー: %@ がありません - 先に 'cloudmachine-agent build-app' を実行してください",
    "==> Preparing the staging folder":
      "==> ステージングフォルダを準備しています",
    "==> Creating %@":
      "==> %@ を作成しています",
    "ERROR: hdiutil exited with code %@.":
      "エラー: hdiutilがコード %@ で終了しました。",
    "==> Done: %@":
      "==> 完了: %@",
    "On first launch (the app is not signed with an Apple Developer account):":
      "初回の起動時(このAppはApple Developerアカウントで署名されていません):",
    "1. Open %@ and drag CloudMachine.app to Applications.":
      "1. %@ を開き、CloudMachine.appをアプリケーションフォルダにドラッグします。",
    "2. In Finder, RIGHT-click CloudMachine.app -> Open -> Open\n   (a plain double-click shows the Gatekeeper block \"unidentified developer\").":
      "2. Finderで、CloudMachine.appを右クリックして「開く」->「開く」を選びます\n   (そのままダブルクリックすると、Gatekeeperが「開発元を確認できません」と表示してブロックします)。",
    "3. Later launches work normally, with a double-click.":
      "3. 2回目以降は、通常どおりダブルクリックで起動できます。",
    "Builds CloudMachine.app (Release) - GUI + cloudmachine-agent in Contents/MacOS/, plus launchd/, vm/ and config/ as Resources.":
      "CloudMachine.app(Release)をビルドします - GUIとcloudmachine-agentはContents/MacOS/に、launchd/、vm/、config/はResourcesとして含まれます。",
    "Binaries for Apple Silicon and Intel at once (how CI builds a release; unnecessary locally).":
      "Apple SiliconとIntel向けのバイナリを同時に作成します(CIがリリースをビルドする方法です。ローカルでは不要)。",
    "==> Building CloudMachineApp + cloudmachine-agent (release) - version %@ (%@)":
      "==> CloudMachineApp + cloudmachine-agent をビルドしています(release) - バージョン %@ (%@)",
    "ERROR: swift build exited with code %@.":
      "エラー: swift buildがコード %@ で終了しました。",
    "ERROR: swift build --show-bin-path did not report the binaries directory.":
      "エラー: swift build --show-bin-path がバイナリのディレクトリを返しませんでした。",
    "ERROR: no built binary found at %@":
      "エラー: ビルド済みのバイナリが %@ に見つかりません",
    "==> Assembling the .app bundle in %@":
      "==> %@ に.appバンドルを組み立てています",
    "==> WARNING: you are building from a DIRTY tree - the version will not point to a commit.":
      "==> 警告: 未コミットの変更がある状態でビルドしています - バージョンはどのコミットにも対応しません。",
    "ERROR: Resources/AppIcon.icns is missing - generate it: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns":
      "エラー: Resources/AppIcon.icns がありません - 次で生成してください: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns",
    "==> Signing with the local certificate '%@' (Full Disk Access will survive later rebuilds)":
      "==> ローカル証明書 '%@' で署名しています(以降の再ビルド後もフルディスクアクセスが維持されます)",
    "==> Signing ad-hoc (no Apple Developer account) - run 'cloudmachine-agent setup-signing-cert' once so that TCC permissions survive later rebuilds":
      "==> アドホック署名しています(Apple Developerアカウントなし) - 以降の再ビルド後もTCCの権限が維持されるよう、'cloudmachine-agent setup-signing-cert' を一度実行してください",
    "ERROR: codesign exited with code %@.":
      "エラー: codesignがコード %@ で終了しました。",
    "Next step: %@":
      "次のステップ: %@",
    "Creates a local self-signed certificate so that Full Disk Access survives later rebuilds of the app.":
      "ローカルの自己署名証明書を作成し、以降のAppの再ビルド後もフルディスクアクセスが維持されるようにします。",
    "Certificate '%@' already exists in %@, nothing to do.":
      "証明書 '%1$@' は %2$@ にすでに存在するため、何もしません。",
    "==> Generating the key and self-signed certificate '%@'...":
      "==> キーと自己署名証明書 '%@' を生成しています...",
    "ERROR: openssl req exited with code %@.":
      "エラー: openssl reqがコード %@ で終了しました。",
    "ERROR: openssl pkcs12 exited with code %@.":
      "エラー: openssl pkcs12がコード %@ で終了しました。",
    "==> Importing the certificate into %@ (pre-authorizing /usr/bin/codesign, so it does not ask for the keychain password every time)...":
      "==> 証明書を %@ に読み込んでいます(/usr/bin/codesignを事前に許可するため、毎回キーチェーンのパスワードを求められることはありません)...",
    "ERROR: security import exited with code %@.":
      "エラー: security importがコード %@ で終了しました。",
    "==> Trusting the certificate ONLY for code signing...":
      "==> 証明書をコード署名の用途にのみ信頼します...",
    "ERROR: security add-trusted-cert exited with code %@.":
      "エラー: security add-trusted-certがコード %@ で終了しました。",
    "Done. Certificate '%@' is now available to codesign.":
      "完了。証明書 '%@' をcodesignで使用できるようになりました。",
    "The next 'cloudmachine-agent build-app' will use it automatically instead of an ad-hoc signature.":
      "次回の 'cloudmachine-agent build-app' では、アドホック署名の代わりにこの証明書が自動的に使用されます。",
    "After THAT ONE rebuild, grant Full Disk Access one last time - later\nrebuilds will no longer reset it, as long as you sign with the same certificate.":
      "その再ビルドを1回行ったあとで、フルディスクアクセスをもう一度だけ許可してください。以降は\n同じ証明書で署名している限り、再ビルドしても許可がリセットされなくなります。",
    "Checks whether the hourly cycle STILL works (date of the last SUCCESSFUL backup) and reports failures.":
      "1時間ごとのサイクルが引き続き動作しているか(最後に成功したバックアップの日時)を確認し、障害を報告します。",
    "After this many hours without a successful backup we consider the cycle broken.":
      "成功したバックアップがないまま、この時間数が経過したら、サイクルが停止したとみなします。",
    "Only print the state, without a system notification.":
      "システム通知は出さず、状態のみを表示します。",
    "A different Time Machine preferences file - to test the watchdog on a known sample.":
      "別のTime Machine環境設定ファイル - 既知のサンプルで監視をテストするためのものです。",
    "Last successful backup: %@":
      "最後に成功したバックアップ: %@",
    "Last successful backup: NONE":
      "最後に成功したバックアップ: なし",
    "Last attempt:           %@":
      "最後の試行:             %@",
    "WAITING (system startup): %@":
      "待機中(システム起動時): %@",
    "Backup cycle: OK":
      "バックアップサイクル: 正常",
    "FAILURE: %@":
      "障害: %@",
    "         %@":
      "         %@",
    "Check the state:  %@":
      "状態を確認:  %@",
    "Preparing for restart":
      "再起動の準備中",
    "Prepare for restart":
      "再起動の準備",
    "Prepare":
      "準備",
    "==> WARNING: git rev-list failed (%@) - using the date as the build number.":
      "==> 警告: git rev-listが失敗しました(%@) - ビルド番号の代わりに日付を使用します。",
    "Agents:           %@":
      "エージェント:     %@",
    "CANNOT START: %@ - open CloudMachine or run backup-health to reload them":
      "起動できません: %@ - CloudMachineを開くか、backup-healthを実行して再読み込みしてください",
    "Reloaded agents that could not start: %@":
      "起動できなかったエージェントを再読み込みしました: %@",
    "Drive folder:     %@":
      "Driveのフォルダ:  %@",
    "Name of this Mac's folder on Google Drive (default: derived from the computer name). Set once; it cannot be changed later.":
      "Google Drive上のこのMacのフォルダ名です(既定値: コンピュータ名から生成)。一度だけ設定でき、あとから変更することはできません。",
    "Backup watchdog:  %@":
      "バックアップ監視: %@",
    "Prints the version, the build number and the commit this binary was built from.":
      "バージョン、ビルド番号、このバイナリのビルド元のコミットを表示します。",
    "Only one line, without a description.":
      "説明なしで1行だけ表示します。",
    "Build from the working tree (outside a bundle) - no version data.":
      "作業ツリーからのビルド(バンドル外) - バージョン情報はありません。",
    "Version: %@":
      "バージョン: %@",
    "Build:   %@":
      "ビルド:     %@",
    "Commit:  %@":
      "コミット:   %@",
    "WARNING: built from a DIRTY tree - the binary contains code that\n         is in no commit. The commit number does NOT describe\n         what actually runs.":
      "警告: 未コミットの変更がある状態でビルドされています - このバイナリには、\n      どのコミットにも含まれていないコードが入っています。コミット番号は\n      実際に動作している内容を表していません。",
    "Saving the space limit":
      "容量の上限を保存しています",
    "Measuring usage on Google Drive":
      "Google Driveの使用量を測定しています",
    "Google Drive did not answer - try again later.":
      "Google Driveから応答がありませんでした - しばらくしてからもう一度お試しください。",
    "Measured.":
      "測定しました。",
    "Space limit for this Mac":
      "このMacの容量の上限",
    "Used on Google Drive":
      "Google Driveでの使用量",
    "Measured %@. The watchdog measures again every few hours.":
      "%@に測定しました。監視は数時間ごとに再測定します。",
    "Limit (GB)":
      "上限 (GB)",
    "Save":
      "保存",
    "Measure now":
      "今すぐ測定",
    "Time Machine quota: %@ GB (70%% of the limit - the copy on Drive is about a third larger than the backup inside it). Time Machine deletes the oldest backups to stay within it.":
      "Time Machineの容量制限: %@ GB(上限の70%% - Drive上のコピーは、中のバックアップより約3分の1大きくなります)。Time Machineは、この範囲に収めるため古いバックアップを削除します。",
    "Set the Time Machine quota: run this in Terminal (needs sudo)":
      "Time Machineの容量制限を設定: ターミナルで次を実行してください(sudoが必要です)",
    "Connect Google Drive: run this in Terminal and approve in the browser":
      "Google Driveに接続: ターミナルで次を実行し、ブラウザで承認してください",
    "Grant Full Disk Access to CloudMachine, so it can tell whether backups complete":
      "CloudMachineにフルディスクアクセスを許可して、バックアップが完了したかどうかを確認できるようにする",
    "Folder on Google Drive":
      "Google Driveのフォルダ",
    "One folder per Mac. Set once - it cannot be changed after connecting.":
      "Macごとに1つのフォルダを使用します。一度だけ設定でき、接続後は変更できません。",
    "Use lowercase letters, digits and dashes.":
      "小文字、数字、ハイフンを使用してください。",
    "Install rclone":
      "rcloneをインストール",
    "Open System Settings":
      "システム設定を開く",
    "Install agents":
      "エージェントをインストール",
    "not checked":
      "未確認",
    "none at all":
      "まったくありません",
    "%@ ago":
      "%@前",
    "Missing: %@":
      "不足: %@",
    "Google Drive not connected":
      "Google Driveに接続されていません",
    "Time Machine does not point to CloudMachine":
      "Time MachineがCloudMachineを指していません",
    "UNKNOWN whether Time Machine points to CloudMachine - tmutil did not answer":
      "Time MachineがCloudMachineを指しているか不明です - tmutilから応答がありませんでした",
    "Backup in progress":
      "バックアップ中",
    "Unknown when the last backup was made":
      "最後のバックアップがいつ作成されたか不明です",
    "There is no completed backup at all":
      "完了したバックアップがまったくありません",
    "No completed backup for %@":
      "%@の間、完了したバックアップがありません",
    "Ready":
      "準備完了",
    "Not saved: %@":
      "保存されていません: %@",
    "Installing rclone":
      "rcloneをインストールしています",
    "Installing launchd agents":
      "launchdエージェントをインストールしています",
    "Starting backup":
      "バックアップを開始しています",
    "Backup started.":
      "バックアップを開始しました。",
    "Could not start the backup.":
      "バックアップを開始できませんでした。",
    "Stopping backup":
      "バックアップを停止しています",
    "Backup stopped.":
      "バックアップを停止しました。",
    "Could not stop the backup.":
      "バックアップを停止できませんでした。",
    "Could not prepare the AppleScript.":
      "AppleScriptを準備できませんでした。",
    "Unknown authorization error.":
      "不明な認証エラーです。",
    "Waiting to upload":
      "アップロード待ち",
    "%@ files":
      "%@ 個のファイル",
    "nothing":
      "なし",
    "Back up now":
      "今すぐバックアップ",
    "Stop backup":
      "バックアップを停止",
    "Open CloudMachine":
      "CloudMachineを開く",
    "Quit":
      "終了",
    "Healthy":
      "正常",
    "Attention":
      "注意",
    "Refreshed %@":
      "%@に更新",
    "System Status":
      "システムの状態",
    "Action needed":
      "対応が必要",
    "not measured":
      "未測定",
    "rclone did not answer":
      "rcloneから応答がありませんでした",
    "Backup in Progress":
      "バックアップ中",
    "Files processed":
      "処理済みのファイル",
    "Write speed":
      "書き込み速度",
    "Operation phase":
      "操作の段階",
    "Required Setup Steps":
      "必要な設定手順",
    "Copy":
      "コピー",
    "Last completed backup":
      "最後に完了したバックアップ",
    "Last backup watchdog run":
      "バックアップ監視の最後の実行",
    "not read":
      "未取得",
    "Everything uploaded":
      "すべてアップロード済み",
    "File upload errors":
      "ファイルのアップロードエラー",
    "Google Drive Credentials (OAuth 2.0)":
      "Google Driveの認証情報(OAuth 2.0)",
    "Keychain OK":
      "キーチェーン: OK",
    "No custom keys":
      "独自のキーなし",
    "Paste client_id...":
      "client_idを貼り付け...",
    "Paste client_secret...":
      "client_secretを貼り付け...",
    "Save securely in the Keychain":
      "キーチェーンに安全に保存",
    "Refresh":
      "更新",
    "Overview":
      "概要",
    "Backups":
      "バックアップ",
    "Storage":
      "ストレージ",
    "Settings":
      "設定",
    "Current status: %@":
      "現在の状態: %@",
    "Does not point to CloudMachine":
      "CloudMachineを指していません",
    "tmutil did not answer":
      "tmutilから応答がありませんでした",
    "Backing up: %@ of %@":
      "バックアップ中: %2$@ のうち %1$@",
    "%@ of %@":
      "%2$@ のうち %1$@",
    "Copied":
      "コピーしました",
    "No backup is running":
      "バックアップは実行されていません",
    "Time Machine starts the next one on its own schedule.":
      "Time Machineは、独自のスケジュールで次回のバックアップを開始します。",
    "Backup cycle":
      "バックアップサイクル",
    "%@ GiB":
      "%@ GiB",
    "%@ GiB in %@ bands, %@ uploading":
      "%1$@ GiB(%2$@ バンド、うち %3$@ をアップロード中)",
    "%@ bands":
      "%@ バンド",
    "%@ fragments abandoned - only in the machine":
      "%@ 個のフラグメントを破棄しました - マシン内にのみ存在します",
    "127.0.0.1:5572 answers on the Mac: Lima forwards the machine's rclone remote control, which has no password. Any web page open in a browser can send it commands - including deleting the backup on Google Drive. Add the portForwards rule from vm/cmsmb.yaml to the machine and restart it (see vm/README.md).":
      "127.0.0.1:5572 がMac上で応答しています: Limaが、パスワードのないマシンのrclone遠隔操作を転送しています。ブラウザで開いているWebページからコマンドを送られる可能性があり、Google Drive上のバックアップを削除されることもあります。vm/cmsmb.yamlのportForwardsルールをマシンに追加し、マシンを再起動してください(vm/README.mdを参照)。",
    "A service in the CloudMachine machine is not running":
      "CloudMachineマシン内のサービスが動作していません",
    "Address":
      "アドレス",
    "Agent installation INCOMPLETE - %@ of %@ did not go in:\n%@\n%@\nEvery missing agent is a function that has silently stopped working (vm-guard watches the machine's buffer, backup-health reports failures). Fix the cause and repeat the installation.":
      "エージェントのインストールが不完全です - %2$@ 個のうち %1$@ 個がインストールされませんでした:\n%3$@\n%4$@\n不足しているエージェントは、気づかないうちに動作しなくなった機能です(vm-guardはマシンのバッファを監視し、backup-healthは障害を報告します)。原因を解消して、もう一度インストールしてください。",
    "All running":
      "すべて動作中",
    "Also install the launchd agents (same as install-launchd).":
      "launchdエージェントもインストールします(install-launchdと同じ)。",
    "At most this many minutes of waiting for the upload.":
      "アップロードを待つ最大の分数。",
    "At the limit every new band fails with EMFILE and the backup stops. Check: cloudmachine-agent vm-status":
      "上限に達すると、新しいバンドがすべてEMFILEで失敗し、バックアップが停止します。確認: cloudmachine-agent vm-status",
    "Cache on the machine's disk":
      "マシンのディスク上のキャッシュ",
    "Connected to Google Drive, but could not create the folder '%@' - without it the machine has nowhere to keep the backup. Check the account permissions and try again.":
      "Google Driveには接続できましたが、フォルダ '%@' を作成できませんでした - フォルダがないと、マシンはバックアップを保存する場所がありません。アカウントの権限を確認して、もう一度お試しください。",
    "Convert the image":
      "イメージを変換",
    "Converting the image to 32 MB bands":
      "イメージを32 MBのバンドに変換しています",
    "Could not check with the current connection whether the backup is on Google Drive (%@), so remote '%@' was NOT replaced: without that answer the new sign-in cannot be checked against it.":
      "現在の接続では、バックアップがGoogle Drive上にあるかどうかを確認できなかった(%1$@)ため、remote '%2$@' は置き換えられませんでした。その確認ができないと、新しいサインインを照合できません。",
    "Downloads the official rclone binary into ~/.cloudmachine/bin (Google sign-in and the machine's rclone.conf).":
      "公式のrcloneバイナリを~/.cloudmachine/binにダウンロードします(Googleへのサインインとマシンのrclone.conf用)。",
    "Free in the machine":
      "マシンの空き容量",
    "Free in the machine: %@":
      "マシンの空き容量: %@",
    "Generates and installs the launchd agents (app, backup watchdog, machine start, machine guard).":
      "launchdエージェント(App、バックアップ監視、マシンの起動、マシンのガード)を生成してインストールします。",
    "Install Lima, which runs the CloudMachine machine: run this in Terminal":
      "CloudMachineマシンを動かすLimaをインストール: ターミナルで次を実行してください",
    "Install rclone (signs in to Google Drive for the machine)":
      "rcloneをインストール(マシン用にGoogle Driveへサインインします)",
    "Install the background agents (machine start, buffer guard, backup watchdog)":
      "バックグラウンドエージェントをインストール(マシンの起動、バッファのガード、バックアップ監視)",
    "Installs rclone through Homebrew - CloudMachine itself uses the one from install-rclone.":
      "Homebrewでrcloneをインストールします - CloudMachine自体は、install-rcloneで入れたものを使用します。",
    "Info.plist, token and mapped/ of the backup image exist only on the machine's disk; without them the bands in %@ cannot be restored. The copy (tm-meta-sync, every 15 min) goes to %@. Check: cloudmachine-agent vm-status, then in the machine: journalctl -u tm-meta-sync":
      "バックアップイメージのInfo.plist、トークン、mapped/はマシンのディスク上にのみ存在します。これらがないと、%1$@ のバンドは復元できません。コピー(tm-meta-sync、15分ごと)は %2$@ に保存されます。確認: cloudmachine-agent vm-status、続いてマシン内で: journalctl -u tm-meta-sync",
    "Lima says the machine is running, but a command in it did not return. Without it nothing is known about Samba, rclone or the upload. Check: cloudmachine-agent vm-status":
      "Limaはマシンが動作中と報告していますが、マシン内のコマンドが戻ってきませんでした。このコマンドがないと、Samba、rclone、アップロードの状態がわかりません。確認: cloudmachine-agent vm-status",
    "Machine":
      "マシン",
    "Machine %@":
      "マシン %@",
    "Machine & Upload Status":
      "マシンとアップロードの状態",
    "Machine buffer":
      "マシンのバッファ",
    "No Time Machine destination is the machine's share (smb://tm@<address>/CloudMachine) - backups are not being made there. The command is printed by: cloudmachine-agent vm-setup":
      "マシンの共有(smb://tm@<アドレス>/CloudMachine)が、Time Machineのバックアップ先になっていません - そこにはバックアップが作成されません。コマンドは次で表示されます: cloudmachine-agent vm-setup",
    "Not running: %@":
      "動作していません: %@",
    "Not set up":
      "未設定",
    "Once it runs out, rclone stops uploading, the machine's buffer fills up and backups stop being made. At a growth of ~600 MB per hourly cycle that is about %@ days.":
      "使い切ると、rcloneがアップロードを停止し、マシンのバッファがいっぱいになって、バックアップが作成されなくなります。1時間ごとのサイクルで約600 MBずつ増える場合、約 %@ 日で到達します。",
    "Or rclone.conf is missing: this Mac has already set up the CloudMachine machine, so it is not connected anew blindly. Restore the file from a backup (the machine keeps its own copy in %@). To connect anyway, create an empty file at the path `%@ config file` prints and run again - the existing folder is kept.":
      "または、rclone.confがありません: このMacはすでにCloudMachineマシンを設定済みのため、むやみに新しく接続することはしません。バックアップからファイルを復元してください(マシンは %@ に独自のコピーを保持しています)。それでも接続する場合は、`%@ config file` が表示するパスに空のファイルを作成して、もう一度実行してください - 既存のフォルダは維持されます。",
    "Point Time Machine at the machine: run this in Terminal (needs sudo; Copy includes the password)":
      "Time Machineの接続先をマシンに設定: ターミナルで次を実行してください(sudoが必要です。「コピー」にはパスワードが含まれます)",
    "Points to the machine":
      "マシンを指しています",
    "Prepares for a restart: stops the backup, waits a while for the upload, then stops the machine cleanly.":
      "再起動の準備をします: バックアップを停止し、アップロードをしばらく待ってから、マシンを正常に停止します。",
    "Reading the Time Machine destination did not return within %@ s. That is how tmutil behaves when its destination hangs.":
      "Time Machineの接続先の読み取りが %@ 秒以内に戻りませんでした。接続先が応答しなくなると、tmutilはこのように動作します。",
    "Remote '%@' was NOT replaced. The new sign-in gets the 'drive.file' scope, which sees only files created under its own client_id. The existing backup was most likely created by the current connection and would become invisible to it. Before anything is written, the new token is checked against the existing backup, and the replacement is abandoned if it cannot see it. The machine keeps its own copy of the configuration until vm-setup --replace-rclone-config. To go ahead, run again with --replace-existing --accept-scope-change.":
      "remote '%@' は置き換えられませんでした。新しいサインインには 'drive.file' スコープが付与され、自身のclient_idで作成したファイルしか見えません。既存のバックアップは現在の接続で作成された可能性が高く、新しい接続からは見えなくなります。何かを書き込む前に、新しいトークンを既存のバックアップと照合し、見えない場合は置き換えを中止します。マシンは、vm-setup --replace-rclone-config を実行するまで、設定の独自のコピーを保持します。このまま進めるには、--replace-existing --accept-scope-change を付けてもう一度実行してください。",
    "Remote control:   OPEN on the Mac at 127.0.0.1:5572 - any web page can send rclone commands; see vm/README.md (portForwards)":
      "リモート制御:     Mac上の127.0.0.1:5572で公開されています - どのWebページからもrcloneコマンドを送れます。vm/README.md(portForwards)を参照",
    "Running":
      "動作中",
    "Samba, rclone or punchfs in the machine is not active, so Time Machine has nowhere to write or the bands do not reach Google Drive. Check: cloudmachine-agent vm-status":
      "マシン内のSamba、rclone、punchfsのいずれかが動作していないため、Time Machineの書き込み先がないか、バンドがGoogle Driveに届いていません。確認: cloudmachine-agent vm-status",
    "Service %@":
      "サービス %@",
    "Services":
      "サービス",
    "Set up the CloudMachine machine (the first time it downloads Ubuntu - several minutes)":
      "CloudMachineマシンを設定(初回はUbuntuをダウンロードするため数分かかります)",
    "Set up the CloudMachine machine again, so it prints the Time Machine command":
      "CloudMachineマシンをもう一度設定し、Time Machineのコマンドを表示",
    "Set up the machine":
      "マシンを設定",
    "Setting up the CloudMachine machine":
      "CloudMachineマシンを設定しています",
    "Start the CloudMachine machine":
      "CloudMachineマシンを起動",
    "Start the machine":
      "マシンを起動",
    "Starting the CloudMachine machine":
      "CloudMachineマシンを起動しています",
    "Still to upload: %@ GiB":
      "アップロード待ち: %@ GiB",
    "Stopping the Time Machine backup...":
      "Time Machineのバックアップを停止しています...",
    "Stopping the machine %@...":
      "マシン %@ を停止しています...",
    "The CloudMachine machine does not answer":
      "CloudMachineマシンから応答がありません",
    "The CloudMachine machine is not running":
      "CloudMachineマシンが動作していません",
    "The CloudMachine machine is not set up yet":
      "CloudMachineマシンはまだ設定されていません",
    "The CloudMachine machine is stopped":
      "CloudMachineマシンは停止しています",
    "The backup is stopped, the upload gets up to 30 minutes, then the machine shuts down cleanly. It starts again at the next login.":
      "バックアップを停止し、最大30分間アップロードを待ってから、マシンを正常に停止します。次回のログイン時に再び起動します。",
    "The machine %@ is not running - nothing to prepare.":
      "マシン %@ は動作していません - 準備するものはありません。",
    "The machine is stopped and everything reached Google Drive. The Mac can be restarted; the machine starts again at login.":
      "マシンは停止し、すべてがGoogle Driveに届きました。Macを再起動できます。マシンはログイン時に再び起動します。",
    "The machine is stopped. %@ GiB had not reached Google Drive yet - it is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "マシンは停止しました。%@ GiBがまだGoogle Driveに届いていません - マシンのバッファに保持され、次回の起動後にアップロードされます。Macを再起動できます。",
    "The machine is stopped. rclone did not say how much was still to upload; what was not uploaded is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "マシンは停止しました。rcloneは、アップロード待ちの量を報告しませんでした。アップロードされていないデータはマシンのバッファに保持され、次回の起動後にアップロードされます。Macを再起動できます。",
    "The machine's disk is a file on this disk and grows as the upload buffer fills. With no space left the machine cannot write the buffer, and Time Machine's local snapshots have nowhere to go either.":
      "マシンのディスクは、このディスク上のファイルであり、アップロードバッファがいっぱいになるにつれて大きくなります。空き容量がなくなると、マシンはバッファに書き込めず、Time Machineのローカルスナップショットも保存できなくなります。",
    "The image's metadata has never been copied to Drive":
      "イメージのメタデータは一度もDriveにコピーされていません",
    "The image's metadata was last copied to Drive %@ ago":
      "イメージのメタデータは %@前にDriveへ最後にコピーされました",
    "The machine's disk is running out of space (%@ GB)":
      "マシンのディスクの空き容量が残りわずかです(%@ GB)",
    "The new sign-in does NOT see the existing backup (%@), so remote '%@' was NOT replaced and rclone.conf is unchanged. Keep the current connection, or sign in with the credential (client_id) that created the backup.":
      "新しいサインインでは既存のバックアップ(%1$@)が見えないため、remote '%2$@' は置き換えられず、rclone.confも変更されていません。現在の接続を維持するか、バックアップを作成した認証情報(client_id)でサインインしてください。",
    "The upload buffer lives on this disk. The guard pauses Time Machine before it fills; if the upload does not catch up, backups stay paused.":
      "アップロードバッファはこのディスク上にあります。ガードは、いっぱいになる前にTime Machineを一時停止します。アップロードが追いつかない場合、バックアップは一時停止のままになります。",
    "These bands exist only in the machine's buffer. The backup on Google Drive is INCOMPLETE and may not open.":
      "これらのバンドはマシンのバッファにのみ存在します。Google Drive上のバックアップは不完全で、開けない可能性があります。",
    "Time Machine backs up to the machine, so without it no backup is made. Start it: limactl start %@ (or the Start button in the app).":
      "Time Machineはマシンにバックアップするため、マシンが動作していないとバックアップは作成されません。起動してください: limactl start %@(またはAppの「起動」ボタン)。",
    "Time Machine did not stop its backup within 2 minutes (or tmutil did not answer) - the machine was NOT stopped. Try again in a moment.":
      "Time Machineが2分以内にバックアップを停止しなかった(またはtmutilが応答しなかった)ため、マシンは停止されませんでした。しばらくしてから、もう一度お試しください。",
    "Time Machine has created its image: stop the backup, then convert the image to 32 MB bands":
      "Time Machineがイメージを作成しました: バックアップを停止してから、イメージを32 MBのバンドに変換してください",
    "To upload":
      "アップロード待ち",
    "Unknown whether the CloudMachine machine is running":
      "CloudMachineマシンが動作中かどうか不明です",
    "Waiting for the upload to Google Drive (at most %@ min)...":
      "Google Driveへのアップロードを待っています(最大 %@ 分)...",
    "With --replace-existing: confirms that the new sign-in (scope 'drive.file') may not see the existing backup. The new token is still checked against the backup first.":
      "--replace-existing と併用: 新しいサインイン(スコープ 'drive.file')から既存のバックアップが見えない可能性があることを承認します。新しいトークンは、その前に必ずバックアップと照合されます。",
    "Without it there is no way to check whether anything reached the Drive - the machine's guard is blind then.":
      "これがないと、Driveに何かが届いたかどうかを確認する手段がなく、マシンのガードは何も見えない状態になります。",
    "limactl did not answer":
      "limactlから応答がありませんでした",
    "limactl did not answer (or is not installed). That does not mean the machine is down - it means nobody has checked.":
      "limactlから応答がありませんでした(またはインストールされていません)。マシンが停止しているという意味ではなく、誰も確認していないという意味です。",
    "limactl start failed: %@":
      "limactl startが失敗しました: %@",
    "limactl stop failed: %@":
      "limactl stopが失敗しました: %@",
    "punchfs is close to its open-file limit":
      "punchfsが開けるファイル数の上限に近づいています",
    "punchfs open files":
      "punchfsの開いているファイル",
    "rclone's remote control is open on this Mac":
      "rcloneのリモート制御がこのMacで公開されています",
    "statfs('/System/Volumes/Data') returned an error, so nobody knows whether the machine's disk can still grow on this Mac.":
      "statfs('/System/Volumes/Data') がエラーを返したため、このMac上でマシンのディスクがまだ大きくなれるかどうか不明です。",
    "Google Drive's daily upload limit stops the upload":
      "Google Driveの1日あたりのアップロード上限により、アップロードが停止しています",
    "Google last refused an upload %@ ago (750 GB a day). Backups since then are only in the machine's buffer on this Mac. rclone retries every 5 min and resumes by itself when the limit passes; the guard pauses Time Machine if more than %@ GiB waits.":
      "Googleは %1$@前に最後にアップロードを拒否しました(1日750 GB)。それ以降のバックアップは、このMac上のマシンのバッファにのみあります。rcloneは5分ごとに再試行し、上限が解除されると自動的に再開します。%2$@ GiBを超えるデータが待機している場合は、ガードがTime Machineを一時停止します。",
    "Usage on Google Drive is not being measured":
      "Google Driveの使用量が測定されていません",
    "The last measurement (%@ GB) is from %@, %@ ago - rclone size has not answered since. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "最後の測定(%1$@ GB)は %2$@、%3$@前のものです - それ以降、rclone sizeは応答していません。応答するまでは、%4$@ GBの上限を監視するものがなく、90%%と100%%のアラートも出ません。vm-statusを確認するか、ウインドウで「今すぐ測定」を押してください。",
    "rclone size has not answered even once. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "rclone sizeは一度も応答していません。応答するまでは、%@ GBの上限を監視するものがなく、90%%と100%%のアラートも出ません。vm-statusを確認するか、ウインドウで「今すぐ測定」を押してください。",
    "Saved in the Keychain. Connecting Google Drive (configure-remote) will use them.":
      "キーチェーンに保存しました。Google Drive(configure-remote)に接続するときに使用されます。",
    "Saved in the Keychain. The existing Google Drive connection keeps its old client_id, and on this Mac it should stay that way: a connection made with the new keys (the 'drive.file' scope) cannot see the backup created by the old one. Do not replace the connection here; the new keys are for a Mac that is not connected yet.":
      "キーチェーンに保存しました。既存のGoogle Drive接続は古いclient_idを維持します。このMacではそのままにしてください。新しいキー('drive.file' スコープ)で作成した接続では、古い接続で作成したバックアップが見えません。ここで接続を置き換えないでください。新しいキーは、まだ接続していないMac用です。",
    "it is not there for the new token":
      "新しいトークンからは見えません",
    "Cancel":
      "キャンセル",
    "ACTION NEEDED":
      "対応が必要です",
    "WILL PASS BY ITSELF — DO NOTHING":
      "自然に解消します - 何もしなくて大丈夫です",
    "UNKNOWN — CHECK AGAIN SHORTLY":
      "不明 - しばらくしてからもう一度確認してください",
    "ALL GOOD":
      "問題なし",
    "Upload is not working":
      "アップロードが動作していません",
    "Upload stopped — no space left on Google Drive":
      "アップロードが停止しました - Google Driveの空き容量がありません",
    "%@ backup fragments not uploaded":
      "%@ 個のバックアップフラグメントがアップロードされていません",
    "Upload cannot keep up with writes":
      "アップロードが書き込みに追いついていません",
    "Upload paused — Google daily limit":
      "アップロードを一時停止中 - Googleの1日の上限",
    "Uploading to Google Drive — %@ queued":
      "Google Driveにアップロード中 - %@ 件が待機中",
    "Everything uploaded to Google Drive":
      "すべてGoogle Driveにアップロードされました",
    "Unknown what is waiting in the queue":
      "待機中のキューの内容が不明です",
    "There is no connection to Google Drive, so backups are only made on this Mac. If this does not pass by itself within a few minutes, check the network and the connection to Drive.":
      "Google Driveに接続できないため、バックアップはこのMac上にのみ作成されます。数分以内に自然に解消しない場合は、ネットワークとDriveへの接続を確認してください。",
    "There is no space left on Google Drive. This will NOT pass by itself — you need to free up space on Drive. Until then Time Machine is paused, so that it does not fill up this Mac's disk.":
      "Google Driveに空き容量がありません。これは自然には解消しません - Drive上の容量を空ける必要があります。それまでは、このMacのディスクがいっぱいにならないよう、Time Machineは一時停止されます。",
    "%@ backup fragments could not be uploaded and rclone stopped trying. These fragments exist only on this Mac, so the backup on Drive is incomplete. This needs checking.":
      "%@ 個のバックアップフラグメントをアップロードできず、rcloneは再試行を停止しました。これらのフラグメントはこのMacにのみ存在するため、Drive上のバックアップは不完全です。確認が必要です。",
    "Time Machine is writing faster than the upload goes, and the buffer has filled up. The backup will be paused until the upload catches up — this is a safeguard against filling up the disk, not a failure.":
      "Time Machineがアップロードより速く書き込んでおり、バッファがいっぱいになりました。アップロードが追いつくまでバックアップは一時停止されます - これはディスクがいっぱいになるのを防ぐための安全策であり、障害ではありません。",
    "Google accepts 750 GB per day and that limit has been used up. There is nothing to do: the limit renews by itself, usually within a few hours. Time Machine backups are made normally in the meantime and wait in the buffer — they will be uploaded as soon as Google starts accepting again.":
      "Googleは1日あたり750 GBまで受け付けており、その上限を使い切りました。できることはありません。上限は通常、数時間以内に自動的にリセットされます。その間もTime Machineのバックアップは通常どおり作成されてバッファに保持され、Googleが再び受け付けるようになりしだいアップロードされます。",
    "%@ backup fragments are queued and on their way to Drive.":
      "%@ 個のバックアップフラグメントが待機中で、Driveに向かっています。",
    "Nothing is waiting in the queue — the backup on Google Drive is complete.":
      "待機中のものはありません - Google Drive上のバックアップは完全です。",
    "rclone did not answer the question about the queue, so it is unknown how many backups are still waiting to be uploaded. This does not mean something broke — under load the answer can be late. It only means that right now nobody knows. If it persists, the backup cycle check will report it.":
      "rcloneがキューに関する問い合わせに応答しなかったため、アップロード待ちのバックアップがどれだけあるかは不明です。何かが壊れたという意味ではありません - 負荷が高いと応答が遅れることがあります。今のところ誰にもわからない、というだけです。続くようであれば、バックアップサイクルの確認で報告されます。",
    "unknown error":
      "不明なエラー",
    "rclone lsf ended with an error":
      "rclone lsfがエラーで終了しました",
    "This Mac is close to its space limit on Google Drive":
      "このMacは、Google Driveの容量の上限に近づいています",
    "%@ GB of %@ GB used. Time Machine deletes the oldest backups to stay within its quota; check that the quota is set (vm-status).":
      "%2$@ GB中 %1$@ GBを使用中です。Time Machineは、容量制限に収めるため古いバックアップを削除します。容量制限が設定されていることを確認してください(vm-status)。",
    "This Mac is over its space limit on Google Drive":
      "このMacは、Google Driveの容量の上限を超えています",
    "%@ GB of %@ GB used. Set the Time Machine quota (command in the app window or vm-status), or raise the limit.":
      "%2$@ GB中 %1$@ GBを使用中です。Time Machineの容量制限を設定する(コマンドはAppのウインドウまたはvm-statusに表示)か、上限を引き上げてください。",
    "not set":
      "未設定",
    "%@ GB - usage not measured yet":
      "%@ GB - 使用量は未測定",
    "%@ of %@ GB used (%@%%)":
      "%2$@ GB中 %1$@ GBを使用中(%3$@%%)",
    "The limit must be a whole number of GB above zero.":
      "上限は、0より大きい整数のGBで指定してください。",
    "machines.json cannot be read, so it was not overwritten. Fix or remove it first.":
      "machines.jsonを読み取れないため、上書きしませんでした。先に修正するか削除してください。",
    "'%@' is not a valid folder name: use lowercase letters, digits and dashes.":
      "'%@' はフォルダ名として使用できません: 小文字、数字、ハイフンを使用してください。",
    "This Mac already backs up to folder '%@'. Switching to '%@' would start a new, empty backup and orphan the existing one, so nothing was changed.":
      "このMacはすでにフォルダ '%1$@' にバックアップしています。'%2$@' に切り替えると、新しい空のバックアップが始まり、既存のバックアップが孤立してしまうため、何も変更していません。",
    "This Mac already has a CloudMachine installation, whose backup is in folder '%@'. Switching to '%@' would orphan it, so nothing was changed.":
      "このMacにはすでにCloudMachineがインストールされており、バックアップはフォルダ '%1$@' にあります。'%2$@' に切り替えるとバックアップが孤立してしまうため、何も変更していません。",
    "Could not save the folder name to %@: %@":
      "フォルダ名を %1$@ に保存できませんでした: %2$@",
    "Homebrew is not installed. Install it manually: https://brew.sh":
      "Homebrewがインストールされていません。手動でインストールしてください: https://brew.sh",
    "Installing rclone failed: %@":
      "rcloneのインストールに失敗しました: %@",
    "Installed rclone.":
      "rcloneをインストールしました。",
    "Own Google credentials: set.":
      "独自のGoogle認証情報: 設定済み。",
    "INCOMPLETE: %@ is missing - rclone will use rclone's shared client_id anyway.":
      "不完全: %@ がありません - rcloneは共有のclient_idをそのまま使用します。",
    "No own credentials - rclone uses the shared client_id, rate-limited jointly and being retired in 2026.":
      "独自の認証情報がありません - rcloneは共有のclient_idを使用します。これは共同でレート制限を受け、2026年に廃止されます。",
    "Empty value - not saving.":
      "値が空です - 保存しません。",
    "Keychain refused: %@":
      "キーチェーンが拒否しました: %@",
    "DIRTY-TREE":
      "未コミットの変更あり",
    "Cannot create the working directory: %@":
      "作業ディレクトリを作成できません: %@",
    "Could not read the rclone version number.":
      "rcloneのバージョン番号を読み取れませんでした。",
    "Could not download %@.":
      "%@ をダウンロードできませんでした。",
    "No entry for %@ in SHA256SUMS.":
      "SHA256SUMSに %@ のエントリがありません。",
    "Could not compute the checksum.":
      "チェックサムを計算できませんでした。",
    "SHA256 checksum does not match - NOT installing.\n  expected: %@\n  computed: %@":
      "SHA256チェックサムが一致しません - インストールしません。\n  期待値: %1$@\n  計算値: %2$@",
    "Could not unpack the archive.":
      "アーカイブを展開できませんでした。",
    "Could not install the binary: %@":
      "バイナリをインストールできませんでした: %@",
    "Installed rclone %@ in %@ (SHA256 checksum matches).":
      "rclone %1$@ を %2$@ にインストールしました(SHA256チェックサムが一致)。",
    "%@ did not respond within the allotted time (the process was left orphaned in the background).":
      "%@ が所定の時間内に応答しませんでした(プロセスはバックグラウンドに残されたままです)。",
    "Cannot launch %@: %@":
      "%1$@ を起動できません: %2$@",
    "Remote '%@' already exists and was NOT touched.\nOverwriting it replaces the token and the permission scope; a credential with the 'drive.file' scope does not see files created by the previous one, so the existing backup becomes unreachable.\nIf you really want to replace it, first back up ~/.config/rclone/rclone.conf and run again with --replace-existing.":
      "remote '%@' はすでに存在し、変更されませんでした。\n上書きするとトークンと権限スコープが置き換えられます。'drive.file' スコープの認証情報は、以前の認証情報が作成したファイルを見ることができないため、既存のバックアップに到達できなくなります。\nどうしても置き換える場合は、先に~/.config/rclone/rclone.confをバックアップし、--replace-existing を付けてもう一度実行してください。",
    "Could not check whether remote '%@' already exists (rclone listremotes did not answer or failed), so nothing was changed. Run `%@ listremotes` to see the error, then try again.":
      "remote '%1$@' がすでに存在するか確認できなかった(rclone listremotesが応答しないか、失敗しました)ため、何も変更していません。`%2$@ listremotes` を実行してエラーを確認し、もう一度お試しください。",
    "Could not check whether this Mac already has a CloudMachine installation (rclone did not answer), so no folder was chosen. Try again in a moment.":
      "このMacにすでにCloudMachineがインストールされているか確認できなかった(rcloneが応答しませんでした)ため、フォルダは選択されませんでした。しばらくしてから、もう一度お試しください。",
    "rclone authorize failed (%@). If that binary is missing, start with: cloudmachine-agent install-rclone.":
      "rclone authorizeが失敗しました(%@)。そのバイナリがない場合は、次から始めてください: cloudmachine-agent install-rclone。",
    "Could not read the token from the output of rclone authorize.":
      "rclone authorizeの出力からトークンを読み取れませんでした。",
    "rclone config create failed.":
      "rclone config createが失敗しました。",
    "Connected to Google Drive as remote '%@', folder %@.":
      "Google Driveにremote '%1$@'、フォルダ %2$@ として接続しました。",
    "tmutil is not responding - unknown where the backup goes":
      "tmutilが応答していません - バックアップの保存先が不明です",
    "No successful backup for %@":
      "%@の間、成功したバックアップがありません",
    "Last COMPLETED backup: %@. The cycle is hourly, so that is %@ missed runs.":
      "最後に完了したバックアップ: %1$@。サイクルは1時間ごとなので、%2$@ 回分が実行されていません。",
    "There is NOT A SINGLE successful backup":
      "成功したバックアップが1つもありません",
    "The Time Machine preferences contain no date of a completed backup for this destination.":
      "Time Machineの環境設定に、この接続先で完了したバックアップの日時が含まれていません。",
    "The last backup attempt did not end in a backup":
      "最後のバックアップの試行は、バックアップとして完了しませんでした",
    "The attempt at %@ is newer than the last successful backup at %@.":
      "%1$@の試行は、最後に成功したバックアップ(%2$@)より新しいものです。",
    "Time Machine reports an error in the last run (RESULT=%@)":
      "Time Machineが前回の実行でエラーを報告しています(RESULT=%@)",
    "A non-zero RESULT in the Time Machine preferences means the run did not succeed.":
      "Time Machineの環境設定でRESULTが0以外の場合、その実行は成功しなかったことを意味します。",
    "rclone failed to upload %@ files":
      "rcloneが %@ 個のファイルをアップロードできませんでした",
    "Buffer full of nothing but unsent data":
      "バッファが未送信のデータだけでいっぱいです",
    "rclone has nothing left to evict from the buffer - the upload cannot keep up or has stalled.":
      "rcloneがバッファから退避できるものがもうありません - アップロードが追いついていないか、止まっています。",
    "The rclone control interface is not responding":
      "rcloneの制御インターフェースが応答していません",
    "Google Drive is running out of space (%@ GB)":
      "Google Driveの空き容量が残りわずかです(%@ GB)",
    "The Mac's disk is running out of space (%@ GB)":
      "Macのディスクの空き容量が残りわずかです(%@ GB)",
    "Cannot read the Time Machine preferences":
      "Time Machineの環境設定を読み取れません",
    "%@ is unreadable - most often Full Disk Access is missing. Without this file it is UNKNOWN when the last backup was made, so we treat it as a failure, not as the absence of a problem.":
      "%@ を読み取れません - 多くの場合、フルディスクアクセスがないことが原因です。このファイルがないと、最後のバックアップがいつ作成されたか不明のため、問題がないものとはせず、障害として扱います。",
    "Cannot measure free space on the Mac's disk":
      "Macのディスクの空き容量を測定できません",
    "%@ days":
      "%@ 日",
    "CloudMachine: backup is not working":
      "CloudMachine: バックアップが動作していません",
    "unknown reason":
      "原因不明",
    "osascript did not show the notification (permissions or no graphical session)":
      "osascriptが通知を表示しませんでした(権限がないか、グラフィカルセッションがありません)",
    "UNDELIVERED ALARM: %@":
      "未配信のアラート: %@",
    "from %@, reason: %@":
      "%1$@から、理由: %2$@",
    "The system notification was not delivered - you will see this alarm ONLY here.":
      "システム通知が配信されませんでした - このアラートはここでのみ確認できます。",
    "%@ (%@ ago)":
      "%1$@(%2$@前)",
    "%@ - marker from the FUTURE":
      "%@ - 未来の日時のマーカー",
    "%@ (%@ ago) - THE WATCHDOG MAY NOT BE RUNNING":
      "%1$@(%2$@前) - 監視が動作していない可能性があります",
    "NEVER - the watchdog has not recorded a single run":
      "一度もありません - 監視は実行を1回も記録していません",
    "Could not find the launchd/ directory with templates.":
      "テンプレートのあるlaunchd/ディレクトリが見つかりませんでした。",
    "Could not find the compiled cloudmachine-agent binary.":
      "コンパイル済みのcloudmachine-agentバイナリが見つかりませんでした。",
    "ABORTED: could not put cloudmachine-agent in a stable location\n(%@) - most often a lack of space or permissions.\nNOT installing agents pointing at %@: that path\ndisappears on the next `swift build` or `git clean`, and backups stop\nwithout any visible signal.":
      "中止しました: cloudmachine-agentを固定の場所に置けませんでした\n(%1$@) - 多くの場合、空き容量または権限の不足が原因です。\n%2$@ を指すエージェントはインストールしません: このパスは\n次回の `swift build` や `git clean` で消えてしまい、バックアップが\n何の兆候もなく停止します。",
    "ABORTED: %@":
      "中止しました: %@",
    "Could not list the templates in %@.":
      "%@ のテンプレートを一覧表示できませんでした。",
    "could not read the template %@":
      "テンプレート %@ を読み取れませんでした",
    "could not write %@ (lack of space or permissions)":
      "%@ を書き込めませんでした(空き容量または権限の不足)",
    "launchctl load refused to load %@":
      "launchctl loadが %@ の読み込みを拒否しました",
    "NOT A SINGLE agent was loaded.":
      "読み込まれたエージェントは1つもありません。",
    "Only these went in: %@.":
      "インストールされたのは次のみです: %@。",
    "Could not load any launchd agent.":
      "launchdエージェントを1つも読み込めませんでした。",
    "Installed agents: %@":
      "インストールしたエージェント: %@",
    "                  WARNING: close to the limit - new bands will fail with EMFILE":
      "                  警告: 上限に近づいています - 新しいバンドがEMFILEで失敗します",
    "%@/bands on Google Drive is not empty - it may hold another backup. NOT overwriting it; check it by hand.":
      "Google Drive上の %@/bands が空ではありません - 別のバックアップがある可能性があります。上書きしません。手動で確認してください。",
    "Address:          %@":
      "アドレス:         %@",
    "Already prepared (%@ exists) - nothing to do.":
      "すでに準備済みです(%@ が存在します) - 何もする必要はありません。",
    "Converts Time Machine's new, empty image in the machine to 32 MB bands and moves the bands to Google Drive.":
      "マシン内のTime Machineの新しい空のイメージを32 MBのバンドに変換し、バンドをGoogle Driveに移動します。",
    "Copy rclone.conf into the machine even if it already has one.":
      "すでにrclone.confがある場合でも、マシンにコピーします。",
    "Copying the converted image into the machine failed: %@":
      "変換したイメージのマシンへのコピーに失敗しました: %@",
    "Copying the image to the Mac failed: %@":
      "イメージのMacへのコピーに失敗しました: %@",
    "Could not ask Lima about the machine: %@":
      "マシンについてLimaに問い合わせできませんでした: %@",
    "Could not carry the Time Machine files over: %@":
      "Time Machineのファイルを移動できませんでした: %@",
    "Could not check the image in the machine.":
      "マシン内のイメージを確認できませんでした。",
    "Could not copy the rclone configuration into the machine.":
      "rcloneの設定をマシンにコピーできませんでした。",
    "Could not create %@ on Google Drive: %@":
      "Google Drive上に %1$@ を作成できませんでした: %2$@",
    "Could not create %@: %@":
      "%1$@ を作成できませんでした: %2$@",
    "Could not find the vm/ directory with the machine template.":
      "マシンのテンプレートがあるvm/ディレクトリが見つかりませんでした。",
    "Could not read the image size.":
      "イメージのサイズを読み取れませんでした。",
    "Could not set the SMB password of user %@ in the machine.":
      "マシン内でユーザ %@ のSMBパスワードを設定できませんでした。",
    "Could not stop smbd in the machine.":
      "マシン内のsmbdを停止できませんでした。",
    "Could not write %@ in the machine.":
      "マシン内に %@ を書き込めませんでした。",
    "Could not write the password file %@.":
      "パスワードファイル %@ を書き込めませんでした。",
    "Creates or starts the CloudMachine machine (Lima), gives it rclone's configuration and an SMB password, and prints the Time Machine command.":
      "CloudMachineマシン(Lima)を作成または起動し、rcloneの設定とSMBパスワードを渡して、Time Machineのコマンドを表示します。",
    "Creating the machine %@ (first start downloads Ubuntu and installs packages - several minutes)...":
      "マシン %@ を作成しています(初回の起動ではUbuntuをダウンロードしてパッケージをインストールします - 数分かかります)...",
    "Done: %@ has %@ MB bands on Google Drive; the original is kept in %@ in the machine. Start the backup: tmutil startbackup":
      "完了: %1$@ はGoogle Drive上で %2$@ MBのバンドになりました。元のイメージはマシン内の %3$@ に保持されています。バックアップを開始: tmutil startbackup",
    "exit code %@, no message":
      "終了コード %@、メッセージなし",
    "Image metadata:   NEVER copied to %@ - check tm-meta-sync in the machine":
      "イメージのメタデータ: %@ に一度もコピーされていません - マシン内のtm-meta-syncを確認してください",
    "Image metadata:   copied %@ ago to %@":
      "イメージのメタデータ: %1$@前に %2$@ にコピー済み",
    "Image metadata:   last copied %@ ago - OVERDUE (%@)":
      "イメージのメタデータ: 最後のコピーは %1$@前 - 遅延しています(%2$@)",
    "Image metadata:   not copied yet - waits for vm-prepare-bundle":
      "イメージのメタデータ: まだコピーされていません - vm-prepare-bundleを待っています",
    "Backup %@, paused by the guard %@: %@":
      "バックアップ %1$@、ガード %2$@ により一時停止: %3$@",
    "Free in machine:  %@ GiB":
      "マシンの空き:     %@ GiB",
    "fsck_apfs -n found problems: %@":
      "fsck_apfs -n が問題を検出しました: %@",
    "Google Drive folder: %@":
      "Google Driveのフォルダ: %@",
    "hdiutil attach of the converted image failed: %@":
      "変換したイメージのhdiutil attachに失敗しました: %@",
    "hdiutil convert failed: %@":
      "hdiutil convertに失敗しました: %@",
    "Image name in the machine (default: from the computer name).":
      "マシン内のイメージ名(既定値: コンピュータ名から生成)。",
    "Installing the converted image FAILED: %@\nsmbd is left STOPPED so Time Machine does not open a half-installed image. The original is in %@ in the machine.":
      "変換したイメージのインストールに失敗しました: %1$@\nTime Machineが中途半端にインストールされたイメージを開かないよう、smbdは停止したままにしています。元のイメージはマシン内の %2$@ にあります。",
    "limactl create failed: %@":
      "limactl createに失敗しました: %@",
    "limactl list failed: %@":
      "limactl listに失敗しました: %@",
    "limactl not found - install Lima: brew install lima":
      "limactlが見つかりません - Limaをインストールしてください: brew install lima",
    "limactl start failed: %@\nThe machine's own log: %@":
      "limactl startに失敗しました: %1$@\nマシン自身のログ: %2$@",
    "Machine %@ is running.":
      "マシン %@ は動作中です。",
    "Machine %@ was already running.":
      "マシン %@ はすでに動作していました。",
    "Machine:          %@ (%@)":
      "マシン:           %1$@(%2$@)",
    "Machine:          %@":
      "マシン:           %@",
    "Machine:          not created - run: cloudmachine-agent vm-setup":
      "マシン:           未作成 - 次を実行してください: cloudmachine-agent vm-setup",
    "no answer within the time limit":
      "制限時間内に応答なし",
    "No image %@ in the machine.":
      "マシン内にイメージ %@ がありません。",
    "No image in the machine yet - point Time Machine at the share and let it create one first.":
      "マシン内にまだイメージがありません - 先にTime Machineの接続先をこの共有に設定し、イメージを作成させてください。",
    "No rclone configuration at %@ - connect Google Drive first (configure-remote).":
      "%@ にrcloneの設定がありません - 先にGoogle Driveに接続してください(configure-remote)。",
    "no SMB destination":
      "SMBの接続先なし",
    "One check of the machine's upload buffer: pauses Time Machine when it fills, resumes what it paused.":
      "マシンのアップロードバッファを1回確認します: いっぱいになるとTime Machineを一時停止し、一時停止したものを再開します。",
    "Packing the converted image failed: %@":
      "変換したイメージのパッキングに失敗しました: %@",
    "Packing the image failed: %@":
      "イメージのパッキングに失敗しました: %@",
    "No answer from the machine (rclone rc) - the guard would do nothing.":
      "マシンから応答がありません(rclone rc) - ガードは何もしません。",
    "Only print what the guard would decide - for trying thresholds on a throwaway machine.":
      "ガードが判断する内容だけを表示します - 使い捨てのマシンでしきい値を試すためのものです。",
    "Pause above this many GiB in the buffer.":
      "バッファがこのGiBを超えたら一時停止します。",
    "Pause when the machine has less free than this, in GiB.":
      "マシンの空き容量がこのGiBを下回ったら一時停止します。",
    "Point Time Machine at the machine (once, needs an administrator password):":
      "Time Machineの接続先をマシンに設定してください(一度だけ。管理者パスワードが必要です):",
    "punchfs files:    %@ open, limit %@":
      "punchfsのファイル: %1$@ 個を開いています、上限 %2$@",
    "rclone configuration already in the machine - kept (--replace-rclone-config replaces it).":
      "rcloneの設定はすでにマシン内にあります - そのまま維持しました(--replace-rclone-configで置き換えられます)。",
    "rclone configuration copied into the machine.":
      "rcloneの設定をマシンにコピーしました。",
    "rclone-tm or punchfs is not running in the machine - see cloudmachine-agent vm-status.":
      "マシン内でrclone-tmまたはpunchfsが動作していません - cloudmachine-agent vm-statusを参照してください。",
    "Resume below this many GiB (only a backup the guard paused).":
      "バッファがこのGiBを下回ったら再開します(ガードが一時停止したバックアップのみ)。",
    "Service %@: %@":
      "サービス %1$@: %2$@",
    "Several images in the machine (%@) - choose one with --bundle.":
      "マシン内に複数のイメージがあります(%@) - --bundle で1つ選んでください。",
    "Shows the machine: address, services, upload buffer, free space and the Time Machine destination.":
      "マシンの状態を表示します: アドレス、サービス、アップロードバッファ、空き容量、Time Machineの接続先。",
    "SMB password stored in %@ (mode 600).":
      "SMBパスワードを %@ に保存しました(モード600)。",
    "The converted image does not have %@-byte bands.":
      "変換したイメージのバンドは %@ バイトではありません。",
    "The converted image has no APFS partition.":
      "変換したイメージにAPFSパーティションがありません。",
    "The image already takes %@ MB - this command converts only a new, empty image (under %@ MB).":
      "イメージはすでに %1$@ MBを使用しています - このコマンドは、新しい空のイメージ(%2$@ MB未満)のみを変換します。",
    "The image is encrypted - converting encrypted images is not supported.":
      "イメージは暗号化されています - 暗号化されたイメージの変換には対応していません。",
    "The image was not changed; smbd started again.":
      "イメージは変更されていません。smbdを再起動しました。",
    "The machine does not answer - is it running? cloudmachine-agent vm-status":
      "マシンが応答しません - 動作していますか? cloudmachine-agent vm-status",
    "The machine has no address on the vzNAT network.":
      "マシンがvzNATネットワークでアドレスを持っていません。",
    "The services in the machine did not start - check: cloudmachine-agent vm-status":
      "マシン内のサービスが起動しませんでした - 確認: cloudmachine-agent vm-status",
    "Time Machine is backing up - stop it first: tmutil stopbackup":
      "Time Machineがバックアップ中です - 先に停止してください: tmutil stopbackup",
    "Time Machine:     %@":
      "Time Machine:     %@",
    "Time Machine:     NOT pointing at the machine (%@)":
      "Time Machine:     マシンを指していません(%@)",
    "Time Machine:     tmutil did not answer":
      "Time Machine:     tmutilから応答がありませんでした",
    "tmutil did not answer - not touching the image while its state is unknown.":
      "tmutilから応答がありませんでした - イメージの状態が不明な間は、イメージに触れません。",
    "unknown":
      "不明",
    "Unpacking the image failed: %@":
      "イメージの展開に失敗しました: %@",
    "Still to upload:  %@ GiB in %@ bands, uploading %@ (cache on disk %@ GiB)":
      "アップロード待ち: %1$@ GiB(%2$@ バンド)、アップロード中 %3$@(ディスク上のキャッシュ %4$@ GiB)",
    "Excluded %@ (the machine and its upload buffer) from Time Machine.":
      "%@(マシンとそのアップロードバッファ)をTime Machineから除外しました。",
    "WARNING: could not exclude %@ from Time Machine - run: tmutil addexclusion %@":
      "警告: %1$@ をTime Machineから除外できませんでした - 次を実行してください: tmutil addexclusion %2$@",
    "Upload buffer:    no answer from rclone (rc %@)":
      "アップロードバッファ: rclone(rc %@)から応答なし",
    "When Time Machine has created its empty image, stop the backup (tmutil stopbackup) and run: cloudmachine-agent vm-prepare-bundle":
      "Time Machineが空のイメージを作成したら、バックアップを停止し(tmutil stopbackup)、次を実行してください: cloudmachine-agent vm-prepare-bundle",
    "Unsent %@ GiB, free %@ GiB (pause above %@ GiB unsent or below %@ GiB free, resume below %@ GiB).":
      "未送信 %1$@ GiB、空き %2$@ GiB(未送信が %3$@ GiBを超えるか空きが %4$@ GiBを下回ると一時停止、%5$@ GiBを下回ると再開)。",
    "Upload:           Google's daily limit refused an upload %@ ago - rclone retries every 5 min and resumes by itself":
      "アップロード:     Googleの1日の上限によりアップロードが %@前に拒否されました - rcloneは5分ごとに再試行し、自動的に再開します",
    "no":
      "いいえ",
    "running":
      "実行中",
    "stopped":
      "停止中",
    "yes":
      "はい",
    "%@\nThe previous template is in %@ - copy it back over lima.yaml and run limactl start %@.":
      "%1$@\n以前のテンプレートは %2$@ にあります - lima.yamlの上にコピーし直して、limactl start %3$@ を実行してください。",
    "Could not read this app's machine template (limactl template copy).":
      "このAppのマシンテンプレートを読み取れませんでした(limactl template copy)。",
    "Could not replace %@: %@":
      "%1$@ を置き換えられませんでした: %2$@",
    "Machine %@ already runs this app's template.":
      "マシン %@ はすでにこのAppのテンプレートで動作しています。",
    "Machine %@ now runs this app's template; the previous one is in %@.":
      "マシン %1$@ は、このAppのテンプレートで動作するようになりました。以前のものは %2$@ にあります。",
    "Moves the machine onto this app's template (two restarts, never during a backup).":
      "マシンをこのAppのテンプレートに移行します(再起動2回、バックアップ中は実行しません)。",
    "No machine %@ - create it with: cloudmachine-agent vm-setup":
      "マシン %@ がありません - 次で作成してください: cloudmachine-agent vm-setup",
    "Template:         OLDER than this app's - run: cloudmachine-agent vm-update":
      "テンプレート:     このAppのものより古い - 次を実行してください: cloudmachine-agent vm-update",
    "Template:         not compared":
      "テンプレート:     未比較",
    "Template:         this app's":
      "テンプレート:     このAppのもの",
    "The machine has no %@ - run cloudmachine-agent vm-setup first.":
      "マシンに %@ がありません - 先にcloudmachine-agent vm-setupを実行してください。",
    "The machine restarted, but not every service is running - check: cloudmachine-agent vm-status. The previous template is in %@.":
      "マシンは再起動しましたが、すべてのサービスが動作しているわけではありません - 確認: cloudmachine-agent vm-status。以前のテンプレートは %@ にあります。",
    "The template changes the machine itself (%@) - that needs a new machine, not an update.":
      "テンプレートがマシン自体(%@)を変更します - 更新ではなく、新しいマシンが必要です。",
    "The upload to Google Drive hangs":
      "Google Driveへのアップロードが止まっています",
    "Time Machine is backing up - try again when it has finished.":
      "Time Machineがバックアップ中です - 終了してから、もう一度お試しください。",
    "Upload:           HANGS - bands in progress, none uploaded for %@ (network?); see /var/log/rclone-tm.log in the machine":
      "アップロード:     停止 - 処理中のバンドがありますが、%@ の間アップロードされていません(ネットワーク?)。マシン内の/var/log/rclone-tm.logを参照",
    "limactl stop failed - nothing was changed.":
      "limactl stopに失敗しました - 何も変更されていません。",
    "rclone has bands in progress, but none has been uploaded for %@ - usually a broken network connection, which rclone does not report as an error. Backups since then are only in the machine's buffer. When the network comes back the upload resumes by itself (on 28.10.2026 within 80 s); if it does not, restarting the machine (prepare-shutdown, limactl start) drops the dead connections.":
      "rcloneには処理中のバンドがありますが、%1$@の間、1つもアップロードされていません - 通常はネットワーク接続の切断が原因で、rcloneはこれをエラーとして報告しません。それ以降のバックアップは、マシンのバッファにのみあります。ネットワークが復旧すると、アップロードは自動的に再開します(2026年10月28日には80秒以内)。再開しない場合は、マシンを再起動する(prepare-shutdown、limactl start)と、切れた接続が破棄されます。",
    "tmutil did not answer - not restarting the machine while its state is unknown.":
      "tmutilから応答がありませんでした - マシンの状態が不明な間は、マシンを再起動しません。",
  ]
}
