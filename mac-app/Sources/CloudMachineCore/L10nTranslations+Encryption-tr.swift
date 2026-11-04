// Turkish translations of vm-encrypt (DriveEncryption), keyed by the English text.
extension L10nTranslations {
  static let trEncryption: [String: String] = [
    "%@ and its metadata are in Google Drive's bin (kept 30 days, still counted in the quota).":
      "%@ ve meta verileri Google Drive çöp kutusunda (30 gün saklanır, kotaya sayılmaya devam eder).",
    "'%@' is already in %@ - not replacing its password.":
      "'%@' zaten %@ içinde – parolası değiştirilmiyor.",
    "'%@' is already in the machine's rclone.conf - not replacing its password.":
      "'%@' zaten makinenin rclone.conf dosyasında – parolası değiştirilmiyor.",
    "%@ holds folders this key cannot read: another password or salt in the machine, or leftovers of an earlier try. Compare the machine's rclone.conf with the Mac's; leftovers have to be removed from %@ by hand.":
      "%@ bu anahtarın okuyamadığı klasörler içeriyor: makinede başka bir parola veya tuz ya da önceki bir denemeden kalıntılar. Makinenin rclone.conf dosyasını Mac'tekiyle karşılaştırın; kalıntılar %@ içinden elle silinmelidir.",
    "'%@' is incomplete or missing in the Mac's rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "'%@', Mac'in rclone.conf dosyasında eksik veya yok – çalıştırın: cloudmachine-agent vm-encrypt setup",
    "CLOUDMACHINE_VM_INSTANCE=%@ needs its own rclone.conf - set RCLONE_CONFIG to a copy, not %@. Its Keychain entry is service %@.":
      "CLOUDMACHINE_VM_INSTANCE=%@ kendi rclone.conf dosyasına ihtiyaç duyar – RCLONE_CONFIG'i %@ yerine bir kopyaya ayarlayın. Anahtar Zinciri kaydı %@ hizmetidir.",
    "Could not read the '%@' section on the Mac or in the machine.":
      "'%@' bölümü Mac'te veya makinede okunamadı.",
    "The machine's '%@' (password, salt or folder) differs from the Mac's - the copy would be readable only with the machine's key. Not moving anything.":
      "Makinedeki '%@' (parola, tuz veya klasör) Mac'tekinden farklı – kopya yalnızca makinenin anahtarıyla okunabilirdi. Hiçbir şey taşınmıyor.",
    "A file was restored from the encrypted backup.":
      "Şifreli yedekten bir dosya geri yüklendi.",
    "Added '%@' (%@) on the Mac and in the machine; password and salt are in the Keychain (service %@).\nSALT: %@\nKeep the password AND this salt outside this Mac now - without both the encrypted backup cannot be read. Next: cloudmachine-agent vm-encrypt copy":
      "'%@' (%@) Mac'e ve makineye eklendi; parola ve tuz Anahtar Zinciri'nde (hizmet %@).\nTUZ: %@\nParolayı VE bu tuzu şimdi bu Mac'in dışında saklayın – ikisi olmadan şifreli yedek okunamaz. Sonraki: cloudmachine-agent vm-encrypt copy",
    "Adds the encrypted remote on the Mac and in the machine (asks for the password). Moves no data.":
      "Şifreli uzak depoyu Mac'e ve makineye ekler (parolayı sorar). Veri taşımaz.",
    "Again: ":
      "Tekrar: ",
    "Copies the plain backup into the encrypted folder, in the background; backups go on.":
      "Şifrelenmemiş yedeği arka planda şifreli klasöre kopyalar; yedeklemeler sürer.",
    "Copy:             %@":
      "Kopya:            %@",
    "CLOUDMACHINE_VM_INSTANCE=%@ without CLOUDMACHINE_VM_REMOTE would use the live backup's folder - set both.":
      "CLOUDMACHINE_VM_INSTANCE=%@, CLOUDMACHINE_VM_REMOTE olmadan canlı yedeğin klasörünü kullanırdı – ikisini de ayarlayın.",
    "Could not add the remote to %@: %@":
      "Uzak depo %@ dosyasına eklenemedi: %@",
    "Could not add the remote to the machine's rclone.conf.":
      "Uzak depo makinenin rclone.conf dosyasına eklenemedi.",
    "Could not read %@.":
      "%@ okunamadı.",
    "Could not read when Time Machine last finished a backup (Full Disk Access?) - not deleting.":
      "Time Machine'in son yedeği ne zaman bitirdiği okunamadı (Tam Disk Erişimi?) – hiçbir şey silinmiyor.",
    "Could not start the copy: %@":
      "Kopyalama başlatılamadı: %@",
    "Could not write %@.":
      "%@ yazılamadı.",
    "Deleting the plain folder failed: %@":
      "Şifrelenmemiş klasör silinemedi: %@",
    "Encrypted folder: %@":
      "Şifreli klasör:   %@",
    "Encryption password: ":
      "Şifreleme parolası: ",
    "Machine uses:     %@":
      "Makine kullanıyor: %@",
    "Moves the backup on Google Drive under rclone encryption: setup, copy, switch, then delete-plain.":
      "Google Drive'daki yedeği rclone şifrelemesinin altına taşır: setup, copy, switch, ardından delete-plain.",
    "Moves the plain folder to Google Drive's bin - only after a backup has finished into the encrypted one.":
      "Şifrelenmemiş klasörü Google Drive çöp kutusuna taşır – yalnızca şifreli klasöre bir yedek tamamlandıktan sonra.",
    "Moving the machine failed; it went back to %@: %@":
      "Makine geçirilemedi; %@ klasörüne geri döndü: %@",
    "No answer from rclone in the machine - the upload queue is unknown.":
      "Makinedeki rclone yanıt vermedi – yükleme kuyruğu bilinmiyor.",
    "No backup has finished into the encrypted folder yet (last one %@, switched %@) - not deleting.":
      "Şifreli klasöre henüz hiçbir yedek tamamlanmadı (sonuncusu %@, geçiş %@) – hiçbir şey silinmiyor.",
    "Not everything is on Google Drive yet (%@ MB unsent, %@ uploading, %@ failed). Wait until the upload is done: cloudmachine-agent vm-status":
      "Henüz her şey Google Drive'da değil (%@ MB gönderilmedi, %@ yükleniyor, %@ başarısız). Yükleme bitene kadar bekleyin: cloudmachine-agent vm-status",
    "Restore a file from the encrypted backup first (Time Machine, Browse), then confirm with --restore-checked.":
      "Önce şifreli yedekten bir dosya geri yükleyin (Time Machine, Göz At), ardından --restore-checked ile onaylayın.",
    "Shows which folder the machine uses and the copy.":
      "Makinenin hangi klasörü kullandığını ve kopyanın durumunu gösterir.",
    "Switched:         %@":
      "Geçiş:            %@",
    "The copy is already running - see: cloudmachine-agent vm-encrypt status":
      "Kopyalama zaten çalışıyor – bakın: cloudmachine-agent vm-encrypt status",
    "The copy runs in the machine (%@, log %@). Backups go on meanwhile. Check: cloudmachine-agent vm-encrypt status":
      "Kopyalama makinede çalışıyor (%@, günlük %@). Bu sırada yedeklemeler sürer. Denetleyin: cloudmachine-agent vm-encrypt status",
    "The copy to the encrypted folder has not finished well (%@) - run: cloudmachine-agent vm-encrypt copy, and wait for it.":
      "Şifreli klasöre kopyalama düzgün bitmedi (%@) – çalıştırın: cloudmachine-agent vm-encrypt copy ve bitmesini bekleyin.",
    "The encryption password and salt are kept outside this Mac.":
      "Şifreleme parolası ve tuz bu Mac'in dışında saklanıyor.",
    "The guard holds Time Machine paused and would resume it during the switch. Wait until it resumes and the upload is done.":
      "Bekçi Time Machine'i duraklatılmış tutuyor ve geçiş sırasında sürdürürdü. Sürdürülene ve yükleme bitene kadar bekleyin.",
    "The image metadata has not been copied to the encrypted folder since the last backup - not deleting.":
      "Görüntünün meta verileri son yedekten beri şifreli klasöre kopyalanmadı – hiçbir şey silinmiyor.",
    "The last sync or cryptcheck failed - the machine was NOT moved: %@":
      "Son eşitleme veya cryptcheck başarısız oldu – makine TAŞINMADI: %@",
    "The machine already uses the encrypted folder - nothing to switch.":
      "Makine zaten şifreli klasörü kullanıyor – geçirilecek bir şey yok.",
    "The machine already uses the encrypted folder.":
      "Makine zaten şifreli klasörü kullanıyor.",
    "The machine does not use the encrypted folder - nothing to roll back.":
      "Makine şifreli klasörü kullanmıyor – geri alınacak bir şey yok.",
    "The machine does not use the encrypted folder - the plain folder is the backup. Not deleting it.":
      "Makine şifreli klasörü kullanmıyor – yedek, şifrelenmemiş klasördür. Silinmiyor.",
    "The machine has no '%@' remote in its rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "Makinenin rclone.conf dosyasında '%@' uzak deposu yok – çalıştırın: cloudmachine-agent vm-encrypt setup",
    "The machine is not on this app's template or does not use %@ (cloudmachine-agent vm-update first): %@":
      "Makine bu uygulamanın şablonunda değil veya %@ kullanmıyor (önce cloudmachine-agent vm-update): %@",
    "The machine now uses %@, but %@ could not be updated (%@) - fix it before anything else runs vm-setup.":
      "Makine artık %@ kullanıyor, ancak %@ güncellenemedi (%@) – başka bir şey vm-setup çalıştırmadan önce düzeltin.",
    "The machine now uses %@. %@ is kept. Turn automatic backups back on: sudo tmutil enable":
      "Makine artık %@ kullanıyor. %@ korunuyor. Otomatik yedeklemeleri yeniden açın: sudo tmutil enable",
    "The password must have at least 12 characters.":
      "Parola en az 12 karakter olmalıdır.",
    "The passwords differ - nothing was changed.":
      "Parolalar farklı – hiçbir şey değiştirilmedi.",
    "The switch the other way: decrypts what changed back into the plain folder and uses it again.":
      "Ters yönde geçiş: değişenleri şifrelenmemiş klasöre geri çözer ve onu yeniden kullanır.",
    "The upload to the encrypted folder is not finished (or rclone did not answer) - not deleting.":
      "Şifreli klasöre yükleme bitmedi (veya rclone yanıt vermedi) – hiçbir şey silinmiyor.",
    "Time Machine is backing up. Turn automatic backups off (sudo tmutil disable), stop it (tmutil stopbackup), then run this again.":
      "Time Machine yedekleme yapıyor. Otomatik yedeklemeleri kapatın (sudo tmutil disable), durdurun (tmutil stopbackup), ardından bunu yeniden çalıştırın.",
    "With Time Machine stopped: last sync, cryptcheck, then the machine uses the encrypted folder. The plain one stays.":
      "Time Machine durdurulmuşken: son eşitleme, cryptcheck, ardından makine şifreli klasörü kullanır. Şifrelenmemiş olan kalır.",
    "Without the encryption password and salt the encrypted backup cannot be read. Keep both outside this Mac (a password manager, paper), then confirm with --secrets-saved-elsewhere.":
      "Şifreleme parolası ve tuz olmadan şifreli yedek okunamaz. İkisini de bu Mac'in dışında saklayın (parola yöneticisi, kâğıt), ardından --secrets-saved-elsewhere ile onaylayın.",
    "rclone obscure failed.":
      "rclone obscure başarısız oldu.",
    "tmutil did not answer - not switching while Time Machine's state is unknown.":
      "tmutil yanıt vermedi – Time Machine'in durumu bilinmezken geçiş yapılmıyor.",
  ]
}
