// Arabic translations of vm-encrypt (DriveEncryption), keyed by the English text.
extension L10nTranslations {
  static let arEncryption: [String: String] = [
    "%@ and its metadata are in Google Drive's bin (kept 30 days, still counted in the quota).":
      "%@ وبيانات تعريفه في سلة مهملات Google Drive (تُحفظ 30 يومًا وتظل محسوبة ضمن الحصة).",
    "'%@' is already in %@ - not replacing its password.":
      "'%@' موجود بالفعل في %@ - لن تُستبدل كلمة مروره.",
    "'%@' is already in the machine's rclone.conf - not replacing its password.":
      "'%@' موجود بالفعل في rclone.conf الخاص بالجهاز الافتراضي - لن تُستبدل كلمة مروره.",
    "%@ holds folders this key cannot read: another password or salt in the machine, or leftovers of an earlier try. Compare the machine's rclone.conf with the Mac's; leftovers have to be removed from %@ by hand.":
      "يحتوي %@ على مجلدات لا يستطيع هذا المفتاح قراءتها: كلمة مرور أخرى أو ملح آخر في الجهاز الافتراضي، أو بقايا محاولة سابقة. قارن rclone.conf الخاص بالجهاز الافتراضي بالموجود على الـ Mac؛ يجب حذف البقايا من %@ يدويًا.",
    "'%@' is incomplete or missing in the Mac's rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "'%@' غير مكتمل أو غير موجود في rclone.conf على الـ Mac - شغّل: cloudmachine-agent vm-encrypt setup",
    "CLOUDMACHINE_VM_INSTANCE=%@ needs its own rclone.conf - set RCLONE_CONFIG to a copy, not %@. Its Keychain entry is service %@.":
      "يحتاج CLOUDMACHINE_VM_INSTANCE=%@ إلى ملف rclone.conf خاص به - اضبط RCLONE_CONFIG على نسخة، وليس على %@. إدخاله في سلسلة المفاتيح هو الخدمة %@.",
    "Could not read the '%@' section on the Mac or in the machine.":
      "تعذرت قراءة القسم '%@' على الـ Mac أو في الجهاز الافتراضي.",
    "The machine's '%@' (password, salt or folder) differs from the Mac's - the copy would be readable only with the machine's key. Not moving anything.":
      "'%@' في الجهاز الافتراضي (كلمة المرور أو الملح أو المجلد) يختلف عن الموجود على الـ Mac - لن تُقرأ النسخة إلا بمفتاح الجهاز الافتراضي. لن يُنقل أي شيء.",
    "A file was restored from the encrypted backup.":
      "تمت استعادة ملف من النسخة الاحتياطية المشفرة.",
    "Added '%@' (%@) on the Mac and in the machine; password and salt are in the Keychain (service %@).\nSALT: %@\nKeep the password AND this salt outside this Mac now - without both the encrypted backup cannot be read. Next: cloudmachine-agent vm-encrypt copy":
      "تمت إضافة '%@' (%@) على الـ Mac وفي الجهاز الافتراضي؛ كلمة المرور والملح في سلسلة المفاتيح (الخدمة %@).\nالملح: %@\nاحفظ الآن كلمة المرور وهذا الملح خارج هذا الـ Mac - فبدونهما لا يمكن قراءة النسخة الاحتياطية المشفرة. التالي: cloudmachine-agent vm-encrypt copy",
    "Adds the encrypted remote on the Mac and in the machine (asks for the password). Moves no data.":
      "يضيف الاتصال البعيد المشفر على الـ Mac وفي الجهاز الافتراضي (يطلب كلمة المرور). لا ينقل أي بيانات.",
    "Again: ":
      "مرة أخرى: ",
    "Copies the plain backup into the encrypted folder, in the background; backups go on.":
      "ينسخ النسخة الاحتياطية غير المشفرة إلى المجلد المشفر في الخلفية؛ وتستمر النسخ الاحتياطية.",
    "Copy:             %@":
      "النسخ:            %@",
    "CLOUDMACHINE_VM_INSTANCE=%@ without CLOUDMACHINE_VM_REMOTE would use the live backup's folder - set both.":
      "سيستخدم CLOUDMACHINE_VM_INSTANCE=%@ بدون CLOUDMACHINE_VM_REMOTE مجلد النسخة الاحتياطية الحالية - اضبط الاثنين.",
    "Could not add the remote to %@: %@":
      "تعذرت إضافة الاتصال البعيد إلى %@: %@",
    "Could not add the remote to the machine's rclone.conf.":
      "تعذرت إضافة الاتصال البعيد إلى rclone.conf الخاص بالجهاز الافتراضي.",
    "Could not read %@.":
      "تعذرت قراءة %@.",
    "Could not read when Time Machine last finished a backup (Full Disk Access?) - not deleting.":
      "تعذر معرفة متى أنهى Time Machine آخر نسخة احتياطية (الوصول الكامل إلى القرص؟) - لن يُحذف شيء.",
    "Could not start the copy: %@":
      "تعذر بدء النسخ: %@",
    "Could not write %@.":
      "تعذرت كتابة %@.",
    "Deleting the plain folder failed: %@":
      "فشل حذف المجلد غير المشفر: %@",
    "Encrypted folder: %@":
      "المجلد المشفر:    %@",
    "Encryption password: ":
      "كلمة مرور التشفير: ",
    "Machine uses:     %@":
      "الجهاز يستخدم:    %@",
    "Moves the backup on Google Drive under rclone encryption: setup, copy, switch, then delete-plain.":
      "ينقل النسخة الاحتياطية على Google Drive إلى تشفير rclone: setup ثم copy ثم switch ثم delete-plain.",
    "Moves the plain folder to Google Drive's bin - only after a backup has finished into the encrypted one.":
      "ينقل المجلد غير المشفر إلى سلة مهملات Google Drive - فقط بعد اكتمال نسخة احتياطية في المجلد المشفر.",
    "Moving the machine failed; it went back to %@: %@":
      "فشل تحويل الجهاز الافتراضي؛ وعاد إلى %@: %@",
    "No answer from rclone in the machine - the upload queue is unknown.":
      "لا رد من rclone في الجهاز الافتراضي - قائمة انتظار الرفع غير معروفة.",
    "No backup has finished into the encrypted folder yet (last one %@, switched %@) - not deleting.":
      "لم تكتمل أي نسخة احتياطية في المجلد المشفر بعد (الأخيرة %@، التحويل %@) - لن يُحذف شيء.",
    "Not everything is on Google Drive yet (%@ MB unsent, %@ uploading, %@ failed). Wait until the upload is done: cloudmachine-agent vm-status":
      "ليس كل شيء على Google Drive بعد (%@ MB لم تُرسل، %@ قيد الرفع، %@ فشلت). انتظر حتى ينتهي الرفع: cloudmachine-agent vm-status",
    "Restore a file from the encrypted backup first (Time Machine, Browse), then confirm with --restore-checked.":
      "استعد أولًا ملفًا من النسخة الاحتياطية المشفرة (Time Machine، تصفح)، ثم أكّد باستخدام --restore-checked.",
    "Shows which folder the machine uses and the copy.":
      "يعرض المجلد الذي يستخدمه الجهاز الافتراضي وحالة النسخ.",
    "Switched:         %@":
      "التحويل:          %@",
    "The copy is already running - see: cloudmachine-agent vm-encrypt status":
      "النسخ قيد التشغيل بالفعل - راجع: cloudmachine-agent vm-encrypt status",
    "The copy runs in the machine (%@, log %@). Backups go on meanwhile. Check: cloudmachine-agent vm-encrypt status":
      "يعمل النسخ في الجهاز الافتراضي (%@، السجل %@). تستمر النسخ الاحتياطية في أثناء ذلك. للتحقق: cloudmachine-agent vm-encrypt status",
    "The copy to the encrypted folder has not finished well (%@) - run: cloudmachine-agent vm-encrypt copy, and wait for it.":
      "لم ينته النسخ إلى المجلد المشفر بنجاح (%@) - شغّل: cloudmachine-agent vm-encrypt copy وانتظره.",
    "The encryption password and salt are kept outside this Mac.":
      "كلمة مرور التشفير والملح محفوظان خارج هذا الـ Mac.",
    "The guard holds Time Machine paused and would resume it during the switch. Wait until it resumes and the upload is done.":
      "يُبقي حارس المخزن المؤقت Time Machine متوقفًا مؤقتًا وقد يستأنفه أثناء التحويل. انتظر حتى يُستأنف وينتهي الرفع.",
    "The image metadata has not been copied to the encrypted folder since the last backup - not deleting.":
      "لم تُنسخ بيانات تعريف الصورة إلى المجلد المشفر منذ آخر نسخة احتياطية - لن يُحذف شيء.",
    "The last sync or cryptcheck failed - the machine was NOT moved: %@":
      "فشلت المزامنة الأخيرة أو cryptcheck - لم يُحوَّل الجهاز الافتراضي: %@",
    "The machine already uses the encrypted folder - nothing to switch.":
      "يستخدم الجهاز الافتراضي المجلد المشفر بالفعل - لا شيء للتحويل.",
    "The machine already uses the encrypted folder.":
      "يستخدم الجهاز الافتراضي المجلد المشفر بالفعل.",
    "The machine does not use the encrypted folder - nothing to roll back.":
      "لا يستخدم الجهاز الافتراضي المجلد المشفر - لا شيء للتراجع عنه.",
    "The machine does not use the encrypted folder - the plain folder is the backup. Not deleting it.":
      "لا يستخدم الجهاز الافتراضي المجلد المشفر - المجلد غير المشفر هو النسخة الاحتياطية. لن يُحذف.",
    "The machine has no '%@' remote in its rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "لا يوجد اتصال بعيد '%@' في rclone.conf الخاص بالجهاز الافتراضي - شغّل: cloudmachine-agent vm-encrypt setup",
    "The machine is not on this app's template or does not use %@ (cloudmachine-agent vm-update first): %@":
      "الجهاز الافتراضي لا يعمل بقالب هذا التطبيق أو لا يستخدم %@ (شغّل أولًا cloudmachine-agent vm-update): %@",
    "The machine now uses %@, but %@ could not be updated (%@) - fix it before anything else runs vm-setup.":
      "يستخدم الجهاز الافتراضي الآن %@، لكن تعذر تحديث %@ (%@) - أصلحه قبل أن يشغّل أي شيء آخر الأمر vm-setup.",
    "The machine now uses %@. %@ is kept. Turn automatic backups back on: sudo tmutil enable":
      "يستخدم الجهاز الافتراضي الآن %@. يُحتفظ بـ %@. أعد تفعيل النسخ الاحتياطية التلقائية: sudo tmutil enable",
    "The password must have at least 12 characters.":
      "يجب أن تتكون كلمة المرور من 12 حرفًا على الأقل.",
    "The passwords differ - nothing was changed.":
      "كلمتا المرور مختلفتان - لم يتغير شيء.",
    "The switch the other way: decrypts what changed back into the plain folder and uses it again.":
      "التحويل في الاتجاه المعاكس: يفك تشفير ما تغيّر ويعيده إلى المجلد غير المشفر ويستخدمه مجددًا.",
    "The upload to the encrypted folder is not finished (or rclone did not answer) - not deleting.":
      "لم ينته الرفع إلى المجلد المشفر (أو لم يرد rclone) - لن يُحذف شيء.",
    "Time Machine is backing up. Turn automatic backups off (sudo tmutil disable), stop it (tmutil stopbackup), then run this again.":
      "يُجري Time Machine نسخًا احتياطيًا. عطّل النسخ الاحتياطية التلقائية (sudo tmutil disable)، وأوقف النسخ الجاري (tmutil stopbackup)، ثم شغّل هذا مجددًا.",
    "With Time Machine stopped: last sync, cryptcheck, then the machine uses the encrypted folder. The plain one stays.":
      "مع إيقاف Time Machine: مزامنة أخيرة ثم cryptcheck ثم يستخدم الجهاز الافتراضي المجلد المشفر. يبقى المجلد غير المشفر.",
    "Without the encryption password and salt the encrypted backup cannot be read. Keep both outside this Mac (a password manager, paper), then confirm with --secrets-saved-elsewhere.":
      "بدون كلمة مرور التشفير والملح لا يمكن قراءة النسخة الاحتياطية المشفرة. احفظ الاثنين خارج هذا الـ Mac (مدير كلمات مرور، ورق)، ثم أكّد باستخدام --secrets-saved-elsewhere.",
    "rclone obscure failed.":
      "فشل rclone obscure.",
    "tmutil did not answer - not switching while Time Machine's state is unknown.":
      "لم يرد tmutil - لن يتم التحويل ما دامت حالة Time Machine غير معروفة.",
  ]
}
