// Thai translations of vm-encrypt (DriveEncryption), keyed by the English text.
extension L10nTranslations {
  static let thEncryption: [String: String] = [
    "%@ and its metadata are in Google Drive's bin (kept 30 days, still counted in the quota).":
      "%@ และข้อมูลเมตาอยู่ในถังขยะของ Google Drive (เก็บไว้ 30 วัน และยังนับรวมในโควตา)",
    "'%@' is already in %@ - not replacing its password.":
      "'%@' มีอยู่แล้วใน %@ - จะไม่แทนที่รหัสผ่าน",
    "'%@' is already in the machine's rclone.conf - not replacing its password.":
      "'%@' มีอยู่แล้วใน rclone.conf ของเครื่องเสมือน - จะไม่แทนที่รหัสผ่าน",
    "%@ holds folders this key cannot read: another password or salt in the machine, or leftovers of an earlier try. Compare the machine's rclone.conf with the Mac's; leftovers have to be removed from %@ by hand.":
      "%@ มีโฟลเดอร์ที่คีย์นี้อ่านไม่ได้: รหัสผ่านหรือซอลต์ในเครื่องเสมือนต่างกัน หรือเป็นเศษจากการลองครั้งก่อน ให้เปรียบเทียบ rclone.conf ของเครื่องเสมือนกับของ Mac ส่วนเศษที่เหลือต้องลบออกจาก %@ ด้วยตนเอง",
    "'%@' is incomplete or missing in the Mac's rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "'%@' ไม่สมบูรณ์หรือไม่มีใน rclone.conf ของ Mac - เรียกใช้: cloudmachine-agent vm-encrypt setup",
    "CLOUDMACHINE_VM_INSTANCE=%@ needs its own rclone.conf - set RCLONE_CONFIG to a copy, not %@. Its Keychain entry is service %@.":
      "CLOUDMACHINE_VM_INSTANCE=%@ ต้องมี rclone.conf ของตัวเอง - ตั้ง RCLONE_CONFIG เป็นสำเนา ไม่ใช่ %@ รายการในพวงกุญแจของอินสแตนซ์นี้คือบริการ %@",
    "Could not read the '%@' section on the Mac or in the machine.":
      "อ่านส่วน '%@' บน Mac หรือในเครื่องเสมือนไม่ได้",
    "The machine's '%@' (password, salt or folder) differs from the Mac's - the copy would be readable only with the machine's key. Not moving anything.":
      "'%@' ของเครื่องเสมือน (รหัสผ่าน ซอลต์ หรือโฟลเดอร์) ต่างจากของ Mac - สำเนาจะอ่านได้ด้วยคีย์ของเครื่องเสมือนเท่านั้น จะไม่ย้ายอะไร",
    "A file was restored from the encrypted backup.":
      "กู้คืนไฟล์จากข้อมูลสำรองที่เข้ารหัสแล้ว",
    "Added '%@' (%@) on the Mac and in the machine; password and salt are in the Keychain (service %@).\nSALT: %@\nKeep the password AND this salt outside this Mac now - without both the encrypted backup cannot be read. Next: cloudmachine-agent vm-encrypt copy":
      "เพิ่ม '%@' (%@) บน Mac และในเครื่องเสมือนแล้ว รหัสผ่านและซอลต์อยู่ในพวงกุญแจ (บริการ %@)\nซอลต์: %@\nเก็บรหัสผ่านและซอลต์นี้ไว้นอก Mac เครื่องนี้ตอนนี้เลย - หากไม่มีทั้งสองอย่างจะอ่านข้อมูลสำรองที่เข้ารหัสไม่ได้ ถัดไป: cloudmachine-agent vm-encrypt copy",
    "Adds the encrypted remote on the Mac and in the machine (asks for the password). Moves no data.":
      "เพิ่ม remote ที่เข้ารหัสบน Mac และในเครื่องเสมือน (ถามรหัสผ่าน) ไม่ย้ายข้อมูล",
    "Again: ":
      "อีกครั้ง: ",
    "Copies the plain backup into the encrypted folder, in the background; backups go on.":
      "คัดลอกข้อมูลสำรองที่ไม่เข้ารหัสไปยังโฟลเดอร์ที่เข้ารหัสในเบื้องหลัง การสำรองข้อมูลยังดำเนินต่อไป",
    "Copy:             %@":
      "การคัดลอก:        %@",
    "CLOUDMACHINE_VM_INSTANCE=%@ without CLOUDMACHINE_VM_REMOTE would use the live backup's folder - set both.":
      "CLOUDMACHINE_VM_INSTANCE=%@ ที่ไม่มี CLOUDMACHINE_VM_REMOTE จะใช้โฟลเดอร์ของข้อมูลสำรองที่ใช้งานอยู่ - ตั้งค่าทั้งสองตัว",
    "Could not add the remote to %@: %@":
      "เพิ่ม remote ลงใน %@ ไม่ได้: %@",
    "Could not add the remote to the machine's rclone.conf.":
      "เพิ่ม remote ลงใน rclone.conf ของเครื่องเสมือนไม่ได้",
    "Could not read %@.":
      "อ่าน %@ ไม่ได้",
    "Could not read when Time Machine last finished a backup (Full Disk Access?) - not deleting.":
      "อ่านไม่ได้ว่า Time Machine สำรองข้อมูลเสร็จครั้งล่าสุดเมื่อใด (การเข้าถึงดิสก์แบบเต็ม?) - จะไม่ลบอะไร",
    "Could not start the copy: %@":
      "เริ่มการคัดลอกไม่ได้: %@",
    "Could not write %@.":
      "เขียน %@ ไม่ได้",
    "Deleting the plain folder failed: %@":
      "ลบโฟลเดอร์ที่ไม่เข้ารหัสไม่สำเร็จ: %@",
    "Encrypted folder: %@":
      "โฟลเดอร์เข้ารหัส: %@",
    "Encryption password: ":
      "รหัสผ่านการเข้ารหัส: ",
    "Machine uses:     %@":
      "เครื่องเสมือนใช้:  %@",
    "Moves the backup on Google Drive under rclone encryption: setup, copy, switch, then delete-plain.":
      "ย้ายข้อมูลสำรองบน Google Drive ไปอยู่ใต้การเข้ารหัสของ rclone: setup, copy, switch แล้วจึง delete-plain",
    "Moves the plain folder to Google Drive's bin - only after a backup has finished into the encrypted one.":
      "ย้ายโฟลเดอร์ที่ไม่เข้ารหัสไปยังถังขยะของ Google Drive - หลังจากสำรองข้อมูลลงโฟลเดอร์ที่เข้ารหัสเสร็จแล้วเท่านั้น",
    "Moving the machine failed; it went back to %@: %@":
      "การย้ายเครื่องเสมือนไปยังโฟลเดอร์ใหม่ไม่สำเร็จ จึงกลับไปใช้ %@: %@",
    "No answer from rclone in the machine - the upload queue is unknown.":
      "ไม่มีคำตอบจาก rclone ในเครื่องเสมือน - ไม่ทราบสถานะคิวอัปโหลด",
    "No backup has finished into the encrypted folder yet (last one %@, switched %@) - not deleting.":
      "ยังไม่มีการสำรองข้อมูลใดเสร็จในโฟลเดอร์ที่เข้ารหัส (ล่าสุด %@ สลับเมื่อ %@) - จะไม่ลบอะไร",
    "Not everything is on Google Drive yet (%@ MB unsent, %@ uploading, %@ failed). Wait until the upload is done: cloudmachine-agent vm-status":
      "ยังไม่ได้อยู่บน Google Drive ทั้งหมด (%@ MB ยังไม่ส่ง, %@ กำลังอัปโหลด, %@ ล้มเหลว) รอจนอัปโหลดเสร็จ: cloudmachine-agent vm-status",
    "Restore a file from the encrypted backup first (Time Machine, Browse), then confirm with --restore-checked.":
      "กู้คืนไฟล์จากข้อมูลสำรองที่เข้ารหัสก่อน (Time Machine, เลือกดู) แล้วยืนยันด้วย --restore-checked",
    "Shows which folder the machine uses and the copy.":
      "แสดงว่าเครื่องเสมือนใช้โฟลเดอร์ใดและสถานะการคัดลอก",
    "Switched:         %@":
      "สลับเมื่อ:        %@",
    "The copy is already running - see: cloudmachine-agent vm-encrypt status":
      "การคัดลอกกำลังทำงานอยู่แล้ว - ดู: cloudmachine-agent vm-encrypt status",
    "The copy runs in the machine (%@, log %@). Backups go on meanwhile. Check: cloudmachine-agent vm-encrypt status":
      "การคัดลอกทำงานในเครื่องเสมือน (%@, บันทึก %@) ระหว่างนี้การสำรองข้อมูลยังดำเนินต่อไป ตรวจสอบ: cloudmachine-agent vm-encrypt status",
    "The copy to the encrypted folder has not finished well (%@) - run: cloudmachine-agent vm-encrypt copy, and wait for it.":
      "การคัดลอกไปยังโฟลเดอร์ที่เข้ารหัสไม่เสร็จสมบูรณ์ (%@) - เรียกใช้: cloudmachine-agent vm-encrypt copy แล้วรอให้เสร็จ",
    "The encryption password and salt are kept outside this Mac.":
      "รหัสผ่านการเข้ารหัสและซอลต์เก็บไว้นอก Mac เครื่องนี้",
    "The guard holds Time Machine paused and would resume it during the switch. Wait until it resumes and the upload is done.":
      "ตัวป้องกันบัฟเฟอร์กำลังหยุด Time Machine ไว้ชั่วคราว และจะให้ทำงานต่อระหว่างการสลับ รอจนกว่า Time Machine จะกลับมาทำงานและอัปโหลดเสร็จ",
    "The image metadata has not been copied to the encrypted folder since the last backup - not deleting.":
      "ข้อมูลเมตาของอิมเมจยังไม่ถูกคัดลอกไปยังโฟลเดอร์ที่เข้ารหัสตั้งแต่การสำรองข้อมูลครั้งล่าสุด - จะไม่ลบอะไร",
    "The last sync or cryptcheck failed - the machine was NOT moved: %@":
      "การซิงค์ครั้งสุดท้ายหรือ cryptcheck ล้มเหลว - ไม่ได้ย้ายเครื่องเสมือนไปยังโฟลเดอร์ที่เข้ารหัส: %@",
    "The machine already uses the encrypted folder - nothing to switch.":
      "เครื่องเสมือนใช้โฟลเดอร์ที่เข้ารหัสอยู่แล้ว - ไม่มีอะไรต้องสลับ",
    "The machine already uses the encrypted folder.":
      "เครื่องเสมือนใช้โฟลเดอร์ที่เข้ารหัสอยู่แล้ว",
    "The machine does not use the encrypted folder - nothing to roll back.":
      "เครื่องเสมือนไม่ได้ใช้โฟลเดอร์ที่เข้ารหัส - ไม่มีอะไรต้องย้อนกลับ",
    "The machine does not use the encrypted folder - the plain folder is the backup. Not deleting it.":
      "เครื่องเสมือนไม่ได้ใช้โฟลเดอร์ที่เข้ารหัส - โฟลเดอร์ที่ไม่เข้ารหัสคือข้อมูลสำรอง จะไม่ลบ",
    "The machine has no '%@' remote in its rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "เครื่องเสมือนไม่มี remote '%@' ใน rclone.conf - เรียกใช้: cloudmachine-agent vm-encrypt setup",
    "The machine is not on this app's template or does not use %@ (cloudmachine-agent vm-update first): %@":
      "เครื่องเสมือนไม่ได้ใช้เทมเพลตของแอปนี้ หรือไม่ได้ใช้ %@ (ทำ cloudmachine-agent vm-update ก่อน): %@",
    "The machine now uses %@, but %@ could not be updated (%@) - fix it before anything else runs vm-setup.":
      "ตอนนี้เครื่องเสมือนใช้ %@ แต่อัปเดต %@ ไม่ได้ (%@) - แก้ไขก่อนที่จะมีการเรียกใช้ vm-setup อีก",
    "The machine now uses %@. %@ is kept. Turn automatic backups back on: sudo tmutil enable":
      "ตอนนี้เครื่องเสมือนใช้ %@ และเก็บ %@ ไว้ เปิดการสำรองข้อมูลอัตโนมัติอีกครั้ง: sudo tmutil enable",
    "The password must have at least 12 characters.":
      "รหัสผ่านต้องมีอย่างน้อย 12 ตัวอักษร",
    "The passwords differ - nothing was changed.":
      "รหัสผ่านไม่ตรงกัน - ไม่ได้เปลี่ยนแปลงอะไร",
    "The switch the other way: decrypts what changed back into the plain folder and uses it again.":
      "การสลับในทิศทางกลับ: ถอดรหัสส่วนที่เปลี่ยนกลับไปยังโฟลเดอร์ที่ไม่เข้ารหัสแล้วใช้โฟลเดอร์นั้นอีกครั้ง",
    "The upload to the encrypted folder is not finished (or rclone did not answer) - not deleting.":
      "การอัปโหลดไปยังโฟลเดอร์ที่เข้ารหัสยังไม่เสร็จ (หรือ rclone ไม่ตอบ) - จะไม่ลบอะไร",
    "Time Machine is backing up. Turn automatic backups off (sudo tmutil disable), stop it (tmutil stopbackup), then run this again.":
      "Time Machine กำลังสำรองข้อมูล ปิดการสำรองข้อมูลอัตโนมัติ (sudo tmutil disable) หยุดการทำงาน (tmutil stopbackup) แล้วเรียกใช้คำสั่งนี้อีกครั้ง",
    "With Time Machine stopped: last sync, cryptcheck, then the machine uses the encrypted folder. The plain one stays.":
      "เมื่อหยุด Time Machine แล้ว: ซิงค์ครั้งสุดท้าย, cryptcheck แล้วเครื่องเสมือนจะใช้โฟลเดอร์ที่เข้ารหัส โฟลเดอร์ที่ไม่เข้ารหัสยังอยู่",
    "Without the encryption password and salt the encrypted backup cannot be read. Keep both outside this Mac (a password manager, paper), then confirm with --secrets-saved-elsewhere.":
      "หากไม่มีรหัสผ่านการเข้ารหัสและซอลต์จะอ่านข้อมูลสำรองที่เข้ารหัสไม่ได้ เก็บทั้งสองไว้นอก Mac เครื่องนี้ (ตัวจัดการรหัสผ่าน, กระดาษ) แล้วยืนยันด้วย --secrets-saved-elsewhere",
    "rclone obscure failed.":
      "rclone obscure ล้มเหลว",
    "tmutil did not answer - not switching while Time Machine's state is unknown.":
      "tmutil ไม่ตอบ - จะไม่สลับขณะที่ไม่ทราบสถานะของ Time Machine",
  ]
}
