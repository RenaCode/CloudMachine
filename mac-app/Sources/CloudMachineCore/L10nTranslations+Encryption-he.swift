// Hebrew translations of vm-encrypt (DriveEncryption), keyed by the English text.
extension L10nTranslations {
  static let heEncryption: [String: String] = [
    "%@ and its metadata are in Google Drive's bin (kept 30 days, still counted in the quota).":
      "%@ והמטא-נתונים שלו נמצאים בפח של Google Drive (נשמרים 30 יום ועדיין נספרים במכסה).",
    "'%@' is already in %@ - not replacing its password.":
      "'%@' כבר נמצא ב-%@ - הסיסמה שלו לא תוחלף.",
    "'%@' is already in the machine's rclone.conf - not replacing its password.":
      "'%@' כבר נמצא ב-rclone.conf של המכונה - הסיסמה שלו לא תוחלף.",
    "%@ holds folders this key cannot read: another password or salt in the machine, or leftovers of an earlier try. Compare the machine's rclone.conf with the Mac's; leftovers have to be removed from %@ by hand.":
      "%@ מכיל תיקיות שהמפתח הזה לא יכול לקרוא: סיסמה או מלח אחרים במכונה, או שאריות מניסיון קודם. השווה את rclone.conf של המכונה לזה שב-Mac; יש להסיר את השאריות מ-%@ באופן ידני.",
    "'%@' is incomplete or missing in the Mac's rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "'%@' חסר או לא שלם ב-rclone.conf של ה-Mac - הרץ: cloudmachine-agent vm-encrypt setup",
    "CLOUDMACHINE_VM_INSTANCE=%@ needs its own rclone.conf - set RCLONE_CONFIG to a copy, not %@. Its Keychain entry is service %@.":
      "CLOUDMACHINE_VM_INSTANCE=%@ צריכה קובץ rclone.conf משלה - הגדר את RCLONE_CONFIG לעותק, לא ל-%@. הרשומה שלה במחזיק המפתחות היא השירות %@.",
    "Could not read the '%@' section on the Mac or in the machine.":
      "לא ניתן היה לקרוא את המקטע '%@' ב-Mac או במכונה.",
    "The machine's '%@' (password, salt or folder) differs from the Mac's - the copy would be readable only with the machine's key. Not moving anything.":
      "'%@' של המכונה (סיסמה, מלח או תיקייה) שונה מזה שב-Mac - את העותק ניתן היה לקרוא רק עם המפתח של המכונה. שום דבר לא מועבר.",
    "A file was restored from the encrypted backup.":
      "קובץ שוחזר מהגיבוי המוצפן.",
    "Added '%@' (%@) on the Mac and in the machine; password and salt are in the Keychain (service %@).\nSALT: %@\nKeep the password AND this salt outside this Mac now - without both the encrypted backup cannot be read. Next: cloudmachine-agent vm-encrypt copy":
      "'%@' (%@) נוסף ב-Mac ובמכונה; הסיסמה והמלח נמצאים במחזיק המפתחות (שירות %@).\nמלח: %@\nשמור עכשיו את הסיסמה ואת המלח הזה מחוץ ל-Mac הזה - בלי שניהם אי אפשר לקרוא את הגיבוי המוצפן. הבא: cloudmachine-agent vm-encrypt copy",
    "Adds the encrypted remote on the Mac and in the machine (asks for the password). Moves no data.":
      "מוסיף את היעד המרוחק המוצפן ב-Mac ובמכונה (מבקש את הסיסמה). לא מעביר נתונים.",
    "Again: ":
      "שוב: ",
    "Copies the plain backup into the encrypted folder, in the background; backups go on.":
      "מעתיק את הגיבוי הלא מוצפן לתיקייה המוצפנת ברקע; הגיבויים ממשיכים.",
    "Copy:             %@":
      "העתקה:            %@",
    "CLOUDMACHINE_VM_INSTANCE=%@ without CLOUDMACHINE_VM_REMOTE would use the live backup's folder - set both.":
      "CLOUDMACHINE_VM_INSTANCE=%@ ללא CLOUDMACHINE_VM_REMOTE תשתמש בתיקיית הגיבוי הפעיל - הגדר את שניהם.",
    "Could not add the remote to %@: %@":
      "לא ניתן היה להוסיף את היעד המרוחק ל-%@: %@",
    "Could not add the remote to the machine's rclone.conf.":
      "לא ניתן היה להוסיף את היעד המרוחק ל-rclone.conf של המכונה.",
    "Could not read %@.":
      "לא ניתן היה לקרוא את %@.",
    "Could not read when Time Machine last finished a backup (Full Disk Access?) - not deleting.":
      "לא ניתן היה לקרוא מתי Time Machine סיים לאחרונה גיבוי (גישה מלאה לדיסק?) - שום דבר לא נמחק.",
    "Could not start the copy: %@":
      "לא ניתן היה להתחיל את ההעתקה: %@",
    "Could not write %@.":
      "לא ניתן היה לכתוב את %@.",
    "Deleting the plain folder failed: %@":
      "מחיקת התיקייה הלא מוצפנת נכשלה: %@",
    "Encrypted folder: %@":
      "תיקייה מוצפנת:    %@",
    "Encryption password: ":
      "סיסמת הצפנה: ",
    "Machine uses:     %@":
      "המכונה משתמשת:   %@",
    "Moves the backup on Google Drive under rclone encryption: setup, copy, switch, then delete-plain.":
      "מעביר את הגיבוי ב-Google Drive אל מתחת להצפנה של rclone: setup, copy, switch ואז delete-plain.",
    "Moves the plain folder to Google Drive's bin - only after a backup has finished into the encrypted one.":
      "מעביר את התיקייה הלא מוצפנת לפח של Google Drive - רק אחרי שגיבוי הסתיים בתיקייה המוצפנת.",
    "Moving the machine failed; it went back to %@: %@":
      "העברת המכונה נכשלה; היא חזרה אל %@: %@",
    "No answer from rclone in the machine - the upload queue is unknown.":
      "אין תשובה מ-rclone במכונה - תור ההעלאה לא ידוע.",
    "No backup has finished into the encrypted folder yet (last one %@, switched %@) - not deleting.":
      "עדיין אף גיבוי לא הסתיים בתיקייה המוצפנת (האחרון %@, הועבר %@) - שום דבר לא נמחק.",
    "Not everything is on Google Drive yet (%@ MB unsent, %@ uploading, %@ failed). Wait until the upload is done: cloudmachine-agent vm-status":
      "עדיין לא הכול ב-Google Drive (%@ MB לא נשלחו, %@ בהעלאה, %@ נכשלו). המתן עד שההעלאה תסתיים: cloudmachine-agent vm-status",
    "Restore a file from the encrypted backup first (Time Machine, Browse), then confirm with --restore-checked.":
      "שחזר קודם קובץ מהגיבוי המוצפן (Time Machine, עיון), ואז אשר עם --restore-checked.",
    "Shows which folder the machine uses and the copy.":
      "מציג באיזו תיקייה המכונה משתמשת ואת מצב ההעתקה.",
    "Switched:         %@":
      "הועבר:            %@",
    "The copy is already running - see: cloudmachine-agent vm-encrypt status":
      "ההעתקה כבר פועלת - ראה: cloudmachine-agent vm-encrypt status",
    "The copy runs in the machine (%@, log %@). Backups go on meanwhile. Check: cloudmachine-agent vm-encrypt status":
      "ההעתקה פועלת במכונה (%@, יומן %@). בינתיים הגיבויים ממשיכים. בדיקה: cloudmachine-agent vm-encrypt status",
    "The copy to the encrypted folder has not finished well (%@) - run: cloudmachine-agent vm-encrypt copy, and wait for it.":
      "ההעתקה לתיקייה המוצפנת לא הסתיימה כראוי (%@) - הרץ: cloudmachine-agent vm-encrypt copy, והמתן לה.",
    "The encryption password and salt are kept outside this Mac.":
      "סיסמת ההצפנה והמלח נשמרים מחוץ ל-Mac הזה.",
    "The guard holds Time Machine paused and would resume it during the switch. Wait until it resumes and the upload is done.":
      "השומר מחזיק את Time Machine מושהה והיה מחדש אותו במהלך ההעברה. המתן עד שיחודש וההעלאה תסתיים.",
    "The image metadata has not been copied to the encrypted folder since the last backup - not deleting.":
      "המטא-נתונים של התמונה לא הועתקו לתיקייה המוצפנת מאז הגיבוי האחרון - שום דבר לא נמחק.",
    "The last sync or cryptcheck failed - the machine was NOT moved: %@":
      "הסנכרון האחרון או cryptcheck נכשל - המכונה לא הועברה: %@",
    "The machine already uses the encrypted folder - nothing to switch.":
      "המכונה כבר משתמשת בתיקייה המוצפנת - אין מה להעביר.",
    "The machine already uses the encrypted folder.":
      "המכונה כבר משתמשת בתיקייה המוצפנת.",
    "The machine does not use the encrypted folder - nothing to roll back.":
      "המכונה לא משתמשת בתיקייה המוצפנת - אין מה לבטל.",
    "The machine does not use the encrypted folder - the plain folder is the backup. Not deleting it.":
      "המכונה לא משתמשת בתיקייה המוצפנת - התיקייה הלא מוצפנת היא הגיבוי. היא לא נמחקת.",
    "The machine has no '%@' remote in its rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "למכונה אין יעד מרוחק '%@' ב-rclone.conf שלה - הרץ: cloudmachine-agent vm-encrypt setup",
    "The machine is not on this app's template or does not use %@ (cloudmachine-agent vm-update first): %@":
      "המכונה לא על התבנית של היישום הזה או לא משתמשת ב-%@ (קודם cloudmachine-agent vm-update): %@",
    "The machine now uses %@, but %@ could not be updated (%@) - fix it before anything else runs vm-setup.":
      "המכונה משתמשת עכשיו ב-%@, אבל לא ניתן היה לעדכן את %@ (%@) - תקן זאת לפני שמשהו אחר מריץ vm-setup.",
    "The machine now uses %@. %@ is kept. Turn automatic backups back on: sudo tmutil enable":
      "המכונה משתמשת עכשיו ב-%@. %@ נשמרת. הפעל מחדש גיבויים אוטומטיים: sudo tmutil enable",
    "The password must have at least 12 characters.":
      "הסיסמה חייבת להכיל לפחות 12 תווים.",
    "The passwords differ - nothing was changed.":
      "הסיסמאות שונות - שום דבר לא שונה.",
    "The switch the other way: decrypts what changed back into the plain folder and uses it again.":
      "ההעברה בכיוון ההפוך: מפענח את מה שהשתנה בחזרה לתיקייה הלא מוצפנת ומשתמש בה שוב.",
    "The upload to the encrypted folder is not finished (or rclone did not answer) - not deleting.":
      "ההעלאה לתיקייה המוצפנת לא הסתיימה (או ש-rclone לא ענה) - שום דבר לא נמחק.",
    "Time Machine is backing up. Turn automatic backups off (sudo tmutil disable), stop it (tmutil stopbackup), then run this again.":
      "Time Machine מגבה כרגע. כבה גיבויים אוטומטיים (sudo tmutil disable), עצור אותו (tmutil stopbackup), ואז הרץ זאת שוב.",
    "With Time Machine stopped: last sync, cryptcheck, then the machine uses the encrypted folder. The plain one stays.":
      "כש-Time Machine עצור: סנכרון אחרון, cryptcheck, ואז המכונה משתמשת בתיקייה המוצפנת. הלא מוצפנת נשארת.",
    "Without the encryption password and salt the encrypted backup cannot be read. Keep both outside this Mac (a password manager, paper), then confirm with --secrets-saved-elsewhere.":
      "בלי סיסמת ההצפנה והמלח אי אפשר לקרוא את הגיבוי המוצפן. שמור את שניהם מחוץ ל-Mac הזה (מנהל סיסמאות, נייר), ואז אשר עם --secrets-saved-elsewhere.",
    "rclone obscure failed.":
      "rclone obscure נכשל.",
    "tmutil did not answer - not switching while Time Machine's state is unknown.":
      "tmutil לא ענה - אין העברה כל עוד המצב של Time Machine לא ידוע.",
  ]
}
