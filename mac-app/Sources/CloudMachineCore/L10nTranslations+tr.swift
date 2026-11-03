// Turkish translations, keyed by the English text passed to `L10n.tr`.
extension L10nTranslations {
  static let tr: [String: String] = [
    "Space limit:      %@":
      "Alan sınırı:      %@",
    "                  Time Machine quota not set to match - run: %@":
      "                  Time Machine kotası eşleşmiyor - şunu çalıştırın: %@",
    "Sets how much of Google Drive this Mac may use, and prints the Time Machine quota command.":
      "Bu Mac'in Google Drive'da ne kadar yer kullanabileceğini ayarlar ve Time Machine kotası komutunu yazdırır.",
    "Limit in GB.":
      "GB cinsinden sınır.",
    "Limit for this Mac: %@ GB.":
      "Bu Mac için sınır: %@ GB.",
    "Now set the Time Machine quota (needs an administrator password):":
      "Şimdi Time Machine kotasını ayarlayın (yönetici parolası gerekir):",
    "CloudMachine - verification, Google Drive setup and installation. Called by launchd on a schedule, or by hand from Terminal.":
      "CloudMachine - doğrulama, Google Drive kurulumu ve yükleme. launchd tarafından zamanlanmış olarak veya Terminal'den elle çağrılır.",
    "Connects to Google Drive through rclone (OAuth in the browser) and creates this machine's folder.":
      "rclone aracılığıyla Google Drive'a bağlanır (tarayıcıda OAuth) ve bu makinenin klasörünü oluşturur.",
    "Overwrite the existing remote. RISKY: replaces the token and permissions.":
      "Mevcut remote'un üzerine yaz. RİSKLİ: belirteci ve izinleri değiştirir.",
    "Packs build/CloudMachine.app into build/CloudMachine-<version>.dmg.":
      "build/CloudMachine.app dosyasını build/CloudMachine-<sürüm>.dmg olarak paketler.",
    "ERROR: %@ is missing - run 'cloudmachine-agent build-app' first":
      "HATA: %@ yok - önce 'cloudmachine-agent build-app' komutunu çalıştırın",
    "==> Preparing the staging folder":
      "==> Staging klasörü hazırlanıyor",
    "==> Creating %@":
      "==> %@ oluşturuluyor",
    "ERROR: hdiutil exited with code %@.":
      "HATA: hdiutil %@ koduyla sonlandı.",
    "==> Done: %@":
      "==> Bitti: %@",
    "On first launch (the app is not signed with an Apple Developer account):":
      "İlk açılışta (uygulama bir Apple Developer hesabıyla imzalanmadı):",
    "1. Open %@ and drag CloudMachine.app to Applications.":
      "1. %@ dosyasını açın ve CloudMachine.app'i Uygulamalar'a sürükleyin.",
    "2. In Finder, RIGHT-click CloudMachine.app -> Open -> Open\n   (a plain double-click shows the Gatekeeper block \"unidentified developer\").":
      "2. Finder'da CloudMachine.app üzerinde SAĞ tıklayın -> Aç -> Aç\n   (düz çift tıklama Gatekeeper'ın \"kimliği belirsiz geliştirici\" engelini gösterir).",
    "3. Later launches work normally, with a double-click.":
      "3. Sonraki açılışlar çift tıklamayla normal şekilde çalışır.",
    "Builds CloudMachine.app (Release) - GUI + cloudmachine-agent in Contents/MacOS/, plus launchd/, vm/ and config/ as Resources.":
      "CloudMachine.app'i derler (Release) - Contents/MacOS/ içinde GUI + cloudmachine-agent, ayrıca Resources olarak launchd/, vm/ ve config/.",
    "Binaries for Apple Silicon and Intel at once (how CI builds a release; unnecessary locally).":
      "Apple Silicon ve Intel için ikili dosyalar birlikte (CI sürümü böyle derler; yerelde gereksiz).",
    "==> Building CloudMachineApp + cloudmachine-agent (release) - version %@ (%@)":
      "==> CloudMachineApp + cloudmachine-agent derleniyor (release) - sürüm %@ (%@)",
    "ERROR: swift build exited with code %@.":
      "HATA: swift build %@ koduyla sonlandı.",
    "ERROR: swift build --show-bin-path did not report the binaries directory.":
      "HATA: swift build --show-bin-path ikili dosyaların klasörünü bildirmedi.",
    "ERROR: no built binary found at %@":
      "HATA: derlenmiş ikili dosya bulunamadı: %@",
    "==> Assembling the .app bundle in %@":
      "==> .app paketi %@ içinde birleştiriliyor",
    "==> WARNING: you are building from a DIRTY tree - the version will not point to a commit.":
      "==> UYARI: KİRLİ bir ağaçtan derliyorsunuz - sürüm bir commit'i göstermeyecek.",
    "ERROR: Resources/AppIcon.icns is missing - generate it: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns":
      "HATA: Resources/AppIcon.icns yok - oluşturun: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns",
    "==> Signing with the local certificate '%@' (Full Disk Access will survive later rebuilds)":
      "==> Yerel '%@' sertifikasıyla imzalanıyor (Tam Disk Erişimi sonraki yeniden derlemelerde korunur)",
    "==> Signing ad-hoc (no Apple Developer account) - run 'cloudmachine-agent setup-signing-cert' once so that TCC permissions survive later rebuilds":
      "==> Ad-hoc imzalanıyor (Apple Developer hesabı yok) - TCC izinlerinin sonraki yeniden derlemelerde korunması için bir kez 'cloudmachine-agent setup-signing-cert' çalıştırın",
    "ERROR: codesign exited with code %@.":
      "HATA: codesign %@ koduyla sonlandı.",
    "Next step: %@":
      "Sonraki adım: %@",
    "Creates a local self-signed certificate so that Full Disk Access survives later rebuilds of the app.":
      "Tam Disk Erişimi'nin uygulamanın sonraki yeniden derlemelerinde korunması için yerel, kendinden imzalı bir sertifika oluşturur.",
    "Certificate '%@' already exists in %@, nothing to do.":
      "'%@' sertifikası zaten %@ içinde var, yapılacak bir şey yok.",
    "==> Generating the key and self-signed certificate '%@'...":
      "==> Anahtar ve kendinden imzalı '%@' sertifikası oluşturuluyor...",
    "ERROR: openssl req exited with code %@.":
      "HATA: openssl req %@ koduyla sonlandı.",
    "ERROR: openssl pkcs12 exited with code %@.":
      "HATA: openssl pkcs12 %@ koduyla sonlandı.",
    "==> Importing the certificate into %@ (pre-authorizing /usr/bin/codesign, so it does not ask for the keychain password every time)...":
      "==> Sertifika %@ içine aktarılıyor (/usr/bin/codesign önceden yetkilendiriliyor, böylece her seferinde anahtar zinciri parolası sorulmaz)...",
    "ERROR: security import exited with code %@.":
      "HATA: security import %@ koduyla sonlandı.",
    "==> Trusting the certificate ONLY for code signing...":
      "==> Sertifikaya YALNIZCA kod imzalama için güveniliyor...",
    "ERROR: security add-trusted-cert exited with code %@.":
      "HATA: security add-trusted-cert %@ koduyla sonlandı.",
    "Done. Certificate '%@' is now available to codesign.":
      "Bitti. '%@' sertifikası artık codesign için kullanılabilir.",
    "The next 'cloudmachine-agent build-app' will use it automatically instead of an ad-hoc signature.":
      "Sonraki 'cloudmachine-agent build-app' ad-hoc imza yerine bunu otomatik olarak kullanır.",
    "After THAT ONE rebuild, grant Full Disk Access one last time - later\nrebuilds will no longer reset it, as long as you sign with the same certificate.":
      "BU TEK yeniden derlemeden sonra Tam Disk Erişimi'ni son bir kez verin - sonraki\nyeniden derlemeler, aynı sertifikayla imzaladığınız sürece onu sıfırlamaz.",
    "Checks whether the hourly cycle STILL works (date of the last SUCCESSFUL backup) and reports failures.":
      "Saatlik döngünün HÂLÂ çalışıp çalışmadığını (son BAŞARILI yedeğin tarihi) denetler ve hataları bildirir.",
    "After this many hours without a successful backup we consider the cycle broken.":
      "Bu kadar saat başarılı yedek olmazsa döngü bozuk sayılır.",
    "Only print the state, without a system notification.":
      "Yalnızca durumu yazdır, sistem bildirimi gösterme.",
    "A different Time Machine preferences file - to test the watchdog on a known sample.":
      "Farklı bir Time Machine tercihleri dosyası - gözcüyü bilinen bir örnek üzerinde denemek için.",
    "Last successful backup: %@":
      "Son başarılı yedek: %@",
    "Last successful backup: NONE":
      "Son başarılı yedek: YOK",
    "Last attempt:           %@":
      "Son deneme:             %@",
    "WAITING (system startup): %@":
      "BEKLİYOR (sistem açılışı): %@",
    "Backup cycle: OK":
      "Yedekleme döngüsü: Tamam",
    "FAILURE: %@":
      "HATA: %@",
    "         %@":
      "         %@",
    "Check the state:  %@":
      "Durumu denetle:  %@",
    "Preparing for restart":
      "Yeniden başlatmaya hazırlanıyor",
    "Prepare for restart":
      "Yeniden başlatmaya hazırla",
    "Prepare":
      "Hazırla",
    "==> WARNING: git rev-list failed (%@) - using the date as the build number.":
      "==> UYARI: git rev-list başarısız oldu (%@) - derleme numarası olarak tarih kullanılıyor.",
    "Agents:           %@":
      "Aracılar:         %@",
    "CANNOT START: %@ - open CloudMachine or run backup-health to reload them":
      "BAŞLAYAMIYOR: %@ - yeniden yüklemek için CloudMachine'i açın veya backup-health çalıştırın",
    "Reloaded agents that could not start: %@":
      "Başlayamayan aracılar yeniden yüklendi: %@",
    "Drive folder:     %@":
      "Drive klasörü:    %@",
    "Name of this Mac's folder on Google Drive (default: derived from the computer name). Set once; it cannot be changed later.":
      "Bu Mac'in Google Drive'daki klasörünün adı (varsayılan: bilgisayar adından türetilir). Bir kez ayarlanır; sonradan değiştirilemez.",
    "Backup watchdog:  %@":
      "Yedek gözcüsü:    %@",
    "Prints the version, the build number and the commit this binary was built from.":
      "Sürümü, derleme numarasını ve bu ikili dosyanın derlendiği commit'i yazdırır.",
    "Only one line, without a description.":
      "Yalnızca tek satır, açıklama olmadan.",
    "Build from the working tree (outside a bundle) - no version data.":
      "Çalışma ağacından derleme (paket dışında) - sürüm bilgisi yok.",
    "Version: %@":
      "Sürüm:   %@",
    "Build:   %@":
      "Derleme: %@",
    "Commit:  %@":
      "Commit:  %@",
    "WARNING: built from a DIRTY tree - the binary contains code that\n         is in no commit. The commit number does NOT describe\n         what actually runs.":
      "UYARI: KİRLİ bir ağaçtan derlendi - ikili dosyada hiçbir commit'te\n       olmayan kod var. Commit numarası gerçekte çalışanı\n       TANIMLAMAZ.",
    "Saving the space limit":
      "Alan sınırı kaydediliyor",
    "Measuring usage on Google Drive":
      "Google Drive'daki kullanım ölçülüyor",
    "Google Drive did not answer - try again later.":
      "Google Drive yanıt vermedi - daha sonra tekrar deneyin.",
    "Measured.":
      "Ölçüldü.",
    "Space limit for this Mac":
      "Bu Mac için alan sınırı",
    "Used on Google Drive":
      "Google Drive'da kullanılan",
    "Measured %@. The watchdog measures again every few hours.":
      "%@ ölçüldü. Gözcü birkaç saatte bir yeniden ölçer.",
    "Limit (GB)":
      "Sınır (GB)",
    "Save":
      "Kaydet",
    "Measure now":
      "Şimdi ölç",
    "Time Machine quota: %@ GB (70%% of the limit - the copy on Drive is about a third larger than the backup inside it). Time Machine deletes the oldest backups to stay within it.":
      "Time Machine kotası: %@ GB (sınırın %%70'i - Drive'daki kopya, içindeki yedekten yaklaşık üçte bir daha büyüktür). Time Machine bu kotaya sığmak için en eski yedekleri siler.",
    "Set the Time Machine quota: run this in Terminal (needs sudo)":
      "Time Machine kotasını ayarlayın: bunu Terminal'de çalıştırın (sudo gerekir)",
    "Connect Google Drive: run this in Terminal and approve in the browser":
      "Google Drive'ı bağlayın: bunu Terminal'de çalıştırın ve tarayıcıda onaylayın",
    "Grant Full Disk Access to CloudMachine, so it can tell whether backups complete":
      "CloudMachine'e Tam Disk Erişimi verin; böylece yedeklerin tamamlanıp tamamlanmadığını anlayabilir",
    "Folder on Google Drive":
      "Google Drive'daki klasör",
    "One folder per Mac. Set once - it cannot be changed after connecting.":
      "Her Mac için bir klasör. Bir kez ayarlanır - bağlandıktan sonra değiştirilemez.",
    "Use lowercase letters, digits and dashes.":
      "Küçük harf, rakam ve tire kullanın.",
    "Install rclone":
      "rclone'u yükle",
    "Open System Settings":
      "Sistem Ayarları'nı aç",
    "Install agents":
      "Aracıları yükle",
    "not checked":
      "denetlenmedi",
    "none at all":
      "hiç yok",
    "%@ ago":
      "%@ önce",
    "Missing: %@":
      "Eksik: %@",
    "Google Drive not connected":
      "Google Drive bağlı değil",
    "Time Machine does not point to CloudMachine":
      "Time Machine, CloudMachine'i göstermiyor",
    "UNKNOWN whether Time Machine points to CloudMachine - tmutil did not answer":
      "Time Machine'in CloudMachine'i gösterip göstermediği BİLİNMİYOR - tmutil yanıt vermedi",
    "Backup in progress":
      "Yedekleme sürüyor",
    "Unknown when the last backup was made":
      "Son yedeğin ne zaman alındığı bilinmiyor",
    "There is no completed backup at all":
      "Hiç tamamlanmış yedek yok",
    "No completed backup for %@":
      "%@ süredir tamamlanmış yedek yok",
    "Ready":
      "Hazır",
    "Not saved: %@":
      "Kaydedilmedi: %@",
    "Installing rclone":
      "rclone yükleniyor",
    "Installing launchd agents":
      "launchd aracıları yükleniyor",
    "Starting backup":
      "Yedekleme başlatılıyor",
    "Backup started.":
      "Yedekleme başlatıldı.",
    "Could not start the backup.":
      "Yedekleme başlatılamadı.",
    "Stopping backup":
      "Yedekleme durduruluyor",
    "Backup stopped.":
      "Yedekleme durduruldu.",
    "Could not stop the backup.":
      "Yedekleme durdurulamadı.",
    "Could not prepare the AppleScript.":
      "AppleScript hazırlanamadı.",
    "Unknown authorization error.":
      "Bilinmeyen yetkilendirme hatası.",
    "Waiting to upload":
      "Yüklenmeyi bekliyor",
    "%@ files":
      "%@ dosya",
    "nothing":
      "hiçbir şey",
    "Back up now":
      "Şimdi yedekle",
    "Stop backup":
      "Yedeklemeyi durdur",
    "Open CloudMachine":
      "CloudMachine'i aç",
    "Quit":
      "Çık",
    "Healthy":
      "Sağlıklı",
    "Attention":
      "Dikkat",
    "Refreshed %@":
      "Yenilendi %@",
    "System Status":
      "Sistem durumu",
    "Action needed":
      "İşlem gerekli",
    "not measured":
      "ölçülmedi",
    "rclone did not answer":
      "rclone yanıt vermedi",
    "Backup in Progress":
      "Yedekleme sürüyor",
    "Files processed":
      "İşlenen dosyalar",
    "Write speed":
      "Yazma hızı",
    "Operation phase":
      "İşlem aşaması",
    "Required Setup Steps":
      "Gerekli kurulum adımları",
    "Copy":
      "Kopyala",
    "Last completed backup":
      "Son tamamlanan yedek",
    "Last backup watchdog run":
      "Yedek gözcüsünün son çalışması",
    "not read":
      "okunmadı",
    "Everything uploaded":
      "Her şey yüklendi",
    "File upload errors":
      "Dosya yükleme hataları",
    "Google Drive Credentials (OAuth 2.0)":
      "Google Drive kimlik bilgileri (OAuth 2.0)",
    "Keychain OK":
      "Anahtar Zinciri tamam",
    "No custom keys":
      "Özel anahtar yok",
    "Paste client_id...":
      "client_id yapıştırın...",
    "Paste client_secret...":
      "client_secret yapıştırın...",
    "Save securely in the Keychain":
      "Anahtar Zinciri'ne güvenli şekilde kaydet",
    "Refresh":
      "Yenile",
    "Overview":
      "Genel bakış",
    "Backups":
      "Yedekler",
    "Storage":
      "Alan",
    "Settings":
      "Ayarlar",
    "Current status: %@":
      "Geçerli durum: %@",
    "Does not point to CloudMachine":
      "CloudMachine'i göstermiyor",
    "tmutil did not answer":
      "tmutil yanıt vermedi",
    "Backing up: %@ of %@":
      "Yedekleniyor: %@ / %@",
    "%@ of %@":
      "%@ / %@",
    "Copied":
      "Kopyalandı",
    "No backup is running":
      "Çalışan yedekleme yok",
    "Time Machine starts the next one on its own schedule.":
      "Time Machine bir sonrakini kendi zamanlamasına göre başlatır.",
    "Backup cycle":
      "Yedekleme döngüsü",
    "%@ GiB":
      "%@ GiB",
    "%@ GiB in %@ bands, %@ uploading":
      "%@ GiB, %@ bant, %@ yükleniyor",
    "%@ bands":
      "%@ bant",
    "%@ fragments abandoned - only in the machine":
      "%@ parça bırakıldı - yalnızca makinede",
    "127.0.0.1:5572 answers on the Mac: Lima forwards the machine's rclone remote control, which has no password. Any web page open in a browser can send it commands - including deleting the backup on Google Drive. Add the portForwards rule from vm/cmsmb.yaml to the machine and restart it (see vm/README.md).":
      "127.0.0.1:5572 Mac'te yanıt veriyor: Lima, makinenin parolasız rclone uzaktan denetimini yönlendiriyor. Tarayıcıda açık herhangi bir web sayfası ona komut gönderebilir - Google Drive'daki yedeği silmek dahil. vm/cmsmb.yaml dosyasındaki portForwards kuralını makineye ekleyin ve yeniden başlatın (bkz. vm/README.md).",
    "A service in the CloudMachine machine is not running":
      "CloudMachine makinesindeki bir hizmet çalışmıyor",
    "Address":
      "Adres",
    "Agent installation INCOMPLETE - %@ of %@ did not go in:\n%@\n%@\nEvery missing agent is a function that has silently stopped working (vm-guard watches the machine's buffer, backup-health reports failures). Fix the cause and repeat the installation.":
      "Aracı kurulumu EKSİK - %@ / %@ kurulamadı:\n%@\n%@\nEksik her aracı, sessizce çalışmayı bırakmış bir işlevdir (vm-guard makinenin arabelleğini izler, backup-health hataları bildirir). Nedeni giderin ve kurulumu yineleyin.",
    "All running":
      "Tümü çalışıyor",
    "Also install the launchd agents (same as install-launchd).":
      "launchd aracılarını da kur (install-launchd ile aynı).",
    "At most this many minutes of waiting for the upload.":
      "Yüklemeyi en fazla bu kadar dakika bekle.",
    "At the limit every new band fails with EMFILE and the backup stops. Check: cloudmachine-agent vm-status":
      "Sınırda her yeni bant EMFILE hatasıyla başarısız olur ve yedekleme durur. Denetleyin: cloudmachine-agent vm-status",
    "Cache on the machine's disk":
      "Makinenin diskindeki önbellek",
    "Connected to Google Drive, but could not create the folder '%@' - without it the machine has nowhere to keep the backup. Check the account permissions and try again.":
      "Google Drive'a bağlanıldı ancak '%@' klasörü oluşturulamadı - o olmadan makinenin yedeği saklayacak yeri yok. Hesap izinlerini denetleyin ve yeniden deneyin.",
    "Convert the image":
      "Görüntüyü dönüştür",
    "Converting the image to 32 MB bands":
      "Görüntü 32 MB'lık bantlara dönüştürülüyor",
    "Could not check with the current connection whether the backup is on Google Drive (%@), so remote '%@' was NOT replaced: without that answer the new sign-in cannot be checked against it.":
      "Yedeğin Google Drive'da olup olmadığı (%@) mevcut bağlantıyla denetlenemedi; bu yüzden '%@' remote'u DEĞİŞTİRİLMEDİ: bu yanıt olmadan yeni oturum açma onunla karşılaştırılamaz.",
    "Downloads the official rclone binary into ~/.cloudmachine/bin (Google sign-in and the machine's rclone.conf).":
      "Resmî rclone ikili dosyasını ~/.cloudmachine/bin içine indirir (Google oturum açma ve makinenin rclone.conf dosyası).",
    "Free in the machine":
      "Makinede boş",
    "Free in the machine: %@":
      "Makinede boş: %@",
    "Generates and installs the launchd agents (app, backup watchdog, machine start, machine guard).":
      "launchd aracılarını oluşturur ve kurar (uygulama, yedek gözcüsü, makine başlatma, makine bekçisi).",
    "Install Lima, which runs the CloudMachine machine: run this in Terminal":
      "CloudMachine makinesini çalıştıran Lima'yı kurun: bunu Terminal'de çalıştırın",
    "Install rclone (signs in to Google Drive for the machine)":
      "rclone'u kurun (makine için Google Drive'da oturum açar)",
    "Install the background agents (machine start, buffer guard, backup watchdog)":
      "Arka plan aracılarını kurun (makine başlatma, arabellek bekçisi, yedek gözcüsü)",
    "Installs rclone through Homebrew - CloudMachine itself uses the one from install-rclone.":
      "rclone'u Homebrew ile kurar - CloudMachine'in kendisi install-rclone ile gelen sürümü kullanır.",
    "Info.plist, token and mapped/ of the backup image exist only on the machine's disk; without them the bands in %@ cannot be restored. The copy (tm-meta-sync, every 15 min) goes to %@. Check: cloudmachine-agent vm-status, then in the machine: journalctl -u tm-meta-sync":
      "Yedek görüntüsünün Info.plist, token ve mapped/ öğeleri yalnızca makinenin diskinde bulunur; onlar olmadan %@ içindeki bantlar geri yüklenemez. Kopya (tm-meta-sync, 15 dakikada bir) %@ konumuna gider. Denetleyin: cloudmachine-agent vm-status, sonra makinede: journalctl -u tm-meta-sync",
    "Lima says the machine is running, but a command in it did not return. Without it nothing is known about Samba, rclone or the upload. Check: cloudmachine-agent vm-status":
      "Lima makinenin çalıştığını söylüyor, ancak içindeki bir komut dönmedi. Bu olmadan Samba, rclone veya yükleme hakkında hiçbir şey bilinmiyor. Denetleyin: cloudmachine-agent vm-status",
    "Machine":
      "Makine",
    "Machine %@":
      "Makine %@",
    "Machine & Upload Status":
      "Makine ve yükleme durumu",
    "Machine buffer":
      "Makine arabelleği",
    "No Time Machine destination is the machine's share (smb://tm@<address>/CloudMachine) - backups are not being made there. The command is printed by: cloudmachine-agent vm-setup":
      "Hiçbir Time Machine hedefi makinenin paylaşımı (smb://tm@<adres>/CloudMachine) değil - yedekler oraya alınmıyor. Komutu şu yazdırır: cloudmachine-agent vm-setup",
    "Not running: %@":
      "Çalışmıyor: %@",
    "Not set up":
      "Kurulmadı",
    "Once it runs out, rclone stops uploading, the machine's buffer fills up and backups stop being made. At a growth of ~600 MB per hourly cycle that is about %@ days.":
      "Bittiğinde rclone yüklemeyi durdurur, makinenin arabelleği dolar ve yedekler alınmaz olur. Saatlik döngü başına ~600 MB artışla bu yaklaşık %@ gün eder.",
    "Or rclone.conf is missing: this Mac has already set up the CloudMachine machine, so it is not connected anew blindly. Restore the file from a backup (the machine keeps its own copy in %@). To connect anyway, create an empty file at the path `%@ config file` prints and run again - the existing folder is kept.":
      "Ya da rclone.conf yok: bu Mac'te CloudMachine makinesi zaten kurulmuş, bu yüzden körü körüne yeniden bağlanmaz. Dosyayı bir yedekten geri yükleyin (makine kendi kopyasını %@ içinde tutar). Yine de bağlanmak için `%@ config file` komutunun yazdırdığı yolda boş bir dosya oluşturun ve yeniden çalıştırın - mevcut klasör korunur.",
    "Point Time Machine at the machine: run this in Terminal (needs sudo; Copy includes the password)":
      "Time Machine'i makineye yönlendirin: bunu Terminal'de çalıştırın (sudo gerekir; Kopyala parolayı da içerir)",
    "Points to the machine":
      "Makineyi gösteriyor",
    "Prepares for a restart: stops the backup, waits a while for the upload, then stops the machine cleanly.":
      "Yeniden başlatmaya hazırlar: yedeklemeyi durdurur, yükleme için bir süre bekler, sonra makineyi düzgünce durdurur.",
    "Reading the Time Machine destination did not return within %@ s. That is how tmutil behaves when its destination hangs.":
      "Time Machine hedefinin okunması %@ s içinde dönmedi. Hedefi takıldığında tmutil böyle davranır.",
    "Remote '%@' was NOT replaced. The new sign-in gets the 'drive.file' scope, which sees only files created under its own client_id. The existing backup was most likely created by the current connection and would become invisible to it. Before anything is written, the new token is checked against the existing backup, and the replacement is abandoned if it cannot see it. The machine keeps its own copy of the configuration until vm-setup --replace-rclone-config. To go ahead, run again with --replace-existing --accept-scope-change.":
      "'%@' remote'u DEĞİŞTİRİLMEDİ. Yeni oturum açma, yalnızca kendi client_id'si altında oluşturulan dosyaları gören 'drive.file' kapsamını alır. Mevcut yedek büyük olasılıkla geçerli bağlantıyla oluşturuldu ve ona görünmez olurdu. Herhangi bir şey yazılmadan önce yeni belirteç mevcut yedekle denetlenir ve onu göremezse değiştirme iptal edilir. Makine, yapılandırmanın kendi kopyasını vm-setup --replace-rclone-config komutuna kadar tutar. Devam etmek için --replace-existing --accept-scope-change ile yeniden çalıştırın.",
    "Remote control:   OPEN on the Mac at 127.0.0.1:5572 - any web page can send rclone commands; see vm/README.md (portForwards)":
      "Uzaktan denetim:  Mac'te 127.0.0.1:5572 adresinde AÇIK - herhangi bir web sayfası rclone komutları gönderebilir; bkz. vm/README.md (portForwards)",
    "Running":
      "Çalışıyor",
    "Samba, rclone or punchfs in the machine is not active, so Time Machine has nowhere to write or the bands do not reach Google Drive. Check: cloudmachine-agent vm-status":
      "Makinedeki Samba, rclone veya punchfs etkin değil; bu yüzden Time Machine'in yazacak yeri yok ya da bantlar Google Drive'a ulaşmıyor. Denetleyin: cloudmachine-agent vm-status",
    "Service %@":
      "Hizmet %@",
    "Services":
      "Hizmetler",
    "Set up the CloudMachine machine (the first time it downloads Ubuntu - several minutes)":
      "CloudMachine makinesini kurun (ilk seferde Ubuntu indirilir - birkaç dakika)",
    "Set up the CloudMachine machine again, so it prints the Time Machine command":
      "CloudMachine makinesini yeniden kurun; böylece Time Machine komutunu yazdırır",
    "Set up the machine":
      "Makineyi kur",
    "Setting up the CloudMachine machine":
      "CloudMachine makinesi kuruluyor",
    "Start the CloudMachine machine":
      "CloudMachine makinesini başlatın",
    "Start the machine":
      "Makineyi başlat",
    "Starting the CloudMachine machine":
      "CloudMachine makinesi başlatılıyor",
    "Still to upload: %@ GiB":
      "Yüklenecek kalan: %@ GiB",
    "Stopping the Time Machine backup...":
      "Time Machine yedeklemesi durduruluyor...",
    "Stopping the machine %@...":
      "%@ makinesi durduruluyor...",
    "The CloudMachine machine does not answer":
      "CloudMachine makinesi yanıt vermiyor",
    "The CloudMachine machine is not running":
      "CloudMachine makinesi çalışmıyor",
    "The CloudMachine machine is not set up yet":
      "CloudMachine makinesi henüz kurulmadı",
    "The CloudMachine machine is stopped":
      "CloudMachine makinesi durduruldu",
    "The backup is stopped, the upload gets up to 30 minutes, then the machine shuts down cleanly. It starts again at the next login.":
      "Yedekleme durdurulur, yükleme için 30 dakikaya kadar süre tanınır, sonra makine düzgünce kapanır. Bir sonraki oturum açmada yeniden başlar.",
    "The machine %@ is not running - nothing to prepare.":
      "%@ makinesi çalışmıyor - hazırlanacak bir şey yok.",
    "The machine is stopped and everything reached Google Drive. The Mac can be restarted; the machine starts again at login.":
      "Makine durduruldu ve her şey Google Drive'a ulaştı. Mac yeniden başlatılabilir; makine oturum açıldığında yeniden başlar.",
    "The machine is stopped. %@ GiB had not reached Google Drive yet - it is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "Makine durduruldu. %@ GiB henüz Google Drive'a ulaşmadı - makinenin arabelleğinde tutuluyor ve bir sonraki başlatmadan sonra yüklenecek. Mac yeniden başlatılabilir.",
    "The machine is stopped. rclone did not say how much was still to upload; what was not uploaded is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "Makine durduruldu. rclone yüklenecek ne kadar kaldığını bildirmedi; yüklenmeyenler makinenin arabelleğinde tutulur ve bir sonraki başlatmadan sonra yüklenir. Mac yeniden başlatılabilir.",
    "The machine's disk is a file on this disk and grows as the upload buffer fills. With no space left the machine cannot write the buffer, and Time Machine's local snapshots have nowhere to go either.":
      "Makinenin diski bu diskteki bir dosyadır ve yükleme arabelleği doldukça büyür. Boş yer kalmazsa makine arabelleği yazamaz ve Time Machine'in yerel anlık görüntülerinin de gidecek yeri olmaz.",
    "The image's metadata has never been copied to Drive":
      "Yedek görüntüsünün üst verileri Drive'a hiç kopyalanmadı",
    "The image's metadata was last copied to Drive %@ ago":
      "Yedek görüntüsünün üst verileri Drive'a en son %@ önce kopyalandı",
    "The machine's disk is running out of space (%@ GB)":
      "Makinenin diskinde yer azalıyor (%@ GB)",
    "The new sign-in does NOT see the existing backup (%@), so remote '%@' was NOT replaced and rclone.conf is unchanged. Keep the current connection, or sign in with the credential (client_id) that created the backup.":
      "Yeni oturum açma mevcut yedeği (%@) GÖRMÜYOR; bu yüzden '%@' remote'u DEĞİŞTİRİLMEDİ ve rclone.conf aynı kaldı. Mevcut bağlantıyı koruyun veya yedeği oluşturan kimlik bilgisiyle (client_id) oturum açın.",
    "The upload buffer lives on this disk. The guard pauses Time Machine before it fills; if the upload does not catch up, backups stay paused.":
      "Yükleme arabelleği bu diskte bulunur. Bekçi, dolmadan önce Time Machine'i duraklatır; yükleme yetişmezse yedekler duraklatılmış kalır.",
    "These bands exist only in the machine's buffer. The backup on Google Drive is INCOMPLETE and may not open.":
      "Bu bantlar yalnızca makinenin arabelleğinde var. Google Drive'daki yedek EKSİK ve açılmayabilir.",
    "Time Machine backs up to the machine, so without it no backup is made. Start it: limactl start %@ (or the Start button in the app).":
      "Time Machine makineye yedekler; bu yüzden makine olmadan yedek alınmaz. Başlatın: limactl start %@ (veya uygulamadaki düğmeyle).",
    "Time Machine did not stop its backup within 2 minutes (or tmutil did not answer) - the machine was NOT stopped. Try again in a moment.":
      "Time Machine yedeklemeyi 2 dakika içinde durdurmadı (ya da tmutil yanıt vermedi) - makine DURDURULMADI. Biraz sonra yeniden deneyin.",
    "Time Machine has created its image: stop the backup, then convert the image to 32 MB bands":
      "Time Machine görüntüsünü oluşturdu: yedeklemeyi durdurun, sonra görüntüyü 32 MB'lık bantlara dönüştürün",
    "To upload":
      "Yüklenecek",
    "Unknown whether the CloudMachine machine is running":
      "CloudMachine makinesinin çalışıp çalışmadığı bilinmiyor",
    "Waiting for the upload to Google Drive (at most %@ min)...":
      "Google Drive'a yükleme bekleniyor (en fazla %@ dk)...",
    "With --replace-existing: confirms that the new sign-in (scope 'drive.file') may not see the existing backup. The new token is still checked against the backup first.":
      "--replace-existing ile: yeni oturum açmanın ('drive.file' kapsamı) mevcut yedeği görmeyebileceğini onaylar. Yeni belirteç yine de önce yedekle denetlenir.",
    "Without it there is no way to check whether anything reached the Drive - the machine's guard is blind then.":
      "O olmadan Drive'a bir şey ulaşıp ulaşmadığını denetlemenin yolu yok - makinenin bekçisi o zaman kördür.",
    "limactl did not answer":
      "limactl yanıt vermedi",
    "limactl did not answer (or is not installed). That does not mean the machine is down - it means nobody has checked.":
      "limactl yanıt vermedi (veya kurulu değil). Bu, makinenin kapalı olduğu anlamına gelmez - kimsenin denetlemediği anlamına gelir.",
    "limactl start failed: %@":
      "limactl start başarısız oldu: %@",
    "limactl stop failed: %@":
      "limactl stop başarısız oldu: %@",
    "punchfs is close to its open-file limit":
      "punchfs açık dosya sınırına yaklaştı",
    "punchfs open files":
      "punchfs açık dosyaları",
    "rclone's remote control is open on this Mac":
      "rclone uzaktan denetimi bu Mac'te açık",
    "statfs('/System/Volumes/Data') returned an error, so nobody knows whether the machine's disk can still grow on this Mac.":
      "statfs('/System/Volumes/Data') hata döndürdü; bu yüzden makinenin diskinin bu Mac'te hâlâ büyüyüp büyüyemeyeceği bilinmiyor.",
    "Google Drive's daily upload limit stops the upload":
      "Google Drive'ın günlük yükleme sınırı yüklemeyi durdurdu",
    "Google last refused an upload %@ ago (750 GB a day). Backups since then are only in the machine's buffer on this Mac. rclone retries every 5 min and resumes by itself when the limit passes; the guard pauses Time Machine if more than %@ GiB waits.":
      "Google en son %@ önce bir yüklemeyi reddetti (günde 750 GB). O zamandan beri alınan yedekler yalnızca bu Mac'teki makinenin arabelleğinde. rclone 5 dakikada bir yeniden dener ve sınır geçince kendiliğinden devam eder; %@ GiB'den fazlası bekliyorsa bekçi Time Machine'i duraklatır.",
    "Usage on Google Drive is not being measured":
      "Google Drive'daki kullanım ölçülmüyor",
    "The last measurement (%@ GB) is from %@, %@ ago - rclone size has not answered since. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "Son ölçüm (%@ GB) %@ tarihli, %@ önce - rclone size o zamandan beri yanıt vermiyor. Yanıt verene kadar %@ GB sınırını kimse izlemiyor: %%90 ve %%100 uyarıları sessiz kalır. vm-status'a bakın veya penceredeki Şimdi ölç'e basın.",
    "rclone size has not answered even once. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "rclone size bir kez bile yanıt vermedi. Yanıt verene kadar %@ GB sınırını kimse izlemiyor: %%90 ve %%100 uyarıları sessiz kalır. vm-status'a bakın veya penceredeki Şimdi ölç'e basın.",
    "Saved in the Keychain. Connecting Google Drive (configure-remote) will use them.":
      "Anahtar Zinciri'ne kaydedildi. Google Drive'ı bağlarken (configure-remote) bunlar kullanılacak.",
    "Saved in the Keychain. The existing Google Drive connection keeps its old client_id, and on this Mac it should stay that way: a connection made with the new keys (the 'drive.file' scope) cannot see the backup created by the old one. Do not replace the connection here; the new keys are for a Mac that is not connected yet.":
      "Anahtar Zinciri'ne kaydedildi. Mevcut Google Drive bağlantısı eski client_id'sini korur ve bu Mac'te öyle kalmalı: yeni anahtarlarla ('drive.file' kapsamı) yapılan bağlantı, eskisinin oluşturduğu yedeği göremez. Bağlantıyı burada değiştirmeyin; yeni anahtarlar henüz bağlı olmayan bir Mac içindir.",
    "it is not there for the new token":
      "yeni belirteç için orada değil",
    "Cancel":
      "İptal",
    "ACTION NEEDED":
      "İŞLEM GEREKLİ",
    "WILL PASS BY ITSELF — DO NOTHING":
      "KENDİLİĞİNDEN GEÇECEK — BİR ŞEY YAPMAYIN",
    "UNKNOWN — CHECK AGAIN SHORTLY":
      "BİLİNMİYOR — BİRAZ SONRA YENİDEN DENETLEYİN",
    "ALL GOOD":
      "HER ŞEY YOLUNDA",
    "Upload is not working":
      "Yükleme çalışmıyor",
    "Upload stopped — no space left on Google Drive":
      "Yükleme durdu — Google Drive'da yer kalmadı",
    "%@ backup fragments not uploaded":
      "%@ yedek parçası yüklenmedi",
    "Upload cannot keep up with writes":
      "Yükleme yazmaya yetişemiyor",
    "Upload paused — Google daily limit":
      "Yükleme duraklatıldı — Google günlük sınırı",
    "Uploading to Google Drive — %@ queued":
      "Google Drive'a yükleniyor — %@ sırada",
    "Everything uploaded to Google Drive":
      "Her şey Google Drive'a yüklendi",
    "Unknown what is waiting in the queue":
      "Sırada ne beklediği bilinmiyor",
    "There is no connection to Google Drive, so backups are only made on this Mac. If this does not pass by itself within a few minutes, check the network and the connection to Drive.":
      "Google Drive bağlantısı yok; bu yüzden yedekler yalnızca bu Mac'te alınıyor. Bu birkaç dakika içinde kendiliğinden geçmezse ağı ve Drive bağlantısını denetleyin.",
    "There is no space left on Google Drive. This will NOT pass by itself — you need to free up space on Drive. Until then Time Machine is paused, so that it does not fill up this Mac's disk.":
      "Google Drive'da yer kalmadı. Bu kendiliğinden GEÇMEZ — Drive'da yer açmanız gerekir. O zamana kadar bu Mac'in diski dolmasın diye Time Machine duraklatıldı.",
    "%@ backup fragments could not be uploaded and rclone stopped trying. These fragments exist only on this Mac, so the backup on Drive is incomplete. This needs checking.":
      "%@ yedek parçası yüklenemedi ve rclone denemeyi bıraktı. Bu parçalar yalnızca bu Mac'te var, bu yüzden Drive'daki yedek eksik. Bunun denetlenmesi gerekiyor.",
    "Time Machine is writing faster than the upload goes, and the buffer has filled up. The backup will be paused until the upload catches up — this is a safeguard against filling up the disk, not a failure.":
      "Time Machine yüklemenin gidebildiğinden hızlı yazıyor ve arabellek doldu. Yedekleme, yükleme yetişene kadar duraklatılacak — bu bir arıza değil, diskin dolmasına karşı bir güvenlik önlemi.",
    "Google accepts 750 GB per day and that limit has been used up. There is nothing to do: the limit renews by itself, usually within a few hours. Time Machine backups are made normally in the meantime and wait in the buffer — they will be uploaded as soon as Google starts accepting again.":
      "Google günde 750 GB kabul eder ve bu sınır doldu. Yapılacak bir şey yok: sınır kendiliğinden, genellikle birkaç saat içinde yenilenir. Bu sırada Time Machine yedekleri normal alınır ve arabellekte bekler — Google yeniden kabul etmeye başlar başlamaz yüklenir.",
    "%@ backup fragments are queued and on their way to Drive.":
      "%@ yedek parçası sırada ve Drive'a gidiyor.",
    "Nothing is waiting in the queue — the backup on Google Drive is complete.":
      "Sırada bekleyen yok — Google Drive'daki yedek eksiksiz.",
    "rclone did not answer the question about the queue, so it is unknown how many backups are still waiting to be uploaded. This does not mean something broke — under load the answer can be late. It only means that right now nobody knows. If it persists, the backup cycle check will report it.":
      "rclone sıra sorusuna yanıt vermedi; bu yüzden kaç yedeğin hâlâ yüklenmeyi beklediği bilinmiyor. Bu bir şeyin bozulduğu anlamına gelmez — yük altında yanıt gecikebilir. Yalnızca şu anda bunu kimsenin bilmediği anlamına gelir. Sürerse yedekleme döngüsü denetimi bunu bildirir.",
    "unknown error":
      "bilinmeyen hata",
    "rclone lsf ended with an error":
      "rclone lsf hatayla bitti",
    "This Mac is close to its space limit on Google Drive":
      "Bu Mac, Google Drive'daki alan sınırına yaklaşıyor",
    "%@ GB of %@ GB used. Time Machine deletes the oldest backups to stay within its quota; check that the quota is set (vm-status).":
      "%@ / %@ GB kullanıldı. Time Machine kotaya sığmak için en eski yedekleri siler; kotanın ayarlandığını denetleyin (vm-status).",
    "This Mac is over its space limit on Google Drive":
      "Bu Mac, Google Drive'daki alan sınırını aştı",
    "%@ GB of %@ GB used. Set the Time Machine quota (command in the app window or vm-status), or raise the limit.":
      "%@ / %@ GB kullanıldı. Time Machine kotasını ayarlayın (komut uygulama penceresinde veya vm-status'ta) ya da sınırı yükseltin.",
    "not set":
      "ayarlanmadı",
    "%@ GB - usage not measured yet":
      "%@ GB - kullanım henüz ölçülmedi",
    "%@ of %@ GB used (%@%%)":
      "%@ / %@ GB kullanıldı (%%%@)",
    "The limit must be a whole number of GB above zero.":
      "Sınır, sıfırdan büyük bir tam GB sayısı olmalıdır.",
    "machines.json cannot be read, so it was not overwritten. Fix or remove it first.":
      "machines.json okunamıyor, bu yüzden üzerine yazılmadı. Önce onu düzeltin veya silin.",
    "'%@' is not a valid folder name: use lowercase letters, digits and dashes.":
      "'%@' geçerli bir klasör adı değil: küçük harf, rakam ve tire kullanın.",
    "This Mac already backs up to folder '%@'. Switching to '%@' would start a new, empty backup and orphan the existing one, so nothing was changed.":
      "Bu Mac zaten '%@' klasörüne yedekliyor. '%@' klasörüne geçmek yeni, boş bir yedek başlatır ve mevcut olanı sahipsiz bırakırdı; bu yüzden hiçbir şey değiştirilmedi.",
    "This Mac already has a CloudMachine installation, whose backup is in folder '%@'. Switching to '%@' would orphan it, so nothing was changed.":
      "Bu Mac'te zaten bir CloudMachine kurulumu var ve yedeği '%@' klasöründe. '%@' klasörüne geçmek onu sahipsiz bırakırdı; bu yüzden hiçbir şey değiştirilmedi.",
    "Could not save the folder name to %@: %@":
      "Klasör adı %@ konumuna kaydedilemedi: %@",
    "Homebrew is not installed. Install it manually: https://brew.sh":
      "Homebrew kurulu değil. Elle kurun: https://brew.sh",
    "Installing rclone failed: %@":
      "rclone kurulumu başarısız oldu: %@",
    "Installed rclone.":
      "rclone kuruldu.",
    "Own Google credentials: set.":
      "Özel Google kimlik bilgileri: ayarlandı.",
    "INCOMPLETE: %@ is missing - rclone will use rclone's shared client_id anyway.":
      "EKSİK: %@ yok - rclone yine de paylaşılan rclone client_id'sini kullanır.",
    "No own credentials - rclone uses the shared client_id, rate-limited jointly and being retired in 2026.":
      "Özel kimlik bilgisi yok - rclone, ortak olarak sınırlanan ve 2026'da kullanımdan kaldırılacak paylaşılan client_id'yi kullanır.",
    "Empty value - not saving.":
      "Boş değer - kaydedilmiyor.",
    "Keychain refused: %@":
      "Anahtar Zinciri reddetti: %@",
    "DIRTY-TREE":
      "KİRLİ-AĞAÇ",
    "Cannot create the working directory: %@":
      "Çalışma klasörü oluşturulamıyor: %@",
    "Could not read the rclone version number.":
      "rclone sürüm numarası okunamadı.",
    "Could not download %@.":
      "%@ indirilemedi.",
    "No entry for %@ in SHA256SUMS.":
      "SHA256SUMS içinde %@ için kayıt yok.",
    "Could not compute the checksum.":
      "Sağlama toplamı hesaplanamadı.",
    "SHA256 checksum does not match - NOT installing.\n  expected: %@\n  computed: %@":
      "SHA256 sağlama toplamı eşleşmiyor - KURULMUYOR.\n  beklenen: %@\n  hesaplanan: %@",
    "Could not unpack the archive.":
      "Arşiv açılamadı.",
    "Could not install the binary: %@":
      "İkili dosya kurulamadı: %@",
    "Installed rclone %@ in %@ (SHA256 checksum matches).":
      "rclone %@, %@ içine kuruldu (SHA256 sağlama toplamı eşleşiyor).",
    "%@ did not respond within the allotted time (the process was left orphaned in the background).":
      "%@ ayrılan sürede yanıt vermedi (işlem arka planda sahipsiz bırakıldı).",
    "Cannot launch %@: %@":
      "%@ başlatılamıyor: %@",
    "Remote '%@' already exists and was NOT touched.\nOverwriting it replaces the token and the permission scope; a credential with the 'drive.file' scope does not see files created by the previous one, so the existing backup becomes unreachable.\nIf you really want to replace it, first back up ~/.config/rclone/rclone.conf and run again with --replace-existing.":
      "'%@' remote'u zaten var ve DOKUNULMADI.\nÜzerine yazmak belirteci ve izin kapsamını değiştirir; 'drive.file' kapsamlı bir kimlik bilgisi öncekinin oluşturduğu dosyaları görmez, bu yüzden mevcut yedeğe ulaşılamaz hâle gelir.\nGerçekten değiştirmek istiyorsanız önce ~/.config/rclone/rclone.conf dosyasını yedekleyin ve --replace-existing ile yeniden çalıştırın.",
    "Could not check whether remote '%@' already exists (rclone listremotes did not answer or failed), so nothing was changed. Run `%@ listremotes` to see the error, then try again.":
      "'%@' remote'unun zaten var olup olmadığı denetlenemedi (rclone listremotes yanıt vermedi veya hata verdi); bu yüzden hiçbir şey değiştirilmedi. Hatayı görmek için `%@ listremotes` çalıştırın ve yeniden deneyin.",
    "Could not check whether this Mac already has a CloudMachine installation (rclone did not answer), so no folder was chosen. Try again in a moment.":
      "Bu Mac'te zaten bir CloudMachine kurulumu olup olmadığı denetlenemedi (rclone yanıt vermedi); bu yüzden klasör seçilmedi. Birazdan yeniden deneyin.",
    "rclone authorize failed (%@). If that binary is missing, start with: cloudmachine-agent install-rclone.":
      "rclone authorize başarısız oldu (%@). Bu ikili dosya yoksa şununla başlayın: cloudmachine-agent install-rclone.",
    "Could not read the token from the output of rclone authorize.":
      "rclone authorize çıktısından belirteç okunamadı.",
    "rclone config create failed.":
      "rclone config create başarısız oldu.",
    "Connected to Google Drive as remote '%@', folder %@.":
      "Google Drive'a '%@' remote'u olarak bağlanıldı, klasör %@.",
    "tmutil is not responding - unknown where the backup goes":
      "tmutil yanıt vermiyor - yedeğin nereye gittiği bilinmiyor",
    "No successful backup for %@":
      "%@ süredir başarılı yedek yok",
    "Last COMPLETED backup: %@. The cycle is hourly, so that is %@ missed runs.":
      "Son TAMAMLANAN yedek: %@. Döngü saatlik olduğundan bu %@ atlanan çalıştırma eder.",
    "There is NOT A SINGLE successful backup":
      "Tek bir başarılı yedek bile YOK",
    "The Time Machine preferences contain no date of a completed backup for this destination.":
      "Time Machine tercihlerinde bu hedef için tamamlanmış bir yedeğin tarihi yok.",
    "The last backup attempt did not end in a backup":
      "Son yedekleme denemesi yedekle sonuçlanmadı",
    "The attempt at %@ is newer than the last successful backup at %@.":
      "%@ tarihli deneme, %@ tarihli son başarılı yedekten daha yeni.",
    "Time Machine reports an error in the last run (RESULT=%@)":
      "Time Machine son çalıştırmada hata bildiriyor (RESULT=%@)",
    "A non-zero RESULT in the Time Machine preferences means the run did not succeed.":
      "Time Machine tercihlerinde sıfırdan farklı bir RESULT, çalıştırmanın başarısız olduğu anlamına gelir.",
    "rclone failed to upload %@ files":
      "rclone %@ dosyayı yükleyemedi",
    "Buffer full of nothing but unsent data":
      "Arabellek yalnızca gönderilmemiş verilerle dolu",
    "rclone has nothing left to evict from the buffer - the upload cannot keep up or has stalled.":
      "rclone'un arabellekten çıkaracak bir şeyi kalmadı - yükleme yetişemiyor veya takıldı.",
    "The rclone control interface is not responding":
      "rclone denetim arayüzü yanıt vermiyor",
    "Google Drive is running out of space (%@ GB)":
      "Google Drive'da yer azalıyor (%@ GB)",
    "The Mac's disk is running out of space (%@ GB)":
      "Mac'in diskinde yer azalıyor (%@ GB)",
    "Cannot read the Time Machine preferences":
      "Time Machine tercihleri okunamıyor",
    "%@ is unreadable - most often Full Disk Access is missing. Without this file it is UNKNOWN when the last backup was made, so we treat it as a failure, not as the absence of a problem.":
      "%@ okunamıyor - çoğunlukla Tam Disk Erişimi eksiktir. Bu dosya olmadan son yedeğin ne zaman alındığı BİLİNMİYOR; bu yüzden bunu sorunun yokluğu değil, arıza sayıyoruz.",
    "Cannot measure free space on the Mac's disk":
      "Mac'in diskindeki boş alan ölçülemiyor",
    "%@ days":
      "%@ gün",
    "CloudMachine: backup is not working":
      "CloudMachine: yedekleme çalışmıyor",
    "unknown reason":
      "bilinmeyen neden",
    "osascript did not show the notification (permissions or no graphical session)":
      "osascript bildirimi göstermedi (izinler veya grafik oturumu yok)",
    "UNDELIVERED ALARM: %@":
      "TESLİM EDİLMEYEN UYARI: %@",
    "from %@, reason: %@":
      "%@ kaynaklı, neden: %@",
    "The system notification was not delivered - you will see this alarm ONLY here.":
      "Sistem bildirimi teslim edilmedi - bu uyarıyı YALNIZCA burada göreceksiniz.",
    "%@ (%@ ago)":
      "%@ (%@ önce)",
    "%@ - marker from the FUTURE":
      "%@ - GELECEKTEN işaret",
    "%@ (%@ ago) - THE WATCHDOG MAY NOT BE RUNNING":
      "%@ (%@ önce) - GÖZCÜ ÇALIŞMIYOR OLABİLİR",
    "NEVER - the watchdog has not recorded a single run":
      "HİÇ - gözcü tek bir çalışma bile kaydetmedi",
    "Could not find the launchd/ directory with templates.":
      "Şablonların bulunduğu launchd/ klasörü bulunamadı.",
    "Could not find the compiled cloudmachine-agent binary.":
      "Derlenmiş cloudmachine-agent ikili dosyası bulunamadı.",
    "ABORTED: could not put cloudmachine-agent in a stable location\n(%@) - most often a lack of space or permissions.\nNOT installing agents pointing at %@: that path\ndisappears on the next `swift build` or `git clean`, and backups stop\nwithout any visible signal.":
      "İPTAL EDİLDİ: cloudmachine-agent sabit bir konuma konamadı\n(%@) - çoğunlukla yer veya izin eksikliğinden.\n%@ konumunu gösteren aracılar KURULMUYOR: bu yol\nbir sonraki `swift build` veya `git clean` ile kaybolur ve yedekler\nhiçbir görünür işaret olmadan durur.",
    "ABORTED: %@":
      "İPTAL EDİLDİ: %@",
    "Could not list the templates in %@.":
      "%@ içindeki şablonlar listelenemedi.",
    "could not read the template %@":
      "%@ şablonu okunamadı",
    "could not write %@ (lack of space or permissions)":
      "%@ yazılamadı (yer veya izin eksikliği)",
    "launchctl load refused to load %@":
      "launchctl load, %@ dosyasını yüklemeyi reddetti",
    "NOT A SINGLE agent was loaded.":
      "TEK BİR aracı bile yüklenmedi.",
    "Only these went in: %@.":
      "Yalnızca şunlar kuruldu: %@.",
    "Could not load any launchd agent.":
      "Hiçbir launchd aracısı yüklenemedi.",
    "Installed agents: %@":
      "Kurulan aracılar: %@",
    "                  WARNING: close to the limit - new bands will fail with EMFILE":
      "                  UYARI: sınıra yakın - yeni bantlar EMFILE hatasıyla başarısız olur",
    "%@/bands on Google Drive is not empty - it may hold another backup. NOT overwriting it; check it by hand.":
      "Google Drive'daki %@/bands boş değil - başka bir yedek olabilir. Üzerine YAZILMIYOR; elle denetleyin.",
    "Address:          %@":
      "Adres:            %@",
    "Already prepared (%@ exists) - nothing to do.":
      "Zaten hazırlanmış (%@ var) - yapılacak bir şey yok.",
    "Converts Time Machine's new, empty image in the machine to 32 MB bands and moves the bands to Google Drive.":
      "Makinedeki yeni, boş Time Machine görüntüsünü 32 MB'lık bantlara dönüştürür ve bantları Google Drive'a taşır.",
    "Copy rclone.conf into the machine even if it already has one.":
      "rclone.conf dosyasını makinede zaten olsa bile makineye kopyala.",
    "Copying the converted image into the machine failed: %@":
      "Dönüştürülen görüntü makineye kopyalanamadı: %@",
    "Copying the image to the Mac failed: %@":
      "Görüntü Mac'e kopyalanamadı: %@",
    "Could not ask Lima about the machine: %@":
      "Makine hakkında Lima'ya sorulamadı: %@",
    "Could not carry the Time Machine files over: %@":
      "Time Machine dosyaları aktarılamadı: %@",
    "Could not check the image in the machine.":
      "Makinedeki görüntü denetlenemedi.",
    "Could not copy the rclone configuration into the machine.":
      "rclone yapılandırması makineye kopyalanamadı.",
    "Could not create %@ on Google Drive: %@":
      "Google Drive'da %@ oluşturulamadı: %@",
    "Could not create %@: %@":
      "%@ oluşturulamadı: %@",
    "Could not find the vm/ directory with the machine template.":
      "Makine şablonunun bulunduğu vm/ klasörü bulunamadı.",
    "Could not read the image size.":
      "Görüntü boyutu okunamadı.",
    "Could not set the SMB password of user %@ in the machine.":
      "Makinede %@ kullanıcısının SMB parolası ayarlanamadı.",
    "Could not stop smbd in the machine.":
      "Makinede smbd durdurulamadı.",
    "Could not write %@ in the machine.":
      "Makinede %@ yazılamadı.",
    "Could not write the password file %@.":
      "%@ parola dosyası yazılamadı.",
    "Creates or starts the CloudMachine machine (Lima), gives it rclone's configuration and an SMB password, and prints the Time Machine command.":
      "CloudMachine makinesini (Lima) oluşturur veya başlatır, ona rclone yapılandırmasını ve bir SMB parolası verir ve Time Machine komutunu yazdırır.",
    "Creating the machine %@ (first start downloads Ubuntu and installs packages - several minutes)...":
      "%@ makinesi oluşturuluyor (ilk başlatmada Ubuntu indirilir ve paketler kurulur - birkaç dakika)...",
    "Done: %@ has %@ MB bands on Google Drive; the original is kept in %@ in the machine. Start the backup: tmutil startbackup":
      "Bitti: %@, Google Drive'da %@ MB'lık bantlara sahip; orijinal makinede %@ içinde saklanıyor. Yedeklemeyi başlatın: tmutil startbackup",
    "exit code %@, no message":
      "çıkış kodu %@, ileti yok",
    "Image metadata:   NEVER copied to %@ - check tm-meta-sync in the machine":
      "Görüntü üst verisi: %@ konumuna HİÇ kopyalanmadı - makinedeki tm-meta-sync'i denetleyin",
    "Image metadata:   copied %@ ago to %@":
      "Görüntü üst verisi: %@ önce %@ konumuna kopyalandı",
    "Image metadata:   last copied %@ ago - OVERDUE (%@)":
      "Görüntü üst verisi: en son %@ önce kopyalandı - GECİKMİŞ (%@)",
    "Image metadata:   not copied yet - waits for vm-prepare-bundle":
      "Görüntü üst verisi: henüz kopyalanmadı - vm-prepare-bundle'ı bekliyor",
    "Backup %@, paused by the guard %@: %@":
      "Yedek %@, bekçi tarafından %@ duraklatıldı: %@",
    "Free in machine:  %@ GiB":
      "Makinede boş:     %@ GiB",
    "fsck_apfs -n found problems: %@":
      "fsck_apfs -n sorun buldu: %@",
    "Google Drive folder: %@":
      "Google Drive klasörü: %@",
    "hdiutil attach of the converted image failed: %@":
      "Dönüştürülen görüntünün hdiutil attach işlemi başarısız oldu: %@",
    "hdiutil convert failed: %@":
      "hdiutil convert başarısız oldu: %@",
    "Image name in the machine (default: from the computer name).":
      "Makinedeki görüntünün adı (varsayılan: bilgisayar adından).",
    "Installing the converted image FAILED: %@\nsmbd is left STOPPED so Time Machine does not open a half-installed image. The original is in %@ in the machine.":
      "Dönüştürülen görüntünün kurulumu BAŞARISIZ OLDU: %@\nTime Machine yarım kurulmuş bir görüntüyü açmasın diye smbd DURDURULMUŞ bırakıldı. Orijinal makinede %@ içinde.",
    "limactl create failed: %@":
      "limactl create başarısız oldu: %@",
    "limactl list failed: %@":
      "limactl list başarısız oldu: %@",
    "limactl not found - install Lima: brew install lima":
      "limactl bulunamadı - Lima'yı kurun: brew install lima",
    "limactl start failed: %@\nThe machine's own log: %@":
      "limactl start başarısız oldu: %@\nMakinenin kendi günlüğü: %@",
    "Machine %@ is running.":
      "%@ makinesi çalışıyor.",
    "Machine %@ was already running.":
      "%@ makinesi zaten çalışıyordu.",
    "Machine:          %@ (%@)":
      "Makine:           %@ (%@)",
    "Machine:          %@":
      "Makine:           %@",
    "Machine:          not created - run: cloudmachine-agent vm-setup":
      "Makine:           oluşturulmadı - çalıştırın: cloudmachine-agent vm-setup",
    "no answer within the time limit":
      "süre sınırı içinde yanıt yok",
    "No image %@ in the machine.":
      "Makinede %@ görüntüsü yok.",
    "No image in the machine yet - point Time Machine at the share and let it create one first.":
      "Makinede henüz görüntü yok - önce Time Machine'i paylaşıma yönlendirin ve bir tane oluşturmasına izin verin.",
    "No rclone configuration at %@ - connect Google Drive first (configure-remote).":
      "%@ konumunda rclone yapılandırması yok - önce Google Drive'ı bağlayın (configure-remote).",
    "no SMB destination":
      "SMB hedefi yok",
    "One check of the machine's upload buffer: pauses Time Machine when it fills, resumes what it paused.":
      "Makinenin yükleme arabelleğinin tek bir denetimi: dolduğunda Time Machine'i duraklatır, duraklattığını sürdürür.",
    "Packing the converted image failed: %@":
      "Dönüştürülen görüntü paketlenemedi: %@",
    "Packing the image failed: %@":
      "Görüntü paketlenemedi: %@",
    "No answer from the machine (rclone rc) - the guard would do nothing.":
      "Makineden yanıt yok (rclone rc) - bekçi hiçbir şey yapmazdı.",
    "Only print what the guard would decide - for trying thresholds on a throwaway machine.":
      "Yalnızca bekçinin ne karar vereceğini yazdır - eşikleri atılabilir bir makinede denemek için.",
    "Pause above this many GiB in the buffer.":
      "Arabellekte bu kadar GiB'ın üzerinde duraklat.",
    "Pause when the machine has less free than this, in GiB.":
      "Makinenin boş alanı bundan azsa duraklat, GiB cinsinden.",
    "Point Time Machine at the machine (once, needs an administrator password):":
      "Time Machine'i makineye yönlendirin (bir kez, yönetici parolası gerekir):",
    "punchfs files:    %@ open, limit %@":
      "punchfs dosyaları: %@ açık, sınır %@",
    "rclone configuration already in the machine - kept (--replace-rclone-config replaces it).":
      "rclone yapılandırması makinede zaten var - korundu (--replace-rclone-config onu değiştirir).",
    "rclone configuration copied into the machine.":
      "rclone yapılandırması makineye kopyalandı.",
    "rclone-tm or punchfs is not running in the machine - see cloudmachine-agent vm-status.":
      "rclone-tm veya punchfs makinede çalışmıyor - bkz. cloudmachine-agent vm-status.",
    "Resume below this many GiB (only a backup the guard paused).":
      "Bu kadar GiB'ın altına inince sürdür (yalnızca bekçinin duraklattığı yedeği).",
    "Service %@: %@":
      "Hizmet %@: %@",
    "Several images in the machine (%@) - choose one with --bundle.":
      "Makinede birden çok görüntü var (%@) - --bundle ile birini seçin.",
    "Shows the machine: address, services, upload buffer, free space and the Time Machine destination.":
      "Makineyi gösterir: adres, hizmetler, yükleme arabelleği, boş alan ve Time Machine hedefi.",
    "SMB password stored in %@ (mode 600).":
      "SMB parolası %@ içinde saklandı (izinler 600).",
    "The converted image does not have %@-byte bands.":
      "Dönüştürülen görüntüde %@ baytlık bantlar yok.",
    "The converted image has no APFS partition.":
      "Dönüştürülen görüntüde APFS bölümü yok.",
    "The image already takes %@ MB - this command converts only a new, empty image (under %@ MB).":
      "Görüntü zaten %@ MB yer kaplıyor - bu komut yalnızca yeni, boş bir görüntüyü (%@ MB altı) dönüştürür.",
    "The image is encrypted - converting encrypted images is not supported.":
      "Görüntü şifreli - şifreli görüntüleri dönüştürme desteklenmiyor.",
    "The image was not changed; smbd started again.":
      "Görüntü değiştirilmedi; smbd yeniden başlatıldı.",
    "The machine does not answer - is it running? cloudmachine-agent vm-status":
      "Makine yanıt vermiyor - çalışıyor mu? cloudmachine-agent vm-status",
    "The machine has no address on the vzNAT network.":
      "Makinenin vzNAT ağında adresi yok.",
    "The services in the machine did not start - check: cloudmachine-agent vm-status":
      "Makinedeki hizmetler başlamadı - denetleyin: cloudmachine-agent vm-status",
    "Time Machine is backing up - stop it first: tmutil stopbackup":
      "Time Machine yedekliyor - önce durdurun: tmutil stopbackup",
    "Time Machine:     %@":
      "Time Machine:     %@",
    "Time Machine:     NOT pointing at the machine (%@)":
      "Time Machine:     makineyi GÖSTERMİYOR (%@)",
    "Time Machine:     tmutil did not answer":
      "Time Machine:     tmutil yanıt vermedi",
    "tmutil did not answer - not touching the image while its state is unknown.":
      "tmutil yanıt vermedi - durumu bilinmeyen görüntüye dokunulmuyor.",
    "unknown":
      "bilinmiyor",
    "Unpacking the image failed: %@":
      "Görüntü açılamadı: %@",
    "Still to upload:  %@ GiB in %@ bands, uploading %@ (cache on disk %@ GiB)":
      "Yüklenecek kalan: %@ GiB, %@ bantta, yüklenen %@ (diskteki önbellek %@ GiB)",
    "Excluded %@ (the machine and its upload buffer) from Time Machine.":
      "%@ (makine ve yükleme arabelleği) Time Machine'den hariç tutuldu.",
    "WARNING: could not exclude %@ from Time Machine - run: tmutil addexclusion %@":
      "UYARI: %@ Time Machine'den hariç tutulamadı - çalıştırın: tmutil addexclusion %@",
    "Upload buffer:    no answer from rclone (rc %@)":
      "Yükleme arabelleği: rclone'dan yanıt yok (rc %@)",
    "When Time Machine has created its empty image, stop the backup (tmutil stopbackup) and run: cloudmachine-agent vm-prepare-bundle":
      "Time Machine boş görüntüsünü oluşturunca yedeklemeyi durdurun (tmutil stopbackup) ve şunu çalıştırın: cloudmachine-agent vm-prepare-bundle",
    "Unsent %@ GiB, free %@ GiB (pause above %@ GiB unsent or below %@ GiB free, resume below %@ GiB).":
      "Gönderilmemiş %@ GiB, boş %@ GiB (%@ GiB gönderilmemişin üzerinde veya %@ GiB boşun altında duraklat, %@ GiB altında sürdür).",
    "Upload:           Google's daily limit refused an upload %@ ago - rclone retries every 5 min and resumes by itself":
      "Yükleme:          Google'ın günlük sınırı %@ önce bir yüklemeyi reddetti - rclone 5 dakikada bir yeniden dener ve kendiliğinden sürdürür",
    "no":
      "hayır",
    "running":
      "sürüyor",
    "stopped":
      "durduruldu",
    "yes":
      "evet",
    "%@\nThe previous template is in %@ - copy it back over lima.yaml and run limactl start %@.":
      "%@\nÖnceki şablon %@ içinde - onu lima.yaml üzerine geri kopyalayın ve limactl start %@ çalıştırın.",
    "Could not read this app's machine template (limactl template copy).":
      "Bu uygulamanın makine şablonu okunamadı (limactl template copy).",
    "Could not replace %@: %@":
      "%@ değiştirilemedi: %@",
    "Machine %@ already runs this app's template.":
      "%@ makinesi zaten bu uygulamanın şablonuyla çalışıyor.",
    "Machine %@ now runs this app's template; the previous one is in %@.":
      "%@ makinesi artık bu uygulamanın şablonuyla çalışıyor; öncekisi %@ içinde.",
    "Moves the machine onto this app's template (two restarts, never during a backup).":
      "Makineyi bu uygulamanın şablonuna taşır (iki yeniden başlatma, asla yedekleme sırasında değil).",
    "No machine %@ - create it with: cloudmachine-agent vm-setup":
      "%@ makinesi yok - oluşturun: cloudmachine-agent vm-setup",
    "Template:         OLDER than this app's - run: cloudmachine-agent vm-update":
      "Şablon:           bu uygulamanınkinden ESKİ - çalıştırın: cloudmachine-agent vm-update",
    "Template:         not compared":
      "Şablon:           karşılaştırılmadı",
    "Template:         this app's":
      "Şablon:           bu uygulamanınki",
    "The machine has no %@ - run cloudmachine-agent vm-setup first.":
      "Makinede %@ yok - önce cloudmachine-agent vm-setup çalıştırın.",
    "The machine restarted, but not every service is running - check: cloudmachine-agent vm-status. The previous template is in %@.":
      "Makine yeniden başladı ama tüm hizmetler çalışmıyor - denetleyin: cloudmachine-agent vm-status. Önceki şablon %@ içinde.",
    "The template changes the machine itself (%@) - that needs a new machine, not an update.":
      "Şablon makinenin kendisini değiştiriyor (%@) - bu güncelleme değil, yeni bir makine gerektirir.",
    "The upload to Google Drive hangs":
      "Google Drive'a yükleme takıldı",
    "Time Machine is backing up - try again when it has finished.":
      "Time Machine yedekliyor - bitince yeniden deneyin.",
    "Upload:           HANGS - bands in progress, none uploaded for %@ (network?); see /var/log/rclone-tm.log in the machine":
      "Yükleme:          TAKILDI - bantlar sürüyor, %@ süredir hiçbiri yüklenmedi (ağ?); makinedeki /var/log/rclone-tm.log dosyasına bakın",
    "limactl stop failed - nothing was changed.":
      "limactl stop başarısız oldu - hiçbir şey değiştirilmedi.",
    "rclone has bands in progress, but none has been uploaded for %@ - usually a broken network connection, which rclone does not report as an error. Backups since then are only in the machine's buffer. When the network comes back the upload resumes by itself (on 28.10.2026 within 80 s); if it does not, restarting the machine (prepare-shutdown, limactl start) drops the dead connections.":
      "rclone'da süren bantlar var ama %@ süredir hiçbiri yüklenmedi - genellikle rclone'un hata olarak bildirmediği kopuk bir ağ bağlantısıdır. O zamandan beri alınan yedekler yalnızca makinenin arabelleğinde. Ağ geri gelince yükleme kendiliğinden sürer (28.10.2026'da 80 s içinde); sürmezse makineyi yeniden başlatmak (prepare-shutdown, limactl start) ölü bağlantıları koparır.",
    "tmutil did not answer - not restarting the machine while its state is unknown.":
      "tmutil yanıt vermedi - durumu bilinmeyen makine yeniden başlatılmıyor.",
    "The machine's share cannot be read":
      "Makinenin paylaşımı okunamıyor",
    "Unknown whether the machine's share can be read":
      "Makinenin paylaşımının okunup okunamadığı bilinmiyor",
    "Samba in the machine does not answer this Mac":
      "Makinedeki Samba bu Mac'e yanıt vermiyor",
    "Unknown whether Samba in the machine answers this Mac":
      "Makinedeki Samba'nın bu Mac'e yanıt verip vermediği bilinmiyor",
    "Reading 1 byte of %@ in the machine failed: %@. Every service says it is active, yet Time Machine cannot use the image there. Nothing restarts it by itself. Check: cloudmachine-agent vm-status, then in the machine: journalctl -u punchfs -u tm-bands-bind -u rclone-tm":
      "Makinede %@ dosyasından 1 bayt okunamadı: %@. Her hizmet etkin olduğunu söylüyor, ancak Time Machine oradaki imajı kullanamıyor. Hiçbir şey bunu kendiliğinden yeniden başlatmaz. Kontrol edin: cloudmachine-agent vm-status, ardından makinede: journalctl -u punchfs -u tm-bands-bind -u rclone-tm",
    "Reading 1 byte of %@ in the machine has not returned for %@ s. That is how a hung punchfs or rclone mount behaves. Nothing is restarted while the state is unknown - a restart under a write still going could lose it. Check in the machine: journalctl -u punchfs -u rclone-tm":
      "Makinede %@ dosyasından 1 bayt okuma %@ sn'dir dönmedi. Takılmış bir punchfs veya rclone bağlaması böyle davranır. Durum bilinmezken hiçbir şey yeniden başlatılmaz - süren bir yazma sırasında yeniden başlatmak onu kaybettirebilir. Makinede kontrol edin: journalctl -u punchfs -u rclone-tm",
    "An SMB connection to %@ got no answer within %@ s. Time Machine reaches the machine at this address. Check the machine's network and smbd: cloudmachine-agent vm-status":
      "%@ adresine SMB bağlantısı %@ sn içinde yanıt almadı. Time Machine makineye bu adresten ulaşır. Makinenin ağını ve smbd'yi kontrol edin: cloudmachine-agent vm-status",
    "The machine did not report its address, so nobody could try an SMB connection. Check: cloudmachine-agent vm-status":
      "Makine adresini bildirmedi, bu yüzden kimse SMB bağlantısı deneyemedi. Kontrol edin: cloudmachine-agent vm-status",
    "An SMB connection to %@ failed (%@). Time Machine reaches the machine at this address, so no backup is made. Check the machine's network and smbd: cloudmachine-agent vm-status":
      "%@ adresine SMB bağlantısı başarısız oldu (%@). Time Machine makineye bu adresten ulaşır, bu yüzden yedek alınmıyor. Makinenin ağını ve smbd'yi kontrol edin: cloudmachine-agent vm-status",
    "readable":
      "okunabilir",
    "no image yet":
      "henüz imaj yok",
    "answers":
      "yanıt veriyor",
    "Share read:       %@":
      "Paylaşım okuma:   %@",
    "Samba from Mac:   %@":
      "Mac'ten Samba:    %@",
    "This Mac found no route to %@ (%@). Either the route to the machine is gone, or macOS Local Network privacy has not allowed CloudMachine - then allow it in System Settings > Privacy & Security > Local Network. Check: cloudmachine-agent vm-status":
      "Bu Mac %@ için yol bulamadı (%@). Ya makineye giden yol yok oldu ya da macOS'in Yerel Ağ gizliliği CloudMachine'e izin vermedi - bu durumda Sistem Ayarları > Gizlilik ve Güvenlik > Yerel Ağ bölümünden izin verin. Kontrol edin: cloudmachine-agent vm-status",
  ]
}
