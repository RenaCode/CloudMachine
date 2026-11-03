// Arabic translations, keyed by the English text passed to `L10n.tr`.
extension L10nTranslations {
  static let ar: [String: String] = [
    "Space limit:      %@":
      "حد المساحة:      %@",
    "                  Time Machine quota not set to match - run: %@":
      "                  لم تُضبط حصة Time Machine لتطابقه - شغّل: %@",
    "Sets how much of Google Drive this Mac may use, and prints the Time Machine quota command.":
      "يحدد مقدار ما يمكن لهذا الـ Mac استخدامه من Google Drive، ويطبع أمر حصة Time Machine.",
    "Limit in GB.":
      "الحد بالـ GB.",
    "Limit for this Mac: %@ GB.":
      "الحد لهذا الـ Mac: %@ GB.",
    "Now set the Time Machine quota (needs an administrator password):":
      "اضبط الآن حصة Time Machine (تتطلب كلمة مرور المسؤول):",
    "CloudMachine - verification, Google Drive setup and installation. Called by launchd on a schedule, or by hand from Terminal.":
      "CloudMachine - التحقق وإعداد Google Drive والتثبيت. يستدعيه launchd وفق جدول زمني، أو يدويًا من الطرفية.",
    "Connects to Google Drive through rclone (OAuth in the browser) and creates this machine's folder.":
      "يتصل بـ Google Drive عبر rclone (OAuth في المتصفح) وينشئ مجلد هذا الجهاز الافتراضي.",
    "Overwrite the existing remote. RISKY: replaces the token and permissions.":
      "استبدال الاتصال البعيد الحالي. خطر: يستبدل الرمز والأذونات.",
    "Packs build/CloudMachine.app into build/CloudMachine-<version>.dmg.":
      "يحزّم build/CloudMachine.app في build/CloudMachine-<version>.dmg.",
    "ERROR: %@ is missing - run 'cloudmachine-agent build-app' first":
      "خطأ: %@ غير موجود - شغّل 'cloudmachine-agent build-app' أولًا",
    "==> Preparing the staging folder":
      "==> تجهيز مجلد التجميع",
    "==> Creating %@":
      "==> إنشاء %@",
    "ERROR: hdiutil exited with code %@.":
      "خطأ: انتهى hdiutil برمز الخروج %@.",
    "==> Done: %@":
      "==> تم: %@",
    "On first launch (the app is not signed with an Apple Developer account):":
      "عند التشغيل الأول (التطبيق غير موقّع بحساب مطوّر Apple):",
    "1. Open %@ and drag CloudMachine.app to Applications.":
      "1. افتح %@ واسحب CloudMachine.app إلى مجلد التطبيقات.",
    "2. In Finder, RIGHT-click CloudMachine.app -> Open -> Open\n   (a plain double-click shows the Gatekeeper block \"unidentified developer\").":
      "2. في Finder، انقر بزر الفأرة الأيمن على CloudMachine.app -> فتح -> فتح\n   (النقر المزدوج العادي يُظهر حظر Gatekeeper \"مطوّر غير معروف\").",
    "3. Later launches work normally, with a double-click.":
      "3. عمليات التشغيل اللاحقة تعمل بشكل طبيعي، بنقرة مزدوجة.",
    "Builds CloudMachine.app (Release) - GUI + cloudmachine-agent in Contents/MacOS/, plus launchd/, vm/ and config/ as Resources.":
      "يبني CloudMachine.app (Release) - الواجهة الرسومية + cloudmachine-agent في Contents/MacOS/، إضافةً إلى launchd/ وvm/ وconfig/ كموارد.",
    "Binaries for Apple Silicon and Intel at once (how CI builds a release; unnecessary locally).":
      "ملفات تنفيذية لـ Apple Silicon وIntel معًا (هكذا تبني CI الإصدار؛ غير لازم محليًا).",
    "==> Building CloudMachineApp + cloudmachine-agent (release) - version %@ (%@)":
      "==> بناء CloudMachineApp + cloudmachine-agent (release) - الإصدار %@ (%@)",
    "ERROR: swift build exited with code %@.":
      "خطأ: انتهى swift build برمز الخروج %@.",
    "ERROR: swift build --show-bin-path did not report the binaries directory.":
      "خطأ: لم يُبلغ swift build --show-bin-path عن مجلد الملفات التنفيذية.",
    "ERROR: no built binary found at %@":
      "خطأ: لا يوجد ملف تنفيذي مبني في %@",
    "==> Assembling the .app bundle in %@":
      "==> تجميع حزمة .app في %@",
    "==> WARNING: you are building from a DIRTY tree - the version will not point to a commit.":
      "==> تحذير: أنت تبني من شجرة غير نظيفة - لن يشير الإصدار إلى commit.",
    "ERROR: Resources/AppIcon.icns is missing - generate it: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns":
      "خطأ: Resources/AppIcon.icns غير موجود - أنشئه: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns",
    "==> Signing with the local certificate '%@' (Full Disk Access will survive later rebuilds)":
      "==> التوقيع بالشهادة المحلية '%@' (سيبقى الوصول الكامل إلى القرص بعد إعادة البناء لاحقًا)",
    "==> Signing ad-hoc (no Apple Developer account) - run 'cloudmachine-agent setup-signing-cert' once so that TCC permissions survive later rebuilds":
      "==> توقيع ad-hoc (دون حساب مطوّر Apple) - شغّل 'cloudmachine-agent setup-signing-cert' مرة واحدة لتبقى أذونات TCC بعد إعادة البناء لاحقًا",
    "ERROR: codesign exited with code %@.":
      "خطأ: انتهى codesign برمز الخروج %@.",
    "Next step: %@":
      "الخطوة التالية: %@",
    "Creates a local self-signed certificate so that Full Disk Access survives later rebuilds of the app.":
      "ينشئ شهادة محلية موقّعة ذاتيًا لكي يبقى الوصول الكامل إلى القرص بعد إعادة بناء التطبيق لاحقًا.",
    "Certificate '%@' already exists in %@, nothing to do.":
      "الشهادة '%@' موجودة بالفعل في %@، لا حاجة لأي إجراء.",
    "==> Generating the key and self-signed certificate '%@'...":
      "==> إنشاء المفتاح والشهادة الموقّعة ذاتيًا '%@'...",
    "ERROR: openssl req exited with code %@.":
      "خطأ: انتهى openssl req برمز الخروج %@.",
    "ERROR: openssl pkcs12 exited with code %@.":
      "خطأ: انتهى openssl pkcs12 برمز الخروج %@.",
    "==> Importing the certificate into %@ (pre-authorizing /usr/bin/codesign, so it does not ask for the keychain password every time)...":
      "==> استيراد الشهادة إلى %@ (مع تفويض /usr/bin/codesign مسبقًا لكي لا يطلب كلمة مرور سلسلة المفاتيح كل مرة)...",
    "ERROR: security import exited with code %@.":
      "خطأ: انتهى security import برمز الخروج %@.",
    "==> Trusting the certificate ONLY for code signing...":
      "==> الوثوق بالشهادة لتوقيع الشيفرة فقط...",
    "ERROR: security add-trusted-cert exited with code %@.":
      "خطأ: انتهى security add-trusted-cert برمز الخروج %@.",
    "Done. Certificate '%@' is now available to codesign.":
      "تم. الشهادة '%@' متاحة الآن لـ codesign.",
    "The next 'cloudmachine-agent build-app' will use it automatically instead of an ad-hoc signature.":
      "سيستخدمها 'cloudmachine-agent build-app' التالي تلقائيًا بدل توقيع ad-hoc.",
    "After THAT ONE rebuild, grant Full Disk Access one last time - later\nrebuilds will no longer reset it, as long as you sign with the same certificate.":
      "بعد إعادة البناء تلك مرة واحدة، امنح الوصول الكامل إلى القرص مرة أخيرة - ولن\nتُعيد عمليات إعادة البناء اللاحقة ضبطه ما دمت توقّع بالشهادة نفسها.",
    "Checks whether the hourly cycle STILL works (date of the last SUCCESSFUL backup) and reports failures.":
      "يتحقق من أن الدورة كل ساعة ما زالت تعمل (تاريخ آخر نسخة احتياطية ناجحة) ويبلّغ عن الأعطال.",
    "After this many hours without a successful backup we consider the cycle broken.":
      "بعد هذا العدد من الساعات دون نسخة احتياطية ناجحة نعدّ الدورة معطلة.",
    "Only print the state, without a system notification.":
      "طباعة الحالة فقط، دون إشعار من النظام.",
    "A different Time Machine preferences file - to test the watchdog on a known sample.":
      "ملف تفضيلات Time Machine آخر - لاختبار المراقب على عيّنة معروفة.",
    "Last successful backup: %@":
      "آخر نسخة احتياطية ناجحة: %@",
    "Last successful backup: NONE":
      "آخر نسخة احتياطية ناجحة: لا توجد",
    "Last attempt:           %@":
      "آخر محاولة:           %@",
    "WAITING (system startup): %@":
      "قيد الانتظار (بدء تشغيل النظام): %@",
    "Backup cycle: OK":
      "دورة النسخ الاحتياطي: سليمة",
    "FAILURE: %@":
      "عطل: %@",
    "         %@":
      "         %@",
    "Check the state:  %@":
      "فحص الحالة:  %@",
    "Preparing for restart":
      "جارٍ التحضير لإعادة التشغيل",
    "Prepare for restart":
      "التحضير لإعادة التشغيل",
    "Prepare":
      "تحضير",
    "==> WARNING: git rev-list failed (%@) - using the date as the build number.":
      "==> تحذير: فشل git rev-list (%@) - سيُستخدم التاريخ رقمًا للبناء.",
    "Agents:           %@":
      "الوكلاء:           %@",
    "CANNOT START: %@ - open CloudMachine or run backup-health to reload them":
      "تعذّر البدء: %@ - افتح CloudMachine أو شغّل backup-health لإعادة تحميلها",
    "Reloaded agents that could not start: %@":
      "أُعيد تحميل الوكلاء الذين تعذّر بدؤهم: %@",
    "Drive folder:     %@":
      "مجلد Drive:     %@",
    "Name of this Mac's folder on Google Drive (default: derived from the computer name). Set once; it cannot be changed later.":
      "اسم مجلد هذا الـ Mac على Google Drive (الافتراضي: مشتق من اسم الكمبيوتر). يُضبط مرة واحدة ولا يمكن تغييره لاحقًا.",
    "Backup watchdog:  %@":
      "مراقب النسخ الاحتياطي:  %@",
    "Prints the version, the build number and the commit this binary was built from.":
      "يطبع الإصدار ورقم البناء والـ commit الذي بُني منه هذا الملف التنفيذي.",
    "Only one line, without a description.":
      "سطر واحد فقط، دون وصف.",
    "Build from the working tree (outside a bundle) - no version data.":
      "بناء من شجرة العمل (خارج حزمة) - لا توجد بيانات إصدار.",
    "Version: %@":
      "الإصدار: %@",
    "Build:   %@":
      "البناء:   %@",
    "Commit:  %@":
      "Commit:  %@",
    "WARNING: built from a DIRTY tree - the binary contains code that\n         is in no commit. The commit number does NOT describe\n         what actually runs.":
      "تحذير: بُني من شجرة غير نظيفة - يحتوي الملف التنفيذي على شيفرة\n         ليست في أي commit. رقم الـ commit لا يصف\n         ما يعمل فعليًا.",
    "Saving the space limit":
      "حفظ حد المساحة",
    "Measuring usage on Google Drive":
      "قياس الاستخدام على Google Drive",
    "Google Drive did not answer - try again later.":
      "لم يستجب Google Drive - حاول مرة أخرى لاحقًا.",
    "Measured.":
      "تم القياس.",
    "Space limit for this Mac":
      "حد المساحة لهذا الـ Mac",
    "Used on Google Drive":
      "المستخدم على Google Drive",
    "Measured %@. The watchdog measures again every few hours.":
      "قِيس في %@. يعيد المراقب القياس كل بضع ساعات.",
    "Limit (GB)":
      "الحد (GB)",
    "Save":
      "حفظ",
    "Measure now":
      "قِس الآن",
    "Time Machine quota: %@ GB (70%% of the limit - the copy on Drive is about a third larger than the backup inside it). Time Machine deletes the oldest backups to stay within it.":
      "حصة Time Machine: %@ GB (70%% من الحد - نسخة Drive أكبر بنحو الثلث من النسخة الاحتياطية بداخلها). يحذف Time Machine أقدم النسخ الاحتياطية لتبقى ضمنها.",
    "Set the Time Machine quota: run this in Terminal (needs sudo)":
      "اضبط حصة Time Machine: شغّل هذا في الطرفية (يتطلب sudo)",
    "Connect Google Drive: run this in Terminal and approve in the browser":
      "اربط Google Drive: شغّل هذا في الطرفية ووافق في المتصفح",
    "Grant Full Disk Access to CloudMachine, so it can tell whether backups complete":
      "امنح CloudMachine الوصول الكامل إلى القرص ليعرف ما إذا اكتملت النسخ الاحتياطية",
    "Folder on Google Drive":
      "المجلد على Google Drive",
    "One folder per Mac. Set once - it cannot be changed after connecting.":
      "مجلد واحد لكل Mac. يُضبط مرة واحدة - لا يمكن تغييره بعد الاتصال.",
    "Use lowercase letters, digits and dashes.":
      "استخدم أحرفًا لاتينية صغيرة وأرقامًا وشرطات.",
    "Install rclone":
      "تثبيت rclone",
    "Open System Settings":
      "فتح إعدادات النظام",
    "Install agents":
      "تثبيت الوكلاء",
    "not checked":
      "لم يُفحص",
    "none at all":
      "لا شيء إطلاقًا",
    "%@ ago":
      "منذ %@",
    "Missing: %@":
      "مفقود: %@",
    "Google Drive not connected":
      "Google Drive غير متصل",
    "Time Machine does not point to CloudMachine":
      "Time Machine لا يشير إلى CloudMachine",
    "UNKNOWN whether Time Machine points to CloudMachine - tmutil did not answer":
      "غير معروف ما إذا كان Time Machine يشير إلى CloudMachine - لم يستجب tmutil",
    "Backup in progress":
      "النسخ الاحتياطي قيد التنفيذ",
    "Unknown when the last backup was made":
      "موعد آخر نسخة احتياطية غير معروف",
    "There is no completed backup at all":
      "لا توجد أي نسخة احتياطية مكتملة",
    "No completed backup for %@":
      "لا توجد نسخة احتياطية مكتملة منذ %@",
    "Ready":
      "جاهز",
    "Not saved: %@":
      "لم يُحفظ: %@",
    "Installing rclone":
      "تثبيت rclone",
    "Installing launchd agents":
      "تثبيت وكلاء launchd",
    "Starting backup":
      "بدء النسخ الاحتياطي",
    "Backup started.":
      "بدأ النسخ الاحتياطي.",
    "Could not start the backup.":
      "تعذّر بدء النسخ الاحتياطي.",
    "Stopping backup":
      "إيقاف النسخ الاحتياطي",
    "Backup stopped.":
      "توقف النسخ الاحتياطي.",
    "Could not stop the backup.":
      "تعذّر إيقاف النسخ الاحتياطي.",
    "Could not prepare the AppleScript.":
      "تعذّر تجهيز AppleScript.",
    "Unknown authorization error.":
      "خطأ تفويض غير معروف.",
    "Waiting to upload":
      "بانتظار الرفع",
    "%@ files":
      "الملفات: %@",
    "nothing":
      "لا شيء",
    "Back up now":
      "نسخ احتياطي الآن",
    "Stop backup":
      "إيقاف النسخ الاحتياطي",
    "Open CloudMachine":
      "فتح CloudMachine",
    "Quit":
      "إنهاء",
    "Healthy":
      "سليم",
    "Attention":
      "تنبيه",
    "Refreshed %@":
      "حُدّث %@",
    "System Status":
      "حالة النظام",
    "Action needed":
      "إجراء مطلوب",
    "not measured":
      "لم يُقَس",
    "rclone did not answer":
      "لم يستجب rclone",
    "Backup in Progress":
      "النسخ الاحتياطي قيد التنفيذ",
    "Files processed":
      "الملفات المعالَجة",
    "Write speed":
      "سرعة الكتابة",
    "Operation phase":
      "مرحلة العملية",
    "Required Setup Steps":
      "خطوات الإعداد المطلوبة",
    "Copy":
      "نسخ",
    "Last completed backup":
      "آخر نسخة احتياطية مكتملة",
    "Last backup watchdog run":
      "آخر تشغيل لمراقب النسخ الاحتياطي",
    "not read":
      "لم يُقرأ",
    "Everything uploaded":
      "تم رفع كل شيء",
    "File upload errors":
      "أخطاء رفع الملفات",
    "Google Drive Credentials (OAuth 2.0)":
      "بيانات اعتماد Google Drive (OAuth 2.0)",
    "Keychain OK":
      "سلسلة المفاتيح سليمة",
    "No custom keys":
      "لا مفاتيح مخصصة",
    "Paste client_id...":
      "الصق client_id...",
    "Paste client_secret...":
      "الصق client_secret...",
    "Save securely in the Keychain":
      "احفظ بأمان في سلسلة المفاتيح",
    "Refresh":
      "تحديث",
    "Overview":
      "نظرة عامة",
    "Backups":
      "النسخ الاحتياطية",
    "Storage":
      "التخزين",
    "Settings":
      "الإعدادات",
    "Current status: %@":
      "الحالة الحالية: %@",
    "Does not point to CloudMachine":
      "لا يشير إلى CloudMachine",
    "tmutil did not answer":
      "لم يستجب tmutil",
    "Backing up: %@ of %@":
      "جارٍ النسخ الاحتياطي: %@ من %@",
    "%@ of %@":
      "%@ من %@",
    "Copied":
      "تم النسخ",
    "No backup is running":
      "لا يوجد نسخ احتياطي قيد التنفيذ",
    "Time Machine starts the next one on its own schedule.":
      "يبدأ Time Machine النسخة التالية وفق جدوله.",
    "Backup cycle":
      "دورة النسخ الاحتياطي",
    "%@ GiB":
      "%@ GiB",
    "%@ GiB in %@ bands, %@ uploading":
      "%@ GiB في %@ أجزاء، يجري رفع %@",
    "%@ bands":
      "الأجزاء: %@",
    "%@ fragments abandoned - only in the machine":
      "%@ مقاطع متروكة - موجودة في الجهاز الافتراضي فقط",
    "127.0.0.1:5572 answers on the Mac: Lima forwards the machine's rclone remote control, which has no password. Any web page open in a browser can send it commands - including deleting the backup on Google Drive. Add the portForwards rule from vm/cmsmb.yaml to the machine and restart it (see vm/README.md).":
      "يستجيب 127.0.0.1:5572 على الـ Mac: تعيد Lima توجيه التحكم عن بُعد لـ rclone في الجهاز الافتراضي، وهو بلا كلمة مرور. يمكن لأي صفحة ويب مفتوحة في المتصفح إرسال أوامر إليه - بما فيها حذف النسخة الاحتياطية على Google Drive. أضف قاعدة portForwards من vm/cmsmb.yaml إلى الجهاز الافتراضي وأعد تشغيله (انظر vm/README.md).",
    "A service in the CloudMachine machine is not running":
      "خدمة في الجهاز الافتراضي لـ CloudMachine لا تعمل",
    "Address":
      "العنوان",
    "Agent installation INCOMPLETE - %@ of %@ did not go in:\n%@\n%@\nEvery missing agent is a function that has silently stopped working (vm-guard watches the machine's buffer, backup-health reports failures). Fix the cause and repeat the installation.":
      "تثبيت الوكلاء غير مكتمل - لم يُثبَّت %@ من %@:\n%@\n%@\nكل وكيل مفقود هو وظيفة توقفت بصمت (يراقب vm-guard المخزن المؤقت للجهاز الافتراضي، ويبلّغ backup-health عن الأعطال). عالج السبب وكرر التثبيت.",
    "All running":
      "الكل يعمل",
    "Also install the launchd agents (same as install-launchd).":
      "ثبّت أيضًا وكلاء launchd (مثل install-launchd).",
    "At most this many minutes of waiting for the upload.":
      "الحد الأقصى بالدقائق لانتظار الرفع.",
    "At the limit every new band fails with EMFILE and the backup stops. Check: cloudmachine-agent vm-status":
      "عند بلوغ الحد يفشل كل جزء جديد بالخطأ EMFILE ويتوقف النسخ الاحتياطي. تحقق: cloudmachine-agent vm-status",
    "Cache on the machine's disk":
      "ذاكرة تخزين مؤقت على قرص الجهاز الافتراضي",
    "Connected to Google Drive, but could not create the folder '%@' - without it the machine has nowhere to keep the backup. Check the account permissions and try again.":
      "تم الاتصال بـ Google Drive، لكن تعذّر إنشاء المجلد '%@' - ومن دونه لا يملك الجهاز الافتراضي مكانًا لحفظ النسخة الاحتياطية. تحقق من أذونات الحساب وحاول مرة أخرى.",
    "Convert the image":
      "تحويل صورة القرص",
    "Converting the image to 32 MB bands":
      "تحويل الصورة إلى أجزاء بحجم 32 MB",
    "Could not check with the current connection whether the backup is on Google Drive (%@), so remote '%@' was NOT replaced: without that answer the new sign-in cannot be checked against it.":
      "تعذّر التحقق عبر الاتصال الحالي مما إذا كانت النسخة الاحتياطية على Google Drive (%@)، لذا لم يُستبدل الاتصال البعيد '%@': ومن دون هذا الجواب لا يمكن مطابقة تسجيل الدخول الجديد معها.",
    "Downloads the official rclone binary into ~/.cloudmachine/bin (Google sign-in and the machine's rclone.conf).":
      "ينزّل ملف rclone التنفيذي الرسمي إلى ~/.cloudmachine/bin (تسجيل الدخول إلى Google وملف rclone.conf الخاص بالجهاز الافتراضي).",
    "Free in the machine":
      "المتاح في الجهاز الافتراضي",
    "Free in the machine: %@":
      "المتاح في الجهاز الافتراضي: %@",
    "Generates and installs the launchd agents (app, backup watchdog, machine start, machine guard).":
      "ينشئ وكلاء launchd ويثبّتهم (التطبيق، مراقب النسخ الاحتياطي، تشغيل الجهاز الافتراضي، حارس الجهاز الافتراضي).",
    "Install Lima, which runs the CloudMachine machine: run this in Terminal":
      "ثبّت Lima التي تشغّل الجهاز الافتراضي لـ CloudMachine: شغّل هذا في الطرفية",
    "Install rclone (signs in to Google Drive for the machine)":
      "ثبّت rclone (يسجّل الدخول إلى Google Drive للجهاز الافتراضي)",
    "Install the background agents (machine start, buffer guard, backup watchdog)":
      "ثبّت وكلاء الخلفية (تشغيل الجهاز الافتراضي، حارس المخزن المؤقت، مراقب النسخ الاحتياطي)",
    "Installs rclone through Homebrew - CloudMachine itself uses the one from install-rclone.":
      "يثبّت rclone عبر Homebrew - يستخدم CloudMachine نفسه النسخة من install-rclone.",
    "Info.plist, token and mapped/ of the backup image exist only on the machine's disk; without them the bands in %@ cannot be restored. The copy (tm-meta-sync, every 15 min) goes to %@. Check: cloudmachine-agent vm-status, then in the machine: journalctl -u tm-meta-sync":
      "توجد Info.plist والرمز وmapped/ الخاصة بصورة النسخ الاحتياطي على قرص الجهاز الافتراضي فقط؛ ومن دونها لا يمكن استعادة الأجزاء في %@. تذهب النسخة (tm-meta-sync، كل 15 دقيقة) إلى %@. تحقق: cloudmachine-agent vm-status، ثم في الجهاز الافتراضي: journalctl -u tm-meta-sync",
    "Lima says the machine is running, but a command in it did not return. Without it nothing is known about Samba, rclone or the upload. Check: cloudmachine-agent vm-status":
      "تقول Lima إن الجهاز الافتراضي يعمل، لكن أمرًا فيه لم يعد. ومن دونه لا يُعرف شيء عن Samba أو rclone أو الرفع. تحقق: cloudmachine-agent vm-status",
    "Machine":
      "الجهاز الافتراضي",
    "Machine %@":
      "الجهاز الافتراضي %@",
    "Machine & Upload Status":
      "حالة الجهاز الافتراضي والرفع",
    "Machine buffer":
      "المخزن المؤقت للجهاز الافتراضي",
    "No Time Machine destination is the machine's share (smb://tm@<address>/CloudMachine) - backups are not being made there. The command is printed by: cloudmachine-agent vm-setup":
      "لا توجد وجهة Time Machine هي مشاركة الجهاز الافتراضي (smb://tm@<address>/CloudMachine) - لا تُجرى نسخ احتياطية هناك. يُطبع الأمر بواسطة: cloudmachine-agent vm-setup",
    "Not running: %@":
      "لا يعمل: %@",
    "Not set up":
      "غير مُعدّ",
    "Once it runs out, rclone stops uploading, the machine's buffer fills up and backups stop being made. At a growth of ~600 MB per hourly cycle that is about %@ days.":
      "عند نفاده يتوقف rclone عن الرفع، ويمتلئ المخزن المؤقت للجهاز الافتراضي، وتتوقف النسخ الاحتياطية. وبمعدل نمو نحو 600 MB لكل دورة ساعية يعني ذلك نحو %@ أيام.",
    "Or rclone.conf is missing: this Mac has already set up the CloudMachine machine, so it is not connected anew blindly. Restore the file from a backup (the machine keeps its own copy in %@). To connect anyway, create an empty file at the path `%@ config file` prints and run again - the existing folder is kept.":
      "أو أن rclone.conf مفقود: سبق أن أعدّ هذا الـ Mac الجهاز الافتراضي لـ CloudMachine، لذا لا يُوصَل من جديد دون تحقق. استعد الملف من نسخة احتياطية (يحتفظ الجهاز الافتراضي بنسخته الخاصة في %@). للاتصال رغم ذلك، أنشئ ملفًا فارغًا في المسار الذي يطبعه `%@ config file` وشغّل الأمر مجددًا - يبقى المجلد الحالي.",
    "Point Time Machine at the machine: run this in Terminal (needs sudo; Copy includes the password)":
      "وجّه Time Machine إلى الجهاز الافتراضي: شغّل هذا في الطرفية (يتطلب sudo؛ نسخ يتضمن كلمة المرور)",
    "Points to the machine":
      "يشير إلى الجهاز الافتراضي",
    "Prepares for a restart: stops the backup, waits a while for the upload, then stops the machine cleanly.":
      "يتحضر لإعادة التشغيل: يوقف النسخ الاحتياطي، وينتظر قليلًا اكتمال الرفع، ثم يوقف الجهاز الافتراضي بشكل سليم.",
    "Reading the Time Machine destination did not return within %@ s. That is how tmutil behaves when its destination hangs.":
      "لم تعد قراءة وجهة Time Machine خلال %@ s. هذا سلوك tmutil حين تتعلق وجهته.",
    "Remote '%@' was NOT replaced. The new sign-in gets the 'drive.file' scope, which sees only files created under its own client_id. The existing backup was most likely created by the current connection and would become invisible to it. Before anything is written, the new token is checked against the existing backup, and the replacement is abandoned if it cannot see it. The machine keeps its own copy of the configuration until vm-setup --replace-rclone-config. To go ahead, run again with --replace-existing --accept-scope-change.":
      "لم يُستبدل الاتصال البعيد '%@'. يحصل تسجيل الدخول الجديد على النطاق 'drive.file' الذي لا يرى إلا الملفات المنشأة تحت client_id الخاص به. على الأرجح أُنشئت النسخة الاحتياطية الحالية بالاتصال الحالي وستصبح غير مرئية له. قبل كتابة أي شيء، يُفحص الرمز الجديد مقابل النسخة الاحتياطية الحالية، ويُلغى الاستبدال إن لم يستطع رؤيتها. يحتفظ الجهاز الافتراضي بنسخته الخاصة من الإعدادات حتى vm-setup --replace-rclone-config. للمتابعة، شغّل الأمر مجددًا مع --replace-existing --accept-scope-change.",
    "Remote control:   OPEN on the Mac at 127.0.0.1:5572 - any web page can send rclone commands; see vm/README.md (portForwards)":
      "التحكم عن بُعد:   مفتوح على الـ Mac عند 127.0.0.1:5572 - يمكن لأي صفحة ويب إرسال أوامر rclone؛ انظر vm/README.md (portForwards)",
    "Running":
      "يعمل",
    "Samba, rclone or punchfs in the machine is not active, so Time Machine has nowhere to write or the bands do not reach Google Drive. Check: cloudmachine-agent vm-status":
      "Samba أو rclone أو punchfs في الجهاز الافتراضي غير نشطة، فلا يجد Time Machine مكانًا للكتابة أو لا تصل الأجزاء إلى Google Drive. تحقق: cloudmachine-agent vm-status",
    "Service %@":
      "الخدمة %@",
    "Services":
      "الخدمات",
    "Set up the CloudMachine machine (the first time it downloads Ubuntu - several minutes)":
      "أعدّ الجهاز الافتراضي لـ CloudMachine (ينزّل Ubuntu في المرة الأولى - عدة دقائق)",
    "Set up the CloudMachine machine again, so it prints the Time Machine command":
      "أعد إعداد الجهاز الافتراضي لـ CloudMachine ليطبع أمر Time Machine",
    "Set up the machine":
      "إعداد الجهاز الافتراضي",
    "Setting up the CloudMachine machine":
      "جارٍ إعداد الجهاز الافتراضي لـ CloudMachine",
    "Start the CloudMachine machine":
      "شغّل الجهاز الافتراضي لـ CloudMachine",
    "Start the machine":
      "تشغيل الجهاز الافتراضي",
    "Starting the CloudMachine machine":
      "جارٍ تشغيل الجهاز الافتراضي لـ CloudMachine",
    "Still to upload: %@ GiB":
      "المتبقي للرفع: %@ GiB",
    "Stopping the Time Machine backup...":
      "جارٍ إيقاف النسخ الاحتياطي لـ Time Machine...",
    "Stopping the machine %@...":
      "جارٍ إيقاف الجهاز الافتراضي %@...",
    "The CloudMachine machine does not answer":
      "الجهاز الافتراضي لـ CloudMachine لا يستجيب",
    "The CloudMachine machine is not running":
      "الجهاز الافتراضي لـ CloudMachine لا يعمل",
    "The CloudMachine machine is not set up yet":
      "الجهاز الافتراضي لـ CloudMachine لم يُعدّ بعد",
    "The CloudMachine machine is stopped":
      "الجهاز الافتراضي لـ CloudMachine متوقف",
    "The backup is stopped, the upload gets up to 30 minutes, then the machine shuts down cleanly. It starts again at the next login.":
      "توقف النسخ الاحتياطي، وتُمنح عملية الرفع حتى 30 دقيقة، ثم يُغلق الجهاز الافتراضي بشكل سليم. يبدأ من جديد عند تسجيل الدخول التالي.",
    "The machine %@ is not running - nothing to prepare.":
      "الجهاز الافتراضي %@ لا يعمل - لا شيء للتحضير.",
    "The machine is stopped and everything reached Google Drive. The Mac can be restarted; the machine starts again at login.":
      "الجهاز الافتراضي متوقف ووصل كل شيء إلى Google Drive. يمكن إعادة تشغيل الـ Mac؛ يبدأ الجهاز الافتراضي من جديد عند تسجيل الدخول.",
    "The machine is stopped. %@ GiB had not reached Google Drive yet - it is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "الجهاز الافتراضي متوقف. لم يصل %@ GiB إلى Google Drive بعد - محفوظة في المخزن المؤقت للجهاز الافتراضي وستُرفع بعد التشغيل التالي. يمكن إعادة تشغيل الـ Mac.",
    "The machine is stopped. rclone did not say how much was still to upload; what was not uploaded is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "الجهاز الافتراضي متوقف. لم يذكر rclone مقدار ما بقي للرفع؛ ما لم يُرفع محفوظ في المخزن المؤقت للجهاز الافتراضي وسيُرفع بعد التشغيل التالي. يمكن إعادة تشغيل الـ Mac.",
    "The machine's disk is a file on this disk and grows as the upload buffer fills. With no space left the machine cannot write the buffer, and Time Machine's local snapshots have nowhere to go either.":
      "قرص الجهاز الافتراضي ملف على هذا القرص ويكبر مع امتلاء المخزن المؤقت للرفع. وعند نفاد المساحة لا يستطيع الجهاز الافتراضي كتابة المخزن المؤقت، ولا تجد اللقطات المحلية لـ Time Machine مكانًا تذهب إليه.",
    "The image's metadata has never been copied to Drive":
      "لم تُنسخ بيانات تعريف الصورة إلى Drive قط",
    "The image's metadata was last copied to Drive %@ ago":
      "نُسخت بيانات تعريف الصورة إلى Drive آخر مرة منذ %@",
    "The machine's disk is running out of space (%@ GB)":
      "مساحة قرص الجهاز الافتراضي توشك على النفاد (%@ GB)",
    "The new sign-in does NOT see the existing backup (%@), so remote '%@' was NOT replaced and rclone.conf is unchanged. Keep the current connection, or sign in with the credential (client_id) that created the backup.":
      "لا يرى تسجيل الدخول الجديد النسخة الاحتياطية الحالية (%@)، لذا لم يُستبدل الاتصال البعيد '%@' ولم يتغير rclone.conf. أبقِ الاتصال الحالي، أو سجّل الدخول ببيانات الاعتماد (client_id) التي أنشأت النسخة الاحتياطية.",
    "The upload buffer lives on this disk. The guard pauses Time Machine before it fills; if the upload does not catch up, backups stay paused.":
      "يوجد المخزن المؤقت للرفع على هذا القرص. يوقف الحارس Time Machine مؤقتًا قبل أن يمتلئ؛ وإن لم يلحق الرفع، تبقى النسخ الاحتياطية متوقفة.",
    "These bands exist only in the machine's buffer. The backup on Google Drive is INCOMPLETE and may not open.":
      "هذه الأجزاء موجودة في المخزن المؤقت للجهاز الافتراضي فقط. النسخة الاحتياطية على Google Drive غير مكتملة وقد لا تُفتح.",
    "Time Machine backs up to the machine, so without it no backup is made. Start it: limactl start %@ (or the Start button in the app).":
      "يجري Time Machine النسخ الاحتياطي إلى الجهاز الافتراضي، ومن دونه لا تُجرى أي نسخة احتياطية. شغّله: limactl start %@ (أو زر \"تشغيل الجهاز الافتراضي\" في التطبيق).",
    "Time Machine did not stop its backup within 2 minutes (or tmutil did not answer) - the machine was NOT stopped. Try again in a moment.":
      "لم يوقف Time Machine نسخه الاحتياطي خلال دقيقتين (أو لم يستجب tmutil) - لم يُوقف الجهاز الافتراضي. حاول مرة أخرى بعد قليل.",
    "Time Machine has created its image: stop the backup, then convert the image to 32 MB bands":
      "أنشأ Time Machine صورته: أوقف النسخ الاحتياطي، ثم حوّل الصورة إلى أجزاء بحجم 32 MB",
    "To upload":
      "للرفع",
    "Unknown whether the CloudMachine machine is running":
      "غير معروف ما إذا كان الجهاز الافتراضي لـ CloudMachine يعمل",
    "Waiting for the upload to Google Drive (at most %@ min)...":
      "بانتظار الرفع إلى Google Drive (%@ دقيقة كحد أقصى)...",
    "With --replace-existing: confirms that the new sign-in (scope 'drive.file') may not see the existing backup. The new token is still checked against the backup first.":
      "مع --replace-existing: يؤكد أن تسجيل الدخول الجديد (النطاق 'drive.file') قد لا يرى النسخة الاحتياطية الحالية. يُفحص الرمز الجديد مقابل النسخة الاحتياطية أولًا في كل الأحوال.",
    "Without it there is no way to check whether anything reached the Drive - the machine's guard is blind then.":
      "من دونه لا توجد طريقة للتحقق مما إذا كان أي شيء قد وصل إلى Drive - حارس الجهاز الافتراضي أعمى حينها.",
    "limactl did not answer":
      "لم يستجب limactl",
    "limactl did not answer (or is not installed). That does not mean the machine is down - it means nobody has checked.":
      "لم يستجب limactl (أو غير مثبّت). هذا لا يعني أن الجهاز الافتراضي متوقف - بل يعني أن أحدًا لم يتحقق.",
    "limactl start failed: %@":
      "فشل limactl start: %@",
    "limactl stop failed: %@":
      "فشل limactl stop: %@",
    "punchfs is close to its open-file limit":
      "punchfs يقترب من حد الملفات المفتوحة",
    "punchfs open files":
      "ملفات punchfs المفتوحة",
    "rclone's remote control is open on this Mac":
      "التحكم عن بُعد في rclone مفتوح على هذا الـ Mac",
    "statfs('/System/Volumes/Data') returned an error, so nobody knows whether the machine's disk can still grow on this Mac.":
      "أعاد statfs('/System/Volumes/Data') خطأً، لذا لا يعرف أحد ما إذا كان قرص الجهاز الافتراضي يستطيع النمو أكثر على هذا الـ Mac.",
    "Google Drive's daily upload limit stops the upload":
      "حد الرفع اليومي في Google Drive يوقف الرفع",
    "Google last refused an upload %@ ago (750 GB a day). Backups since then are only in the machine's buffer on this Mac. rclone retries every 5 min and resumes by itself when the limit passes; the guard pauses Time Machine if more than %@ GiB waits.":
      "رفضت Google رفعًا آخر مرة منذ %@ (750 GB في اليوم). النسخ الاحتياطية منذ ذلك الحين موجودة في المخزن المؤقت للجهاز الافتراضي على هذا الـ Mac فقط. يعيد rclone المحاولة كل 5 دقائق ويستأنف تلقائيًا عند زوال الحد؛ ويوقف الحارس Time Machine مؤقتًا إذا انتظر أكثر من %@ GiB.",
    "Usage on Google Drive is not being measured":
      "استخدام Google Drive غير مقيس",
    "The last measurement (%@ GB) is from %@, %@ ago - rclone size has not answered since. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "آخر قياس (%@ GB) كان في %@، منذ %@ - ولم يستجب rclone size منذ ذلك الحين. وإلى أن يستجيب، لا شيء يراقب الحد %@ GB: تبقى تنبيهات 90%% و100%% صامتة. تحقق من vm-status، أو اضغط قِس الآن في النافذة.",
    "rclone size has not answered even once. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "لم يستجب rclone size ولو مرة واحدة. وإلى أن يستجيب، لا شيء يراقب الحد %@ GB: تبقى تنبيهات 90%% و100%% صامتة. تحقق من vm-status، أو اضغط قِس الآن في النافذة.",
    "Saved in the Keychain. Connecting Google Drive (configure-remote) will use them.":
      "حُفظ في سلسلة المفاتيح. سيستخدمها اتصال Google Drive (configure-remote).",
    "Saved in the Keychain. The existing Google Drive connection keeps its old client_id, and on this Mac it should stay that way: a connection made with the new keys (the 'drive.file' scope) cannot see the backup created by the old one. Do not replace the connection here; the new keys are for a Mac that is not connected yet.":
      "حُفظ في سلسلة المفاتيح. يحتفظ اتصال Google Drive الحالي بـ client_id القديم، وعلى هذا الـ Mac ينبغي أن يبقى كذلك: الاتصال المنشأ بالمفاتيح الجديدة (النطاق 'drive.file') لا يرى النسخة الاحتياطية التي أنشأها الاتصال القديم. لا تستبدل الاتصال هنا؛ المفاتيح الجديدة لـ Mac غير متصل بعد.",
    "it is not there for the new token":
      "غير موجود للرمز الجديد",
    "Cancel":
      "إلغاء",
    "ACTION NEEDED":
      "إجراء مطلوب",
    "WILL PASS BY ITSELF — DO NOTHING":
      "سيزول من تلقاء نفسه - لا تفعل شيئًا",
    "UNKNOWN — CHECK AGAIN SHORTLY":
      "غير معروف - تحقق مجددًا بعد قليل",
    "ALL GOOD":
      "كل شيء على ما يرام",
    "Upload is not working":
      "الرفع لا يعمل",
    "Upload stopped — no space left on Google Drive":
      "توقف الرفع - لا توجد مساحة على Google Drive",
    "%@ backup fragments not uploaded":
      "%@ مقاطع من النسخة الاحتياطية لم تُرفع",
    "Upload cannot keep up with writes":
      "الرفع لا يواكب الكتابة",
    "Upload paused — Google daily limit":
      "الرفع متوقف مؤقتًا - الحد اليومي لـ Google",
    "Uploading to Google Drive — %@ queued":
      "الرفع إلى Google Drive جارٍ - %@ في الانتظار",
    "Everything uploaded to Google Drive":
      "تم رفع كل شيء إلى Google Drive",
    "Unknown what is waiting in the queue":
      "غير معروف ما ينتظر في الطابور",
    "There is no connection to Google Drive, so backups are only made on this Mac. If this does not pass by itself within a few minutes, check the network and the connection to Drive.":
      "لا يوجد اتصال بـ Google Drive، لذا تُجرى النسخ الاحتياطية على هذا الـ Mac فقط. إن لم تزل المشكلة من تلقاء نفسها خلال بضع دقائق، فتحقق من الشبكة ومن الاتصال بـ Drive.",
    "There is no space left on Google Drive. This will NOT pass by itself — you need to free up space on Drive. Until then Time Machine is paused, so that it does not fill up this Mac's disk.":
      "لا توجد مساحة على Google Drive. لن تزول المشكلة من تلقاء نفسها - عليك تحرير مساحة على Drive. وحتى ذلك الحين يبقى Time Machine متوقفًا مؤقتًا لكي لا يملأ قرص هذا الـ Mac.",
    "%@ backup fragments could not be uploaded and rclone stopped trying. These fragments exist only on this Mac, so the backup on Drive is incomplete. This needs checking.":
      "تعذّر رفع %@ مقاطع من النسخة الاحتياطية وتوقف rclone عن المحاولة. هذه المقاطع موجودة على هذا الـ Mac فقط، لذا النسخة الاحتياطية على Drive غير مكتملة. يلزم الفحص.",
    "Time Machine is writing faster than the upload goes, and the buffer has filled up. The backup will be paused until the upload catches up — this is a safeguard against filling up the disk, not a failure.":
      "يكتب Time Machine أسرع من الرفع، وقد امتلأ المخزن المؤقت. ستتوقف النسخة الاحتياطية مؤقتًا إلى أن يلحق الرفع - هذا إجراء وقائي لمنع امتلاء القرص وليس عطلًا.",
    "Google accepts 750 GB per day and that limit has been used up. There is nothing to do: the limit renews by itself, usually within a few hours. Time Machine backups are made normally in the meantime and wait in the buffer — they will be uploaded as soon as Google starts accepting again.":
      "تقبل Google 750 GB في اليوم وقد استُنفد هذا الحد. لا شيء يلزم فعله: يتجدد الحد تلقائيًا، عادةً خلال ساعات قليلة. وفي هذه الأثناء تُجرى نسخ Time Machine الاحتياطية بشكل طبيعي وتنتظر في المخزن المؤقت - وسترفع فور أن تعود Google إلى القبول.",
    "%@ backup fragments are queued and on their way to Drive.":
      "%@ مقاطع من النسخة الاحتياطية في الطابور وفي طريقها إلى Drive.",
    "Nothing is waiting in the queue — the backup on Google Drive is complete.":
      "لا شيء ينتظر في الطابور - النسخة الاحتياطية على Google Drive مكتملة.",
    "rclone did not answer the question about the queue, so it is unknown how many backups are still waiting to be uploaded. This does not mean something broke — under load the answer can be late. It only means that right now nobody knows. If it persists, the backup cycle check will report it.":
      "لم يجب rclone عن سؤال الطابور، لذا لا يُعرف كم نسخة احتياطية لا تزال تنتظر الرفع. لا يعني هذا أن شيئًا تعطل - تحت الحمل قد يتأخر الجواب. يعني فقط أن أحدًا لا يعرف الآن. إن استمر الأمر، فسيبلّغ فحص دورة النسخ الاحتياطي عنه.",
    "unknown error":
      "خطأ غير معروف",
    "rclone lsf ended with an error":
      "انتهى rclone lsf بخطأ",
    "This Mac is close to its space limit on Google Drive":
      "هذا الـ Mac قريب من حد مساحته على Google Drive",
    "%@ GB of %@ GB used. Time Machine deletes the oldest backups to stay within its quota; check that the quota is set (vm-status).":
      "المستخدم %@ GB من %@ GB. يحذف Time Machine أقدم النسخ الاحتياطية ليبقى ضمن حصته؛ تحقق من ضبط الحصة (vm-status).",
    "This Mac is over its space limit on Google Drive":
      "هذا الـ Mac تجاوز حد مساحته على Google Drive",
    "%@ GB of %@ GB used. Set the Time Machine quota (command in the app window or vm-status), or raise the limit.":
      "المستخدم %@ GB من %@ GB. اضبط حصة Time Machine (الأمر في نافذة التطبيق أو vm-status)، أو ارفع الحد.",
    "not set":
      "غير مضبوط",
    "%@ GB - usage not measured yet":
      "%@ GB - الاستخدام لم يُقَس بعد",
    "%@ of %@ GB used (%@%%)":
      "المستخدم %@ من %@ GB (%@%%)",
    "The limit must be a whole number of GB above zero.":
      "يجب أن يكون الحد عددًا صحيحًا من GB أكبر من الصفر.",
    "machines.json cannot be read, so it was not overwritten. Fix or remove it first.":
      "تعذّرت قراءة machines.json، لذا لم يُكتب فوقه. أصلحه أو أزله أولًا.",
    "'%@' is not a valid folder name: use lowercase letters, digits and dashes.":
      "'%@' ليس اسم مجلد صالحًا: استخدم أحرفًا لاتينية صغيرة وأرقامًا وشرطات.",
    "This Mac already backs up to folder '%@'. Switching to '%@' would start a new, empty backup and orphan the existing one, so nothing was changed.":
      "هذا الـ Mac ينسخ احتياطيًا بالفعل إلى المجلد '%@'. التحول إلى '%@' سيبدأ نسخة احتياطية جديدة فارغة ويترك الحالية يتيمة، لذا لم يتغير شيء.",
    "This Mac already has a CloudMachine installation, whose backup is in folder '%@'. Switching to '%@' would orphan it, so nothing was changed.":
      "لدى هذا الـ Mac تثبيت CloudMachine بالفعل، ونسخته الاحتياطية في المجلد '%@'. التحول إلى '%@' سيتركها يتيمة، لذا لم يتغير شيء.",
    "Could not save the folder name to %@: %@":
      "تعذّر حفظ اسم المجلد في %@: %@",
    "Homebrew is not installed. Install it manually: https://brew.sh":
      "Homebrew غير مثبّت. ثبّته يدويًا: https://brew.sh",
    "Installing rclone failed: %@":
      "فشل تثبيت rclone: %@",
    "Installed rclone.":
      "تم تثبيت rclone.",
    "Own Google credentials: set.":
      "بيانات اعتماد Google الخاصة: مضبوطة.",
    "INCOMPLETE: %@ is missing - rclone will use rclone's shared client_id anyway.":
      "غير مكتمل: %@ مفقود - سيستخدم rclone الـ client_id المشترك الخاص به على أي حال.",
    "No own credentials - rclone uses the shared client_id, rate-limited jointly and being retired in 2026.":
      "لا توجد بيانات اعتماد خاصة - يستخدم rclone الـ client_id المشترك، وهو محدود المعدل بالاشتراك وسيُسحب في 2026.",
    "Empty value - not saving.":
      "قيمة فارغة - لن تُحفظ.",
    "Keychain refused: %@":
      "رفضت سلسلة المفاتيح: %@",
    "DIRTY-TREE":
      "DIRTY-TREE",
    "Cannot create the working directory: %@":
      "تعذّر إنشاء مجلد العمل: %@",
    "Could not read the rclone version number.":
      "تعذّرت قراءة رقم إصدار rclone.",
    "Could not download %@.":
      "تعذّر تنزيل %@.",
    "No entry for %@ in SHA256SUMS.":
      "لا يوجد إدخال لـ %@ في SHA256SUMS.",
    "Could not compute the checksum.":
      "تعذّر حساب المجموع الاختباري.",
    "SHA256 checksum does not match - NOT installing.\n  expected: %@\n  computed: %@":
      "المجموع الاختباري SHA256 لا يطابق - لن يُثبَّت.\n  المتوقع: %@\n  المحسوب: %@",
    "Could not unpack the archive.":
      "تعذّر فك ضغط الأرشيف.",
    "Could not install the binary: %@":
      "تعذّر تثبيت الملف التنفيذي: %@",
    "Installed rclone %@ in %@ (SHA256 checksum matches).":
      "تم تثبيت rclone %@ في %@ (المجموع الاختباري SHA256 مطابق).",
    "%@ did not respond within the allotted time (the process was left orphaned in the background).":
      "لم يستجب %@ خلال المهلة المحددة (تُركت العملية يتيمة في الخلفية).",
    "Cannot launch %@: %@":
      "تعذّر تشغيل %@: %@",
    "Remote '%@' already exists and was NOT touched.\nOverwriting it replaces the token and the permission scope; a credential with the 'drive.file' scope does not see files created by the previous one, so the existing backup becomes unreachable.\nIf you really want to replace it, first back up ~/.config/rclone/rclone.conf and run again with --replace-existing.":
      "الاتصال البعيد '%@' موجود بالفعل ولم يُمسّ.\nيؤدي استبداله إلى استبدال الرمز ونطاق الأذونات؛ وبيانات الاعتماد ذات النطاق 'drive.file' لا ترى الملفات التي أنشأتها السابقة، فتصبح النسخة الاحتياطية الحالية بعيدة المنال.\nإن أردت الاستبدال فعلًا، فانسخ احتياطيًا ~/.config/rclone/rclone.conf أولًا وشغّل الأمر مجددًا مع --replace-existing.",
    "Could not check whether remote '%@' already exists (rclone listremotes did not answer or failed), so nothing was changed. Run `%@ listremotes` to see the error, then try again.":
      "تعذّر التحقق مما إذا كان الاتصال البعيد '%@' موجودًا (لم يستجب rclone listremotes أو فشل)، لذا لم يتغير شيء. شغّل `%@ listremotes` لرؤية الخطأ، ثم حاول مرة أخرى.",
    "Could not check whether this Mac already has a CloudMachine installation (rclone did not answer), so no folder was chosen. Try again in a moment.":
      "تعذّر التحقق مما إذا كان لدى هذا الـ Mac تثبيت CloudMachine (لم يستجب rclone)، لذا لم يُختر مجلد. حاول مرة أخرى بعد قليل.",
    "rclone authorize failed (%@). If that binary is missing, start with: cloudmachine-agent install-rclone.":
      "فشل rclone authorize (%@). إن كان ذلك الملف التنفيذي مفقودًا، فابدأ بـ: cloudmachine-agent install-rclone.",
    "Could not read the token from the output of rclone authorize.":
      "تعذّرت قراءة الرمز من مخرجات rclone authorize.",
    "rclone config create failed.":
      "فشل rclone config create.",
    "Connected to Google Drive as remote '%@', folder %@.":
      "تم الاتصال بـ Google Drive باسم الاتصال البعيد '%@'، المجلد %@.",
    "tmutil is not responding - unknown where the backup goes":
      "tmutil لا يستجيب - مكان حفظ النسخة الاحتياطية غير معروف",
    "No successful backup for %@":
      "لا توجد نسخة احتياطية ناجحة منذ %@",
    "Last COMPLETED backup: %@. The cycle is hourly, so that is %@ missed runs.":
      "آخر نسخة احتياطية مكتملة: %@. الدورة كل ساعة، أي ما يعادل %@ عمليات فائتة.",
    "There is NOT A SINGLE successful backup":
      "لا توجد ولا نسخة احتياطية ناجحة واحدة",
    "The Time Machine preferences contain no date of a completed backup for this destination.":
      "لا تحتوي تفضيلات Time Machine على تاريخ نسخة احتياطية مكتملة لهذه الوجهة.",
    "The last backup attempt did not end in a backup":
      "لم تنتهِ آخر محاولة نسخ احتياطي بنسخة احتياطية",
    "The attempt at %@ is newer than the last successful backup at %@.":
      "المحاولة في %@ أحدث من آخر نسخة احتياطية ناجحة في %@.",
    "Time Machine reports an error in the last run (RESULT=%@)":
      "أبلغ Time Machine عن خطأ في آخر تشغيل (RESULT=%@)",
    "A non-zero RESULT in the Time Machine preferences means the run did not succeed.":
      "قيمة RESULT غير الصفرية في تفضيلات Time Machine تعني أن التشغيل لم ينجح.",
    "rclone failed to upload %@ files":
      "فشل rclone في رفع %@ ملفًا",
    "Buffer full of nothing but unsent data":
      "المخزن المؤقت ممتلئ ببيانات غير مرسلة فقط",
    "rclone has nothing left to evict from the buffer - the upload cannot keep up or has stalled.":
      "لم يعد لدى rclone ما يُخليه من المخزن المؤقت - الرفع لا يواكب أو توقف.",
    "The rclone control interface is not responding":
      "واجهة تحكم rclone لا تستجيب",
    "Google Drive is running out of space (%@ GB)":
      "مساحة Google Drive توشك على النفاد (%@ GB)",
    "The Mac's disk is running out of space (%@ GB)":
      "مساحة قرص الـ Mac توشك على النفاد (%@ GB)",
    "Cannot read the Time Machine preferences":
      "تعذّرت قراءة تفضيلات Time Machine",
    "%@ is unreadable - most often Full Disk Access is missing. Without this file it is UNKNOWN when the last backup was made, so we treat it as a failure, not as the absence of a problem.":
      "%@ غير قابل للقراءة - غالبًا بسبب غياب الوصول الكامل إلى القرص. ومن دون هذا الملف لا يُعرف متى أُجريت آخر نسخة احتياطية، لذا نعدّه عطلًا لا غياب مشكلة.",
    "Cannot measure free space on the Mac's disk":
      "تعذّر قياس المساحة الحرة على قرص الـ Mac",
    "%@ days":
      "%@ أيام",
    "CloudMachine: backup is not working":
      "CloudMachine: النسخ الاحتياطي لا يعمل",
    "unknown reason":
      "سبب غير معروف",
    "osascript did not show the notification (permissions or no graphical session)":
      "لم يعرض osascript الإشعار (الأذونات أو لا توجد جلسة رسومية)",
    "UNDELIVERED ALARM: %@":
      "تنبيه لم يُسلَّم: %@",
    "from %@, reason: %@":
      "من %@، السبب: %@",
    "The system notification was not delivered - you will see this alarm ONLY here.":
      "لم يُسلَّم إشعار النظام - سترى هذا التنبيه هنا فقط.",
    "%@ (%@ ago)":
      "%@ (منذ %@)",
    "%@ - marker from the FUTURE":
      "%@ - علامة من المستقبل",
    "%@ (%@ ago) - THE WATCHDOG MAY NOT BE RUNNING":
      "%@ (منذ %@) - قد لا يكون المراقب يعمل",
    "NEVER - the watchdog has not recorded a single run":
      "أبدًا - لم يسجّل المراقب أي تشغيل",
    "Could not find the launchd/ directory with templates.":
      "تعذّر العثور على مجلد launchd/ الذي يحوي القوالب.",
    "Could not find the compiled cloudmachine-agent binary.":
      "تعذّر العثور على الملف التنفيذي المترجم cloudmachine-agent.",
    "ABORTED: could not put cloudmachine-agent in a stable location\n(%@) - most often a lack of space or permissions.\nNOT installing agents pointing at %@: that path\ndisappears on the next `swift build` or `git clean`, and backups stop\nwithout any visible signal.":
      "أُلغي: تعذّر وضع cloudmachine-agent في موقع ثابت\n(%@) - غالبًا بسبب نقص المساحة أو الأذونات.\nلن يُثبَّت الوكلاء الذين يشيرون إلى %@: هذا المسار\nيختفي عند `swift build` أو `git clean` التاليين، وتتوقف النسخ الاحتياطية\nدون أي إشارة ظاهرة.",
    "ABORTED: %@":
      "أُلغي: %@",
    "Could not list the templates in %@.":
      "تعذّر سرد القوالب في %@.",
    "could not read the template %@":
      "تعذّرت قراءة القالب %@",
    "could not write %@ (lack of space or permissions)":
      "تعذّرت كتابة %@ (نقص مساحة أو أذونات)",
    "launchctl load refused to load %@":
      "رفض launchctl load تحميل %@",
    "NOT A SINGLE agent was loaded.":
      "لم يُحمَّل ولا وكيل واحد.",
    "Only these went in: %@.":
      "لم يُثبَّت سوى هؤلاء: %@.",
    "Could not load any launchd agent.":
      "تعذّر تحميل أي وكيل launchd.",
    "Installed agents: %@":
      "الوكلاء المثبّتون: %@",
    "                  WARNING: close to the limit - new bands will fail with EMFILE":
      "                  تحذير: قريب من الحد - ستفشل الأجزاء الجديدة بالخطأ EMFILE",
    "%@/bands on Google Drive is not empty - it may hold another backup. NOT overwriting it; check it by hand.":
      "%@/bands على Google Drive غير فارغ - قد يحوي نسخة احتياطية أخرى. لن يُكتب فوقه؛ افحصه يدويًا.",
    "Address:          %@":
      "العنوان:          %@",
    "Already prepared (%@ exists) - nothing to do.":
      "مُحضَّر بالفعل (%@ موجود) - لا حاجة لأي إجراء.",
    "Converts Time Machine's new, empty image in the machine to 32 MB bands and moves the bands to Google Drive.":
      "يحوّل صورة Time Machine الجديدة الفارغة في الجهاز الافتراضي إلى أجزاء بحجم 32 MB وينقل الأجزاء إلى Google Drive.",
    "Copy rclone.conf into the machine even if it already has one.":
      "انسخ rclone.conf إلى الجهاز الافتراضي حتى لو كان فيه واحد بالفعل.",
    "Copying the converted image into the machine failed: %@":
      "فشل نسخ الصورة المحوَّلة إلى الجهاز الافتراضي: %@",
    "Copying the image to the Mac failed: %@":
      "فشل نسخ الصورة إلى الـ Mac: %@",
    "Could not ask Lima about the machine: %@":
      "تعذّر سؤال Lima عن الجهاز الافتراضي: %@",
    "Could not carry the Time Machine files over: %@":
      "تعذّر نقل ملفات Time Machine: %@",
    "Could not check the image in the machine.":
      "تعذّر فحص الصورة في الجهاز الافتراضي.",
    "Could not copy the rclone configuration into the machine.":
      "تعذّر نسخ إعدادات rclone إلى الجهاز الافتراضي.",
    "Could not create %@ on Google Drive: %@":
      "تعذّر إنشاء %@ على Google Drive: %@",
    "Could not create %@: %@":
      "تعذّر إنشاء %@: %@",
    "Could not find the vm/ directory with the machine template.":
      "تعذّر العثور على مجلد vm/ الذي يحوي قالب الجهاز الافتراضي.",
    "Could not read the image size.":
      "تعذّرت قراءة حجم الصورة.",
    "Could not set the SMB password of user %@ in the machine.":
      "تعذّر ضبط كلمة مرور SMB للمستخدم %@ في الجهاز الافتراضي.",
    "Could not stop smbd in the machine.":
      "تعذّر إيقاف smbd في الجهاز الافتراضي.",
    "Could not write %@ in the machine.":
      "تعذّرت كتابة %@ في الجهاز الافتراضي.",
    "Could not write the password file %@.":
      "تعذّرت كتابة ملف كلمة المرور %@.",
    "Creates or starts the CloudMachine machine (Lima), gives it rclone's configuration and an SMB password, and prints the Time Machine command.":
      "ينشئ الجهاز الافتراضي لـ CloudMachine (Lima) أو يشغّله، ويمنحه إعدادات rclone وكلمة مرور SMB، ويطبع أمر Time Machine.",
    "Creating the machine %@ (first start downloads Ubuntu and installs packages - several minutes)...":
      "إنشاء الجهاز الافتراضي %@ (يُنزَّل Ubuntu وتُثبَّت الحزم عند أول تشغيل - عدة دقائق)...",
    "Done: %@ has %@ MB bands on Google Drive; the original is kept in %@ in the machine. Start the backup: tmutil startbackup":
      "تم: لدى %@ أجزاء بحجم %@ MB على Google Drive؛ والأصل محفوظ في %@ في الجهاز الافتراضي. ابدأ النسخ الاحتياطي: tmutil startbackup",
    "exit code %@, no message":
      "رمز الخروج %@، بلا رسالة",
    "Image metadata:   NEVER copied to %@ - check tm-meta-sync in the machine":
      "بيانات تعريف الصورة:   لم تُنسخ أبدًا إلى %@ - افحص tm-meta-sync في الجهاز الافتراضي",
    "Image metadata:   copied %@ ago to %@":
      "بيانات تعريف الصورة:   نُسخت منذ %@ إلى %@",
    "Image metadata:   last copied %@ ago - OVERDUE (%@)":
      "بيانات تعريف الصورة:   آخر نسخ منذ %@ - متأخر (%@)",
    "Image metadata:   not copied yet - waits for vm-prepare-bundle":
      "بيانات تعريف الصورة:   لم تُنسخ بعد - بانتظار vm-prepare-bundle",
    "Backup %@, paused by the guard %@: %@":
      "النسخ الاحتياطي %@، أوقفه الحارس مؤقتًا %@: %@",
    "Free in machine:  %@ GiB":
      "المتاح في الجهاز:  %@ GiB",
    "fsck_apfs -n found problems: %@":
      "وجد fsck_apfs -n مشكلات: %@",
    "Google Drive folder: %@":
      "مجلد Google Drive: %@",
    "hdiutil attach of the converted image failed: %@":
      "فشل hdiutil attach للصورة المحوَّلة: %@",
    "hdiutil convert failed: %@":
      "فشل hdiutil convert: %@",
    "Image name in the machine (default: from the computer name).":
      "اسم الصورة في الجهاز الافتراضي (الافتراضي: من اسم الكمبيوتر).",
    "Installing the converted image FAILED: %@\nsmbd is left STOPPED so Time Machine does not open a half-installed image. The original is in %@ in the machine.":
      "فشل تثبيت الصورة المحوَّلة: %@\nتُرك smbd متوقفًا لكي لا يفتح Time Machine صورة مثبّتة جزئيًا. الأصل في %@ في الجهاز الافتراضي.",
    "limactl create failed: %@":
      "فشل limactl create: %@",
    "limactl list failed: %@":
      "فشل limactl list: %@",
    "limactl not found - install Lima: brew install lima":
      "لم يُعثر على limactl - ثبّت Lima: brew install lima",
    "limactl start failed: %@\nThe machine's own log: %@":
      "فشل limactl start: %@\nسجل الجهاز الافتراضي نفسه: %@",
    "Machine %@ is running.":
      "الجهاز الافتراضي %@ يعمل.",
    "Machine %@ was already running.":
      "الجهاز الافتراضي %@ كان يعمل بالفعل.",
    "Machine:          %@ (%@)":
      "الجهاز الافتراضي:  %@ (%@)",
    "Machine:          %@":
      "الجهاز الافتراضي:  %@",
    "Machine:          not created - run: cloudmachine-agent vm-setup":
      "الجهاز الافتراضي:  لم يُنشأ - شغّل: cloudmachine-agent vm-setup",
    "no answer within the time limit":
      "لا جواب خلال المهلة",
    "No image %@ in the machine.":
      "لا توجد صورة %@ في الجهاز الافتراضي.",
    "No image in the machine yet - point Time Machine at the share and let it create one first.":
      "لا توجد صورة في الجهاز الافتراضي بعد - وجّه Time Machine إلى المشاركة ودعه ينشئ واحدة أولًا.",
    "No rclone configuration at %@ - connect Google Drive first (configure-remote).":
      "لا توجد إعدادات rclone في %@ - اربط Google Drive أولًا (configure-remote).",
    "no SMB destination":
      "لا توجد وجهة SMB",
    "One check of the machine's upload buffer: pauses Time Machine when it fills, resumes what it paused.":
      "فحص واحد للمخزن المؤقت للرفع في الجهاز الافتراضي: يوقف Time Machine مؤقتًا حين يمتلئ، ويستأنف ما أوقفه.",
    "Packing the converted image failed: %@":
      "فشلت تعبئة الصورة المحوَّلة: %@",
    "Packing the image failed: %@":
      "فشلت تعبئة الصورة: %@",
    "No answer from the machine (rclone rc) - the guard would do nothing.":
      "لا جواب من الجهاز الافتراضي (rclone rc) - لن يفعل الحارس شيئًا.",
    "Only print what the guard would decide - for trying thresholds on a throwaway machine.":
      "طباعة ما كان الحارس سيقرره فقط - لتجربة العتبات على جهاز افتراضي مؤقت.",
    "Pause above this many GiB in the buffer.":
      "إيقاف مؤقت عند تجاوز هذا العدد من GiB في المخزن المؤقت.",
    "Pause when the machine has less free than this, in GiB.":
      "إيقاف مؤقت حين يقل المتاح في الجهاز الافتراضي عن هذا، بالـ GiB.",
    "Point Time Machine at the machine (once, needs an administrator password):":
      "وجّه Time Machine إلى الجهاز الافتراضي (مرة واحدة، يتطلب كلمة مرور المسؤول):",
    "punchfs files:    %@ open, limit %@":
      "ملفات punchfs:    %@ مفتوح، الحد %@",
    "rclone configuration already in the machine - kept (--replace-rclone-config replaces it).":
      "إعدادات rclone موجودة بالفعل في الجهاز الافتراضي - أُبقيت (--replace-rclone-config يستبدلها).",
    "rclone configuration copied into the machine.":
      "نُسخت إعدادات rclone إلى الجهاز الافتراضي.",
    "rclone-tm or punchfs is not running in the machine - see cloudmachine-agent vm-status.":
      "rclone-tm أو punchfs لا يعمل في الجهاز الافتراضي - انظر cloudmachine-agent vm-status.",
    "Resume below this many GiB (only a backup the guard paused).":
      "استئناف عند الانخفاض عن هذا العدد من GiB (فقط لنسخة أوقفها الحارس مؤقتًا).",
    "Service %@: %@":
      "الخدمة %@: %@",
    "Several images in the machine (%@) - choose one with --bundle.":
      "عدة صور في الجهاز الافتراضي (%@) - اختر واحدة بـ --bundle.",
    "Shows the machine: address, services, upload buffer, free space and the Time Machine destination.":
      "يعرض الجهاز الافتراضي: العنوان والخدمات والمخزن المؤقت للرفع والمساحة الحرة ووجهة Time Machine.",
    "SMB password stored in %@ (mode 600).":
      "خُزّنت كلمة مرور SMB في %@ (الوضع 600).",
    "The converted image does not have %@-byte bands.":
      "الصورة المحوَّلة ليست بأجزاء حجمها %@ بايت.",
    "The converted image has no APFS partition.":
      "الصورة المحوَّلة لا تحتوي على قسم APFS.",
    "The image already takes %@ MB - this command converts only a new, empty image (under %@ MB).":
      "تشغل الصورة بالفعل %@ MB - هذا الأمر يحوّل صورة جديدة فارغة فقط (أقل من %@ MB).",
    "The image is encrypted - converting encrypted images is not supported.":
      "الصورة مشفّرة - تحويل الصور المشفّرة غير مدعوم.",
    "The image was not changed; smbd started again.":
      "لم تتغير الصورة؛ بدأ smbd من جديد.",
    "The machine does not answer - is it running? cloudmachine-agent vm-status":
      "الجهاز الافتراضي لا يستجيب - هل يعمل؟ cloudmachine-agent vm-status",
    "The machine has no address on the vzNAT network.":
      "ليس للجهاز الافتراضي عنوان على شبكة vzNAT.",
    "The services in the machine did not start - check: cloudmachine-agent vm-status":
      "لم تبدأ الخدمات في الجهاز الافتراضي - تحقق: cloudmachine-agent vm-status",
    "Time Machine is backing up - stop it first: tmutil stopbackup":
      "Time Machine يجري نسخًا احتياطيًا - أوقفه أولًا: tmutil stopbackup",
    "Time Machine:     %@":
      "Time Machine:     %@",
    "Time Machine:     NOT pointing at the machine (%@)":
      "Time Machine:     لا يشير إلى الجهاز الافتراضي (%@)",
    "Time Machine:     tmutil did not answer":
      "Time Machine:     لم يستجب tmutil",
    "tmutil did not answer - not touching the image while its state is unknown.":
      "لم يستجب tmutil - لن تُمسّ الصورة ما دامت حالتها غير معروفة.",
    "unknown":
      "غير معروف",
    "Unpacking the image failed: %@":
      "فشل فك تعبئة الصورة: %@",
    "Still to upload:  %@ GiB in %@ bands, uploading %@ (cache on disk %@ GiB)":
      "المتبقي للرفع:  %@ GiB في %@ أجزاء، يجري رفع %@ (ذاكرة مؤقتة على القرص %@ GiB)",
    "Excluded %@ (the machine and its upload buffer) from Time Machine.":
      "استُبعد %@ (الجهاز الافتراضي والمخزن المؤقت للرفع) من Time Machine.",
    "WARNING: could not exclude %@ from Time Machine - run: tmutil addexclusion %@":
      "تحذير: تعذّر استبعاد %@ من Time Machine - شغّل: tmutil addexclusion %@",
    "Upload buffer:    no answer from rclone (rc %@)":
      "المخزن المؤقت للرفع:    لا جواب من rclone (rc %@)",
    "When Time Machine has created its empty image, stop the backup (tmutil stopbackup) and run: cloudmachine-agent vm-prepare-bundle":
      "حين ينشئ Time Machine صورته الفارغة، أوقف النسخ الاحتياطي (tmutil stopbackup) وشغّل: cloudmachine-agent vm-prepare-bundle",
    "Unsent %@ GiB, free %@ GiB (pause above %@ GiB unsent or below %@ GiB free, resume below %@ GiB).":
      "غير مرسل %@ GiB، المتاح %@ GiB (إيقاف مؤقت فوق %@ GiB غير مرسلة أو دون %@ GiB متاحة، استئناف دون %@ GiB).",
    "Upload:           Google's daily limit refused an upload %@ ago - rclone retries every 5 min and resumes by itself":
      "الرفع:           رفض حد Google اليومي رفعًا منذ %@ - يعيد rclone المحاولة كل 5 دقائق ويستأنف تلقائيًا",
    "no":
      "لا",
    "running":
      "يعمل",
    "stopped":
      "متوقف",
    "yes":
      "نعم",
    "%@\nThe previous template is in %@ - copy it back over lima.yaml and run limactl start %@.":
      "%@\nالقالب السابق في %@ - انسخه فوق lima.yaml وشغّل limactl start %@.",
    "Could not read this app's machine template (limactl template copy).":
      "تعذّرت قراءة قالب الجهاز الافتراضي لهذا التطبيق (limactl template copy).",
    "Could not replace %@: %@":
      "تعذّر استبدال %@: %@",
    "Machine %@ already runs this app's template.":
      "الجهاز الافتراضي %@ يعمل بالفعل بقالب هذا التطبيق.",
    "Machine %@ now runs this app's template; the previous one is in %@.":
      "الجهاز الافتراضي %@ يعمل الآن بقالب هذا التطبيق؛ والقالب السابق في %@.",
    "Moves the machine onto this app's template (two restarts, never during a backup).":
      "ينقل الجهاز الافتراضي إلى قالب هذا التطبيق (إعادتا تشغيل، وليس أثناء نسخ احتياطي).",
    "No machine %@ - create it with: cloudmachine-agent vm-setup":
      "لا يوجد جهاز افتراضي %@ - أنشئه بـ: cloudmachine-agent vm-setup",
    "Template:         OLDER than this app's - run: cloudmachine-agent vm-update":
      "القالب:           أقدم من قالب هذا التطبيق - شغّل: cloudmachine-agent vm-update",
    "Template:         not compared":
      "القالب:           لم يُقارَن",
    "Template:         this app's":
      "القالب:           قالب هذا التطبيق",
    "The machine has no %@ - run cloudmachine-agent vm-setup first.":
      "ليس في الجهاز الافتراضي %@ - شغّل cloudmachine-agent vm-setup أولًا.",
    "The machine restarted, but not every service is running - check: cloudmachine-agent vm-status. The previous template is in %@.":
      "أُعيد تشغيل الجهاز الافتراضي، لكن لا تعمل كل الخدمات - تحقق: cloudmachine-agent vm-status. القالب السابق في %@.",
    "The template changes the machine itself (%@) - that needs a new machine, not an update.":
      "يغيّر القالب الجهاز الافتراضي نفسه (%@) - وهذا يتطلب جهازًا افتراضيًا جديدًا لا تحديثًا.",
    "The upload to Google Drive hangs":
      "الرفع إلى Google Drive متعلّق",
    "Time Machine is backing up - try again when it has finished.":
      "Time Machine يجري نسخًا احتياطيًا - حاول مجددًا بعد انتهائه.",
    "Upload:           HANGS - bands in progress, none uploaded for %@ (network?); see /var/log/rclone-tm.log in the machine":
      "الرفع:           متعلّق - أجزاء قيد التنفيذ ولم يُرفع أي منها منذ %@ (الشبكة؟)؛ انظر /var/log/rclone-tm.log في الجهاز الافتراضي",
    "limactl stop failed - nothing was changed.":
      "فشل limactl stop - لم يتغير شيء.",
    "rclone has bands in progress, but none has been uploaded for %@ - usually a broken network connection, which rclone does not report as an error. Backups since then are only in the machine's buffer. When the network comes back the upload resumes by itself (on 28.10.2026 within 80 s); if it does not, restarting the machine (prepare-shutdown, limactl start) drops the dead connections.":
      "لدى rclone أجزاء قيد التنفيذ، لكن لم يُرفع أي منها منذ %@ - عادةً بسبب انقطاع اتصال الشبكة، ولا يبلّغ rclone عنه كخطأ. النسخ الاحتياطية منذ ذلك الحين موجودة في المخزن المؤقت للجهاز الافتراضي فقط. حين تعود الشبكة يستأنف الرفع تلقائيًا (في 28.10.2026 خلال 80 s)؛ وإن لم يحدث، فإعادة تشغيل الجهاز الافتراضي (prepare-shutdown ثم limactl start) تُسقط الاتصالات الميتة.",
    "tmutil did not answer - not restarting the machine while its state is unknown.":
      "لم يستجب tmutil - لن يُعاد تشغيل الجهاز الافتراضي ما دامت حالته غير معروفة.",
    "The machine's share cannot be read":
      "تعذّرت قراءة مشاركة الجهاز",
    "Unknown whether the machine's share can be read":
      "غير معروف ما إذا كانت مشاركة الجهاز قابلة للقراءة",
    "Samba in the machine does not answer this Mac":
      "Samba في الجهاز لا يستجيب لهذا الـ Mac",
    "Unknown whether Samba in the machine answers this Mac":
      "غير معروف ما إذا كان Samba في الجهاز يستجيب لهذا الـ Mac",
    "Reading 1 byte of %@ in the machine failed: %@. Every service says it is active, yet Time Machine cannot use the image there. Nothing restarts it by itself. Check: cloudmachine-agent vm-status, then in the machine: journalctl -u punchfs -u tm-bands-bind -u rclone-tm":
      "فشلت قراءة بايت واحد من %@ في الجهاز: %@. كل خدمة تقول إنها نشطة، ومع ذلك لا يستطيع Time Machine استخدام الصورة هناك. لا شيء يعيد تشغيله تلقائيًا. تحقّق: cloudmachine-agent vm-status، ثم داخل الجهاز: journalctl -u punchfs -u tm-bands-bind -u rclone-tm",
    "Reading 1 byte of %@ in the machine has not returned for %@ s. That is how a hung punchfs or rclone mount behaves. Nothing is restarted while the state is unknown - a restart under a write still going could lose it. Check in the machine: journalctl -u punchfs -u rclone-tm":
      "لم تعد قراءة بايت واحد من %@ في الجهاز منذ %@ ث. هكذا يتصرف تركيب punchfs أو rclone المعلّق. لا يُعاد تشغيل أي شيء ما دامت الحالة غير معروفة - إعادة التشغيل أثناء كتابة جارية قد تُضيّعها. تحقّق داخل الجهاز: journalctl -u punchfs -u rclone-tm",
    "An SMB connection to %@ got no answer within %@ s. Time Machine reaches the machine at this address. Check the machine's network and smbd: cloudmachine-agent vm-status":
      "لم يتلقَّ اتصال SMB بـ %@ أي رد خلال %@ ث. يصل Time Machine إلى الجهاز عبر هذا العنوان. تحقّق من شبكة الجهاز وsmbd: cloudmachine-agent vm-status",
    "The machine did not report its address, so nobody could try an SMB connection. Check: cloudmachine-agent vm-status":
      "لم يُبلغ الجهاز عن عنوانه، لذا لم يتمكن أحد من تجربة اتصال SMB. تحقّق: cloudmachine-agent vm-status",
    "An SMB connection to %@ failed (%@). Time Machine reaches the machine at this address, so no backup is made. Check the machine's network and smbd: cloudmachine-agent vm-status":
      "فشل اتصال SMB بـ %@ (%@). يصل Time Machine إلى الجهاز عبر هذا العنوان، لذا لا تُنشأ أي نسخة احتياطية. تحقّق من شبكة الجهاز وsmbd: cloudmachine-agent vm-status",
    "readable":
      "قابلة للقراءة",
    "no image yet":
      "لا توجد صورة بعد",
    "answers":
      "يستجيب",
    "Share read:       %@":
      "قراءة المشاركة:   %@",
    "Samba from Mac:   %@":
      "Samba من الـ Mac: %@",
    "This Mac found no route to %@ (%@). Either the route to the machine is gone, or macOS Local Network privacy has not allowed CloudMachine - then allow it in System Settings > Privacy & Security > Local Network. Check: cloudmachine-agent vm-status":
      "لم يجد هذا الـ Mac مسارًا إلى %@ (%@). إما أن المسار إلى الجهاز اختفى، أو أن خصوصية «الشبكة المحلية» في macOS لم تسمح لـ CloudMachine - عندها اسمح بذلك من إعدادات النظام > الخصوصية والأمن > الشبكة المحلية. تحقّق: cloudmachine-agent vm-status",
  ]
}
