// Thai translations, keyed by the English text passed to `L10n.tr`.
extension L10nTranslations {
  static let th: [String: String] = [
    "Space limit:      %@":
      "ขีดจำกัดพื้นที่:   %@",
    "                  Time Machine quota not set to match - run: %@":
      "                  โควตา Time Machine ยังไม่ตรงกัน - เรียกใช้: %@",
    "Sets how much of Google Drive this Mac may use, and prints the Time Machine quota command.":
      "กำหนดพื้นที่ Google Drive ที่ Mac เครื่องนี้ใช้ได้ และพิมพ์คำสั่งโควตา Time Machine",
    "Limit in GB.":
      "ขีดจำกัดเป็น GB",
    "Limit for this Mac: %@ GB.":
      "ขีดจำกัดสำหรับ Mac เครื่องนี้: %@ GB",
    "Now set the Time Machine quota (needs an administrator password):":
      "ตอนนี้ให้ตั้งโควตา Time Machine (ต้องใช้รหัสผ่านผู้ดูแลระบบ):",
    "CloudMachine - verification, Google Drive setup and installation. Called by launchd on a schedule, or by hand from Terminal.":
      "CloudMachine - การตรวจสอบ การตั้งค่า Google Drive และการติดตั้ง launchd เรียกใช้ตามกำหนดเวลา หรือเรียกด้วยตนเองจากเทอร์มินัล",
    "Connects to Google Drive through rclone (OAuth in the browser) and creates this machine's folder.":
      "เชื่อมต่อกับ Google Drive ผ่าน rclone (OAuth ในเบราว์เซอร์) และสร้างโฟลเดอร์ของเครื่องเสมือนนี้",
    "Overwrite the existing remote. RISKY: replaces the token and permissions.":
      "เขียนทับ remote ที่มีอยู่ เสี่ยง: จะแทนที่โทเค็นและสิทธิ์",
    "Packs build/CloudMachine.app into build/CloudMachine-<version>.dmg.":
      "แพ็ก build/CloudMachine.app เป็น build/CloudMachine-<version>.dmg",
    "ERROR: %@ is missing - run 'cloudmachine-agent build-app' first":
      "ข้อผิดพลาด: ไม่พบ %@ - เรียกใช้ 'cloudmachine-agent build-app' ก่อน",
    "==> Preparing the staging folder":
      "==> กำลังเตรียมโฟลเดอร์สเตจจิ้ง",
    "==> Creating %@":
      "==> กำลังสร้าง %@",
    "ERROR: hdiutil exited with code %@.":
      "ข้อผิดพลาด: hdiutil จบการทำงานด้วยรหัส %@",
    "==> Done: %@":
      "==> เสร็จสิ้น: %@",
    "On first launch (the app is not signed with an Apple Developer account):":
      "เมื่อเปิดครั้งแรก (แอปนี้ไม่ได้ลงนามด้วยบัญชี Apple Developer):",
    "1. Open %@ and drag CloudMachine.app to Applications.":
      "1. เปิด %@ แล้วลาก CloudMachine.app ไปที่โฟลเดอร์แอปพลิเคชัน",
    "2. In Finder, RIGHT-click CloudMachine.app -> Open -> Open\n   (a plain double-click shows the Gatekeeper block \"unidentified developer\").":
      "2. ใน Finder ให้คลิกขวาที่ CloudMachine.app -> เปิด -> เปิด\n   (การดับเบิลคลิกตามปกติจะแสดงการบล็อกของ Gatekeeper \"ไม่ทราบผู้พัฒนา\")",
    "3. Later launches work normally, with a double-click.":
      "3. การเปิดครั้งต่อไปทำงานตามปกติ ด้วยการดับเบิลคลิก",
    "Builds CloudMachine.app (Release) - GUI + cloudmachine-agent in Contents/MacOS/, plus launchd/, vm/ and config/ as Resources.":
      "สร้าง CloudMachine.app (Release) - GUI + cloudmachine-agent ใน Contents/MacOS/ พร้อม launchd/, vm/ และ config/ เป็น Resources",
    "Binaries for Apple Silicon and Intel at once (how CI builds a release; unnecessary locally).":
      "ไบนารีสำหรับ Apple Silicon และ Intel พร้อมกัน (วิธีที่ CI สร้างรุ่นที่เผยแพร่ ไม่จำเป็นในเครื่อง)",
    "==> Building CloudMachineApp + cloudmachine-agent (release) - version %@ (%@)":
      "==> กำลังสร้าง CloudMachineApp + cloudmachine-agent (release) - เวอร์ชัน %@ (%@)",
    "ERROR: swift build exited with code %@.":
      "ข้อผิดพลาด: swift build จบการทำงานด้วยรหัส %@",
    "ERROR: swift build --show-bin-path did not report the binaries directory.":
      "ข้อผิดพลาด: swift build --show-bin-path ไม่รายงานไดเรกทอรีของไบนารี",
    "ERROR: no built binary found at %@":
      "ข้อผิดพลาด: ไม่พบไบนารีที่สร้างไว้ที่ %@",
    "==> Assembling the .app bundle in %@":
      "==> กำลังประกอบชุดแอป .app ใน %@",
    "==> WARNING: you are building from a DIRTY tree - the version will not point to a commit.":
      "==> คำเตือน: คุณกำลังสร้างจากต้นไม้ที่ยัง \"สกปรก\" (มีการเปลี่ยนแปลงที่ยังไม่คอมมิต) - เวอร์ชันจะไม่ชี้ไปที่คอมมิตใด",
    "ERROR: Resources/AppIcon.icns is missing - generate it: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns":
      "ข้อผิดพลาด: ไม่พบ Resources/AppIcon.icns - สร้างด้วย: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns",
    "==> Signing with the local certificate '%@' (Full Disk Access will survive later rebuilds)":
      "==> กำลังลงนามด้วยใบรับรองในเครื่อง '%@' (การเข้าถึงดิสก์แบบเต็มจะยังคงอยู่หลังการสร้างใหม่)",
    "==> Signing ad-hoc (no Apple Developer account) - run 'cloudmachine-agent setup-signing-cert' once so that TCC permissions survive later rebuilds":
      "==> กำลังลงนามแบบ ad-hoc (ไม่มีบัญชี Apple Developer) - เรียกใช้ 'cloudmachine-agent setup-signing-cert' หนึ่งครั้ง เพื่อให้สิทธิ์ TCC ยังคงอยู่หลังการสร้างใหม่",
    "ERROR: codesign exited with code %@.":
      "ข้อผิดพลาด: codesign จบการทำงานด้วยรหัส %@",
    "Next step: %@":
      "ขั้นตอนถัดไป: %@",
    "Creates a local self-signed certificate so that Full Disk Access survives later rebuilds of the app.":
      "สร้างใบรับรองที่ลงนามด้วยตนเองในเครื่อง เพื่อให้การเข้าถึงดิสก์แบบเต็มยังคงอยู่หลังการสร้างแอปใหม่",
    "Certificate '%@' already exists in %@, nothing to do.":
      "ใบรับรอง '%@' มีอยู่แล้วใน %@ ไม่ต้องดำเนินการใด ๆ",
    "==> Generating the key and self-signed certificate '%@'...":
      "==> กำลังสร้างคีย์และใบรับรองที่ลงนามด้วยตนเอง '%@'...",
    "ERROR: openssl req exited with code %@.":
      "ข้อผิดพลาด: openssl req จบการทำงานด้วยรหัส %@",
    "ERROR: openssl pkcs12 exited with code %@.":
      "ข้อผิดพลาด: openssl pkcs12 จบการทำงานด้วยรหัส %@",
    "==> Importing the certificate into %@ (pre-authorizing /usr/bin/codesign, so it does not ask for the keychain password every time)...":
      "==> กำลังนำเข้าใบรับรองไปยัง %@ (อนุญาต /usr/bin/codesign ล่วงหน้า เพื่อไม่ให้ขอรหัสผ่านพวงกุญแจทุกครั้ง)...",
    "ERROR: security import exited with code %@.":
      "ข้อผิดพลาด: security import จบการทำงานด้วยรหัส %@",
    "==> Trusting the certificate ONLY for code signing...":
      "==> กำลังเชื่อถือใบรับรองสำหรับการลงนามโค้ดเท่านั้น...",
    "ERROR: security add-trusted-cert exited with code %@.":
      "ข้อผิดพลาด: security add-trusted-cert จบการทำงานด้วยรหัส %@",
    "Done. Certificate '%@' is now available to codesign.":
      "เสร็จสิ้น ใบรับรอง '%@' พร้อมให้ codesign ใช้งานแล้ว",
    "The next 'cloudmachine-agent build-app' will use it automatically instead of an ad-hoc signature.":
      "'cloudmachine-agent build-app' ครั้งถัดไปจะใช้ใบรับรองนี้โดยอัตโนมัติแทนลายเซ็น ad-hoc",
    "After THAT ONE rebuild, grant Full Disk Access one last time - later\nrebuilds will no longer reset it, as long as you sign with the same certificate.":
      "หลังจากการสร้างใหม่ครั้งนั้นเพียงครั้งเดียว ให้อนุญาตการเข้าถึงดิสก์แบบเต็มอีกครั้งเป็นครั้งสุดท้าย - การสร้างใหม่\nครั้งต่อไปจะไม่รีเซ็ตสิทธิ์นี้อีก ตราบใดที่ลงนามด้วยใบรับรองเดิม",
    "Checks whether the hourly cycle STILL works (date of the last SUCCESSFUL backup) and reports failures.":
      "ตรวจสอบว่ารอบรายชั่วโมงยังทำงานอยู่หรือไม่ (วันที่ของการสำรองข้อมูลที่สำเร็จครั้งล่าสุด) และรายงานความล้มเหลว",
    "After this many hours without a successful backup we consider the cycle broken.":
      "หากผ่านไปตามจำนวนชั่วโมงนี้โดยไม่มีการสำรองข้อมูลที่สำเร็จ จะถือว่ารอบการทำงานเสีย",
    "Only print the state, without a system notification.":
      "พิมพ์เฉพาะสถานะ โดยไม่แจ้งเตือนจากระบบ",
    "A different Time Machine preferences file - to test the watchdog on a known sample.":
      "ไฟล์การตั้งค่า Time Machine อื่น - เพื่อทดสอบตัวเฝ้าระวังกับตัวอย่างที่ทราบ",
    "Last successful backup: %@":
      "การสำรองข้อมูลที่สำเร็จครั้งล่าสุด: %@",
    "Last successful backup: NONE":
      "การสำรองข้อมูลที่สำเร็จครั้งล่าสุด: ไม่มีเลย",
    "Last attempt:           %@":
      "ความพยายามครั้งล่าสุด:   %@",
    "WAITING (system startup): %@":
      "กำลังรอ (ระบบเพิ่งเริ่มทำงาน): %@",
    "Backup cycle: OK":
      "รอบการสำรองข้อมูล: ปกติ",
    "FAILURE: %@":
      "ล้มเหลว: %@",
    "         %@":
      "         %@",
    "Check the state:  %@":
      "ตรวจสอบสถานะ:  %@",
    "Preparing for restart":
      "กำลังเตรียมรีสตาร์ท",
    "Prepare for restart":
      "เตรียมรีสตาร์ท",
    "Prepare":
      "เตรียม",
    "==> WARNING: git rev-list failed (%@) - using the date as the build number.":
      "==> คำเตือน: git rev-list ล้มเหลว (%@) - ใช้วันที่เป็นหมายเลขบิลด์",
    "Agents:           %@":
      "เอเจนต์:          %@",
    "CANNOT START: %@ - open CloudMachine or run backup-health to reload them":
      "เริ่มไม่ได้: %@ - เปิด CloudMachine หรือเรียกใช้ backup-health เพื่อโหลดใหม่",
    "Reloaded agents that could not start: %@":
      "โหลดเอเจนต์ที่เริ่มไม่ได้ใหม่แล้ว: %@",
    "Drive folder:     %@":
      "โฟลเดอร์ Drive:   %@",
    "Name of this Mac's folder on Google Drive (default: derived from the computer name). Set once; it cannot be changed later.":
      "ชื่อโฟลเดอร์ของ Mac เครื่องนี้บน Google Drive (ค่าเริ่มต้น: ได้จากชื่อคอมพิวเตอร์) ตั้งครั้งเดียว และเปลี่ยนภายหลังไม่ได้",
    "Backup watchdog:  %@":
      "ตัวเฝ้าระวังการสำรองข้อมูล: %@",
    "Prints the version, the build number and the commit this binary was built from.":
      "พิมพ์เวอร์ชัน หมายเลขบิลด์ และคอมมิตที่ใช้สร้างไบนารีนี้",
    "Only one line, without a description.":
      "บรรทัดเดียว ไม่มีคำอธิบาย",
    "Build from the working tree (outside a bundle) - no version data.":
      "สร้างจากต้นไม้ทำงาน (นอกชุดแอป) - ไม่มีข้อมูลเวอร์ชัน",
    "Version: %@":
      "เวอร์ชัน: %@",
    "Build:   %@":
      "บิลด์:    %@",
    "Commit:  %@":
      "คอมมิต:   %@",
    "WARNING: built from a DIRTY tree - the binary contains code that\n         is in no commit. The commit number does NOT describe\n         what actually runs.":
      "คำเตือน: สร้างจากต้นไม้ที่ \"สกปรก\" - ไบนารีมีโค้ดที่\n         ไม่อยู่ในคอมมิตใดเลย หมายเลขคอมมิต\n         ไม่ได้อธิบายสิ่งที่กำลังทำงานอยู่จริง",
    "Saving the space limit":
      "กำลังบันทึกขีดจำกัดพื้นที่",
    "Measuring usage on Google Drive":
      "กำลังวัดการใช้งานบน Google Drive",
    "Google Drive did not answer - try again later.":
      "Google Drive ไม่ตอบสนอง - ลองอีกครั้งภายหลัง",
    "Measured.":
      "วัดแล้ว",
    "Space limit for this Mac":
      "ขีดจำกัดพื้นที่สำหรับ Mac เครื่องนี้",
    "Used on Google Drive":
      "ใช้ไปบน Google Drive",
    "Measured %@. The watchdog measures again every few hours.":
      "วัดเมื่อ %@ ตัวเฝ้าระวังจะวัดอีกครั้งทุกไม่กี่ชั่วโมง",
    "Limit (GB)":
      "ขีดจำกัด (GB)",
    "Save":
      "บันทึก",
    "Measure now":
      "วัดตอนนี้",
    "Time Machine quota: %@ GB (70%% of the limit - the copy on Drive is about a third larger than the backup inside it). Time Machine deletes the oldest backups to stay within it.":
      "โควตา Time Machine: %@ GB (70%% ของขีดจำกัด - สำเนาบน Drive ใหญ่กว่าข้อมูลสำรองข้างในประมาณหนึ่งในสาม) Time Machine จะลบข้อมูลสำรองที่เก่าที่สุดเพื่อให้อยู่ในโควตา",
    "Set the Time Machine quota: run this in Terminal (needs sudo)":
      "ตั้งโควตา Time Machine: เรียกใช้คำสั่งนี้ในเทอร์มินัล (ต้องใช้ sudo)",
    "Connect Google Drive: run this in Terminal and approve in the browser":
      "เชื่อมต่อ Google Drive: เรียกใช้คำสั่งนี้ในเทอร์มินัลแล้วอนุมัติในเบราว์เซอร์",
    "Grant Full Disk Access to CloudMachine, so it can tell whether backups complete":
      "อนุญาตการเข้าถึงดิสก์แบบเต็มให้ CloudMachine เพื่อให้ทราบได้ว่าการสำรองข้อมูลเสร็จสมบูรณ์หรือไม่",
    "Folder on Google Drive":
      "โฟลเดอร์บน Google Drive",
    "One folder per Mac. Set once - it cannot be changed after connecting.":
      "หนึ่งโฟลเดอร์ต่อ Mac หนึ่งเครื่อง ตั้งครั้งเดียว - เปลี่ยนไม่ได้หลังจากเชื่อมต่อแล้ว",
    "Use lowercase letters, digits and dashes.":
      "ใช้ตัวพิมพ์เล็ก ตัวเลข และขีดกลาง",
    "Install rclone":
      "ติดตั้ง rclone",
    "Open System Settings":
      "เปิดการตั้งค่าระบบ",
    "Install agents":
      "ติดตั้งเอเจนต์",
    "not checked":
      "ยังไม่ได้ตรวจสอบ",
    "none at all":
      "ไม่มีเลย",
    "%@ ago":
      "%@ ที่แล้ว",
    "Missing: %@":
      "ขาดหายไป: %@",
    "Google Drive not connected":
      "ยังไม่ได้เชื่อมต่อ Google Drive",
    "Time Machine does not point to CloudMachine":
      "Time Machine ไม่ได้ชี้ไปที่ CloudMachine",
    "UNKNOWN whether Time Machine points to CloudMachine - tmutil did not answer":
      "ไม่ทราบว่า Time Machine ชี้ไปที่ CloudMachine หรือไม่ - tmutil ไม่ตอบสนอง",
    "Backup in progress":
      "กำลังสำรองข้อมูล",
    "Unknown when the last backup was made":
      "ไม่ทราบว่าสำรองข้อมูลครั้งล่าสุดเมื่อใด",
    "There is no completed backup at all":
      "ไม่มีการสำรองข้อมูลที่เสร็จสมบูรณ์เลย",
    "No completed backup for %@":
      "ไม่มีการสำรองข้อมูลที่เสร็จสมบูรณ์เป็นเวลา %@",
    "Ready":
      "พร้อม",
    "Not saved: %@":
      "ไม่ได้บันทึก: %@",
    "Installing rclone":
      "กำลังติดตั้ง rclone",
    "Installing launchd agents":
      "กำลังติดตั้งเอเจนต์ launchd",
    "Starting backup":
      "กำลังเริ่มการสำรองข้อมูล",
    "Backup started.":
      "เริ่มการสำรองข้อมูลแล้ว",
    "Could not start the backup.":
      "เริ่มการสำรองข้อมูลไม่ได้",
    "Stopping backup":
      "กำลังหยุดการสำรองข้อมูล",
    "Backup stopped.":
      "หยุดการสำรองข้อมูลแล้ว",
    "Could not stop the backup.":
      "หยุดการสำรองข้อมูลไม่ได้",
    "Could not prepare the AppleScript.":
      "เตรียม AppleScript ไม่ได้",
    "Unknown authorization error.":
      "ข้อผิดพลาดการอนุญาตที่ไม่ทราบสาเหตุ",
    "Waiting to upload":
      "รออัปโหลด",
    "%@ files":
      "%@ ไฟล์",
    "nothing":
      "ไม่มี",
    "Back up now":
      "สำรองข้อมูลตอนนี้",
    "Stop backup":
      "หยุดการสำรองข้อมูล",
    "Open CloudMachine":
      "เปิด CloudMachine",
    "Quit":
      "ออก",
    "Healthy":
      "ปกติ",
    "Attention":
      "ต้องดูแล",
    "Refreshed %@":
      "รีเฟรชเมื่อ %@",
    "System Status":
      "สถานะระบบ",
    "Action needed":
      "ต้องดำเนินการ",
    "not measured":
      "ยังไม่ได้วัด",
    "rclone did not answer":
      "rclone ไม่ตอบสนอง",
    "Backup in Progress":
      "กำลังสำรองข้อมูล",
    "Files processed":
      "ไฟล์ที่ประมวลผลแล้ว",
    "Write speed":
      "ความเร็วในการเขียน",
    "Operation phase":
      "ขั้นตอนการทำงาน",
    "Required Setup Steps":
      "ขั้นตอนการตั้งค่าที่จำเป็น",
    "Copy":
      "คัดลอก",
    "Last completed backup":
      "การสำรองข้อมูลที่เสร็จสมบูรณ์ครั้งล่าสุด",
    "Last backup watchdog run":
      "การทำงานของตัวเฝ้าระวังการสำรองข้อมูลครั้งล่าสุด",
    "not read":
      "ยังไม่ได้อ่าน",
    "Everything uploaded":
      "อัปโหลดครบทั้งหมดแล้ว",
    "File upload errors":
      "ข้อผิดพลาดในการอัปโหลดไฟล์",
    "Google Drive Credentials (OAuth 2.0)":
      "ข้อมูลรับรอง Google Drive (OAuth 2.0)",
    "Keychain OK":
      "พวงกุญแจปกติ",
    "No custom keys":
      "ไม่มีคีย์กำหนดเอง",
    "Paste client_id...":
      "วาง client_id...",
    "Paste client_secret...":
      "วาง client_secret...",
    "Save securely in the Keychain":
      "บันทึกอย่างปลอดภัยในพวงกุญแจ",
    "Refresh":
      "รีเฟรช",
    "Overview":
      "ภาพรวม",
    "Backups":
      "ข้อมูลสำรอง",
    "Storage":
      "พื้นที่เก็บข้อมูล",
    "Settings":
      "การตั้งค่า",
    "Current status: %@":
      "สถานะปัจจุบัน: %@",
    "Does not point to CloudMachine":
      "ไม่ได้ชี้ไปที่ CloudMachine",
    "tmutil did not answer":
      "tmutil ไม่ตอบสนอง",
    "Backing up: %@ of %@":
      "กำลังสำรองข้อมูล: %@ จาก %@",
    "%@ of %@":
      "%@ จาก %@",
    "Copied":
      "คัดลอกแล้ว",
    "No backup is running":
      "ไม่มีการสำรองข้อมูลที่กำลังทำงาน",
    "Time Machine starts the next one on its own schedule.":
      "Time Machine จะเริ่มครั้งถัดไปเองตามกำหนดเวลาของตัวเอง",
    "Backup cycle":
      "รอบการสำรองข้อมูล",
    "%@ GiB":
      "%@ GiB",
    "%@ GiB in %@ bands, %@ uploading":
      "%@ GiB ใน %@ แบนด์ กำลังอัปโหลด %@",
    "%@ bands":
      "%@ แบนด์",
    "%@ fragments abandoned - only in the machine":
      "ละทิ้ง %@ ชิ้นส่วน - มีอยู่ในเครื่องเสมือนเท่านั้น",
    "127.0.0.1:5572 answers on the Mac: Lima forwards the machine's rclone remote control, which has no password. Any web page open in a browser can send it commands - including deleting the backup on Google Drive. Add the portForwards rule from vm/cmsmb.yaml to the machine and restart it (see vm/README.md).":
      "127.0.0.1:5572 ตอบสนองบน Mac: Lima ส่งต่อการควบคุมระยะไกลของ rclone ในเครื่องเสมือน ซึ่งไม่มีรหัสผ่าน หน้าเว็บใดก็ตามที่เปิดอยู่ในเบราว์เซอร์สามารถส่งคำสั่งไปได้ - รวมถึงการลบข้อมูลสำรองบน Google Drive เพิ่มกฎ portForwards จาก vm/cmsmb.yaml ลงในเครื่องเสมือนแล้วรีสตาร์ท (ดู vm/README.md)",
    "A service in the CloudMachine machine is not running":
      "บริการในเครื่องเสมือน CloudMachine ไม่ได้ทำงาน",
    "Address":
      "ที่อยู่",
    "Agent installation INCOMPLETE - %@ of %@ did not go in:\n%@\n%@\nEvery missing agent is a function that has silently stopped working (vm-guard watches the machine's buffer, backup-health reports failures). Fix the cause and repeat the installation.":
      "การติดตั้งเอเจนต์ไม่สมบูรณ์ - %@ จาก %@ ติดตั้งไม่สำเร็จ:\n%@\n%@\nเอเจนต์ที่ขาดไปทุกตัวคือฟังก์ชันที่หยุดทำงานโดยไม่มีสัญญาณ (vm-guard เฝ้าดูบัฟเฟอร์ของเครื่องเสมือน, backup-health รายงานความล้มเหลว) แก้ไขสาเหตุแล้วติดตั้งซ้ำ",
    "All running":
      "ทำงานทั้งหมด",
    "Also install the launchd agents (same as install-launchd).":
      "ติดตั้งเอเจนต์ launchd ด้วย (เหมือนกับ install-launchd)",
    "At most this many minutes of waiting for the upload.":
      "รอการอัปโหลดนานที่สุดตามจำนวนนาทีนี้",
    "At the limit every new band fails with EMFILE and the backup stops. Check: cloudmachine-agent vm-status":
      "เมื่อถึงขีดจำกัด แบนด์ใหม่ทุกอันจะล้มเหลวด้วย EMFILE และการสำรองข้อมูลจะหยุด ตรวจสอบ: cloudmachine-agent vm-status",
    "Cache on the machine's disk":
      "แคชบนดิสก์ของเครื่องเสมือน",
    "Connected to Google Drive, but could not create the folder '%@' - without it the machine has nowhere to keep the backup. Check the account permissions and try again.":
      "เชื่อมต่อกับ Google Drive แล้ว แต่สร้างโฟลเดอร์ '%@' ไม่ได้ - หากไม่มีโฟลเดอร์นี้ เครื่องเสมือนจะไม่มีที่เก็บข้อมูลสำรอง ตรวจสอบสิทธิ์ของบัญชีแล้วลองอีกครั้ง",
    "Convert the image":
      "แปลงอิมเมจ",
    "Converting the image to 32 MB bands":
      "กำลังแปลงอิมเมจเป็นแบนด์ขนาด 32 MB",
    "Could not check with the current connection whether the backup is on Google Drive (%@), so remote '%@' was NOT replaced: without that answer the new sign-in cannot be checked against it.":
      "ตรวจสอบด้วยการเชื่อมต่อปัจจุบันไม่ได้ว่าข้อมูลสำรองอยู่บน Google Drive (%@) หรือไม่ จึง \"ไม่ได้\" แทนที่ remote '%@': หากไม่มีคำตอบนั้น จะตรวจสอบการลงชื่อเข้าใช้ใหม่เทียบกับข้อมูลสำรองไม่ได้",
    "Downloads the official rclone binary into ~/.cloudmachine/bin (Google sign-in and the machine's rclone.conf).":
      "ดาวน์โหลดไบนารี rclone อย่างเป็นทางการไปที่ ~/.cloudmachine/bin (การลงชื่อเข้าใช้ Google และ rclone.conf ของเครื่องเสมือน)",
    "Free in the machine":
      "พื้นที่ว่างในเครื่องเสมือน",
    "Free in the machine: %@":
      "พื้นที่ว่างในเครื่องเสมือน: %@",
    "Generates and installs the launchd agents (app, backup watchdog, machine start, machine guard).":
      "สร้างและติดตั้งเอเจนต์ launchd (แอป ตัวเฝ้าระวังการสำรองข้อมูล การเริ่มเครื่องเสมือน ตัวป้องกันเครื่องเสมือน)",
    "Install Lima, which runs the CloudMachine machine: run this in Terminal":
      "ติดตั้ง Lima ซึ่งเรียกใช้เครื่องเสมือน CloudMachine: เรียกใช้คำสั่งนี้ในเทอร์มินัล",
    "Install rclone (signs in to Google Drive for the machine)":
      "ติดตั้ง rclone (ลงชื่อเข้าใช้ Google Drive ให้เครื่องเสมือน)",
    "Install the background agents (machine start, buffer guard, backup watchdog)":
      "ติดตั้งเอเจนต์เบื้องหลัง (การเริ่มเครื่องเสมือน ตัวป้องกันบัฟเฟอร์ ตัวเฝ้าระวังการสำรองข้อมูล)",
    "Installs rclone through Homebrew - CloudMachine itself uses the one from install-rclone.":
      "ติดตั้ง rclone ผ่าน Homebrew - CloudMachine เองใช้ตัวที่มาจาก install-rclone",
    "Info.plist, token and mapped/ of the backup image exist only on the machine's disk; without them the bands in %@ cannot be restored. The copy (tm-meta-sync, every 15 min) goes to %@. Check: cloudmachine-agent vm-status, then in the machine: journalctl -u tm-meta-sync":
      "Info.plist, โทเค็น และ mapped/ ของอิมเมจสำรองข้อมูลมีอยู่บนดิสก์ของเครื่องเสมือนเท่านั้น หากไม่มี แบนด์ใน %@ จะกู้คืนไม่ได้ สำเนา (tm-meta-sync ทุก 15 นาที) ถูกส่งไปที่ %@ ตรวจสอบ: cloudmachine-agent vm-status แล้วในเครื่องเสมือน: journalctl -u tm-meta-sync",
    "Lima says the machine is running, but a command in it did not return. Without it nothing is known about Samba, rclone or the upload. Check: cloudmachine-agent vm-status":
      "Lima รายงานว่าเครื่องเสมือนกำลังทำงาน แต่คำสั่งหนึ่งในเครื่องไม่ตอบกลับ หากไม่มีคำสั่งนั้น จะไม่ทราบอะไรเกี่ยวกับ Samba, rclone หรือการอัปโหลดเลย ตรวจสอบ: cloudmachine-agent vm-status",
    "Machine":
      "เครื่องเสมือน",
    "Machine %@":
      "เครื่องเสมือน %@",
    "Machine & Upload Status":
      "สถานะเครื่องเสมือนและการอัปโหลด",
    "Machine buffer":
      "บัฟเฟอร์ของเครื่องเสมือน",
    "No Time Machine destination is the machine's share (smb://tm@<address>/CloudMachine) - backups are not being made there. The command is printed by: cloudmachine-agent vm-setup":
      "ไม่มีปลายทาง Time Machine ใดที่เป็นแชร์ของเครื่องเสมือน (smb://tm@<address>/CloudMachine) - จึงไม่มีการสำรองข้อมูลไปที่นั่น คำสั่งพิมพ์ได้ด้วย: cloudmachine-agent vm-setup",
    "Not running: %@":
      "ไม่ได้ทำงาน: %@",
    "Not set up":
      "ยังไม่ได้ตั้งค่า",
    "Once it runs out, rclone stops uploading, the machine's buffer fills up and backups stop being made. At a growth of ~600 MB per hourly cycle that is about %@ days.":
      "เมื่อหมด rclone จะหยุดอัปโหลด บัฟเฟอร์ของเครื่องเสมือนจะเต็ม และการสำรองข้อมูลจะหยุด ที่อัตราเพิ่มประมาณ 600 MB ต่อรอบรายชั่วโมง จะอยู่ได้ราว %@ วัน",
    "Or rclone.conf is missing: this Mac has already set up the CloudMachine machine, so it is not connected anew blindly. Restore the file from a backup (the machine keeps its own copy in %@). To connect anyway, create an empty file at the path `%@ config file` prints and run again - the existing folder is kept.":
      "หรือไม่พบ rclone.conf: Mac เครื่องนี้เคยตั้งค่าเครื่องเสมือน CloudMachine แล้ว จึงไม่เชื่อมต่อใหม่แบบสุ่มสี่สุ่มห้า กู้คืนไฟล์จากข้อมูลสำรอง (เครื่องเสมือนเก็บสำเนาของตัวเองไว้ใน %@) หากต้องการเชื่อมต่อต่อไป ให้สร้างไฟล์เปล่าที่เส้นทางซึ่ง `%@ config file` พิมพ์ออกมา แล้วเรียกใช้อีกครั้ง - โฟลเดอร์ที่มีอยู่จะถูกเก็บไว้",
    "Point Time Machine at the machine: run this in Terminal (needs sudo; Copy includes the password)":
      "ชี้ Time Machine ไปที่เครื่องเสมือน: เรียกใช้คำสั่งนี้ในเทอร์มินัล (ต้องใช้ sudo; คัดลอกจะรวมรหัสผ่านด้วย)",
    "Points to the machine":
      "ชี้ไปที่เครื่องเสมือน",
    "Prepares for a restart: stops the backup, waits a while for the upload, then stops the machine cleanly.":
      "เตรียมการรีสตาร์ท: หยุดการสำรองข้อมูล รอการอัปโหลดสักครู่ แล้วหยุดเครื่องเสมือนอย่างเรียบร้อย",
    "Reading the Time Machine destination did not return within %@ s. That is how tmutil behaves when its destination hangs.":
      "การอ่านปลายทาง Time Machine ไม่ตอบกลับภายใน %@ s tmutil เป็นเช่นนี้เมื่อปลายทางค้าง",
    "Remote '%@' was NOT replaced. The new sign-in gets the 'drive.file' scope, which sees only files created under its own client_id. The existing backup was most likely created by the current connection and would become invisible to it. Before anything is written, the new token is checked against the existing backup, and the replacement is abandoned if it cannot see it. The machine keeps its own copy of the configuration until vm-setup --replace-rclone-config. To go ahead, run again with --replace-existing --accept-scope-change.":
      "remote '%@' \"ไม่ได้\" ถูกแทนที่ การลงชื่อเข้าใช้ใหม่ได้ขอบเขต 'drive.file' ซึ่งมองเห็นเฉพาะไฟล์ที่สร้างภายใต้ client_id ของตัวเองเท่านั้น ข้อมูลสำรองที่มีอยู่น่าจะถูกสร้างโดยการเชื่อมต่อปัจจุบัน และจะมองไม่เห็นสำหรับการเชื่อมต่อใหม่ ก่อนเขียนสิ่งใด จะตรวจสอบโทเค็นใหม่เทียบกับข้อมูลสำรองที่มีอยู่ และจะยกเลิกการแทนที่หากมองไม่เห็น เครื่องเสมือนเก็บสำเนาการตั้งค่าของตัวเองไว้จนกว่าจะใช้ vm-setup --replace-rclone-config หากต้องการดำเนินการต่อ ให้เรียกใช้อีกครั้งด้วย --replace-existing --accept-scope-change",
    "Remote control:   OPEN on the Mac at 127.0.0.1:5572 - any web page can send rclone commands; see vm/README.md (portForwards)":
      "การควบคุมระยะไกล:   เปิดอยู่บน Mac ที่ 127.0.0.1:5572 - หน้าเว็บใดก็ส่งคำสั่ง rclone ได้; ดู vm/README.md (portForwards)",
    "Running":
      "กำลังทำงาน",
    "Samba, rclone or punchfs in the machine is not active, so Time Machine has nowhere to write or the bands do not reach Google Drive. Check: cloudmachine-agent vm-status":
      "Samba, rclone หรือ punchfs ในเครื่องเสมือนไม่ทำงาน Time Machine จึงไม่มีที่เขียน หรือแบนด์ไม่ถึง Google Drive ตรวจสอบ: cloudmachine-agent vm-status",
    "Service %@":
      "บริการ %@",
    "Services":
      "บริการ",
    "Set up the CloudMachine machine (the first time it downloads Ubuntu - several minutes)":
      "ตั้งค่าเครื่องเสมือน CloudMachine (ครั้งแรกจะดาวน์โหลด Ubuntu - ใช้เวลาหลายนาที)",
    "Set up the CloudMachine machine again, so it prints the Time Machine command":
      "ตั้งค่าเครื่องเสมือน CloudMachine อีกครั้ง เพื่อให้พิมพ์คำสั่ง Time Machine",
    "Set up the machine":
      "ตั้งค่าเครื่องเสมือน",
    "Setting up the CloudMachine machine":
      "กำลังตั้งค่าเครื่องเสมือน CloudMachine",
    "Start the CloudMachine machine":
      "เริ่มเครื่องเสมือน CloudMachine",
    "Start the machine":
      "เริ่มเครื่องเสมือน",
    "Starting the CloudMachine machine":
      "กำลังเริ่มเครื่องเสมือน CloudMachine",
    "Still to upload: %@ GiB":
      "ยังต้องอัปโหลด: %@ GiB",
    "Stopping the Time Machine backup...":
      "กำลังหยุดการสำรองข้อมูลของ Time Machine...",
    "Stopping the machine %@...":
      "กำลังหยุดเครื่องเสมือน %@...",
    "The CloudMachine machine does not answer":
      "เครื่องเสมือน CloudMachine ไม่ตอบสนอง",
    "The CloudMachine machine is not running":
      "เครื่องเสมือน CloudMachine ไม่ได้ทำงาน",
    "The CloudMachine machine is not set up yet":
      "ยังไม่ได้ตั้งค่าเครื่องเสมือน CloudMachine",
    "The CloudMachine machine is stopped":
      "เครื่องเสมือน CloudMachine หยุดอยู่",
    "The backup is stopped, the upload gets up to 30 minutes, then the machine shuts down cleanly. It starts again at the next login.":
      "หยุดการสำรองข้อมูลแล้ว ให้เวลาอัปโหลดนานถึง 30 นาที จากนั้นเครื่องเสมือนจะปิดอย่างเรียบร้อย และจะเริ่มทำงานอีกครั้งเมื่อเข้าสู่ระบบครั้งถัดไป",
    "The machine %@ is not running - nothing to prepare.":
      "เครื่องเสมือน %@ ไม่ได้ทำงาน - ไม่มีอะไรต้องเตรียม",
    "The machine is stopped and everything reached Google Drive. The Mac can be restarted; the machine starts again at login.":
      "เครื่องเสมือนหยุดแล้ว และทุกอย่างถึง Google Drive แล้ว สามารถรีสตาร์ท Mac ได้ เครื่องเสมือนจะเริ่มทำงานอีกครั้งเมื่อเข้าสู่ระบบ",
    "The machine is stopped. %@ GiB had not reached Google Drive yet - it is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "เครื่องเสมือนหยุดแล้ว %@ GiB ยังไม่ถึง Google Drive - เก็บไว้ในบัฟเฟอร์ของเครื่องเสมือนและจะอัปโหลดหลังการเริ่มครั้งถัดไป สามารถรีสตาร์ท Mac ได้",
    "The machine is stopped. rclone did not say how much was still to upload; what was not uploaded is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "เครื่องเสมือนหยุดแล้ว rclone ไม่ได้แจ้งว่ายังเหลือต้องอัปโหลดเท่าใด สิ่งที่ยังไม่ได้อัปโหลดเก็บไว้ในบัฟเฟอร์ของเครื่องเสมือนและจะอัปโหลดหลังการเริ่มครั้งถัดไป สามารถรีสตาร์ท Mac ได้",
    "The machine's disk is a file on this disk and grows as the upload buffer fills. With no space left the machine cannot write the buffer, and Time Machine's local snapshots have nowhere to go either.":
      "ดิสก์ของเครื่องเสมือนเป็นไฟล์บนดิสก์นี้ และจะโตขึ้นเมื่อบัฟเฟอร์อัปโหลดเต็ม หากไม่มีพื้นที่เหลือ เครื่องเสมือนจะเขียนบัฟเฟอร์ไม่ได้ และสแนปชอตในเครื่องของ Time Machine ก็ไม่มีที่เก็บเช่นกัน",
    "The image's metadata has never been copied to Drive":
      "ยังไม่เคยคัดลอกข้อมูลเมตาของอิมเมจไปที่ Drive",
    "The image's metadata was last copied to Drive %@ ago":
      "คัดลอกข้อมูลเมตาของอิมเมจไปที่ Drive ครั้งล่าสุดเมื่อ %@ ที่แล้ว",
    "The machine's disk is running out of space (%@ GB)":
      "ดิสก์ของเครื่องเสมือนใกล้เต็ม (%@ GB)",
    "The new sign-in does NOT see the existing backup (%@), so remote '%@' was NOT replaced and rclone.conf is unchanged. Keep the current connection, or sign in with the credential (client_id) that created the backup.":
      "การลงชื่อเข้าใช้ใหม่ \"มองไม่เห็น\" ข้อมูลสำรองที่มีอยู่ (%@) จึง \"ไม่ได้\" แทนที่ remote '%@' และ rclone.conf ไม่เปลี่ยนแปลง ให้ใช้การเชื่อมต่อปัจจุบันต่อไป หรือลงชื่อเข้าใช้ด้วยข้อมูลรับรอง (client_id) ที่สร้างข้อมูลสำรองนั้น",
    "The upload buffer lives on this disk. The guard pauses Time Machine before it fills; if the upload does not catch up, backups stay paused.":
      "บัฟเฟอร์อัปโหลดอยู่บนดิสก์นี้ ตัวป้องกันจะหยุด Time Machine ชั่วคราวก่อนที่บัฟเฟอร์จะเต็ม หากการอัปโหลดตามไม่ทัน การสำรองข้อมูลจะหยุดค้างไว้",
    "These bands exist only in the machine's buffer. The backup on Google Drive is INCOMPLETE and may not open.":
      "แบนด์เหล่านี้มีอยู่ในบัฟเฟอร์ของเครื่องเสมือนเท่านั้น ข้อมูลสำรองบน Google Drive ไม่สมบูรณ์และอาจเปิดไม่ได้",
    "Time Machine backs up to the machine, so without it no backup is made. Start it: limactl start %@ (or the Start button in the app).":
      "Time Machine สำรองข้อมูลไปที่เครื่องเสมือน หากไม่มีเครื่องเสมือนจะไม่มีการสำรองข้อมูล เริ่มด้วย: limactl start %@ (หรือปุ่มเริ่มในแอป)",
    "Time Machine did not stop its backup within 2 minutes (or tmutil did not answer) - the machine was NOT stopped. Try again in a moment.":
      "Time Machine ไม่หยุดการสำรองข้อมูลภายใน 2 นาที (หรือ tmutil ไม่ตอบสนอง) - เครื่องเสมือน \"ไม่ได้\" ถูกหยุด ลองอีกครั้งในอีกสักครู่",
    "Time Machine has created its image: stop the backup, then convert the image to 32 MB bands":
      "Time Machine สร้างอิมเมจแล้ว: หยุดการสำรองข้อมูล แล้วแปลงอิมเมจเป็นแบนด์ขนาด 32 MB",
    "To upload":
      "รออัปโหลด",
    "Unknown whether the CloudMachine machine is running":
      "ไม่ทราบว่าเครื่องเสมือน CloudMachine ทำงานอยู่หรือไม่",
    "Waiting for the upload to Google Drive (at most %@ min)...":
      "กำลังรอการอัปโหลดไปที่ Google Drive (นานที่สุด %@ นาที)...",
    "With --replace-existing: confirms that the new sign-in (scope 'drive.file') may not see the existing backup. The new token is still checked against the backup first.":
      "เมื่อใช้ --replace-existing: ยืนยันว่าการลงชื่อเข้าใช้ใหม่ (ขอบเขต 'drive.file') อาจมองไม่เห็นข้อมูลสำรองที่มีอยู่ โทเค็นใหม่ยังคงถูกตรวจสอบเทียบกับข้อมูลสำรองก่อน",
    "Without it there is no way to check whether anything reached the Drive - the machine's guard is blind then.":
      "หากไม่มี จะไม่มีทางตรวจสอบได้ว่ามีสิ่งใดถึง Drive หรือไม่ - ตัวป้องกันของเครื่องเสมือนจะมองไม่เห็น",
    "limactl did not answer":
      "limactl ไม่ตอบสนอง",
    "limactl did not answer (or is not installed). That does not mean the machine is down - it means nobody has checked.":
      "limactl ไม่ตอบสนอง (หรือไม่ได้ติดตั้ง) ซึ่งไม่ได้หมายความว่าเครื่องเสมือนล่ม แต่หมายความว่ายังไม่มีใครตรวจสอบ",
    "limactl start failed: %@":
      "limactl start ล้มเหลว: %@",
    "limactl stop failed: %@":
      "limactl stop ล้มเหลว: %@",
    "punchfs is close to its open-file limit":
      "punchfs ใกล้ถึงขีดจำกัดจำนวนไฟล์ที่เปิดได้",
    "punchfs open files":
      "ไฟล์ที่ punchfs เปิดอยู่",
    "rclone's remote control is open on this Mac":
      "การควบคุมระยะไกลของ rclone เปิดอยู่บน Mac เครื่องนี้",
    "statfs('/System/Volumes/Data') returned an error, so nobody knows whether the machine's disk can still grow on this Mac.":
      "statfs('/System/Volumes/Data') ส่งคืนข้อผิดพลาด จึงไม่มีใครทราบว่าดิสก์ของเครื่องเสมือนยังโตต่อได้บน Mac เครื่องนี้หรือไม่",
    "Google Drive's daily upload limit stops the upload":
      "ขีดจำกัดการอัปโหลดรายวันของ Google Drive ทำให้การอัปโหลดหยุด",
    "Google last refused an upload %@ ago (750 GB a day). Backups since then are only in the machine's buffer on this Mac. rclone retries every 5 min and resumes by itself when the limit passes; the guard pauses Time Machine if more than %@ GiB waits.":
      "Google ปฏิเสธการอัปโหลดครั้งล่าสุดเมื่อ %@ ที่แล้ว (750 GB ต่อวัน) ข้อมูลสำรองตั้งแต่นั้นมีอยู่ในบัฟเฟอร์ของเครื่องเสมือนบน Mac เครื่องนี้เท่านั้น rclone ลองใหม่ทุก 5 นาทีและจะทำต่อเองเมื่อพ้นขีดจำกัด ตัวป้องกันจะหยุด Time Machine ชั่วคราวหากมีข้อมูลรออยู่เกิน %@ GiB",
    "Usage on Google Drive is not being measured":
      "ไม่ได้วัดการใช้งานบน Google Drive",
    "The last measurement (%@ GB) is from %@, %@ ago - rclone size has not answered since. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "การวัดครั้งล่าสุด (%@ GB) มาจาก %@ (%@ ที่แล้ว) - rclone size ไม่ตอบสนองมาตั้งแต่นั้น จนกว่าจะตอบสนอง จะไม่มีอะไรเฝ้าดูขีดจำกัด %@ GB: การเตือนที่ 90%% และ 100%% จะเงียบ ตรวจสอบ vm-status หรือกด วัดตอนนี้ ในหน้าต่าง",
    "rclone size has not answered even once. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "rclone size ไม่ตอบสนองเลยสักครั้ง จนกว่าจะตอบสนอง จะไม่มีอะไรเฝ้าดูขีดจำกัด %@ GB: การเตือนที่ 90%% และ 100%% จะเงียบ ตรวจสอบ vm-status หรือกด วัดตอนนี้ ในหน้าต่าง",
    "Saved in the Keychain. Connecting Google Drive (configure-remote) will use them.":
      "บันทึกในพวงกุญแจแล้ว การเชื่อมต่อ Google Drive (configure-remote) จะใช้ข้อมูลเหล่านี้",
    "Saved in the Keychain. The existing Google Drive connection keeps its old client_id, and on this Mac it should stay that way: a connection made with the new keys (the 'drive.file' scope) cannot see the backup created by the old one. Do not replace the connection here; the new keys are for a Mac that is not connected yet.":
      "บันทึกในพวงกุญแจแล้ว การเชื่อมต่อ Google Drive ที่มีอยู่ยังคงใช้ client_id เดิม และบน Mac เครื่องนี้ควรเป็นเช่นนั้น: การเชื่อมต่อที่สร้างด้วยคีย์ใหม่ (ขอบเขต 'drive.file') มองไม่เห็นข้อมูลสำรองที่สร้างโดยตัวเดิม อย่าแทนที่การเชื่อมต่อที่นี่ คีย์ใหม่ไว้สำหรับ Mac ที่ยังไม่ได้เชื่อมต่อ",
    "it is not there for the new token":
      "ไม่มีสำหรับโทเค็นใหม่",
    "Cancel":
      "ยกเลิก",
    "ACTION NEEDED":
      "ต้องดำเนินการ",
    "WILL PASS BY ITSELF — DO NOTHING":
      "จะหายไปเอง - ไม่ต้องทำอะไร",
    "UNKNOWN — CHECK AGAIN SHORTLY":
      "ไม่ทราบ - ตรวจสอบอีกครั้งในอีกสักครู่",
    "ALL GOOD":
      "ปกติดี",
    "Upload is not working":
      "การอัปโหลดไม่ทำงาน",
    "Upload stopped — no space left on Google Drive":
      "การอัปโหลดหยุด - Google Drive ไม่มีพื้นที่เหลือ",
    "%@ backup fragments not uploaded":
      "ชิ้นส่วนข้อมูลสำรอง %@ ชิ้นยังไม่ได้อัปโหลด",
    "Upload cannot keep up with writes":
      "การอัปโหลดตามการเขียนไม่ทัน",
    "Upload paused — Google daily limit":
      "การอัปโหลดหยุดชั่วคราว - ขีดจำกัดรายวันของ Google",
    "Uploading to Google Drive — %@ queued":
      "กำลังอัปโหลดไปที่ Google Drive - รอในคิว %@",
    "Everything uploaded to Google Drive":
      "อัปโหลดไปที่ Google Drive ครบทั้งหมดแล้ว",
    "Unknown what is waiting in the queue":
      "ไม่ทราบว่ามีอะไรรออยู่ในคิว",
    "There is no connection to Google Drive, so backups are only made on this Mac. If this does not pass by itself within a few minutes, check the network and the connection to Drive.":
      "ไม่มีการเชื่อมต่อกับ Google Drive จึงสำรองข้อมูลได้เฉพาะบน Mac เครื่องนี้ หากไม่หายไปเองภายในไม่กี่นาที ให้ตรวจสอบเครือข่ายและการเชื่อมต่อกับ Drive",
    "There is no space left on Google Drive. This will NOT pass by itself — you need to free up space on Drive. Until then Time Machine is paused, so that it does not fill up this Mac's disk.":
      "Google Drive ไม่มีพื้นที่เหลือ สิ่งนี้จะ \"ไม่\" หายไปเอง - ต้องเพิ่มพื้นที่ว่างบน Drive จนกว่าจะทำ Time Machine จะหยุดชั่วคราวเพื่อไม่ให้ดิสก์ของ Mac เครื่องนี้เต็ม",
    "%@ backup fragments could not be uploaded and rclone stopped trying. These fragments exist only on this Mac, so the backup on Drive is incomplete. This needs checking.":
      "ชิ้นส่วนข้อมูลสำรอง %@ ชิ้นอัปโหลดไม่ได้และ rclone เลิกลองแล้ว ชิ้นส่วนเหล่านี้มีอยู่บน Mac เครื่องนี้เท่านั้น ข้อมูลสำรองบน Drive จึงไม่สมบูรณ์ ต้องตรวจสอบเรื่องนี้",
    "Time Machine is writing faster than the upload goes, and the buffer has filled up. The backup will be paused until the upload catches up — this is a safeguard against filling up the disk, not a failure.":
      "Time Machine เขียนเร็วกว่าการอัปโหลด และบัฟเฟอร์เต็มแล้ว การสำรองข้อมูลจะหยุดชั่วคราวจนกว่าการอัปโหลดจะตามทัน - นี่เป็นมาตรการป้องกันไม่ให้ดิสก์เต็ม ไม่ใช่ความล้มเหลว",
    "Google accepts 750 GB per day and that limit has been used up. There is nothing to do: the limit renews by itself, usually within a few hours. Time Machine backups are made normally in the meantime and wait in the buffer — they will be uploaded as soon as Google starts accepting again.":
      "Google รับ 750 GB ต่อวัน และใช้ครบขีดจำกัดแล้ว ไม่ต้องทำอะไร: ขีดจำกัดจะรีเซ็ตเอง โดยปกติภายในไม่กี่ชั่วโมง ระหว่างนี้ Time Machine สำรองข้อมูลได้ตามปกติและรออยู่ในบัฟเฟอร์ - จะอัปโหลดทันทีที่ Google เริ่มรับอีกครั้ง",
    "%@ backup fragments are queued and on their way to Drive.":
      "ชิ้นส่วนข้อมูลสำรอง %@ ชิ้นอยู่ในคิวและกำลังไปที่ Drive",
    "Nothing is waiting in the queue — the backup on Google Drive is complete.":
      "ไม่มีอะไรรออยู่ในคิว - ข้อมูลสำรองบน Google Drive สมบูรณ์",
    "rclone did not answer the question about the queue, so it is unknown how many backups are still waiting to be uploaded. This does not mean something broke — under load the answer can be late. It only means that right now nobody knows. If it persists, the backup cycle check will report it.":
      "rclone ไม่ตอบคำถามเกี่ยวกับคิว จึงไม่ทราบว่ามีข้อมูลสำรองรออัปโหลดอีกเท่าใด ซึ่งไม่ได้หมายความว่ามีบางอย่างเสีย - เมื่อโหลดสูง คำตอบอาจช้า หมายความเพียงว่าตอนนี้ยังไม่มีใครทราบ หากยังเป็นอยู่ การตรวจสอบรอบการสำรองข้อมูลจะรายงาน",
    "unknown error":
      "ข้อผิดพลาดที่ไม่ทราบสาเหตุ",
    "rclone lsf ended with an error":
      "rclone lsf จบการทำงานด้วยข้อผิดพลาด",
    "This Mac is close to its space limit on Google Drive":
      "Mac เครื่องนี้ใกล้ถึงขีดจำกัดพื้นที่บน Google Drive",
    "%@ GB of %@ GB used. Time Machine deletes the oldest backups to stay within its quota; check that the quota is set (vm-status).":
      "ใช้ไป %@ GB จาก %@ GB Time Machine จะลบข้อมูลสำรองที่เก่าที่สุดเพื่อให้อยู่ในโควตา ตรวจสอบว่าตั้งโควตาแล้ว (vm-status)",
    "This Mac is over its space limit on Google Drive":
      "Mac เครื่องนี้เกินขีดจำกัดพื้นที่บน Google Drive",
    "%@ GB of %@ GB used. Set the Time Machine quota (command in the app window or vm-status), or raise the limit.":
      "ใช้ไป %@ GB จาก %@ GB ตั้งโควตา Time Machine (คำสั่งอยู่ในหน้าต่างแอปหรือ vm-status) หรือเพิ่มขีดจำกัด",
    "not set":
      "ยังไม่ได้ตั้งค่า",
    "%@ GB - usage not measured yet":
      "%@ GB - ยังไม่ได้วัดการใช้งาน",
    "%@ of %@ GB used (%@%%)":
      "ใช้ไป %@ จาก %@ GB (%@%%)",
    "The limit must be a whole number of GB above zero.":
      "ขีดจำกัดต้องเป็นจำนวนเต็ม GB ที่มากกว่าศูนย์",
    "machines.json cannot be read, so it was not overwritten. Fix or remove it first.":
      "อ่าน machines.json ไม่ได้ จึงไม่ได้เขียนทับ แก้ไขหรือลบไฟล์นั้นก่อน",
    "'%@' is not a valid folder name: use lowercase letters, digits and dashes.":
      "'%@' ไม่ใช่ชื่อโฟลเดอร์ที่ถูกต้อง: ใช้ตัวพิมพ์เล็ก ตัวเลข และขีดกลาง",
    "This Mac already backs up to folder '%@'. Switching to '%@' would start a new, empty backup and orphan the existing one, so nothing was changed.":
      "Mac เครื่องนี้สำรองข้อมูลไปที่โฟลเดอร์ '%@' อยู่แล้ว การเปลี่ยนเป็น '%@' จะเริ่มข้อมูลสำรองใหม่ที่ว่างเปล่าและทำให้ข้อมูลสำรองเดิมไม่มีเจ้าของ จึงไม่ได้เปลี่ยนแปลงอะไร",
    "This Mac already has a CloudMachine installation, whose backup is in folder '%@'. Switching to '%@' would orphan it, so nothing was changed.":
      "Mac เครื่องนี้มีการติดตั้ง CloudMachine อยู่แล้ว โดยข้อมูลสำรองอยู่ในโฟลเดอร์ '%@' การเปลี่ยนเป็น '%@' จะทำให้ข้อมูลสำรองนั้นไม่มีเจ้าของ จึงไม่ได้เปลี่ยนแปลงอะไร",
    "Could not save the folder name to %@: %@":
      "บันทึกชื่อโฟลเดอร์ไปที่ %@ ไม่ได้: %@",
    "Homebrew is not installed. Install it manually: https://brew.sh":
      "ไม่ได้ติดตั้ง Homebrew ติดตั้งด้วยตนเอง: https://brew.sh",
    "Installing rclone failed: %@":
      "ติดตั้ง rclone ไม่สำเร็จ: %@",
    "Installed rclone.":
      "ติดตั้ง rclone แล้ว",
    "Own Google credentials: set.":
      "ข้อมูลรับรอง Google ของตนเอง: ตั้งค่าแล้ว",
    "INCOMPLETE: %@ is missing - rclone will use rclone's shared client_id anyway.":
      "ไม่สมบูรณ์: ไม่มี %@ - rclone จะใช้ client_id ที่ใช้ร่วมกันของ rclone อยู่ดี",
    "No own credentials - rclone uses the shared client_id, rate-limited jointly and being retired in 2026.":
      "ไม่มีข้อมูลรับรองของตนเอง - rclone ใช้ client_id ที่ใช้ร่วมกัน ซึ่งมีการจำกัดอัตราร่วมกันและจะเลิกใช้ในปี 2026",
    "Empty value - not saving.":
      "ค่าว่าง - ไม่บันทึก",
    "Keychain refused: %@":
      "พวงกุญแจปฏิเสธ: %@",
    "DIRTY-TREE":
      "ต้นไม้สกปรก",
    "Cannot create the working directory: %@":
      "สร้างไดเรกทอรีทำงานไม่ได้: %@",
    "Could not read the rclone version number.":
      "อ่านหมายเลขเวอร์ชันของ rclone ไม่ได้",
    "Could not download %@.":
      "ดาวน์โหลด %@ ไม่ได้",
    "No entry for %@ in SHA256SUMS.":
      "ไม่พบรายการสำหรับ %@ ใน SHA256SUMS",
    "Could not compute the checksum.":
      "คำนวณค่า checksum ไม่ได้",
    "SHA256 checksum does not match - NOT installing.\n  expected: %@\n  computed: %@":
      "ค่า checksum SHA256 ไม่ตรงกัน - \"ไม่\" ติดตั้ง\n  ที่คาดไว้: %@\n  ที่คำนวณได้: %@",
    "Could not unpack the archive.":
      "แตกไฟล์เก็บถาวรไม่ได้",
    "Could not install the binary: %@":
      "ติดตั้งไบนารีไม่ได้: %@",
    "Installed rclone %@ in %@ (SHA256 checksum matches).":
      "ติดตั้ง rclone %@ ใน %@ แล้ว (ค่า checksum SHA256 ตรงกัน)",
    "%@ did not respond within the allotted time (the process was left orphaned in the background).":
      "%@ ไม่ตอบสนองภายในเวลาที่กำหนด (กระบวนการถูกทิ้งไว้ค้างอยู่เบื้องหลัง)",
    "Cannot launch %@: %@":
      "เรียกใช้ %@ ไม่ได้: %@",
    "Remote '%@' already exists and was NOT touched.\nOverwriting it replaces the token and the permission scope; a credential with the 'drive.file' scope does not see files created by the previous one, so the existing backup becomes unreachable.\nIf you really want to replace it, first back up ~/.config/rclone/rclone.conf and run again with --replace-existing.":
      "remote '%@' มีอยู่แล้วและ \"ไม่ได้\" ถูกแตะต้อง\nการเขียนทับจะแทนที่โทเค็นและขอบเขตสิทธิ์ ข้อมูลรับรองที่มีขอบเขต 'drive.file' มองไม่เห็นไฟล์ที่สร้างโดยตัวก่อนหน้า ข้อมูลสำรองที่มีอยู่จึงเข้าถึงไม่ได้\nหากต้องการแทนที่จริง ๆ ให้สำรอง ~/.config/rclone/rclone.conf ก่อน แล้วเรียกใช้อีกครั้งด้วย --replace-existing",
    "Could not check whether remote '%@' already exists (rclone listremotes did not answer or failed), so nothing was changed. Run `%@ listremotes` to see the error, then try again.":
      "ตรวจสอบไม่ได้ว่ามี remote '%@' อยู่แล้วหรือไม่ (rclone listremotes ไม่ตอบสนองหรือล้มเหลว) จึงไม่ได้เปลี่ยนแปลงอะไร เรียกใช้ `%@ listremotes` เพื่อดูข้อผิดพลาด แล้วลองอีกครั้ง",
    "Could not check whether this Mac already has a CloudMachine installation (rclone did not answer), so no folder was chosen. Try again in a moment.":
      "ตรวจสอบไม่ได้ว่า Mac เครื่องนี้มีการติดตั้ง CloudMachine อยู่แล้วหรือไม่ (rclone ไม่ตอบสนอง) จึงไม่ได้เลือกโฟลเดอร์ ลองอีกครั้งในอีกสักครู่",
    "rclone authorize failed (%@). If that binary is missing, start with: cloudmachine-agent install-rclone.":
      "rclone authorize ล้มเหลว (%@) หากไม่พบไบนารีนั้น ให้เริ่มด้วย: cloudmachine-agent install-rclone",
    "Could not read the token from the output of rclone authorize.":
      "อ่านโทเค็นจากเอาต์พุตของ rclone authorize ไม่ได้",
    "rclone config create failed.":
      "rclone config create ล้มเหลว",
    "Connected to Google Drive as remote '%@', folder %@.":
      "เชื่อมต่อกับ Google Drive แล้วในชื่อ remote '%@' โฟลเดอร์ %@",
    "tmutil is not responding - unknown where the backup goes":
      "tmutil ไม่ตอบสนอง - ไม่ทราบว่าข้อมูลสำรองไปที่ใด",
    "No successful backup for %@":
      "ไม่มีการสำรองข้อมูลที่สำเร็จเป็นเวลา %@",
    "Last COMPLETED backup: %@. The cycle is hourly, so that is %@ missed runs.":
      "การสำรองข้อมูลที่เสร็จสมบูรณ์ครั้งล่าสุด: %@ รอบการทำงานเป็นรายชั่วโมง นั่นหมายถึงพลาดไป %@ รอบ",
    "There is NOT A SINGLE successful backup":
      "ไม่มีการสำรองข้อมูลที่สำเร็จเลยแม้แต่ครั้งเดียว",
    "The Time Machine preferences contain no date of a completed backup for this destination.":
      "การตั้งค่า Time Machine ไม่มีวันที่ของการสำรองข้อมูลที่เสร็จสมบูรณ์สำหรับปลายทางนี้",
    "The last backup attempt did not end in a backup":
      "ความพยายามสำรองข้อมูลครั้งล่าสุดไม่ได้ลงเอยด้วยข้อมูลสำรอง",
    "The attempt at %@ is newer than the last successful backup at %@.":
      "ความพยายามเมื่อ %@ ใหม่กว่าการสำรองข้อมูลที่สำเร็จครั้งล่าสุดเมื่อ %@",
    "Time Machine reports an error in the last run (RESULT=%@)":
      "Time Machine รายงานข้อผิดพลาดในการทำงานครั้งล่าสุด (RESULT=%@)",
    "A non-zero RESULT in the Time Machine preferences means the run did not succeed.":
      "ค่า RESULT ที่ไม่ใช่ศูนย์ในการตั้งค่า Time Machine หมายความว่าการทำงานไม่สำเร็จ",
    "rclone failed to upload %@ files":
      "rclone อัปโหลดไฟล์ %@ ไฟล์ไม่สำเร็จ",
    "Buffer full of nothing but unsent data":
      "บัฟเฟอร์เต็มไปด้วยข้อมูลที่ยังไม่ได้ส่งทั้งหมด",
    "rclone has nothing left to evict from the buffer - the upload cannot keep up or has stalled.":
      "rclone ไม่มีอะไรจะนำออกจากบัฟเฟอร์ได้อีก - การอัปโหลดตามไม่ทันหรือติดค้าง",
    "The rclone control interface is not responding":
      "อินเทอร์เฟซควบคุมของ rclone ไม่ตอบสนอง",
    "Google Drive is running out of space (%@ GB)":
      "Google Drive ใกล้เต็ม (%@ GB)",
    "The Mac's disk is running out of space (%@ GB)":
      "ดิสก์ของ Mac ใกล้เต็ม (%@ GB)",
    "Cannot read the Time Machine preferences":
      "อ่านการตั้งค่า Time Machine ไม่ได้",
    "%@ is unreadable - most often Full Disk Access is missing. Without this file it is UNKNOWN when the last backup was made, so we treat it as a failure, not as the absence of a problem.":
      "อ่าน %@ ไม่ได้ - สาเหตุที่พบบ่อยที่สุดคือไม่มีการเข้าถึงดิสก์แบบเต็ม หากไม่มีไฟล์นี้ จะไม่ทราบว่าสำรองข้อมูลครั้งล่าสุดเมื่อใด จึงถือเป็นความล้มเหลว ไม่ใช่การไม่มีปัญหา",
    "Cannot measure free space on the Mac's disk":
      "วัดพื้นที่ว่างบนดิสก์ของ Mac ไม่ได้",
    "%@ days":
      "%@ วัน",
    "CloudMachine: backup is not working":
      "CloudMachine: การสำรองข้อมูลไม่ทำงาน",
    "unknown reason":
      "ไม่ทราบสาเหตุ",
    "osascript did not show the notification (permissions or no graphical session)":
      "osascript ไม่ได้แสดงการแจ้งเตือน (สิทธิ์ หรือไม่มีเซสชันแบบกราฟิก)",
    "UNDELIVERED ALARM: %@":
      "การเตือนที่ไม่ได้ส่ง: %@",
    "from %@, reason: %@":
      "จาก %@ เหตุผล: %@",
    "The system notification was not delivered - you will see this alarm ONLY here.":
      "การแจ้งเตือนจากระบบไม่ได้ส่ง - คุณจะเห็นการเตือนนี้ที่นี่เท่านั้น",
    "%@ (%@ ago)":
      "%@ (%@ ที่แล้ว)",
    "%@ - marker from the FUTURE":
      "%@ - เครื่องหมายจากอนาคต",
    "%@ (%@ ago) - THE WATCHDOG MAY NOT BE RUNNING":
      "%@ (%@ ที่แล้ว) - ตัวเฝ้าระวังอาจไม่ได้ทำงาน",
    "NEVER - the watchdog has not recorded a single run":
      "ไม่เคย - ตัวเฝ้าระวังยังไม่ได้บันทึกการทำงานเลยสักครั้ง",
    "Could not find the launchd/ directory with templates.":
      "ไม่พบไดเรกทอรี launchd/ ที่มีเทมเพลต",
    "Could not find the compiled cloudmachine-agent binary.":
      "ไม่พบไบนารี cloudmachine-agent ที่คอมไพล์แล้ว",
    "ABORTED: could not put cloudmachine-agent in a stable location\n(%@) - most often a lack of space or permissions.\nNOT installing agents pointing at %@: that path\ndisappears on the next `swift build` or `git clean`, and backups stop\nwithout any visible signal.":
      "ยกเลิก: วาง cloudmachine-agent ในตำแหน่งที่คงที่ไม่ได้\n(%@) - สาเหตุที่พบบ่อยที่สุดคือพื้นที่หรือสิทธิ์ไม่พอ\n\"ไม่\" ติดตั้งเอเจนต์ที่ชี้ไปที่ %@ : เส้นทางนั้น\nจะหายไปเมื่อ `swift build` หรือ `git clean` ครั้งถัดไป และการสำรองข้อมูลจะหยุด\nโดยไม่มีสัญญาณใด ๆ ให้เห็น",
    "ABORTED: %@":
      "ยกเลิก: %@",
    "Could not list the templates in %@.":
      "แสดงรายการเทมเพลตใน %@ ไม่ได้",
    "could not read the template %@":
      "อ่านเทมเพลต %@ ไม่ได้",
    "could not write %@ (lack of space or permissions)":
      "เขียน %@ ไม่ได้ (พื้นที่หรือสิทธิ์ไม่พอ)",
    "launchctl load refused to load %@":
      "launchctl load ปฏิเสธการโหลด %@",
    "NOT A SINGLE agent was loaded.":
      "ไม่มีเอเจนต์ใดถูกโหลดเลยแม้แต่ตัวเดียว",
    "Only these went in: %@.":
      "ติดตั้งสำเร็จเฉพาะ: %@",
    "Could not load any launchd agent.":
      "โหลดเอเจนต์ launchd ใด ๆ ไม่ได้",
    "Installed agents: %@":
      "เอเจนต์ที่ติดตั้ง: %@",
    "                  WARNING: close to the limit - new bands will fail with EMFILE":
      "                  คำเตือน: ใกล้ถึงขีดจำกัด - แบนด์ใหม่จะล้มเหลวด้วย EMFILE",
    "%@/bands on Google Drive is not empty - it may hold another backup. NOT overwriting it; check it by hand.":
      "%@/bands บน Google Drive ไม่ว่างเปล่า - อาจมีข้อมูลสำรองอื่นอยู่ \"ไม่\" เขียนทับ ตรวจสอบด้วยตนเอง",
    "Address:          %@":
      "ที่อยู่:           %@",
    "Already prepared (%@ exists) - nothing to do.":
      "เตรียมไว้แล้ว (มี %@ อยู่) - ไม่ต้องดำเนินการใด ๆ",
    "Converts Time Machine's new, empty image in the machine to 32 MB bands and moves the bands to Google Drive.":
      "แปลงอิมเมจใหม่ที่ว่างเปล่าของ Time Machine ในเครื่องเสมือนเป็นแบนด์ขนาด 32 MB และย้ายแบนด์ไปที่ Google Drive",
    "Copy rclone.conf into the machine even if it already has one.":
      "คัดลอก rclone.conf ไปยังเครื่องเสมือน แม้ว่ามีอยู่แล้ว",
    "Copying the converted image into the machine failed: %@":
      "คัดลอกอิมเมจที่แปลงแล้วเข้าเครื่องเสมือนไม่สำเร็จ: %@",
    "Copying the image to the Mac failed: %@":
      "คัดลอกอิมเมจไปที่ Mac ไม่สำเร็จ: %@",
    "Could not ask Lima about the machine: %@":
      "สอบถาม Lima เกี่ยวกับเครื่องเสมือนไม่ได้: %@",
    "Could not carry the Time Machine files over: %@":
      "ย้ายไฟล์ Time Machine ไม่ได้: %@",
    "Could not check the image in the machine.":
      "ตรวจสอบอิมเมจในเครื่องเสมือนไม่ได้",
    "Could not copy the rclone configuration into the machine.":
      "คัดลอกการตั้งค่า rclone เข้าเครื่องเสมือนไม่ได้",
    "Could not create %@ on Google Drive: %@":
      "สร้าง %@ บน Google Drive ไม่ได้: %@",
    "Could not create %@: %@":
      "สร้าง %@ ไม่ได้: %@",
    "Could not find the vm/ directory with the machine template.":
      "ไม่พบไดเรกทอรี vm/ ที่มีเทมเพลตของเครื่องเสมือน",
    "Could not read the image size.":
      "อ่านขนาดอิมเมจไม่ได้",
    "Could not set the SMB password of user %@ in the machine.":
      "ตั้งรหัสผ่าน SMB ของผู้ใช้ %@ ในเครื่องเสมือนไม่ได้",
    "Could not stop smbd in the machine.":
      "หยุด smbd ในเครื่องเสมือนไม่ได้",
    "Could not write %@ in the machine.":
      "เขียน %@ ในเครื่องเสมือนไม่ได้",
    "Could not write the password file %@.":
      "เขียนไฟล์รหัสผ่าน %@ ไม่ได้",
    "Creates or starts the CloudMachine machine (Lima), gives it rclone's configuration and an SMB password, and prints the Time Machine command.":
      "สร้างหรือเริ่มเครื่องเสมือน CloudMachine (Lima) ให้การตั้งค่า rclone และรหัสผ่าน SMB แล้วพิมพ์คำสั่ง Time Machine",
    "Creating the machine %@ (first start downloads Ubuntu and installs packages - several minutes)...":
      "กำลังสร้างเครื่องเสมือน %@ (การเริ่มครั้งแรกจะดาวน์โหลด Ubuntu และติดตั้งแพ็กเกจ - ใช้เวลาหลายนาที)...",
    "Done: %@ has %@ MB bands on Google Drive; the original is kept in %@ in the machine. Start the backup: tmutil startbackup":
      "เสร็จสิ้น: %@ มีแบนด์ขนาด %@ MB บน Google Drive; ต้นฉบับเก็บไว้ใน %@ ในเครื่องเสมือน เริ่มการสำรองข้อมูล: tmutil startbackup",
    "exit code %@, no message":
      "รหัสออก %@ ไม่มีข้อความ",
    "Image metadata:   NEVER copied to %@ - check tm-meta-sync in the machine":
      "เมตาดาต้าอิมเมจ:  ไม่เคยคัดลอกไปที่ %@ - ตรวจสอบ tm-meta-sync ในเครื่องเสมือน",
    "Image metadata:   copied %@ ago to %@":
      "เมตาดาต้าอิมเมจ:  คัดลอกเมื่อ %@ ที่แล้วไปที่ %@",
    "Image metadata:   last copied %@ ago - OVERDUE (%@)":
      "เมตาดาต้าอิมเมจ:  คัดลอกครั้งล่าสุดเมื่อ %@ ที่แล้ว - เลยกำหนด (%@)",
    "Image metadata:   not copied yet - waits for vm-prepare-bundle":
      "เมตาดาต้าอิมเมจ:  ยังไม่ได้คัดลอก - รอ vm-prepare-bundle",
    "Backup %@, paused by the guard %@: %@":
      "การสำรองข้อมูล %@ ถูกตัวป้องกันหยุดชั่วคราว %@: %@",
    "Free in machine:  %@ GiB":
      "ว่างในเครื่องเสมือน: %@ GiB",
    "fsck_apfs -n found problems: %@":
      "fsck_apfs -n พบปัญหา: %@",
    "Google Drive folder: %@":
      "โฟลเดอร์ Google Drive: %@",
    "hdiutil attach of the converted image failed: %@":
      "hdiutil attach ของอิมเมจที่แปลงแล้วล้มเหลว: %@",
    "hdiutil convert failed: %@":
      "hdiutil convert ล้มเหลว: %@",
    "Image name in the machine (default: from the computer name).":
      "ชื่ออิมเมจในเครื่องเสมือน (ค่าเริ่มต้น: จากชื่อคอมพิวเตอร์)",
    "Installing the converted image FAILED: %@\nsmbd is left STOPPED so Time Machine does not open a half-installed image. The original is in %@ in the machine.":
      "ติดตั้งอิมเมจที่แปลงแล้วล้มเหลว: %@\nsmbd ถูกปล่อยให้หยุดอยู่ เพื่อไม่ให้ Time Machine เปิดอิมเมจที่ติดตั้งไม่สมบูรณ์ ต้นฉบับอยู่ใน %@ ในเครื่องเสมือน",
    "limactl create failed: %@":
      "limactl create ล้มเหลว: %@",
    "limactl list failed: %@":
      "limactl list ล้มเหลว: %@",
    "limactl not found - install Lima: brew install lima":
      "ไม่พบ limactl - ติดตั้ง Lima: brew install lima",
    "limactl start failed: %@\nThe machine's own log: %@":
      "limactl start ล้มเหลว: %@\nบันทึกของเครื่องเสมือนเอง: %@",
    "Machine %@ is running.":
      "เครื่องเสมือน %@ กำลังทำงาน",
    "Machine %@ was already running.":
      "เครื่องเสมือน %@ ทำงานอยู่แล้ว",
    "Machine:          %@ (%@)":
      "เครื่องเสมือน:    %@ (%@)",
    "Machine:          %@":
      "เครื่องเสมือน:    %@",
    "Machine:          not created - run: cloudmachine-agent vm-setup":
      "เครื่องเสมือน:    ยังไม่ได้สร้าง - เรียกใช้: cloudmachine-agent vm-setup",
    "no answer within the time limit":
      "ไม่มีคำตอบภายในเวลาที่กำหนด",
    "No image %@ in the machine.":
      "ไม่มีอิมเมจ %@ ในเครื่องเสมือน",
    "No image in the machine yet - point Time Machine at the share and let it create one first.":
      "ยังไม่มีอิมเมจในเครื่องเสมือน - ชี้ Time Machine ไปที่แชร์และให้สร้างอิมเมจก่อน",
    "No rclone configuration at %@ - connect Google Drive first (configure-remote).":
      "ไม่มีการตั้งค่า rclone ที่ %@ - เชื่อมต่อ Google Drive ก่อน (configure-remote)",
    "no SMB destination":
      "ไม่มีปลายทาง SMB",
    "One check of the machine's upload buffer: pauses Time Machine when it fills, resumes what it paused.":
      "ตรวจสอบบัฟเฟอร์อัปโหลดของเครื่องเสมือนหนึ่งครั้ง: หยุด Time Machine ชั่วคราวเมื่อเต็ม และเริ่มต่อสิ่งที่หยุดไว้",
    "Packing the converted image failed: %@":
      "แพ็กอิมเมจที่แปลงแล้วไม่สำเร็จ: %@",
    "Packing the image failed: %@":
      "แพ็กอิมเมจไม่สำเร็จ: %@",
    "No answer from the machine (rclone rc) - the guard would do nothing.":
      "ไม่มีคำตอบจากเครื่องเสมือน (rclone rc) - ตัวป้องกันจะไม่ทำอะไร",
    "Only print what the guard would decide - for trying thresholds on a throwaway machine.":
      "พิมพ์เฉพาะสิ่งที่ตัวป้องกันจะตัดสินใจ - สำหรับทดลองเกณฑ์บนเครื่องเสมือนที่ใช้แล้วทิ้ง",
    "Pause above this many GiB in the buffer.":
      "หยุดชั่วคราวเมื่อบัฟเฟอร์เกิน GiB ตามจำนวนนี้",
    "Pause when the machine has less free than this, in GiB.":
      "หยุดชั่วคราวเมื่อเครื่องเสมือนมีพื้นที่ว่างน้อยกว่านี้ เป็น GiB",
    "Point Time Machine at the machine (once, needs an administrator password):":
      "ชี้ Time Machine ไปที่เครื่องเสมือน (ครั้งเดียว ต้องใช้รหัสผ่านผู้ดูแลระบบ):",
    "punchfs files:    %@ open, limit %@":
      "ไฟล์ punchfs:      เปิดอยู่ %@ ขีดจำกัด %@",
    "rclone configuration already in the machine - kept (--replace-rclone-config replaces it).":
      "มีการตั้งค่า rclone ในเครื่องเสมือนอยู่แล้ว - เก็บไว้ (--replace-rclone-config จะแทนที่)",
    "rclone configuration copied into the machine.":
      "คัดลอกการตั้งค่า rclone เข้าเครื่องเสมือนแล้ว",
    "rclone-tm or punchfs is not running in the machine - see cloudmachine-agent vm-status.":
      "rclone-tm หรือ punchfs ไม่ได้ทำงานในเครื่องเสมือน - ดู cloudmachine-agent vm-status",
    "Resume below this many GiB (only a backup the guard paused).":
      "เริ่มต่อเมื่อต่ำกว่า GiB ตามจำนวนนี้ (เฉพาะการสำรองข้อมูลที่ตัวป้องกันหยุดไว้)",
    "Service %@: %@":
      "บริการ %@: %@",
    "Several images in the machine (%@) - choose one with --bundle.":
      "มีหลายอิมเมจในเครื่องเสมือน (%@) - เลือกหนึ่งอิมเมจด้วย --bundle",
    "Shows the machine: address, services, upload buffer, free space and the Time Machine destination.":
      "แสดงเครื่องเสมือน: ที่อยู่ บริการ บัฟเฟอร์อัปโหลด พื้นที่ว่าง และปลายทาง Time Machine",
    "SMB password stored in %@ (mode 600).":
      "รหัสผ่าน SMB เก็บไว้ใน %@ (โหมด 600)",
    "The converted image does not have %@-byte bands.":
      "อิมเมจที่แปลงแล้วไม่มีแบนด์ขนาด %@ ไบต์",
    "The converted image has no APFS partition.":
      "อิมเมจที่แปลงแล้วไม่มีพาร์ทิชัน APFS",
    "The image already takes %@ MB - this command converts only a new, empty image (under %@ MB).":
      "อิมเมจใช้พื้นที่ %@ MB แล้ว - คำสั่งนี้แปลงเฉพาะอิมเมจใหม่ที่ว่างเปล่า (ต่ำกว่า %@ MB)",
    "The image is encrypted - converting encrypted images is not supported.":
      "อิมเมจถูกเข้ารหัส - ไม่รองรับการแปลงอิมเมจที่เข้ารหัส",
    "The image was not changed; smbd started again.":
      "อิมเมจไม่ถูกเปลี่ยนแปลง; smbd เริ่มทำงานอีกครั้ง",
    "The machine does not answer - is it running? cloudmachine-agent vm-status":
      "เครื่องเสมือนไม่ตอบสนอง - กำลังทำงานอยู่หรือไม่? cloudmachine-agent vm-status",
    "The machine has no address on the vzNAT network.":
      "เครื่องเสมือนไม่มีที่อยู่บนเครือข่าย vzNAT",
    "The services in the machine did not start - check: cloudmachine-agent vm-status":
      "บริการในเครื่องเสมือนไม่เริ่มทำงาน - ตรวจสอบ: cloudmachine-agent vm-status",
    "Time Machine is backing up - stop it first: tmutil stopbackup":
      "Time Machine กำลังสำรองข้อมูล - หยุดก่อน: tmutil stopbackup",
    "Time Machine:     %@":
      "Time Machine:      %@",
    "Time Machine:     NOT pointing at the machine (%@)":
      "Time Machine:      ไม่ได้ชี้ไปที่เครื่องเสมือน (%@)",
    "Time Machine:     tmutil did not answer":
      "Time Machine:      tmutil ไม่ตอบสนอง",
    "tmutil did not answer - not touching the image while its state is unknown.":
      "tmutil ไม่ตอบสนอง - ไม่แตะต้องอิมเมจขณะที่ไม่ทราบสถานะ",
    "unknown":
      "ไม่ทราบ",
    "Unpacking the image failed: %@":
      "แตกอิมเมจไม่สำเร็จ: %@",
    "Still to upload:  %@ GiB in %@ bands, uploading %@ (cache on disk %@ GiB)":
      "ยังต้องอัปโหลด:   %@ GiB ใน %@ แบนด์ กำลังอัปโหลด %@ (แคชบนดิสก์ %@ GiB)",
    "Excluded %@ (the machine and its upload buffer) from Time Machine.":
      "ยกเว้น %@ (เครื่องเสมือนและบัฟเฟอร์อัปโหลด) จาก Time Machine แล้ว",
    "WARNING: could not exclude %@ from Time Machine - run: tmutil addexclusion %@":
      "คำเตือน: ยกเว้น %@ จาก Time Machine ไม่ได้ - เรียกใช้: tmutil addexclusion %@",
    "Upload buffer:    no answer from rclone (rc %@)":
      "บัฟเฟอร์อัปโหลด:  ไม่มีคำตอบจาก rclone (rc %@)",
    "When Time Machine has created its empty image, stop the backup (tmutil stopbackup) and run: cloudmachine-agent vm-prepare-bundle":
      "เมื่อ Time Machine สร้างอิมเมจเปล่าแล้ว ให้หยุดการสำรองข้อมูล (tmutil stopbackup) แล้วเรียกใช้: cloudmachine-agent vm-prepare-bundle",
    "Unsent %@ GiB, free %@ GiB (pause above %@ GiB unsent or below %@ GiB free, resume below %@ GiB).":
      "ยังไม่ได้ส่ง %@ GiB ว่าง %@ GiB (หยุดชั่วคราวเมื่อยังไม่ได้ส่งเกิน %@ GiB หรือว่างต่ำกว่า %@ GiB เริ่มต่อเมื่อต่ำกว่า %@ GiB)",
    "Upload:           Google's daily limit refused an upload %@ ago - rclone retries every 5 min and resumes by itself":
      "อัปโหลด:          ขีดจำกัดรายวันของ Google ปฏิเสธการอัปโหลดเมื่อ %@ ที่แล้ว - rclone ลองใหม่ทุก 5 นาทีและจะทำต่อเอง",
    "no":
      "ไม่",
    "running":
      "กำลังทำงาน",
    "stopped":
      "หยุดอยู่",
    "yes":
      "ใช่",
    "%@\nThe previous template is in %@ - copy it back over lima.yaml and run limactl start %@.":
      "%@\nเทมเพลตก่อนหน้าอยู่ใน %@ - คัดลอกกลับไปทับ lima.yaml แล้วเรียกใช้ limactl start %@",
    "Could not read this app's machine template (limactl template copy).":
      "อ่านเทมเพลตเครื่องเสมือนของแอปนี้ไม่ได้ (limactl template copy)",
    "Could not replace %@: %@":
      "แทนที่ %@ ไม่ได้: %@",
    "Machine %@ already runs this app's template.":
      "เครื่องเสมือน %@ ใช้เทมเพลตของแอปนี้อยู่แล้ว",
    "Machine %@ now runs this app's template; the previous one is in %@.":
      "เครื่องเสมือน %@ ใช้เทมเพลตของแอปนี้แล้ว; เทมเพลตก่อนหน้าอยู่ใน %@",
    "Moves the machine onto this app's template (two restarts, never during a backup).":
      "ย้ายเครื่องเสมือนไปใช้เทมเพลตของแอปนี้ (รีสตาร์ทสองครั้ง ไม่ทำระหว่างการสำรองข้อมูล)",
    "No machine %@ - create it with: cloudmachine-agent vm-setup":
      "ไม่มีเครื่องเสมือน %@ - สร้างด้วย: cloudmachine-agent vm-setup",
    "Template:         OLDER than this app's - run: cloudmachine-agent vm-update":
      "เทมเพลต:          เก่ากว่าของแอปนี้ - เรียกใช้: cloudmachine-agent vm-update",
    "Template:         not compared":
      "เทมเพลต:          ไม่ได้เปรียบเทียบ",
    "Template:         this app's":
      "เทมเพลต:          ตรงกับของแอปนี้",
    "The machine has no %@ - run cloudmachine-agent vm-setup first.":
      "เครื่องเสมือนไม่มี %@ - เรียกใช้ cloudmachine-agent vm-setup ก่อน",
    "The machine restarted, but not every service is running - check: cloudmachine-agent vm-status. The previous template is in %@.":
      "เครื่องเสมือนรีสตาร์ทแล้ว แต่บริการไม่ได้ทำงานครบทุกตัว - ตรวจสอบ: cloudmachine-agent vm-status เทมเพลตก่อนหน้าอยู่ใน %@",
    "The template changes the machine itself (%@) - that needs a new machine, not an update.":
      "เทมเพลตเปลี่ยนแปลงตัวเครื่องเสมือนเอง (%@) - ต้องสร้างเครื่องเสมือนใหม่ ไม่ใช่การอัปเดต",
    "The upload to Google Drive hangs":
      "การอัปโหลดไปที่ Google Drive ค้าง",
    "Time Machine is backing up - try again when it has finished.":
      "Time Machine กำลังสำรองข้อมูล - ลองอีกครั้งเมื่อเสร็จแล้ว",
    "Upload:           HANGS - bands in progress, none uploaded for %@ (network?); see /var/log/rclone-tm.log in the machine":
      "อัปโหลด:          ค้าง - มีแบนด์กำลังดำเนินการ ไม่มีการอัปโหลดเป็นเวลา %@ (เครือข่าย?); ดู /var/log/rclone-tm.log ในเครื่องเสมือน",
    "limactl stop failed - nothing was changed.":
      "limactl stop ล้มเหลว - ไม่ได้เปลี่ยนแปลงอะไร",
    "rclone has bands in progress, but none has been uploaded for %@ - usually a broken network connection, which rclone does not report as an error. Backups since then are only in the machine's buffer. When the network comes back the upload resumes by itself (on 28.10.2026 within 80 s); if it does not, restarting the machine (prepare-shutdown, limactl start) drops the dead connections.":
      "rclone มีแบนด์กำลังดำเนินการ แต่ไม่มีการอัปโหลดเป็นเวลา %@ - มักเกิดจากการเชื่อมต่อเครือข่ายขาด ซึ่ง rclone ไม่รายงานเป็นข้อผิดพลาด ข้อมูลสำรองตั้งแต่นั้นมีอยู่ในบัฟเฟอร์ของเครื่องเสมือนเท่านั้น เมื่อเครือข่ายกลับมา การอัปโหลดจะทำต่อเอง (เมื่อ 28.10.2026 ภายใน 80 s) หากไม่ทำต่อ การรีสตาร์ทเครื่องเสมือน (prepare-shutdown, limactl start) จะตัดการเชื่อมต่อที่ตายแล้ว",
    "tmutil did not answer - not restarting the machine while its state is unknown.":
      "tmutil ไม่ตอบสนอง - ไม่รีสตาร์ทเครื่องเสมือนขณะที่ไม่ทราบสถานะ",
    "The machine's share cannot be read":
      "อ่านการแชร์ของเครื่องไม่ได้",
    "Unknown whether the machine's share can be read":
      "ไม่ทราบว่าอ่านการแชร์ของเครื่องได้หรือไม่",
    "Samba in the machine does not answer this Mac":
      "Samba ในเครื่องไม่ตอบ Mac เครื่องนี้",
    "Unknown whether Samba in the machine answers this Mac":
      "ไม่ทราบว่า Samba ในเครื่องตอบ Mac เครื่องนี้หรือไม่",
    "Reading 1 byte of %@ in the machine failed: %@. Every service says it is active, yet Time Machine cannot use the image there. Nothing restarts it by itself. Check: cloudmachine-agent vm-status, then in the machine: journalctl -u punchfs -u tm-bands-bind -u rclone-tm":
      "การอ่าน 1 ไบต์จาก %@ ในเครื่องล้มเหลว: %@ ทุกบริการแจ้งว่าทำงานอยู่ แต่ Time Machine ใช้อิมเมจที่นั่นไม่ได้ ไม่มีสิ่งใดรีสตาร์ทให้เอง ตรวจสอบ: cloudmachine-agent vm-status แล้วในเครื่อง: journalctl -u punchfs -u tm-bands-bind -u rclone-tm",
    "Reading 1 byte of %@ in the machine has not returned for %@ s. That is how a hung punchfs or rclone mount behaves. Nothing is restarted while the state is unknown - a restart under a write still going could lose it. Check in the machine: journalctl -u punchfs -u rclone-tm":
      "การอ่าน 1 ไบต์จาก %@ ในเครื่องยังไม่กลับมาเป็นเวลา %@ วินาที นี่คือลักษณะของการเมานต์ punchfs หรือ rclone ที่ค้าง ระหว่างที่ไม่ทราบสถานะจะไม่มีการรีสตาร์ทใดๆ - การรีสตาร์ทระหว่างการเขียนที่ยังดำเนินอยู่อาจทำให้ข้อมูลนั้นหาย ตรวจสอบในเครื่อง: journalctl -u punchfs -u rclone-tm",
    "An SMB connection to %@ got no answer within %@ s. Time Machine reaches the machine at this address. Check the machine's network and smbd: cloudmachine-agent vm-status":
      "การเชื่อมต่อ SMB ไปยัง %@ ไม่ได้รับคำตอบภายใน %@ วินาที Time Machine เข้าถึงเครื่องที่ที่อยู่นี้ ตรวจสอบเครือข่ายของเครื่องและ smbd: cloudmachine-agent vm-status",
    "The machine did not report its address, so nobody could try an SMB connection. Check: cloudmachine-agent vm-status":
      "เครื่องไม่ได้แจ้งที่อยู่ของตน จึงไม่มีใครลองเชื่อมต่อ SMB ได้ ตรวจสอบ: cloudmachine-agent vm-status",
    "An SMB connection to %@ failed (%@). Time Machine reaches the machine at this address, so no backup is made. Check the machine's network and smbd: cloudmachine-agent vm-status":
      "การเชื่อมต่อ SMB ไปยัง %@ ล้มเหลว (%@) Time Machine เข้าถึงเครื่องที่ที่อยู่นี้ จึงไม่มีการสำรองข้อมูล ตรวจสอบเครือข่ายของเครื่องและ smbd: cloudmachine-agent vm-status",
    "readable":
      "อ่านได้",
    "no image yet":
      "ยังไม่มีอิมเมจ",
    "answers":
      "ตอบ",
    "Share read:       %@":
      "การอ่านการแชร์:   %@",
    "Samba from Mac:   %@":
      "Samba จาก Mac:    %@",
    "This Mac found no route to %@ (%@). Either the route to the machine is gone, or macOS Local Network privacy has not allowed CloudMachine - then allow it in System Settings > Privacy & Security > Local Network. Check: cloudmachine-agent vm-status":
      "Mac เครื่องนี้หาเส้นทางไปยัง %@ ไม่พบ (%@) อาจเป็นเพราะเส้นทางไปยังเครื่องหายไป หรือความเป็นส่วนตัว \"เครือข่ายเฉพาะที่\" ของ macOS ยังไม่อนุญาต CloudMachine - หากเป็นเช่นนั้นให้อนุญาตใน การตั้งค่าระบบ > ความเป็นส่วนตัวและความปลอดภัย > เครือข่ายเฉพาะที่ ตรวจสอบ: cloudmachine-agent vm-status",
  ]
}
