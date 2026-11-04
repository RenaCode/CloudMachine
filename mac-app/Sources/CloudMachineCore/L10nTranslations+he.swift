// Hebrew translations, keyed by the English text passed to `L10n.tr`.
extension L10nTranslations {
  static let he: [String: String] = [
    "Space limit:      %@":
      "מגבלת נפח:      %@",
    "                  Time Machine quota not set to match - run: %@":
      "                  מכסת Time Machine לא הוגדרה בהתאם - הרץ: %@",
    "Sets how much of Google Drive this Mac may use, and prints the Time Machine quota command.":
      "קובע כמה מ-Google Drive מותר ל-Mac הזה להשתמש, ומדפיס את פקודת המכסה של Time Machine.",
    "Limit in GB.":
      "המגבלה ב-GB.",
    "Limit for this Mac: %@ GB.":
      "מגבלה ל-Mac הזה: %@ GB.",
    "Now set the Time Machine quota (needs an administrator password):":
      "עכשיו הגדר את מכסת Time Machine (נדרשת סיסמת מנהל):",
    "CloudMachine - verification, Google Drive setup and installation. Called by launchd on a schedule, or by hand from Terminal.":
      "CloudMachine - בדיקה, הגדרת Google Drive והתקנה. נקרא על ידי launchd לפי לוח זמנים, או ידנית מהמסוף.",
    "Connects to Google Drive through rclone (OAuth in the browser) and creates this machine's folder.":
      "מתחבר ל-Google Drive דרך rclone (OAuth בדפדפן) ויוצר את תיקיית המכונה הזו.",
    "Overwrite the existing remote. RISKY: replaces the token and permissions.":
      "החלפת החיבור הקיים. מסוכן: מחליף את האסימון וההרשאות.",
    "Packs build/CloudMachine.app into build/CloudMachine-<version>.dmg.":
      "אורז את build/CloudMachine.app לקובץ build/CloudMachine-<version>.dmg.",
    "ERROR: %@ is missing - run 'cloudmachine-agent build-app' first":
      "שגיאה: %@ חסר - הרץ קודם 'cloudmachine-agent build-app'",
    "==> Preparing the staging folder":
      "==> מכין את תיקיית ההרכבה",
    "==> Creating %@":
      "==> יוצר את %@",
    "ERROR: hdiutil exited with code %@.":
      "שגיאה: hdiutil הסתיים בקוד %@.",
    "==> Done: %@":
      "==> הסתיים: %@",
    "On first launch (the app is not signed with an Apple Developer account):":
      "בהפעלה הראשונה (האפליקציה אינה חתומה בחשבון מפתח של Apple):",
    "1. Open %@ and drag CloudMachine.app to Applications.":
      "1. פתח את %@ וגרור את CloudMachine.app אל היישומים.",
    "2. In Finder, RIGHT-click CloudMachine.app -> Open -> Open\n   (a plain double-click shows the Gatekeeper block \"unidentified developer\").":
      "2. ב-Finder, לחץ לחיצה ימנית על CloudMachine.app -> פתח -> פתח\n   (לחיצה כפולה רגילה מציגה את חסימת Gatekeeper \"מפתח לא מזוהה\").",
    "3. Later launches work normally, with a double-click.":
      "3. הפעלות מאוחרות יותר פועלות כרגיל, בלחיצה כפולה.",
    "Builds CloudMachine.app (Release) - GUI + cloudmachine-agent in Contents/MacOS/, plus launchd/, vm/ and config/ as Resources.":
      "בונה את CloudMachine.app (Release) - ממשק גרפי + cloudmachine-agent ב-Contents/MacOS/, וכן launchd/, vm/ ו-config/ כמשאבים.",
    "Binaries for Apple Silicon and Intel at once (how CI builds a release; unnecessary locally).":
      "קבצים בינאריים ל-Apple Silicon ול-Intel יחד (כך CI בונה גרסה; מיותר מקומית).",
    "==> Building CloudMachineApp + cloudmachine-agent (release) - version %@ (%@)":
      "==> בונה את CloudMachineApp + cloudmachine-agent (release) - גרסה %@ (%@)",
    "ERROR: swift build exited with code %@.":
      "שגיאה: swift build הסתיים בקוד %@.",
    "ERROR: swift build --show-bin-path did not report the binaries directory.":
      "שגיאה: swift build --show-bin-path לא דיווח על תיקיית הקבצים הבינאריים.",
    "ERROR: no built binary found at %@":
      "שגיאה: לא נמצא קובץ בינארי שנבנה ב-%@",
    "==> Assembling the .app bundle in %@":
      "==> מרכיב את חבילת ה-.app ב-%@",
    "==> WARNING: you are building from a DIRTY tree - the version will not point to a commit.":
      "==> אזהרה: אתה בונה מעץ עבודה מלוכלך - הגרסה לא תצביע על commit.",
    "ERROR: Resources/AppIcon.icns is missing - generate it: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns":
      "שגיאה: Resources/AppIcon.icns חסר - צור אותו: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns",
    "==> Signing with the local certificate '%@' (Full Disk Access will survive later rebuilds)":
      "==> חותם בתעודה המקומית '%@' (גישה מלאה לדיסק תישמר גם אחרי בנייה מחדש)",
    "==> Signing ad-hoc (no Apple Developer account) - run 'cloudmachine-agent setup-signing-cert' once so that TCC permissions survive later rebuilds":
      "==> חותם ad-hoc (ללא חשבון מפתח של Apple) - הרץ פעם אחת 'cloudmachine-agent setup-signing-cert' כדי שהרשאות TCC יישמרו אחרי בנייה מחדש",
    "ERROR: codesign exited with code %@.":
      "שגיאה: codesign הסתיים בקוד %@.",
    "Next step: %@":
      "הצעד הבא: %@",
    "Creates a local self-signed certificate so that Full Disk Access survives later rebuilds of the app.":
      "יוצר תעודה מקומית בחתימה עצמית כדי שגישה מלאה לדיסק תישמר אחרי בנייה מחדש של האפליקציה.",
    "Certificate '%@' already exists in %@, nothing to do.":
      "התעודה '%@' כבר קיימת ב-%@, אין מה לעשות.",
    "==> Generating the key and self-signed certificate '%@'...":
      "==> יוצר את המפתח ואת התעודה בחתימה עצמית '%@'...",
    "ERROR: openssl req exited with code %@.":
      "שגיאה: openssl req הסתיים בקוד %@.",
    "ERROR: openssl pkcs12 exited with code %@.":
      "שגיאה: openssl pkcs12 הסתיים בקוד %@.",
    "==> Importing the certificate into %@ (pre-authorizing /usr/bin/codesign, so it does not ask for the keychain password every time)...":
      "==> מייבא את התעודה אל %@ (מאשר מראש את /usr/bin/codesign, כדי שלא יבקש את סיסמת מחזיק המפתחות בכל פעם)...",
    "ERROR: security import exited with code %@.":
      "שגיאה: security import הסתיים בקוד %@.",
    "==> Trusting the certificate ONLY for code signing...":
      "==> מגדיר אמון בתעודה לחתימת קוד בלבד...",
    "ERROR: security add-trusted-cert exited with code %@.":
      "שגיאה: security add-trusted-cert הסתיים בקוד %@.",
    "Done. Certificate '%@' is now available to codesign.":
      "הסתיים. התעודה '%@' זמינה כעת ל-codesign.",
    "The next 'cloudmachine-agent build-app' will use it automatically instead of an ad-hoc signature.":
      "'cloudmachine-agent build-app' הבא ישתמש בה אוטומטית במקום בחתימת ad-hoc.",
    "After THAT ONE rebuild, grant Full Disk Access one last time - later\nrebuilds will no longer reset it, as long as you sign with the same certificate.":
      "אחרי אותה בנייה מחדש אחת, הענק גישה מלאה לדיסק פעם אחרונה - בניות\nמחדש מאוחרות יותר לא יאפסו אותה, כל עוד אתה חותם באותה תעודה.",
    "Checks whether the hourly cycle STILL works (date of the last SUCCESSFUL backup) and reports failures.":
      "בודק אם המחזור השעתי עדיין פועל (תאריך הגיבוי המוצלח האחרון) ומדווח על כשלים.",
    "After this many hours without a successful backup we consider the cycle broken.":
      "אחרי מספר השעות הזה ללא גיבוי מוצלח נחשיב את המחזור כתקול.",
    "Only print the state, without a system notification.":
      "הדפס את המצב בלבד, בלי התראת מערכת.",
    "A different Time Machine preferences file - to test the watchdog on a known sample.":
      "קובץ העדפות אחר של Time Machine - לבדיקת המשגיח על דוגמה ידועה.",
    "Last successful backup: %@":
      "גיבוי מוצלח אחרון: %@",
    "Last successful backup: NONE":
      "גיבוי מוצלח אחרון: אין",
    "Last attempt:           %@":
      "ניסיון אחרון:          %@",
    "WAITING (system startup): %@":
      "ממתין (עליית המערכת): %@",
    "Backup cycle: OK":
      "מחזור הגיבוי: תקין",
    "FAILURE: %@":
      "כשל: %@",
    "         %@":
      "         %@",
    "Check the state:  %@":
      "בדיקת המצב:  %@",
    "Preparing for restart":
      "מתכונן להפעלה מחדש",
    "Prepare for restart":
      "היכון להפעלה מחדש",
    "Prepare":
      "היכון",
    "==> WARNING: git rev-list failed (%@) - using the date as the build number.":
      "==> אזהרה: git rev-list נכשל (%@) - התאריך ישמש כמספר הבנייה.",
    "Agents:           %@":
      "סוכנים:           %@",
    "CANNOT START: %@ - open CloudMachine or run backup-health to reload them":
      "לא ניתן להפעיל: %@ - פתח את CloudMachine או הרץ backup-health כדי לטעון אותם מחדש",
    "Reloaded agents that could not start: %@":
      "נטענו מחדש סוכנים שלא הצליחו לעלות: %@",
    "Drive folder:     %@":
      "תיקיית Drive:     %@",
    "Name of this Mac's folder on Google Drive (default: derived from the computer name). Set once; it cannot be changed later.":
      "שם התיקייה של ה-Mac הזה ב-Google Drive (ברירת מחדל: נגזר משם המחשב). נקבע פעם אחת ואי אפשר לשנותו אחר כך.",
    "Backup watchdog:  %@":
      "משגיח הגיבוי:  %@",
    "Prints the version, the build number and the commit this binary was built from.":
      "מדפיס את הגרסה, את מספר הבנייה ואת ה-commit שממנו נבנה הקובץ הבינארי.",
    "Only one line, without a description.":
      "שורה אחת בלבד, בלי תיאור.",
    "Build from the working tree (outside a bundle) - no version data.":
      "בנייה מעץ העבודה (מחוץ לחבילה) - אין נתוני גרסה.",
    "Version: %@":
      "גרסה: %@",
    "Build:   %@":
      "בנייה:   %@",
    "Commit:  %@":
      "Commit:  %@",
    "WARNING: built from a DIRTY tree - the binary contains code that\n         is in no commit. The commit number does NOT describe\n         what actually runs.":
      "אזהרה: נבנה מעץ עבודה מלוכלך - הקובץ הבינארי מכיל קוד\n         שאינו באף commit. מספר ה-commit אינו מתאר\n         את מה שרץ בפועל.",
    "Saving the space limit":
      "שומר את מגבלת הנפח",
    "Measuring usage on Google Drive":
      "מודד שימוש ב-Google Drive",
    "Google Drive did not answer - try again later.":
      "Google Drive לא ענה - נסה שוב מאוחר יותר.",
    "Measured.":
      "נמדד.",
    "Space limit for this Mac":
      "מגבלת נפח ל-Mac הזה",
    "Used on Google Drive":
      "בשימוש ב-Google Drive",
    "Measured %@. The watchdog measures again every few hours.":
      "נמדד %@. המשגיח מודד שוב כל כמה שעות.",
    "Limit (GB)":
      "מגבלה (GB)",
    "Save":
      "שמור",
    "Measure now":
      "מדוד עכשיו",
    "Time Machine quota: %@ GB (70%% of the limit - the copy on Drive is about a third larger than the backup inside it). Time Machine deletes the oldest backups to stay within it.":
      "מכסת Time Machine: %@ GB (70%% מהמגבלה - העותק ב-Drive גדול בכשליש מהגיבוי שבתוכו). Time Machine מוחק את הגיבויים הישנים ביותר כדי להישאר בתוכה.",
    "Set the Time Machine quota: run this in Terminal (needs sudo)":
      "הגדר את מכסת Time Machine: הרץ זאת במסוף (נדרש sudo)",
    "Connect Google Drive: run this in Terminal and approve in the browser":
      "חבר את Google Drive: הרץ זאת במסוף ואשר בדפדפן",
    "Grant Full Disk Access to CloudMachine, so it can tell whether backups complete":
      "הענק ל-CloudMachine גישה מלאה לדיסק, כדי שיוכל לדעת אם הגיבויים הושלמו",
    "Folder on Google Drive":
      "תיקייה ב-Google Drive",
    "One folder per Mac. Set once - it cannot be changed after connecting.":
      "תיקייה אחת לכל Mac. נקבעת פעם אחת - אי אפשר לשנות אחרי החיבור.",
    "Use lowercase letters, digits and dashes.":
      "השתמש באותיות לטיניות קטנות, ספרות ומקפים.",
    "Install rclone":
      "התקן את rclone",
    "Open System Settings":
      "פתח את הגדרות המערכת",
    "Install agents":
      "התקן סוכנים",
    "not checked":
      "לא נבדק",
    "none at all":
      "אין כלל",
    "%@ ago":
      "לפני %@",
    "Missing: %@":
      "חסר: %@",
    "Google Drive not connected":
      "Google Drive לא מחובר",
    "Time Machine does not point to CloudMachine":
      "Time Machine לא מצביע על CloudMachine",
    "UNKNOWN whether Time Machine points to CloudMachine - tmutil did not answer":
      "לא ידוע אם Time Machine מצביע על CloudMachine - tmutil לא ענה",
    "Backup in progress":
      "גיבוי מתבצע",
    "Unknown when the last backup was made":
      "לא ידוע מתי בוצע הגיבוי האחרון",
    "There is no completed backup at all":
      "אין אף גיבוי שהושלם",
    "No completed backup for %@":
      "אין גיבוי שהושלם מאז %@",
    "Ready":
      "מוכן",
    "Not saved: %@":
      "לא נשמר: %@",
    "Installing rclone":
      "מתקין את rclone",
    "Installing launchd agents":
      "מתקין סוכני launchd",
    "Starting backup":
      "מתחיל גיבוי",
    "Backup started.":
      "הגיבוי התחיל.",
    "Could not start the backup.":
      "לא ניתן היה להתחיל את הגיבוי.",
    "Stopping backup":
      "עוצר גיבוי",
    "Backup stopped.":
      "הגיבוי נעצר.",
    "Could not stop the backup.":
      "לא ניתן היה לעצור את הגיבוי.",
    "Could not prepare the AppleScript.":
      "לא ניתן היה להכין את ה-AppleScript.",
    "Unknown authorization error.":
      "שגיאת הרשאה לא ידועה.",
    "Waiting to upload":
      "ממתין להעלאה",
    "%@ files":
      "%@ קבצים",
    "nothing":
      "כלום",
    "Back up now":
      "גבה עכשיו",
    "Stop backup":
      "עצור גיבוי",
    "Open CloudMachine":
      "פתח את CloudMachine",
    "Quit":
      "יציאה",
    "Healthy":
      "תקין",
    "Attention":
      "שים לב",
    "Refreshed %@":
      "רוענן %@",
    "System Status":
      "מצב המערכת",
    "Action needed":
      "נדרשת פעולה",
    "not measured":
      "לא נמדד",
    "rclone did not answer":
      "rclone לא ענה",
    "Backup in Progress":
      "גיבוי מתבצע",
    "Files processed":
      "קבצים שעובדו",
    "Write speed":
      "מהירות כתיבה",
    "Operation phase":
      "שלב הפעולה",
    "Required Setup Steps":
      "שלבי הגדרה נדרשים",
    "Copy":
      "העתק",
    "Last completed backup":
      "הגיבוי האחרון שהושלם",
    "Last backup watchdog run":
      "הרצה אחרונה של משגיח הגיבוי",
    "not read":
      "לא נקרא",
    "Everything uploaded":
      "הכול הועלה",
    "File upload errors":
      "שגיאות העלאת קבצים",
    "Google Drive Credentials (OAuth 2.0)":
      "פרטי הזדהות של Google Drive (OAuth 2.0)",
    "Keychain OK":
      "מחזיק המפתחות תקין",
    "No custom keys":
      "אין מפתחות מותאמים",
    "Paste client_id...":
      "הדבק client_id...",
    "Paste client_secret...":
      "הדבק client_secret...",
    "Save securely in the Keychain":
      "שמור באופן מאובטח במחזיק המפתחות",
    "Refresh":
      "רענן",
    "Overview":
      "סקירה",
    "Backups":
      "גיבויים",
    "Storage":
      "אחסון",
    "Settings":
      "הגדרות",
    "Current status: %@":
      "המצב הנוכחי: %@",
    "Does not point to CloudMachine":
      "לא מצביע על CloudMachine",
    "tmutil did not answer":
      "tmutil לא ענה",
    "Backing up: %@ of %@":
      "מגבה: %@ מתוך %@",
    "%@ of %@":
      "%@ מתוך %@",
    "Copied":
      "הועתק",
    "No backup is running":
      "אין גיבוי רץ",
    "Time Machine starts the next one on its own schedule.":
      "Time Machine יתחיל את הבא לפי לוח הזמנים שלו.",
    "Backup cycle":
      "מחזור גיבוי",
    "%@ GiB":
      "%@ GiB",
    "%@ GiB in %@ bands, %@ uploading":
      "%@ GiB ב-%@ חלקים, מועלים: %@",
    "%@ bands":
      "%@ חלקים",
    "%@ fragments abandoned - only in the machine":
      "%@ קטעים ננטשו - קיימים במכונה בלבד",
    "127.0.0.1:5572 answers on the Mac: Lima forwards the machine's rclone remote control, which has no password. Any web page open in a browser can send it commands - including deleting the backup on Google Drive. Add the portForwards rule from vm/cmsmb.yaml to the machine and restart it (see vm/README.md).":
      "127.0.0.1:5572 עונה ב-Mac: Lima מעבירה את השליטה מרחוק של rclone במכונה, שאין לה סיסמה. כל דף אינטרנט פתוח בדפדפן יכול לשלוח לה פקודות - כולל מחיקת הגיבוי ב-Google Drive. הוסף למכונה את כלל portForwards מ-vm/cmsmb.yaml והפעל אותה מחדש (ראה vm/README.md).",
    "A service in the CloudMachine machine is not running":
      "שירות במכונה של CloudMachine אינו פועל",
    "Address":
      "כתובת",
    "Agent installation INCOMPLETE - %@ of %@ did not go in:\n%@\n%@\nEvery missing agent is a function that has silently stopped working (vm-guard watches the machine's buffer, backup-health reports failures). Fix the cause and repeat the installation.":
      "התקנת הסוכנים לא הושלמה - %@ מתוך %@ לא הותקנו:\n%@\n%@\nכל סוכן חסר הוא פונקציה שהפסיקה לפעול בלי הודעה (vm-guard עוקב אחר מאגר הביניים של המכונה, backup-health מדווח על כשלים). תקן את הסיבה וחזור על ההתקנה.",
    "All running":
      "הכול פועל",
    "Also install the launchd agents (same as install-launchd).":
      "התקן גם את סוכני launchd (כמו install-launchd).",
    "At most this many minutes of waiting for the upload.":
      "מספר הדקות המרבי להמתנה להעלאה.",
    "At the limit every new band fails with EMFILE and the backup stops. Check: cloudmachine-agent vm-status":
      "במגבלה כל חלק חדש נכשל עם EMFILE והגיבוי נעצר. בדיקה: cloudmachine-agent vm-status",
    "Cache on the machine's disk":
      "מטמון בדיסק של המכונה",
    "Connected to Google Drive, but could not create the folder '%@' - without it the machine has nowhere to keep the backup. Check the account permissions and try again.":
      "התחברנו ל-Google Drive, אבל לא ניתן היה ליצור את התיקייה '%@' - בלעדיה אין למכונה איפה לשמור את הגיבוי. בדוק את הרשאות החשבון ונסה שוב.",
    "Convert the image":
      "המר את התמונה",
    "Converting the image to 32 MB bands":
      "ממיר את התמונה לחלקים של 32 MB",
    "Could not check with the current connection whether the backup is on Google Drive (%@), so remote '%@' was NOT replaced: without that answer the new sign-in cannot be checked against it.":
      "לא ניתן היה לבדוק בחיבור הנוכחי אם הגיבוי נמצא ב-Google Drive (%@), ולכן החיבור '%@' לא הוחלף: בלי תשובה זו אי אפשר לבדוק את ההתחברות החדשה מולו.",
    "Downloads the official rclone binary into ~/.cloudmachine/bin (Google sign-in and the machine's rclone.conf).":
      "מוריד את הקובץ הבינארי הרשמי של rclone אל ~/.cloudmachine/bin (התחברות ל-Google ו-rclone.conf של המכונה).",
    "Free in the machine":
      "פנוי במכונה",
    "Free in the machine: %@":
      "פנוי במכונה: %@",
    "Generates and installs the launchd agents (app, backup watchdog, machine start, machine guard).":
      "יוצר ומתקין את סוכני launchd (אפליקציה, משגיח גיבוי, הפעלת המכונה, שומר המכונה).",
    "Install Lima, which runs the CloudMachine machine: run this in Terminal":
      "התקן את Lima, שמריצה את המכונה של CloudMachine: הרץ זאת במסוף",
    "Install rclone (signs in to Google Drive for the machine)":
      "התקן את rclone (מתחבר ל-Google Drive עבור המכונה)",
    "Install the background agents (machine start, buffer guard, backup watchdog)":
      "התקן את סוכני הרקע (הפעלת המכונה, שומר מאגר הביניים, משגיח הגיבוי)",
    "Installs rclone through Homebrew - CloudMachine itself uses the one from install-rclone.":
      "מתקין את rclone דרך Homebrew - CloudMachine עצמו משתמש בזה מ-install-rclone.",
    "Info.plist, token and mapped/ of the backup image exist only on the machine's disk; without them the bands in %@ cannot be restored. The copy (tm-meta-sync, every 15 min) goes to %@. Check: cloudmachine-agent vm-status, then in the machine: journalctl -u tm-meta-sync":
      "Info.plist, האסימון ו-mapped/ של תמונת הגיבוי קיימים רק בדיסק של המכונה; בלעדיהם אי אפשר לשחזר את החלקים ב-%@. ההעתק (tm-meta-sync, כל 15 דקות) נשלח אל %@. בדיקה: cloudmachine-agent vm-status, ואז במכונה: journalctl -u tm-meta-sync",
    "Lima says the machine is running, but a command in it did not return. Without it nothing is known about Samba, rclone or the upload. Check: cloudmachine-agent vm-status":
      "Lima אומרת שהמכונה פועלת, אבל פקודה בתוכה לא חזרה. בלעדיה לא ידוע דבר על Samba, rclone או ההעלאה. בדיקה: cloudmachine-agent vm-status",
    "Machine":
      "מכונה",
    "Machine %@":
      "מכונה %@",
    "Machine & Upload Status":
      "מצב המכונה וההעלאה",
    "Machine buffer":
      "מאגר ביניים של המכונה",
    "No Time Machine destination is the machine's share (smb://tm@<address>/CloudMachine) - backups are not being made there. The command is printed by: cloudmachine-agent vm-setup":
      "אף יעד של Time Machine אינו שיתוף המכונה (smb://tm@<address>/CloudMachine) - לא מתבצעים שם גיבויים. הפקודה מודפסת על ידי: cloudmachine-agent vm-setup",
    "Not running: %@":
      "לא פועל: %@",
    "Not set up":
      "לא מוגדר",
    "Once it runs out, rclone stops uploading, the machine's buffer fills up and backups stop being made. At a growth of ~600 MB per hourly cycle that is about %@ days.":
      "כשהמקום נגמר, rclone מפסיק להעלות, מאגר הביניים של המכונה מתמלא והגיבויים נעצרים. בקצב גידול של כ-600 MB למחזור שעתי זה בערך %@ ימים.",
    "Or rclone.conf is missing: this Mac has already set up the CloudMachine machine, so it is not connected anew blindly. Restore the file from a backup (the machine keeps its own copy in %@). To connect anyway, create an empty file at the path `%@ config file` prints and run again - the existing folder is kept.":
      "או ש-rclone.conf חסר: ה-Mac הזה כבר הגדיר את המכונה של CloudMachine, ולכן לא מתחברים מחדש באופן עיוור. שחזר את הקובץ מגיבוי (למכונה יש עותק משלה ב-%@). כדי להתחבר בכל זאת, צור קובץ ריק בנתיב ש-`%@ config file` מדפיס והרץ שוב - התיקייה הקיימת נשמרת.",
    "Point Time Machine at the machine: run this in Terminal (needs sudo; Copy includes the password)":
      "כוון את Time Machine אל המכונה: הרץ זאת במסוף (נדרש sudo; העתק כולל את הסיסמה)",
    "Points to the machine":
      "מצביע על המכונה",
    "Prepares for a restart: stops the backup, waits a while for the upload, then stops the machine cleanly.":
      "נערך להפעלה מחדש: עוצר את הגיבוי, ממתין זמן מה להעלאה, ואז עוצר את המכונה בצורה נקייה.",
    "Reading the Time Machine destination did not return within %@ s. That is how tmutil behaves when its destination hangs.":
      "קריאת היעד של Time Machine לא חזרה תוך %@ s. כך tmutil מתנהג כשהיעד שלו נתקע.",
    "Remote '%@' was NOT replaced. The new sign-in gets the 'drive.file' scope, which sees only files created under its own client_id. The existing backup was most likely created by the current connection and would become invisible to it. Before anything is written, the new token is checked against the existing backup, and the replacement is abandoned if it cannot see it. The machine keeps its own copy of the configuration until vm-setup --replace-rclone-config. To go ahead, run again with --replace-existing --accept-scope-change.":
      "החיבור '%@' לא הוחלף. ההתחברות החדשה מקבלת את ההיקף 'drive.file', שרואה רק קבצים שנוצרו תחת ה-client_id שלה. הגיבוי הקיים נוצר ככל הנראה על ידי החיבור הנוכחי ויהפוך בלתי נראה לה. לפני שנכתב משהו, האסימון החדש נבדק מול הגיבוי הקיים, וההחלפה מבוטלת אם הוא לא רואה אותו. למכונה יש עותק משלה של ההגדרות עד vm-setup --replace-rclone-config. כדי להמשיך, הרץ שוב עם --replace-existing --accept-scope-change.",
    "Remote control:   OPEN on the Mac at 127.0.0.1:5572 - any web page can send rclone commands; see vm/README.md (portForwards)":
      "שליטה מרחוק:   פתוחה ב-Mac בכתובת 127.0.0.1:5572 - כל דף אינטרנט יכול לשלוח פקודות rclone; ראה vm/README.md (portForwards)",
    "Running":
      "פועל",
    "Samba, rclone or punchfs in the machine is not active, so Time Machine has nowhere to write or the bands do not reach Google Drive. Check: cloudmachine-agent vm-status":
      "Samba, rclone או punchfs במכונה אינם פעילים, ולכן ל-Time Machine אין לאן לכתוב או שהחלקים לא מגיעים ל-Google Drive. בדיקה: cloudmachine-agent vm-status",
    "Service %@":
      "שירות %@",
    "Services":
      "שירותים",
    "Set up the CloudMachine machine (the first time it downloads Ubuntu - several minutes)":
      "הגדר את המכונה של CloudMachine (בפעם הראשונה מורידה Ubuntu - כמה דקות)",
    "Set up the CloudMachine machine again, so it prints the Time Machine command":
      "הגדר שוב את המכונה של CloudMachine, כדי שתדפיס את פקודת Time Machine",
    "Set up the machine":
      "הגדר את המכונה",
    "Setting up the CloudMachine machine":
      "מגדיר את המכונה של CloudMachine",
    "Start the CloudMachine machine":
      "הפעל את המכונה של CloudMachine",
    "Start the machine":
      "הפעל את המכונה",
    "Starting the CloudMachine machine":
      "מפעיל את המכונה של CloudMachine",
    "Still to upload: %@ GiB":
      "נשאר להעלות: %@ GiB",
    "Stopping the Time Machine backup...":
      "עוצר את הגיבוי של Time Machine...",
    "Stopping the machine %@...":
      "עוצר את המכונה %@...",
    "The CloudMachine machine does not answer":
      "המכונה של CloudMachine לא עונה",
    "The CloudMachine machine is not running":
      "המכונה של CloudMachine לא פועלת",
    "The CloudMachine machine is not set up yet":
      "המכונה של CloudMachine עדיין לא הוגדרה",
    "The CloudMachine machine is stopped":
      "המכונה של CloudMachine נעצרה",
    "The backup is stopped, the upload gets up to 30 minutes, then the machine shuts down cleanly. It starts again at the next login.":
      "הגיבוי נעצר, ההעלאה מקבלת עד 30 דקות, ואז המכונה נכבית בצורה נקייה. היא מתחילה שוב בהתחברות הבאה.",
    "The machine %@ is not running - nothing to prepare.":
      "המכונה %@ אינה פועלת - אין מה להכין.",
    "The machine is stopped and everything reached Google Drive. The Mac can be restarted; the machine starts again at login.":
      "המכונה נעצרה וכל מה שהיה הגיע ל-Google Drive. אפשר להפעיל מחדש את ה-Mac; המכונה מתחילה שוב בהתחברות.",
    "The machine is stopped. %@ GiB had not reached Google Drive yet - it is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "המכונה נעצרה. %@ GiB עדיין לא הגיעו ל-Google Drive - הם נשמרים במאגר הביניים של המכונה ויועלו אחרי ההפעלה הבאה. אפשר להפעיל מחדש את ה-Mac.",
    "The machine is stopped. rclone did not say how much was still to upload; what was not uploaded is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "המכונה נעצרה. rclone לא אמר כמה נשאר להעלות; מה שלא הועלה נשמר במאגר הביניים של המכונה ויועלה אחרי ההפעלה הבאה. אפשר להפעיל מחדש את ה-Mac.",
    "The machine's disk is a file on this disk and grows as the upload buffer fills. With no space left the machine cannot write the buffer, and Time Machine's local snapshots have nowhere to go either.":
      "הדיסק של המכונה הוא קובץ בדיסק הזה וגדל ככל שמאגר ההעלאה מתמלא. כשאין מקום, המכונה לא יכולה לכתוב למאגר, וגם לתמונות המצב המקומיות של Time Machine אין לאן ללכת.",
    "The image's metadata has never been copied to Drive":
      "המטא-נתונים של התמונה מעולם לא הועתקו ל-Drive",
    "The image's metadata was last copied to Drive %@ ago":
      "המטא-נתונים של התמונה הועתקו ל-Drive לאחרונה לפני %@",
    "The machine's disk is running out of space (%@ GB)":
      "בדיסק של המכונה נגמר המקום (%@ GB)",
    "The new sign-in does NOT see the existing backup (%@), so remote '%@' was NOT replaced and rclone.conf is unchanged. Keep the current connection, or sign in with the credential (client_id) that created the backup.":
      "ההתחברות החדשה לא רואה את הגיבוי הקיים (%@), ולכן החיבור '%@' לא הוחלף ו-rclone.conf לא השתנה. השאר את החיבור הנוכחי, או התחבר עם פרטי ההזדהות (client_id) שיצרו את הגיבוי.",
    "The upload buffer lives on this disk. The guard pauses Time Machine before it fills; if the upload does not catch up, backups stay paused.":
      "מאגר ההעלאה נמצא בדיסק הזה. השומר משהה את Time Machine לפני שהוא מתמלא; אם ההעלאה לא משלימה פער, הגיבויים נשארים מושהים.",
    "These bands exist only in the machine's buffer. The backup on Google Drive is INCOMPLETE and may not open.":
      "החלקים האלה קיימים רק במאגר הביניים של המכונה. הגיבוי ב-Google Drive לא שלם ועלול שלא להיפתח.",
    "Time Machine backs up to the machine, so without it no backup is made. Start it: limactl start %@ (or the Start button in the app).":
      "Time Machine מגבה אל המכונה, ולכן בלעדיה לא נעשה גיבוי. הפעל אותה: limactl start %@ (או הכפתור הפעל את המכונה באפליקציה).",
    "Time Machine did not stop its backup within 2 minutes (or tmutil did not answer) - the machine was NOT stopped. Try again in a moment.":
      "Time Machine לא עצר את הגיבוי שלו תוך 2 דקות (או ש-tmutil לא ענה) - המכונה לא נעצרה. נסה שוב בעוד רגע.",
    "Time Machine has created its image: stop the backup, then convert the image to 32 MB bands":
      "Time Machine יצר את התמונה שלו: עצור את הגיבוי, ואז המר את התמונה לחלקים של 32 MB",
    "To upload":
      "להעלאה",
    "Unknown whether the CloudMachine machine is running":
      "לא ידוע אם המכונה של CloudMachine פועלת",
    "Waiting for the upload to Google Drive (at most %@ min)...":
      "ממתין להעלאה ל-Google Drive (לכל היותר %@ דקות)...",
    "With --replace-existing: confirms that the new sign-in (scope 'drive.file') may not see the existing backup. The new token is still checked against the backup first.":
      "עם --replace-existing: מאשר שההתחברות החדשה (היקף 'drive.file') אולי לא רואה את הגיבוי הקיים. האסימון החדש עדיין נבדק קודם מול הגיבוי.",
    "Without it there is no way to check whether anything reached the Drive - the machine's guard is blind then.":
      "בלעדיו אין דרך לבדוק אם משהו הגיע ל-Drive - שומר המכונה עיוור אז.",
    "limactl did not answer":
      "limactl לא ענה",
    "limactl did not answer (or is not installed). That does not mean the machine is down - it means nobody has checked.":
      "limactl לא ענה (או שאינו מותקן). זה לא אומר שהמכונה כבויה - זה אומר שאיש לא בדק.",
    "limactl start failed: %@":
      "limactl start נכשל: %@",
    "limactl stop failed: %@":
      "limactl stop נכשל: %@",
    "punchfs is close to its open-file limit":
      "punchfs קרוב למגבלת הקבצים הפתוחים",
    "punchfs open files":
      "קבצים פתוחים של punchfs",
    "rclone's remote control is open on this Mac":
      "השליטה מרחוק של rclone פתוחה ב-Mac הזה",
    "statfs('/System/Volumes/Data') returned an error, so nobody knows whether the machine's disk can still grow on this Mac.":
      "statfs('/System/Volumes/Data') החזיר שגיאה, ולכן איש לא יודע אם הדיסק של המכונה יכול עוד לגדול ב-Mac הזה.",
    "Google Drive's daily upload limit stops the upload":
      "מגבלת ההעלאה היומית של Google Drive עוצרת את ההעלאה",
    "Google last refused an upload %@ ago (750 GB a day). Backups since then are only in the machine's buffer on this Mac. rclone retries every 5 min and resumes by itself when the limit passes; the guard pauses Time Machine if more than %@ GiB waits.":
      "Google סירבה להעלאה לאחרונה לפני %@ (750 GB ביום). גיבויים מאז נמצאים רק במאגר הביניים של המכונה ב-Mac הזה. rclone מנסה שוב כל 5 דקות וממשיך מעצמו כשהמגבלה חולפת; השומר משהה את Time Machine אם ממתינים יותר מ-%@ GiB.",
    "Usage on Google Drive is not being measured":
      "השימוש ב-Google Drive אינו נמדד",
    "The last measurement (%@ GB) is from %@, %@ ago - rclone size has not answered since. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "המדידה האחרונה (%@ GB) היא מ-%@, לפני %@ - rclone size לא ענה מאז. עד שיענה, דבר לא עוקב אחר המגבלה של %@ GB: ההתראות על 90%% ועל 100%% שותקות. בדוק את vm-status, או לחץ על מדוד עכשיו בחלון.",
    "rclone size has not answered even once. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "rclone size לא ענה אפילו פעם אחת. עד שיענה, דבר לא עוקב אחר המגבלה של %@ GB: ההתראות על 90%% ועל 100%% שותקות. בדוק את vm-status, או לחץ על מדוד עכשיו בחלון.",
    "Saved in the Keychain. Connecting Google Drive (configure-remote) will use them.":
      "נשמר במחזיק המפתחות. החיבור ל-Google Drive (configure-remote) ישתמש בהם.",
    "Saved in the Keychain. The existing Google Drive connection keeps its old client_id, and on this Mac it should stay that way: a connection made with the new keys (the 'drive.file' scope) cannot see the backup created by the old one. Do not replace the connection here; the new keys are for a Mac that is not connected yet.":
      "נשמר במחזיק המפתחות. החיבור הקיים ל-Google Drive שומר על ה-client_id הישן שלו, וב-Mac הזה כדאי שיישאר כך: חיבור שנוצר במפתחות החדשים (ההיקף 'drive.file') לא רואה את הגיבוי שנוצר בחיבור הישן. אל תחליף כאן את החיבור; המפתחות החדשים מיועדים ל-Mac שעדיין לא מחובר.",
    "it is not there for the new token":
      "הוא לא קיים עבור האסימון החדש",
    "Cancel":
      "ביטול",
    "ACTION NEEDED":
      "נדרשת פעולה",
    "WILL PASS BY ITSELF — DO NOTHING":
      "יעבור מעצמו - אל תעשה דבר",
    "UNKNOWN — CHECK AGAIN SHORTLY":
      "לא ידוע - בדוק שוב בעוד רגע",
    "ALL GOOD":
      "הכול תקין",
    "Upload is not working":
      "ההעלאה לא עובדת",
    "Upload stopped — no space left on Google Drive":
      "ההעלאה נעצרה - אין מקום פנוי ב-Google Drive",
    "%@ backup fragments not uploaded":
      "%@ קטעי גיבוי לא הועלו",
    "Upload cannot keep up with writes":
      "ההעלאה לא עומדת בקצב הכתיבה",
    "Upload paused — Google daily limit":
      "ההעלאה מושהית - מגבלה יומית של Google",
    "Uploading to Google Drive — %@ queued":
      "מעלה ל-Google Drive - %@ בתור",
    "Everything uploaded to Google Drive":
      "הכול הועלה ל-Google Drive",
    "Unknown what is waiting in the queue":
      "לא ידוע מה ממתין בתור",
    "There is no connection to Google Drive, so backups are only made on this Mac. If this does not pass by itself within a few minutes, check the network and the connection to Drive.":
      "אין חיבור ל-Google Drive, ולכן גיבויים נעשים רק ב-Mac הזה. אם זה לא חולף מעצמו תוך כמה דקות, בדוק את הרשת ואת החיבור ל-Drive.",
    "There is no space left on Google Drive. This will NOT pass by itself — you need to free up space on Drive. Until then Time Machine is paused, so that it does not fill up this Mac's disk.":
      "אין מקום פנוי ב-Google Drive. זה לא יעבור מעצמו - צריך לפנות מקום ב-Drive. עד אז Time Machine מושהה, כדי שלא ימלא את הדיסק של ה-Mac הזה.",
    "%@ backup fragments could not be uploaded and rclone stopped trying. These fragments exist only on this Mac, so the backup on Drive is incomplete. This needs checking.":
      "%@ קטעי גיבוי לא ניתנו להעלאה ו-rclone הפסיק לנסות. הקטעים האלה קיימים רק ב-Mac הזה, ולכן הגיבוי ב-Drive אינו שלם. צריך לבדוק.",
    "Time Machine is writing faster than the upload goes, and the buffer has filled up. The backup will be paused until the upload catches up — this is a safeguard against filling up the disk, not a failure.":
      "Time Machine כותב מהר יותר ממה שההעלאה מתקדמת, ומאגר הביניים התמלא. הגיבוי יושהה עד שההעלאה תשלים פער - זו הגנה מפני מילוי הדיסק, לא תקלה.",
    "Google accepts 750 GB per day and that limit has been used up. There is nothing to do: the limit renews by itself, usually within a few hours. Time Machine backups are made normally in the meantime and wait in the buffer — they will be uploaded as soon as Google starts accepting again.":
      "Google מקבלת 750 GB ביום והמגבלה הזו נוצלה. אין מה לעשות: המגבלה מתחדשת מעצמה, בדרך כלל תוך כמה שעות. בינתיים גיבויי Time Machine נעשים כרגיל וממתינים במאגר הביניים - הם יועלו ברגע ש-Google תחזור לקבל.",
    "%@ backup fragments are queued and on their way to Drive.":
      "%@ קטעי גיבוי בתור ובדרך ל-Drive.",
    "Nothing is waiting in the queue — the backup on Google Drive is complete.":
      "דבר לא ממתין בתור - הגיבוי ב-Google Drive שלם.",
    "rclone did not answer the question about the queue, so it is unknown how many backups are still waiting to be uploaded. This does not mean something broke — under load the answer can be late. It only means that right now nobody knows. If it persists, the backup cycle check will report it.":
      "rclone לא ענה על השאלה לגבי התור, ולכן לא ידוע כמה גיבויים עדיין ממתינים להעלאה. זה לא אומר שמשהו נשבר - תחת עומס התשובה יכולה להתאחר. זה אומר רק שכרגע איש לא יודע. אם זה נמשך, בדיקת מחזור הגיבוי תדווח על כך.",
    "unknown error":
      "שגיאה לא ידועה",
    "rclone lsf ended with an error":
      "rclone lsf הסתיים בשגיאה",
    "This Mac is close to its space limit on Google Drive":
      "ה-Mac הזה קרוב למגבלת הנפח שלו ב-Google Drive",
    "%@ GB of %@ GB used. Time Machine deletes the oldest backups to stay within its quota; check that the quota is set (vm-status).":
      "%@ GB מתוך %@ GB בשימוש. Time Machine מוחק את הגיבויים הישנים ביותר כדי להישאר במכסה שלו; ודא שהמכסה מוגדרת (vm-status).",
    "This Mac is over its space limit on Google Drive":
      "ה-Mac הזה חרג ממגבלת הנפח שלו ב-Google Drive",
    "%@ GB of %@ GB used. Set the Time Machine quota (command in the app window or vm-status), or raise the limit.":
      "%@ GB מתוך %@ GB בשימוש. הגדר את מכסת Time Machine (הפקודה בחלון האפליקציה או ב-vm-status), או הגדל את המגבלה.",
    "not set":
      "לא מוגדר",
    "%@ GB - usage not measured yet":
      "%@ GB - השימוש עדיין לא נמדד",
    "%@ of %@ GB used (%@%%)":
      "%@ מתוך %@ GB בשימוש (%@%%)",
    "The limit must be a whole number of GB above zero.":
      "המגבלה חייבת להיות מספר שלם של GB הגדול מאפס.",
    "machines.json cannot be read, so it was not overwritten. Fix or remove it first.":
      "אי אפשר לקרוא את machines.json, ולכן לא נכתב עליו דבר. תקן או הסר אותו קודם.",
    "'%@' is not a valid folder name: use lowercase letters, digits and dashes.":
      "'%@' אינו שם תיקייה תקין: השתמש באותיות לטיניות קטנות, ספרות ומקפים.",
    "This Mac already backs up to folder '%@'. Switching to '%@' would start a new, empty backup and orphan the existing one, so nothing was changed.":
      "ה-Mac הזה כבר מגבה לתיקייה '%@'. מעבר ל-'%@' היה מתחיל גיבוי חדש וריק ומשאיר את הקיים יתום, ולכן דבר לא שונה.",
    "This Mac already has a CloudMachine installation, whose backup is in folder '%@'. Switching to '%@' would orphan it, so nothing was changed.":
      "ב-Mac הזה כבר יש התקנה של CloudMachine, והגיבוי שלה בתיקייה '%@'. מעבר ל-'%@' היה משאיר אותו יתום, ולכן דבר לא שונה.",
    "Could not save the folder name to %@: %@":
      "לא ניתן היה לשמור את שם התיקייה ב-%@: %@",
    "Homebrew is not installed. Install it manually: https://brew.sh":
      "Homebrew אינו מותקן. התקן אותו ידנית: https://brew.sh",
    "Installing rclone failed: %@":
      "התקנת rclone נכשלה: %@",
    "Installed rclone.":
      "rclone הותקן.",
    "Own Google credentials: set.":
      "פרטי הזדהות עצמיים של Google: מוגדרים.",
    "INCOMPLETE: %@ is missing - rclone will use rclone's shared client_id anyway.":
      "לא שלם: %@ חסר - rclone ישתמש ב-client_id המשותף שלו בכל זאת.",
    "No own credentials - rclone uses the shared client_id, rate-limited jointly and being retired in 2026.":
      "אין פרטי הזדהות עצמיים - rclone משתמש ב-client_id המשותף, המוגבל בקצב במשותף ושיופסק ב-2026.",
    "Empty value - not saving.":
      "ערך ריק - לא נשמר.",
    "Keychain refused: %@":
      "מחזיק המפתחות סירב: %@",
    "DIRTY-TREE":
      "DIRTY-TREE",
    "Cannot create the working directory: %@":
      "לא ניתן ליצור את תיקיית העבודה: %@",
    "Could not read the rclone version number.":
      "לא ניתן היה לקרוא את מספר הגרסה של rclone.",
    "Could not download %@.":
      "לא ניתן היה להוריד את %@.",
    "No entry for %@ in SHA256SUMS.":
      "אין רשומה עבור %@ ב-SHA256SUMS.",
    "Could not compute the checksum.":
      "לא ניתן היה לחשב את סכום הביקורת.",
    "SHA256 checksum does not match - NOT installing.\n  expected: %@\n  computed: %@":
      "סכום הביקורת SHA256 אינו תואם - לא מתקין.\n  צפוי: %@\n  מחושב: %@",
    "Could not unpack the archive.":
      "לא ניתן היה לפתוח את הארכיון.",
    "Could not install the binary: %@":
      "לא ניתן היה להתקין את הקובץ הבינארי: %@",
    "Installed rclone %@ in %@ (SHA256 checksum matches).":
      "rclone %@ הותקן ב-%@ (סכום הביקורת SHA256 תואם).",
    "%@ did not respond within the allotted time (the process was left orphaned in the background).":
      "%@ לא הגיב בזמן שהוקצב (התהליך נשאר יתום ברקע).",
    "Cannot launch %@: %@":
      "לא ניתן להפעיל את %@: %@",
    "Remote '%@' already exists and was NOT touched.\nOverwriting it replaces the token and the permission scope; a credential with the 'drive.file' scope does not see files created by the previous one, so the existing backup becomes unreachable.\nIf you really want to replace it, first back up ~/.config/rclone/rclone.conf and run again with --replace-existing.":
      "החיבור '%@' כבר קיים ולא נגעו בו.\nהחלפתו מחליפה את האסימון ואת היקף ההרשאות; פרטי הזדהות עם ההיקף 'drive.file' לא רואים קבצים שנוצרו על ידי קודמיהם, ולכן הגיבוי הקיים הופך בלתי נגיש.\nאם אתה באמת רוצה להחליף, גבה קודם את ~/.config/rclone/rclone.conf והרץ שוב עם --replace-existing.",
    "Could not check whether remote '%@' already exists (rclone listremotes did not answer or failed), so nothing was changed. Run `%@ listremotes` to see the error, then try again.":
      "לא ניתן היה לבדוק אם החיבור '%@' כבר קיים (rclone listremotes לא ענה או נכשל), ולכן דבר לא שונה. הרץ `%@ listremotes` כדי לראות את השגיאה, ואז נסה שוב.",
    "Could not check whether this Mac already has a CloudMachine installation (rclone did not answer), so no folder was chosen. Try again in a moment.":
      "לא ניתן היה לבדוק אם ב-Mac הזה כבר יש התקנה של CloudMachine (rclone לא ענה), ולכן לא נבחרה תיקייה. נסה שוב בעוד רגע.",
    "rclone authorize failed (%@). If that binary is missing, start with: cloudmachine-agent install-rclone.":
      "rclone authorize נכשל (%@). אם הקובץ הבינארי חסר, התחל ב: cloudmachine-agent install-rclone.",
    "Could not read the token from the output of rclone authorize.":
      "לא ניתן היה לקרוא את האסימון מהפלט של rclone authorize.",
    "rclone config create failed.":
      "rclone config create נכשל.",
    "Connected to Google Drive as remote '%@', folder %@.":
      "מחובר ל-Google Drive כחיבור '%@', תיקייה %@.",
    "tmutil is not responding - unknown where the backup goes":
      "tmutil לא מגיב - לא ידוע לאן הגיבוי הולך",
    "No successful backup for %@":
      "אין גיבוי מוצלח מזה %@",
    "Last COMPLETED backup: %@. The cycle is hourly, so that is %@ missed runs.":
      "הגיבוי האחרון שהושלם: %@. המחזור שעתי, כלומר זה %@ הרצות שהוחמצו.",
    "There is NOT A SINGLE successful backup":
      "אין אף גיבוי מוצלח",
    "The Time Machine preferences contain no date of a completed backup for this destination.":
      "העדפות Time Machine אינן כוללות תאריך של גיבוי שהושלם ליעד הזה.",
    "The last backup attempt did not end in a backup":
      "ניסיון הגיבוי האחרון לא הסתיים בגיבוי",
    "The attempt at %@ is newer than the last successful backup at %@.":
      "הניסיון ב-%@ חדש יותר מהגיבוי המוצלח האחרון ב-%@.",
    "Time Machine reports an error in the last run (RESULT=%@)":
      "Time Machine מדווח על שגיאה בהרצה האחרונה (RESULT=%@)",
    "A non-zero RESULT in the Time Machine preferences means the run did not succeed.":
      "RESULT שאינו אפס בהעדפות Time Machine פירושו שההרצה לא הצליחה.",
    "rclone failed to upload %@ files":
      "rclone נכשל בהעלאת %@ קבצים",
    "Buffer full of nothing but unsent data":
      "מאגר הביניים מלא בנתונים שלא נשלחו בלבד",
    "rclone has nothing left to evict from the buffer - the upload cannot keep up or has stalled.":
      "לא נשאר ל-rclone מה לפנות ממאגר הביניים - ההעלאה לא עומדת בקצב או נתקעה.",
    "The rclone control interface is not responding":
      "ממשק השליטה של rclone לא מגיב",
    "Google Drive is running out of space (%@ GB)":
      "ב-Google Drive נגמר המקום (%@ GB)",
    "The Mac's disk is running out of space (%@ GB)":
      "בדיסק של ה-Mac נגמר המקום (%@ GB)",
    "Cannot read the Time Machine preferences":
      "אי אפשר לקרוא את העדפות Time Machine",
    "%@ is unreadable - most often Full Disk Access is missing. Without this file it is UNKNOWN when the last backup was made, so we treat it as a failure, not as the absence of a problem.":
      "%@ אינו קריא - לרוב חסרה גישה מלאה לדיסק. בלי הקובץ הזה לא ידוע מתי בוצע הגיבוי האחרון, ולכן אנו מתייחסים לכך ככשל, לא כהיעדר בעיה.",
    "Cannot measure free space on the Mac's disk":
      "אי אפשר למדוד מקום פנוי בדיסק של ה-Mac",
    "%@ days":
      "%@ ימים",
    "CloudMachine: backup is not working":
      "CloudMachine: הגיבוי לא עובד",
    "unknown reason":
      "סיבה לא ידועה",
    "osascript did not show the notification (permissions or no graphical session)":
      "osascript לא הציג את ההתראה (הרשאות או שאין סשן גרפי)",
    "UNDELIVERED ALARM: %@":
      "התראה שלא נמסרה: %@",
    "from %@, reason: %@":
      "מ-%@, סיבה: %@",
    "The system notification was not delivered - you will see this alarm ONLY here.":
      "התראת המערכת לא נמסרה - תראה את ההתראה הזו רק כאן.",
    "%@ (%@ ago)":
      "%@ (לפני %@)",
    "%@ - marker from the FUTURE":
      "%@ - סימון מהעתיד",
    "%@ (%@ ago) - THE WATCHDOG MAY NOT BE RUNNING":
      "%@ (לפני %@) - ייתכן שהמשגיח אינו פועל",
    "NEVER - the watchdog has not recorded a single run":
      "אף פעם - המשגיח לא רשם אף הרצה",
    "Could not find the launchd/ directory with templates.":
      "לא נמצאה תיקיית launchd/ עם התבניות.",
    "Could not find the compiled cloudmachine-agent binary.":
      "לא נמצא הקובץ הבינארי המקומפל cloudmachine-agent.",
    "ABORTED: could not put cloudmachine-agent in a stable location\n(%@) - most often a lack of space or permissions.\nNOT installing agents pointing at %@: that path\ndisappears on the next `swift build` or `git clean`, and backups stop\nwithout any visible signal.":
      "בוטל: לא ניתן היה להציב את cloudmachine-agent במיקום יציב\n(%@) - לרוב בגלל חוסר מקום או הרשאות.\nלא מתקינים סוכנים שמצביעים על %@: הנתיב הזה\nנעלם ב-`swift build` או ב-`git clean` הבא, והגיבויים נעצרים\nבלי שום סימן גלוי.",
    "ABORTED: %@":
      "בוטל: %@",
    "Could not list the templates in %@.":
      "לא ניתן היה לרשום את התבניות ב-%@.",
    "could not read the template %@":
      "לא ניתן היה לקרוא את התבנית %@",
    "could not write %@ (lack of space or permissions)":
      "לא ניתן היה לכתוב את %@ (חוסר מקום או הרשאות)",
    "launchctl load refused to load %@":
      "launchctl load סירב לטעון את %@",
    "NOT A SINGLE agent was loaded.":
      "אף סוכן לא נטען.",
    "Only these went in: %@.":
      "רק אלה הותקנו: %@.",
    "Could not load any launchd agent.":
      "לא ניתן היה לטעון אף סוכן launchd.",
    "Installed agents: %@":
      "סוכנים שהותקנו: %@",
    "                  WARNING: close to the limit - new bands will fail with EMFILE":
      "                  אזהרה: קרוב למגבלה - חלקים חדשים ייכשלו עם EMFILE",
    "%@/bands on Google Drive is not empty - it may hold another backup. NOT overwriting it; check it by hand.":
      "%@/bands ב-Google Drive אינו ריק - ייתכן שיש בו גיבוי אחר. לא כותבים עליו; בדוק אותו ידנית.",
    "Address:          %@":
      "כתובת:          %@",
    "Already prepared (%@ exists) - nothing to do.":
      "כבר הוכן (%@ קיים) - אין מה לעשות.",
    "Converts Time Machine's new, empty image in the machine to 32 MB bands and moves the bands to Google Drive.":
      "ממיר את התמונה החדשה והריקה של Time Machine במכונה לחלקים של 32 MB ומעביר את החלקים ל-Google Drive.",
    "Copy rclone.conf into the machine even if it already has one.":
      "העתק את rclone.conf למכונה גם אם כבר יש בה אחד.",
    "Copying the converted image into the machine failed: %@":
      "העתקת התמונה שהומרה למכונה נכשלה: %@",
    "Copying the image to the Mac failed: %@":
      "העתקת התמונה ל-Mac נכשלה: %@",
    "Could not ask Lima about the machine: %@":
      "לא ניתן היה לשאול את Lima על המכונה: %@",
    "Could not carry the Time Machine files over: %@":
      "לא ניתן היה להעביר את קובצי Time Machine: %@",
    "Could not check the image in the machine.":
      "לא ניתן היה לבדוק את התמונה במכונה.",
    "Could not copy the rclone configuration into the machine.":
      "לא ניתן היה להעתיק את הגדרות rclone למכונה.",
    "Could not create %@ on Google Drive: %@":
      "לא ניתן היה ליצור את %@ ב-Google Drive: %@",
    "Could not create %@: %@":
      "לא ניתן היה ליצור את %@: %@",
    "Could not find the vm/ directory with the machine template.":
      "לא נמצאה תיקיית vm/ עם תבנית המכונה.",
    "Could not read the image size.":
      "לא ניתן היה לקרוא את גודל התמונה.",
    "Could not set the SMB password of user %@ in the machine.":
      "לא ניתן היה להגדיר את סיסמת ה-SMB של המשתמש %@ במכונה.",
    "Could not stop smbd in the machine.":
      "לא ניתן היה לעצור את smbd במכונה.",
    "Could not write %@ in the machine.":
      "לא ניתן היה לכתוב את %@ במכונה.",
    "Could not write the password file %@.":
      "לא ניתן היה לכתוב את קובץ הסיסמה %@.",
    "Creates or starts the CloudMachine machine (Lima), gives it rclone's configuration and an SMB password, and prints the Time Machine command.":
      "יוצר או מפעיל את המכונה של CloudMachine (Lima), נותן לה את ההגדרות של rclone וסיסמת SMB, ומדפיס את פקודת Time Machine.",
    "Creating the machine %@ (first start downloads Ubuntu and installs packages - several minutes)...":
      "יוצר את המכונה %@ (בהפעלה הראשונה מורידה Ubuntu ומתקינה חבילות - כמה דקות)...",
    "Done: %@ has %@ MB bands on Google Drive; the original is kept in %@ in the machine. Start the backup: tmutil startbackup":
      "הסתיים: ל-%@ יש חלקים של %@ MB ב-Google Drive; המקור נשמר ב-%@ במכונה. התחל את הגיבוי: tmutil startbackup",
    "exit code %@, no message":
      "קוד יציאה %@, ללא הודעה",
    "Image metadata:   NEVER copied to %@ - check tm-meta-sync in the machine":
      "מטא-נתוני תמונה:   מעולם לא הועתקו אל %@ - בדוק את tm-meta-sync במכונה",
    "Image metadata:   copied %@ ago to %@":
      "מטא-נתוני תמונה:   הועתקו לפני %@ אל %@",
    "Image metadata:   last copied %@ ago - OVERDUE (%@)":
      "מטא-נתוני תמונה:   הועתקו לאחרונה לפני %@ - באיחור (%@)",
    "Image metadata:   not copied yet - waits for vm-prepare-bundle":
      "מטא-נתוני תמונה:   עדיין לא הועתקו - ממתינים ל-vm-prepare-bundle",
    "Backup %@, paused by the guard %@: %@":
      "גיבוי %@, הושהה על ידי השומר %@: %@",
    "Free in machine:  %@ GiB":
      "פנוי במכונה:  %@ GiB",
    "fsck_apfs -n found problems: %@":
      "fsck_apfs -n מצא בעיות: %@",
    "Google Drive folder: %@":
      "תיקיית Google Drive: %@",
    "hdiutil attach of the converted image failed: %@":
      "hdiutil attach של התמונה שהומרה נכשל: %@",
    "hdiutil convert failed: %@":
      "hdiutil convert נכשל: %@",
    "Image name in the machine (default: from the computer name).":
      "שם התמונה במכונה (ברירת מחדל: משם המחשב).",
    "Installing the converted image FAILED: %@\nsmbd is left STOPPED so Time Machine does not open a half-installed image. The original is in %@ in the machine.":
      "התקנת התמונה שהומרה נכשלה: %@\nsmbd נשאר עצור כדי ש-Time Machine לא יפתח תמונה שהותקנה למחצה. המקור ב-%@ במכונה.",
    "limactl create failed: %@":
      "limactl create נכשל: %@",
    "limactl list failed: %@":
      "limactl list נכשל: %@",
    "limactl not found - install Lima: brew install lima":
      "limactl לא נמצא - התקן את Lima: brew install lima",
    "limactl start failed: %@\nThe machine's own log: %@":
      "limactl start נכשל: %@\nהיומן של המכונה עצמה: %@",
    "Machine %@ is running.":
      "המכונה %@ פועלת.",
    "Machine %@ was already running.":
      "המכונה %@ כבר פעלה.",
    "Machine:          %@ (%@)":
      "מכונה:          %@ (%@)",
    "Machine:          %@":
      "מכונה:          %@",
    "Machine:          not created - run: cloudmachine-agent vm-setup":
      "מכונה:          לא נוצרה - הרץ: cloudmachine-agent vm-setup",
    "no answer within the time limit":
      "אין תשובה בתוך מגבלת הזמן",
    "No image %@ in the machine.":
      "אין תמונה %@ במכונה.",
    "No image in the machine yet - point Time Machine at the share and let it create one first.":
      "עדיין אין תמונה במכונה - כוון את Time Machine אל השיתוף ותן לו ליצור אחת קודם.",
    "No rclone configuration at %@ - connect Google Drive first (configure-remote).":
      "אין הגדרות rclone ב-%@ - חבר קודם את Google Drive (configure-remote).",
    "no SMB destination":
      "אין יעד SMB",
    "One check of the machine's upload buffer: pauses Time Machine when it fills, resumes what it paused.":
      "בדיקה אחת של מאגר ההעלאה של המכונה: משהה את Time Machine כשהוא מתמלא, וממשיך את מה שהושהה.",
    "Packing the converted image failed: %@":
      "אריזת התמונה שהומרה נכשלה: %@",
    "Packing the image failed: %@":
      "אריזת התמונה נכשלה: %@",
    "No answer from the machine (rclone rc) - the guard would do nothing.":
      "אין תשובה מהמכונה (rclone rc) - השומר לא יעשה דבר.",
    "Only print what the guard would decide - for trying thresholds on a throwaway machine.":
      "הדפס רק מה שהשומר היה מחליט - לניסוי ספי הפעלה במכונה זמנית.",
    "Pause above this many GiB in the buffer.":
      "השהה מעל מספר GiB זה במאגר הביניים.",
    "Pause when the machine has less free than this, in GiB.":
      "השהה כשהפנוי במכונה קטן מזה, ב-GiB.",
    "Point Time Machine at the machine (once, needs an administrator password):":
      "כוון את Time Machine אל המכונה (פעם אחת, נדרשת סיסמת מנהל):",
    "punchfs files:    %@ open, limit %@":
      "קבצי punchfs:    %@ פתוחים, מגבלה %@",
    "rclone configuration already in the machine - kept (--replace-rclone-config replaces it).":
      "הגדרות rclone כבר קיימות במכונה - נשמרו (--replace-rclone-config מחליף אותן).",
    "rclone configuration copied into the machine.":
      "הגדרות rclone הועתקו למכונה.",
    "rclone-tm or punchfs is not running in the machine - see cloudmachine-agent vm-status.":
      "rclone-tm או punchfs אינו פועל במכונה - ראה cloudmachine-agent vm-status.",
    "Resume below this many GiB (only a backup the guard paused).":
      "המשך מתחת למספר GiB זה (רק של גיבוי שהשומר השהה).",
    "Service %@: %@":
      "שירות %@: %@",
    "Several images in the machine (%@) - choose one with --bundle.":
      "כמה תמונות במכונה (%@) - בחר אחת עם --bundle.",
    "Shows the machine: address, services, upload buffer, free space and the Time Machine destination.":
      "מציג את המכונה: כתובת, שירותים, מאגר העלאה, מקום פנוי ויעד Time Machine.",
    "SMB password stored in %@ (mode 600).":
      "סיסמת SMB נשמרה ב-%@ (מצב 600).",
    "The converted image does not have %@-byte bands.":
      "לתמונה שהומרה אין חלקים של %@ בייטים.",
    "The converted image has no APFS partition.":
      "לתמונה שהומרה אין מחיצת APFS.",
    "The image already takes %@ MB - this command converts only a new, empty image (under %@ MB).":
      "התמונה כבר תופסת %@ MB - הפקודה הזו ממירה רק תמונה חדשה וריקה (מתחת ל-%@ MB).",
    "The image is encrypted - converting encrypted images is not supported.":
      "התמונה מוצפנת - המרת תמונות מוצפנות אינה נתמכת.",
    "The image was not changed; smbd started again.":
      "התמונה לא שונתה; smbd הופעל שוב.",
    "The machine does not answer - is it running? cloudmachine-agent vm-status":
      "המכונה לא עונה - האם היא פועלת? cloudmachine-agent vm-status",
    "The machine has no address on the vzNAT network.":
      "למכונה אין כתובת ברשת vzNAT.",
    "The services in the machine did not start - check: cloudmachine-agent vm-status":
      "השירותים במכונה לא עלו - בדוק: cloudmachine-agent vm-status",
    "Time Machine is backing up - stop it first: tmutil stopbackup":
      "Time Machine מגבה - עצור אותו קודם: tmutil stopbackup",
    "Time Machine:     %@":
      "Time Machine:     %@",
    "Time Machine:     NOT pointing at the machine (%@)":
      "Time Machine:     לא מצביע על המכונה (%@)",
    "Time Machine:     tmutil did not answer":
      "Time Machine:     tmutil לא ענה",
    "tmutil did not answer - not touching the image while its state is unknown.":
      "tmutil לא ענה - לא נוגעים בתמונה כל עוד מצבה לא ידוע.",
    "unknown":
      "לא ידוע",
    "Unpacking the image failed: %@":
      "פריקת התמונה נכשלה: %@",
    "Still to upload:  %@ GiB in %@ bands, uploading %@ (cache on disk %@ GiB)":
      "נשאר להעלות:  %@ GiB ב-%@ חלקים, מועלים %@ (מטמון בדיסק %@ GiB)",
    "Excluded %@ (the machine and its upload buffer) from Time Machine.":
      "%@ (המכונה ומאגר ההעלאה שלה) הוחרג מ-Time Machine.",
    "WARNING: could not exclude %@ from Time Machine - run: tmutil addexclusion %@":
      "אזהרה: לא ניתן היה להחריג את %@ מ-Time Machine - הרץ: tmutil addexclusion %@",
    "Upload buffer:    no answer from rclone (rc %@)":
      "מאגר העלאה:    אין תשובה מ-rclone (rc %@)",
    "When Time Machine has created its empty image, stop the backup (tmutil stopbackup) and run: cloudmachine-agent vm-prepare-bundle":
      "כש-Time Machine יוצר את התמונה הריקה שלו, עצור את הגיבוי (tmutil stopbackup) והרץ: cloudmachine-agent vm-prepare-bundle",
    "Unsent %@ GiB, free %@ GiB (pause above %@ GiB unsent or below %@ GiB free, resume below %@ GiB).":
      "לא נשלחו %@ GiB, פנויים %@ GiB (השהיה מעל %@ GiB שלא נשלחו או מתחת ל-%@ GiB פנויים, המשך מתחת ל-%@ GiB).",
    "Upload:           Google's daily limit refused an upload %@ ago - rclone retries every 5 min and resumes by itself":
      "העלאה:           המגבלה היומית של Google סירבה להעלאה לפני %@ - rclone מנסה שוב כל 5 דקות וממשיך מעצמו",
    "no":
      "לא",
    "running":
      "פועל",
    "stopped":
      "נעצר",
    "yes":
      "כן",
    "%@\nThe previous template is in %@ - copy it back over lima.yaml and run limactl start %@.":
      "%@\nהתבנית הקודמת ב-%@ - העתק אותה חזרה על lima.yaml והרץ limactl start %@.",
    "Could not read this app's machine template (limactl template copy).":
      "לא ניתן היה לקרוא את תבנית המכונה של האפליקציה הזו (limactl template copy).",
    "Could not replace %@: %@":
      "לא ניתן היה להחליף את %@: %@",
    "Machine %@ already runs this app's template.":
      "המכונה %@ כבר פועלת עם התבנית של האפליקציה הזו.",
    "Machine %@ now runs this app's template; the previous one is in %@.":
      "המכונה %@ פועלת כעת עם התבנית של האפליקציה הזו; הקודמת ב-%@.",
    "Moves the machine onto this app's template (two restarts, never during a backup).":
      "מעביר את המכונה לתבנית של האפליקציה הזו (שתי הפעלות מחדש, לעולם לא בזמן גיבוי).",
    "No machine %@ - create it with: cloudmachine-agent vm-setup":
      "אין מכונה %@ - צור אותה עם: cloudmachine-agent vm-setup",
    "Template:         OLDER than this app's - run: cloudmachine-agent vm-update":
      "תבנית:           ישנה יותר מזו של האפליקציה - הרץ: cloudmachine-agent vm-update",
    "Template:         not compared":
      "תבנית:           לא הושוותה",
    "Template:         this app's":
      "תבנית:           של האפליקציה הזו",
    "The machine has no %@ - run cloudmachine-agent vm-setup first.":
      "במכונה אין %@ - הרץ קודם cloudmachine-agent vm-setup.",
    "The machine restarted, but not every service is running - check: cloudmachine-agent vm-status. The previous template is in %@.":
      "המכונה הופעלה מחדש, אבל לא כל השירותים פועלים - בדוק: cloudmachine-agent vm-status. התבנית הקודמת ב-%@.",
    "The template changes the machine itself (%@) - that needs a new machine, not an update.":
      "התבנית משנה את המכונה עצמה (%@) - לכך נדרשת מכונה חדשה, לא עדכון.",
    "The upload to Google Drive hangs":
      "ההעלאה ל-Google Drive תקועה",
    "Time Machine is backing up - try again when it has finished.":
      "Time Machine מגבה - נסה שוב כשיסיים.",
    "Upload:           HANGS - bands in progress, none uploaded for %@ (network?); see /var/log/rclone-tm.log in the machine":
      "העלאה:           תקועה - חלקים בעיבוד, אף אחד לא הועלה במשך %@ (רשת?); ראה /var/log/rclone-tm.log במכונה",
    "limactl stop failed - nothing was changed.":
      "limactl stop נכשל - דבר לא שונה.",
    "rclone has bands in progress, but none has been uploaded for %@ - usually a broken network connection, which rclone does not report as an error. Backups since then are only in the machine's buffer. When the network comes back the upload resumes by itself (on 28.10.2026 within 80 s); if it does not, restarting the machine (prepare-shutdown, limactl start) drops the dead connections.":
      "ל-rclone יש חלקים בעיבוד, אבל אף אחד לא הועלה במשך %@ - לרוב בגלל חיבור רשת שנותק, ש-rclone אינו מדווח עליו כשגיאה. גיבויים מאז נמצאים רק במאגר הביניים של המכונה. כשהרשת חוזרת ההעלאה ממשיכה מעצמה (ב-28.10.2026 תוך 80 s); אם לא, הפעלה מחדש של המכונה (prepare-shutdown, limactl start) מנתקת את החיבורים המתים.",
    "tmutil did not answer - not restarting the machine while its state is unknown.":
      "tmutil לא ענה - לא מפעילים מחדש את המכונה כל עוד מצבה לא ידוע.",
    "The machine's share cannot be read":
      "לא ניתן לקרוא את השיתוף של המכונה",
    "Unknown whether the machine's share can be read":
      "לא ידוע אם ניתן לקרוא את השיתוף של המכונה",
    "Samba in the machine does not answer this Mac":
      "Samba במכונה לא עונה ל-Mac הזה",
    "Unknown whether Samba in the machine answers this Mac":
      "לא ידוע אם Samba במכונה עונה ל-Mac הזה",
    "Reading 1 byte of %@ in the machine failed: %@. Every service says it is active, yet Time Machine cannot use the image there. Nothing restarts it by itself. Check: cloudmachine-agent vm-status, then in the machine: journalctl -u punchfs -u tm-bands-bind -u rclone-tm":
      "קריאת בית אחד מ-%@ במכונה נכשלה: %@. כל שירות מדווח שהוא פעיל, ובכל זאת Time Machine לא יכול להשתמש בתמונה שם. שום דבר לא מפעיל אותו מחדש מעצמו. בדיקה: cloudmachine-agent vm-status, ואז במכונה: journalctl -u punchfs -u tm-bands-bind -u rclone-tm",
    "Reading 1 byte of %@ in the machine has not returned for %@ s. That is how a hung punchfs or rclone mount behaves. Nothing is restarted while the state is unknown - a restart under a write still going could lose it. Check in the machine: journalctl -u punchfs -u rclone-tm":
      "קריאת בית אחד מ-%@ במכונה לא חזרה כבר %@ שנ'. כך מתנהג עיגון תקוע של punchfs או rclone. שום דבר לא מופעל מחדש כל עוד המצב לא ידוע - הפעלה מחדש באמצע כתיבה שעדיין מתבצעת עלולה לאבד אותה. בדיקה במכונה: journalctl -u punchfs -u rclone-tm",
    "An SMB connection to %@ got no answer within %@ s. Time Machine reaches the machine at this address. Check the machine's network and smbd: cloudmachine-agent vm-status":
      "חיבור SMB אל %@ לא קיבל תשובה בתוך %@ שנ'. Time Machine מגיע למכונה בכתובת הזו. בדקו את הרשת של המכונה ואת smbd: cloudmachine-agent vm-status",
    "The machine did not report its address, so nobody could try an SMB connection. Check: cloudmachine-agent vm-status":
      "המכונה לא דיווחה על הכתובת שלה, ולכן איש לא יכול היה לנסות חיבור SMB. בדיקה: cloudmachine-agent vm-status",
    "An SMB connection to %@ failed (%@). Time Machine reaches the machine at this address, so no backup is made. Check the machine's network and smbd: cloudmachine-agent vm-status":
      "חיבור SMB אל %@ נכשל (%@). Time Machine מגיע למכונה בכתובת הזו, ולכן לא נוצר גיבוי. בדקו את הרשת של המכונה ואת smbd: cloudmachine-agent vm-status",
    "readable":
      "קריא",
    "no image yet":
      "עדיין אין תמונה",
    "answers":
      "עונה",
    "Share read:       %@":
      "קריאת השיתוף:     %@",
    "Samba from Mac:   %@":
      "Samba מה-Mac:     %@",
    "This Mac found no route to %@ (%@). Either the route to the machine is gone, or macOS Local Network privacy has not allowed CloudMachine - then allow it in System Settings > Privacy & Security > Local Network. Check: cloudmachine-agent vm-status":
      "ה-Mac הזה לא מצא נתיב אל %@ (%@). או שהנתיב למכונה נעלם, או שפרטיות \"רשת מקומית\" של macOS לא התירה ל-CloudMachine - במקרה כזה התירו זאת בהגדרות המערכת > פרטיות ואבטחה > רשת מקומית. בדיקה: cloudmachine-agent vm-status",
  ]
}
