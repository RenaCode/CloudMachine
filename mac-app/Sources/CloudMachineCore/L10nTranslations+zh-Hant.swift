// Traditional Chinese translations, keyed by the English text passed to `L10n.tr`.
extension L10nTranslations {
  static let zhHant: [String: String] = [
    "Space limit:      %@":
      "空間上限：        %@",
    "                  Time Machine quota not set to match - run: %@":
      "                  Time Machine 配額尚未對應設定，請執行：%@",
    "Sets how much of Google Drive this Mac may use, and prints the Time Machine quota command.":
      "設定這台 Mac 可使用多少 Google Drive 空間，並輸出 Time Machine 配額指令。",
    "Limit in GB.":
      "上限，單位為 GB。",
    "Limit for this Mac: %@ GB.":
      "這台 Mac 的上限：%@ GB。",
    "Now set the Time Machine quota (needs an administrator password):":
      "現在設定 Time Machine 配額（需要管理員密碼）：",
    "CloudMachine - verification, Google Drive setup and installation. Called by launchd on a schedule, or by hand from Terminal.":
      "CloudMachine：檢查、Google Drive 設定與安裝。由 launchd 依排程呼叫，或在終端機中手動執行。",
    "Connects to Google Drive through rclone (OAuth in the browser) and creates this machine's folder.":
      "透過 rclone 連接 Google Drive（在瀏覽器中進行 OAuth 授權），並為這台虛擬機器建立資料夾。",
    "Overwrite the existing remote. RISKY: replaces the token and permissions.":
      "覆寫現有的 remote。有風險：會取代權杖與權限。",
    "Packs build/CloudMachine.app into build/CloudMachine-<version>.dmg.":
      "將 build/CloudMachine.app 打包成 build/CloudMachine-<version>.dmg。",
    "ERROR: %@ is missing - run 'cloudmachine-agent build-app' first":
      "錯誤：找不到 %@，請先執行 'cloudmachine-agent build-app'",
    "==> Preparing the staging folder":
      "==> 正在準備暫存資料夾",
    "==> Creating %@":
      "==> 正在建立 %@",
    "ERROR: hdiutil exited with code %@.":
      "錯誤：hdiutil 以代碼 %@ 結束。",
    "==> Done: %@":
      "==> 完成：%@",
    "On first launch (the app is not signed with an Apple Developer account):":
      "首次開啟時（此 App 未使用 Apple Developer 帳號簽署）：",
    "1. Open %@ and drag CloudMachine.app to Applications.":
      "1. 開啟 %@，並將 CloudMachine.app 拖到「應用程式」資料夾。",
    "2. In Finder, RIGHT-click CloudMachine.app -> Open -> Open\n   (a plain double-click shows the Gatekeeper block \"unidentified developer\").":
      "2. 在 Finder 中，按住 Control 鍵按一下（或按右鍵）CloudMachine.app -> 打開 -> 打開\n   （直接按兩下會顯示 Gatekeeper 的「未識別的開發者」攔截提示）。",
    "3. Later launches work normally, with a double-click.":
      "3. 之後即可正常按兩下開啟。",
    "Builds CloudMachine.app (Release) - GUI + cloudmachine-agent in Contents/MacOS/, plus launchd/, vm/ and config/ as Resources.":
      "建置 CloudMachine.app（Release）：圖形介面與 cloudmachine-agent 位於 Contents/MacOS/，launchd/、vm/ 和 config/ 則作為資源一併打包。",
    "Binaries for Apple Silicon and Intel at once (how CI builds a release; unnecessary locally).":
      "同時建置 Apple 晶片與 Intel 版本的二進位檔（CI 發行版本的方式；本機不需要）。",
    "==> Building CloudMachineApp + cloudmachine-agent (release) - version %@ (%@)":
      "==> 正在建置 CloudMachineApp + cloudmachine-agent（release）- 版本 %@（%@）",
    "ERROR: swift build exited with code %@.":
      "錯誤：swift build 以代碼 %@ 結束。",
    "ERROR: swift build --show-bin-path did not report the binaries directory.":
      "錯誤：swift build --show-bin-path 未回報二進位檔所在的目錄。",
    "ERROR: no built binary found at %@":
      "錯誤：在 %@ 找不到已建置的二進位檔",
    "==> Assembling the .app bundle in %@":
      "==> 正在 %@ 中組裝 .app 套件",
    "==> WARNING: you are building from a DIRTY tree - the version will not point to a commit.":
      "==> 警告：目前是從有未提交變更的工作樹建置，此版本無法對應到某次提交。",
    "ERROR: Resources/AppIcon.icns is missing - generate it: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns":
      "錯誤：找不到 Resources/AppIcon.icns，請產生：swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns",
    "==> Signing with the local certificate '%@' (Full Disk Access will survive later rebuilds)":
      "==> 正在使用本機憑證 '%@' 簽署（之後重新建置時，「完整磁碟取用權限」仍會保留）",
    "==> Signing ad-hoc (no Apple Developer account) - run 'cloudmachine-agent setup-signing-cert' once so that TCC permissions survive later rebuilds":
      "==> 正在進行臨時簽署（ad-hoc，沒有 Apple Developer 帳號）：請先執行一次 'cloudmachine-agent setup-signing-cert'，這樣之後重新建置時 TCC 權限才會保留",
    "ERROR: codesign exited with code %@.":
      "錯誤：codesign 以代碼 %@ 結束。",
    "Next step: %@":
      "下一步：%@",
    "Creates a local self-signed certificate so that Full Disk Access survives later rebuilds of the app.":
      "建立本機自行簽署的憑證，讓「完整磁碟取用權限」在之後重新建置 App 時仍能保留。",
    "Certificate '%@' already exists in %@, nothing to do.":
      "憑證 '%@' 已存在於 %@，不需要處理。",
    "==> Generating the key and self-signed certificate '%@'...":
      "==> 正在產生金鑰與自行簽署的憑證 '%@'...",
    "ERROR: openssl req exited with code %@.":
      "錯誤：openssl req 以代碼 %@ 結束。",
    "ERROR: openssl pkcs12 exited with code %@.":
      "錯誤：openssl pkcs12 以代碼 %@ 結束。",
    "==> Importing the certificate into %@ (pre-authorizing /usr/bin/codesign, so it does not ask for the keychain password every time)...":
      "==> 正在將憑證匯入 %@（已預先授權 /usr/bin/codesign，因此不會每次都詢問鑰匙圈密碼）...",
    "ERROR: security import exited with code %@.":
      "錯誤：security import 以代碼 %@ 結束。",
    "==> Trusting the certificate ONLY for code signing...":
      "==> 正在將此憑證設為僅信任用於程式碼簽署...",
    "ERROR: security add-trusted-cert exited with code %@.":
      "錯誤：security add-trusted-cert 以代碼 %@ 結束。",
    "Done. Certificate '%@' is now available to codesign.":
      "完成。憑證 '%@' 現在可供 codesign 使用。",
    "The next 'cloudmachine-agent build-app' will use it automatically instead of an ad-hoc signature.":
      "下次執行 'cloudmachine-agent build-app' 時，會自動使用它，而不是臨時簽署。",
    "After THAT ONE rebuild, grant Full Disk Access one last time - later\nrebuilds will no longer reset it, as long as you sign with the same certificate.":
      "在那一次重新建置之後，請再授予一次「完整磁碟取用權限」。\n只要使用同一個憑證簽署，之後重新建置就不會再重設該權限。",
    "Checks whether the hourly cycle STILL works (date of the last SUCCESSFUL backup) and reports failures.":
      "檢查每小時的備份週期是否仍正常運作（最近一次成功備份的日期），並回報故障。",
    "After this many hours without a successful backup we consider the cycle broken.":
      "超過這麼多小時沒有成功備份，就視為備份週期已中斷。",
    "Only print the state, without a system notification.":
      "只輸出狀態，不發送系統通知。",
    "A different Time Machine preferences file - to test the watchdog on a known sample.":
      "使用另一個 Time Machine 偏好設定檔，以便用已知範例測試備份監測。",
    "Last successful backup: %@":
      "最近一次成功備份：%@",
    "Last successful backup: NONE":
      "最近一次成功備份：無",
    "Last attempt:           %@":
      "最近一次嘗試：    %@",
    "WAITING (system startup): %@":
      "等待中（系統啟動）：%@",
    "Backup cycle: OK":
      "備份週期：正常",
    "FAILURE: %@":
      "故障：%@",
    "         %@":
      "         %@",
    "Check the state:  %@":
      "查看狀態：  %@",
    "Preparing for restart":
      "正在準備重新啟動",
    "Prepare for restart":
      "準備重新啟動",
    "Prepare":
      "準備",
    "==> WARNING: git rev-list failed (%@) - using the date as the build number.":
      "==> 警告：git rev-list 失敗（%@），改用日期作為建置編號。",
    "Agents:           %@":
      "代理程式：      %@",
    "CANNOT START: %@ - open CloudMachine or run backup-health to reload them":
      "無法啟動：%@，請開啟 CloudMachine 或執行 backup-health 重新載入",
    "Reloaded agents that could not start: %@":
      "已重新載入無法啟動的代理程式：%@",
    "Drive folder:     %@":
      "Drive 資料夾：  %@",
    "Name of this Mac's folder on Google Drive (default: derived from the computer name). Set once; it cannot be changed later.":
      "這台 Mac 在 Google Drive 上的資料夾名稱（預設：依電腦名稱產生）。只能設定一次，之後無法更改。",
    "Backup watchdog:  %@":
      "備份監測：      %@",
    "Prints the version, the build number and the commit this binary was built from.":
      "輸出版本、建置編號，以及建置此二進位檔所用的提交。",
    "Only one line, without a description.":
      "只輸出一行，不含說明。",
    "Build from the working tree (outside a bundle) - no version data.":
      "從工作樹建置（不在 App 套件內），沒有版本資料。",
    "Version: %@":
      "版本：%@",
    "Build:   %@":
      "建置：%@",
    "Commit:  %@":
      "提交：%@",
    "WARNING: built from a DIRTY tree - the binary contains code that\n         is in no commit. The commit number does NOT describe\n         what actually runs.":
      "警告：此版本是從有未提交變更的工作樹建置的，\n         其中包含不在任何提交中的程式碼。\n         提交編號無法說明實際執行的是什麼。",
    "Saving the space limit":
      "正在儲存空間上限",
    "Measuring usage on Google Drive":
      "正在測量 Google Drive 用量",
    "Google Drive did not answer - try again later.":
      "Google Drive 沒有回應，請稍後再試。",
    "Measured.":
      "已測量。",
    "Space limit for this Mac":
      "這台 Mac 的空間上限",
    "Used on Google Drive":
      "Google Drive 已用空間",
    "Measured %@. The watchdog measures again every few hours.":
      "已於 %@ 測量。備份監測每隔幾小時會再測量一次。",
    "Limit (GB)":
      "上限（GB）",
    "Save":
      "儲存",
    "Measure now":
      "立即測量",
    "Time Machine quota: %@ GB (70%% of the limit - the copy on Drive is about a third larger than the backup inside it). Time Machine deletes the oldest backups to stay within it.":
      "Time Machine 配額：%@ GB（上限的 70%%，因為 Drive 上的副本比其中的備份大了約三分之一）。Time Machine 會刪除最舊的備份，以維持在配額之內。",
    "Set the Time Machine quota: run this in Terminal (needs sudo)":
      "設定 Time Machine 配額：在終端機中執行以下指令（需要 sudo）",
    "Connect Google Drive: run this in Terminal and approve in the browser":
      "連接 Google Drive：在終端機中執行以下指令，並在瀏覽器中核准",
    "Grant Full Disk Access to CloudMachine, so it can tell whether backups complete":
      "為 CloudMachine 授予「完整磁碟取用權限」，這樣它才能判斷備份是否完成",
    "Folder on Google Drive":
      "Google Drive 上的資料夾",
    "One folder per Mac. Set once - it cannot be changed after connecting.":
      "每台 Mac 一個資料夾。只能設定一次，連接後無法更改。",
    "Use lowercase letters, digits and dashes.":
      "請使用小寫字母、數字與連字號。",
    "Install rclone":
      "安裝 rclone",
    "Open System Settings":
      "打開系統設定",
    "Install agents":
      "安裝代理程式",
    "not checked":
      "尚未檢查",
    "none at all":
      "完全沒有",
    "%@ ago":
      "%@前",
    "Missing: %@":
      "缺少：%@",
    "Google Drive not connected":
      "尚未連接 Google Drive",
    "Time Machine does not point to CloudMachine":
      "Time Machine 未指向 CloudMachine",
    "UNKNOWN whether Time Machine points to CloudMachine - tmutil did not answer":
      "無法確定 Time Machine 是否指向 CloudMachine，tmutil 沒有回應",
    "Backup in progress":
      "正在備份",
    "Unknown when the last backup was made":
      "不知道上次備份是什麼時候",
    "There is no completed backup at all":
      "完全沒有已完成的備份",
    "No completed backup for %@":
      "已有 %@ 沒有完成的備份",
    "Ready":
      "就緒",
    "Not saved: %@":
      "未儲存：%@",
    "Installing rclone":
      "正在安裝 rclone",
    "Installing launchd agents":
      "正在安裝 launchd 代理程式",
    "Starting backup":
      "正在開始備份",
    "Backup started.":
      "備份已開始。",
    "Could not start the backup.":
      "無法開始備份。",
    "Stopping backup":
      "正在停止備份",
    "Backup stopped.":
      "備份已停止。",
    "Could not stop the backup.":
      "無法停止備份。",
    "Could not prepare the AppleScript.":
      "無法準備 AppleScript。",
    "Unknown authorization error.":
      "未知的授權錯誤。",
    "Waiting to upload":
      "等待上傳",
    "%@ files":
      "%@ 個檔案",
    "nothing":
      "無",
    "Back up now":
      "立即備份",
    "Stop backup":
      "停止備份",
    "Open CloudMachine":
      "打開 CloudMachine",
    "Quit":
      "結束",
    "Healthy":
      "正常",
    "Attention":
      "需要注意",
    "Refreshed %@":
      "已於 %@ 重新整理",
    "System Status":
      "系統狀態",
    "Action needed":
      "需要處理",
    "not measured":
      "尚未測量",
    "rclone did not answer":
      "rclone 沒有回應",
    "Backup in Progress":
      "正在備份",
    "Files processed":
      "已處理的檔案",
    "Write speed":
      "寫入速度",
    "Operation phase":
      "作業階段",
    "Required Setup Steps":
      "必要的設定步驟",
    "Copy":
      "拷貝",
    "Last completed backup":
      "最近一次完成的備份",
    "Last backup watchdog run":
      "備份監測最近一次執行",
    "not read":
      "尚未讀取",
    "Everything uploaded":
      "已全部上傳",
    "File upload errors":
      "檔案上傳錯誤",
    "Google Drive Credentials (OAuth 2.0)":
      "Google Drive 認證資料（OAuth 2.0）",
    "Keychain OK":
      "鑰匙圈正常",
    "No custom keys":
      "沒有自訂金鑰",
    "Paste client_id...":
      "貼上 client_id...",
    "Paste client_secret...":
      "貼上 client_secret...",
    "Save securely in the Keychain":
      "安全地存入鑰匙圈",
    "Refresh":
      "重新整理",
    "Overview":
      "總覽",
    "Backups":
      "備份",
    "Storage":
      "儲存空間",
    "Settings":
      "設定",
    "Current status: %@":
      "目前狀態：%@",
    "Does not point to CloudMachine":
      "未指向 CloudMachine",
    "tmutil did not answer":
      "tmutil 沒有回應",
    "Backing up: %@ of %@":
      "正在備份：%@ / %@",
    "%@ of %@":
      "%@ / %@",
    "Copied":
      "已拷貝",
    "No backup is running":
      "沒有進行中的備份",
    "Time Machine starts the next one on its own schedule.":
      "Time Machine 會依自己的排程開始下一次備份。",
    "Backup cycle":
      "備份週期",
    "%@ GiB":
      "%@ GiB",
    "%@ GiB in %@ bands, %@ uploading":
      "%@ GiB，共 %@ 個分塊，正在上傳 %@ 個",
    "%@ bands":
      "%@ 個分塊",
    "%@ fragments abandoned - only in the machine":
      "%@ 個片段已放棄，僅存在於虛擬機器中",
    "127.0.0.1:5572 answers on the Mac: Lima forwards the machine's rclone remote control, which has no password. Any web page open in a browser can send it commands - including deleting the backup on Google Drive. Add the portForwards rule from vm/cmsmb.yaml to the machine and restart it (see vm/README.md).":
      "127.0.0.1:5572 在這台 Mac 上有回應：Lima 轉送了虛擬機器的 rclone 遠端控制，而它沒有密碼。瀏覽器中開啟的任何網頁都可以對它傳送指令，包括刪除 Google Drive 上的備份。請將 vm/cmsmb.yaml 中的 portForwards 規則加到虛擬機器，並重新啟動它（請參閱 vm/README.md）。",
    "A service in the CloudMachine machine is not running":
      "CloudMachine 虛擬機器中的某項服務沒有執行",
    "Address":
      "位址",
    "Agent installation INCOMPLETE - %@ of %@ did not go in:\n%@\n%@\nEvery missing agent is a function that has silently stopped working (vm-guard watches the machine's buffer, backup-health reports failures). Fix the cause and repeat the installation.":
      "代理程式安裝不完整：%@ / %@ 未能裝入：\n%@\n%@\n每個缺少的代理程式，都代表某項功能已悄悄停止運作（vm-guard 監看虛擬機器的緩衝區，backup-health 回報故障）。請排除原因後重新安裝。",
    "All running":
      "全部執行中",
    "Also install the launchd agents (same as install-launchd).":
      "同時安裝 launchd 代理程式（與 install-launchd 相同）。",
    "At most this many minutes of waiting for the upload.":
      "等待上傳的時間最多為這麼多分鐘。",
    "At the limit every new band fails with EMFILE and the backup stops. Check: cloudmachine-agent vm-status":
      "達到上限時，每個新分塊都會因 EMFILE 而失敗，備份隨之停止。檢查：cloudmachine-agent vm-status",
    "Cache on the machine's disk":
      "虛擬機器磁碟上的快取",
    "Connected to Google Drive, but could not create the folder '%@' - without it the machine has nowhere to keep the backup. Check the account permissions and try again.":
      "已連接到 Google Drive，但無法建立資料夾 '%@'，沒有它虛擬機器就沒有地方存放備份。請檢查帳號權限後再試一次。",
    "Convert the image":
      "轉換映像檔",
    "Converting the image to 32 MB bands":
      "正在將映像檔轉換為 32 MB 分塊",
    "Could not check with the current connection whether the backup is on Google Drive (%@), so remote '%@' was NOT replaced: without that answer the new sign-in cannot be checked against it.":
      "無法透過目前的連線檢查備份是否在 Google Drive 上（%@），因此 remote '%@' 沒有被取代：沒有這個結果，就無法用它來核對新的登入。",
    "Downloads the official rclone binary into ~/.cloudmachine/bin (Google sign-in and the machine's rclone.conf).":
      "將官方 rclone 二進位檔下載到 ~/.cloudmachine/bin（Google 登入與虛擬機器的 rclone.conf）。",
    "Free in the machine":
      "虛擬機器可用空間",
    "Free in the machine: %@":
      "虛擬機器可用空間：%@",
    "Generates and installs the launchd agents (app, backup watchdog, machine start, machine guard).":
      "產生並安裝 launchd 代理程式（App、備份監測、虛擬機器啟動、虛擬機器守護）。",
    "Install Lima, which runs the CloudMachine machine: run this in Terminal":
      "安裝執行 CloudMachine 虛擬機器的 Lima：在終端機中執行以下指令",
    "Install rclone (signs in to Google Drive for the machine)":
      "安裝 rclone（為虛擬機器登入 Google Drive）",
    "Install the background agents (machine start, buffer guard, backup watchdog)":
      "安裝背景代理程式（虛擬機器啟動、緩衝區守護、備份監測）",
    "Installs rclone through Homebrew - CloudMachine itself uses the one from install-rclone.":
      "透過 Homebrew 安裝 rclone；CloudMachine 本身使用的是 install-rclone 安裝的那一個。",
    "Info.plist, token and mapped/ of the backup image exist only on the machine's disk; without them the bands in %@ cannot be restored. The copy (tm-meta-sync, every 15 min) goes to %@. Check: cloudmachine-agent vm-status, then in the machine: journalctl -u tm-meta-sync":
      "備份映像檔的 Info.plist、權杖與 mapped/ 只存在於虛擬機器的磁碟上；沒有它們，%@ 中的分塊就無法復原。副本（tm-meta-sync，每 15 分鐘一次）會傳送到 %@。檢查：cloudmachine-agent vm-status，然後在虛擬機器中執行：journalctl -u tm-meta-sync",
    "Lima says the machine is running, but a command in it did not return. Without it nothing is known about Samba, rclone or the upload. Check: cloudmachine-agent vm-status":
      "Lima 顯示虛擬機器正在執行，但其中的某個指令沒有傳回。沒有它，就無法得知 Samba、rclone 或上傳的情況。檢查：cloudmachine-agent vm-status",
    "Machine":
      "虛擬機器",
    "Machine %@":
      "虛擬機器 %@",
    "Machine & Upload Status":
      "虛擬機器與上傳狀態",
    "Machine buffer":
      "虛擬機器緩衝區",
    "No Time Machine destination is the machine's share (smb://tm@<address>/CloudMachine) - backups are not being made there. The command is printed by: cloudmachine-agent vm-setup":
      "沒有任何 Time Machine 備份目的地是虛擬機器的共享（smb://tm@<address>/CloudMachine），因此不會在那裡進行備份。該指令由以下指令輸出：cloudmachine-agent vm-setup",
    "Not running: %@":
      "未執行：%@",
    "Not set up":
      "尚未設定",
    "Once it runs out, rclone stops uploading, the machine's buffer fills up and backups stop being made. At a growth of ~600 MB per hourly cycle that is about %@ days.":
      "用盡後，rclone 會停止上傳，虛擬機器的緩衝區會被填滿，備份也會停止。依每小時週期增加約 600 MB 計算，大約還能支撐 %@ 天。",
    "Or rclone.conf is missing: this Mac has already set up the CloudMachine machine, so it is not connected anew blindly. Restore the file from a backup (the machine keeps its own copy in %@). To connect anyway, create an empty file at the path `%@ config file` prints and run again - the existing folder is kept.":
      "或是缺少 rclone.conf：這台 Mac 已經設定過 CloudMachine 虛擬機器，因此不會不加確認就重新連接。請從備份中復原該檔案（虛擬機器在 %@ 中保留有自己的副本）。若仍要連接，請在 `%@ config file` 輸出的路徑建立一個空檔案，然後重新執行，現有資料夾會保留。",
    "Point Time Machine at the machine: run this in Terminal (needs sudo; Copy includes the password)":
      "讓 Time Machine 指向虛擬機器：在終端機中執行以下指令（需要 sudo；「拷貝」會包含密碼）",
    "Points to the machine":
      "指向虛擬機器",
    "Prepares for a restart: stops the backup, waits a while for the upload, then stops the machine cleanly.":
      "為重新啟動做準備：停止備份，等待一段時間讓上傳完成，然後正常關閉虛擬機器。",
    "Reading the Time Machine destination did not return within %@ s. That is how tmutil behaves when its destination hangs.":
      "讀取 Time Machine 備份目的地未在 %@ 秒內傳回。備份目的地卡住時，tmutil 就是這樣的表現。",
    "Remote '%@' was NOT replaced. The new sign-in gets the 'drive.file' scope, which sees only files created under its own client_id. The existing backup was most likely created by the current connection and would become invisible to it. Before anything is written, the new token is checked against the existing backup, and the replacement is abandoned if it cannot see it. The machine keeps its own copy of the configuration until vm-setup --replace-rclone-config. To go ahead, run again with --replace-existing --accept-scope-change.":
      "remote '%@' 沒有被取代。新的登入會取得 'drive.file' 權限範圍，只能看到由它自己的 client_id 建立的檔案。現有備份很可能是由目前的連線建立的，會對它不可見。在寫入任何內容之前，會先用現有備份核對新權杖，如果它看不到備份，就放棄取代。在執行 vm-setup --replace-rclone-config 之前，虛擬機器會保留自己的那份設定副本。若要繼續，請加上 --replace-existing --accept-scope-change 重新執行。",
    "Remote control:   OPEN on the Mac at 127.0.0.1:5572 - any web page can send rclone commands; see vm/README.md (portForwards)":
      "遠端控制：       在 Mac 上開放，位址為 127.0.0.1:5572，任何網頁都可以傳送 rclone 指令；請參閱 vm/README.md（portForwards）",
    "Running":
      "執行中",
    "Samba, rclone or punchfs in the machine is not active, so Time Machine has nowhere to write or the bands do not reach Google Drive. Check: cloudmachine-agent vm-status":
      "虛擬機器中的 Samba、rclone 或 punchfs 未處於作用中，因此 Time Machine 無處可寫入，或分塊無法送到 Google Drive。檢查：cloudmachine-agent vm-status",
    "Service %@":
      "服務 %@",
    "Services":
      "服務",
    "Set up the CloudMachine machine (the first time it downloads Ubuntu - several minutes)":
      "設定 CloudMachine 虛擬機器（首次會下載 Ubuntu，需要幾分鐘）",
    "Set up the CloudMachine machine again, so it prints the Time Machine command":
      "重新設定 CloudMachine 虛擬機器，以輸出 Time Machine 指令",
    "Set up the machine":
      "設定虛擬機器",
    "Setting up the CloudMachine machine":
      "正在設定 CloudMachine 虛擬機器",
    "Start the CloudMachine machine":
      "啟動 CloudMachine 虛擬機器",
    "Start the machine":
      "啟動虛擬機器",
    "Starting the CloudMachine machine":
      "正在啟動 CloudMachine 虛擬機器",
    "Still to upload: %@ GiB":
      "仍待上傳：%@ GiB",
    "Stopping the Time Machine backup...":
      "正在停止 Time Machine 備份...",
    "Stopping the machine %@...":
      "正在停止虛擬機器 %@...",
    "The CloudMachine machine does not answer":
      "CloudMachine 虛擬機器沒有回應",
    "The CloudMachine machine is not running":
      "CloudMachine 虛擬機器未執行",
    "The CloudMachine machine is not set up yet":
      "CloudMachine 虛擬機器尚未設定",
    "The CloudMachine machine is stopped":
      "CloudMachine 虛擬機器已停止",
    "The backup is stopped, the upload gets up to 30 minutes, then the machine shuts down cleanly. It starts again at the next login.":
      "備份會停止，上傳最多有 30 分鐘的時間，然後虛擬機器會正常關閉。下次登入時它會再次啟動。",
    "The machine %@ is not running - nothing to prepare.":
      "虛擬機器 %@ 未執行，不需要準備。",
    "The machine is stopped and everything reached Google Drive. The Mac can be restarted; the machine starts again at login.":
      "虛擬機器已停止，所有內容都已送到 Google Drive。可以重新啟動 Mac；虛擬機器會在登入時再次啟動。",
    "The machine is stopped. %@ GiB had not reached Google Drive yet - it is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "虛擬機器已停止。有 %@ GiB 尚未送到 Google Drive，它們保留在虛擬機器的緩衝區中，會在下次啟動後上傳。可以重新啟動 Mac。",
    "The machine is stopped. rclone did not say how much was still to upload; what was not uploaded is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "虛擬機器已停止。rclone 沒有說明還有多少內容待上傳；未上傳的內容保留在虛擬機器的緩衝區中，會在下次啟動後上傳。可以重新啟動 Mac。",
    "The machine's disk is a file on this disk and grows as the upload buffer fills. With no space left the machine cannot write the buffer, and Time Machine's local snapshots have nowhere to go either.":
      "虛擬機器的磁碟是這個磁碟上的一個檔案，會隨著上傳緩衝區被填滿而變大。沒有剩餘空間時，虛擬機器無法寫入緩衝區，Time Machine 的本機快照也無處可放。",
    "The image's metadata has never been copied to Drive":
      "映像檔的中繼資料從未拷貝到 Drive",
    "The image's metadata was last copied to Drive %@ ago":
      "映像檔的中繼資料已於 %@前拷貝到 Drive",
    "The machine's disk is running out of space (%@ GB)":
      "虛擬機器的磁碟空間即將用盡（%@ GB）",
    "The new sign-in does NOT see the existing backup (%@), so remote '%@' was NOT replaced and rclone.conf is unchanged. Keep the current connection, or sign in with the credential (client_id) that created the backup.":
      "新的登入看不到現有備份（%@），因此 remote '%@' 沒有被取代，rclone.conf 維持不變。請保留目前的連線，或使用建立該備份的認證資料（client_id）登入。",
    "The upload buffer lives on this disk. The guard pauses Time Machine before it fills; if the upload does not catch up, backups stay paused.":
      "上傳緩衝區位於這個磁碟上。守護程式會在緩衝區填滿之前暫停 Time Machine；如果上傳一直追不上，備份將持續暫停。",
    "These bands exist only in the machine's buffer. The backup on Google Drive is INCOMPLETE and may not open.":
      "這些分塊只存在於虛擬機器的緩衝區中。Google Drive 上的備份不完整，可能無法打開。",
    "Time Machine backs up to the machine, so without it no backup is made. Start it: limactl start %@ (or the Start button in the app).":
      "Time Machine 備份到虛擬機器，因此虛擬機器沒有執行就無法備份。啟動它：limactl start %@（或使用 App 中的「啟動虛擬機器」按鈕）。",
    "Time Machine did not stop its backup within 2 minutes (or tmutil did not answer) - the machine was NOT stopped. Try again in a moment.":
      "Time Machine 沒有在 2 分鐘內停止備份（或 tmutil 沒有回應），虛擬機器沒有被停止。請稍後再試一次。",
    "Time Machine has created its image: stop the backup, then convert the image to 32 MB bands":
      "Time Machine 已建立映像檔：停止備份，然後將映像檔轉換為 32 MB 分塊",
    "To upload":
      "待上傳",
    "Unknown whether the CloudMachine machine is running":
      "無法確定 CloudMachine 虛擬機器是否在執行",
    "Waiting for the upload to Google Drive (at most %@ min)...":
      "正在等待上傳到 Google Drive（最多 %@ 分鐘）...",
    "With --replace-existing: confirms that the new sign-in (scope 'drive.file') may not see the existing backup. The new token is still checked against the backup first.":
      "與 --replace-existing 一起使用：確認新的登入（權限範圍 'drive.file'）可能看不到現有備份。仍會先用該備份核對新權杖。",
    "Without it there is no way to check whether anything reached the Drive - the machine's guard is blind then.":
      "沒有它，就無法檢查是否有內容送到 Drive，虛擬機器的守護程式將處於盲區。",
    "limactl did not answer":
      "limactl 沒有回應",
    "limactl did not answer (or is not installed). That does not mean the machine is down - it means nobody has checked.":
      "limactl 沒有回應（或未安裝）。這並不表示虛擬機器已停止，只表示還沒有人檢查過。",
    "limactl start failed: %@":
      "limactl start 失敗：%@",
    "limactl stop failed: %@":
      "limactl stop 失敗：%@",
    "punchfs is close to its open-file limit":
      "punchfs 已接近其開啟檔案數上限",
    "punchfs open files":
      "punchfs 開啟的檔案",
    "rclone's remote control is open on this Mac":
      "rclone 的遠端控制在這台 Mac 上處於開放狀態",
    "statfs('/System/Volumes/Data') returned an error, so nobody knows whether the machine's disk can still grow on this Mac.":
      "statfs('/System/Volumes/Data') 傳回了錯誤，因此無法得知虛擬機器的磁碟在這台 Mac 上是否還能繼續增大。",
    "Google Drive's daily upload limit stops the upload":
      "Google Drive 的每日上傳上限使上傳停止",
    "Google last refused an upload %@ ago (750 GB a day). Backups since then are only in the machine's buffer on this Mac. rclone retries every 5 min and resumes by itself when the limit passes; the guard pauses Time Machine if more than %@ GiB waits.":
      "Google 在 %@前拒絕了一次上傳（每天 750 GB）。此後的備份只存在於這台 Mac 上虛擬機器的緩衝區中。rclone 每 5 分鐘重試一次，上限解除後會自動繼續；如果等待上傳的內容超過 %@ GiB，守護程式會暫停 Time Machine。",
    "Usage on Google Drive is not being measured":
      "未測量 Google Drive 的用量",
    "The last measurement (%@ GB) is from %@, %@ ago - rclone size has not answered since. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "最近一次測量（%@ GB）是在 %@，即 %@前，此後 rclone size 一直沒有回應。在它回應之前，沒有任何機制監看 %@ GB 的上限：90%% 與 100%% 的警示都不會觸發。請檢查 vm-status，或在視窗中按一下「立即測量」。",
    "rclone size has not answered even once. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "rclone size 一次都沒有回應過。在它回應之前，沒有任何機制監看 %@ GB 的上限：90%% 與 100%% 的警示都不會觸發。請檢查 vm-status，或在視窗中按一下「立即測量」。",
    "Saved in the Keychain. Connecting Google Drive (configure-remote) will use them.":
      "已存入鑰匙圈。連接 Google Drive（configure-remote）時會使用它們。",
    "Saved in the Keychain. The existing Google Drive connection keeps its old client_id, and on this Mac it should stay that way: a connection made with the new keys (the 'drive.file' scope) cannot see the backup created by the old one. Do not replace the connection here; the new keys are for a Mac that is not connected yet.":
      "已存入鑰匙圈。現有的 Google Drive 連線仍使用舊的 client_id，在這台 Mac 上應維持如此：用新金鑰建立的連線（'drive.file' 權限範圍）看不到由舊連線建立的備份。請不要在此處取代連線；新金鑰是留給尚未連接的 Mac 使用的。",
    "it is not there for the new token":
      "新權杖看不到它",
    "Cancel":
      "取消",
    "ACTION NEEDED":
      "需要處理",
    "WILL PASS BY ITSELF — DO NOTHING":
      "會自行恢復，無需操作",
    "UNKNOWN — CHECK AGAIN SHORTLY":
      "情況未知，請稍後再查看",
    "ALL GOOD":
      "一切正常",
    "Upload is not working":
      "上傳無法進行",
    "Upload stopped — no space left on Google Drive":
      "上傳已停止：Google Drive 上沒有剩餘空間",
    "%@ backup fragments not uploaded":
      "%@ 個備份片段未上傳",
    "Upload cannot keep up with writes":
      "上傳跟不上寫入速度",
    "Upload paused — Google daily limit":
      "上傳已暫停：Google 每日上限",
    "Uploading to Google Drive — %@ queued":
      "正在上傳到 Google Drive：%@ 個在佇列中",
    "Everything uploaded to Google Drive":
      "已全部上傳到 Google Drive",
    "Unknown what is waiting in the queue":
      "不知道佇列中還有什麼在等待",
    "There is no connection to Google Drive, so backups are only made on this Mac. If this does not pass by itself within a few minutes, check the network and the connection to Drive.":
      "與 Google Drive 之間沒有連線，因此備份只在這台 Mac 上進行。如果幾分鐘內沒有自行恢復，請檢查網路以及與 Drive 的連線。",
    "There is no space left on Google Drive. This will NOT pass by itself — you need to free up space on Drive. Until then Time Machine is paused, so that it does not fill up this Mac's disk.":
      "Google Drive 上沒有剩餘空間。這不會自行恢復：你需要在 Drive 上釋出空間。在此之前，Time Machine 會保持暫停，以免占滿這台 Mac 的磁碟。",
    "%@ backup fragments could not be uploaded and rclone stopped trying. These fragments exist only on this Mac, so the backup on Drive is incomplete. This needs checking.":
      "%@ 個備份片段無法上傳，rclone 已停止重試。這些片段只存在於這台 Mac 上，所以 Drive 上的備份不完整。需要檢查。",
    "Time Machine is writing faster than the upload goes, and the buffer has filled up. The backup will be paused until the upload catches up — this is a safeguard against filling up the disk, not a failure.":
      "Time Machine 的寫入速度比上傳速度快，緩衝區已滿。備份會暫停，直到上傳追上來為止。這是為了避免磁碟被占滿而設的保護機制，並非故障。",
    "Google accepts 750 GB per day and that limit has been used up. There is nothing to do: the limit renews by itself, usually within a few hours. Time Machine backups are made normally in the meantime and wait in the buffer — they will be uploaded as soon as Google starts accepting again.":
      "Google 每天接受 750 GB，這個上限已用完。不需要任何操作：上限會自行恢復，通常在幾個小時內。在此期間 Time Machine 會正常備份，資料會在緩衝區中等待，Google 重新接受後就會立即上傳。",
    "%@ backup fragments are queued and on their way to Drive.":
      "%@ 個備份片段在佇列中，正在傳送到 Drive。",
    "Nothing is waiting in the queue — the backup on Google Drive is complete.":
      "佇列中沒有等待的內容，Google Drive 上的備份是完整的。",
    "rclone did not answer the question about the queue, so it is unknown how many backups are still waiting to be uploaded. This does not mean something broke — under load the answer can be late. It only means that right now nobody knows. If it persists, the backup cycle check will report it.":
      "rclone 沒有回答關於佇列的詢問，因此不知道還有多少備份在等待上傳。這並不表示出了問題，負載較高時回應可能會延遲。這只表示目前沒有人知道。如果持續如此，備份週期檢查會回報出來。",
    "unknown error":
      "未知的錯誤",
    "rclone lsf ended with an error":
      "rclone lsf 以錯誤結束",
    "This Mac is close to its space limit on Google Drive":
      "這台 Mac 的 Google Drive 空間已接近上限",
    "%@ GB of %@ GB used. Time Machine deletes the oldest backups to stay within its quota; check that the quota is set (vm-status).":
      "已用 %@ GB，上限 %@ GB。Time Machine 會刪除最舊的備份，以維持在配額之內；請確認已設定配額（vm-status）。",
    "This Mac is over its space limit on Google Drive":
      "這台 Mac 的 Google Drive 空間已超出上限",
    "%@ GB of %@ GB used. Set the Time Machine quota (command in the app window or vm-status), or raise the limit.":
      "已用 %@ GB，上限 %@ GB。請設定 Time Machine 配額（指令見 App 視窗或 vm-status），或提高上限。",
    "not set":
      "未設定",
    "%@ GB - usage not measured yet":
      "%@ GB，用量尚未測量",
    "%@ of %@ GB used (%@%%)":
      "已用 %@ / %@ GB（%@%%）",
    "The limit must be a whole number of GB above zero.":
      "上限必須是大於零的整數 GB。",
    "machines.json cannot be read, so it was not overwritten. Fix or remove it first.":
      "無法讀取 machines.json，因此沒有覆寫它。請先修復或刪除它。",
    "'%@' is not a valid folder name: use lowercase letters, digits and dashes.":
      "'%@' 不是有效的資料夾名稱：請使用小寫字母、數字與連字號。",
    "This Mac already backs up to folder '%@'. Switching to '%@' would start a new, empty backup and orphan the existing one, so nothing was changed.":
      "這台 Mac 已備份到資料夾 '%@'。改用 '%@' 會開始一個新的空備份，並使現有備份成為孤立資料，因此沒有做任何變更。",
    "This Mac already has a CloudMachine installation, whose backup is in folder '%@'. Switching to '%@' would orphan it, so nothing was changed.":
      "這台 Mac 已安裝過 CloudMachine，其備份位於資料夾 '%@'。改用 '%@' 會使它成為孤立資料，因此沒有做任何變更。",
    "Could not save the folder name to %@: %@":
      "無法將資料夾名稱儲存到 %@：%@",
    "Homebrew is not installed. Install it manually: https://brew.sh":
      "尚未安裝 Homebrew。請手動安裝：https://brew.sh",
    "Installing rclone failed: %@":
      "安裝 rclone 失敗：%@",
    "Installed rclone.":
      "已安裝 rclone。",
    "Own Google credentials: set.":
      "自有的 Google 認證資料：已設定。",
    "INCOMPLETE: %@ is missing - rclone will use rclone's shared client_id anyway.":
      "不完整：缺少 %@，rclone 仍會使用 rclone 的共用 client_id。",
    "No own credentials - rclone uses the shared client_id, rate-limited jointly and being retired in 2026.":
      "沒有自有的認證資料：rclone 使用共用的 client_id，該 client_id 由所有使用者共同限速，並將在 2026 年停用。",
    "Empty value - not saving.":
      "值為空，不儲存。",
    "Keychain refused: %@":
      "鑰匙圈拒絕了要求：%@",
    "DIRTY-TREE":
      "未提交變更",
    "Cannot create the working directory: %@":
      "無法建立工作目錄：%@",
    "Could not read the rclone version number.":
      "無法讀取 rclone 的版本號碼。",
    "Could not download %@.":
      "無法下載 %@。",
    "No entry for %@ in SHA256SUMS.":
      "SHA256SUMS 中沒有 %@ 的項目。",
    "Could not compute the checksum.":
      "無法計算總和檢查碼。",
    "SHA256 checksum does not match - NOT installing.\n  expected: %@\n  computed: %@":
      "SHA256 總和檢查碼不符，不予安裝。\n  預期：%@\n  計算得到：%@",
    "Could not unpack the archive.":
      "無法解壓縮封存檔。",
    "Could not install the binary: %@":
      "無法安裝該二進位檔：%@",
    "Installed rclone %@ in %@ (SHA256 checksum matches).":
      "已將 rclone %@ 安裝到 %@（SHA256 總和檢查碼相符）。",
    "%@ did not respond within the allotted time (the process was left orphaned in the background).":
      "%@ 未在規定時間內回應（該程序已成為孤立程序留在背景）。",
    "Cannot launch %@: %@":
      "無法啟動 %@：%@",
    "Remote '%@' already exists and was NOT touched.\nOverwriting it replaces the token and the permission scope; a credential with the 'drive.file' scope does not see files created by the previous one, so the existing backup becomes unreachable.\nIf you really want to replace it, first back up ~/.config/rclone/rclone.conf and run again with --replace-existing.":
      "remote '%@' 已存在，沒有被更動。\n覆寫它會取代權杖與權限範圍；使用 'drive.file' 權限範圍的認證資料看不到由先前那個認證資料建立的檔案，因此現有備份將無法存取。\n如果確實要取代，請先備份 ~/.config/rclone/rclone.conf，然後加上 --replace-existing 重新執行。",
    "Could not check whether remote '%@' already exists (rclone listremotes did not answer or failed), so nothing was changed. Run `%@ listremotes` to see the error, then try again.":
      "無法檢查 remote '%@' 是否已存在（rclone listremotes 沒有回應或失敗），因此沒有做任何變更。請執行 `%@ listremotes` 查看錯誤，然後再試一次。",
    "Could not check whether this Mac already has a CloudMachine installation (rclone did not answer), so no folder was chosen. Try again in a moment.":
      "無法檢查這台 Mac 是否已安裝過 CloudMachine（rclone 沒有回應），因此沒有選擇資料夾。請稍後再試一次。",
    "rclone authorize failed (%@). If that binary is missing, start with: cloudmachine-agent install-rclone.":
      "rclone authorize 失敗（%@）。如果缺少該二進位檔，請先執行：cloudmachine-agent install-rclone。",
    "Could not read the token from the output of rclone authorize.":
      "無法從 rclone authorize 的輸出中讀取權杖。",
    "rclone config create failed.":
      "rclone config create 失敗。",
    "Connected to Google Drive as remote '%@', folder %@.":
      "已作為 remote '%@' 連接到 Google Drive，資料夾為 %@。",
    "tmutil is not responding - unknown where the backup goes":
      "tmutil 沒有回應，不知道備份存放在哪裡",
    "No successful backup for %@":
      "已有 %@ 沒有成功的備份",
    "Last COMPLETED backup: %@. The cycle is hourly, so that is %@ missed runs.":
      "最近一次完成的備份：%@。備份週期為每小時一次，因此已錯過 %@ 次執行。",
    "There is NOT A SINGLE successful backup":
      "沒有任何一次成功的備份",
    "The Time Machine preferences contain no date of a completed backup for this destination.":
      "Time Machine 偏好設定中沒有此備份目的地的已完成備份日期。",
    "The last backup attempt did not end in a backup":
      "最近一次備份嘗試沒有產生備份",
    "The attempt at %@ is newer than the last successful backup at %@.":
      "%@ 的嘗試比 %@ 的最近一次成功備份更新。",
    "Time Machine reports an error in the last run (RESULT=%@)":
      "Time Machine 回報上次執行出錯（RESULT=%@）",
    "A non-zero RESULT in the Time Machine preferences means the run did not succeed.":
      "Time Machine 偏好設定中的 RESULT 不為零，表示該次執行未成功。",
    "rclone failed to upload %@ files":
      "rclone 上傳 %@ 個檔案失敗",
    "Buffer full of nothing but unsent data":
      "緩衝區中全是尚未傳送的資料",
    "rclone has nothing left to evict from the buffer - the upload cannot keep up or has stalled.":
      "rclone 已沒有可從緩衝區中移出的內容，上傳跟不上或已停滯。",
    "The rclone control interface is not responding":
      "rclone 控制介面沒有回應",
    "Google Drive is running out of space (%@ GB)":
      "Google Drive 空間即將用盡（%@ GB）",
    "The Mac's disk is running out of space (%@ GB)":
      "Mac 的磁碟空間即將用盡（%@ GB）",
    "Cannot read the Time Machine preferences":
      "無法讀取 Time Machine 偏好設定",
    "%@ is unreadable - most often Full Disk Access is missing. Without this file it is UNKNOWN when the last backup was made, so we treat it as a failure, not as the absence of a problem.":
      "%@ 無法讀取，最常見的原因是缺少「完整磁碟取用權限」。沒有這個檔案，就無法得知上次備份的時間，所以我們把它視為故障，而不是沒有問題。",
    "Cannot measure free space on the Mac's disk":
      "無法測量 Mac 磁碟的可用空間",
    "%@ days":
      "%@ 天",
    "CloudMachine: backup is not working":
      "CloudMachine：備份未正常運作",
    "unknown reason":
      "原因不明",
    "osascript did not show the notification (permissions or no graphical session)":
      "osascript 沒有顯示通知（權限問題，或沒有圖形介面工作階段）",
    "UNDELIVERED ALARM: %@":
      "未送達的警示：%@",
    "from %@, reason: %@":
      "來自 %@，原因：%@",
    "The system notification was not delivered - you will see this alarm ONLY here.":
      "系統通知沒有送達，此警示只會顯示在這裡。",
    "%@ (%@ ago)":
      "%@（%@前）",
    "%@ - marker from the FUTURE":
      "%@：標記來自未來",
    "%@ (%@ ago) - THE WATCHDOG MAY NOT BE RUNNING":
      "%@（%@前）：備份監測可能沒有在執行",
    "NEVER - the watchdog has not recorded a single run":
      "從未：備份監測沒有記錄過任何一次執行",
    "Could not find the launchd/ directory with templates.":
      "找不到包含範本的 launchd/ 目錄。",
    "Could not find the compiled cloudmachine-agent binary.":
      "找不到已編譯的 cloudmachine-agent 二進位檔。",
    "ABORTED: could not put cloudmachine-agent in a stable location\n(%@) - most often a lack of space or permissions.\nNOT installing agents pointing at %@: that path\ndisappears on the next `swift build` or `git clean`, and backups stop\nwithout any visible signal.":
      "已中止：無法將 cloudmachine-agent 放到固定位置\n（%@），最常見的原因是空間或權限不足。\n不會安裝指向 %@ 的代理程式：該路徑\n會在下次 `swift build` 或 `git clean` 時消失，備份將在\n沒有任何可見提示的情況下停止。",
    "ABORTED: %@":
      "已中止：%@",
    "Could not list the templates in %@.":
      "無法列出 %@ 中的範本。",
    "could not read the template %@":
      "無法讀取範本 %@",
    "could not write %@ (lack of space or permissions)":
      "無法寫入 %@（空間或權限不足）",
    "launchctl load refused to load %@":
      "launchctl load 拒絕載入 %@",
    "NOT A SINGLE agent was loaded.":
      "沒有載入任何一個代理程式。",
    "Only these went in: %@.":
      "只裝入了這些：%@。",
    "Could not load any launchd agent.":
      "無法載入任何 launchd 代理程式。",
    "Installed agents: %@":
      "已安裝的代理程式：%@",
    "                  WARNING: close to the limit - new bands will fail with EMFILE":
      "                  警告：已接近上限，新的分塊將因 EMFILE 而失敗",
    "%@/bands on Google Drive is not empty - it may hold another backup. NOT overwriting it; check it by hand.":
      "Google Drive 上的 %@/bands 不是空的，其中可能有另一份備份。不會覆寫它，請手動檢查。",
    "Address:          %@":
      "位址：            %@",
    "Already prepared (%@ exists) - nothing to do.":
      "已經準備好（%@ 已存在），不需要處理。",
    "Converts Time Machine's new, empty image in the machine to 32 MB bands and moves the bands to Google Drive.":
      "將虛擬機器中 Time Machine 新建的空映像檔轉換為 32 MB 分塊，並將分塊移到 Google Drive。",
    "Copy rclone.conf into the machine even if it already has one.":
      "即使虛擬機器中已有 rclone.conf，也將其拷貝進去。",
    "Copying the converted image into the machine failed: %@":
      "將轉換後的映像檔拷貝到虛擬機器失敗：%@",
    "Copying the image to the Mac failed: %@":
      "將映像檔拷貝到 Mac 失敗：%@",
    "Could not ask Lima about the machine: %@":
      "無法向 Lima 詢問虛擬機器的情況：%@",
    "Could not carry the Time Machine files over: %@":
      "無法轉移 Time Machine 檔案：%@",
    "Could not check the image in the machine.":
      "無法檢查虛擬機器中的映像檔。",
    "Could not copy the rclone configuration into the machine.":
      "無法將 rclone 設定拷貝到虛擬機器。",
    "Could not create %@ on Google Drive: %@":
      "無法在 Google Drive 上建立 %@：%@",
    "Could not create %@: %@":
      "無法建立 %@：%@",
    "Could not find the vm/ directory with the machine template.":
      "找不到包含虛擬機器範本的 vm/ 目錄。",
    "Could not read the image size.":
      "無法讀取映像檔大小。",
    "Could not set the SMB password of user %@ in the machine.":
      "無法為虛擬機器中的使用者 %@ 設定 SMB 密碼。",
    "Could not stop smbd in the machine.":
      "無法停止虛擬機器中的 smbd。",
    "Could not write %@ in the machine.":
      "無法在虛擬機器中寫入 %@。",
    "Could not write the password file %@.":
      "無法寫入密碼檔 %@。",
    "Creates or starts the CloudMachine machine (Lima), gives it rclone's configuration and an SMB password, and prints the Time Machine command.":
      "建立或啟動 CloudMachine 虛擬機器（Lima），為它提供 rclone 設定與 SMB 密碼，並輸出 Time Machine 指令。",
    "Creating the machine %@ (first start downloads Ubuntu and installs packages - several minutes)...":
      "正在建立虛擬機器 %@（首次啟動會下載 Ubuntu 並安裝軟體套件，需要幾分鐘）...",
    "Done: %@ has %@ MB bands on Google Drive; the original is kept in %@ in the machine. Start the backup: tmutil startbackup":
      "完成：%@ 在 Google Drive 上有 %@ MB 的分塊；原始映像檔保存在虛擬機器的 %@ 中。開始備份：tmutil startbackup",
    "exit code %@, no message":
      "結束代碼 %@，沒有訊息",
    "Image metadata:   NEVER copied to %@ - check tm-meta-sync in the machine":
      "映像檔中繼資料：  從未拷貝到 %@，請檢查虛擬機器中的 tm-meta-sync",
    "Image metadata:   copied %@ ago to %@":
      "映像檔中繼資料：  已於 %@前拷貝到 %@",
    "Image metadata:   last copied %@ ago - OVERDUE (%@)":
      "映像檔中繼資料：  上次拷貝在 %@前，已逾期（%@）",
    "Image metadata:   not copied yet - waits for vm-prepare-bundle":
      "映像檔中繼資料：  尚未拷貝，等待 vm-prepare-bundle",
    "Backup %@, paused by the guard %@: %@":
      "備份 %@，守護程式暫停於 %@：%@",
    "Free in machine:  %@ GiB":
      "虛擬機器可用空間：%@ GiB",
    "fsck_apfs -n found problems: %@":
      "fsck_apfs -n 發現問題：%@",
    "Google Drive folder: %@":
      "Google Drive 資料夾：%@",
    "hdiutil attach of the converted image failed: %@":
      "hdiutil attach 掛載轉換後的映像檔失敗：%@",
    "hdiutil convert failed: %@":
      "hdiutil convert 失敗：%@",
    "Image name in the machine (default: from the computer name).":
      "虛擬機器中的映像檔名稱（預設：依電腦名稱產生）。",
    "Installing the converted image FAILED: %@\nsmbd is left STOPPED so Time Machine does not open a half-installed image. The original is in %@ in the machine.":
      "安裝轉換後的映像檔失敗：%@\nsmbd 保持停止狀態，以免 Time Machine 打開只裝了一半的映像檔。原始映像檔在虛擬機器的 %@ 中。",
    "limactl create failed: %@":
      "limactl create 失敗：%@",
    "limactl list failed: %@":
      "limactl list 失敗：%@",
    "limactl not found - install Lima: brew install lima":
      "找不到 limactl，請安裝 Lima：brew install lima",
    "limactl start failed: %@\nThe machine's own log: %@":
      "limactl start 失敗：%@\n虛擬機器自己的記錄檔：%@",
    "Machine %@ is running.":
      "虛擬機器 %@ 正在執行。",
    "Machine %@ was already running.":
      "虛擬機器 %@ 已在執行。",
    "Machine:          %@ (%@)":
      "虛擬機器：        %@（%@）",
    "Machine:          %@":
      "虛擬機器：        %@",
    "Machine:          not created - run: cloudmachine-agent vm-setup":
      "虛擬機器：        尚未建立，請執行：cloudmachine-agent vm-setup",
    "no answer within the time limit":
      "在時限內沒有回應",
    "No image %@ in the machine.":
      "虛擬機器中沒有映像檔 %@。",
    "No image in the machine yet - point Time Machine at the share and let it create one first.":
      "虛擬機器中還沒有映像檔，請先讓 Time Machine 指向該共享並建立一個。",
    "No rclone configuration at %@ - connect Google Drive first (configure-remote).":
      "在 %@ 沒有 rclone 設定，請先連接 Google Drive（configure-remote）。",
    "no SMB destination":
      "沒有 SMB 備份目的地",
    "One check of the machine's upload buffer: pauses Time Machine when it fills, resumes what it paused.":
      "對虛擬機器的上傳緩衝區做一次檢查：緩衝區填滿時暫停 Time Machine，並恢復它曾暫停的備份。",
    "Packing the converted image failed: %@":
      "打包轉換後的映像檔失敗：%@",
    "Packing the image failed: %@":
      "打包映像檔失敗：%@",
    "No answer from the machine (rclone rc) - the guard would do nothing.":
      "虛擬機器（rclone rc）沒有回應，守護程式將不會採取任何動作。",
    "Only print what the guard would decide - for trying thresholds on a throwaway machine.":
      "只輸出守護程式會做出的決定，用於在臨時虛擬機器上試驗門檻值。",
    "Pause above this many GiB in the buffer.":
      "緩衝區超過這麼多 GiB 時暫停。",
    "Pause when the machine has less free than this, in GiB.":
      "虛擬機器的可用空間少於這麼多 GiB 時暫停。",
    "Point Time Machine at the machine (once, needs an administrator password):":
      "讓 Time Machine 指向虛擬機器（只需一次，需要管理員密碼）：",
    "punchfs files:    %@ open, limit %@":
      "punchfs 檔案：    已開啟 %@ 個，上限 %@",
    "rclone configuration already in the machine - kept (--replace-rclone-config replaces it).":
      "虛擬機器中已有 rclone 設定，予以保留（--replace-rclone-config 可取代它）。",
    "rclone configuration copied into the machine.":
      "rclone 設定已拷貝到虛擬機器。",
    "rclone-tm or punchfs is not running in the machine - see cloudmachine-agent vm-status.":
      "虛擬機器中的 rclone-tm 或 punchfs 未執行，請參閱 cloudmachine-agent vm-status。",
    "Resume below this many GiB (only a backup the guard paused).":
      "低於這麼多 GiB 時恢復（僅限守護程式暫停的備份）。",
    "Service %@: %@":
      "服務 %@：%@",
    "Several images in the machine (%@) - choose one with --bundle.":
      "虛擬機器中有多個映像檔（%@），請用 --bundle 選擇一個。",
    "Shows the machine: address, services, upload buffer, free space and the Time Machine destination.":
      "顯示虛擬機器的情況：位址、服務、上傳緩衝區、可用空間與 Time Machine 備份目的地。",
    "SMB password stored in %@ (mode 600).":
      "SMB 密碼已儲存在 %@（權限 600）。",
    "The converted image does not have %@-byte bands.":
      "轉換後的映像檔的分塊不是 %@ 位元組。",
    "The converted image has no APFS partition.":
      "轉換後的映像檔沒有 APFS 分割區。",
    "The image already takes %@ MB - this command converts only a new, empty image (under %@ MB).":
      "映像檔已占用 %@ MB，此指令只轉換新建的空映像檔（小於 %@ MB）。",
    "The image is encrypted - converting encrypted images is not supported.":
      "映像檔已加密，不支援轉換加密的映像檔。",
    "The image was not changed; smbd started again.":
      "映像檔未被更改，smbd 已重新啟動。",
    "The machine does not answer - is it running? cloudmachine-agent vm-status":
      "虛擬機器沒有回應，它在執行嗎？cloudmachine-agent vm-status",
    "The machine has no address on the vzNAT network.":
      "虛擬機器在 vzNAT 網路上沒有位址。",
    "The services in the machine did not start - check: cloudmachine-agent vm-status":
      "虛擬機器中的服務沒有啟動，請檢查：cloudmachine-agent vm-status",
    "Time Machine is backing up - stop it first: tmutil stopbackup":
      "Time Machine 正在備份，請先停止：tmutil stopbackup",
    "Time Machine:     %@":
      "Time Machine：   %@",
    "Time Machine:     NOT pointing at the machine (%@)":
      "Time Machine：   未指向虛擬機器（%@）",
    "Time Machine:     tmutil did not answer":
      "Time Machine：   tmutil 沒有回應",
    "tmutil did not answer - not touching the image while its state is unknown.":
      "tmutil 沒有回應，在映像檔狀態未知時不會更動映像檔。",
    "unknown":
      "未知",
    "Unpacking the image failed: %@":
      "解開映像檔失敗：%@",
    "Still to upload:  %@ GiB in %@ bands, uploading %@ (cache on disk %@ GiB)":
      "仍待上傳：        %@ GiB，共 %@ 個分塊，正在上傳 %@（磁碟快取 %@ GiB）",
    "Excluded %@ (the machine and its upload buffer) from Time Machine.":
      "已將 %@（虛擬機器及其上傳緩衝區）從 Time Machine 中排除。",
    "WARNING: could not exclude %@ from Time Machine - run: tmutil addexclusion %@":
      "警告：無法將 %@ 從 Time Machine 中排除，請執行：tmutil addexclusion %@",
    "Upload buffer:    no answer from rclone (rc %@)":
      "上傳緩衝區：      rclone 沒有回應（rc %@）",
    "When Time Machine has created its empty image, stop the backup (tmutil stopbackup) and run: cloudmachine-agent vm-prepare-bundle":
      "Time Machine 建立好空映像檔後，請停止備份（tmutil stopbackup）並執行：cloudmachine-agent vm-prepare-bundle",
    "Unsent %@ GiB, free %@ GiB (pause above %@ GiB unsent or below %@ GiB free, resume below %@ GiB).":
      "未傳送 %@ GiB，可用 %@ GiB（未傳送超過 %@ GiB 或可用低於 %@ GiB 時暫停，低於 %@ GiB 時恢復）。",
    "Upload:           Google's daily limit refused an upload %@ ago - rclone retries every 5 min and resumes by itself":
      "上傳：            Google 的每日上限在 %@前拒絕了一次上傳，rclone 每 5 分鐘重試一次，並會自動繼續",
    "no":
      "否",
    "running":
      "執行中",
    "stopped":
      "已停止",
    "yes":
      "是",
    "%@\nThe previous template is in %@ - copy it back over lima.yaml and run limactl start %@.":
      "%@\n先前的範本在 %@，請將它拷貝回 lima.yaml，然後執行 limactl start %@。",
    "Could not read this app's machine template (limactl template copy).":
      "無法讀取此 App 的虛擬機器範本（limactl template copy）。",
    "Could not replace %@: %@":
      "無法取代 %@：%@",
    "Machine %@ already runs this app's template.":
      "虛擬機器 %@ 已在使用此 App 的範本。",
    "Machine %@ now runs this app's template; the previous one is in %@.":
      "虛擬機器 %@ 現在使用此 App 的範本；先前的範本在 %@。",
    "Moves the machine onto this app's template (two restarts, never during a backup).":
      "將虛擬機器切換到此 App 的範本（會重新啟動兩次，絕不會在備份期間進行）。",
    "No machine %@ - create it with: cloudmachine-agent vm-setup":
      "沒有虛擬機器 %@，請用以下指令建立：cloudmachine-agent vm-setup",
    "Template:         OLDER than this app's - run: cloudmachine-agent vm-update":
      "範本：            比此 App 的舊，請執行：cloudmachine-agent vm-update",
    "Template:         not compared":
      "範本：            未比較",
    "Template:         this app's":
      "範本：            與此 App 一致",
    "The machine has no %@ - run cloudmachine-agent vm-setup first.":
      "虛擬機器中沒有 %@，請先執行 cloudmachine-agent vm-setup。",
    "The machine restarted, but not every service is running - check: cloudmachine-agent vm-status. The previous template is in %@.":
      "虛擬機器已重新啟動，但並非所有服務都在執行，請檢查：cloudmachine-agent vm-status。先前的範本在 %@。",
    "The template changes the machine itself (%@) - that needs a new machine, not an update.":
      "該範本會更改虛擬機器本身（%@），這需要新建虛擬機器，而不是更新。",
    "The upload to Google Drive hangs":
      "上傳到 Google Drive 卡住了",
    "Time Machine is backing up - try again when it has finished.":
      "Time Machine 正在備份，請在它完成後再試一次。",
    "Upload:           HANGS - bands in progress, none uploaded for %@ (network?); see /var/log/rclone-tm.log in the machine":
      "上傳：            卡住，有分塊正在處理，已有 %@ 沒有任何分塊上傳完成（網路問題？）；請查看虛擬機器中的 /var/log/rclone-tm.log",
    "limactl stop failed - nothing was changed.":
      "limactl stop 失敗，沒有做任何變更。",
    "rclone has bands in progress, but none has been uploaded for %@ - usually a broken network connection, which rclone does not report as an error. Backups since then are only in the machine's buffer. When the network comes back the upload resumes by itself (on 28.10.2026 within 80 s); if it does not, restarting the machine (prepare-shutdown, limactl start) drops the dead connections.":
      "rclone 有分塊正在處理，但已有 %@ 沒有任何分塊上傳完成，這通常是網路連線中斷造成的，rclone 不會把它回報為錯誤。此後的備份只存在於虛擬機器的緩衝區中。網路恢復後，上傳會自動繼續（2026 年 10 月 28 日那次在 80 秒內恢復）；如果沒有恢復，請重新啟動虛擬機器（prepare-shutdown，limactl start）以丟棄失效的連線。",
    "tmutil did not answer - not restarting the machine while its state is unknown.":
      "tmutil 沒有回應，在狀態未知時不會重新啟動虛擬機器。",
  ]
}
