// Korean translations, keyed by the English text passed to `L10n.tr`.
extension L10nTranslations {
  static let ko: [String: String] = [
    "Space limit:      %@":
      "공간 한도:        %@",
    "                  Time Machine quota not set to match - run: %@":
      "                  Time Machine 할당량이 일치하지 않음 - 다음을 실행하세요: %@",
    "Sets how much of Google Drive this Mac may use, and prints the Time Machine quota command.":
      "이 Mac이 사용할 수 있는 Google Drive 공간을 설정하고, Time Machine 할당량을 설정하는 명령어를 출력합니다.",
    "Limit in GB.":
      "한도(GB 단위).",
    "Limit for this Mac: %@ GB.":
      "이 Mac의 한도: %@ GB.",
    "Now set the Time Machine quota (needs an administrator password):":
      "이제 Time Machine 할당량을 설정하세요(관리자 암호 필요):",
    "CloudMachine - verification, Google Drive setup and installation. Called by launchd on a schedule, or by hand from Terminal.":
      "CloudMachine - 검증, Google Drive 설정 및 설치. launchd가 일정에 따라 호출하거나 터미널에서 직접 실행합니다.",
    "Connects to Google Drive through rclone (OAuth in the browser) and creates this machine's folder.":
      "rclone(브라우저에서 OAuth)을 통해 Google Drive에 연결하고 이 머신의 폴더를 만듭니다.",
    "Overwrite the existing remote. RISKY: replaces the token and permissions.":
      "기존 remote를 덮어씁니다. 위험: 토큰과 권한이 교체됩니다.",
    "Packs build/CloudMachine.app into build/CloudMachine-<version>.dmg.":
      "build/CloudMachine.app을 build/CloudMachine-<버전>.dmg로 패키징합니다.",
    "ERROR: %@ is missing - run 'cloudmachine-agent build-app' first":
      "오류: %@이(가) 없습니다 - 먼저 'cloudmachine-agent build-app'을 실행하세요",
    "==> Preparing the staging folder":
      "==> 스테이징 폴더를 준비하는 중",
    "==> Creating %@":
      "==> %@ 생성 중",
    "ERROR: hdiutil exited with code %@.":
      "오류: hdiutil이 코드 %@(으)로 종료되었습니다.",
    "==> Done: %@":
      "==> 완료: %@",
    "On first launch (the app is not signed with an Apple Developer account):":
      "처음 실행할 때(이 앱은 Apple Developer 계정으로 서명되지 않았습니다):",
    "1. Open %@ and drag CloudMachine.app to Applications.":
      "1. %@을(를) 열고 CloudMachine.app을 응용 프로그램 폴더로 드래그합니다.",
    "2. In Finder, RIGHT-click CloudMachine.app -> Open -> Open\n   (a plain double-click shows the Gatekeeper block \"unidentified developer\").":
      "2. Finder에서 CloudMachine.app을 마우스 오른쪽 버튼으로 클릭 -> 열기 -> 열기\n   (그냥 더블 클릭하면 Gatekeeper가 \"확인되지 않은 개발자\"라며 차단합니다).",
    "3. Later launches work normally, with a double-click.":
      "3. 이후에는 더블 클릭으로 평소처럼 실행됩니다.",
    "Builds CloudMachine.app (Release) - GUI + cloudmachine-agent in Contents/MacOS/, plus launchd/, vm/ and config/ as Resources.":
      "CloudMachine.app(Release)을 빌드합니다 - GUI와 cloudmachine-agent는 Contents/MacOS/에, launchd/, vm/, config/는 Resources로 포함됩니다.",
    "Binaries for Apple Silicon and Intel at once (how CI builds a release; unnecessary locally).":
      "Apple Silicon과 Intel용 바이너리를 한 번에 만듭니다(CI가 릴리스를 빌드하는 방식이며, 로컬에서는 필요하지 않음).",
    "==> Building CloudMachineApp + cloudmachine-agent (release) - version %@ (%@)":
      "==> CloudMachineApp + cloudmachine-agent 빌드 중(release) - 버전 %1$@ (%2$@)",
    "ERROR: swift build exited with code %@.":
      "오류: swift build가 코드 %@(으)로 종료되었습니다.",
    "ERROR: swift build --show-bin-path did not report the binaries directory.":
      "오류: swift build --show-bin-path가 바이너리 디렉터리를 알려 주지 않았습니다.",
    "ERROR: no built binary found at %@":
      "오류: %@에서 빌드된 바이너리를 찾을 수 없습니다",
    "==> Assembling the .app bundle in %@":
      "==> %@에 .app 번들을 구성하는 중",
    "==> WARNING: you are building from a DIRTY tree - the version will not point to a commit.":
      "==> 경고: 커밋되지 않은 변경 사항이 있는 상태에서 빌드하고 있습니다 - 버전이 특정 커밋을 가리키지 않습니다.",
    "ERROR: Resources/AppIcon.icns is missing - generate it: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns":
      "오류: Resources/AppIcon.icns가 없습니다 - 다음으로 생성하세요: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns",
    "==> Signing with the local certificate '%@' (Full Disk Access will survive later rebuilds)":
      "==> 로컬 인증서 '%@'(으)로 서명하는 중(이후 다시 빌드해도 전체 디스크 접근 권한이 유지됩니다)",
    "==> Signing ad-hoc (no Apple Developer account) - run 'cloudmachine-agent setup-signing-cert' once so that TCC permissions survive later rebuilds":
      "==> 임시(ad-hoc) 서명 중(Apple Developer 계정 없음) - 이후 다시 빌드해도 TCC 권한이 유지되도록 'cloudmachine-agent setup-signing-cert'를 한 번 실행하세요",
    "ERROR: codesign exited with code %@.":
      "오류: codesign이 코드 %@(으)로 종료되었습니다.",
    "Next step: %@":
      "다음 단계: %@",
    "Creates a local self-signed certificate so that Full Disk Access survives later rebuilds of the app.":
      "이후 앱을 다시 빌드해도 전체 디스크 접근 권한이 유지되도록 로컬 자체 서명 인증서를 만듭니다.",
    "Certificate '%@' already exists in %@, nothing to do.":
      "인증서 '%1$@'은(는) 이미 %2$@에 있으므로 할 일이 없습니다.",
    "==> Generating the key and self-signed certificate '%@'...":
      "==> 키와 자체 서명 인증서 '%@' 생성 중...",
    "ERROR: openssl req exited with code %@.":
      "오류: openssl req가 코드 %@(으)로 종료되었습니다.",
    "ERROR: openssl pkcs12 exited with code %@.":
      "오류: openssl pkcs12가 코드 %@(으)로 종료되었습니다.",
    "==> Importing the certificate into %@ (pre-authorizing /usr/bin/codesign, so it does not ask for the keychain password every time)...":
      "==> 인증서를 %@에 가져오는 중(/usr/bin/codesign을 미리 승인하므로 매번 키체인 암호를 묻지 않습니다)...",
    "ERROR: security import exited with code %@.":
      "오류: security import가 코드 %@(으)로 종료되었습니다.",
    "==> Trusting the certificate ONLY for code signing...":
      "==> 코드 서명 용도로만 인증서를 신뢰하도록 설정하는 중...",
    "ERROR: security add-trusted-cert exited with code %@.":
      "오류: security add-trusted-cert가 코드 %@(으)로 종료되었습니다.",
    "Done. Certificate '%@' is now available to codesign.":
      "완료. 인증서 '%@'을(를) 이제 codesign에서 사용할 수 있습니다.",
    "The next 'cloudmachine-agent build-app' will use it automatically instead of an ad-hoc signature.":
      "다음 'cloudmachine-agent build-app'은 임시 서명 대신 이 인증서를 자동으로 사용합니다.",
    "After THAT ONE rebuild, grant Full Disk Access one last time - later\nrebuilds will no longer reset it, as long as you sign with the same certificate.":
      "그 한 번의 재빌드 후 전체 디스크 접근 권한을 마지막으로 한 번 더 허용하세요 - 이후에는\n같은 인증서로 서명하는 한 재빌드해도 권한이 초기화되지 않습니다.",
    "Checks whether the hourly cycle STILL works (date of the last SUCCESSFUL backup) and reports failures.":
      "1시간 주기가 여전히 작동하는지(마지막으로 성공한 백업 날짜) 확인하고 실패를 알립니다.",
    "After this many hours without a successful backup we consider the cycle broken.":
      "성공한 백업 없이 이 시간이 지나면 주기가 중단된 것으로 간주합니다.",
    "Only print the state, without a system notification.":
      "시스템 알림 없이 상태만 출력합니다.",
    "A different Time Machine preferences file - to test the watchdog on a known sample.":
      "다른 Time Machine 환경설정 파일 - 알려진 샘플로 감시 기능을 시험하기 위한 것입니다.",
    "Last successful backup: %@":
      "마지막으로 성공한 백업: %@",
    "Last successful backup: NONE":
      "마지막으로 성공한 백업: 없음",
    "Last attempt:           %@":
      "마지막 시도:             %@",
    "WAITING (system startup): %@":
      "대기 중(시스템 시작): %@",
    "Backup cycle: OK":
      "백업 주기: 정상",
    "FAILURE: %@":
      "실패: %@",
    "         %@":
      "         %@",
    "Check the state:  %@":
      "상태 확인:  %@",
    "Preparing for restart":
      "재시동 준비 중",
    "Prepare for restart":
      "재시동 준비",
    "Prepare":
      "준비",
    "==> WARNING: git rev-list failed (%@) - using the date as the build number.":
      "==> 경고: git rev-list가 실패했습니다(%@) - 빌드 번호 대신 날짜를 사용합니다.",
    "Agents:           %@":
      "에이전트:         %@",
    "CANNOT START: %@ - open CloudMachine or run backup-health to reload them":
      "시작할 수 없음: %@ - CloudMachine을 열거나 backup-health를 실행하여 다시 불러오세요",
    "Reloaded agents that could not start: %@":
      "시작하지 못한 에이전트를 다시 불러왔습니다: %@",
    "Drive folder:     %@":
      "Drive 폴더:       %@",
    "Name of this Mac's folder on Google Drive (default: derived from the computer name). Set once; it cannot be changed later.":
      "Google Drive에 있는 이 Mac의 폴더 이름입니다(기본값: 컴퓨터 이름에서 가져옴). 한 번만 설정할 수 있으며 나중에 변경할 수 없습니다.",
    "Backup watchdog:  %@":
      "백업 감시:        %@",
    "Prints the version, the build number and the commit this binary was built from.":
      "버전, 빌드 번호, 이 바이너리를 빌드한 커밋을 출력합니다.",
    "Only one line, without a description.":
      "설명 없이 한 줄만 출력합니다.",
    "Build from the working tree (outside a bundle) - no version data.":
      "작업 트리에서 빌드됨(번들 외부) - 버전 정보 없음.",
    "Version: %@":
      "버전:   %@",
    "Build:   %@":
      "빌드:   %@",
    "Commit:  %@":
      "커밋:   %@",
    "WARNING: built from a DIRTY tree - the binary contains code that\n         is in no commit. The commit number does NOT describe\n         what actually runs.":
      "경고: 커밋되지 않은 변경 사항이 있는 상태에서 빌드됨 - 이 바이너리에는\n      어떤 커밋에도 없는 코드가 들어 있습니다. 커밋 번호는\n      실제로 실행되는 내용을 설명하지 않습니다.",
    "Saving the space limit":
      "공간 한도를 저장하는 중",
    "Measuring usage on Google Drive":
      "Google Drive 사용량을 측정하는 중",
    "Google Drive did not answer - try again later.":
      "Google Drive가 응답하지 않았습니다 - 나중에 다시 시도하세요.",
    "Measured.":
      "측정했습니다.",
    "Space limit for this Mac":
      "이 Mac의 공간 한도",
    "Used on Google Drive":
      "Google Drive에서 사용 중",
    "Measured %@. The watchdog measures again every few hours.":
      "%@에 측정함. 감시 기능이 몇 시간마다 다시 측정합니다.",
    "Limit (GB)":
      "한도 (GB)",
    "Save":
      "저장",
    "Measure now":
      "지금 측정",
    "Time Machine quota: %@ GB (70%% of the limit - the copy on Drive is about a third larger than the backup inside it). Time Machine deletes the oldest backups to stay within it.":
      "Time Machine 할당량: %@ GB(한도의 70%% - Drive의 복사본은 그 안의 백업보다 약 3분의 1 큽니다). Time Machine은 이 범위를 지키기 위해 가장 오래된 백업을 삭제합니다.",
    "Set the Time Machine quota: run this in Terminal (needs sudo)":
      "Time Machine 할당량 설정: 터미널에서 다음을 실행하세요(sudo 필요)",
    "Connect Google Drive: run this in Terminal and approve in the browser":
      "Google Drive 연결: 터미널에서 다음을 실행하고 브라우저에서 승인하세요",
    "Grant Full Disk Access to CloudMachine, so it can tell whether backups complete":
      "백업이 완료되는지 확인할 수 있도록 CloudMachine에 전체 디스크 접근 권한을 허용하세요",
    "Folder on Google Drive":
      "Google Drive 폴더",
    "One folder per Mac. Set once - it cannot be changed after connecting.":
      "Mac마다 폴더 하나를 사용합니다. 한 번만 설정할 수 있으며 연결 후에는 변경할 수 없습니다.",
    "Use lowercase letters, digits and dashes.":
      "소문자, 숫자, 하이픈을 사용하세요.",
    "Install rclone":
      "rclone 설치",
    "Open System Settings":
      "시스템 설정 열기",
    "Install agents":
      "에이전트 설치",
    "not checked":
      "확인되지 않음",
    "none at all":
      "전혀 없음",
    "%@ ago":
      "%@ 전",
    "Missing: %@":
      "누락: %@",
    "Google Drive not connected":
      "Google Drive에 연결되지 않음",
    "Time Machine does not point to CloudMachine":
      "Time Machine이 CloudMachine을 가리키지 않음",
    "UNKNOWN whether Time Machine points to CloudMachine - tmutil did not answer":
      "Time Machine이 CloudMachine을 가리키는지 알 수 없음 - tmutil이 응답하지 않았습니다",
    "Backup in progress":
      "백업 진행 중",
    "Unknown when the last backup was made":
      "마지막 백업 시점을 알 수 없음",
    "There is no completed backup at all":
      "완료된 백업이 전혀 없음",
    "No completed backup for %@":
      "%@ 동안 완료된 백업이 없음",
    "Ready":
      "준비됨",
    "Not saved: %@":
      "저장되지 않음: %@",
    "Installing rclone":
      "rclone 설치 중",
    "Installing launchd agents":
      "launchd 에이전트 설치 중",
    "Starting backup":
      "백업을 시작하는 중",
    "Backup started.":
      "백업을 시작했습니다.",
    "Could not start the backup.":
      "백업을 시작할 수 없습니다.",
    "Stopping backup":
      "백업을 중지하는 중",
    "Backup stopped.":
      "백업을 중지했습니다.",
    "Could not stop the backup.":
      "백업을 중지할 수 없습니다.",
    "Could not prepare the AppleScript.":
      "AppleScript를 준비할 수 없습니다.",
    "Unknown authorization error.":
      "알 수 없는 인증 오류입니다.",
    "Waiting to upload":
      "업로드 대기 중",
    "%@ files":
      "파일 %@개",
    "nothing":
      "없음",
    "Back up now":
      "지금 백업",
    "Stop backup":
      "백업 중지",
    "Open CloudMachine":
      "CloudMachine 열기",
    "Quit":
      "종료",
    "Healthy":
      "정상",
    "Attention":
      "주의",
    "Refreshed %@":
      "%@에 새로 고침됨",
    "System Status":
      "시스템 상태",
    "Action needed":
      "조치 필요",
    "not measured":
      "측정되지 않음",
    "rclone did not answer":
      "rclone이 응답하지 않았습니다",
    "Backup in Progress":
      "백업 진행 중",
    "Files processed":
      "처리된 파일",
    "Write speed":
      "쓰기 속도",
    "Operation phase":
      "작업 단계",
    "Required Setup Steps":
      "필수 설정 단계",
    "Copy":
      "복사",
    "Last completed backup":
      "마지막으로 완료된 백업",
    "Last backup watchdog run":
      "마지막 백업 감시 실행",
    "not read":
      "읽지 않음",
    "Everything uploaded":
      "모두 업로드됨",
    "File upload errors":
      "파일 업로드 오류",
    "Google Drive Credentials (OAuth 2.0)":
      "Google Drive 자격 증명(OAuth 2.0)",
    "Keychain OK":
      "키체인 정상",
    "No custom keys":
      "사용자 지정 키 없음",
    "Paste client_id...":
      "client_id 붙여넣기...",
    "Paste client_secret...":
      "client_secret 붙여넣기...",
    "Save securely in the Keychain":
      "키체인에 안전하게 저장",
    "Refresh":
      "새로 고침",
    "Overview":
      "개요",
    "Backups":
      "백업",
    "Storage":
      "저장 공간",
    "Settings":
      "설정",
    "Current status: %@":
      "현재 상태: %@",
    "Does not point to CloudMachine":
      "CloudMachine을 가리키지 않음",
    "tmutil did not answer":
      "tmutil이 응답하지 않았습니다",
    "Backing up: %@ of %@":
      "백업 중: %2$@ 중 %1$@",
    "%@ of %@":
      "%2$@ 중 %1$@",
    "Copied":
      "복사됨",
    "No backup is running":
      "실행 중인 백업이 없음",
    "Time Machine starts the next one on its own schedule.":
      "Time Machine은 자체 일정에 따라 다음 백업을 시작합니다.",
    "Backup cycle":
      "백업 주기",
    "%@ GiB":
      "%@ GiB",
    "%@ GiB in %@ bands, %@ uploading":
      "%2$@개 밴드에 %1$@ GiB, %3$@ 업로드 중",
    "%@ bands":
      "밴드 %@개",
    "%@ fragments abandoned - only in the machine":
      "조각 %@개 포기됨 - 머신에만 있음",
    "127.0.0.1:5572 answers on the Mac: Lima forwards the machine's rclone remote control, which has no password. Any web page open in a browser can send it commands - including deleting the backup on Google Drive. Add the portForwards rule from vm/cmsmb.yaml to the machine and restart it (see vm/README.md).":
      "127.0.0.1:5572가 Mac에서 응답하고 있습니다. Lima가 암호가 없는 머신의 rclone 원격 제어를 전달하고 있습니다. 브라우저에 열려 있는 모든 웹 페이지가 여기에 명령을 보낼 수 있으며, Google Drive의 백업을 삭제하는 것도 가능합니다. vm/cmsmb.yaml의 portForwards 규칙을 머신에 추가하고 머신을 다시 시작하세요(vm/README.md 참조).",
    "A service in the CloudMachine machine is not running":
      "CloudMachine 머신의 서비스가 실행되고 있지 않습니다",
    "Address":
      "주소",
    "Agent installation INCOMPLETE - %@ of %@ did not go in:\n%@\n%@\nEvery missing agent is a function that has silently stopped working (vm-guard watches the machine's buffer, backup-health reports failures). Fix the cause and repeat the installation.":
      "에이전트 설치가 불완전합니다 - %2$@개 중 %1$@개가 설치되지 않았습니다:\n%3$@\n%4$@\n누락된 에이전트는 조용히 작동을 멈춘 기능입니다(vm-guard는 머신의 버퍼를 감시하고, backup-health는 실패를 알립니다). 원인을 해결한 뒤 설치를 다시 실행하세요.",
    "All running":
      "모두 실행 중",
    "Also install the launchd agents (same as install-launchd).":
      "launchd 에이전트도 설치합니다(install-launchd와 동일).",
    "At most this many minutes of waiting for the upload.":
      "업로드를 기다리는 최대 시간(분).",
    "At the limit every new band fails with EMFILE and the backup stops. Check: cloudmachine-agent vm-status":
      "한도에 도달하면 모든 새 밴드가 EMFILE로 실패하고 백업이 중단됩니다. 확인: cloudmachine-agent vm-status",
    "Cache on the machine's disk":
      "머신 디스크의 캐시",
    "Connected to Google Drive, but could not create the folder '%@' - without it the machine has nowhere to keep the backup. Check the account permissions and try again.":
      "Google Drive에는 연결되었지만 폴더 '%@'을(를) 만들 수 없었습니다 - 폴더가 없으면 머신이 백업을 보관할 곳이 없습니다. 계정 권한을 확인하고 다시 시도하세요.",
    "Convert the image":
      "이미지 변환",
    "Converting the image to 32 MB bands":
      "이미지를 32 MB 밴드로 변환하는 중",
    "Could not check with the current connection whether the backup is on Google Drive (%@), so remote '%@' was NOT replaced: without that answer the new sign-in cannot be checked against it.":
      "현재 연결로는 백업이 Google Drive에 있는지 확인할 수 없어(%1$@) remote '%2$@'은(는) 교체되지 않았습니다. 그 답이 없으면 새 로그인을 기존 백업과 대조할 수 없습니다.",
    "Downloads the official rclone binary into ~/.cloudmachine/bin (Google sign-in and the machine's rclone.conf).":
      "공식 rclone 바이너리를 ~/.cloudmachine/bin에 다운로드합니다(Google 로그인과 머신의 rclone.conf용).",
    "Free in the machine":
      "머신의 여유 공간",
    "Free in the machine: %@":
      "머신의 여유 공간: %@",
    "Generates and installs the launchd agents (app, backup watchdog, machine start, machine guard).":
      "launchd 에이전트(앱, 백업 감시, 머신 시작, 머신 가드)를 생성하고 설치합니다.",
    "Install Lima, which runs the CloudMachine machine: run this in Terminal":
      "CloudMachine 머신을 실행하는 Lima 설치: 터미널에서 다음을 실행하세요",
    "Install rclone (signs in to Google Drive for the machine)":
      "rclone 설치(머신을 위해 Google Drive에 로그인합니다)",
    "Install the background agents (machine start, buffer guard, backup watchdog)":
      "백그라운드 에이전트 설치(머신 시작, 버퍼 가드, 백업 감시)",
    "Installs rclone through Homebrew - CloudMachine itself uses the one from install-rclone.":
      "Homebrew로 rclone을 설치합니다 - CloudMachine 자체는 install-rclone으로 설치한 것을 사용합니다.",
    "Info.plist, token and mapped/ of the backup image exist only on the machine's disk; without them the bands in %@ cannot be restored. The copy (tm-meta-sync, every 15 min) goes to %@. Check: cloudmachine-agent vm-status, then in the machine: journalctl -u tm-meta-sync":
      "백업 이미지의 Info.plist, 토큰, mapped/는 머신의 디스크에만 있으며, 이것이 없으면 %1$@의 밴드를 복원할 수 없습니다. 복사본(tm-meta-sync, 15분마다)은 %2$@에 저장됩니다. 확인: cloudmachine-agent vm-status, 이어서 머신에서: journalctl -u tm-meta-sync",
    "Lima says the machine is running, but a command in it did not return. Without it nothing is known about Samba, rclone or the upload. Check: cloudmachine-agent vm-status":
      "Lima는 머신이 실행 중이라고 알리지만, 머신 안의 명령이 돌아오지 않았습니다. 이 명령이 없으면 Samba, rclone, 업로드에 대해 아무것도 알 수 없습니다. 확인: cloudmachine-agent vm-status",
    "Machine":
      "머신",
    "Machine %@":
      "머신 %@",
    "Machine & Upload Status":
      "머신 및 업로드 상태",
    "Machine buffer":
      "머신 버퍼",
    "No Time Machine destination is the machine's share (smb://tm@<address>/CloudMachine) - backups are not being made there. The command is printed by: cloudmachine-agent vm-setup":
      "Time Machine 대상 중 머신의 공유(smb://tm@<주소>/CloudMachine)가 없습니다 - 그곳에는 백업이 만들어지지 않습니다. 명령어는 다음으로 출력됩니다: cloudmachine-agent vm-setup",
    "Not running: %@":
      "실행되지 않음: %@",
    "Not set up":
      "설정되지 않음",
    "Once it runs out, rclone stops uploading, the machine's buffer fills up and backups stop being made. At a growth of ~600 MB per hourly cycle that is about %@ days.":
      "모두 소진되면 rclone이 업로드를 멈추고, 머신의 버퍼가 가득 차며, 백업이 만들어지지 않습니다. 1시간 주기마다 약 600 MB씩 늘어나는 경우 약 %@일 후입니다.",
    "Or rclone.conf is missing: this Mac has already set up the CloudMachine machine, so it is not connected anew blindly. Restore the file from a backup (the machine keeps its own copy in %@). To connect anyway, create an empty file at the path `%@ config file` prints and run again - the existing folder is kept.":
      "또는 rclone.conf가 없습니다. 이 Mac은 이미 CloudMachine 머신을 설정했으므로 무작정 새로 연결하지 않습니다. 백업에서 파일을 복원하세요(머신은 %@에 자체 복사본을 보관합니다). 그래도 연결하려면 `%@ config file`이 출력하는 경로에 빈 파일을 만들고 다시 실행하세요 - 기존 폴더는 유지됩니다.",
    "Point Time Machine at the machine: run this in Terminal (needs sudo; Copy includes the password)":
      "Time Machine이 머신을 가리키도록 설정: 터미널에서 다음을 실행하세요(sudo 필요, 복사에는 암호가 포함됨)",
    "Points to the machine":
      "머신을 가리킴",
    "Prepares for a restart: stops the backup, waits a while for the upload, then stops the machine cleanly.":
      "재시동을 준비합니다. 백업을 중지하고, 업로드를 잠시 기다린 다음, 머신을 안전하게 종료합니다.",
    "Reading the Time Machine destination did not return within %@ s. That is how tmutil behaves when its destination hangs.":
      "Time Machine 대상 읽기가 %@초 안에 돌아오지 않았습니다. 대상이 멈추면 tmutil이 이렇게 동작합니다.",
    "Remote '%@' was NOT replaced. The new sign-in gets the 'drive.file' scope, which sees only files created under its own client_id. The existing backup was most likely created by the current connection and would become invisible to it. Before anything is written, the new token is checked against the existing backup, and the replacement is abandoned if it cannot see it. The machine keeps its own copy of the configuration until vm-setup --replace-rclone-config. To go ahead, run again with --replace-existing --accept-scope-change.":
      "remote '%@'은(는) 교체되지 않았습니다. 새 로그인은 'drive.file' 범위를 받으며, 이 범위는 자체 client_id로 만든 파일만 볼 수 있습니다. 기존 백업은 현재 연결로 만들어졌을 가능성이 높아 새 연결에서는 보이지 않게 됩니다. 무엇이든 쓰기 전에 새 토큰을 기존 백업과 대조하며, 볼 수 없으면 교체를 중단합니다. 머신은 vm-setup --replace-rclone-config를 실행할 때까지 자체 구성 복사본을 유지합니다. 그래도 진행하려면 --replace-existing --accept-scope-change를 붙여 다시 실행하세요.",
    "Remote control:   OPEN on the Mac at 127.0.0.1:5572 - any web page can send rclone commands; see vm/README.md (portForwards)":
      "원격 제어:        Mac의 127.0.0.1:5572에 열려 있음 - 모든 웹 페이지가 rclone 명령을 보낼 수 있습니다. vm/README.md(portForwards) 참조",
    "Running":
      "실행 중",
    "Samba, rclone or punchfs in the machine is not active, so Time Machine has nowhere to write or the bands do not reach Google Drive. Check: cloudmachine-agent vm-status":
      "머신의 Samba, rclone 또는 punchfs가 활성 상태가 아니므로 Time Machine이 쓸 곳이 없거나 밴드가 Google Drive에 도달하지 않습니다. 확인: cloudmachine-agent vm-status",
    "Service %@":
      "서비스 %@",
    "Services":
      "서비스",
    "Set up the CloudMachine machine (the first time it downloads Ubuntu - several minutes)":
      "CloudMachine 머신 설정(처음에는 Ubuntu를 다운로드하므로 몇 분 걸립니다)",
    "Set up the CloudMachine machine again, so it prints the Time Machine command":
      "CloudMachine 머신을 다시 설정하여 Time Machine 명령어를 출력",
    "Set up the machine":
      "머신 설정",
    "Setting up the CloudMachine machine":
      "CloudMachine 머신을 설정하는 중",
    "Start the CloudMachine machine":
      "CloudMachine 머신 시작",
    "Start the machine":
      "머신 시작",
    "Starting the CloudMachine machine":
      "CloudMachine 머신을 시작하는 중",
    "Still to upload: %@ GiB":
      "업로드 대기: %@ GiB",
    "Stopping the Time Machine backup...":
      "Time Machine 백업을 중지하는 중...",
    "Stopping the machine %@...":
      "머신 %@을(를) 중지하는 중...",
    "The CloudMachine machine does not answer":
      "CloudMachine 머신이 응답하지 않습니다",
    "The CloudMachine machine is not running":
      "CloudMachine 머신이 실행되고 있지 않습니다",
    "The CloudMachine machine is not set up yet":
      "CloudMachine 머신이 아직 설정되지 않았습니다",
    "The CloudMachine machine is stopped":
      "CloudMachine 머신이 중지되었습니다",
    "The backup is stopped, the upload gets up to 30 minutes, then the machine shuts down cleanly. It starts again at the next login.":
      "백업을 중지하고, 업로드에 최대 30분을 준 다음 머신을 안전하게 종료합니다. 다음 로그인 때 다시 시작됩니다.",
    "The machine %@ is not running - nothing to prepare.":
      "머신 %@이(가) 실행 중이 아닙니다 - 준비할 것이 없습니다.",
    "The machine is stopped and everything reached Google Drive. The Mac can be restarted; the machine starts again at login.":
      "머신이 중지되었고 모든 데이터가 Google Drive에 도달했습니다. Mac을 재시동해도 됩니다. 머신은 로그인할 때 다시 시작됩니다.",
    "The machine is stopped. %@ GiB had not reached Google Drive yet - it is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "머신이 중지되었습니다. %@ GiB가 아직 Google Drive에 도달하지 않았습니다 - 머신의 버퍼에 보관되며 다음 시작 후 업로드됩니다. Mac을 재시동해도 됩니다.",
    "The machine is stopped. rclone did not say how much was still to upload; what was not uploaded is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "머신이 중지되었습니다. rclone이 남은 업로드 양을 알려 주지 않았습니다. 업로드되지 않은 데이터는 머신의 버퍼에 보관되며 다음 시작 후 업로드됩니다. Mac을 재시동해도 됩니다.",
    "The machine's disk is a file on this disk and grows as the upload buffer fills. With no space left the machine cannot write the buffer, and Time Machine's local snapshots have nowhere to go either.":
      "머신의 디스크는 이 디스크에 있는 파일이며 업로드 버퍼가 차오르면서 커집니다. 공간이 없으면 머신이 버퍼를 쓸 수 없고, Time Machine의 로컬 스냅샷도 저장할 곳이 없습니다.",
    "The image's metadata has never been copied to Drive":
      "이미지의 메타데이터가 Drive에 한 번도 복사되지 않았습니다",
    "The image's metadata was last copied to Drive %@ ago":
      "이미지의 메타데이터가 %@ 전에 Drive에 마지막으로 복사되었습니다",
    "The machine's disk is running out of space (%@ GB)":
      "머신의 디스크 공간이 부족합니다(%@ GB)",
    "The new sign-in does NOT see the existing backup (%@), so remote '%@' was NOT replaced and rclone.conf is unchanged. Keep the current connection, or sign in with the credential (client_id) that created the backup.":
      "새 로그인에서는 기존 백업(%1$@)이 보이지 않으므로 remote '%2$@'은(는) 교체되지 않았고 rclone.conf도 변경되지 않았습니다. 현재 연결을 유지하거나, 백업을 만든 자격 증명(client_id)으로 로그인하세요.",
    "The upload buffer lives on this disk. The guard pauses Time Machine before it fills; if the upload does not catch up, backups stay paused.":
      "업로드 버퍼는 이 디스크에 있습니다. 가드는 버퍼가 가득 차기 전에 Time Machine을 일시 중지합니다. 업로드가 따라잡지 못하면 백업은 계속 일시 중지됩니다.",
    "These bands exist only in the machine's buffer. The backup on Google Drive is INCOMPLETE and may not open.":
      "이 밴드는 머신의 버퍼에만 있습니다. Google Drive의 백업은 불완전하며 열리지 않을 수 있습니다.",
    "Time Machine backs up to the machine, so without it no backup is made. Start it: limactl start %@ (or the Start button in the app).":
      "Time Machine은 머신에 백업하므로 머신이 없으면 백업이 만들어지지 않습니다. 시작하세요: limactl start %@(또는 앱의 시작 버튼).",
    "Time Machine did not stop its backup within 2 minutes (or tmutil did not answer) - the machine was NOT stopped. Try again in a moment.":
      "Time Machine이 2분 안에 백업을 중지하지 않았거나(또는 tmutil이 응답하지 않아) 머신이 중지되지 않았습니다. 잠시 후 다시 시도하세요.",
    "Time Machine has created its image: stop the backup, then convert the image to 32 MB bands":
      "Time Machine이 이미지를 만들었습니다: 백업을 중지한 다음 이미지를 32 MB 밴드로 변환하세요",
    "To upload":
      "업로드 대기",
    "Unknown whether the CloudMachine machine is running":
      "CloudMachine 머신이 실행 중인지 알 수 없습니다",
    "Waiting for the upload to Google Drive (at most %@ min)...":
      "Google Drive로 업로드를 기다리는 중(최대 %@분)...",
    "With --replace-existing: confirms that the new sign-in (scope 'drive.file') may not see the existing backup. The new token is still checked against the backup first.":
      "--replace-existing와 함께 사용: 새 로그인('drive.file' 범위)이 기존 백업을 보지 못할 수 있음을 확인합니다. 새 토큰은 그 전에 먼저 백업과 대조됩니다.",
    "Without it there is no way to check whether anything reached the Drive - the machine's guard is blind then.":
      "이것이 없으면 Drive에 무언가 도달했는지 확인할 방법이 없으며, 머신의 가드는 앞이 보이지 않는 상태가 됩니다.",
    "limactl did not answer":
      "limactl이 응답하지 않았습니다",
    "limactl did not answer (or is not installed). That does not mean the machine is down - it means nobody has checked.":
      "limactl이 응답하지 않았거나 설치되어 있지 않습니다. 이는 머신이 꺼져 있다는 뜻이 아니라, 아무도 확인하지 않았다는 뜻입니다.",
    "limactl start failed: %@":
      "limactl start 실패: %@",
    "limactl stop failed: %@":
      "limactl stop 실패: %@",
    "punchfs is close to its open-file limit":
      "punchfs가 열 수 있는 파일 한도에 가까워졌습니다",
    "punchfs open files":
      "punchfs 열린 파일",
    "rclone's remote control is open on this Mac":
      "rclone의 원격 제어가 이 Mac에 열려 있습니다",
    "statfs('/System/Volumes/Data') returned an error, so nobody knows whether the machine's disk can still grow on this Mac.":
      "statfs('/System/Volumes/Data')가 오류를 반환하여, 이 Mac에서 머신의 디스크가 더 커질 수 있는지 알 수 없습니다.",
    "Google Drive's daily upload limit stops the upload":
      "Google Drive의 일일 업로드 한도로 업로드가 중단되었습니다",
    "Google last refused an upload %@ ago (750 GB a day). Backups since then are only in the machine's buffer on this Mac. rclone retries every 5 min and resumes by itself when the limit passes; the guard pauses Time Machine if more than %@ GiB waits.":
      "Google이 %1$@ 전에 마지막으로 업로드를 거부했습니다(하루 750 GB). 그 이후의 백업은 이 Mac에 있는 머신의 버퍼에만 있습니다. rclone은 5분마다 다시 시도하며 한도가 풀리면 자동으로 재개합니다. %2$@ GiB를 넘게 대기하면 가드가 Time Machine을 일시 중지합니다.",
    "Usage on Google Drive is not being measured":
      "Google Drive 사용량이 측정되고 있지 않습니다",
    "The last measurement (%@ GB) is from %@, %@ ago - rclone size has not answered since. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "마지막 측정(%1$@ GB)은 %2$@, %3$@ 전의 것입니다 - 그 이후 rclone size가 응답하지 않았습니다. 응답할 때까지 %4$@ GB 한도를 감시하는 것이 없으며, 90%% 및 100%% 알림도 울리지 않습니다. vm-status를 확인하거나 창에서 지금 측정을 누르세요.",
    "rclone size has not answered even once. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "rclone size가 한 번도 응답하지 않았습니다. 응답할 때까지 %@ GB 한도를 감시하는 것이 없으며, 90%% 및 100%% 알림도 울리지 않습니다. vm-status를 확인하거나 창에서 지금 측정을 누르세요.",
    "Saved in the Keychain. Connecting Google Drive (configure-remote) will use them.":
      "키체인에 저장했습니다. Google Drive(configure-remote)에 연결할 때 사용됩니다.",
    "Saved in the Keychain. The existing Google Drive connection keeps its old client_id, and on this Mac it should stay that way: a connection made with the new keys (the 'drive.file' scope) cannot see the backup created by the old one. Do not replace the connection here; the new keys are for a Mac that is not connected yet.":
      "키체인에 저장했습니다. 기존 Google Drive 연결은 이전 client_id를 유지하며, 이 Mac에서는 그대로 두어야 합니다. 새 키('drive.file' 범위)로 만든 연결은 이전 연결로 만든 백업을 볼 수 없습니다. 여기서 연결을 교체하지 마세요. 새 키는 아직 연결되지 않은 Mac용입니다.",
    "it is not there for the new token":
      "새 토큰에는 보이지 않습니다",
    "Cancel":
      "취소",
    "ACTION NEEDED":
      "조치 필요",
    "WILL PASS BY ITSELF — DO NOTHING":
      "저절로 해결됩니다 - 아무것도 하지 않아도 됩니다",
    "UNKNOWN — CHECK AGAIN SHORTLY":
      "알 수 없음 - 잠시 후 다시 확인하세요",
    "ALL GOOD":
      "모두 정상",
    "Upload is not working":
      "업로드가 작동하지 않습니다",
    "Upload stopped — no space left on Google Drive":
      "업로드 중단 - Google Drive에 남은 공간이 없습니다",
    "%@ backup fragments not uploaded":
      "백업 조각 %@개가 업로드되지 않았습니다",
    "Upload cannot keep up with writes":
      "업로드가 쓰기 속도를 따라가지 못합니다",
    "Upload paused — Google daily limit":
      "업로드 일시 중지 - Google 일일 한도",
    "Uploading to Google Drive — %@ queued":
      "Google Drive에 업로드 중 - %@개 대기 중",
    "Everything uploaded to Google Drive":
      "모두 Google Drive에 업로드되었습니다",
    "Unknown what is waiting in the queue":
      "대기열에 무엇이 있는지 알 수 없습니다",
    "There is no connection to Google Drive, so backups are only made on this Mac. If this does not pass by itself within a few minutes, check the network and the connection to Drive.":
      "Google Drive에 연결되어 있지 않아 백업이 이 Mac에서만 만들어집니다. 몇 분 안에 저절로 해결되지 않으면 네트워크와 Drive 연결을 확인하세요.",
    "There is no space left on Google Drive. This will NOT pass by itself — you need to free up space on Drive. Until then Time Machine is paused, so that it does not fill up this Mac's disk.":
      "Google Drive에 남은 공간이 없습니다. 이 문제는 저절로 해결되지 않습니다 - Drive의 공간을 비워야 합니다. 그때까지 이 Mac의 디스크가 가득 차지 않도록 Time Machine은 일시 중지됩니다.",
    "%@ backup fragments could not be uploaded and rclone stopped trying. These fragments exist only on this Mac, so the backup on Drive is incomplete. This needs checking.":
      "백업 조각 %@개를 업로드하지 못했고 rclone이 재시도를 멈췄습니다. 이 조각들은 이 Mac에만 있으므로 Drive의 백업은 불완전합니다. 확인이 필요합니다.",
    "Time Machine is writing faster than the upload goes, and the buffer has filled up. The backup will be paused until the upload catches up — this is a safeguard against filling up the disk, not a failure.":
      "Time Machine이 업로드보다 빠르게 쓰고 있어 버퍼가 가득 찼습니다. 업로드가 따라잡을 때까지 백업이 일시 중지됩니다 - 이는 디스크가 가득 차는 것을 막는 안전장치이며 오류가 아닙니다.",
    "Google accepts 750 GB per day and that limit has been used up. There is nothing to do: the limit renews by itself, usually within a few hours. Time Machine backups are made normally in the meantime and wait in the buffer — they will be uploaded as soon as Google starts accepting again.":
      "Google은 하루 750 GB까지 받으며 그 한도를 모두 사용했습니다. 할 일은 없습니다. 한도는 보통 몇 시간 안에 저절로 초기화됩니다. 그동안 Time Machine 백업은 정상적으로 만들어져 버퍼에서 대기하며, Google이 다시 받기 시작하면 바로 업로드됩니다.",
    "%@ backup fragments are queued and on their way to Drive.":
      "백업 조각 %@개가 대기열에서 Drive로 가는 중입니다.",
    "Nothing is waiting in the queue — the backup on Google Drive is complete.":
      "대기열에 대기 중인 것이 없습니다 - Google Drive의 백업이 완전합니다.",
    "rclone did not answer the question about the queue, so it is unknown how many backups are still waiting to be uploaded. This does not mean something broke — under load the answer can be late. It only means that right now nobody knows. If it persists, the backup cycle check will report it.":
      "rclone이 대기열에 대한 질문에 응답하지 않아 아직 업로드를 기다리는 백업이 얼마나 되는지 알 수 없습니다. 무언가 고장 났다는 뜻은 아닙니다 - 부하가 걸리면 응답이 늦어질 수 있습니다. 지금은 아무도 모른다는 뜻일 뿐입니다. 계속되면 백업 주기 점검이 알려 줍니다.",
    "unknown error":
      "알 수 없는 오류",
    "rclone lsf ended with an error":
      "rclone lsf가 오류와 함께 종료되었습니다",
    "This Mac is close to its space limit on Google Drive":
      "이 Mac이 Google Drive 공간 한도에 가까워졌습니다",
    "%@ GB of %@ GB used. Time Machine deletes the oldest backups to stay within its quota; check that the quota is set (vm-status).":
      "%2$@ GB 중 %1$@ GB 사용 중. Time Machine은 할당량을 지키기 위해 가장 오래된 백업을 삭제합니다. 할당량이 설정되어 있는지 확인하세요(vm-status).",
    "This Mac is over its space limit on Google Drive":
      "이 Mac이 Google Drive 공간 한도를 초과했습니다",
    "%@ GB of %@ GB used. Set the Time Machine quota (command in the app window or vm-status), or raise the limit.":
      "%2$@ GB 중 %1$@ GB 사용 중. Time Machine 할당량을 설정하거나(명령어는 앱 창 또는 vm-status에 있음) 한도를 높이세요.",
    "not set":
      "설정되지 않음",
    "%@ GB - usage not measured yet":
      "%@ GB - 사용량 아직 측정되지 않음",
    "%@ of %@ GB used (%@%%)":
      "%2$@ GB 중 %1$@ GB 사용(%3$@%%)",
    "The limit must be a whole number of GB above zero.":
      "한도는 0보다 큰 GB 단위의 정수여야 합니다.",
    "machines.json cannot be read, so it was not overwritten. Fix or remove it first.":
      "machines.json을 읽을 수 없어 덮어쓰지 않았습니다. 먼저 수정하거나 삭제하세요.",
    "'%@' is not a valid folder name: use lowercase letters, digits and dashes.":
      "'%@'은(는) 올바른 폴더 이름이 아닙니다: 소문자, 숫자, 하이픈을 사용하세요.",
    "This Mac already backs up to folder '%@'. Switching to '%@' would start a new, empty backup and orphan the existing one, so nothing was changed.":
      "이 Mac은 이미 폴더 '%1$@'에 백업하고 있습니다. '%2$@'(으)로 전환하면 새 빈 백업이 시작되고 기존 백업이 고아가 되므로 아무것도 변경하지 않았습니다.",
    "This Mac already has a CloudMachine installation, whose backup is in folder '%@'. Switching to '%@' would orphan it, so nothing was changed.":
      "이 Mac에는 이미 CloudMachine이 설치되어 있으며 백업은 폴더 '%1$@'에 있습니다. '%2$@'(으)로 전환하면 고아가 되므로 아무것도 변경하지 않았습니다.",
    "Could not save the folder name to %@: %@":
      "폴더 이름을 %1$@에 저장할 수 없습니다: %2$@",
    "Homebrew is not installed. Install it manually: https://brew.sh":
      "Homebrew가 설치되어 있지 않습니다. 직접 설치하세요: https://brew.sh",
    "Installing rclone failed: %@":
      "rclone 설치 실패: %@",
    "Installed rclone.":
      "rclone을 설치했습니다.",
    "Own Google credentials: set.":
      "자체 Google 자격 증명: 설정됨.",
    "INCOMPLETE: %@ is missing - rclone will use rclone's shared client_id anyway.":
      "불완전: %@이(가) 없습니다 - rclone은 어차피 공유 client_id를 사용합니다.",
    "No own credentials - rclone uses the shared client_id, rate-limited jointly and being retired in 2026.":
      "자체 자격 증명 없음 - rclone은 공유 client_id를 사용하며, 이는 공동으로 속도 제한을 받고 2026년에 폐기됩니다.",
    "Empty value - not saving.":
      "빈 값 - 저장하지 않습니다.",
    "Keychain refused: %@":
      "키체인이 거부했습니다: %@",
    "DIRTY-TREE":
      "커밋되지 않은 변경",
    "Cannot create the working directory: %@":
      "작업 디렉터리를 만들 수 없습니다: %@",
    "Could not read the rclone version number.":
      "rclone 버전 번호를 읽을 수 없습니다.",
    "Could not download %@.":
      "%@을(를) 다운로드할 수 없습니다.",
    "No entry for %@ in SHA256SUMS.":
      "SHA256SUMS에 %@ 항목이 없습니다.",
    "Could not compute the checksum.":
      "체크섬을 계산할 수 없습니다.",
    "SHA256 checksum does not match - NOT installing.\n  expected: %@\n  computed: %@":
      "SHA256 체크섬이 일치하지 않습니다 - 설치하지 않습니다.\n  기대값: %1$@\n  계산값: %2$@",
    "Could not unpack the archive.":
      "압축을 풀 수 없습니다.",
    "Could not install the binary: %@":
      "바이너리를 설치할 수 없습니다: %@",
    "Installed rclone %@ in %@ (SHA256 checksum matches).":
      "rclone %1$@을(를) %2$@에 설치했습니다(SHA256 체크섬 일치).",
    "%@ did not respond within the allotted time (the process was left orphaned in the background).":
      "%@이(가) 제한 시간 안에 응답하지 않았습니다(프로세스가 백그라운드에 남겨졌습니다).",
    "Cannot launch %@: %@":
      "%1$@을(를) 실행할 수 없습니다: %2$@",
    "Remote '%@' already exists and was NOT touched.\nOverwriting it replaces the token and the permission scope; a credential with the 'drive.file' scope does not see files created by the previous one, so the existing backup becomes unreachable.\nIf you really want to replace it, first back up ~/.config/rclone/rclone.conf and run again with --replace-existing.":
      "remote '%@'은(는) 이미 있으며 변경되지 않았습니다.\n덮어쓰면 토큰과 권한 범위가 교체됩니다. 'drive.file' 범위의 자격 증명은 이전 자격 증명이 만든 파일을 볼 수 없으므로 기존 백업에 접근할 수 없게 됩니다.\n정말 교체하려면 먼저 ~/.config/rclone/rclone.conf를 백업한 다음 --replace-existing을 붙여 다시 실행하세요.",
    "Could not check whether remote '%@' already exists (rclone listremotes did not answer or failed), so nothing was changed. Run `%@ listremotes` to see the error, then try again.":
      "remote '%1$@'이(가) 이미 있는지 확인할 수 없어(rclone listremotes가 응답하지 않았거나 실패함) 아무것도 변경하지 않았습니다. `%2$@ listremotes`를 실행하여 오류를 확인한 다음 다시 시도하세요.",
    "Could not check whether this Mac already has a CloudMachine installation (rclone did not answer), so no folder was chosen. Try again in a moment.":
      "이 Mac에 CloudMachine이 이미 설치되어 있는지 확인할 수 없어(rclone이 응답하지 않음) 폴더를 선택하지 않았습니다. 잠시 후 다시 시도하세요.",
    "rclone authorize failed (%@). If that binary is missing, start with: cloudmachine-agent install-rclone.":
      "rclone authorize가 실패했습니다(%@). 해당 바이너리가 없다면 다음으로 시작하세요: cloudmachine-agent install-rclone.",
    "Could not read the token from the output of rclone authorize.":
      "rclone authorize의 출력에서 토큰을 읽을 수 없습니다.",
    "rclone config create failed.":
      "rclone config create가 실패했습니다.",
    "Connected to Google Drive as remote '%@', folder %@.":
      "Google Drive에 remote '%1$@', 폴더 %2$@(으)로 연결했습니다.",
    "tmutil is not responding - unknown where the backup goes":
      "tmutil이 응답하지 않습니다 - 백업이 어디로 가는지 알 수 없습니다",
    "No successful backup for %@":
      "%@ 동안 성공한 백업이 없습니다",
    "Last COMPLETED backup: %@. The cycle is hourly, so that is %@ missed runs.":
      "마지막으로 완료된 백업: %1$@. 주기가 1시간이므로 %2$@회 실행이 누락되었습니다.",
    "There is NOT A SINGLE successful backup":
      "성공한 백업이 하나도 없습니다",
    "The Time Machine preferences contain no date of a completed backup for this destination.":
      "Time Machine 환경설정에 이 대상에 대해 완료된 백업의 날짜가 없습니다.",
    "The last backup attempt did not end in a backup":
      "마지막 백업 시도가 백업으로 끝나지 않았습니다",
    "The attempt at %@ is newer than the last successful backup at %@.":
      "%1$@의 시도가 마지막으로 성공한 백업(%2$@)보다 최근입니다.",
    "Time Machine reports an error in the last run (RESULT=%@)":
      "Time Machine이 마지막 실행에서 오류를 알렸습니다(RESULT=%@)",
    "A non-zero RESULT in the Time Machine preferences means the run did not succeed.":
      "Time Machine 환경설정의 RESULT가 0이 아니면 해당 실행이 성공하지 못했다는 뜻입니다.",
    "rclone failed to upload %@ files":
      "rclone이 파일 %@개를 업로드하지 못했습니다",
    "Buffer full of nothing but unsent data":
      "버퍼가 전송되지 않은 데이터로만 가득 찼습니다",
    "rclone has nothing left to evict from the buffer - the upload cannot keep up or has stalled.":
      "rclone이 버퍼에서 비울 것이 더 이상 없습니다 - 업로드가 따라가지 못하거나 멈췄습니다.",
    "The rclone control interface is not responding":
      "rclone 제어 인터페이스가 응답하지 않습니다",
    "Google Drive is running out of space (%@ GB)":
      "Google Drive 공간이 부족합니다(%@ GB)",
    "The Mac's disk is running out of space (%@ GB)":
      "Mac의 디스크 공간이 부족합니다(%@ GB)",
    "Cannot read the Time Machine preferences":
      "Time Machine 환경설정을 읽을 수 없습니다",
    "%@ is unreadable - most often Full Disk Access is missing. Without this file it is UNKNOWN when the last backup was made, so we treat it as a failure, not as the absence of a problem.":
      "%@을(를) 읽을 수 없습니다 - 대개 전체 디스크 접근 권한이 없기 때문입니다. 이 파일이 없으면 마지막 백업 시점을 알 수 없으므로, 문제가 없는 것으로 보지 않고 실패로 처리합니다.",
    "Cannot measure free space on the Mac's disk":
      "Mac 디스크의 여유 공간을 측정할 수 없습니다",
    "%@ days":
      "%@일",
    "CloudMachine: backup is not working":
      "CloudMachine: 백업이 작동하지 않습니다",
    "unknown reason":
      "알 수 없는 이유",
    "osascript did not show the notification (permissions or no graphical session)":
      "osascript가 알림을 표시하지 않았습니다(권한이 없거나 그래픽 세션이 없음)",
    "UNDELIVERED ALARM: %@":
      "전달되지 않은 경고: %@",
    "from %@, reason: %@":
      "%1$@에서, 이유: %2$@",
    "The system notification was not delivered - you will see this alarm ONLY here.":
      "시스템 알림이 전달되지 않았습니다 - 이 경고는 여기에서만 볼 수 있습니다.",
    "%@ (%@ ago)":
      "%1$@(%2$@ 전)",
    "%@ - marker from the FUTURE":
      "%@ - 미래의 표식",
    "%@ (%@ ago) - THE WATCHDOG MAY NOT BE RUNNING":
      "%1$@(%2$@ 전) - 감시 기능이 실행되고 있지 않을 수 있습니다",
    "NEVER - the watchdog has not recorded a single run":
      "한 번도 없음 - 감시 기능이 실행을 한 번도 기록하지 않았습니다",
    "Could not find the launchd/ directory with templates.":
      "템플릿이 있는 launchd/ 디렉터리를 찾을 수 없습니다.",
    "Could not find the compiled cloudmachine-agent binary.":
      "컴파일된 cloudmachine-agent 바이너리를 찾을 수 없습니다.",
    "ABORTED: could not put cloudmachine-agent in a stable location\n(%@) - most often a lack of space or permissions.\nNOT installing agents pointing at %@: that path\ndisappears on the next `swift build` or `git clean`, and backups stop\nwithout any visible signal.":
      "중단됨: cloudmachine-agent를 고정된 위치에 둘 수 없습니다\n(%1$@) - 대개 공간 또는 권한이 부족하기 때문입니다.\n%2$@을(를) 가리키는 에이전트는 설치하지 않습니다: 이 경로는\n다음 `swift build` 또는 `git clean` 때 사라지며, 백업이\n눈에 보이는 신호 없이 중단됩니다.",
    "ABORTED: %@":
      "중단됨: %@",
    "Could not list the templates in %@.":
      "%@의 템플릿 목록을 가져올 수 없습니다.",
    "could not read the template %@":
      "템플릿 %@을(를) 읽을 수 없습니다",
    "could not write %@ (lack of space or permissions)":
      "%@을(를) 쓸 수 없습니다(공간 또는 권한 부족)",
    "launchctl load refused to load %@":
      "launchctl load가 %@의 로드를 거부했습니다",
    "NOT A SINGLE agent was loaded.":
      "로드된 에이전트가 하나도 없습니다.",
    "Only these went in: %@.":
      "다음만 설치되었습니다: %@.",
    "Could not load any launchd agent.":
      "launchd 에이전트를 하나도 로드할 수 없습니다.",
    "Installed agents: %@":
      "설치된 에이전트: %@",
    "                  WARNING: close to the limit - new bands will fail with EMFILE":
      "                  경고: 한도에 가까움 - 새 밴드가 EMFILE로 실패합니다",
    "%@/bands on Google Drive is not empty - it may hold another backup. NOT overwriting it; check it by hand.":
      "Google Drive의 %@/bands가 비어 있지 않습니다 - 다른 백업이 있을 수 있습니다. 덮어쓰지 않습니다. 직접 확인하세요.",
    "Address:          %@":
      "주소:             %@",
    "Already prepared (%@ exists) - nothing to do.":
      "이미 준비됨(%@이(가) 있음) - 할 일이 없습니다.",
    "Converts Time Machine's new, empty image in the machine to 32 MB bands and moves the bands to Google Drive.":
      "머신에 있는 Time Machine의 새 빈 이미지를 32 MB 밴드로 변환하고 밴드를 Google Drive로 옮깁니다.",
    "Copy rclone.conf into the machine even if it already has one.":
      "이미 rclone.conf가 있더라도 머신에 복사합니다.",
    "Copying the converted image into the machine failed: %@":
      "변환된 이미지를 머신에 복사하지 못했습니다: %@",
    "Copying the image to the Mac failed: %@":
      "이미지를 Mac에 복사하지 못했습니다: %@",
    "Could not ask Lima about the machine: %@":
      "머신에 대해 Lima에 문의할 수 없습니다: %@",
    "Could not carry the Time Machine files over: %@":
      "Time Machine 파일을 옮길 수 없습니다: %@",
    "Could not check the image in the machine.":
      "머신의 이미지를 확인할 수 없습니다.",
    "Could not copy the rclone configuration into the machine.":
      "rclone 구성을 머신에 복사할 수 없습니다.",
    "Could not create %@ on Google Drive: %@":
      "Google Drive에 %1$@을(를) 만들 수 없습니다: %2$@",
    "Could not create %@: %@":
      "%1$@을(를) 만들 수 없습니다: %2$@",
    "Could not find the vm/ directory with the machine template.":
      "머신 템플릿이 있는 vm/ 디렉터리를 찾을 수 없습니다.",
    "Could not read the image size.":
      "이미지 크기를 읽을 수 없습니다.",
    "Could not set the SMB password of user %@ in the machine.":
      "머신에서 사용자 %@의 SMB 암호를 설정할 수 없습니다.",
    "Could not stop smbd in the machine.":
      "머신의 smbd를 중지할 수 없습니다.",
    "Could not write %@ in the machine.":
      "머신에 %@을(를) 쓸 수 없습니다.",
    "Could not write the password file %@.":
      "암호 파일 %@을(를) 쓸 수 없습니다.",
    "Creates or starts the CloudMachine machine (Lima), gives it rclone's configuration and an SMB password, and prints the Time Machine command.":
      "CloudMachine 머신(Lima)을 만들거나 시작하고, rclone 구성과 SMB 암호를 전달한 다음, Time Machine 명령어를 출력합니다.",
    "Creating the machine %@ (first start downloads Ubuntu and installs packages - several minutes)...":
      "머신 %@ 생성 중(처음 시작할 때 Ubuntu를 다운로드하고 패키지를 설치합니다 - 몇 분 걸립니다)...",
    "Done: %@ has %@ MB bands on Google Drive; the original is kept in %@ in the machine. Start the backup: tmutil startbackup":
      "완료: %1$@은(는) Google Drive에서 %2$@ MB 밴드가 되었습니다. 원본은 머신의 %3$@에 보관되어 있습니다. 백업 시작: tmutil startbackup",
    "exit code %@, no message":
      "종료 코드 %@, 메시지 없음",
    "Image metadata:   NEVER copied to %@ - check tm-meta-sync in the machine":
      "이미지 메타데이터: %@에 한 번도 복사되지 않음 - 머신의 tm-meta-sync를 확인하세요",
    "Image metadata:   copied %@ ago to %@":
      "이미지 메타데이터: %1$@ 전에 %2$@에 복사됨",
    "Image metadata:   last copied %@ ago - OVERDUE (%@)":
      "이미지 메타데이터: 마지막 복사가 %1$@ 전 - 지연됨(%2$@)",
    "Image metadata:   not copied yet - waits for vm-prepare-bundle":
      "이미지 메타데이터: 아직 복사되지 않음 - vm-prepare-bundle을 기다리는 중",
    "Backup %@, paused by the guard %@: %@":
      "백업 %1$@, 가드에 의한 일시 중지 %2$@: %3$@",
    "Free in machine:  %@ GiB":
      "머신 여유 공간:   %@ GiB",
    "fsck_apfs -n found problems: %@":
      "fsck_apfs -n이 문제를 발견했습니다: %@",
    "Google Drive folder: %@":
      "Google Drive 폴더: %@",
    "hdiutil attach of the converted image failed: %@":
      "변환된 이미지의 hdiutil attach가 실패했습니다: %@",
    "hdiutil convert failed: %@":
      "hdiutil convert가 실패했습니다: %@",
    "Image name in the machine (default: from the computer name).":
      "머신의 이미지 이름(기본값: 컴퓨터 이름에서 가져옴).",
    "Installing the converted image FAILED: %@\nsmbd is left STOPPED so Time Machine does not open a half-installed image. The original is in %@ in the machine.":
      "변환된 이미지 설치에 실패했습니다: %1$@\nTime Machine이 반쯤 설치된 이미지를 열지 않도록 smbd는 중지된 상태로 둡니다. 원본은 머신의 %2$@에 있습니다.",
    "limactl create failed: %@":
      "limactl create 실패: %@",
    "limactl list failed: %@":
      "limactl list 실패: %@",
    "limactl not found - install Lima: brew install lima":
      "limactl을 찾을 수 없습니다 - Lima를 설치하세요: brew install lima",
    "limactl start failed: %@\nThe machine's own log: %@":
      "limactl start 실패: %1$@\n머신 자체 로그: %2$@",
    "Machine %@ is running.":
      "머신 %@이(가) 실행 중입니다.",
    "Machine %@ was already running.":
      "머신 %@이(가) 이미 실행 중이었습니다.",
    "Machine:          %@ (%@)":
      "머신:             %1$@ (%2$@)",
    "Machine:          %@":
      "머신:             %@",
    "Machine:          not created - run: cloudmachine-agent vm-setup":
      "머신:             만들어지지 않음 - 다음을 실행하세요: cloudmachine-agent vm-setup",
    "no answer within the time limit":
      "제한 시간 내에 응답 없음",
    "No image %@ in the machine.":
      "머신에 이미지 %@이(가) 없습니다.",
    "No image in the machine yet - point Time Machine at the share and let it create one first.":
      "머신에 아직 이미지가 없습니다 - 먼저 Time Machine이 공유를 가리키게 하고 이미지를 만들도록 하세요.",
    "No rclone configuration at %@ - connect Google Drive first (configure-remote).":
      "%@에 rclone 구성이 없습니다 - 먼저 Google Drive를 연결하세요(configure-remote).",
    "no SMB destination":
      "SMB 대상 없음",
    "One check of the machine's upload buffer: pauses Time Machine when it fills, resumes what it paused.":
      "머신의 업로드 버퍼를 한 번 점검합니다. 버퍼가 가득 차면 Time Machine을 일시 중지하고, 일시 중지한 것을 재개합니다.",
    "Packing the converted image failed: %@":
      "변환된 이미지 패킹에 실패했습니다: %@",
    "Packing the image failed: %@":
      "이미지 패킹에 실패했습니다: %@",
    "No answer from the machine (rclone rc) - the guard would do nothing.":
      "머신(rclone rc)에서 응답이 없습니다 - 가드는 아무것도 하지 않을 것입니다.",
    "Only print what the guard would decide - for trying thresholds on a throwaway machine.":
      "가드가 내릴 결정만 출력합니다 - 임시 머신에서 임곗값을 시험하기 위한 것입니다.",
    "Pause above this many GiB in the buffer.":
      "버퍼에 이 GiB를 넘으면 일시 중지합니다.",
    "Pause when the machine has less free than this, in GiB.":
      "머신의 여유 공간이 이 GiB보다 적으면 일시 중지합니다.",
    "Point Time Machine at the machine (once, needs an administrator password):":
      "Time Machine이 머신을 가리키게 하세요(한 번만, 관리자 암호 필요):",
    "punchfs files:    %@ open, limit %@":
      "punchfs 파일:     %1$@개 열림, 한도 %2$@",
    "rclone configuration already in the machine - kept (--replace-rclone-config replaces it).":
      "rclone 구성이 이미 머신에 있습니다 - 유지했습니다(--replace-rclone-config로 교체할 수 있음).",
    "rclone configuration copied into the machine.":
      "rclone 구성을 머신에 복사했습니다.",
    "rclone-tm or punchfs is not running in the machine - see cloudmachine-agent vm-status.":
      "머신에서 rclone-tm 또는 punchfs가 실행되고 있지 않습니다 - cloudmachine-agent vm-status를 참조하세요.",
    "Resume below this many GiB (only a backup the guard paused).":
      "버퍼가 이 GiB보다 줄어들면 재개합니다(가드가 일시 중지한 백업만 해당).",
    "Service %@: %@":
      "서비스 %1$@: %2$@",
    "Several images in the machine (%@) - choose one with --bundle.":
      "머신에 이미지가 여러 개 있습니다(%@) - --bundle로 하나를 선택하세요.",
    "Shows the machine: address, services, upload buffer, free space and the Time Machine destination.":
      "머신의 상태를 보여 줍니다: 주소, 서비스, 업로드 버퍼, 여유 공간, Time Machine 대상.",
    "SMB password stored in %@ (mode 600).":
      "SMB 암호를 %@에 저장했습니다(모드 600).",
    "The converted image does not have %@-byte bands.":
      "변환된 이미지의 밴드가 %@바이트가 아닙니다.",
    "The converted image has no APFS partition.":
      "변환된 이미지에 APFS 파티션이 없습니다.",
    "The image already takes %@ MB - this command converts only a new, empty image (under %@ MB).":
      "이미지가 이미 %1$@ MB를 차지하고 있습니다 - 이 명령은 새 빈 이미지(%2$@ MB 미만)만 변환합니다.",
    "The image is encrypted - converting encrypted images is not supported.":
      "이미지가 암호화되어 있습니다 - 암호화된 이미지의 변환은 지원되지 않습니다.",
    "The image was not changed; smbd started again.":
      "이미지는 변경되지 않았으며 smbd를 다시 시작했습니다.",
    "The machine does not answer - is it running? cloudmachine-agent vm-status":
      "머신이 응답하지 않습니다 - 실행 중인가요? cloudmachine-agent vm-status",
    "The machine has no address on the vzNAT network.":
      "머신에 vzNAT 네트워크 주소가 없습니다.",
    "The services in the machine did not start - check: cloudmachine-agent vm-status":
      "머신의 서비스가 시작되지 않았습니다 - 확인: cloudmachine-agent vm-status",
    "Time Machine is backing up - stop it first: tmutil stopbackup":
      "Time Machine이 백업 중입니다 - 먼저 중지하세요: tmutil stopbackup",
    "Time Machine:     %@":
      "Time Machine:     %@",
    "Time Machine:     NOT pointing at the machine (%@)":
      "Time Machine:     머신을 가리키지 않음(%@)",
    "Time Machine:     tmutil did not answer":
      "Time Machine:     tmutil이 응답하지 않았습니다",
    "tmutil did not answer - not touching the image while its state is unknown.":
      "tmutil이 응답하지 않았습니다 - 이미지의 상태를 모르는 동안에는 이미지를 건드리지 않습니다.",
    "unknown":
      "알 수 없음",
    "Unpacking the image failed: %@":
      "이미지 압축 풀기에 실패했습니다: %@",
    "Still to upload:  %@ GiB in %@ bands, uploading %@ (cache on disk %@ GiB)":
      "업로드 대기:      %2$@개 밴드에 %1$@ GiB, %3$@ 업로드 중(디스크 캐시 %4$@ GiB)",
    "Excluded %@ (the machine and its upload buffer) from Time Machine.":
      "%@(머신과 그 업로드 버퍼)을(를) Time Machine에서 제외했습니다.",
    "WARNING: could not exclude %@ from Time Machine - run: tmutil addexclusion %@":
      "경고: %1$@을(를) Time Machine에서 제외할 수 없습니다 - 다음을 실행하세요: tmutil addexclusion %2$@",
    "Upload buffer:    no answer from rclone (rc %@)":
      "업로드 버퍼:      rclone(rc %@)에서 응답 없음",
    "When Time Machine has created its empty image, stop the backup (tmutil stopbackup) and run: cloudmachine-agent vm-prepare-bundle":
      "Time Machine이 빈 이미지를 만들면 백업을 중지(tmutil stopbackup)하고 다음을 실행하세요: cloudmachine-agent vm-prepare-bundle",
    "Unsent %@ GiB, free %@ GiB (pause above %@ GiB unsent or below %@ GiB free, resume below %@ GiB).":
      "미전송 %1$@ GiB, 여유 %2$@ GiB(미전송이 %3$@ GiB를 넘거나 여유가 %4$@ GiB 미만이면 일시 중지, %5$@ GiB 미만이면 재개).",
    "Upload:           Google's daily limit refused an upload %@ ago - rclone retries every 5 min and resumes by itself":
      "업로드:           Google의 일일 한도로 %@ 전에 업로드가 거부됨 - rclone은 5분마다 다시 시도하며 저절로 재개합니다",
    "no":
      "아니요",
    "running":
      "실행 중",
    "stopped":
      "중지됨",
    "yes":
      "예",
    "%@\nThe previous template is in %@ - copy it back over lima.yaml and run limactl start %@.":
      "%1$@\n이전 템플릿은 %2$@에 있습니다 - lima.yaml 위에 다시 복사한 다음 limactl start %3$@을(를) 실행하세요.",
    "Could not read this app's machine template (limactl template copy).":
      "이 앱의 머신 템플릿을 읽을 수 없습니다(limactl template copy).",
    "Could not replace %@: %@":
      "%1$@을(를) 교체할 수 없습니다: %2$@",
    "Machine %@ already runs this app's template.":
      "머신 %@은(는) 이미 이 앱의 템플릿으로 실행 중입니다.",
    "Machine %@ now runs this app's template; the previous one is in %@.":
      "머신 %1$@은(는) 이제 이 앱의 템플릿으로 실행됩니다. 이전 템플릿은 %2$@에 있습니다.",
    "Moves the machine onto this app's template (two restarts, never during a backup).":
      "머신을 이 앱의 템플릿으로 옮깁니다(재시작 두 번, 백업 중에는 하지 않음).",
    "No machine %@ - create it with: cloudmachine-agent vm-setup":
      "머신 %@이(가) 없습니다 - 다음으로 만드세요: cloudmachine-agent vm-setup",
    "Template:         OLDER than this app's - run: cloudmachine-agent vm-update":
      "템플릿:           이 앱의 것보다 오래됨 - 다음을 실행하세요: cloudmachine-agent vm-update",
    "Template:         not compared":
      "템플릿:           비교하지 않음",
    "Template:         this app's":
      "템플릿:           이 앱의 것",
    "The machine has no %@ - run cloudmachine-agent vm-setup first.":
      "머신에 %@이(가) 없습니다 - 먼저 cloudmachine-agent vm-setup을 실행하세요.",
    "The machine restarted, but not every service is running - check: cloudmachine-agent vm-status. The previous template is in %@.":
      "머신이 다시 시작되었지만 모든 서비스가 실행되고 있지는 않습니다 - 확인: cloudmachine-agent vm-status. 이전 템플릿은 %@에 있습니다.",
    "The template changes the machine itself (%@) - that needs a new machine, not an update.":
      "템플릿이 머신 자체(%@)를 변경합니다 - 업데이트가 아니라 새 머신이 필요합니다.",
    "The upload to Google Drive hangs":
      "Google Drive로의 업로드가 멈췄습니다",
    "Time Machine is backing up - try again when it has finished.":
      "Time Machine이 백업 중입니다 - 끝난 후 다시 시도하세요.",
    "Upload:           HANGS - bands in progress, none uploaded for %@ (network?); see /var/log/rclone-tm.log in the machine":
      "업로드:           멈춤 - 진행 중인 밴드가 있지만 %@ 동안 업로드된 것이 없음(네트워크?). 머신의 /var/log/rclone-tm.log 참조",
    "limactl stop failed - nothing was changed.":
      "limactl stop 실패 - 아무것도 변경되지 않았습니다.",
    "rclone has bands in progress, but none has been uploaded for %@ - usually a broken network connection, which rclone does not report as an error. Backups since then are only in the machine's buffer. When the network comes back the upload resumes by itself (on 28.10.2026 within 80 s); if it does not, restarting the machine (prepare-shutdown, limactl start) drops the dead connections.":
      "rclone에 진행 중인 밴드가 있지만 %1$@ 동안 업로드된 것이 없습니다 - 대개 네트워크 연결이 끊긴 경우이며, rclone은 이를 오류로 알리지 않습니다. 그 이후의 백업은 머신의 버퍼에만 있습니다. 네트워크가 복구되면 업로드가 저절로 재개됩니다(2026년 10월 28일에는 80초 이내). 재개되지 않으면 머신을 다시 시작하면(prepare-shutdown, limactl start) 끊어진 연결이 정리됩니다.",
    "tmutil did not answer - not restarting the machine while its state is unknown.":
      "tmutil이 응답하지 않았습니다 - 머신의 상태를 모르는 동안에는 머신을 다시 시작하지 않습니다.",
    "The machine's share cannot be read":
      "머신의 공유를 읽을 수 없습니다",
    "Unknown whether the machine's share can be read":
      "머신의 공유를 읽을 수 있는지 알 수 없습니다",
    "Samba in the machine does not answer this Mac":
      "머신의 Samba가 이 Mac에 응답하지 않습니다",
    "Unknown whether Samba in the machine answers this Mac":
      "머신의 Samba가 이 Mac에 응답하는지 알 수 없습니다",
    "Reading 1 byte of %@ in the machine failed: %@. Every service says it is active, yet Time Machine cannot use the image there. Nothing restarts it by itself. Check: cloudmachine-agent vm-status, then in the machine: journalctl -u punchfs -u tm-bands-bind -u rclone-tm":
      "머신의 %@에서 1바이트를 읽지 못했습니다: %@. 모든 서비스가 활성 상태라고 하지만 Time Machine은 그곳의 이미지를 사용할 수 없습니다. 스스로 재시작되지 않습니다. 확인: cloudmachine-agent vm-status, 그다음 머신에서: journalctl -u punchfs -u tm-bands-bind -u rclone-tm",
    "Reading 1 byte of %@ in the machine has not returned for %@ s. That is how a hung punchfs or rclone mount behaves. Nothing is restarted while the state is unknown - a restart under a write still going could lose it. Check in the machine: journalctl -u punchfs -u rclone-tm":
      "머신의 %@에서 1바이트 읽기가 %@초째 돌아오지 않습니다. punchfs 또는 rclone 마운트가 멈췄을 때의 동작입니다. 상태를 알 수 없는 동안에는 아무것도 재시작하지 않습니다 - 진행 중인 쓰기 도중 재시작하면 그 쓰기를 잃을 수 있습니다. 머신에서 확인: journalctl -u punchfs -u rclone-tm",
    "An SMB connection to %@ got no answer within %@ s. Time Machine reaches the machine at this address. Check the machine's network and smbd: cloudmachine-agent vm-status":
      "%@(으)로의 SMB 연결이 %@초 안에 응답을 받지 못했습니다. Time Machine은 이 주소로 머신에 접속합니다. 머신의 네트워크와 smbd를 확인하세요: cloudmachine-agent vm-status",
    "The machine did not report its address, so nobody could try an SMB connection. Check: cloudmachine-agent vm-status":
      "머신이 주소를 알려 주지 않아 아무도 SMB 연결을 시도할 수 없었습니다. 확인: cloudmachine-agent vm-status",
    "An SMB connection to %@ failed (%@). Time Machine reaches the machine at this address, so no backup is made. Check the machine's network and smbd: cloudmachine-agent vm-status":
      "%@(으)로의 SMB 연결에 실패했습니다(%@). Time Machine은 이 주소로 머신에 접속하므로 백업이 만들어지지 않습니다. 머신의 네트워크와 smbd를 확인하세요: cloudmachine-agent vm-status",
    "readable":
      "읽기 가능",
    "no image yet":
      "아직 이미지 없음",
    "answers":
      "응답함",
    "Share read:       %@":
      "공유 읽기:        %@",
    "Samba from Mac:   %@":
      "Mac에서 Samba:    %@",
    "This Mac found no route to %@ (%@). Either the route to the machine is gone, or macOS Local Network privacy has not allowed CloudMachine - then allow it in System Settings > Privacy & Security > Local Network. Check: cloudmachine-agent vm-status":
      "이 Mac이 %@(으)로 가는 경로를 찾지 못했습니다(%@). 머신으로 가는 경로가 사라졌거나 macOS의 '로컬 네트워크' 개인정보 보호가 CloudMachine을 허용하지 않았습니다 - 그렇다면 시스템 설정 > 개인정보 보호 및 보안 > 로컬 네트워크에서 허용하세요. 확인: cloudmachine-agent vm-status",
  ]
}
