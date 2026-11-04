// Korean translations of vm-encrypt (DriveEncryption), keyed by the English text.
extension L10nTranslations {
  static let koEncryption: [String: String] = [
    "%@ and its metadata are in Google Drive's bin (kept 30 days, still counted in the quota).":
      "%@ 및 메타데이터는 Google Drive 휴지통에 있습니다(30일 동안 보관되며 계속 용량에 포함됩니다).",
    "'%@' is already in %@ - not replacing its password.":
      "'%@'이(가) 이미 %@에 있습니다 - 암호를 바꾸지 않습니다.",
    "'%@' is already in the machine's rclone.conf - not replacing its password.":
      "'%@'이(가) 이미 머신의 rclone.conf에 있습니다 - 암호를 바꾸지 않습니다.",
    "%@ holds folders this key cannot read: another password or salt in the machine, or leftovers of an earlier try. Compare the machine's rclone.conf with the Mac's; leftovers have to be removed from %@ by hand.":
      "%@에 이 키로 읽을 수 없는 폴더가 있습니다: 머신의 암호나 솔트가 다르거나 이전 시도의 잔여물입니다. 머신의 rclone.conf를 Mac의 것과 비교하십시오. 잔여물은 %@에서 직접 삭제해야 합니다.",
    "'%@' is incomplete or missing in the Mac's rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "Mac의 rclone.conf에 '%@'이(가) 없거나 불완전합니다 - 실행: cloudmachine-agent vm-encrypt setup",
    "CLOUDMACHINE_VM_INSTANCE=%@ needs its own rclone.conf - set RCLONE_CONFIG to a copy, not %@. Its Keychain entry is service %@.":
      "CLOUDMACHINE_VM_INSTANCE=%@에는 자체 rclone.conf가 필요합니다 - RCLONE_CONFIG를 %@이(가) 아닌 사본으로 설정하십시오. 키체인 항목은 서비스 %@입니다.",
    "Could not read the '%@' section on the Mac or in the machine.":
      "Mac 또는 머신에서 '%@' 섹션을 읽을 수 없습니다.",
    "The machine's '%@' (password, salt or folder) differs from the Mac's - the copy would be readable only with the machine's key. Not moving anything.":
      "머신의 '%@'(암호, 솔트 또는 폴더)이(가) Mac의 것과 다릅니다 - 사본은 머신의 키로만 읽을 수 있게 됩니다. 아무것도 옮기지 않습니다.",
    "A file was restored from the encrypted backup.":
      "암호화된 백업에서 파일을 복원했습니다.",
    "Added '%@' (%@) on the Mac and in the machine; password and salt are in the Keychain (service %@).\nSALT: %@\nKeep the password AND this salt outside this Mac now - without both the encrypted backup cannot be read. Next: cloudmachine-agent vm-encrypt copy":
      "'%@'(%@)을(를) Mac과 머신에 추가했습니다. 암호와 솔트는 키체인에 있습니다(서비스 %@).\n솔트: %@\n지금 암호와 이 솔트를 모두 이 Mac 밖에 보관하십시오 - 둘 다 없으면 암호화된 백업을 읽을 수 없습니다. 다음: cloudmachine-agent vm-encrypt copy",
    "Adds the encrypted remote on the Mac and in the machine (asks for the password). Moves no data.":
      "암호화된 원격 저장소를 Mac과 머신에 추가합니다(암호를 묻습니다). 데이터는 옮기지 않습니다.",
    "Again: ":
      "다시 한 번: ",
    "Copies the plain backup into the encrypted folder, in the background; backups go on.":
      "암호화되지 않은 백업을 백그라운드에서 암호화된 폴더로 복사합니다. 백업은 계속됩니다.",
    "Copy:             %@":
      "복사:             %@",
    "CLOUDMACHINE_VM_INSTANCE=%@ without CLOUDMACHINE_VM_REMOTE would use the live backup's folder - set both.":
      "CLOUDMACHINE_VM_INSTANCE=%@을(를) CLOUDMACHINE_VM_REMOTE 없이 쓰면 사용 중인 백업의 폴더를 쓰게 됩니다 - 둘 다 설정하십시오.",
    "Could not add the remote to %@: %@":
      "%@에 원격 저장소를 추가할 수 없습니다: %@",
    "Could not add the remote to the machine's rclone.conf.":
      "머신의 rclone.conf에 원격 저장소를 추가할 수 없습니다.",
    "Could not read %@.":
      "%@을(를) 읽을 수 없습니다.",
    "Could not read when Time Machine last finished a backup (Full Disk Access?) - not deleting.":
      "Time Machine이 마지막으로 백업을 완료한 시각을 읽을 수 없습니다(전체 디스크 접근 권한?) - 삭제하지 않습니다.",
    "Could not start the copy: %@":
      "복사를 시작할 수 없습니다: %@",
    "Could not write %@.":
      "%@에 쓸 수 없습니다.",
    "Deleting the plain folder failed: %@":
      "암호화되지 않은 폴더 삭제에 실패했습니다: %@",
    "Encrypted folder: %@":
      "암호화된 폴더:    %@",
    "Encryption password: ":
      "암호화 암호: ",
    "Machine uses:     %@":
      "머신 사용 폴더:   %@",
    "Moves the backup on Google Drive under rclone encryption: setup, copy, switch, then delete-plain.":
      "Google Drive의 백업을 rclone 암호화 아래로 옮깁니다: setup, copy, switch, 그다음 delete-plain.",
    "Moves the plain folder to Google Drive's bin - only after a backup has finished into the encrypted one.":
      "암호화되지 않은 폴더를 Google Drive 휴지통으로 옮깁니다 - 암호화된 폴더로의 백업이 완료된 후에만.",
    "Moving the machine failed; it went back to %@: %@":
      "머신 전환에 실패했습니다. %@(으)로 돌아갔습니다: %@",
    "No answer from rclone in the machine - the upload queue is unknown.":
      "머신의 rclone에서 응답이 없습니다 - 업로드 대기열 상태를 알 수 없습니다.",
    "No backup has finished into the encrypted folder yet (last one %@, switched %@) - not deleting.":
      "암호화된 폴더로 완료된 백업이 아직 없습니다(마지막 %@, 전환 %@) - 삭제하지 않습니다.",
    "Not everything is on Google Drive yet (%@ MB unsent, %@ uploading, %@ failed). Wait until the upload is done: cloudmachine-agent vm-status":
      "아직 모든 것이 Google Drive에 있지는 않습니다(%@ MB 미전송, %@개 업로드 중, %@개 실패). 업로드가 끝날 때까지 기다리십시오: cloudmachine-agent vm-status",
    "Restore a file from the encrypted backup first (Time Machine, Browse), then confirm with --restore-checked.":
      "먼저 암호화된 백업에서 파일을 하나 복원한 다음(Time Machine, 둘러보기) --restore-checked로 확인하십시오.",
    "Shows which folder the machine uses and the copy.":
      "머신이 사용하는 폴더와 복사 상태를 표시합니다.",
    "Switched:         %@":
      "전환:             %@",
    "The copy is already running - see: cloudmachine-agent vm-encrypt status":
      "복사가 이미 실행 중입니다 - 확인: cloudmachine-agent vm-encrypt status",
    "The copy runs in the machine (%@, log %@). Backups go on meanwhile. Check: cloudmachine-agent vm-encrypt status":
      "복사가 머신에서 실행 중입니다(%@, 로그 %@). 그동안 백업은 계속됩니다. 확인: cloudmachine-agent vm-encrypt status",
    "The copy to the encrypted folder has not finished well (%@) - run: cloudmachine-agent vm-encrypt copy, and wait for it.":
      "암호화된 폴더로의 복사가 제대로 끝나지 않았습니다(%@) - 실행: cloudmachine-agent vm-encrypt copy 후 끝날 때까지 기다리십시오.",
    "The encryption password and salt are kept outside this Mac.":
      "암호화 암호와 솔트는 이 Mac 밖에 보관되어 있습니다.",
    "The guard holds Time Machine paused and would resume it during the switch. Wait until it resumes and the upload is done.":
      "버퍼 가드가 Time Machine을 일시 정지 상태로 두고 있으며 전환 중에 재개하게 됩니다. 재개되고 업로드가 끝날 때까지 기다리십시오.",
    "The image metadata has not been copied to the encrypted folder since the last backup - not deleting.":
      "마지막 백업 이후 이미지 메타데이터가 암호화된 폴더로 복사되지 않았습니다 - 삭제하지 않습니다.",
    "The last sync or cryptcheck failed - the machine was NOT moved: %@":
      "마지막 동기화 또는 cryptcheck에 실패했습니다 - 머신을 전환하지 않았습니다: %@",
    "The machine already uses the encrypted folder - nothing to switch.":
      "머신이 이미 암호화된 폴더를 사용합니다 - 전환할 것이 없습니다.",
    "The machine already uses the encrypted folder.":
      "머신이 이미 암호화된 폴더를 사용합니다.",
    "The machine does not use the encrypted folder - nothing to roll back.":
      "머신이 암호화된 폴더를 사용하지 않습니다 - 되돌릴 것이 없습니다.",
    "The machine does not use the encrypted folder - the plain folder is the backup. Not deleting it.":
      "머신이 암호화된 폴더를 사용하지 않습니다 - 암호화되지 않은 폴더가 백업입니다. 삭제하지 않습니다.",
    "The machine has no '%@' remote in its rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "머신의 rclone.conf에 원격 저장소 '%@'이(가) 없습니다 - 실행: cloudmachine-agent vm-encrypt setup",
    "The machine is not on this app's template or does not use %@ (cloudmachine-agent vm-update first): %@":
      "머신이 이 앱의 템플릿이 아니거나 %@을(를) 사용하지 않습니다(먼저 cloudmachine-agent vm-update): %@",
    "The machine now uses %@, but %@ could not be updated (%@) - fix it before anything else runs vm-setup.":
      "머신이 이제 %@을(를) 사용하지만 %@을(를) 업데이트할 수 없습니다(%@) - 다른 무엇이 vm-setup을 실행하기 전에 고치십시오.",
    "The machine now uses %@. %@ is kept. Turn automatic backups back on: sudo tmutil enable":
      "머신이 이제 %@을(를) 사용합니다. %@은(는) 남겨 둡니다. 자동 백업을 다시 켜십시오: sudo tmutil enable",
    "The password must have at least 12 characters.":
      "암호는 12자 이상이어야 합니다.",
    "The passwords differ - nothing was changed.":
      "암호가 서로 다릅니다 - 아무것도 바꾸지 않았습니다.",
    "The switch the other way: decrypts what changed back into the plain folder and uses it again.":
      "반대 방향 전환: 변경된 부분을 암호화되지 않은 폴더로 복호화하고 다시 그 폴더를 사용합니다.",
    "The upload to the encrypted folder is not finished (or rclone did not answer) - not deleting.":
      "암호화된 폴더로의 업로드가 끝나지 않았습니다(또는 rclone이 응답하지 않았습니다) - 삭제하지 않습니다.",
    "Time Machine is backing up. Turn automatic backups off (sudo tmutil disable), stop it (tmutil stopbackup), then run this again.":
      "Time Machine이 백업 중입니다. 자동 백업을 끄고(sudo tmutil disable), 중지한 다음(tmutil stopbackup) 이 명령을 다시 실행하십시오.",
    "With Time Machine stopped: last sync, cryptcheck, then the machine uses the encrypted folder. The plain one stays.":
      "Time Machine을 중지한 상태에서: 마지막 동기화, cryptcheck, 그다음 머신이 암호화된 폴더를 사용합니다. 암호화되지 않은 폴더는 남습니다.",
    "Without the encryption password and salt the encrypted backup cannot be read. Keep both outside this Mac (a password manager, paper), then confirm with --secrets-saved-elsewhere.":
      "암호화 암호와 솔트가 없으면 암호화된 백업을 읽을 수 없습니다. 둘 다 이 Mac 밖(암호 관리자, 종이)에 보관한 다음 --secrets-saved-elsewhere로 확인하십시오.",
    "rclone obscure failed.":
      "rclone obscure에 실패했습니다.",
    "tmutil did not answer - not switching while Time Machine's state is unknown.":
      "tmutil이 응답하지 않습니다 - Time Machine 상태를 알 수 없는 동안에는 전환하지 않습니다.",
  ]
}
