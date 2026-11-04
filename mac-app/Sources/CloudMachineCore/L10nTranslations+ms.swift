// Malay translations, keyed by the English text passed to `L10n.tr`.
extension L10nTranslations {
  static let ms: [String: String] = [
    "Space limit:      %@":
      "Had ruang:        %@",
    "                  Time Machine quota not set to match - run: %@":
      "                  Kuota Time Machine belum ditetapkan sepadan - jalankan: %@",
    "Sets how much of Google Drive this Mac may use, and prints the Time Machine quota command.":
      "Menetapkan jumlah Google Drive yang boleh digunakan oleh Mac ini dan mencetak arahan kuota Time Machine.",
    "Limit in GB.":
      "Had dalam GB.",
    "Limit for this Mac: %@ GB.":
      "Had untuk Mac ini: %@ GB.",
    "Now set the Time Machine quota (needs an administrator password):":
      "Sekarang tetapkan kuota Time Machine (memerlukan kata laluan pentadbir):",
    "CloudMachine - verification, Google Drive setup and installation. Called by launchd on a schedule, or by hand from Terminal.":
      "CloudMachine - pengesahan, persediaan Google Drive dan pemasangan. Dipanggil oleh launchd mengikut jadual, atau secara manual dari Terminal.",
    "Connects to Google Drive through rclone (OAuth in the browser) and creates this machine's folder.":
      "Menyambung ke Google Drive melalui rclone (OAuth dalam pelayar) dan mencipta folder untuk mesin ini.",
    "Overwrite the existing remote. RISKY: replaces the token and permissions.":
      "Tulis ganti remote sedia ada. BERISIKO: token dan kebenaran akan diganti.",
    "Packs build/CloudMachine.app into build/CloudMachine-<version>.dmg.":
      "Membungkus build/CloudMachine.app menjadi build/CloudMachine-<version>.dmg.",
    "ERROR: %@ is missing - run 'cloudmachine-agent build-app' first":
      "RALAT: %@ tiada - jalankan 'cloudmachine-agent build-app' dahulu",
    "==> Preparing the staging folder":
      "==> Menyediakan folder pementasan",
    "==> Creating %@":
      "==> Mencipta %@",
    "ERROR: hdiutil exited with code %@.":
      "RALAT: hdiutil tamat dengan kod %@.",
    "==> Done: %@":
      "==> Selesai: %@",
    "On first launch (the app is not signed with an Apple Developer account):":
      "Semasa pelancaran pertama (app ini tidak ditandatangani dengan akaun Apple Developer):",
    "1. Open %@ and drag CloudMachine.app to Applications.":
      "1. Buka %@ dan seret CloudMachine.app ke folder Aplikasi.",
    "2. In Finder, RIGHT-click CloudMachine.app -> Open -> Open\n   (a plain double-click shows the Gatekeeper block \"unidentified developer\").":
      "2. Dalam Finder, klik KANAN CloudMachine.app -> Buka -> Buka\n   (klik dua kali biasa memaparkan sekatan Gatekeeper \"pembangun tidak dikenal pasti\").",
    "3. Later launches work normally, with a double-click.":
      "3. Pelancaran seterusnya berfungsi seperti biasa, dengan klik dua kali.",
    "Builds CloudMachine.app (Release) - GUI + cloudmachine-agent in Contents/MacOS/, plus launchd/, vm/ and config/ as Resources.":
      "Membina CloudMachine.app (Release) - GUI + cloudmachine-agent dalam Contents/MacOS/, serta launchd/, vm/ dan config/ sebagai Resources.",
    "Binaries for Apple Silicon and Intel at once (how CI builds a release; unnecessary locally).":
      "Binari untuk Apple Silicon dan Intel serentak (cara CI membina keluaran; tidak perlu secara setempat).",
    "==> Building CloudMachineApp + cloudmachine-agent (release) - version %@ (%@)":
      "==> Membina CloudMachineApp + cloudmachine-agent (release) - versi %@ (%@)",
    "ERROR: swift build exited with code %@.":
      "RALAT: swift build tamat dengan kod %@.",
    "ERROR: swift build --show-bin-path did not report the binaries directory.":
      "RALAT: swift build --show-bin-path tidak melaporkan direktori binari.",
    "ERROR: no built binary found at %@":
      "RALAT: tiada binari terbina ditemui di %@",
    "==> Assembling the .app bundle in %@":
      "==> Memasang bungkusan .app dalam %@",
    "==> WARNING: you are building from a DIRTY tree - the version will not point to a commit.":
      "==> AMARAN: anda membina daripada pokok KOTOR - versi tidak menunjuk kepada sebarang commit.",
    "ERROR: Resources/AppIcon.icns is missing - generate it: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns":
      "RALAT: Resources/AppIcon.icns tiada - jana: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns",
    "==> Signing with the local certificate '%@' (Full Disk Access will survive later rebuilds)":
      "==> Menandatangani dengan sijil setempat '%@' (Capaian Cakera Penuh akan kekal selepas binaan semula)",
    "==> Signing ad-hoc (no Apple Developer account) - run 'cloudmachine-agent setup-signing-cert' once so that TCC permissions survive later rebuilds":
      "==> Menandatangani ad-hoc (tiada akaun Apple Developer) - jalankan 'cloudmachine-agent setup-signing-cert' sekali supaya kebenaran TCC kekal selepas binaan semula",
    "ERROR: codesign exited with code %@.":
      "RALAT: codesign tamat dengan kod %@.",
    "Next step: %@":
      "Langkah seterusnya: %@",
    "Creates a local self-signed certificate so that Full Disk Access survives later rebuilds of the app.":
      "Mencipta sijil tandatangan sendiri setempat supaya Capaian Cakera Penuh kekal selepas app dibina semula.",
    "Certificate '%@' already exists in %@, nothing to do.":
      "Sijil '%@' sudah wujud dalam %@, tiada apa-apa untuk dilakukan.",
    "==> Generating the key and self-signed certificate '%@'...":
      "==> Menjana kunci dan sijil tandatangan sendiri '%@'...",
    "ERROR: openssl req exited with code %@.":
      "RALAT: openssl req tamat dengan kod %@.",
    "ERROR: openssl pkcs12 exited with code %@.":
      "RALAT: openssl pkcs12 tamat dengan kod %@.",
    "==> Importing the certificate into %@ (pre-authorizing /usr/bin/codesign, so it does not ask for the keychain password every time)...":
      "==> Mengimport sijil ke dalam %@ (membenarkan /usr/bin/codesign terlebih dahulu, supaya kata laluan rantai kunci tidak diminta setiap kali)...",
    "ERROR: security import exited with code %@.":
      "RALAT: security import tamat dengan kod %@.",
    "==> Trusting the certificate ONLY for code signing...":
      "==> Mempercayai sijil HANYA untuk penandatanganan kod...",
    "ERROR: security add-trusted-cert exited with code %@.":
      "RALAT: security add-trusted-cert tamat dengan kod %@.",
    "Done. Certificate '%@' is now available to codesign.":
      "Selesai. Sijil '%@' kini tersedia untuk codesign.",
    "The next 'cloudmachine-agent build-app' will use it automatically instead of an ad-hoc signature.":
      "'cloudmachine-agent build-app' yang berikutnya akan menggunakannya secara automatik dan bukannya tandatangan ad-hoc.",
    "After THAT ONE rebuild, grant Full Disk Access one last time - later\nrebuilds will no longer reset it, as long as you sign with the same certificate.":
      "Selepas SATU binaan semula itu, berikan Capaian Cakera Penuh sekali lagi buat kali terakhir - binaan\nsemula seterusnya tidak akan menetapkannya semula selagi anda menandatangani dengan sijil yang sama.",
    "Checks whether the hourly cycle STILL works (date of the last SUCCESSFUL backup) and reports failures.":
      "Menyemak sama ada kitaran setiap jam MASIH berfungsi (tarikh sandaran BERJAYA yang terakhir) dan melaporkan kegagalan.",
    "After this many hours without a successful backup we consider the cycle broken.":
      "Selepas sekian jam tanpa sandaran yang berjaya, kitaran dianggap rosak.",
    "Only print the state, without a system notification.":
      "Hanya cetak keadaan, tanpa pemberitahuan sistem.",
    "A different Time Machine preferences file - to test the watchdog on a known sample.":
      "Fail pilihan Time Machine yang lain - untuk menguji pengawas pada sampel yang diketahui.",
    "Last successful backup: %@":
      "Sandaran berjaya terakhir: %@",
    "Last successful backup: NONE":
      "Sandaran berjaya terakhir: TIADA",
    "Last attempt:           %@":
      "Percubaan terakhir:      %@",
    "WAITING (system startup): %@":
      "MENUNGGU (permulaan sistem): %@",
    "Backup cycle: OK":
      "Kitaran sandaran: OK",
    "FAILURE: %@":
      "KEGAGALAN: %@",
    "         %@":
      "         %@",
    "Check the state:  %@":
      "Semak keadaan:  %@",
    "Preparing for restart":
      "Bersedia untuk mulakan semula",
    "Prepare for restart":
      "Sedia untuk mulakan semula",
    "Prepare":
      "Sediakan",
    "==> WARNING: git rev-list failed (%@) - using the date as the build number.":
      "==> AMARAN: git rev-list gagal (%@) - tarikh digunakan sebagai nombor binaan.",
    "Agents:           %@":
      "Ejen:             %@",
    "CANNOT START: %@ - open CloudMachine or run backup-health to reload them":
      "TIDAK DAPAT DIMULAKAN: %@ - buka CloudMachine atau jalankan backup-health untuk memuatkannya semula",
    "Reloaded agents that could not start: %@":
      "Ejen yang tidak dapat dimulakan telah dimuatkan semula: %@",
    "Drive folder:     %@":
      "Folder Drive:     %@",
    "Name of this Mac's folder on Google Drive (default: derived from the computer name). Set once; it cannot be changed later.":
      "Nama folder Mac ini di Google Drive (lalai: diperoleh daripada nama komputer). Ditetapkan sekali; tidak boleh diubah kemudian.",
    "Backup watchdog:  %@":
      "Pengawas sandaran: %@",
    "Prints the version, the build number and the commit this binary was built from.":
      "Mencetak versi, nombor binaan dan commit tempat binari ini dibina.",
    "Only one line, without a description.":
      "Hanya satu baris, tanpa penerangan.",
    "Build from the working tree (outside a bundle) - no version data.":
      "Binaan daripada pokok kerja (di luar bungkusan) - tiada data versi.",
    "Version: %@":
      "Versi:  %@",
    "Build:   %@":
      "Binaan: %@",
    "Commit:  %@":
      "Commit: %@",
    "WARNING: built from a DIRTY tree - the binary contains code that\n         is in no commit. The commit number does NOT describe\n         what actually runs.":
      "AMARAN: dibina daripada pokok KOTOR - binari mengandungi kod yang\n         tiada dalam sebarang commit. Nombor commit TIDAK menerangkan\n         apa yang sebenarnya berjalan.",
    "Saving the space limit":
      "Menyimpan had ruang",
    "Measuring usage on Google Drive":
      "Mengukur penggunaan di Google Drive",
    "Google Drive did not answer - try again later.":
      "Google Drive tidak menjawab - cuba lagi nanti.",
    "Measured.":
      "Telah diukur.",
    "Space limit for this Mac":
      "Had ruang untuk Mac ini",
    "Used on Google Drive":
      "Digunakan di Google Drive",
    "Measured %@. The watchdog measures again every few hours.":
      "Diukur %@. Pengawas mengukur semula setiap beberapa jam.",
    "Limit (GB)":
      "Had (GB)",
    "Save":
      "Simpan",
    "Measure now":
      "Ukur sekarang",
    "Time Machine quota: %@ GB (70%% of the limit - the copy on Drive is about a third larger than the backup inside it). Time Machine deletes the oldest backups to stay within it.":
      "Kuota Time Machine: %@ GB (70%% daripada had - salinan di Drive kira-kira satu pertiga lebih besar daripada sandaran di dalamnya). Time Machine memadam sandaran paling lama untuk kekal dalam kuota.",
    "Set the Time Machine quota: run this in Terminal (needs sudo)":
      "Tetapkan kuota Time Machine: jalankan ini dalam Terminal (memerlukan sudo)",
    "Connect Google Drive: run this in Terminal and approve in the browser":
      "Sambung Google Drive: jalankan ini dalam Terminal dan luluskan dalam pelayar",
    "Grant Full Disk Access to CloudMachine, so it can tell whether backups complete":
      "Berikan Capaian Cakera Penuh kepada CloudMachine supaya ia dapat mengetahui sama ada sandaran selesai",
    "Folder on Google Drive":
      "Folder di Google Drive",
    "One folder per Mac. Set once - it cannot be changed after connecting.":
      "Satu folder bagi setiap Mac. Ditetapkan sekali - tidak boleh diubah selepas disambungkan.",
    "Use lowercase letters, digits and dashes.":
      "Gunakan huruf kecil, digit dan tanda sempang.",
    "Install rclone":
      "Pasang rclone",
    "Open System Settings":
      "Buka Tetapan Sistem",
    "Install agents":
      "Pasang ejen",
    "not checked":
      "tidak disemak",
    "none at all":
      "langsung tiada",
    "%@ ago":
      "%@ lalu",
    "Missing: %@":
      "Tiada: %@",
    "Google Drive not connected":
      "Google Drive tidak disambungkan",
    "Time Machine does not point to CloudMachine":
      "Time Machine tidak menuju ke CloudMachine",
    "UNKNOWN whether Time Machine points to CloudMachine - tmutil did not answer":
      "TIDAK DIKETAHUI sama ada Time Machine menuju ke CloudMachine - tmutil tidak menjawab",
    "Backup in progress":
      "Sandaran sedang berjalan",
    "Unknown when the last backup was made":
      "Tidak diketahui bila sandaran terakhir dibuat",
    "There is no completed backup at all":
      "Langsung tiada sandaran yang selesai",
    "No completed backup for %@":
      "Tiada sandaran selesai selama %@",
    "Ready":
      "Sedia",
    "Not saved: %@":
      "Tidak disimpan: %@",
    "Installing rclone":
      "Memasang rclone",
    "Installing launchd agents":
      "Memasang ejen launchd",
    "Starting backup":
      "Memulakan sandaran",
    "Backup started.":
      "Sandaran dimulakan.",
    "Could not start the backup.":
      "Tidak dapat memulakan sandaran.",
    "Stopping backup":
      "Menghentikan sandaran",
    "Backup stopped.":
      "Sandaran dihentikan.",
    "Could not stop the backup.":
      "Tidak dapat menghentikan sandaran.",
    "Could not prepare the AppleScript.":
      "Tidak dapat menyediakan AppleScript.",
    "Unknown authorization error.":
      "Ralat kebenaran yang tidak diketahui.",
    "Waiting to upload":
      "Menunggu untuk dimuat naik",
    "%@ files":
      "%@ fail",
    "nothing":
      "tiada",
    "Back up now":
      "Sandar sekarang",
    "Stop backup":
      "Henti sandaran",
    "Open CloudMachine":
      "Buka CloudMachine",
    "Quit":
      "Keluar",
    "Healthy":
      "Sihat",
    "Attention":
      "Perhatian",
    "Refreshed %@":
      "Disegarkan %@",
    "System Status":
      "Status Sistem",
    "Action needed":
      "Tindakan diperlukan",
    "not measured":
      "belum diukur",
    "rclone did not answer":
      "rclone tidak menjawab",
    "Backup in Progress":
      "Sandaran Sedang Berjalan",
    "Files processed":
      "Fail diproses",
    "Write speed":
      "Kelajuan tulis",
    "Operation phase":
      "Fasa operasi",
    "Required Setup Steps":
      "Langkah Persediaan Wajib",
    "Copy":
      "Salin",
    "Last completed backup":
      "Sandaran selesai terakhir",
    "Last backup watchdog run":
      "Larian terakhir pengawas sandaran",
    "not read":
      "tidak dibaca",
    "Everything uploaded":
      "Semuanya dimuat naik",
    "File upload errors":
      "Ralat muat naik fail",
    "Google Drive Credentials (OAuth 2.0)":
      "Bukti Kelayakan Google Drive (OAuth 2.0)",
    "Keychain OK":
      "Rantai Kunci OK",
    "No custom keys":
      "Tiada kunci tersuai",
    "Paste client_id...":
      "Tampal client_id...",
    "Paste client_secret...":
      "Tampal client_secret...",
    "Save securely in the Keychain":
      "Simpan dengan selamat dalam Rantai Kunci",
    "Refresh":
      "Segarkan",
    "Overview":
      "Gambaran Keseluruhan",
    "Backups":
      "Sandaran",
    "Storage":
      "Storan",
    "Settings":
      "Tetapan",
    "Current status: %@":
      "Status semasa: %@",
    "Does not point to CloudMachine":
      "Tidak menuju ke CloudMachine",
    "tmutil did not answer":
      "tmutil tidak menjawab",
    "Backing up: %@ of %@":
      "Menyandar: %@ daripada %@",
    "%@ of %@":
      "%@ daripada %@",
    "Copied":
      "Disalin",
    "No backup is running":
      "Tiada sandaran sedang berjalan",
    "Time Machine starts the next one on its own schedule.":
      "Time Machine memulakan yang seterusnya mengikut jadualnya sendiri.",
    "Backup cycle":
      "Kitaran sandaran",
    "%@ GiB":
      "%@ GiB",
    "%@ GiB in %@ bands, %@ uploading":
      "%@ GiB dalam %@ jalur, %@ sedang dimuat naik",
    "%@ bands":
      "%@ jalur",
    "%@ fragments abandoned - only in the machine":
      "%@ serpihan ditinggalkan - hanya ada dalam mesin",
    "127.0.0.1:5572 answers on the Mac: Lima forwards the machine's rclone remote control, which has no password. Any web page open in a browser can send it commands - including deleting the backup on Google Drive. Add the portForwards rule from vm/cmsmb.yaml to the machine and restart it (see vm/README.md).":
      "127.0.0.1:5572 menjawab pada Mac: Lima memajukan kawalan jauh rclone mesin, yang tidak mempunyai kata laluan. Mana-mana laman web yang terbuka dalam pelayar boleh menghantar arahan kepadanya - termasuk memadam sandaran di Google Drive. Tambahkan peraturan portForwards daripada vm/cmsmb.yaml pada mesin dan mulakan semula (lihat vm/README.md).",
    "A service in the CloudMachine machine is not running":
      "Satu perkhidmatan dalam mesin CloudMachine tidak berjalan",
    "Address":
      "Alamat",
    "Agent installation INCOMPLETE - %@ of %@ did not go in:\n%@\n%@\nEvery missing agent is a function that has silently stopped working (vm-guard watches the machine's buffer, backup-health reports failures). Fix the cause and repeat the installation.":
      "Pemasangan ejen TIDAK LENGKAP - %@ daripada %@ tidak berjaya dipasang:\n%@\n%@\nSetiap ejen yang tiada ialah fungsi yang telah berhenti berfungsi secara senyap (vm-guard memantau penimbal mesin, backup-health melaporkan kegagalan). Betulkan puncanya dan ulang pemasangan.",
    "All running":
      "Semua berjalan",
    "Also install the launchd agents (same as install-launchd).":
      "Pasang juga ejen launchd (sama seperti install-launchd).",
    "At most this many minutes of waiting for the upload.":
      "Paling lama sekian minit menunggu muat naik.",
    "At the limit every new band fails with EMFILE and the backup stops. Check: cloudmachine-agent vm-status":
      "Pada had itu setiap jalur baharu gagal dengan EMFILE dan sandaran berhenti. Semak: cloudmachine-agent vm-status",
    "Cache on the machine's disk":
      "Cache pada cakera mesin",
    "Connected to Google Drive, but could not create the folder '%@' - without it the machine has nowhere to keep the backup. Check the account permissions and try again.":
      "Disambungkan ke Google Drive, tetapi tidak dapat mencipta folder '%@' - tanpanya mesin tiada tempat untuk menyimpan sandaran. Semak kebenaran akaun dan cuba lagi.",
    "Convert the image":
      "Tukar imej",
    "Converting the image to 32 MB bands":
      "Menukar imej kepada jalur 32 MB",
    "Could not check with the current connection whether the backup is on Google Drive (%@), so remote '%@' was NOT replaced: without that answer the new sign-in cannot be checked against it.":
      "Dengan sambungan semasa, tidak dapat disemak sama ada sandaran berada di Google Drive (%@), jadi remote '%@' TIDAK diganti: tanpa jawapan itu log masuk baharu tidak dapat disemak terhadapnya.",
    "Downloads the official rclone binary into ~/.cloudmachine/bin (Google sign-in and the machine's rclone.conf).":
      "Memuat turun binari rclone rasmi ke ~/.cloudmachine/bin (log masuk Google dan rclone.conf mesin).",
    "Free in the machine":
      "Ruang bebas dalam mesin",
    "Free in the machine: %@":
      "Ruang bebas dalam mesin: %@",
    "Generates and installs the launchd agents (app, backup watchdog, machine start, machine guard).":
      "Menjana dan memasang ejen launchd (app, pengawas sandaran, permulaan mesin, pengawal mesin).",
    "Install Lima, which runs the CloudMachine machine: run this in Terminal":
      "Pasang Lima, yang menjalankan mesin CloudMachine: jalankan ini dalam Terminal",
    "Install rclone (signs in to Google Drive for the machine)":
      "Pasang rclone (log masuk ke Google Drive untuk mesin)",
    "Install the background agents (machine start, buffer guard, backup watchdog)":
      "Pasang ejen latar belakang (permulaan mesin, pengawal penimbal, pengawas sandaran)",
    "Installs rclone through Homebrew - CloudMachine itself uses the one from install-rclone.":
      "Memasang rclone melalui Homebrew - CloudMachine sendiri menggunakan yang daripada install-rclone.",
    "Info.plist, token and mapped/ of the backup image exist only on the machine's disk; without them the bands in %@ cannot be restored. The copy (tm-meta-sync, every 15 min) goes to %@. Check: cloudmachine-agent vm-status, then in the machine: journalctl -u tm-meta-sync":
      "Info.plist, token dan mapped/ bagi imej sandaran hanya wujud pada cakera mesin; tanpanya jalur dalam %@ tidak dapat dipulihkan. Salinan (tm-meta-sync, setiap 15 minit) dihantar ke %@. Semak: cloudmachine-agent vm-status, kemudian dalam mesin: journalctl -u tm-meta-sync",
    "Lima says the machine is running, but a command in it did not return. Without it nothing is known about Samba, rclone or the upload. Check: cloudmachine-agent vm-status":
      "Lima mengatakan mesin sedang berjalan, tetapi satu arahan di dalamnya tidak kembali. Tanpanya tiada apa yang diketahui tentang Samba, rclone atau muat naik. Semak: cloudmachine-agent vm-status",
    "Machine":
      "Mesin",
    "Machine %@":
      "Mesin %@",
    "Machine & Upload Status":
      "Status Mesin & Muat Naik",
    "Machine buffer":
      "Penimbal mesin",
    "No Time Machine destination is the machine's share (smb://tm@<address>/CloudMachine) - backups are not being made there. The command is printed by: cloudmachine-agent vm-setup":
      "Tiada destinasi Time Machine ialah kongsi mesin (smb://tm@<address>/CloudMachine) - sandaran tidak dibuat di sana. Arahannya dicetak oleh: cloudmachine-agent vm-setup",
    "Not running: %@":
      "Tidak berjalan: %@",
    "Not set up":
      "Belum disediakan",
    "Once it runs out, rclone stops uploading, the machine's buffer fills up and backups stop being made. At a growth of ~600 MB per hourly cycle that is about %@ days.":
      "Apabila habis, rclone berhenti memuat naik, penimbal mesin penuh dan sandaran tidak lagi dibuat. Pada pertumbuhan ~600 MB setiap kitaran sejam, itu kira-kira %@ hari.",
    "Or rclone.conf is missing: this Mac has already set up the CloudMachine machine, so it is not connected anew blindly. Restore the file from a backup (the machine keeps its own copy in %@). To connect anyway, create an empty file at the path `%@ config file` prints and run again - the existing folder is kept.":
      "Atau rclone.conf tiada: Mac ini sudah menyediakan mesin CloudMachine, jadi ia tidak disambungkan semula secara membuta tuli. Pulihkan fail daripada sandaran (mesin menyimpan salinannya sendiri dalam %@). Untuk menyambung juga, cipta fail kosong pada laluan yang dicetak oleh `%@ config file` dan jalankan semula - folder sedia ada dikekalkan.",
    "Point Time Machine at the machine: run this in Terminal (needs sudo; Copy includes the password)":
      "Halakan Time Machine ke mesin: jalankan ini dalam Terminal (memerlukan sudo; Salin termasuk kata laluan)",
    "Points to the machine":
      "Menuju ke mesin",
    "Prepares for a restart: stops the backup, waits a while for the upload, then stops the machine cleanly.":
      "Bersedia untuk mulakan semula: menghentikan sandaran, menunggu seketika untuk muat naik, kemudian menghentikan mesin dengan bersih.",
    "Reading the Time Machine destination did not return within %@ s. That is how tmutil behaves when its destination hangs.":
      "Pembacaan destinasi Time Machine tidak kembali dalam %@ s. Begitulah tmutil bertindak apabila destinasinya tergantung.",
    "Remote '%@' was NOT replaced. The new sign-in gets the 'drive.file' scope, which sees only files created under its own client_id. The existing backup was most likely created by the current connection and would become invisible to it. Before anything is written, the new token is checked against the existing backup, and the replacement is abandoned if it cannot see it. The machine keeps its own copy of the configuration until vm-setup --replace-rclone-config. To go ahead, run again with --replace-existing --accept-scope-change.":
      "Remote '%@' TIDAK diganti. Log masuk baharu mendapat skop 'drive.file', yang hanya melihat fail yang dicipta di bawah client_id-nya sendiri. Sandaran sedia ada kemungkinan besar dicipta oleh sambungan semasa dan akan menjadi tidak kelihatan kepadanya. Sebelum apa-apa ditulis, token baharu disemak terhadap sandaran sedia ada, dan penggantian dibatalkan jika ia tidak dapat melihatnya. Mesin menyimpan salinan konfigurasinya sendiri sehingga vm-setup --replace-rclone-config. Untuk meneruskan, jalankan semula dengan --replace-existing --accept-scope-change.",
    "Remote control:   OPEN on the Mac at 127.0.0.1:5572 - any web page can send rclone commands; see vm/README.md (portForwards)":
      "Kawalan jauh:     TERBUKA pada Mac di 127.0.0.1:5572 - mana-mana laman web boleh menghantar arahan rclone; lihat vm/README.md (portForwards)",
    "Running":
      "Berjalan",
    "Samba, rclone or punchfs in the machine is not active, so Time Machine has nowhere to write or the bands do not reach Google Drive. Check: cloudmachine-agent vm-status":
      "Samba, rclone atau punchfs dalam mesin tidak aktif, jadi Time Machine tiada tempat untuk menulis atau jalur tidak sampai ke Google Drive. Semak: cloudmachine-agent vm-status",
    "Service %@":
      "Perkhidmatan %@",
    "Services":
      "Perkhidmatan",
    "Set up the CloudMachine machine (the first time it downloads Ubuntu - several minutes)":
      "Sediakan mesin CloudMachine (kali pertama ia memuat turun Ubuntu - beberapa minit)",
    "Set up the CloudMachine machine again, so it prints the Time Machine command":
      "Sediakan mesin CloudMachine sekali lagi supaya ia mencetak arahan Time Machine",
    "Set up the machine":
      "Sediakan mesin",
    "Setting up the CloudMachine machine":
      "Menyediakan mesin CloudMachine",
    "Start the CloudMachine machine":
      "Mulakan mesin CloudMachine",
    "Start the machine":
      "Mulakan mesin",
    "Starting the CloudMachine machine":
      "Memulakan mesin CloudMachine",
    "Still to upload: %@ GiB":
      "Masih perlu dimuat naik: %@ GiB",
    "Stopping the Time Machine backup...":
      "Menghentikan sandaran Time Machine...",
    "Stopping the machine %@...":
      "Menghentikan mesin %@...",
    "The CloudMachine machine does not answer":
      "Mesin CloudMachine tidak menjawab",
    "The CloudMachine machine is not running":
      "Mesin CloudMachine tidak berjalan",
    "The CloudMachine machine is not set up yet":
      "Mesin CloudMachine belum disediakan",
    "The CloudMachine machine is stopped":
      "Mesin CloudMachine dihentikan",
    "The backup is stopped, the upload gets up to 30 minutes, then the machine shuts down cleanly. It starts again at the next login.":
      "Sandaran dihentikan, muat naik diberi masa sehingga 30 minit, kemudian mesin ditutup dengan bersih. Ia bermula semula pada log masuk berikutnya.",
    "The machine %@ is not running - nothing to prepare.":
      "Mesin %@ tidak berjalan - tiada apa untuk disediakan.",
    "The machine is stopped and everything reached Google Drive. The Mac can be restarted; the machine starts again at login.":
      "Mesin dihentikan dan semuanya telah sampai ke Google Drive. Mac boleh dimulakan semula; mesin bermula semula semasa log masuk.",
    "The machine is stopped. %@ GiB had not reached Google Drive yet - it is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "Mesin dihentikan. %@ GiB belum sampai ke Google Drive - ia disimpan dalam penimbal mesin dan dimuat naik selepas permulaan berikutnya. Mac boleh dimulakan semula.",
    "The machine is stopped. rclone did not say how much was still to upload; what was not uploaded is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "Mesin dihentikan. rclone tidak memberitahu berapa banyak lagi yang perlu dimuat naik; apa yang belum dimuat naik disimpan dalam penimbal mesin dan dimuat naik selepas permulaan berikutnya. Mac boleh dimulakan semula.",
    "The machine's disk is a file on this disk and grows as the upload buffer fills. With no space left the machine cannot write the buffer, and Time Machine's local snapshots have nowhere to go either.":
      "Cakera mesin ialah fail pada cakera ini dan membesar apabila penimbal muat naik terisi. Tanpa ruang tersisa, mesin tidak dapat menulis penimbal, dan syot kilat setempat Time Machine juga tiada tempat untuk disimpan.",
    "The image's metadata has never been copied to Drive":
      "Metadata imej tidak pernah disalin ke Drive",
    "The image's metadata was last copied to Drive %@ ago":
      "Metadata imej disalin ke Drive kali terakhir %@ lalu",
    "The machine's disk is running out of space (%@ GB)":
      "Cakera mesin hampir kehabisan ruang (%@ GB)",
    "The new sign-in does NOT see the existing backup (%@), so remote '%@' was NOT replaced and rclone.conf is unchanged. Keep the current connection, or sign in with the credential (client_id) that created the backup.":
      "Log masuk baharu TIDAK melihat sandaran sedia ada (%@), jadi remote '%@' TIDAK diganti dan rclone.conf tidak berubah. Kekalkan sambungan semasa, atau log masuk dengan bukti kelayakan (client_id) yang mencipta sandaran.",
    "The upload buffer lives on this disk. The guard pauses Time Machine before it fills; if the upload does not catch up, backups stay paused.":
      "Penimbal muat naik berada pada cakera ini. Pengawal menjeda Time Machine sebelum ia penuh; jika muat naik tidak mengejar, sandaran kekal dijeda.",
    "These bands exist only in the machine's buffer. The backup on Google Drive is INCOMPLETE and may not open.":
      "Jalur ini hanya wujud dalam penimbal mesin. Sandaran di Google Drive TIDAK LENGKAP dan mungkin tidak dapat dibuka.",
    "Time Machine backs up to the machine, so without it no backup is made. Start it: limactl start %@ (or the Start button in the app).":
      "Time Machine membuat sandaran ke mesin, jadi tanpanya tiada sandaran dibuat. Mulakannya: limactl start %@ (atau butang Mulakan dalam app).",
    "Time Machine did not stop its backup within 2 minutes (or tmutil did not answer) - the machine was NOT stopped. Try again in a moment.":
      "Time Machine tidak menghentikan sandarannya dalam 2 minit (atau tmutil tidak menjawab) - mesin TIDAK dihentikan. Cuba lagi sebentar lagi.",
    "Time Machine has created its image: stop the backup, then convert the image to 32 MB bands":
      "Time Machine telah mencipta imejnya: hentikan sandaran, kemudian tukar imej kepada jalur 32 MB",
    "To upload":
      "Untuk dimuat naik",
    "Unknown whether the CloudMachine machine is running":
      "Tidak diketahui sama ada mesin CloudMachine sedang berjalan",
    "Waiting for the upload to Google Drive (at most %@ min)...":
      "Menunggu muat naik ke Google Drive (paling lama %@ min)...",
    "With --replace-existing: confirms that the new sign-in (scope 'drive.file') may not see the existing backup. The new token is still checked against the backup first.":
      "Dengan --replace-existing: mengesahkan bahawa log masuk baharu (skop 'drive.file') mungkin tidak melihat sandaran sedia ada. Token baharu tetap disemak terhadap sandaran dahulu.",
    "Without it there is no way to check whether anything reached the Drive - the machine's guard is blind then.":
      "Tanpanya tiada cara untuk menyemak sama ada apa-apa sampai ke Drive - pengawal mesin menjadi buta.",
    "limactl did not answer":
      "limactl tidak menjawab",
    "limactl did not answer (or is not installed). That does not mean the machine is down - it means nobody has checked.":
      "limactl tidak menjawab (atau tidak dipasang). Itu tidak bermakna mesin mati - ia bermakna tiada sesiapa yang menyemak.",
    "limactl start failed: %@":
      "limactl start gagal: %@",
    "limactl stop failed: %@":
      "limactl stop gagal: %@",
    "punchfs is close to its open-file limit":
      "punchfs hampir mencapai had fail terbukanya",
    "punchfs open files":
      "Fail terbuka punchfs",
    "rclone's remote control is open on this Mac":
      "Kawalan jauh rclone terbuka pada Mac ini",
    "statfs('/System/Volumes/Data') returned an error, so nobody knows whether the machine's disk can still grow on this Mac.":
      "statfs('/System/Volumes/Data') mengembalikan ralat, jadi tiada sesiapa tahu sama ada cakera mesin masih boleh membesar pada Mac ini.",
    "Google Drive's daily upload limit stops the upload":
      "Had muat naik harian Google Drive menghentikan muat naik",
    "Google last refused an upload %@ ago (750 GB a day). Backups since then are only in the machine's buffer on this Mac. rclone retries every 5 min and resumes by itself when the limit passes; the guard pauses Time Machine if more than %@ GiB waits.":
      "Google kali terakhir menolak muat naik %@ lalu (750 GB sehari). Sandaran sejak itu hanya ada dalam penimbal mesin pada Mac ini. rclone mencuba semula setiap 5 min dan menyambung sendiri apabila had berlalu; pengawal menjeda Time Machine jika lebih daripada %@ GiB menunggu.",
    "Usage on Google Drive is not being measured":
      "Penggunaan di Google Drive tidak diukur",
    "The last measurement (%@ GB) is from %@, %@ ago - rclone size has not answered since. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "Ukuran terakhir (%@ GB) ialah dari %@, %@ lalu - rclone size tidak menjawab sejak itu. Selagi ia tidak menjawab, tiada apa yang memantau had %@ GB: penggera 90%% dan 100%% kekal senyap. Semak vm-status, atau tekan Ukur sekarang dalam tetingkap.",
    "rclone size has not answered even once. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "rclone size tidak menjawab walau sekali. Selagi ia tidak menjawab, tiada apa yang memantau had %@ GB: penggera 90%% dan 100%% kekal senyap. Semak vm-status, atau tekan Ukur sekarang dalam tetingkap.",
    "Saved in the Keychain. Connecting Google Drive (configure-remote) will use them.":
      "Disimpan dalam Rantai Kunci. Menyambung Google Drive (configure-remote) akan menggunakannya.",
    "Saved in the Keychain. The existing Google Drive connection keeps its old client_id, and on this Mac it should stay that way: a connection made with the new keys (the 'drive.file' scope) cannot see the backup created by the old one. Do not replace the connection here; the new keys are for a Mac that is not connected yet.":
      "Disimpan dalam Rantai Kunci. Sambungan Google Drive sedia ada mengekalkan client_id lamanya, dan pada Mac ini ia sepatutnya kekal begitu: sambungan yang dibuat dengan kunci baharu (skop 'drive.file') tidak dapat melihat sandaran yang dicipta oleh yang lama. Jangan ganti sambungan di sini; kunci baharu adalah untuk Mac yang belum disambungkan.",
    "it is not there for the new token":
      "ia tiada untuk token baharu",
    "Cancel":
      "Batal",
    "ACTION NEEDED":
      "TINDAKAN DIPERLUKAN",
    "WILL PASS BY ITSELF — DO NOTHING":
      "AKAN SELESAI SENDIRI - JANGAN BUAT APA-APA",
    "UNKNOWN — CHECK AGAIN SHORTLY":
      "TIDAK DIKETAHUI - SEMAK SEMULA SEBENTAR LAGI",
    "ALL GOOD":
      "SEMUA BAIK",
    "Upload is not working":
      "Muat naik tidak berfungsi",
    "Upload stopped — no space left on Google Drive":
      "Muat naik dihentikan - tiada ruang tersisa di Google Drive",
    "%@ backup fragments not uploaded":
      "%@ serpihan sandaran belum dimuat naik",
    "Upload cannot keep up with writes":
      "Muat naik tidak dapat mengejar penulisan",
    "Upload paused — Google daily limit":
      "Muat naik dijeda - had harian Google",
    "Uploading to Google Drive — %@ queued":
      "Memuat naik ke Google Drive - %@ dalam baris gilir",
    "Everything uploaded to Google Drive":
      "Semuanya dimuat naik ke Google Drive",
    "Unknown what is waiting in the queue":
      "Tidak diketahui apa yang menunggu dalam baris gilir",
    "There is no connection to Google Drive, so backups are only made on this Mac. If this does not pass by itself within a few minutes, check the network and the connection to Drive.":
      "Tiada sambungan ke Google Drive, jadi sandaran hanya dibuat pada Mac ini. Jika ini tidak selesai sendiri dalam beberapa minit, semak rangkaian dan sambungan ke Drive.",
    "There is no space left on Google Drive. This will NOT pass by itself — you need to free up space on Drive. Until then Time Machine is paused, so that it does not fill up this Mac's disk.":
      "Tiada ruang tersisa di Google Drive. Ini TIDAK akan selesai sendiri - anda perlu mengosongkan ruang di Drive. Sehingga itu Time Machine dijeda supaya cakera Mac ini tidak penuh.",
    "%@ backup fragments could not be uploaded and rclone stopped trying. These fragments exist only on this Mac, so the backup on Drive is incomplete. This needs checking.":
      "%@ serpihan sandaran tidak dapat dimuat naik dan rclone berhenti mencuba. Serpihan ini hanya wujud pada Mac ini, jadi sandaran di Drive tidak lengkap. Ini perlu disemak.",
    "Time Machine is writing faster than the upload goes, and the buffer has filled up. The backup will be paused until the upload catches up — this is a safeguard against filling up the disk, not a failure.":
      "Time Machine menulis lebih laju daripada muat naik, dan penimbal telah penuh. Sandaran akan dijeda sehingga muat naik mengejar - ini ialah perlindungan terhadap cakera penuh, bukan kegagalan.",
    "Google accepts 750 GB per day and that limit has been used up. There is nothing to do: the limit renews by itself, usually within a few hours. Time Machine backups are made normally in the meantime and wait in the buffer — they will be uploaded as soon as Google starts accepting again.":
      "Google menerima 750 GB sehari dan had itu telah habis digunakan. Tiada apa yang perlu dilakukan: had diperbaharui sendiri, biasanya dalam beberapa jam. Sandaran Time Machine dibuat seperti biasa sementara itu dan menunggu dalam penimbal - ia akan dimuat naik sebaik sahaja Google menerima semula.",
    "%@ backup fragments are queued and on their way to Drive.":
      "%@ serpihan sandaran berada dalam baris gilir dan dalam perjalanan ke Drive.",
    "Nothing is waiting in the queue — the backup on Google Drive is complete.":
      "Tiada apa yang menunggu dalam baris gilir - sandaran di Google Drive lengkap.",
    "rclone did not answer the question about the queue, so it is unknown how many backups are still waiting to be uploaded. This does not mean something broke — under load the answer can be late. It only means that right now nobody knows. If it persists, the backup cycle check will report it.":
      "rclone tidak menjawab soalan tentang baris gilir, jadi tidak diketahui berapa banyak sandaran yang masih menunggu untuk dimuat naik. Ini tidak bermakna ada yang rosak - ketika beban tinggi jawapan boleh lewat. Ia hanya bermakna buat masa ini tiada sesiapa tahu. Jika berterusan, semakan kitaran sandaran akan melaporkannya.",
    "unknown error":
      "ralat tidak diketahui",
    "rclone lsf ended with an error":
      "rclone lsf tamat dengan ralat",
    "This Mac is close to its space limit on Google Drive":
      "Mac ini hampir mencapai had ruangnya di Google Drive",
    "%@ GB of %@ GB used. Time Machine deletes the oldest backups to stay within its quota; check that the quota is set (vm-status).":
      "%@ GB daripada %@ GB digunakan. Time Machine memadam sandaran paling lama untuk kekal dalam kuotanya; semak bahawa kuota telah ditetapkan (vm-status).",
    "This Mac is over its space limit on Google Drive":
      "Mac ini melebihi had ruangnya di Google Drive",
    "%@ GB of %@ GB used. Set the Time Machine quota (command in the app window or vm-status), or raise the limit.":
      "%@ GB daripada %@ GB digunakan. Tetapkan kuota Time Machine (arahan dalam tetingkap app atau vm-status), atau naikkan had.",
    "not set":
      "belum ditetapkan",
    "%@ GB - usage not measured yet":
      "%@ GB - penggunaan belum diukur",
    "%@ of %@ GB used (%@%%)":
      "%@ daripada %@ GB digunakan (%@%%)",
    "The limit must be a whole number of GB above zero.":
      "Had mestilah nombor bulat GB yang lebih daripada sifar.",
    "machines.json cannot be read, so it was not overwritten. Fix or remove it first.":
      "machines.json tidak dapat dibaca, jadi ia tidak ditulis ganti. Betulkan atau alihkannya dahulu.",
    "'%@' is not a valid folder name: use lowercase letters, digits and dashes.":
      "'%@' bukan nama folder yang sah: gunakan huruf kecil, digit dan tanda sempang.",
    "This Mac already backs up to folder '%@'. Switching to '%@' would start a new, empty backup and orphan the existing one, so nothing was changed.":
      "Mac ini sudah membuat sandaran ke folder '%@'. Menukar kepada '%@' akan memulakan sandaran baharu yang kosong dan meninggalkan yang sedia ada tanpa pemilik, jadi tiada apa yang diubah.",
    "This Mac already has a CloudMachine installation, whose backup is in folder '%@'. Switching to '%@' would orphan it, so nothing was changed.":
      "Mac ini sudah mempunyai pemasangan CloudMachine, yang sandarannya berada dalam folder '%@'. Menukar kepada '%@' akan meninggalkannya tanpa pemilik, jadi tiada apa yang diubah.",
    "Could not save the folder name to %@: %@":
      "Tidak dapat menyimpan nama folder ke %@: %@",
    "Homebrew is not installed. Install it manually: https://brew.sh":
      "Homebrew tidak dipasang. Pasang secara manual: https://brew.sh",
    "Installing rclone failed: %@":
      "Pemasangan rclone gagal: %@",
    "Installed rclone.":
      "rclone dipasang.",
    "Own Google credentials: set.":
      "Bukti kelayakan Google sendiri: ditetapkan.",
    "INCOMPLETE: %@ is missing - rclone will use rclone's shared client_id anyway.":
      "TIDAK LENGKAP: %@ tiada - rclone tetap akan menggunakan client_id kongsi rclone.",
    "No own credentials - rclone uses the shared client_id, rate-limited jointly and being retired in 2026.":
      "Tiada bukti kelayakan sendiri - rclone menggunakan client_id kongsi, yang dihadkan kadarnya secara bersama dan akan dihentikan pada 2026.",
    "Empty value - not saving.":
      "Nilai kosong - tidak disimpan.",
    "Keychain refused: %@":
      "Rantai Kunci menolak: %@",
    "DIRTY-TREE":
      "POKOK-KOTOR",
    "Cannot create the working directory: %@":
      "Tidak dapat mencipta direktori kerja: %@",
    "Could not read the rclone version number.":
      "Tidak dapat membaca nombor versi rclone.",
    "Could not download %@.":
      "Tidak dapat memuat turun %@.",
    "No entry for %@ in SHA256SUMS.":
      "Tiada entri untuk %@ dalam SHA256SUMS.",
    "Could not compute the checksum.":
      "Tidak dapat mengira checksum.",
    "SHA256 checksum does not match - NOT installing.\n  expected: %@\n  computed: %@":
      "Checksum SHA256 tidak sepadan - TIDAK dipasang.\n  dijangka: %@\n  dikira:   %@",
    "Could not unpack the archive.":
      "Tidak dapat menyahpek arkib.",
    "Could not install the binary: %@":
      "Tidak dapat memasang binari: %@",
    "Installed rclone %@ in %@ (SHA256 checksum matches).":
      "rclone %@ dipasang dalam %@ (checksum SHA256 sepadan).",
    "%@ did not respond within the allotted time (the process was left orphaned in the background).":
      "%@ tidak bertindak balas dalam masa yang diperuntukkan (proses ditinggalkan tanpa pengawasan di latar belakang).",
    "Cannot launch %@: %@":
      "Tidak dapat melancarkan %@: %@",
    "Remote '%@' already exists and was NOT touched.\nOverwriting it replaces the token and the permission scope; a credential with the 'drive.file' scope does not see files created by the previous one, so the existing backup becomes unreachable.\nIf you really want to replace it, first back up ~/.config/rclone/rclone.conf and run again with --replace-existing.":
      "Remote '%@' sudah wujud dan TIDAK disentuh.\nPenulisan ganti akan menggantikan token dan skop kebenaran; bukti kelayakan dengan skop 'drive.file' tidak melihat fail yang dicipta oleh yang terdahulu, jadi sandaran sedia ada menjadi tidak dapat dicapai.\nJika anda benar-benar mahu menggantinya, sandarkan ~/.config/rclone/rclone.conf dahulu dan jalankan semula dengan --replace-existing.",
    "Could not check whether remote '%@' already exists (rclone listremotes did not answer or failed), so nothing was changed. Run `%@ listremotes` to see the error, then try again.":
      "Tidak dapat menyemak sama ada remote '%@' sudah wujud (rclone listremotes tidak menjawab atau gagal), jadi tiada apa yang diubah. Jalankan `%@ listremotes` untuk melihat ralat, kemudian cuba lagi.",
    "Could not check whether this Mac already has a CloudMachine installation (rclone did not answer), so no folder was chosen. Try again in a moment.":
      "Tidak dapat menyemak sama ada Mac ini sudah mempunyai pemasangan CloudMachine (rclone tidak menjawab), jadi tiada folder dipilih. Cuba lagi sebentar lagi.",
    "rclone authorize failed (%@). If that binary is missing, start with: cloudmachine-agent install-rclone.":
      "rclone authorize gagal (%@). Jika binari itu tiada, mulakan dengan: cloudmachine-agent install-rclone.",
    "Could not read the token from the output of rclone authorize.":
      "Tidak dapat membaca token daripada output rclone authorize.",
    "rclone config create failed.":
      "rclone config create gagal.",
    "Connected to Google Drive as remote '%@', folder %@.":
      "Disambungkan ke Google Drive sebagai remote '%@', folder %@.",
    "tmutil is not responding - unknown where the backup goes":
      "tmutil tidak bertindak balas - tidak diketahui ke mana sandaran pergi",
    "No successful backup for %@":
      "Tiada sandaran berjaya selama %@",
    "Last COMPLETED backup: %@. The cycle is hourly, so that is %@ missed runs.":
      "Sandaran SELESAI terakhir: %@. Kitaran ialah setiap jam, jadi itu bermakna %@ larian terlepas.",
    "There is NOT A SINGLE successful backup":
      "TIADA LANGSUNG sandaran yang berjaya",
    "The Time Machine preferences contain no date of a completed backup for this destination.":
      "Pilihan Time Machine tidak mengandungi tarikh sandaran selesai untuk destinasi ini.",
    "The last backup attempt did not end in a backup":
      "Percubaan sandaran terakhir tidak berakhir dengan sandaran",
    "The attempt at %@ is newer than the last successful backup at %@.":
      "Percubaan pada %@ lebih baharu daripada sandaran berjaya terakhir pada %@.",
    "Time Machine reports an error in the last run (RESULT=%@)":
      "Time Machine melaporkan ralat dalam larian terakhir (RESULT=%@)",
    "A non-zero RESULT in the Time Machine preferences means the run did not succeed.":
      "RESULT bukan sifar dalam pilihan Time Machine bermakna larian tidak berjaya.",
    "rclone failed to upload %@ files":
      "rclone gagal memuat naik %@ fail",
    "Buffer full of nothing but unsent data":
      "Penimbal penuh dengan data yang belum dihantar sahaja",
    "rclone has nothing left to evict from the buffer - the upload cannot keep up or has stalled.":
      "rclone tiada lagi apa-apa untuk dikeluarkan daripada penimbal - muat naik tidak dapat mengejar atau telah tersekat.",
    "The rclone control interface is not responding":
      "Antara muka kawalan rclone tidak menjawab",
    "Google Drive is running out of space (%@ GB)":
      "Google Drive hampir kehabisan ruang (%@ GB)",
    "The Mac's disk is running out of space (%@ GB)":
      "Cakera Mac hampir kehabisan ruang (%@ GB)",
    "Cannot read the Time Machine preferences":
      "Tidak dapat membaca pilihan Time Machine",
    "%@ is unreadable - most often Full Disk Access is missing. Without this file it is UNKNOWN when the last backup was made, so we treat it as a failure, not as the absence of a problem.":
      "%@ tidak dapat dibaca - selalunya kerana Capaian Cakera Penuh tiada. Tanpa fail ini TIDAK DIKETAHUI bila sandaran terakhir dibuat, jadi kami menganggapnya kegagalan, bukan ketiadaan masalah.",
    "Cannot measure free space on the Mac's disk":
      "Tidak dapat mengukur ruang bebas pada cakera Mac",
    "%@ days":
      "%@ hari",
    "CloudMachine: backup is not working":
      "CloudMachine: sandaran tidak berfungsi",
    "unknown reason":
      "sebab tidak diketahui",
    "osascript did not show the notification (permissions or no graphical session)":
      "osascript tidak memaparkan pemberitahuan (kebenaran atau tiada sesi grafik)",
    "UNDELIVERED ALARM: %@":
      "PENGGERA TIDAK DIHANTAR: %@",
    "from %@, reason: %@":
      "daripada %@, sebab: %@",
    "The system notification was not delivered - you will see this alarm ONLY here.":
      "Pemberitahuan sistem tidak dihantar - anda akan melihat penggera ini HANYA di sini.",
    "%@ (%@ ago)":
      "%@ (%@ lalu)",
    "%@ - marker from the FUTURE":
      "%@ - penanda dari MASA DEPAN",
    "%@ (%@ ago) - THE WATCHDOG MAY NOT BE RUNNING":
      "%@ (%@ lalu) - PENGAWAS MUNGKIN TIDAK BERJALAN",
    "NEVER - the watchdog has not recorded a single run":
      "TIDAK PERNAH - pengawas belum merekodkan walau satu larian",
    "Could not find the launchd/ directory with templates.":
      "Tidak dapat mencari direktori launchd/ yang mengandungi templat.",
    "Could not find the compiled cloudmachine-agent binary.":
      "Tidak dapat mencari binari cloudmachine-agent yang telah dikompil.",
    "ABORTED: could not put cloudmachine-agent in a stable location\n(%@) - most often a lack of space or permissions.\nNOT installing agents pointing at %@: that path\ndisappears on the next `swift build` or `git clean`, and backups stop\nwithout any visible signal.":
      "DIBATALKAN: tidak dapat meletakkan cloudmachine-agent di lokasi yang stabil\n(%@) - selalunya kerana kekurangan ruang atau kebenaran.\nTIDAK memasang ejen yang menuju ke %@: laluan itu\nhilang pada `swift build` atau `git clean` berikutnya, dan sandaran berhenti\ntanpa sebarang isyarat yang kelihatan.",
    "ABORTED: %@":
      "DIBATALKAN: %@",
    "Could not list the templates in %@.":
      "Tidak dapat menyenaraikan templat dalam %@.",
    "could not read the template %@":
      "tidak dapat membaca templat %@",
    "could not write %@ (lack of space or permissions)":
      "tidak dapat menulis %@ (kekurangan ruang atau kebenaran)",
    "launchctl load refused to load %@":
      "launchctl load enggan memuatkan %@",
    "NOT A SINGLE agent was loaded.":
      "TIDAK SATU PUN ejen dimuatkan.",
    "Only these went in: %@.":
      "Hanya ini yang berjaya dipasang: %@.",
    "Could not load any launchd agent.":
      "Tidak dapat memuatkan sebarang ejen launchd.",
    "Installed agents: %@":
      "Ejen dipasang: %@",
    "                  WARNING: close to the limit - new bands will fail with EMFILE":
      "                  AMARAN: hampir had - jalur baharu akan gagal dengan EMFILE",
    "%@/bands on Google Drive is not empty - it may hold another backup. NOT overwriting it; check it by hand.":
      "%@/bands di Google Drive tidak kosong - ia mungkin mengandungi sandaran lain. TIDAK ditulis ganti; semak sendiri.",
    "Address:          %@":
      "Alamat:           %@",
    "Already prepared (%@ exists) - nothing to do.":
      "Sudah disediakan (%@ wujud) - tiada apa untuk dilakukan.",
    "Converts Time Machine's new, empty image in the machine to 32 MB bands and moves the bands to Google Drive.":
      "Menukar imej baharu Time Machine yang kosong dalam mesin kepada jalur 32 MB dan memindahkan jalur ke Google Drive.",
    "Copy rclone.conf into the machine even if it already has one.":
      "Salin rclone.conf ke dalam mesin walaupun ia sudah mempunyainya.",
    "Copying the converted image into the machine failed: %@":
      "Menyalin imej yang telah ditukar ke dalam mesin gagal: %@",
    "Copying the image to the Mac failed: %@":
      "Menyalin imej ke Mac gagal: %@",
    "Could not ask Lima about the machine: %@":
      "Tidak dapat bertanya Lima tentang mesin: %@",
    "Could not carry the Time Machine files over: %@":
      "Tidak dapat memindahkan fail Time Machine: %@",
    "Could not check the image in the machine.":
      "Tidak dapat menyemak imej dalam mesin.",
    "Could not copy the rclone configuration into the machine.":
      "Tidak dapat menyalin konfigurasi rclone ke dalam mesin.",
    "Could not create %@ on Google Drive: %@":
      "Tidak dapat mencipta %@ di Google Drive: %@",
    "Could not create %@: %@":
      "Tidak dapat mencipta %@: %@",
    "Could not find the vm/ directory with the machine template.":
      "Tidak dapat mencari direktori vm/ yang mengandungi templat mesin.",
    "Could not read the image size.":
      "Tidak dapat membaca saiz imej.",
    "Could not set the SMB password of user %@ in the machine.":
      "Tidak dapat menetapkan kata laluan SMB pengguna %@ dalam mesin.",
    "Could not stop smbd in the machine.":
      "Tidak dapat menghentikan smbd dalam mesin.",
    "Could not write %@ in the machine.":
      "Tidak dapat menulis %@ dalam mesin.",
    "Could not write the password file %@.":
      "Tidak dapat menulis fail kata laluan %@.",
    "Creates or starts the CloudMachine machine (Lima), gives it rclone's configuration and an SMB password, and prints the Time Machine command.":
      "Mencipta atau memulakan mesin CloudMachine (Lima), memberinya konfigurasi rclone dan kata laluan SMB, dan mencetak arahan Time Machine.",
    "Creating the machine %@ (first start downloads Ubuntu and installs packages - several minutes)...":
      "Mencipta mesin %@ (permulaan pertama memuat turun Ubuntu dan memasang pakej - beberapa minit)...",
    "Done: %@ has %@ MB bands on Google Drive; the original is kept in %@ in the machine. Start the backup: tmutil startbackup":
      "Selesai: %@ mempunyai jalur %@ MB di Google Drive; yang asal disimpan dalam %@ di dalam mesin. Mulakan sandaran: tmutil startbackup",
    "exit code %@, no message":
      "kod keluar %@, tiada mesej",
    "Image metadata:   NEVER copied to %@ - check tm-meta-sync in the machine":
      "Metadata imej:    TIDAK PERNAH disalin ke %@ - semak tm-meta-sync dalam mesin",
    "Image metadata:   copied %@ ago to %@":
      "Metadata imej:    disalin %@ lalu ke %@",
    "Image metadata:   last copied %@ ago - OVERDUE (%@)":
      "Metadata imej:    kali terakhir disalin %@ lalu - TERLAMBAT (%@)",
    "Image metadata:   not copied yet - waits for vm-prepare-bundle":
      "Metadata imej:    belum disalin - menunggu vm-prepare-bundle",
    "Backup %@, paused by the guard %@: %@":
      "Sandaran %@, dijeda oleh pengawal %@: %@",
    "Free in machine:  %@ GiB":
      "Bebas dalam mesin: %@ GiB",
    "fsck_apfs -n found problems: %@":
      "fsck_apfs -n menemui masalah: %@",
    "Google Drive folder: %@":
      "Folder Google Drive: %@",
    "hdiutil attach of the converted image failed: %@":
      "hdiutil attach bagi imej yang ditukar gagal: %@",
    "hdiutil convert failed: %@":
      "hdiutil convert gagal: %@",
    "Image name in the machine (default: from the computer name).":
      "Nama imej dalam mesin (lalai: daripada nama komputer).",
    "Installing the converted image FAILED: %@\nsmbd is left STOPPED so Time Machine does not open a half-installed image. The original is in %@ in the machine.":
      "Pemasangan imej yang ditukar GAGAL: %@\nsmbd dibiarkan BERHENTI supaya Time Machine tidak membuka imej yang separuh dipasang. Yang asal berada dalam %@ di dalam mesin.",
    "limactl create failed: %@":
      "limactl create gagal: %@",
    "limactl list failed: %@":
      "limactl list gagal: %@",
    "limactl not found - install Lima: brew install lima":
      "limactl tidak ditemui - pasang Lima: brew install lima",
    "limactl start failed: %@\nThe machine's own log: %@":
      "limactl start gagal: %@\nLog mesin itu sendiri: %@",
    "Machine %@ is running.":
      "Mesin %@ sedang berjalan.",
    "Machine %@ was already running.":
      "Mesin %@ sudah berjalan.",
    "Machine:          %@ (%@)":
      "Mesin:            %@ (%@)",
    "Machine:          %@":
      "Mesin:            %@",
    "Machine:          not created - run: cloudmachine-agent vm-setup":
      "Mesin:            belum dicipta - jalankan: cloudmachine-agent vm-setup",
    "no answer within the time limit":
      "tiada jawapan dalam had masa",
    "No image %@ in the machine.":
      "Tiada imej %@ dalam mesin.",
    "No image in the machine yet - point Time Machine at the share and let it create one first.":
      "Belum ada imej dalam mesin - halakan Time Machine ke kongsi dan biarkan ia mencipta satu dahulu.",
    "No rclone configuration at %@ - connect Google Drive first (configure-remote).":
      "Tiada konfigurasi rclone di %@ - sambungkan Google Drive dahulu (configure-remote).",
    "no SMB destination":
      "tiada destinasi SMB",
    "One check of the machine's upload buffer: pauses Time Machine when it fills, resumes what it paused.":
      "Satu semakan penimbal muat naik mesin: menjeda Time Machine apabila ia penuh, menyambung semula apa yang dijedanya.",
    "Packing the converted image failed: %@":
      "Membungkus imej yang ditukar gagal: %@",
    "Packing the image failed: %@":
      "Membungkus imej gagal: %@",
    "No answer from the machine (rclone rc) - the guard would do nothing.":
      "Tiada jawapan daripada mesin (rclone rc) - pengawal tidak akan melakukan apa-apa.",
    "Only print what the guard would decide - for trying thresholds on a throwaway machine.":
      "Hanya cetak keputusan pengawal - untuk mencuba ambang pada mesin sekali guna.",
    "Pause above this many GiB in the buffer.":
      "Jeda apabila penimbal melebihi sekian GiB.",
    "Pause when the machine has less free than this, in GiB.":
      "Jeda apabila mesin mempunyai ruang bebas kurang daripada ini, dalam GiB.",
    "Point Time Machine at the machine (once, needs an administrator password):":
      "Halakan Time Machine ke mesin (sekali, memerlukan kata laluan pentadbir):",
    "punchfs files:    %@ open, limit %@":
      "Fail punchfs:     %@ terbuka, had %@",
    "rclone configuration already in the machine - kept (--replace-rclone-config replaces it).":
      "Konfigurasi rclone sudah ada dalam mesin - dikekalkan (--replace-rclone-config menggantikannya).",
    "rclone configuration copied into the machine.":
      "Konfigurasi rclone disalin ke dalam mesin.",
    "rclone-tm or punchfs is not running in the machine - see cloudmachine-agent vm-status.":
      "rclone-tm atau punchfs tidak berjalan dalam mesin - lihat cloudmachine-agent vm-status.",
    "Resume below this many GiB (only a backup the guard paused).":
      "Sambung semula di bawah sekian GiB (hanya sandaran yang dijeda oleh pengawal).",
    "Service %@: %@":
      "Perkhidmatan %@: %@",
    "Several images in the machine (%@) - choose one with --bundle.":
      "Beberapa imej dalam mesin (%@) - pilih satu dengan --bundle.",
    "Shows the machine: address, services, upload buffer, free space and the Time Machine destination.":
      "Menunjukkan mesin: alamat, perkhidmatan, penimbal muat naik, ruang bebas dan destinasi Time Machine.",
    "SMB password stored in %@ (mode 600).":
      "Kata laluan SMB disimpan dalam %@ (mod 600).",
    "The converted image does not have %@-byte bands.":
      "Imej yang ditukar tidak mempunyai jalur %@ bait.",
    "The converted image has no APFS partition.":
      "Imej yang ditukar tidak mempunyai partition APFS.",
    "The image already takes %@ MB - this command converts only a new, empty image (under %@ MB).":
      "Imej sudah mengambil %@ MB - arahan ini hanya menukar imej baharu yang kosong (di bawah %@ MB).",
    "The image is encrypted - converting encrypted images is not supported.":
      "Imej disulitkan - penukaran imej yang disulitkan tidak disokong.",
    "The image was not changed; smbd started again.":
      "Imej tidak diubah; smbd dimulakan semula.",
    "The machine does not answer - is it running? cloudmachine-agent vm-status":
      "Mesin tidak menjawab - adakah ia berjalan? cloudmachine-agent vm-status",
    "The machine has no address on the vzNAT network.":
      "Mesin tidak mempunyai alamat pada rangkaian vzNAT.",
    "The services in the machine did not start - check: cloudmachine-agent vm-status":
      "Perkhidmatan dalam mesin tidak bermula - semak: cloudmachine-agent vm-status",
    "Time Machine is backing up - stop it first: tmutil stopbackup":
      "Time Machine sedang menyandar - hentikannya dahulu: tmutil stopbackup",
    "Time Machine:     %@":
      "Time Machine:     %@",
    "Time Machine:     NOT pointing at the machine (%@)":
      "Time Machine:     TIDAK menuju ke mesin (%@)",
    "Time Machine:     tmutil did not answer":
      "Time Machine:     tmutil tidak menjawab",
    "tmutil did not answer - not touching the image while its state is unknown.":
      "tmutil tidak menjawab - imej tidak disentuh selagi keadaannya tidak diketahui.",
    "unknown":
      "tidak diketahui",
    "Unpacking the image failed: %@":
      "Menyahpek imej gagal: %@",
    "Still to upload:  %@ GiB in %@ bands, uploading %@ (cache on disk %@ GiB)":
      "Masih perlu dimuat naik: %@ GiB dalam %@ jalur, %@ sedang dimuat naik (cache pada cakera %@ GiB)",
    "Excluded %@ (the machine and its upload buffer) from Time Machine.":
      "%@ (mesin dan penimbal muat naiknya) dikecualikan daripada Time Machine.",
    "WARNING: could not exclude %@ from Time Machine - run: tmutil addexclusion %@":
      "AMARAN: tidak dapat mengecualikan %@ daripada Time Machine - jalankan: tmutil addexclusion %@",
    "Upload buffer:    no answer from rclone (rc %@)":
      "Penimbal muat naik: tiada jawapan daripada rclone (rc %@)",
    "When Time Machine has created its empty image, stop the backup (tmutil stopbackup) and run: cloudmachine-agent vm-prepare-bundle":
      "Apabila Time Machine telah mencipta imej kosongnya, hentikan sandaran (tmutil stopbackup) dan jalankan: cloudmachine-agent vm-prepare-bundle",
    "Unsent %@ GiB, free %@ GiB (pause above %@ GiB unsent or below %@ GiB free, resume below %@ GiB).":
      "Belum dihantar %@ GiB, bebas %@ GiB (jeda di atas %@ GiB belum dihantar atau di bawah %@ GiB bebas, sambung semula di bawah %@ GiB).",
    "Upload:           Google's daily limit refused an upload %@ ago - rclone retries every 5 min and resumes by itself":
      "Muat naik:        had harian Google menolak muat naik %@ lalu - rclone mencuba semula setiap 5 min dan menyambung sendiri",
    "no":
      "tidak",
    "running":
      "berjalan",
    "stopped":
      "dihentikan",
    "yes":
      "ya",
    "%@\nThe previous template is in %@ - copy it back over lima.yaml and run limactl start %@.":
      "%@\nTemplat sebelumnya berada dalam %@ - salin semula ke atas lima.yaml dan jalankan limactl start %@.",
    "Could not read this app's machine template (limactl template copy).":
      "Tidak dapat membaca templat mesin app ini (limactl template copy).",
    "Could not replace %@: %@":
      "Tidak dapat menggantikan %@: %@",
    "Machine %@ already runs this app's template.":
      "Mesin %@ sudah menjalankan templat app ini.",
    "Machine %@ now runs this app's template; the previous one is in %@.":
      "Mesin %@ kini menjalankan templat app ini; yang sebelumnya berada dalam %@.",
    "Moves the machine onto this app's template (two restarts, never during a backup).":
      "Memindahkan mesin ke templat app ini (dua kali mula semula, tidak pernah semasa sandaran).",
    "No machine %@ - create it with: cloudmachine-agent vm-setup":
      "Tiada mesin %@ - cipta dengan: cloudmachine-agent vm-setup",
    "Template:         OLDER than this app's - run: cloudmachine-agent vm-update":
      "Templat:          LEBIH LAMA daripada app ini - jalankan: cloudmachine-agent vm-update",
    "Template:         not compared":
      "Templat:          tidak dibandingkan",
    "Template:         this app's":
      "Templat:          milik app ini",
    "The machine has no %@ - run cloudmachine-agent vm-setup first.":
      "Mesin tidak mempunyai %@ - jalankan cloudmachine-agent vm-setup dahulu.",
    "The machine restarted, but not every service is running - check: cloudmachine-agent vm-status. The previous template is in %@.":
      "Mesin dimulakan semula, tetapi tidak semua perkhidmatan berjalan - semak: cloudmachine-agent vm-status. Templat sebelumnya berada dalam %@.",
    "The template changes the machine itself (%@) - that needs a new machine, not an update.":
      "Templat mengubah mesin itu sendiri (%@) - itu memerlukan mesin baharu, bukan kemas kini.",
    "The upload to Google Drive hangs":
      "Muat naik ke Google Drive tergantung",
    "Time Machine is backing up - try again when it has finished.":
      "Time Machine sedang menyandar - cuba lagi apabila ia selesai.",
    "Upload:           HANGS - bands in progress, none uploaded for %@ (network?); see /var/log/rclone-tm.log in the machine":
      "Muat naik:        TERGANTUNG - jalur sedang berjalan, tiada yang dimuat naik selama %@ (rangkaian?); lihat /var/log/rclone-tm.log dalam mesin",
    "limactl stop failed - nothing was changed.":
      "limactl stop gagal - tiada apa yang diubah.",
    "rclone has bands in progress, but none has been uploaded for %@ - usually a broken network connection, which rclone does not report as an error. Backups since then are only in the machine's buffer. When the network comes back the upload resumes by itself (on 28.10.2026 within 80 s); if it does not, restarting the machine (prepare-shutdown, limactl start) drops the dead connections.":
      "rclone mempunyai jalur sedang berjalan, tetapi tiada yang dimuat naik selama %@ - biasanya sambungan rangkaian terputus, yang tidak dilaporkan oleh rclone sebagai ralat. Sandaran sejak itu hanya ada dalam penimbal mesin. Apabila rangkaian kembali, muat naik menyambung sendiri (pada 28.10.2026 dalam 80 s); jika tidak, memulakan semula mesin (prepare-shutdown, limactl start) menutup sambungan yang mati.",
    "tmutil did not answer - not restarting the machine while its state is unknown.":
      "tmutil tidak menjawab - mesin tidak dimulakan semula selagi keadaannya tidak diketahui.",
    "The machine's share cannot be read":
      "Perkongsian mesin tidak boleh dibaca",
    "Unknown whether the machine's share can be read":
      "Tidak diketahui sama ada perkongsian mesin boleh dibaca",
    "Samba in the machine does not answer this Mac":
      "Samba dalam mesin tidak menjawab Mac ini",
    "Unknown whether Samba in the machine answers this Mac":
      "Tidak diketahui sama ada Samba dalam mesin menjawab Mac ini",
    "Reading 1 byte of %@ in the machine failed: %@. Every service says it is active, yet Time Machine cannot use the image there. Nothing restarts it by itself. Check: cloudmachine-agent vm-status, then in the machine: journalctl -u punchfs -u tm-bands-bind -u rclone-tm":
      "Membaca 1 bait daripada %@ dalam mesin gagal: %@. Setiap perkhidmatan mengatakan ia aktif, tetapi Time Machine tidak dapat menggunakan imej di situ. Tiada apa yang memulakannya semula dengan sendiri. Semak: cloudmachine-agent vm-status, kemudian dalam mesin: journalctl -u punchfs -u tm-bands-bind -u rclone-tm",
    "Reading 1 byte of %@ in the machine has not returned for %@ s. That is how a hung punchfs or rclone mount behaves. Nothing is restarted while the state is unknown - a restart under a write still going could lose it. Check in the machine: journalctl -u punchfs -u rclone-tm":
      "Membaca 1 bait daripada %@ dalam mesin belum kembali selama %@ s. Begitulah kelakuan lekapan punchfs atau rclone yang tergantung. Tiada apa yang dimulakan semula selagi keadaan tidak diketahui - mula semula di bawah penulisan yang masih berjalan boleh menghilangkannya. Semak dalam mesin: journalctl -u punchfs -u rclone-tm",
    "An SMB connection to %@ got no answer within %@ s. Time Machine reaches the machine at this address. Check the machine's network and smbd: cloudmachine-agent vm-status":
      "Sambungan SMB ke %@ tidak mendapat jawapan dalam %@ s. Time Machine mencapai mesin pada alamat ini. Semak rangkaian mesin dan smbd: cloudmachine-agent vm-status",
    "The machine did not report its address, so nobody could try an SMB connection. Check: cloudmachine-agent vm-status":
      "Mesin tidak melaporkan alamatnya, jadi tiada sesiapa dapat mencuba sambungan SMB. Semak: cloudmachine-agent vm-status",
    "An SMB connection to %@ failed (%@). Time Machine reaches the machine at this address, so no backup is made. Check the machine's network and smbd: cloudmachine-agent vm-status":
      "Sambungan SMB ke %@ gagal (%@). Time Machine mencapai mesin pada alamat ini, jadi tiada sandaran dibuat. Semak rangkaian mesin dan smbd: cloudmachine-agent vm-status",
    "readable":
      "boleh dibaca",
    "no image yet":
      "belum ada imej",
    "answers":
      "menjawab",
    "Share read:       %@":
      "Bacaan kongsi:    %@",
    "Samba from Mac:   %@":
      "Samba dari Mac:   %@",
    "This Mac found no route to %@ (%@). Either the route to the machine is gone, or macOS Local Network privacy has not allowed CloudMachine - then allow it in System Settings > Privacy & Security > Local Network. Check: cloudmachine-agent vm-status":
      "Mac ini tidak menemui laluan ke %@ (%@). Sama ada laluan ke mesin sudah hilang, atau privasi Rangkaian Setempat macOS belum membenarkan CloudMachine - jika begitu, benarkannya dalam Seting Sistem > Privasi & Keselamatan > Rangkaian Setempat. Semak: cloudmachine-agent vm-status",
  ]
}
