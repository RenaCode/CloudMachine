// Simplified Chinese translations, keyed by the English text passed to `L10n.tr`.
extension L10nTranslations {
  static let zhHans: [String: String] = [
    "Space limit:      %@":
      "空间上限：        %@",
    "                  Time Machine quota not set to match - run: %@":
      "                  Time Machine 配额未相应设置，请运行：%@",
    "Sets how much of Google Drive this Mac may use, and prints the Time Machine quota command.":
      "设置此 Mac 可使用多少 Google Drive 空间，并输出 Time Machine 配额命令。",
    "Limit in GB.":
      "上限，单位为 GB。",
    "Limit for this Mac: %@ GB.":
      "此 Mac 的上限：%@ GB。",
    "Now set the Time Machine quota (needs an administrator password):":
      "现在设置 Time Machine 配额（需要管理员密码）：",
    "CloudMachine - verification, Google Drive setup and installation. Called by launchd on a schedule, or by hand from Terminal.":
      "CloudMachine：检查、Google Drive 设置与安装。由 launchd 按计划调用，或在终端中手动运行。",
    "Connects to Google Drive through rclone (OAuth in the browser) and creates this machine's folder.":
      "通过 rclone 连接 Google Drive（在浏览器中进行 OAuth 授权），并为此虚拟机创建文件夹。",
    "Overwrite the existing remote. RISKY: replaces the token and permissions.":
      "覆盖现有 remote。有风险：会替换令牌和权限。",
    "Packs build/CloudMachine.app into build/CloudMachine-<version>.dmg.":
      "将 build/CloudMachine.app 打包为 build/CloudMachine-<version>.dmg。",
    "ERROR: %@ is missing - run 'cloudmachine-agent build-app' first":
      "错误：缺少 %@，请先运行 'cloudmachine-agent build-app'",
    "==> Preparing the staging folder":
      "==> 正在准备暂存文件夹",
    "==> Creating %@":
      "==> 正在创建 %@",
    "ERROR: hdiutil exited with code %@.":
      "错误：hdiutil 以代码 %@ 退出。",
    "==> Done: %@":
      "==> 完成：%@",
    "On first launch (the app is not signed with an Apple Developer account):":
      "首次打开时（此 App 未使用 Apple Developer 账户签名）：",
    "1. Open %@ and drag CloudMachine.app to Applications.":
      "1. 打开 %@，并将 CloudMachine.app 拖到“应用程序”文件夹。",
    "2. In Finder, RIGHT-click CloudMachine.app -> Open -> Open\n   (a plain double-click shows the Gatekeeper block \"unidentified developer\").":
      "2. 在访达中，按住 Control 键点按（或右键点按）CloudMachine.app -> 打开 -> 打开\n   （直接双击会显示 Gatekeeper 的“未识别的开发者”拦截提示）。",
    "3. Later launches work normally, with a double-click.":
      "3. 之后即可正常双击打开。",
    "Builds CloudMachine.app (Release) - GUI + cloudmachine-agent in Contents/MacOS/, plus launchd/, vm/ and config/ as Resources.":
      "构建 CloudMachine.app（Release）：图形界面与 cloudmachine-agent 位于 Contents/MacOS/，launchd/、vm/ 和 config/ 作为资源一并打包。",
    "Binaries for Apple Silicon and Intel at once (how CI builds a release; unnecessary locally).":
      "同时构建 Apple 芯片和 Intel 版本的二进制文件（CI 发布版本的方式；本地无需使用）。",
    "==> Building CloudMachineApp + cloudmachine-agent (release) - version %@ (%@)":
      "==> 正在构建 CloudMachineApp + cloudmachine-agent（release）- 版本 %@（%@）",
    "ERROR: swift build exited with code %@.":
      "错误：swift build 以代码 %@ 退出。",
    "ERROR: swift build --show-bin-path did not report the binaries directory.":
      "错误：swift build --show-bin-path 未报告二进制文件所在的目录。",
    "ERROR: no built binary found at %@":
      "错误：在 %@ 未找到已构建的二进制文件",
    "==> Assembling the .app bundle in %@":
      "==> 正在 %@ 中组装 .app 包",
    "==> WARNING: you are building from a DIRTY tree - the version will not point to a commit.":
      "==> 警告：当前是从有未提交更改的工作树构建，此版本无法对应到某次提交。",
    "ERROR: Resources/AppIcon.icns is missing - generate it: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns":
      "错误：缺少 Resources/AppIcon.icns，请生成：swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns",
    "==> Signing with the local certificate '%@' (Full Disk Access will survive later rebuilds)":
      "==> 正在使用本地证书 '%@' 签名（之后重新构建时，完全磁盘访问权限仍会保留）",
    "==> Signing ad-hoc (no Apple Developer account) - run 'cloudmachine-agent setup-signing-cert' once so that TCC permissions survive later rebuilds":
      "==> 正在进行临时签名（ad-hoc，没有 Apple Developer 账户）：请先运行一次 'cloudmachine-agent setup-signing-cert'，这样之后重新构建时 TCC 权限才能保留",
    "ERROR: codesign exited with code %@.":
      "错误：codesign 以代码 %@ 退出。",
    "Next step: %@":
      "下一步：%@",
    "Creates a local self-signed certificate so that Full Disk Access survives later rebuilds of the app.":
      "创建本地自签名证书，使“完全磁盘访问权限”在之后重新构建 App 时仍能保留。",
    "Certificate '%@' already exists in %@, nothing to do.":
      "证书 '%@' 已存在于 %@，无需操作。",
    "==> Generating the key and self-signed certificate '%@'...":
      "==> 正在生成密钥和自签名证书 '%@'...",
    "ERROR: openssl req exited with code %@.":
      "错误：openssl req 以代码 %@ 退出。",
    "ERROR: openssl pkcs12 exited with code %@.":
      "错误：openssl pkcs12 以代码 %@ 退出。",
    "==> Importing the certificate into %@ (pre-authorizing /usr/bin/codesign, so it does not ask for the keychain password every time)...":
      "==> 正在将证书导入 %@（已预先授权 /usr/bin/codesign，因此不会每次都询问钥匙串密码）...",
    "ERROR: security import exited with code %@.":
      "错误：security import 以代码 %@ 退出。",
    "==> Trusting the certificate ONLY for code signing...":
      "==> 正在将该证书仅设为信任用于代码签名...",
    "ERROR: security add-trusted-cert exited with code %@.":
      "错误：security add-trusted-cert 以代码 %@ 退出。",
    "Done. Certificate '%@' is now available to codesign.":
      "完成。证书 '%@' 现在可供 codesign 使用。",
    "The next 'cloudmachine-agent build-app' will use it automatically instead of an ad-hoc signature.":
      "下次运行 'cloudmachine-agent build-app' 时，将自动使用它，而不是临时签名。",
    "After THAT ONE rebuild, grant Full Disk Access one last time - later\nrebuilds will no longer reset it, as long as you sign with the same certificate.":
      "在那一次重新构建之后，请再授予一次“完全磁盘访问权限”。\n只要使用同一个证书签名，之后重新构建就不会再重置该权限。",
    "Checks whether the hourly cycle STILL works (date of the last SUCCESSFUL backup) and reports failures.":
      "检查每小时的备份周期是否仍在正常运行（最近一次成功备份的日期），并报告故障。",
    "After this many hours without a successful backup we consider the cycle broken.":
      "超过这么多小时没有成功备份，就认为备份周期已中断。",
    "Only print the state, without a system notification.":
      "仅输出状态，不发送系统通知。",
    "A different Time Machine preferences file - to test the watchdog on a known sample.":
      "使用另一个 Time Machine 偏好设置文件，以便用已知样本测试备份监测。",
    "Last successful backup: %@":
      "最近一次成功备份：%@",
    "Last successful backup: NONE":
      "最近一次成功备份：无",
    "Last attempt:           %@":
      "最近一次尝试：    %@",
    "WAITING (system startup): %@":
      "等待中（系统启动）：%@",
    "Backup cycle: OK":
      "备份周期：正常",
    "FAILURE: %@":
      "故障：%@",
    "         %@":
      "         %@",
    "Check the state:  %@":
      "查看状态：  %@",
    "Preparing for restart":
      "正在准备重启",
    "Prepare for restart":
      "准备重启",
    "Prepare":
      "准备",
    "==> WARNING: git rev-list failed (%@) - using the date as the build number.":
      "==> 警告：git rev-list 失败（%@），改用日期作为构建号。",
    "Agents:           %@":
      "代理：          %@",
    "CANNOT START: %@ - open CloudMachine or run backup-health to reload them":
      "无法启动：%@，请打开 CloudMachine 或运行 backup-health 重新载入",
    "Reloaded agents that could not start: %@":
      "已重新载入无法启动的代理：%@",
    "Drive folder:     %@":
      "Drive 文件夹：  %@",
    "Name of this Mac's folder on Google Drive (default: derived from the computer name). Set once; it cannot be changed later.":
      "此 Mac 在 Google Drive 上的文件夹名称（默认：根据电脑名称生成）。只能设置一次，之后无法更改。",
    "Backup watchdog:  %@":
      "备份监测：      %@",
    "Prints the version, the build number and the commit this binary was built from.":
      "输出版本、构建号以及构建此二进制文件所用的提交。",
    "Only one line, without a description.":
      "只输出一行，不带说明。",
    "Build from the working tree (outside a bundle) - no version data.":
      "从工作树构建（不在 App 包内），没有版本数据。",
    "Version: %@":
      "版本：%@",
    "Build:   %@":
      "构建：%@",
    "Commit:  %@":
      "提交：%@",
    "WARNING: built from a DIRTY tree - the binary contains code that\n         is in no commit. The commit number does NOT describe\n         what actually runs.":
      "警告：此版本是从有未提交更改的工作树构建的，\n         其中包含不在任何提交中的代码。\n         提交编号并不能说明实际运行的是什么。",
    "Saving the space limit":
      "正在保存空间上限",
    "Measuring usage on Google Drive":
      "正在测量 Google Drive 用量",
    "Google Drive did not answer - try again later.":
      "Google Drive 没有响应，请稍后再试。",
    "Measured.":
      "已测量。",
    "Space limit for this Mac":
      "此 Mac 的空间上限",
    "Used on Google Drive":
      "Google Drive 已用空间",
    "Measured %@. The watchdog measures again every few hours.":
      "已于 %@ 测量。备份监测每隔几小时会再次测量。",
    "Limit (GB)":
      "上限（GB）",
    "Save":
      "保存",
    "Measure now":
      "立即测量",
    "Time Machine quota: %@ GB (70%% of the limit - the copy on Drive is about a third larger than the backup inside it). Time Machine deletes the oldest backups to stay within it.":
      "Time Machine 配额：%@ GB（上限的 70%%，因为 Drive 上的副本比其中的备份大约大三分之一）。Time Machine 会删除最旧的备份，以保持在配额之内。",
    "Set the Time Machine quota: run this in Terminal (needs sudo)":
      "设置 Time Machine 配额：在终端中运行以下命令（需要 sudo）",
    "Connect Google Drive: run this in Terminal and approve in the browser":
      "连接 Google Drive：在终端中运行以下命令，并在浏览器中批准",
    "Grant Full Disk Access to CloudMachine, so it can tell whether backups complete":
      "为 CloudMachine 授予“完全磁盘访问权限”，以便它能判断备份是否完成",
    "Folder on Google Drive":
      "Google Drive 上的文件夹",
    "One folder per Mac. Set once - it cannot be changed after connecting.":
      "每台 Mac 一个文件夹。只能设置一次，连接后无法更改。",
    "Use lowercase letters, digits and dashes.":
      "请使用小写字母、数字和连字符。",
    "Install rclone":
      "安装 rclone",
    "Open System Settings":
      "打开系统设置",
    "Install agents":
      "安装代理",
    "not checked":
      "未检查",
    "none at all":
      "完全没有",
    "%@ ago":
      "%@前",
    "Missing: %@":
      "缺少：%@",
    "Google Drive not connected":
      "未连接 Google Drive",
    "Time Machine does not point to CloudMachine":
      "Time Machine 未指向 CloudMachine",
    "UNKNOWN whether Time Machine points to CloudMachine - tmutil did not answer":
      "无法确定 Time Machine 是否指向 CloudMachine，tmutil 没有响应",
    "Backup in progress":
      "正在备份",
    "Unknown when the last backup was made":
      "不知道上次备份是什么时候",
    "There is no completed backup at all":
      "完全没有已完成的备份",
    "No completed backup for %@":
      "已有 %@ 没有完成的备份",
    "Ready":
      "就绪",
    "Not saved: %@":
      "未保存：%@",
    "Installing rclone":
      "正在安装 rclone",
    "Installing launchd agents":
      "正在安装 launchd 代理",
    "Starting backup":
      "正在开始备份",
    "Backup started.":
      "备份已开始。",
    "Could not start the backup.":
      "无法开始备份。",
    "Stopping backup":
      "正在停止备份",
    "Backup stopped.":
      "备份已停止。",
    "Could not stop the backup.":
      "无法停止备份。",
    "Could not prepare the AppleScript.":
      "无法准备 AppleScript。",
    "Unknown authorization error.":
      "未知的授权错误。",
    "Waiting to upload":
      "等待上传",
    "%@ files":
      "%@ 个文件",
    "nothing":
      "无",
    "Back up now":
      "立即备份",
    "Stop backup":
      "停止备份",
    "Open CloudMachine":
      "打开 CloudMachine",
    "Quit":
      "退出",
    "Healthy":
      "正常",
    "Attention":
      "需要注意",
    "Refreshed %@":
      "已于 %@ 刷新",
    "System Status":
      "系统状态",
    "Action needed":
      "需要处理",
    "not measured":
      "未测量",
    "rclone did not answer":
      "rclone 没有响应",
    "Backup in Progress":
      "正在备份",
    "Files processed":
      "已处理文件",
    "Write speed":
      "写入速度",
    "Operation phase":
      "操作阶段",
    "Required Setup Steps":
      "必要的设置步骤",
    "Copy":
      "拷贝",
    "Last completed backup":
      "最近一次完成的备份",
    "Last backup watchdog run":
      "备份监测最近一次运行",
    "not read":
      "未读取",
    "Everything uploaded":
      "已全部上传",
    "File upload errors":
      "文件上传错误",
    "Google Drive Credentials (OAuth 2.0)":
      "Google Drive 凭据（OAuth 2.0）",
    "Keychain OK":
      "钥匙串正常",
    "No custom keys":
      "没有自定义密钥",
    "Paste client_id...":
      "粘贴 client_id...",
    "Paste client_secret...":
      "粘贴 client_secret...",
    "Save securely in the Keychain":
      "安全存入钥匙串",
    "Refresh":
      "刷新",
    "Overview":
      "概览",
    "Backups":
      "备份",
    "Storage":
      "存储",
    "Settings":
      "设置",
    "Current status: %@":
      "当前状态：%@",
    "Does not point to CloudMachine":
      "未指向 CloudMachine",
    "tmutil did not answer":
      "tmutil 没有响应",
    "Backing up: %@ of %@":
      "正在备份：%@ / %@",
    "%@ of %@":
      "%@ / %@",
    "Copied":
      "已拷贝",
    "No backup is running":
      "没有正在进行的备份",
    "Time Machine starts the next one on its own schedule.":
      "Time Machine 会按自己的计划开始下一次备份。",
    "Backup cycle":
      "备份周期",
    "%@ GiB":
      "%@ GiB",
    "%@ GiB in %@ bands, %@ uploading":
      "%@ GiB，共 %@ 个分块，正在上传 %@ 个",
    "%@ bands":
      "%@ 个分块",
    "%@ fragments abandoned - only in the machine":
      "%@ 个片段已放弃，仅存在于虚拟机中",
    "127.0.0.1:5572 answers on the Mac: Lima forwards the machine's rclone remote control, which has no password. Any web page open in a browser can send it commands - including deleting the backup on Google Drive. Add the portForwards rule from vm/cmsmb.yaml to the machine and restart it (see vm/README.md).":
      "127.0.0.1:5572 在此 Mac 上有响应：Lima 转发了虚拟机的 rclone 远程控制，而它没有密码。浏览器中打开的任何网页都可以向它发送命令，包括删除 Google Drive 上的备份。请将 vm/cmsmb.yaml 中的 portForwards 规则添加到虚拟机并重新启动它（参见 vm/README.md）。",
    "A service in the CloudMachine machine is not running":
      "CloudMachine 虚拟机中的某项服务没有运行",
    "Address":
      "地址",
    "Agent installation INCOMPLETE - %@ of %@ did not go in:\n%@\n%@\nEvery missing agent is a function that has silently stopped working (vm-guard watches the machine's buffer, backup-health reports failures). Fix the cause and repeat the installation.":
      "代理安装不完整：%@ / %@ 未能装入：\n%@\n%@\n每个缺失的代理都意味着某项功能已悄悄停止工作（vm-guard 监视虚拟机的缓冲区，backup-health 报告故障）。请排除原因后重新安装。",
    "All running":
      "全部运行中",
    "Also install the launchd agents (same as install-launchd).":
      "同时安装 launchd 代理（与 install-launchd 相同）。",
    "At most this many minutes of waiting for the upload.":
      "等待上传的时间最多为这么多分钟。",
    "At the limit every new band fails with EMFILE and the backup stops. Check: cloudmachine-agent vm-status":
      "达到上限时，每个新分块都会因 EMFILE 而失败，备份随之停止。检查：cloudmachine-agent vm-status",
    "Cache on the machine's disk":
      "虚拟机磁盘上的缓存",
    "Connected to Google Drive, but could not create the folder '%@' - without it the machine has nowhere to keep the backup. Check the account permissions and try again.":
      "已连接到 Google Drive，但无法创建文件夹 '%@'，没有它虚拟机就没有地方保存备份。请检查账户权限后重试。",
    "Convert the image":
      "转换映像",
    "Converting the image to 32 MB bands":
      "正在将映像转换为 32 MB 分块",
    "Could not check with the current connection whether the backup is on Google Drive (%@), so remote '%@' was NOT replaced: without that answer the new sign-in cannot be checked against it.":
      "无法通过当前连接检查备份是否在 Google Drive 上（%@），因此 remote '%@' 没有被替换：没有这一结果，就无法用它来核对新的登录。",
    "Downloads the official rclone binary into ~/.cloudmachine/bin (Google sign-in and the machine's rclone.conf).":
      "将官方 rclone 二进制文件下载到 ~/.cloudmachine/bin（Google 登录和虚拟机的 rclone.conf）。",
    "Free in the machine":
      "虚拟机可用空间",
    "Free in the machine: %@":
      "虚拟机可用空间：%@",
    "Generates and installs the launchd agents (app, backup watchdog, machine start, machine guard).":
      "生成并安装 launchd 代理（App、备份监测、虚拟机启动、虚拟机守护）。",
    "Install Lima, which runs the CloudMachine machine: run this in Terminal":
      "安装运行 CloudMachine 虚拟机的 Lima：在终端中运行以下命令",
    "Install rclone (signs in to Google Drive for the machine)":
      "安装 rclone（为虚拟机登录 Google Drive）",
    "Install the background agents (machine start, buffer guard, backup watchdog)":
      "安装后台代理（虚拟机启动、缓冲区守护、备份监测）",
    "Installs rclone through Homebrew - CloudMachine itself uses the one from install-rclone.":
      "通过 Homebrew 安装 rclone；CloudMachine 自身使用的是 install-rclone 安装的那一个。",
    "Info.plist, token and mapped/ of the backup image exist only on the machine's disk; without them the bands in %@ cannot be restored. The copy (tm-meta-sync, every 15 min) goes to %@. Check: cloudmachine-agent vm-status, then in the machine: journalctl -u tm-meta-sync":
      "备份映像的 Info.plist、令牌和 mapped/ 只存在于虚拟机的磁盘上；没有它们，%@ 中的分块就无法恢复。副本（tm-meta-sync，每 15 分钟一次）会发送到 %@。检查：cloudmachine-agent vm-status，然后在虚拟机中运行：journalctl -u tm-meta-sync",
    "Lima says the machine is running, but a command in it did not return. Without it nothing is known about Samba, rclone or the upload. Check: cloudmachine-agent vm-status":
      "Lima 显示虚拟机正在运行，但其中的某个命令没有返回。没有它，就无法得知 Samba、rclone 或上传的情况。检查：cloudmachine-agent vm-status",
    "Machine":
      "虚拟机",
    "Machine %@":
      "虚拟机 %@",
    "Machine & Upload Status":
      "虚拟机与上传状态",
    "Machine buffer":
      "虚拟机缓冲区",
    "No Time Machine destination is the machine's share (smb://tm@<address>/CloudMachine) - backups are not being made there. The command is printed by: cloudmachine-agent vm-setup":
      "没有任何 Time Machine 备份目标是虚拟机的共享（smb://tm@<address>/CloudMachine），因此不会在那里进行备份。该命令由以下命令输出：cloudmachine-agent vm-setup",
    "Not running: %@":
      "未运行：%@",
    "Not set up":
      "未设置",
    "Once it runs out, rclone stops uploading, the machine's buffer fills up and backups stop being made. At a growth of ~600 MB per hourly cycle that is about %@ days.":
      "用尽后，rclone 会停止上传，虚拟机的缓冲区会被填满，备份也会停止。按每小时周期增长约 600 MB 计算，大约还能支撑 %@ 天。",
    "Or rclone.conf is missing: this Mac has already set up the CloudMachine machine, so it is not connected anew blindly. Restore the file from a backup (the machine keeps its own copy in %@). To connect anyway, create an empty file at the path `%@ config file` prints and run again - the existing folder is kept.":
      "或者缺少 rclone.conf：此 Mac 已经设置过 CloudMachine 虚拟机，因此不会不加确认地重新连接。请从备份中恢复该文件（虚拟机在 %@ 中保留有自己的副本）。如仍要连接，请在 `%@ config file` 输出的路径创建一个空文件，然后重新运行，现有文件夹会保留。",
    "Point Time Machine at the machine: run this in Terminal (needs sudo; Copy includes the password)":
      "让 Time Machine 指向虚拟机：在终端中运行以下命令（需要 sudo；“拷贝”会包含密码）",
    "Points to the machine":
      "指向虚拟机",
    "Prepares for a restart: stops the backup, waits a while for the upload, then stops the machine cleanly.":
      "为重启做准备：停止备份，等待一段时间让上传完成，然后正常关闭虚拟机。",
    "Reading the Time Machine destination did not return within %@ s. That is how tmutil behaves when its destination hangs.":
      "读取 Time Machine 备份目标未在 %@ 秒内返回。备份目标卡住时，tmutil 就是这样的表现。",
    "Remote '%@' was NOT replaced. The new sign-in gets the 'drive.file' scope, which sees only files created under its own client_id. The existing backup was most likely created by the current connection and would become invisible to it. Before anything is written, the new token is checked against the existing backup, and the replacement is abandoned if it cannot see it. The machine keeps its own copy of the configuration until vm-setup --replace-rclone-config. To go ahead, run again with --replace-existing --accept-scope-change.":
      "remote '%@' 没有被替换。新的登录会获得 'drive.file' 权限范围，只能看到由它自己的 client_id 创建的文件。现有备份很可能是由当前连接创建的，会对它不可见。在写入任何内容之前，会先用现有备份核对新令牌，如果它看不到备份，则放弃替换。在运行 vm-setup --replace-rclone-config 之前，虚拟机会保留自己的那份配置副本。如要继续，请加上 --replace-existing --accept-scope-change 重新运行。",
    "Remote control:   OPEN on the Mac at 127.0.0.1:5572 - any web page can send rclone commands; see vm/README.md (portForwards)":
      "远程控制：       在 Mac 上开放，地址为 127.0.0.1:5572，任何网页都可以发送 rclone 命令；参见 vm/README.md（portForwards）",
    "Running":
      "运行中",
    "Samba, rclone or punchfs in the machine is not active, so Time Machine has nowhere to write or the bands do not reach Google Drive. Check: cloudmachine-agent vm-status":
      "虚拟机中的 Samba、rclone 或 punchfs 未处于活动状态，因此 Time Machine 无处写入，或分块无法到达 Google Drive。检查：cloudmachine-agent vm-status",
    "Service %@":
      "服务 %@",
    "Services":
      "服务",
    "Set up the CloudMachine machine (the first time it downloads Ubuntu - several minutes)":
      "设置 CloudMachine 虚拟机（首次会下载 Ubuntu，需要几分钟）",
    "Set up the CloudMachine machine again, so it prints the Time Machine command":
      "重新设置 CloudMachine 虚拟机，以输出 Time Machine 命令",
    "Set up the machine":
      "设置虚拟机",
    "Setting up the CloudMachine machine":
      "正在设置 CloudMachine 虚拟机",
    "Start the CloudMachine machine":
      "启动 CloudMachine 虚拟机",
    "Start the machine":
      "启动虚拟机",
    "Starting the CloudMachine machine":
      "正在启动 CloudMachine 虚拟机",
    "Still to upload: %@ GiB":
      "仍待上传：%@ GiB",
    "Stopping the Time Machine backup...":
      "正在停止 Time Machine 备份...",
    "Stopping the machine %@...":
      "正在停止虚拟机 %@...",
    "The CloudMachine machine does not answer":
      "CloudMachine 虚拟机没有响应",
    "The CloudMachine machine is not running":
      "CloudMachine 虚拟机未运行",
    "The CloudMachine machine is not set up yet":
      "CloudMachine 虚拟机尚未设置",
    "The CloudMachine machine is stopped":
      "CloudMachine 虚拟机已停止",
    "The backup is stopped, the upload gets up to 30 minutes, then the machine shuts down cleanly. It starts again at the next login.":
      "备份会停止，上传最多有 30 分钟时间，然后虚拟机会正常关闭。下次登录时它会再次启动。",
    "The machine %@ is not running - nothing to prepare.":
      "虚拟机 %@ 未运行，无需准备。",
    "The machine is stopped and everything reached Google Drive. The Mac can be restarted; the machine starts again at login.":
      "虚拟机已停止，所有内容都已到达 Google Drive。可以重启 Mac；虚拟机会在登录时再次启动。",
    "The machine is stopped. %@ GiB had not reached Google Drive yet - it is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "虚拟机已停止。有 %@ GiB 尚未到达 Google Drive，它们保留在虚拟机的缓冲区中，会在下次启动后上传。可以重启 Mac。",
    "The machine is stopped. rclone did not say how much was still to upload; what was not uploaded is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "虚拟机已停止。rclone 没有说明还有多少内容待上传；未上传的内容保留在虚拟机的缓冲区中，会在下次启动后上传。可以重启 Mac。",
    "The machine's disk is a file on this disk and grows as the upload buffer fills. With no space left the machine cannot write the buffer, and Time Machine's local snapshots have nowhere to go either.":
      "虚拟机的磁盘是此磁盘上的一个文件，会随着上传缓冲区被填满而增大。没有剩余空间时，虚拟机无法写入缓冲区，Time Machine 的本地快照也无处存放。",
    "The image's metadata has never been copied to Drive":
      "映像的元数据从未拷贝到 Drive",
    "The image's metadata was last copied to Drive %@ ago":
      "映像的元数据已于 %@前拷贝到 Drive",
    "The machine's disk is running out of space (%@ GB)":
      "虚拟机的磁盘空间即将用尽（%@ GB）",
    "The new sign-in does NOT see the existing backup (%@), so remote '%@' was NOT replaced and rclone.conf is unchanged. Keep the current connection, or sign in with the credential (client_id) that created the backup.":
      "新的登录看不到现有备份（%@），因此 remote '%@' 没有被替换，rclone.conf 保持不变。请保留当前连接，或使用创建该备份的凭据（client_id）登录。",
    "The upload buffer lives on this disk. The guard pauses Time Machine before it fills; if the upload does not catch up, backups stay paused.":
      "上传缓冲区位于此磁盘上。守护程序会在缓冲区填满之前暂停 Time Machine；如果上传一直追不上，备份将保持暂停。",
    "These bands exist only in the machine's buffer. The backup on Google Drive is INCOMPLETE and may not open.":
      "这些分块只存在于虚拟机的缓冲区中。Google Drive 上的备份不完整，可能无法打开。",
    "Time Machine backs up to the machine, so without it no backup is made. Start it: limactl start %@ (or the Start button in the app).":
      "Time Machine 备份到虚拟机，因此虚拟机不运行就无法备份。启动它：limactl start %@（或使用 App 中的“启动虚拟机”按钮）。",
    "Time Machine did not stop its backup within 2 minutes (or tmutil did not answer) - the machine was NOT stopped. Try again in a moment.":
      "Time Machine 没有在 2 分钟内停止备份（或 tmutil 没有响应），虚拟机没有被停止。请稍后再试。",
    "Time Machine has created its image: stop the backup, then convert the image to 32 MB bands":
      "Time Machine 已创建映像：停止备份，然后将映像转换为 32 MB 分块",
    "To upload":
      "待上传",
    "Unknown whether the CloudMachine machine is running":
      "无法确定 CloudMachine 虚拟机是否在运行",
    "Waiting for the upload to Google Drive (at most %@ min)...":
      "正在等待上传到 Google Drive（最多 %@ 分钟）...",
    "With --replace-existing: confirms that the new sign-in (scope 'drive.file') may not see the existing backup. The new token is still checked against the backup first.":
      "与 --replace-existing 一起使用：确认新的登录（权限范围 'drive.file'）可能看不到现有备份。仍会先用该备份核对新令牌。",
    "Without it there is no way to check whether anything reached the Drive - the machine's guard is blind then.":
      "没有它，就无法检查是否有内容到达 Drive，虚拟机的守护程序将处于盲区。",
    "limactl did not answer":
      "limactl 没有响应",
    "limactl did not answer (or is not installed). That does not mean the machine is down - it means nobody has checked.":
      "limactl 没有响应（或未安装）。这并不表示虚拟机已停止，只表示还没有人检查过。",
    "limactl start failed: %@":
      "limactl start 失败：%@",
    "limactl stop failed: %@":
      "limactl stop 失败：%@",
    "punchfs is close to its open-file limit":
      "punchfs 已接近其打开文件数上限",
    "punchfs open files":
      "punchfs 打开的文件",
    "rclone's remote control is open on this Mac":
      "rclone 的远程控制在此 Mac 上处于开放状态",
    "statfs('/System/Volumes/Data') returned an error, so nobody knows whether the machine's disk can still grow on this Mac.":
      "statfs('/System/Volumes/Data') 返回了错误，因此无法得知虚拟机的磁盘在此 Mac 上是否还能继续增大。",
    "Google Drive's daily upload limit stops the upload":
      "Google Drive 的每日上传上限使上传停止",
    "Google last refused an upload %@ ago (750 GB a day). Backups since then are only in the machine's buffer on this Mac. rclone retries every 5 min and resumes by itself when the limit passes; the guard pauses Time Machine if more than %@ GiB waits.":
      "Google 在 %@前拒绝了一次上传（每天 750 GB）。此后的备份只存在于此 Mac 上虚拟机的缓冲区中。rclone 每 5 分钟重试一次，上限解除后会自动继续；如果等待上传的内容超过 %@ GiB，守护程序会暂停 Time Machine。",
    "Usage on Google Drive is not being measured":
      "未测量 Google Drive 的用量",
    "The last measurement (%@ GB) is from %@, %@ ago - rclone size has not answered since. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "最近一次测量（%@ GB）是在 %@，即 %@前，此后 rclone size 一直没有响应。在它响应之前，没有任何机制监视 %@ GB 的上限：90%% 和 100%% 的警报都不会触发。请检查 vm-status，或在窗口中点按“立即测量”。",
    "rclone size has not answered even once. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "rclone size 一次都没有响应过。在它响应之前，没有任何机制监视 %@ GB 的上限：90%% 和 100%% 的警报都不会触发。请检查 vm-status，或在窗口中点按“立即测量”。",
    "Saved in the Keychain. Connecting Google Drive (configure-remote) will use them.":
      "已存入钥匙串。连接 Google Drive（configure-remote）时将使用它们。",
    "Saved in the Keychain. The existing Google Drive connection keeps its old client_id, and on this Mac it should stay that way: a connection made with the new keys (the 'drive.file' scope) cannot see the backup created by the old one. Do not replace the connection here; the new keys are for a Mac that is not connected yet.":
      "已存入钥匙串。现有的 Google Drive 连接仍使用旧的 client_id，在此 Mac 上应保持如此：用新密钥建立的连接（'drive.file' 权限范围）看不到由旧连接创建的备份。请不要在此处替换连接；新密钥是留给尚未连接的 Mac 使用的。",
    "it is not there for the new token":
      "新令牌看不到它",
    "Cancel":
      "取消",
    "ACTION NEEDED":
      "需要处理",
    "WILL PASS BY ITSELF — DO NOTHING":
      "会自行恢复，无需操作",
    "UNKNOWN — CHECK AGAIN SHORTLY":
      "情况未知，请稍后再查看",
    "ALL GOOD":
      "一切正常",
    "Upload is not working":
      "上传无法进行",
    "Upload stopped — no space left on Google Drive":
      "上传已停止：Google Drive 上没有剩余空间",
    "%@ backup fragments not uploaded":
      "%@ 个备份片段未上传",
    "Upload cannot keep up with writes":
      "上传跟不上写入速度",
    "Upload paused — Google daily limit":
      "上传已暂停：Google 每日上限",
    "Uploading to Google Drive — %@ queued":
      "正在上传到 Google Drive：%@ 个在队列中",
    "Everything uploaded to Google Drive":
      "已全部上传到 Google Drive",
    "Unknown what is waiting in the queue":
      "不知道队列中还有什么在等待",
    "There is no connection to Google Drive, so backups are only made on this Mac. If this does not pass by itself within a few minutes, check the network and the connection to Drive.":
      "与 Google Drive 之间没有连接，因此备份只在此 Mac 上进行。如果几分钟内没有自行恢复，请检查网络以及与 Drive 的连接。",
    "There is no space left on Google Drive. This will NOT pass by itself — you need to free up space on Drive. Until then Time Machine is paused, so that it does not fill up this Mac's disk.":
      "Google Drive 上没有剩余空间。这不会自行恢复：您需要在 Drive 上释放空间。在此之前，Time Machine 会保持暂停，以免占满此 Mac 的磁盘。",
    "%@ backup fragments could not be uploaded and rclone stopped trying. These fragments exist only on this Mac, so the backup on Drive is incomplete. This needs checking.":
      "%@ 个备份片段无法上传，rclone 已停止重试。这些片段只存在于此 Mac 上，所以 Drive 上的备份不完整。需要检查。",
    "Time Machine is writing faster than the upload goes, and the buffer has filled up. The backup will be paused until the upload catches up — this is a safeguard against filling up the disk, not a failure.":
      "Time Machine 的写入速度快于上传速度，缓冲区已满。备份会暂停，直到上传追上来为止。这是为防止磁盘被占满而设的保护措施，并非故障。",
    "Google accepts 750 GB per day and that limit has been used up. There is nothing to do: the limit renews by itself, usually within a few hours. Time Machine backups are made normally in the meantime and wait in the buffer — they will be uploaded as soon as Google starts accepting again.":
      "Google 每天接受 750 GB，这一上限已用完。无需任何操作：上限会自行恢复，通常在几个小时内。在此期间 Time Machine 会正常备份，数据会在缓冲区中等待，Google 重新接受后就会立即上传。",
    "%@ backup fragments are queued and on their way to Drive.":
      "%@ 个备份片段在队列中，正在发送到 Drive。",
    "Nothing is waiting in the queue — the backup on Google Drive is complete.":
      "队列中没有等待的内容，Google Drive 上的备份是完整的。",
    "rclone did not answer the question about the queue, so it is unknown how many backups are still waiting to be uploaded. This does not mean something broke — under load the answer can be late. It only means that right now nobody knows. If it persists, the backup cycle check will report it.":
      "rclone 没有回答关于队列的询问，因此不知道还有多少备份在等待上传。这并不表示出了问题，负载较高时响应可能会延迟。这只表示目前没有人知道。如果持续如此，备份周期检查会报告出来。",
    "unknown error":
      "未知错误",
    "rclone lsf ended with an error":
      "rclone lsf 以错误结束",
    "This Mac is close to its space limit on Google Drive":
      "此 Mac 的 Google Drive 空间已接近上限",
    "%@ GB of %@ GB used. Time Machine deletes the oldest backups to stay within its quota; check that the quota is set (vm-status).":
      "已用 %@ GB，上限 %@ GB。Time Machine 会删除最旧的备份，以保持在配额之内；请确认已设置配额（vm-status）。",
    "This Mac is over its space limit on Google Drive":
      "此 Mac 的 Google Drive 空间已超出上限",
    "%@ GB of %@ GB used. Set the Time Machine quota (command in the app window or vm-status), or raise the limit.":
      "已用 %@ GB，上限 %@ GB。请设置 Time Machine 配额（命令见 App 窗口或 vm-status），或提高上限。",
    "not set":
      "未设置",
    "%@ GB - usage not measured yet":
      "%@ GB，用量尚未测量",
    "%@ of %@ GB used (%@%%)":
      "已用 %@ / %@ GB（%@%%）",
    "The limit must be a whole number of GB above zero.":
      "上限必须是大于零的整数 GB。",
    "machines.json cannot be read, so it was not overwritten. Fix or remove it first.":
      "无法读取 machines.json，因此没有覆盖它。请先修复或删除它。",
    "'%@' is not a valid folder name: use lowercase letters, digits and dashes.":
      "'%@' 不是有效的文件夹名称：请使用小写字母、数字和连字符。",
    "This Mac already backs up to folder '%@'. Switching to '%@' would start a new, empty backup and orphan the existing one, so nothing was changed.":
      "此 Mac 已备份到文件夹 '%@'。改用 '%@' 会开始一个新的空备份，并使现有备份成为孤立数据，因此没有做任何更改。",
    "This Mac already has a CloudMachine installation, whose backup is in folder '%@'. Switching to '%@' would orphan it, so nothing was changed.":
      "此 Mac 已安装过 CloudMachine，其备份位于文件夹 '%@'。改用 '%@' 会使它成为孤立数据，因此没有做任何更改。",
    "Could not save the folder name to %@: %@":
      "无法将文件夹名称保存到 %@：%@",
    "Homebrew is not installed. Install it manually: https://brew.sh":
      "未安装 Homebrew。请手动安装：https://brew.sh",
    "Installing rclone failed: %@":
      "安装 rclone 失败：%@",
    "Installed rclone.":
      "已安装 rclone。",
    "Own Google credentials: set.":
      "自有 Google 凭据：已设置。",
    "INCOMPLETE: %@ is missing - rclone will use rclone's shared client_id anyway.":
      "不完整：缺少 %@，rclone 仍会使用 rclone 的共享 client_id。",
    "No own credentials - rclone uses the shared client_id, rate-limited jointly and being retired in 2026.":
      "没有自有凭据：rclone 使用共享的 client_id，该 client_id 由所有用户共同限速，并将在 2026 年停用。",
    "Empty value - not saving.":
      "值为空，不保存。",
    "Keychain refused: %@":
      "钥匙串拒绝了请求：%@",
    "DIRTY-TREE":
      "未提交更改",
    "Cannot create the working directory: %@":
      "无法创建工作目录：%@",
    "Could not read the rclone version number.":
      "无法读取 rclone 的版本号。",
    "Could not download %@.":
      "无法下载 %@。",
    "No entry for %@ in SHA256SUMS.":
      "SHA256SUMS 中没有 %@ 的条目。",
    "Could not compute the checksum.":
      "无法计算校验和。",
    "SHA256 checksum does not match - NOT installing.\n  expected: %@\n  computed: %@":
      "SHA256 校验和不匹配，不予安装。\n  预期：%@\n  计算得到：%@",
    "Could not unpack the archive.":
      "无法解压归档。",
    "Could not install the binary: %@":
      "无法安装该二进制文件：%@",
    "Installed rclone %@ in %@ (SHA256 checksum matches).":
      "已将 rclone %@ 安装到 %@（SHA256 校验和一致）。",
    "%@ did not respond within the allotted time (the process was left orphaned in the background).":
      "%@ 未在规定时间内响应（该进程已作为孤立进程留在后台）。",
    "Cannot launch %@: %@":
      "无法启动 %@：%@",
    "Remote '%@' already exists and was NOT touched.\nOverwriting it replaces the token and the permission scope; a credential with the 'drive.file' scope does not see files created by the previous one, so the existing backup becomes unreachable.\nIf you really want to replace it, first back up ~/.config/rclone/rclone.conf and run again with --replace-existing.":
      "remote '%@' 已存在，没有被改动。\n覆盖它会替换令牌和权限范围；使用 'drive.file' 权限范围的凭据看不到由之前那个凭据创建的文件，因此现有备份将无法访问。\n如果确实要替换，请先备份 ~/.config/rclone/rclone.conf，然后加上 --replace-existing 重新运行。",
    "Could not check whether remote '%@' already exists (rclone listremotes did not answer or failed), so nothing was changed. Run `%@ listremotes` to see the error, then try again.":
      "无法检查 remote '%@' 是否已存在（rclone listremotes 没有响应或失败），因此没有做任何更改。请运行 `%@ listremotes` 查看错误，然后重试。",
    "Could not check whether this Mac already has a CloudMachine installation (rclone did not answer), so no folder was chosen. Try again in a moment.":
      "无法检查此 Mac 是否已安装过 CloudMachine（rclone 没有响应），因此没有选择文件夹。请稍后再试。",
    "rclone authorize failed (%@). If that binary is missing, start with: cloudmachine-agent install-rclone.":
      "rclone authorize 失败（%@）。如果缺少该二进制文件，请先运行：cloudmachine-agent install-rclone。",
    "Could not read the token from the output of rclone authorize.":
      "无法从 rclone authorize 的输出中读取令牌。",
    "rclone config create failed.":
      "rclone config create 失败。",
    "Connected to Google Drive as remote '%@', folder %@.":
      "已作为 remote '%@' 连接到 Google Drive，文件夹为 %@。",
    "tmutil is not responding - unknown where the backup goes":
      "tmutil 没有响应，不知道备份保存在哪里",
    "No successful backup for %@":
      "已有 %@ 没有成功的备份",
    "Last COMPLETED backup: %@. The cycle is hourly, so that is %@ missed runs.":
      "最近一次完成的备份：%@。备份周期为每小时一次，因此已错过 %@ 次运行。",
    "There is NOT A SINGLE successful backup":
      "没有任何一次成功的备份",
    "The Time Machine preferences contain no date of a completed backup for this destination.":
      "Time Machine 偏好设置中没有此备份目标的已完成备份日期。",
    "The last backup attempt did not end in a backup":
      "最近一次备份尝试没有产生备份",
    "The attempt at %@ is newer than the last successful backup at %@.":
      "%@ 的尝试比 %@ 的最近一次成功备份更新。",
    "Time Machine reports an error in the last run (RESULT=%@)":
      "Time Machine 报告上次运行出错（RESULT=%@）",
    "A non-zero RESULT in the Time Machine preferences means the run did not succeed.":
      "Time Machine 偏好设置中的 RESULT 不为零，表示该次运行未成功。",
    "rclone failed to upload %@ files":
      "rclone 上传 %@ 个文件失败",
    "Buffer full of nothing but unsent data":
      "缓冲区中全是尚未发送的数据",
    "rclone has nothing left to evict from the buffer - the upload cannot keep up or has stalled.":
      "rclone 已没有可从缓冲区中移出的内容，上传跟不上或已停滞。",
    "The rclone control interface is not responding":
      "rclone 控制接口没有响应",
    "Google Drive is running out of space (%@ GB)":
      "Google Drive 空间即将用尽（%@ GB）",
    "The Mac's disk is running out of space (%@ GB)":
      "Mac 的磁盘空间即将用尽（%@ GB）",
    "Cannot read the Time Machine preferences":
      "无法读取 Time Machine 偏好设置",
    "%@ is unreadable - most often Full Disk Access is missing. Without this file it is UNKNOWN when the last backup was made, so we treat it as a failure, not as the absence of a problem.":
      "%@ 无法读取，最常见的原因是缺少“完全磁盘访问权限”。没有这个文件，就无法得知上次备份的时间，所以我们把它当作故障，而不是没有问题。",
    "Cannot measure free space on the Mac's disk":
      "无法测量 Mac 磁盘的可用空间",
    "%@ days":
      "%@ 天",
    "CloudMachine: backup is not working":
      "CloudMachine：备份未正常工作",
    "unknown reason":
      "原因未知",
    "osascript did not show the notification (permissions or no graphical session)":
      "osascript 没有显示通知（权限问题，或没有图形界面会话）",
    "UNDELIVERED ALARM: %@":
      "未送达的警报：%@",
    "from %@, reason: %@":
      "来自 %@，原因：%@",
    "The system notification was not delivered - you will see this alarm ONLY here.":
      "系统通知没有送达，此警报只会显示在这里。",
    "%@ (%@ ago)":
      "%@（%@前）",
    "%@ - marker from the FUTURE":
      "%@：标记来自未来",
    "%@ (%@ ago) - THE WATCHDOG MAY NOT BE RUNNING":
      "%@（%@前）：备份监测可能没有在运行",
    "NEVER - the watchdog has not recorded a single run":
      "从未：备份监测没有记录过任何一次运行",
    "Could not find the launchd/ directory with templates.":
      "找不到包含模板的 launchd/ 目录。",
    "Could not find the compiled cloudmachine-agent binary.":
      "找不到已编译的 cloudmachine-agent 二进制文件。",
    "ABORTED: could not put cloudmachine-agent in a stable location\n(%@) - most often a lack of space or permissions.\nNOT installing agents pointing at %@: that path\ndisappears on the next `swift build` or `git clean`, and backups stop\nwithout any visible signal.":
      "已中止：无法将 cloudmachine-agent 放到固定位置\n（%@），最常见的原因是空间或权限不足。\n不会安装指向 %@ 的代理：该路径\n会在下次 `swift build` 或 `git clean` 时消失，备份将在\n没有任何可见提示的情况下停止。",
    "ABORTED: %@":
      "已中止：%@",
    "Could not list the templates in %@.":
      "无法列出 %@ 中的模板。",
    "could not read the template %@":
      "无法读取模板 %@",
    "could not write %@ (lack of space or permissions)":
      "无法写入 %@（空间或权限不足）",
    "launchctl load refused to load %@":
      "launchctl load 拒绝载入 %@",
    "NOT A SINGLE agent was loaded.":
      "没有载入任何一个代理。",
    "Only these went in: %@.":
      "只装入了这些：%@。",
    "Could not load any launchd agent.":
      "无法载入任何 launchd 代理。",
    "Installed agents: %@":
      "已安装的代理：%@",
    "                  WARNING: close to the limit - new bands will fail with EMFILE":
      "                  警告：已接近上限，新的分块将因 EMFILE 而失败",
    "%@/bands on Google Drive is not empty - it may hold another backup. NOT overwriting it; check it by hand.":
      "Google Drive 上的 %@/bands 不是空的，其中可能有另一份备份。不会覆盖它，请手动检查。",
    "Address:          %@":
      "地址：            %@",
    "Already prepared (%@ exists) - nothing to do.":
      "已经准备好（%@ 已存在），无需操作。",
    "Converts Time Machine's new, empty image in the machine to 32 MB bands and moves the bands to Google Drive.":
      "将虚拟机中 Time Machine 新建的空映像转换为 32 MB 分块，并将分块移到 Google Drive。",
    "Copy rclone.conf into the machine even if it already has one.":
      "即使虚拟机中已有 rclone.conf，也将其拷贝进去。",
    "Copying the converted image into the machine failed: %@":
      "将转换后的映像拷贝到虚拟机失败：%@",
    "Copying the image to the Mac failed: %@":
      "将映像拷贝到 Mac 失败：%@",
    "Could not ask Lima about the machine: %@":
      "无法向 Lima 询问虚拟机的情况：%@",
    "Could not carry the Time Machine files over: %@":
      "无法转移 Time Machine 文件：%@",
    "Could not check the image in the machine.":
      "无法检查虚拟机中的映像。",
    "Could not copy the rclone configuration into the machine.":
      "无法将 rclone 配置拷贝到虚拟机。",
    "Could not create %@ on Google Drive: %@":
      "无法在 Google Drive 上创建 %@：%@",
    "Could not create %@: %@":
      "无法创建 %@：%@",
    "Could not find the vm/ directory with the machine template.":
      "找不到包含虚拟机模板的 vm/ 目录。",
    "Could not read the image size.":
      "无法读取映像大小。",
    "Could not set the SMB password of user %@ in the machine.":
      "无法为虚拟机中的用户 %@ 设置 SMB 密码。",
    "Could not stop smbd in the machine.":
      "无法停止虚拟机中的 smbd。",
    "Could not write %@ in the machine.":
      "无法在虚拟机中写入 %@。",
    "Could not write the password file %@.":
      "无法写入密码文件 %@。",
    "Creates or starts the CloudMachine machine (Lima), gives it rclone's configuration and an SMB password, and prints the Time Machine command.":
      "创建或启动 CloudMachine 虚拟机（Lima），为它提供 rclone 配置和 SMB 密码，并输出 Time Machine 命令。",
    "Creating the machine %@ (first start downloads Ubuntu and installs packages - several minutes)...":
      "正在创建虚拟机 %@（首次启动会下载 Ubuntu 并安装软件包，需要几分钟）...",
    "Done: %@ has %@ MB bands on Google Drive; the original is kept in %@ in the machine. Start the backup: tmutil startbackup":
      "完成：%@ 在 Google Drive 上有 %@ MB 的分块；原始映像保存在虚拟机的 %@ 中。开始备份：tmutil startbackup",
    "exit code %@, no message":
      "退出代码 %@，没有消息",
    "Image metadata:   NEVER copied to %@ - check tm-meta-sync in the machine":
      "映像元数据：      从未拷贝到 %@，请检查虚拟机中的 tm-meta-sync",
    "Image metadata:   copied %@ ago to %@":
      "映像元数据：      已于 %@前拷贝到 %@",
    "Image metadata:   last copied %@ ago - OVERDUE (%@)":
      "映像元数据：      上次拷贝在 %@前，已逾期（%@）",
    "Image metadata:   not copied yet - waits for vm-prepare-bundle":
      "映像元数据：      尚未拷贝，等待 vm-prepare-bundle",
    "Backup %@, paused by the guard %@: %@":
      "备份 %@，守护程序暂停于 %@：%@",
    "Free in machine:  %@ GiB":
      "虚拟机可用空间：  %@ GiB",
    "fsck_apfs -n found problems: %@":
      "fsck_apfs -n 发现问题：%@",
    "Google Drive folder: %@":
      "Google Drive 文件夹：%@",
    "hdiutil attach of the converted image failed: %@":
      "hdiutil attach 挂载转换后的映像失败：%@",
    "hdiutil convert failed: %@":
      "hdiutil convert 失败：%@",
    "Image name in the machine (default: from the computer name).":
      "虚拟机中的映像名称（默认：根据电脑名称生成）。",
    "Installing the converted image FAILED: %@\nsmbd is left STOPPED so Time Machine does not open a half-installed image. The original is in %@ in the machine.":
      "安装转换后的映像失败：%@\nsmbd 保持停止状态，以免 Time Machine 打开只装了一半的映像。原始映像在虚拟机的 %@ 中。",
    "limactl create failed: %@":
      "limactl create 失败：%@",
    "limactl list failed: %@":
      "limactl list 失败：%@",
    "limactl not found - install Lima: brew install lima":
      "找不到 limactl，请安装 Lima：brew install lima",
    "limactl start failed: %@\nThe machine's own log: %@":
      "limactl start 失败：%@\n虚拟机自己的日志：%@",
    "Machine %@ is running.":
      "虚拟机 %@ 正在运行。",
    "Machine %@ was already running.":
      "虚拟机 %@ 已在运行。",
    "Machine:          %@ (%@)":
      "虚拟机：          %@（%@）",
    "Machine:          %@":
      "虚拟机：          %@",
    "Machine:          not created - run: cloudmachine-agent vm-setup":
      "虚拟机：          尚未创建，请运行：cloudmachine-agent vm-setup",
    "no answer within the time limit":
      "在时限内没有响应",
    "No image %@ in the machine.":
      "虚拟机中没有映像 %@。",
    "No image in the machine yet - point Time Machine at the share and let it create one first.":
      "虚拟机中还没有映像，请先让 Time Machine 指向该共享并创建一个。",
    "No rclone configuration at %@ - connect Google Drive first (configure-remote).":
      "在 %@ 没有 rclone 配置，请先连接 Google Drive（configure-remote）。",
    "no SMB destination":
      "没有 SMB 备份目标",
    "One check of the machine's upload buffer: pauses Time Machine when it fills, resumes what it paused.":
      "对虚拟机的上传缓冲区做一次检查：缓冲区填满时暂停 Time Machine，并恢复它曾暂停的备份。",
    "Packing the converted image failed: %@":
      "打包转换后的映像失败：%@",
    "Packing the image failed: %@":
      "打包映像失败：%@",
    "No answer from the machine (rclone rc) - the guard would do nothing.":
      "虚拟机（rclone rc）没有响应，守护程序将不会采取任何操作。",
    "Only print what the guard would decide - for trying thresholds on a throwaway machine.":
      "只输出守护程序会做出的决定，用于在临时虚拟机上试验阈值。",
    "Pause above this many GiB in the buffer.":
      "缓冲区超过这么多 GiB 时暂停。",
    "Pause when the machine has less free than this, in GiB.":
      "虚拟机的可用空间少于这么多 GiB 时暂停。",
    "Point Time Machine at the machine (once, needs an administrator password):":
      "让 Time Machine 指向虚拟机（只需一次，需要管理员密码）：",
    "punchfs files:    %@ open, limit %@":
      "punchfs 文件：    已打开 %@ 个，上限 %@",
    "rclone configuration already in the machine - kept (--replace-rclone-config replaces it).":
      "虚拟机中已有 rclone 配置，予以保留（--replace-rclone-config 可替换它）。",
    "rclone configuration copied into the machine.":
      "rclone 配置已拷贝到虚拟机。",
    "rclone-tm or punchfs is not running in the machine - see cloudmachine-agent vm-status.":
      "虚拟机中的 rclone-tm 或 punchfs 未运行，请参见 cloudmachine-agent vm-status。",
    "Resume below this many GiB (only a backup the guard paused).":
      "低于这么多 GiB 时恢复（仅限守护程序暂停的备份）。",
    "Service %@: %@":
      "服务 %@：%@",
    "Several images in the machine (%@) - choose one with --bundle.":
      "虚拟机中有多个映像（%@），请用 --bundle 选择一个。",
    "Shows the machine: address, services, upload buffer, free space and the Time Machine destination.":
      "显示虚拟机的情况：地址、服务、上传缓冲区、可用空间和 Time Machine 备份目标。",
    "SMB password stored in %@ (mode 600).":
      "SMB 密码已存储在 %@（权限 600）。",
    "The converted image does not have %@-byte bands.":
      "转换后的映像的分块不是 %@ 字节。",
    "The converted image has no APFS partition.":
      "转换后的映像没有 APFS 分区。",
    "The image already takes %@ MB - this command converts only a new, empty image (under %@ MB).":
      "映像已占用 %@ MB，此命令只转换新建的空映像（小于 %@ MB）。",
    "The image is encrypted - converting encrypted images is not supported.":
      "映像已加密，不支持转换加密的映像。",
    "The image was not changed; smbd started again.":
      "映像未被更改，smbd 已重新启动。",
    "The machine does not answer - is it running? cloudmachine-agent vm-status":
      "虚拟机没有响应，它在运行吗？cloudmachine-agent vm-status",
    "The machine has no address on the vzNAT network.":
      "虚拟机在 vzNAT 网络上没有地址。",
    "The services in the machine did not start - check: cloudmachine-agent vm-status":
      "虚拟机中的服务没有启动，请检查：cloudmachine-agent vm-status",
    "Time Machine is backing up - stop it first: tmutil stopbackup":
      "Time Machine 正在备份，请先停止：tmutil stopbackup",
    "Time Machine:     %@":
      "Time Machine：   %@",
    "Time Machine:     NOT pointing at the machine (%@)":
      "Time Machine：   未指向虚拟机（%@）",
    "Time Machine:     tmutil did not answer":
      "Time Machine：   tmutil 没有响应",
    "tmutil did not answer - not touching the image while its state is unknown.":
      "tmutil 没有响应，在映像状态未知时不会改动映像。",
    "unknown":
      "未知",
    "Unpacking the image failed: %@":
      "解包映像失败：%@",
    "Still to upload:  %@ GiB in %@ bands, uploading %@ (cache on disk %@ GiB)":
      "仍待上传：        %@ GiB，共 %@ 个分块，正在上传 %@（磁盘缓存 %@ GiB）",
    "Excluded %@ (the machine and its upload buffer) from Time Machine.":
      "已将 %@（虚拟机及其上传缓冲区）从 Time Machine 中排除。",
    "WARNING: could not exclude %@ from Time Machine - run: tmutil addexclusion %@":
      "警告：无法将 %@ 从 Time Machine 中排除，请运行：tmutil addexclusion %@",
    "Upload buffer:    no answer from rclone (rc %@)":
      "上传缓冲区：      rclone 没有响应（rc %@）",
    "When Time Machine has created its empty image, stop the backup (tmutil stopbackup) and run: cloudmachine-agent vm-prepare-bundle":
      "Time Machine 创建好空映像后，请停止备份（tmutil stopbackup）并运行：cloudmachine-agent vm-prepare-bundle",
    "Unsent %@ GiB, free %@ GiB (pause above %@ GiB unsent or below %@ GiB free, resume below %@ GiB).":
      "未发送 %@ GiB，可用 %@ GiB（未发送超过 %@ GiB 或可用低于 %@ GiB 时暂停，低于 %@ GiB 时恢复）。",
    "Upload:           Google's daily limit refused an upload %@ ago - rclone retries every 5 min and resumes by itself":
      "上传：            Google 的每日上限在 %@前拒绝了一次上传，rclone 每 5 分钟重试一次，并会自动继续",
    "no":
      "否",
    "running":
      "运行中",
    "stopped":
      "已停止",
    "yes":
      "是",
    "%@\nThe previous template is in %@ - copy it back over lima.yaml and run limactl start %@.":
      "%@\n之前的模板在 %@，请将它拷贝回 lima.yaml，然后运行 limactl start %@。",
    "Could not read this app's machine template (limactl template copy).":
      "无法读取此 App 的虚拟机模板（limactl template copy）。",
    "Could not replace %@: %@":
      "无法替换 %@：%@",
    "Machine %@ already runs this app's template.":
      "虚拟机 %@ 已在使用此 App 的模板。",
    "Machine %@ now runs this app's template; the previous one is in %@.":
      "虚拟机 %@ 现在使用此 App 的模板；之前的模板在 %@。",
    "Moves the machine onto this app's template (two restarts, never during a backup).":
      "将虚拟机切换到此 App 的模板（会重启两次，绝不会在备份期间进行）。",
    "No machine %@ - create it with: cloudmachine-agent vm-setup":
      "没有虚拟机 %@，请用以下命令创建：cloudmachine-agent vm-setup",
    "Template:         OLDER than this app's - run: cloudmachine-agent vm-update":
      "模板：            比此 App 的旧，请运行：cloudmachine-agent vm-update",
    "Template:         not compared":
      "模板：            未比较",
    "Template:         this app's":
      "模板：            与此 App 一致",
    "The machine has no %@ - run cloudmachine-agent vm-setup first.":
      "虚拟机中没有 %@，请先运行 cloudmachine-agent vm-setup。",
    "The machine restarted, but not every service is running - check: cloudmachine-agent vm-status. The previous template is in %@.":
      "虚拟机已重启，但并非所有服务都在运行，请检查：cloudmachine-agent vm-status。之前的模板在 %@。",
    "The template changes the machine itself (%@) - that needs a new machine, not an update.":
      "该模板会更改虚拟机本身（%@），这需要新建虚拟机，而不是更新。",
    "The upload to Google Drive hangs":
      "上传到 Google Drive 卡住了",
    "Time Machine is backing up - try again when it has finished.":
      "Time Machine 正在备份，请在它完成后再试。",
    "Upload:           HANGS - bands in progress, none uploaded for %@ (network?); see /var/log/rclone-tm.log in the machine":
      "上传：            卡住，有分块正在处理，已有 %@ 没有任何分块上传完成（网络问题？）；请查看虚拟机中的 /var/log/rclone-tm.log",
    "limactl stop failed - nothing was changed.":
      "limactl stop 失败，没有做任何更改。",
    "rclone has bands in progress, but none has been uploaded for %@ - usually a broken network connection, which rclone does not report as an error. Backups since then are only in the machine's buffer. When the network comes back the upload resumes by itself (on 28.10.2026 within 80 s); if it does not, restarting the machine (prepare-shutdown, limactl start) drops the dead connections.":
      "rclone 有分块正在处理，但已有 %@ 没有任何分块上传完成，这通常是网络连接中断造成的，rclone 不会把它报告为错误。此后的备份只存在于虚拟机的缓冲区中。网络恢复后，上传会自动继续（2026 年 10 月 28 日那次在 80 秒内恢复）；如果没有恢复，请重启虚拟机（prepare-shutdown，limactl start）以丢弃失效的连接。",
    "tmutil did not answer - not restarting the machine while its state is unknown.":
      "tmutil 没有响应，在状态未知时不会重启虚拟机。",
  ]
}
