// Malay translations of vm-encrypt (DriveEncryption), keyed by the English text.
extension L10nTranslations {
  static let msEncryption: [String: String] = [
    "%@ and its metadata are in Google Drive's bin (kept 30 days, still counted in the quota).":
      "%@ dan metadatanya berada dalam tong sampah Google Drive (disimpan 30 hari, masih dikira dalam kuota).",
    "'%@' is already in %@ - not replacing its password.":
      "'%@' sudah ada dalam %@ - kata laluannya tidak diganti.",
    "'%@' is already in the machine's rclone.conf - not replacing its password.":
      "'%@' sudah ada dalam rclone.conf mesin - kata laluannya tidak diganti.",
    "%@ holds folders this key cannot read: another password or salt in the machine, or leftovers of an earlier try. Compare the machine's rclone.conf with the Mac's; leftovers have to be removed from %@ by hand.":
      "%@ mengandungi folder yang tidak dapat dibaca oleh kunci ini: kata laluan atau garam lain dalam mesin, atau sisa cubaan terdahulu. Bandingkan rclone.conf mesin dengan rclone.conf Mac; sisa perlu dibuang daripada %@ secara manual.",
    "'%@' is incomplete or missing in the Mac's rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "'%@' tidak lengkap atau tiada dalam rclone.conf Mac - jalankan: cloudmachine-agent vm-encrypt setup",
    "CLOUDMACHINE_VM_INSTANCE=%@ needs its own rclone.conf - set RCLONE_CONFIG to a copy, not %@. Its Keychain entry is service %@.":
      "CLOUDMACHINE_VM_INSTANCE=%@ memerlukan rclone.conf sendiri - tetapkan RCLONE_CONFIG kepada salinan, bukan %@. Entri Rantai Kuncinya ialah perkhidmatan %@.",
    "Could not read the '%@' section on the Mac or in the machine.":
      "Bahagian '%@' tidak dapat dibaca pada Mac atau dalam mesin.",
    "The machine's '%@' (password, salt or folder) differs from the Mac's - the copy would be readable only with the machine's key. Not moving anything.":
      "'%@' mesin (kata laluan, garam atau folder) berbeza daripada Mac - salinan hanya dapat dibaca dengan kunci mesin. Tiada apa-apa dipindahkan.",
    "A file was restored from the encrypted backup.":
      "Satu fail telah dipulihkan daripada sandaran tersulit.",
    "Added '%@' (%@) on the Mac and in the machine; password and salt are in the Keychain (service %@).\nSALT: %@\nKeep the password AND this salt outside this Mac now - without both the encrypted backup cannot be read. Next: cloudmachine-agent vm-encrypt copy":
      "'%@' (%@) ditambah pada Mac dan dalam mesin; kata laluan dan garam berada dalam Rantai Kunci (perkhidmatan %@).\nGARAM: %@\nSimpan kata laluan DAN garam ini di luar Mac ini sekarang - tanpa kedua-duanya sandaran tersulit tidak dapat dibaca. Seterusnya: cloudmachine-agent vm-encrypt copy",
    "Adds the encrypted remote on the Mac and in the machine (asks for the password). Moves no data.":
      "Menambah jauh tersulit pada Mac dan dalam mesin (meminta kata laluan). Tidak memindahkan data.",
    "Again: ":
      "Sekali lagi: ",
    "Copies the plain backup into the encrypted folder, in the background; backups go on.":
      "Menyalin sandaran tidak tersulit ke folder tersulit di latar belakang; sandaran diteruskan.",
    "Copy:             %@":
      "Salinan:          %@",
    "CLOUDMACHINE_VM_INSTANCE=%@ without CLOUDMACHINE_VM_REMOTE would use the live backup's folder - set both.":
      "CLOUDMACHINE_VM_INSTANCE=%@ tanpa CLOUDMACHINE_VM_REMOTE akan menggunakan folder sandaran yang sedang digunakan - tetapkan kedua-duanya.",
    "Could not add the remote to %@: %@":
      "Tidak dapat menambah jauh ke %@: %@",
    "Could not add the remote to the machine's rclone.conf.":
      "Tidak dapat menambah jauh ke rclone.conf mesin.",
    "Could not read %@.":
      "Tidak dapat membaca %@.",
    "Could not read when Time Machine last finished a backup (Full Disk Access?) - not deleting.":
      "Tidak dapat membaca bila Time Machine terakhir menyelesaikan sandaran (Capaian Cakera Penuh?) - tiada apa-apa dipadam.",
    "Could not start the copy: %@":
      "Tidak dapat memulakan salinan: %@",
    "Could not write %@.":
      "Tidak dapat menulis %@.",
    "Deleting the plain folder failed: %@":
      "Pemadaman folder tidak tersulit gagal: %@",
    "Encrypted folder: %@":
      "Folder tersulit:  %@",
    "Encryption password: ":
      "Kata laluan penyulitan: ",
    "Machine uses:     %@":
      "Mesin guna:       %@",
    "Moves the backup on Google Drive under rclone encryption: setup, copy, switch, then delete-plain.":
      "Memindahkan sandaran di Google Drive ke bawah penyulitan rclone: setup, copy, switch, kemudian delete-plain.",
    "Moves the plain folder to Google Drive's bin - only after a backup has finished into the encrypted one.":
      "Memindahkan folder tidak tersulit ke tong sampah Google Drive - hanya selepas satu sandaran selesai ke folder tersulit.",
    "Moving the machine failed; it went back to %@: %@":
      "Pertukaran mesin gagal; ia kembali ke %@: %@",
    "No answer from rclone in the machine - the upload queue is unknown.":
      "Tiada jawapan daripada rclone dalam mesin - baris gilir muat naik tidak diketahui.",
    "No backup has finished into the encrypted folder yet (last one %@, switched %@) - not deleting.":
      "Belum ada sandaran yang selesai ke folder tersulit (terakhir %@, ditukar %@) - tiada apa-apa dipadam.",
    "Not everything is on Google Drive yet (%@ MB unsent, %@ uploading, %@ failed). Wait until the upload is done: cloudmachine-agent vm-status":
      "Belum semuanya berada di Google Drive (%@ MB belum dihantar, %@ sedang dimuat naik, %@ gagal). Tunggu sehingga muat naik selesai: cloudmachine-agent vm-status",
    "Restore a file from the encrypted backup first (Time Machine, Browse), then confirm with --restore-checked.":
      "Pulihkan satu fail daripada sandaran tersulit dahulu (Time Machine, Layari), kemudian sahkan dengan --restore-checked.",
    "Shows which folder the machine uses and the copy.":
      "Menunjukkan folder yang digunakan mesin dan keadaan salinan.",
    "Switched:         %@":
      "Ditukar:          %@",
    "The copy is already running - see: cloudmachine-agent vm-encrypt status":
      "Salinan sudah berjalan - lihat: cloudmachine-agent vm-encrypt status",
    "The copy runs in the machine (%@, log %@). Backups go on meanwhile. Check: cloudmachine-agent vm-encrypt status":
      "Salinan berjalan dalam mesin (%@, log %@). Sandaran diteruskan sementara itu. Semak: cloudmachine-agent vm-encrypt status",
    "The copy to the encrypted folder has not finished well (%@) - run: cloudmachine-agent vm-encrypt copy, and wait for it.":
      "Salinan ke folder tersulit tidak selesai dengan baik (%@) - jalankan: cloudmachine-agent vm-encrypt copy, dan tunggu sehingga selesai.",
    "The encryption password and salt are kept outside this Mac.":
      "Kata laluan penyulitan dan garam disimpan di luar Mac ini.",
    "The guard holds Time Machine paused and would resume it during the switch. Wait until it resumes and the upload is done.":
      "Pengawal menahan Time Machine dalam jeda dan akan menyambungnya semasa pertukaran. Tunggu sehingga ia disambung semula dan muat naik selesai.",
    "The image metadata has not been copied to the encrypted folder since the last backup - not deleting.":
      "Metadata imej belum disalin ke folder tersulit sejak sandaran terakhir - tiada apa-apa dipadam.",
    "The last sync or cryptcheck failed - the machine was NOT moved: %@":
      "Penyegerakan terakhir atau cryptcheck gagal - mesin TIDAK ditukar: %@",
    "The machine already uses the encrypted folder - nothing to switch.":
      "Mesin sudah menggunakan folder tersulit - tiada apa-apa untuk ditukar.",
    "The machine already uses the encrypted folder.":
      "Mesin sudah menggunakan folder tersulit.",
    "The machine does not use the encrypted folder - nothing to roll back.":
      "Mesin tidak menggunakan folder tersulit - tiada apa-apa untuk dikembalikan.",
    "The machine does not use the encrypted folder - the plain folder is the backup. Not deleting it.":
      "Mesin tidak menggunakan folder tersulit - folder tidak tersulit ialah sandarannya. Ia tidak dipadam.",
    "The machine has no '%@' remote in its rclone.conf - run: cloudmachine-agent vm-encrypt setup":
      "Mesin tiada jauh '%@' dalam rclone.conf nya - jalankan: cloudmachine-agent vm-encrypt setup",
    "The machine is not on this app's template or does not use %@ (cloudmachine-agent vm-update first): %@":
      "Mesin tidak menggunakan templat apl ini atau tidak menggunakan %@ (cloudmachine-agent vm-update dahulu): %@",
    "The machine now uses %@, but %@ could not be updated (%@) - fix it before anything else runs vm-setup.":
      "Mesin kini menggunakan %@, tetapi %@ tidak dapat dikemas kini (%@) - betulkan sebelum apa-apa lagi menjalankan vm-setup.",
    "The machine now uses %@. %@ is kept. Turn automatic backups back on: sudo tmutil enable":
      "Mesin kini menggunakan %@. %@ dikekalkan. Hidupkan semula sandaran automatik: sudo tmutil enable",
    "The password must have at least 12 characters.":
      "Kata laluan mesti sekurang-kurangnya 12 aksara.",
    "The passwords differ - nothing was changed.":
      "Kata laluan berbeza - tiada apa-apa diubah.",
    "The switch the other way: decrypts what changed back into the plain folder and uses it again.":
      "Pertukaran ke arah sebaliknya: menyahsulit perubahan kembali ke folder tidak tersulit dan menggunakannya semula.",
    "The upload to the encrypted folder is not finished (or rclone did not answer) - not deleting.":
      "Muat naik ke folder tersulit belum selesai (atau rclone tidak menjawab) - tiada apa-apa dipadam.",
    "Time Machine is backing up. Turn automatic backups off (sudo tmutil disable), stop it (tmutil stopbackup), then run this again.":
      "Time Machine sedang membuat sandaran. Matikan sandaran automatik (sudo tmutil disable), hentikannya (tmutil stopbackup), kemudian jalankan ini semula.",
    "With Time Machine stopped: last sync, cryptcheck, then the machine uses the encrypted folder. The plain one stays.":
      "Dengan Time Machine dihentikan: penyegerakan terakhir, cryptcheck, kemudian mesin menggunakan folder tersulit. Folder tidak tersulit kekal.",
    "Without the encryption password and salt the encrypted backup cannot be read. Keep both outside this Mac (a password manager, paper), then confirm with --secrets-saved-elsewhere.":
      "Tanpa kata laluan penyulitan dan garam sandaran tersulit tidak dapat dibaca. Simpan kedua-duanya di luar Mac ini (pengurus kata laluan, kertas), kemudian sahkan dengan --secrets-saved-elsewhere.",
    "rclone obscure failed.":
      "rclone obscure gagal.",
    "tmutil did not answer - not switching while Time Machine's state is unknown.":
      "tmutil tidak menjawab - tiada pertukaran selagi keadaan Time Machine tidak diketahui.",
  ]
}
