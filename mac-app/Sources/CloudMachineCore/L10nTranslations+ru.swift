// Russian translations, keyed by the English text passed to `L10n.tr`.
extension L10nTranslations {
  static let ru: [String: String] = [
    "Space limit:      %@":
      "Лимит места:      %@",
    "                  Time Machine quota not set to match - run: %@":
      "                  Квота Time Machine не соответствует - выполните: %@",
    "Sets how much of Google Drive this Mac may use, and prints the Time Machine quota command.":
      "Задаёт, сколько места на Google Drive может занять этот Mac, и выводит команду для квоты Time Machine.",
    "Limit in GB.":
      "Лимит в GB.",
    "Limit for this Mac: %@ GB.":
      "Лимит для этого Mac: %@ GB.",
    "Now set the Time Machine quota (needs an administrator password):":
      "Теперь задайте квоту Time Machine (потребуется пароль администратора):",
    "CloudMachine - verification, Google Drive setup and installation. Called by launchd on a schedule, or by hand from Terminal.":
      "CloudMachine - проверка, настройка Google Drive и установка. Вызывается launchd по расписанию или вручную из Терминала.",
    "Connects to Google Drive through rclone (OAuth in the browser) and creates this machine's folder.":
      "Подключается к Google Drive через rclone (OAuth в браузере) и создаёт папку этой машины.",
    "Overwrite the existing remote. RISKY: replaces the token and permissions.":
      "Перезаписать существующий remote. РИСКОВАННО: заменяет токен и права доступа.",
    "Packs build/CloudMachine.app into build/CloudMachine-<version>.dmg.":
      "Упаковывает build/CloudMachine.app в build/CloudMachine-<версия>.dmg.",
    "ERROR: %@ is missing - run 'cloudmachine-agent build-app' first":
      "ОШИБКА: %@ отсутствует - сначала выполните 'cloudmachine-agent build-app'",
    "==> Preparing the staging folder":
      "==> Подготавливаю папку staging",
    "==> Creating %@":
      "==> Создаю %@",
    "ERROR: hdiutil exited with code %@.":
      "ОШИБКА: hdiutil завершился с кодом %@.",
    "==> Done: %@":
      "==> Готово: %@",
    "On first launch (the app is not signed with an Apple Developer account):":
      "При первом запуске (приложение не подписано учётной записью Apple Developer):",
    "1. Open %@ and drag CloudMachine.app to Applications.":
      "1. Откройте %@ и перетащите CloudMachine.app в «Программы».",
    "2. In Finder, RIGHT-click CloudMachine.app -> Open -> Open\n   (a plain double-click shows the Gatekeeper block \"unidentified developer\").":
      "2. В Finder щёлкните CloudMachine.app ПРАВОЙ кнопкой -> Открыть -> Открыть\n   (обычный двойной щелчок покажет блокировку Gatekeeper «неопознанный разработчик»).",
    "3. Later launches work normally, with a double-click.":
      "3. Последующие запуски работают как обычно, двойным щелчком.",
    "Builds CloudMachine.app (Release) - GUI + cloudmachine-agent in Contents/MacOS/, plus launchd/, vm/ and config/ as Resources.":
      "Собирает CloudMachine.app (Release) - GUI + cloudmachine-agent в Contents/MacOS/, плюс launchd/, vm/ и config/ как Resources.",
    "Binaries for Apple Silicon and Intel at once (how CI builds a release; unnecessary locally).":
      "Бинарные файлы сразу для Apple Silicon и Intel (так CI собирает релиз; локально не нужно).",
    "==> Building CloudMachineApp + cloudmachine-agent (release) - version %@ (%@)":
      "==> Собираю CloudMachineApp + cloudmachine-agent (release) - версия %@ (%@)",
    "ERROR: swift build exited with code %@.":
      "ОШИБКА: swift build завершился с кодом %@.",
    "ERROR: swift build --show-bin-path did not report the binaries directory.":
      "ОШИБКА: swift build --show-bin-path не вернул каталог с бинарными файлами.",
    "ERROR: no built binary found at %@":
      "ОШИБКА: собранный бинарный файл не найден: %@",
    "==> Assembling the .app bundle in %@":
      "==> Собираю пакет .app в %@",
    "==> WARNING: you are building from a DIRTY tree - the version will not point to a commit.":
      "==> ВНИМАНИЕ: сборка выполняется из ГРЯЗНОГО дерева - версия не будет указывать на коммит.",
    "ERROR: Resources/AppIcon.icns is missing - generate it: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns":
      "ОШИБКА: Resources/AppIcon.icns отсутствует - создайте его: swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset && iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns",
    "==> Signing with the local certificate '%@' (Full Disk Access will survive later rebuilds)":
      "==> Подписываю локальным сертификатом '%@' (Полный доступ к диску сохранится после следующих пересборок)",
    "==> Signing ad-hoc (no Apple Developer account) - run 'cloudmachine-agent setup-signing-cert' once so that TCC permissions survive later rebuilds":
      "==> Подписываю ad-hoc (без учётной записи Apple Developer) - выполните один раз 'cloudmachine-agent setup-signing-cert', чтобы разрешения TCC сохранялись после следующих пересборок",
    "ERROR: codesign exited with code %@.":
      "ОШИБКА: codesign завершился с кодом %@.",
    "Next step: %@":
      "Следующий шаг: %@",
    "Creates a local self-signed certificate so that Full Disk Access survives later rebuilds of the app.":
      "Создаёт локальный самоподписанный сертификат, чтобы Полный доступ к диску сохранялся после следующих пересборок приложения.",
    "Certificate '%@' already exists in %@, nothing to do.":
      "Сертификат '%@' уже есть в %@, делать нечего.",
    "==> Generating the key and self-signed certificate '%@'...":
      "==> Создаю ключ и самоподписанный сертификат '%@'...",
    "ERROR: openssl req exited with code %@.":
      "ОШИБКА: openssl req завершился с кодом %@.",
    "ERROR: openssl pkcs12 exited with code %@.":
      "ОШИБКА: openssl pkcs12 завершился с кодом %@.",
    "==> Importing the certificate into %@ (pre-authorizing /usr/bin/codesign, so it does not ask for the keychain password every time)...":
      "==> Импортирую сертификат в %@ (заранее разрешаю /usr/bin/codesign, чтобы пароль связки ключей не запрашивался каждый раз)...",
    "ERROR: security import exited with code %@.":
      "ОШИБКА: security import завершился с кодом %@.",
    "==> Trusting the certificate ONLY for code signing...":
      "==> Доверяю сертификату ТОЛЬКО для подписи кода...",
    "ERROR: security add-trusted-cert exited with code %@.":
      "ОШИБКА: security add-trusted-cert завершился с кодом %@.",
    "Done. Certificate '%@' is now available to codesign.":
      "Готово. Сертификат '%@' теперь доступен для codesign.",
    "The next 'cloudmachine-agent build-app' will use it automatically instead of an ad-hoc signature.":
      "Следующая команда 'cloudmachine-agent build-app' автоматически использует его вместо подписи ad-hoc.",
    "After THAT ONE rebuild, grant Full Disk Access one last time - later\nrebuilds will no longer reset it, as long as you sign with the same certificate.":
      "После ЭТОЙ ОДНОЙ пересборки ещё раз выдайте Полный доступ к диску - последующие\nпересборки его больше не сбросят, пока вы подписываете тем же сертификатом.",
    "Checks whether the hourly cycle STILL works (date of the last SUCCESSFUL backup) and reports failures.":
      "Проверяет, РАБОТАЕТ ли ещё ежечасный цикл (дата последней УСПЕШНОЙ копии), и сообщает о сбоях.",
    "After this many hours without a successful backup we consider the cycle broken.":
      "Через столько часов без успешной копии цикл считается нарушенным.",
    "Only print the state, without a system notification.":
      "Только вывести состояние, без системного уведомления.",
    "A different Time Machine preferences file - to test the watchdog on a known sample.":
      "Другой файл настроек Time Machine - чтобы проверить наблюдателя на известном образце.",
    "Last successful backup: %@":
      "Последняя успешная копия: %@",
    "Last successful backup: NONE":
      "Последняя успешная копия: НЕТ",
    "Last attempt:           %@":
      "Последняя попытка:       %@",
    "WAITING (system startup): %@":
      "ОЖИДАНИЕ (запуск системы): %@",
    "Backup cycle: OK":
      "Цикл копирования: OK",
    "FAILURE: %@":
      "СБОЙ: %@",
    "         %@":
      "         %@",
    "Check the state:  %@":
      "Проверить состояние:  %@",
    "Preparing for restart":
      "Подготовка к перезагрузке",
    "Prepare for restart":
      "Подготовить к перезагрузке",
    "Prepare":
      "Подготовить",
    "==> WARNING: git rev-list failed (%@) - using the date as the build number.":
      "==> ВНИМАНИЕ: git rev-list завершился с ошибкой (%@) - в качестве номера сборки используется дата.",
    "Agents:           %@":
      "Агенты:           %@",
    "CANNOT START: %@ - open CloudMachine or run backup-health to reload them":
      "НЕ ЗАПУСКАЮТСЯ: %@ - откройте CloudMachine или выполните backup-health, чтобы перезагрузить их",
    "Reloaded agents that could not start: %@":
      "Перезагружены агенты, которые не смогли запуститься: %@",
    "Drive folder:     %@":
      "Папка на Drive:   %@",
    "Name of this Mac's folder on Google Drive (default: derived from the computer name). Set once; it cannot be changed later.":
      "Имя папки этого Mac на Google Drive (по умолчанию берётся из имени компьютера). Задаётся один раз; позже изменить нельзя.",
    "Backup watchdog:  %@":
      "Наблюдатель:      %@",
    "Prints the version, the build number and the commit this binary was built from.":
      "Выводит версию, номер сборки и коммит, из которого собран этот бинарный файл.",
    "Only one line, without a description.":
      "Только одна строка, без описания.",
    "Build from the working tree (outside a bundle) - no version data.":
      "Сборка из рабочего дерева (вне пакета) - данных о версии нет.",
    "Version: %@":
      "Версия:  %@",
    "Build:   %@":
      "Сборка:  %@",
    "Commit:  %@":
      "Коммит:  %@",
    "WARNING: built from a DIRTY tree - the binary contains code that\n         is in no commit. The commit number does NOT describe\n         what actually runs.":
      "ВНИМАНИЕ: собрано из ГРЯЗНОГО дерева - в бинарном файле есть код,\n          которого нет ни в одном коммите. Номер коммита НЕ описывает\n          то, что действительно работает.",
    "Saving the space limit":
      "Сохраняю лимит места",
    "Measuring usage on Google Drive":
      "Измеряю занятое место на Google Drive",
    "Google Drive did not answer - try again later.":
      "Google Drive не ответил - повторите попытку позже.",
    "Measured.":
      "Измерено.",
    "Space limit for this Mac":
      "Лимит места для этого Mac",
    "Used on Google Drive":
      "Занято на Google Drive",
    "Measured %@. The watchdog measures again every few hours.":
      "Измерено: %@. Наблюдатель измеряет повторно каждые несколько часов.",
    "Limit (GB)":
      "Лимит (GB)",
    "Save":
      "Сохранить",
    "Measure now":
      "Измерить сейчас",
    "Time Machine quota: %@ GB (70%% of the limit - the copy on Drive is about a third larger than the backup inside it). Time Machine deletes the oldest backups to stay within it.":
      "Квота Time Machine: %@ GB (70%% от лимита - копия на Drive примерно на треть больше резервной копии внутри неё). Time Machine удаляет самые старые копии, чтобы уложиться в неё.",
    "Set the Time Machine quota: run this in Terminal (needs sudo)":
      "Задать квоту Time Machine: выполните это в Терминале (нужен sudo)",
    "Connect Google Drive: run this in Terminal and approve in the browser":
      "Подключить Google Drive: выполните это в Терминале и подтвердите в браузере",
    "Grant Full Disk Access to CloudMachine, so it can tell whether backups complete":
      "Предоставьте CloudMachine Полный доступ к диску, чтобы он мог определять, завершаются ли копии",
    "Folder on Google Drive":
      "Папка на Google Drive",
    "One folder per Mac. Set once - it cannot be changed after connecting.":
      "Одна папка на каждый Mac. Задаётся один раз - после подключения изменить нельзя.",
    "Use lowercase letters, digits and dashes.":
      "Используйте строчные латинские буквы, цифры и дефисы.",
    "Install rclone":
      "Установить rclone",
    "Open System Settings":
      "Открыть Системные настройки",
    "Install agents":
      "Установить агентов",
    "not checked":
      "не проверено",
    "none at all":
      "нет ни одной",
    "%@ ago":
      "%@ назад",
    "Missing: %@":
      "Не хватает: %@",
    "Google Drive not connected":
      "Google Drive не подключён",
    "Time Machine does not point to CloudMachine":
      "Time Machine не указывает на CloudMachine",
    "UNKNOWN whether Time Machine points to CloudMachine - tmutil did not answer":
      "НЕИЗВЕСТНО, указывает ли Time Machine на CloudMachine - tmutil не ответил",
    "Backup in progress":
      "Идёт копирование",
    "Unknown when the last backup was made":
      "Неизвестно, когда была сделана последняя копия",
    "There is no completed backup at all":
      "Нет ни одной завершённой копии",
    "No completed backup for %@":
      "Нет завершённой копии уже %@",
    "Ready":
      "Готово",
    "Not saved: %@":
      "Не сохранено: %@",
    "Installing rclone":
      "Устанавливаю rclone",
    "Installing launchd agents":
      "Устанавливаю агентов launchd",
    "Starting backup":
      "Запускаю копирование",
    "Backup started.":
      "Копирование запущено.",
    "Could not start the backup.":
      "Не удалось запустить копирование.",
    "Stopping backup":
      "Останавливаю копирование",
    "Backup stopped.":
      "Копирование остановлено.",
    "Could not stop the backup.":
      "Не удалось остановить копирование.",
    "Could not prepare the AppleScript.":
      "Не удалось подготовить AppleScript.",
    "Unknown authorization error.":
      "Неизвестная ошибка авторизации.",
    "Waiting to upload":
      "Ожидает отправки",
    "%@ files":
      "Файлов: %@",
    "nothing":
      "ничего",
    "Back up now":
      "Копировать сейчас",
    "Stop backup":
      "Остановить копирование",
    "Open CloudMachine":
      "Открыть CloudMachine",
    "Quit":
      "Завершить",
    "Healthy":
      "Исправно",
    "Attention":
      "Внимание",
    "Refreshed %@":
      "Обновлено %@",
    "System Status":
      "Состояние системы",
    "Action needed":
      "Требуется действие",
    "not measured":
      "не измерено",
    "rclone did not answer":
      "rclone не ответил",
    "Backup in Progress":
      "Идёт копирование",
    "Files processed":
      "Обработано файлов",
    "Write speed":
      "Скорость записи",
    "Operation phase":
      "Фаза операции",
    "Required Setup Steps":
      "Обязательные шаги настройки",
    "Copy":
      "Скопировать",
    "Last completed backup":
      "Последняя завершённая копия",
    "Last backup watchdog run":
      "Последний запуск наблюдателя",
    "not read":
      "не прочитано",
    "Everything uploaded":
      "Всё отправлено",
    "File upload errors":
      "Ошибки отправки файлов",
    "Google Drive Credentials (OAuth 2.0)":
      "Учётные данные Google Drive (OAuth 2.0)",
    "Keychain OK":
      "Связка ключей: OK",
    "No custom keys":
      "Своих ключей нет",
    "Paste client_id...":
      "Вставьте client_id...",
    "Paste client_secret...":
      "Вставьте client_secret...",
    "Save securely in the Keychain":
      "Надёжно сохранить в Связке ключей",
    "Refresh":
      "Обновить",
    "Overview":
      "Обзор",
    "Backups":
      "Копии",
    "Storage":
      "Место",
    "Settings":
      "Настройки",
    "Current status: %@":
      "Текущее состояние: %@",
    "Does not point to CloudMachine":
      "Не указывает на CloudMachine",
    "tmutil did not answer":
      "tmutil не ответил",
    "Backing up: %@ of %@":
      "Копирование: %@ из %@",
    "%@ of %@":
      "%@ из %@",
    "Copied":
      "Скопировано",
    "No backup is running":
      "Копирование сейчас не идёт",
    "Time Machine starts the next one on its own schedule.":
      "Time Machine запустит следующее по собственному расписанию.",
    "Backup cycle":
      "Цикл копирования",
    "%@ GiB":
      "%@ GiB",
    "%@ GiB in %@ bands, %@ uploading":
      "%@ GiB, полос: %@, отправляется: %@",
    "%@ bands":
      "Полос: %@",
    "%@ fragments abandoned - only in the machine":
      "Брошено фрагментов: %@ - они только в машине",
    "127.0.0.1:5572 answers on the Mac: Lima forwards the machine's rclone remote control, which has no password. Any web page open in a browser can send it commands - including deleting the backup on Google Drive. Add the portForwards rule from vm/cmsmb.yaml to the machine and restart it (see vm/README.md).":
      "127.0.0.1:5572 отвечает на Mac: Lima пробрасывает удалённое управление rclone из машины, которое не защищено паролем. Любая веб-страница, открытая в браузере, может отправить ему команды - в том числе удалить копию на Google Drive. Добавьте в машину правило portForwards из vm/cmsmb.yaml и перезапустите её (см. vm/README.md).",
    "A service in the CloudMachine machine is not running":
      "Служба в машине CloudMachine не работает",
    "Address":
      "Адрес",
    "Agent installation INCOMPLETE - %@ of %@ did not go in:\n%@\n%@\nEvery missing agent is a function that has silently stopped working (vm-guard watches the machine's buffer, backup-health reports failures). Fix the cause and repeat the installation.":
      "Установка агентов НЕПОЛНАЯ - не установлено %@ из %@:\n%@\n%@\nКаждый отсутствующий агент - это функция, которая тихо перестала работать (vm-guard следит за буфером машины, backup-health сообщает о сбоях). Устраните причину и повторите установку.",
    "All running":
      "Все работают",
    "Also install the launchd agents (same as install-launchd).":
      "Также установить агентов launchd (то же, что install-launchd).",
    "At most this many minutes of waiting for the upload.":
      "Ждать отправку не более стольких минут.",
    "At the limit every new band fails with EMFILE and the backup stops. Check: cloudmachine-agent vm-status":
      "При достижении лимита каждая новая полоса завершается ошибкой EMFILE, и копирование останавливается. Проверьте: cloudmachine-agent vm-status",
    "Cache on the machine's disk":
      "Кэш на диске машины",
    "Connected to Google Drive, but could not create the folder '%@' - without it the machine has nowhere to keep the backup. Check the account permissions and try again.":
      "Подключение к Google Drive выполнено, но создать папку '%@' не удалось - без неё машине негде хранить копию. Проверьте права учётной записи и повторите попытку.",
    "Convert the image":
      "Преобразовать образ",
    "Converting the image to 32 MB bands":
      "Преобразование образа в полосы по 32 MB",
    "Could not check with the current connection whether the backup is on Google Drive (%@), so remote '%@' was NOT replaced: without that answer the new sign-in cannot be checked against it.":
      "Текущим подключением не удалось проверить, есть ли копия на Google Drive (%@), поэтому remote '%@' НЕ заменён: без этого ответа новый вход нельзя с ней сверить.",
    "Downloads the official rclone binary into ~/.cloudmachine/bin (Google sign-in and the machine's rclone.conf).":
      "Скачивает официальный бинарный файл rclone в ~/.cloudmachine/bin (вход в Google и rclone.conf машины).",
    "Free in the machine":
      "Свободно в машине",
    "Free in the machine: %@":
      "Свободно в машине: %@",
    "Generates and installs the launchd agents (app, backup watchdog, machine start, machine guard).":
      "Создаёт и устанавливает агентов launchd (приложение, наблюдатель копий, запуск машины, страж машины).",
    "Install Lima, which runs the CloudMachine machine: run this in Terminal":
      "Установите Lima, которая запускает машину CloudMachine: выполните это в Терминале",
    "Install rclone (signs in to Google Drive for the machine)":
      "Установите rclone (выполняет вход машины в Google Drive)",
    "Install the background agents (machine start, buffer guard, backup watchdog)":
      "Установите фоновых агентов (запуск машины, страж буфера, наблюдатель копий)",
    "Installs rclone through Homebrew - CloudMachine itself uses the one from install-rclone.":
      "Устанавливает rclone через Homebrew - сам CloudMachine использует тот, что из install-rclone.",
    "Info.plist, token and mapped/ of the backup image exist only on the machine's disk; without them the bands in %@ cannot be restored. The copy (tm-meta-sync, every 15 min) goes to %@. Check: cloudmachine-agent vm-status, then in the machine: journalctl -u tm-meta-sync":
      "Info.plist, token и mapped/ образа копии есть только на диске машины; без них полосы в %@ восстановить нельзя. Копия (tm-meta-sync, каждые 15 мин) отправляется в %@. Проверьте: cloudmachine-agent vm-status, затем в машине: journalctl -u tm-meta-sync",
    "Lima says the machine is running, but a command in it did not return. Without it nothing is known about Samba, rclone or the upload. Check: cloudmachine-agent vm-status":
      "Lima сообщает, что машина работает, но команда в ней не вернула результат. Без этого ничего не известно о Samba, rclone и отправке. Проверьте: cloudmachine-agent vm-status",
    "Machine":
      "Машина",
    "Machine %@":
      "Машина %@",
    "Machine & Upload Status":
      "Состояние машины и отправки",
    "Machine buffer":
      "Буфер машины",
    "No Time Machine destination is the machine's share (smb://tm@<address>/CloudMachine) - backups are not being made there. The command is printed by: cloudmachine-agent vm-setup":
      "Ни одно место назначения Time Machine не является общим ресурсом машины (smb://tm@<адрес>/CloudMachine) - копии туда не делаются. Команду выводит: cloudmachine-agent vm-setup",
    "Not running: %@":
      "Не работает: %@",
    "Not set up":
      "Не настроена",
    "Once it runs out, rclone stops uploading, the machine's buffer fills up and backups stop being made. At a growth of ~600 MB per hourly cycle that is about %@ days.":
      "Когда он закончится, rclone перестанет отправлять данные, буфер машины заполнится, и копии перестанут создаваться. При приросте ~600 MB за часовой цикл это около %@ дн.",
    "Or rclone.conf is missing: this Mac has already set up the CloudMachine machine, so it is not connected anew blindly. Restore the file from a backup (the machine keeps its own copy in %@). To connect anyway, create an empty file at the path `%@ config file` prints and run again - the existing folder is kept.":
      "Либо отсутствует rclone.conf: на этом Mac машина CloudMachine уже настроена, поэтому вслепую заново не подключается. Восстановите файл из копии (машина хранит собственную копию в %@). Чтобы всё же подключиться, создайте пустой файл по пути, который выводит `%@ config file`, и запустите снова - существующая папка сохранится.",
    "Point Time Machine at the machine: run this in Terminal (needs sudo; Copy includes the password)":
      "Укажите Time Machine машину: выполните это в Терминале (нужен sudo; «Скопировать» включает пароль)",
    "Points to the machine":
      "Указывает на машину",
    "Prepares for a restart: stops the backup, waits a while for the upload, then stops the machine cleanly.":
      "Готовит к перезагрузке: останавливает копирование, немного ждёт отправку, затем корректно останавливает машину.",
    "Reading the Time Machine destination did not return within %@ s. That is how tmutil behaves when its destination hangs.":
      "Чтение места назначения Time Machine не завершилось за %@ s. Так tmutil ведёт себя, когда его место назначения зависло.",
    "Remote '%@' was NOT replaced. The new sign-in gets the 'drive.file' scope, which sees only files created under its own client_id. The existing backup was most likely created by the current connection and would become invisible to it. Before anything is written, the new token is checked against the existing backup, and the replacement is abandoned if it cannot see it. The machine keeps its own copy of the configuration until vm-setup --replace-rclone-config. To go ahead, run again with --replace-existing --accept-scope-change.":
      "Remote '%@' НЕ заменён. Новый вход получает область 'drive.file', которая видит только файлы, созданные под собственным client_id. Существующая копия, скорее всего, создана текущим подключением и стала бы для него невидимой. Прежде чем что-либо записать, новый токен проверяется на существующей копии, и замена отменяется, если он её не видит. Машина хранит собственную копию конфигурации до vm-setup --replace-rclone-config. Чтобы продолжить, запустите снова с --replace-existing --accept-scope-change.",
    "Remote control:   OPEN on the Mac at 127.0.0.1:5572 - any web page can send rclone commands; see vm/README.md (portForwards)":
      "Удалённое управление: ОТКРЫТО на Mac по адресу 127.0.0.1:5572 - любая страница может отправлять команды rclone; см. vm/README.md (portForwards)",
    "Running":
      "Работает",
    "Samba, rclone or punchfs in the machine is not active, so Time Machine has nowhere to write or the bands do not reach Google Drive. Check: cloudmachine-agent vm-status":
      "Samba, rclone или punchfs в машине не активны, поэтому Time Machine некуда писать либо полосы не попадают на Google Drive. Проверьте: cloudmachine-agent vm-status",
    "Service %@":
      "Служба %@",
    "Services":
      "Службы",
    "Set up the CloudMachine machine (the first time it downloads Ubuntu - several minutes)":
      "Настройте машину CloudMachine (при первом запуске скачивается Ubuntu - несколько минут)",
    "Set up the CloudMachine machine again, so it prints the Time Machine command":
      "Настройте машину CloudMachine заново, чтобы она вывела команду для Time Machine",
    "Set up the machine":
      "Настроить машину",
    "Setting up the CloudMachine machine":
      "Настройка машины CloudMachine",
    "Start the CloudMachine machine":
      "Запустите машину CloudMachine",
    "Start the machine":
      "Запустить машину",
    "Starting the CloudMachine machine":
      "Запуск машины CloudMachine",
    "Still to upload: %@ GiB":
      "Осталось отправить: %@ GiB",
    "Stopping the Time Machine backup...":
      "Остановка копирования Time Machine...",
    "Stopping the machine %@...":
      "Остановка машины %@...",
    "The CloudMachine machine does not answer":
      "Машина CloudMachine не отвечает",
    "The CloudMachine machine is not running":
      "Машина CloudMachine не работает",
    "The CloudMachine machine is not set up yet":
      "Машина CloudMachine ещё не настроена",
    "The CloudMachine machine is stopped":
      "Машина CloudMachine остановлена",
    "The backup is stopped, the upload gets up to 30 minutes, then the machine shuts down cleanly. It starts again at the next login.":
      "Копирование останавливается, на отправку отводится до 30 минут, затем машина корректно выключается. При следующем входе она запустится снова.",
    "The machine %@ is not running - nothing to prepare.":
      "Машина %@ не работает - готовить нечего.",
    "The machine is stopped and everything reached Google Drive. The Mac can be restarted; the machine starts again at login.":
      "Машина остановлена, и всё дошло до Google Drive. Mac можно перезагружать; машина запустится снова при входе.",
    "The machine is stopped. %@ GiB had not reached Google Drive yet - it is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "Машина остановлена. %@ GiB ещё не дошло до Google Drive - оно хранится в буфере машины и будет отправлено после следующего запуска. Mac можно перезагружать.",
    "The machine is stopped. rclone did not say how much was still to upload; what was not uploaded is kept in the machine's buffer and uploaded after the next start. The Mac can be restarted.":
      "Машина остановлена. rclone не сообщил, сколько ещё осталось отправить; неотправленное хранится в буфере машины и будет отправлено после следующего запуска. Mac можно перезагружать.",
    "The machine's disk is a file on this disk and grows as the upload buffer fills. With no space left the machine cannot write the buffer, and Time Machine's local snapshots have nowhere to go either.":
      "Диск машины - это файл на этом диске, и он растёт по мере заполнения буфера отправки. Без свободного места машина не сможет записывать буфер, а локальным снимкам Time Machine тоже некуда будет деваться.",
    "The image's metadata has never been copied to Drive":
      "Метаданные образа ни разу не копировались на Drive",
    "The image's metadata was last copied to Drive %@ ago":
      "Метаданные образа последний раз копировались на Drive %@ назад",
    "The machine's disk is running out of space (%@ GB)":
      "На диске машины заканчивается место (%@ GB)",
    "The new sign-in does NOT see the existing backup (%@), so remote '%@' was NOT replaced and rclone.conf is unchanged. Keep the current connection, or sign in with the credential (client_id) that created the backup.":
      "Новый вход НЕ видит существующую копию (%@), поэтому remote '%@' НЕ заменён, а rclone.conf не изменён. Оставьте текущее подключение либо войдите с учётными данными (client_id), которыми была создана копия.",
    "The upload buffer lives on this disk. The guard pauses Time Machine before it fills; if the upload does not catch up, backups stay paused.":
      "Буфер отправки находится на этом диске. Страж приостанавливает Time Machine до его заполнения; если отправка не успевает, копирование остаётся приостановленным.",
    "These bands exist only in the machine's buffer. The backup on Google Drive is INCOMPLETE and may not open.":
      "Эти полосы существуют только в буфере машины. Копия на Google Drive НЕПОЛНАЯ и может не открыться.",
    "Time Machine backs up to the machine, so without it no backup is made. Start it: limactl start %@ (or the Start button in the app).":
      "Time Machine копирует в машину, поэтому без неё копии не создаются. Запустите её: limactl start %@ (или кнопкой в приложении).",
    "Time Machine did not stop its backup within 2 minutes (or tmutil did not answer) - the machine was NOT stopped. Try again in a moment.":
      "Time Machine не остановил копирование за 2 минуты (или tmutil не ответил) - машина НЕ остановлена. Повторите через минуту.",
    "Time Machine has created its image: stop the backup, then convert the image to 32 MB bands":
      "Time Machine создал свой образ: остановите копирование, затем преобразуйте образ в полосы по 32 MB",
    "To upload":
      "К отправке",
    "Unknown whether the CloudMachine machine is running":
      "Неизвестно, работает ли машина CloudMachine",
    "Waiting for the upload to Google Drive (at most %@ min)...":
      "Ожидание отправки на Google Drive (не более %@ мин)...",
    "With --replace-existing: confirms that the new sign-in (scope 'drive.file') may not see the existing backup. The new token is still checked against the backup first.":
      "С --replace-existing: подтверждает, что новый вход (область 'drive.file') может не видеть существующую копию. Новый токен всё равно сначала проверяется на копии.",
    "Without it there is no way to check whether anything reached the Drive - the machine's guard is blind then.":
      "Без него нельзя проверить, дошло ли что-нибудь до Drive - страж машины тогда слеп.",
    "limactl did not answer":
      "limactl не ответил",
    "limactl did not answer (or is not installed). That does not mean the machine is down - it means nobody has checked.":
      "limactl не ответил (или не установлен). Это не значит, что машина не работает - это значит, что никто не проверил.",
    "limactl start failed: %@":
      "limactl start завершился с ошибкой: %@",
    "limactl stop failed: %@":
      "limactl stop завершился с ошибкой: %@",
    "punchfs is close to its open-file limit":
      "punchfs близок к лимиту открытых файлов",
    "punchfs open files":
      "Открытые файлы punchfs",
    "rclone's remote control is open on this Mac":
      "Удалённое управление rclone открыто на этом Mac",
    "statfs('/System/Volumes/Data') returned an error, so nobody knows whether the machine's disk can still grow on this Mac.":
      "statfs('/System/Volumes/Data') вернул ошибку, поэтому неизвестно, может ли диск машины ещё расти на этом Mac.",
    "Google Drive's daily upload limit stops the upload":
      "Суточный лимит отправки Google Drive остановил отправку",
    "Google last refused an upload %@ ago (750 GB a day). Backups since then are only in the machine's buffer on this Mac. rclone retries every 5 min and resumes by itself when the limit passes; the guard pauses Time Machine if more than %@ GiB waits.":
      "Google отклонил отправку %@ назад (750 GB в сутки). Копии с тех пор находятся только в буфере машины на этом Mac. rclone повторяет попытку каждые 5 мин и сам возобновит отправку, когда лимит снимется; страж приостановит Time Machine, если ждут отправки более %@ GiB.",
    "Usage on Google Drive is not being measured":
      "Занятое место на Google Drive не измеряется",
    "The last measurement (%@ GB) is from %@, %@ ago - rclone size has not answered since. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "Последнее измерение (%@ GB) от %@, %@ назад - с тех пор rclone size не отвечает. Пока он не ответит, за лимитом %@ GB никто не следит: оповещения о 90%% и 100%% молчат. Проверьте vm-status или нажмите «Измерить сейчас» в окне.",
    "rclone size has not answered even once. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "rclone size не ответил ни разу. Пока он не ответит, за лимитом %@ GB никто не следит: оповещения о 90%% и 100%% молчат. Проверьте vm-status или нажмите «Измерить сейчас» в окне.",
    "Saved in the Keychain. Connecting Google Drive (configure-remote) will use them.":
      "Сохранено в Связке ключей. При подключении Google Drive (configure-remote) они будут использованы.",
    "Saved in the Keychain. The existing Google Drive connection keeps its old client_id, and on this Mac it should stay that way: a connection made with the new keys (the 'drive.file' scope) cannot see the backup created by the old one. Do not replace the connection here; the new keys are for a Mac that is not connected yet.":
      "Сохранено в Связке ключей. Существующее подключение к Google Drive остаётся со старым client_id, и на этом Mac так и должно быть: подключение с новыми ключами (область 'drive.file') не видит копию, созданную старым. Не заменяйте здесь подключение; новые ключи предназначены для Mac, который ещё не подключён.",
    "it is not there for the new token":
      "для нового токена её нет",
    "Cancel":
      "Отмена",
    "ACTION NEEDED":
      "ТРЕБУЕТСЯ ДЕЙСТВИЕ",
    "WILL PASS BY ITSELF — DO NOTHING":
      "ПРОЙДЁТ САМО — НИЧЕГО НЕ ДЕЛАЙТЕ",
    "UNKNOWN — CHECK AGAIN SHORTLY":
      "НЕИЗВЕСТНО — ПРОВЕРЬТЕ ЕЩЁ РАЗ ЧУТЬ ПОЗЖЕ",
    "ALL GOOD":
      "ВСЁ В ПОРЯДКЕ",
    "Upload is not working":
      "Отправка не работает",
    "Upload stopped — no space left on Google Drive":
      "Отправка остановлена — на Google Drive нет места",
    "%@ backup fragments not uploaded":
      "Не отправлено фрагментов копии: %@",
    "Upload cannot keep up with writes":
      "Отправка не успевает за записью",
    "Upload paused — Google daily limit":
      "Отправка приостановлена — суточный лимит Google",
    "Uploading to Google Drive — %@ queued":
      "Отправка на Google Drive — в очереди: %@",
    "Everything uploaded to Google Drive":
      "Всё отправлено на Google Drive",
    "Unknown what is waiting in the queue":
      "Неизвестно, что ждёт в очереди",
    "There is no connection to Google Drive, so backups are only made on this Mac. If this does not pass by itself within a few minutes, check the network and the connection to Drive.":
      "Нет подключения к Google Drive, поэтому копии создаются только на этом Mac. Если это не пройдёт само за несколько минут, проверьте сеть и подключение к Drive.",
    "There is no space left on Google Drive. This will NOT pass by itself — you need to free up space on Drive. Until then Time Machine is paused, so that it does not fill up this Mac's disk.":
      "На Google Drive не осталось места. Это НЕ пройдёт само — нужно освободить место на Drive. До тех пор Time Machine приостановлен, чтобы не заполнить диск этого Mac.",
    "%@ backup fragments could not be uploaded and rclone stopped trying. These fragments exist only on this Mac, so the backup on Drive is incomplete. This needs checking.":
      "Не удалось отправить фрагментов копии: %@, и rclone прекратил попытки. Эти фрагменты есть только на этом Mac, поэтому копия на Drive неполная. Это нужно проверить.",
    "Time Machine is writing faster than the upload goes, and the buffer has filled up. The backup will be paused until the upload catches up — this is a safeguard against filling up the disk, not a failure.":
      "Time Machine пишет быстрее, чем идёт отправка, и буфер заполнился. Копирование будет приостановлено, пока отправка не догонит — это защита от заполнения диска, а не сбой.",
    "Google accepts 750 GB per day and that limit has been used up. There is nothing to do: the limit renews by itself, usually within a few hours. Time Machine backups are made normally in the meantime and wait in the buffer — they will be uploaded as soon as Google starts accepting again.":
      "Google принимает 750 GB в сутки, и этот лимит исчерпан. Делать ничего не нужно: лимит обновляется сам, обычно в течение нескольких часов. Копии Time Machine тем временем создаются как обычно и ждут в буфере — они будут отправлены, как только Google снова начнёт принимать данные.",
    "%@ backup fragments are queued and on their way to Drive.":
      "Фрагментов копии в очереди и на пути к Drive: %@.",
    "Nothing is waiting in the queue — the backup on Google Drive is complete.":
      "В очереди ничего нет — копия на Google Drive полная.",
    "rclone did not answer the question about the queue, so it is unknown how many backups are still waiting to be uploaded. This does not mean something broke — under load the answer can be late. It only means that right now nobody knows. If it persists, the backup cycle check will report it.":
      "rclone не ответил на вопрос об очереди, поэтому неизвестно, сколько копий ещё ждёт отправки. Это не значит, что что-то сломалось — под нагрузкой ответ может запаздывать. Это лишь означает, что сейчас этого никто не знает. Если так будет и дальше, об этом сообщит проверка цикла копирования.",
    "unknown error":
      "неизвестная ошибка",
    "rclone lsf ended with an error":
      "rclone lsf завершился с ошибкой",
    "This Mac is close to its space limit on Google Drive":
      "Этот Mac приближается к лимиту места на Google Drive",
    "%@ GB of %@ GB used. Time Machine deletes the oldest backups to stay within its quota; check that the quota is set (vm-status).":
      "Занято %@ GB из %@ GB. Time Machine удаляет самые старые копии, чтобы уложиться в квоту; убедитесь, что квота задана (vm-status).",
    "This Mac is over its space limit on Google Drive":
      "Этот Mac превысил лимит места на Google Drive",
    "%@ GB of %@ GB used. Set the Time Machine quota (command in the app window or vm-status), or raise the limit.":
      "Занято %@ GB из %@ GB. Задайте квоту Time Machine (команда в окне приложения или в vm-status) либо увеличьте лимит.",
    "not set":
      "не задан",
    "%@ GB - usage not measured yet":
      "%@ GB - занятое место ещё не измерено",
    "%@ of %@ GB used (%@%%)":
      "Занято %@ из %@ GB (%@%%)",
    "The limit must be a whole number of GB above zero.":
      "Лимит должен быть целым числом GB больше нуля.",
    "machines.json cannot be read, so it was not overwritten. Fix or remove it first.":
      "Не удаётся прочитать machines.json, поэтому он не перезаписан. Сначала исправьте или удалите его.",
    "'%@' is not a valid folder name: use lowercase letters, digits and dashes.":
      "'%@' - недопустимое имя папки: используйте строчные латинские буквы, цифры и дефисы.",
    "This Mac already backs up to folder '%@'. Switching to '%@' would start a new, empty backup and orphan the existing one, so nothing was changed.":
      "Этот Mac уже копирует в папку '%@'. Переход на '%@' начал бы новую пустую копию и оставил бы существующую без владельца, поэтому ничего не изменено.",
    "This Mac already has a CloudMachine installation, whose backup is in folder '%@'. Switching to '%@' would orphan it, so nothing was changed.":
      "На этом Mac уже установлен CloudMachine, его копия лежит в папке '%@'. Переход на '%@' оставил бы её без владельца, поэтому ничего не изменено.",
    "Could not save the folder name to %@: %@":
      "Не удалось сохранить имя папки в %@: %@",
    "Homebrew is not installed. Install it manually: https://brew.sh":
      "Homebrew не установлен. Установите его вручную: https://brew.sh",
    "Installing rclone failed: %@":
      "Не удалось установить rclone: %@",
    "Installed rclone.":
      "rclone установлен.",
    "Own Google credentials: set.":
      "Собственные учётные данные Google: заданы.",
    "INCOMPLETE: %@ is missing - rclone will use rclone's shared client_id anyway.":
      "НЕПОЛНЫЕ: не хватает %@ - rclone всё равно будет использовать общий client_id rclone.",
    "No own credentials - rclone uses the shared client_id, rate-limited jointly and being retired in 2026.":
      "Собственных учётных данных нет - rclone использует общий client_id, лимит на который общий и который будет выведен из обращения в 2026 году.",
    "Empty value - not saving.":
      "Пустое значение - не сохраняю.",
    "Keychain refused: %@":
      "Связка ключей отказала: %@",
    "DIRTY-TREE":
      "ГРЯЗНОЕ-ДЕРЕВО",
    "Cannot create the working directory: %@":
      "Не удаётся создать рабочий каталог: %@",
    "Could not read the rclone version number.":
      "Не удалось прочитать номер версии rclone.",
    "Could not download %@.":
      "Не удалось скачать %@.",
    "No entry for %@ in SHA256SUMS.":
      "Нет записи для %@ в SHA256SUMS.",
    "Could not compute the checksum.":
      "Не удалось вычислить контрольную сумму.",
    "SHA256 checksum does not match - NOT installing.\n  expected: %@\n  computed: %@":
      "Контрольная сумма SHA256 не совпадает - НЕ устанавливаю.\n  ожидалась: %@\n  вычислена: %@",
    "Could not unpack the archive.":
      "Не удалось распаковать архив.",
    "Could not install the binary: %@":
      "Не удалось установить бинарный файл: %@",
    "Installed rclone %@ in %@ (SHA256 checksum matches).":
      "rclone %@ установлен в %@ (контрольная сумма SHA256 совпадает).",
    "%@ did not respond within the allotted time (the process was left orphaned in the background).":
      "%@ не ответил за отведённое время (процесс остался в фоне без владельца).",
    "Cannot launch %@: %@":
      "Не удаётся запустить %@: %@",
    "Remote '%@' already exists and was NOT touched.\nOverwriting it replaces the token and the permission scope; a credential with the 'drive.file' scope does not see files created by the previous one, so the existing backup becomes unreachable.\nIf you really want to replace it, first back up ~/.config/rclone/rclone.conf and run again with --replace-existing.":
      "Remote '%@' уже существует и НЕ тронут.\nПерезапись заменяет токен и область прав; учётные данные с областью 'drive.file' не видят файлы, созданные предыдущими, поэтому существующая копия становится недоступной.\nЕсли вы действительно хотите его заменить, сначала сделайте копию ~/.config/rclone/rclone.conf и запустите снова с --replace-existing.",
    "Could not check whether remote '%@' already exists (rclone listremotes did not answer or failed), so nothing was changed. Run `%@ listremotes` to see the error, then try again.":
      "Не удалось проверить, существует ли уже remote '%@' (rclone listremotes не ответил или завершился с ошибкой), поэтому ничего не изменено. Выполните `%@ listremotes`, чтобы увидеть ошибку, и повторите попытку.",
    "Could not check whether this Mac already has a CloudMachine installation (rclone did not answer), so no folder was chosen. Try again in a moment.":
      "Не удалось проверить, установлен ли на этом Mac CloudMachine (rclone не ответил), поэтому папка не выбрана. Повторите попытку через минуту.",
    "rclone authorize failed (%@). If that binary is missing, start with: cloudmachine-agent install-rclone.":
      "rclone authorize завершился с ошибкой (%@). Если этого бинарного файла нет, начните с: cloudmachine-agent install-rclone.",
    "Could not read the token from the output of rclone authorize.":
      "Не удалось прочитать токен из вывода rclone authorize.",
    "rclone config create failed.":
      "rclone config create завершился с ошибкой.",
    "Connected to Google Drive as remote '%@', folder %@.":
      "Подключено к Google Drive как remote '%@', папка %@.",
    "tmutil is not responding - unknown where the backup goes":
      "tmutil не отвечает - неизвестно, куда идёт копия",
    "No successful backup for %@":
      "Нет успешной копии уже %@",
    "Last COMPLETED backup: %@. The cycle is hourly, so that is %@ missed runs.":
      "Последняя ЗАВЕРШЁННАЯ копия: %@. Цикл часовой, поэтому пропущено запусков: %@.",
    "There is NOT A SINGLE successful backup":
      "НЕТ НИ ОДНОЙ успешной копии",
    "The Time Machine preferences contain no date of a completed backup for this destination.":
      "В настройках Time Machine нет даты завершённой копии для этого места назначения.",
    "The last backup attempt did not end in a backup":
      "Последняя попытка копирования не закончилась копией",
    "The attempt at %@ is newer than the last successful backup at %@.":
      "Попытка в %@ новее последней успешной копии в %@.",
    "Time Machine reports an error in the last run (RESULT=%@)":
      "Time Machine сообщает об ошибке при последнем запуске (RESULT=%@)",
    "A non-zero RESULT in the Time Machine preferences means the run did not succeed.":
      "Ненулевой RESULT в настройках Time Machine означает, что запуск не удался.",
    "rclone failed to upload %@ files":
      "rclone не удалось отправить файлов: %@",
    "Buffer full of nothing but unsent data":
      "Буфер полон одних неотправленных данных",
    "rclone has nothing left to evict from the buffer - the upload cannot keep up or has stalled.":
      "В буфере rclone больше нечего вытеснять - отправка не успевает или стоит.",
    "The rclone control interface is not responding":
      "Интерфейс управления rclone не отвечает",
    "Google Drive is running out of space (%@ GB)":
      "На Google Drive заканчивается место (%@ GB)",
    "The Mac's disk is running out of space (%@ GB)":
      "На диске Mac заканчивается место (%@ GB)",
    "Cannot read the Time Machine preferences":
      "Не удаётся прочитать настройки Time Machine",
    "%@ is unreadable - most often Full Disk Access is missing. Without this file it is UNKNOWN when the last backup was made, so we treat it as a failure, not as the absence of a problem.":
      "%@ нечитаем - чаще всего не выдан Полный доступ к диску. Без этого файла НЕИЗВЕСТНО, когда была сделана последняя копия, поэтому мы считаем это сбоем, а не отсутствием проблемы.",
    "Cannot measure free space on the Mac's disk":
      "Не удаётся измерить свободное место на диске Mac",
    "%@ days":
      "Дней: %@",
    "CloudMachine: backup is not working":
      "CloudMachine: копирование не работает",
    "unknown reason":
      "причина неизвестна",
    "osascript did not show the notification (permissions or no graphical session)":
      "osascript не показал уведомление (нет разрешений или нет графического сеанса)",
    "UNDELIVERED ALARM: %@":
      "НЕДОСТАВЛЕННОЕ ОПОВЕЩЕНИЕ: %@",
    "from %@, reason: %@":
      "от %@, причина: %@",
    "The system notification was not delivered - you will see this alarm ONLY here.":
      "Системное уведомление не доставлено - это оповещение вы увидите ТОЛЬКО здесь.",
    "%@ (%@ ago)":
      "%@ (%@ назад)",
    "%@ - marker from the FUTURE":
      "%@ - метка из БУДУЩЕГО",
    "%@ (%@ ago) - THE WATCHDOG MAY NOT BE RUNNING":
      "%@ (%@ назад) - НАБЛЮДАТЕЛЬ, ВОЗМОЖНО, НЕ РАБОТАЕТ",
    "NEVER - the watchdog has not recorded a single run":
      "НИКОГДА - наблюдатель не записал ни одного запуска",
    "Could not find the launchd/ directory with templates.":
      "Не найден каталог launchd/ с шаблонами.",
    "Could not find the compiled cloudmachine-agent binary.":
      "Не найден скомпилированный бинарный файл cloudmachine-agent.",
    "ABORTED: could not put cloudmachine-agent in a stable location\n(%@) - most often a lack of space or permissions.\nNOT installing agents pointing at %@: that path\ndisappears on the next `swift build` or `git clean`, and backups stop\nwithout any visible signal.":
      "ПРЕРВАНО: не удалось поместить cloudmachine-agent в постоянное место\n(%@) - чаще всего из-за нехватки места или прав.\nАгенты, указывающие на %@, НЕ устанавливаются: этот путь\nисчезнет при следующем `swift build` или `git clean`, и копирование\nпрекратится без какого-либо заметного сигнала.",
    "ABORTED: %@":
      "ПРЕРВАНО: %@",
    "Could not list the templates in %@.":
      "Не удалось получить список шаблонов в %@.",
    "could not read the template %@":
      "не удалось прочитать шаблон %@",
    "could not write %@ (lack of space or permissions)":
      "не удалось записать %@ (нет места или прав)",
    "launchctl load refused to load %@":
      "launchctl load отказался загружать %@",
    "NOT A SINGLE agent was loaded.":
      "НЕ ЗАГРУЖЕН НИ ОДИН агент.",
    "Only these went in: %@.":
      "Установлены только: %@.",
    "Could not load any launchd agent.":
      "Не удалось загрузить ни одного агента launchd.",
    "Installed agents: %@":
      "Установлено агентов: %@",
    "                  WARNING: close to the limit - new bands will fail with EMFILE":
      "                  ВНИМАНИЕ: близко к лимиту - новые полосы завершатся ошибкой EMFILE",
    "%@/bands on Google Drive is not empty - it may hold another backup. NOT overwriting it; check it by hand.":
      "%@/bands на Google Drive не пуст - там может быть другая копия. НЕ перезаписываю; проверьте вручную.",
    "Address:          %@":
      "Адрес:            %@",
    "Already prepared (%@ exists) - nothing to do.":
      "Уже подготовлено (%@ существует) - делать нечего.",
    "Converts Time Machine's new, empty image in the machine to 32 MB bands and moves the bands to Google Drive.":
      "Преобразует новый пустой образ Time Machine в машине в полосы по 32 MB и переносит полосы на Google Drive.",
    "Copy rclone.conf into the machine even if it already has one.":
      "Скопировать rclone.conf в машину, даже если он там уже есть.",
    "Copying the converted image into the machine failed: %@":
      "Не удалось скопировать преобразованный образ в машину: %@",
    "Copying the image to the Mac failed: %@":
      "Не удалось скопировать образ на Mac: %@",
    "Could not ask Lima about the machine: %@":
      "Не удалось запросить у Lima данные о машине: %@",
    "Could not carry the Time Machine files over: %@":
      "Не удалось перенести файлы Time Machine: %@",
    "Could not check the image in the machine.":
      "Не удалось проверить образ в машине.",
    "Could not copy the rclone configuration into the machine.":
      "Не удалось скопировать конфигурацию rclone в машину.",
    "Could not create %@ on Google Drive: %@":
      "Не удалось создать %@ на Google Drive: %@",
    "Could not create %@: %@":
      "Не удалось создать %@: %@",
    "Could not find the vm/ directory with the machine template.":
      "Не найден каталог vm/ с шаблоном машины.",
    "Could not read the image size.":
      "Не удалось прочитать размер образа.",
    "Could not set the SMB password of user %@ in the machine.":
      "Не удалось задать пароль SMB пользователя %@ в машине.",
    "Could not stop smbd in the machine.":
      "Не удалось остановить smbd в машине.",
    "Could not write %@ in the machine.":
      "Не удалось записать %@ в машине.",
    "Could not write the password file %@.":
      "Не удалось записать файл с паролем %@.",
    "Creates or starts the CloudMachine machine (Lima), gives it rclone's configuration and an SMB password, and prints the Time Machine command.":
      "Создаёт или запускает машину CloudMachine (Lima), передаёт ей конфигурацию rclone и пароль SMB и выводит команду для Time Machine.",
    "Creating the machine %@ (first start downloads Ubuntu and installs packages - several minutes)...":
      "Создаю машину %@ (при первом запуске скачивается Ubuntu и устанавливаются пакеты - несколько минут)...",
    "Done: %@ has %@ MB bands on Google Drive; the original is kept in %@ in the machine. Start the backup: tmutil startbackup":
      "Готово: у %@ полосы по %@ MB на Google Drive; оригинал хранится в %@ в машине. Запустите копирование: tmutil startbackup",
    "exit code %@, no message":
      "код выхода %@, без сообщения",
    "Image metadata:   NEVER copied to %@ - check tm-meta-sync in the machine":
      "Метаданные образа: НИКОГДА не копировались в %@ - проверьте tm-meta-sync в машине",
    "Image metadata:   copied %@ ago to %@":
      "Метаданные образа: скопированы %@ назад в %@",
    "Image metadata:   last copied %@ ago - OVERDUE (%@)":
      "Метаданные образа: последний раз скопированы %@ назад - ПРОСРОЧЕНО (%@)",
    "Image metadata:   not copied yet - waits for vm-prepare-bundle":
      "Метаданные образа: ещё не копировались - ждут vm-prepare-bundle",
    "Backup %@, paused by the guard %@: %@":
      "Копирование %@, приостановлено стражем %@: %@",
    "Free in machine:  %@ GiB":
      "Свободно в машине: %@ GiB",
    "fsck_apfs -n found problems: %@":
      "fsck_apfs -n обнаружил проблемы: %@",
    "Google Drive folder: %@":
      "Папка на Google Drive: %@",
    "hdiutil attach of the converted image failed: %@":
      "hdiutil attach преобразованного образа завершился с ошибкой: %@",
    "hdiutil convert failed: %@":
      "hdiutil convert завершился с ошибкой: %@",
    "Image name in the machine (default: from the computer name).":
      "Имя образа в машине (по умолчанию: из имени компьютера).",
    "Installing the converted image FAILED: %@\nsmbd is left STOPPED so Time Machine does not open a half-installed image. The original is in %@ in the machine.":
      "Установка преобразованного образа НЕ УДАЛАСЬ: %@\nsmbd оставлен ОСТАНОВЛЕННЫМ, чтобы Time Machine не открыл наполовину установленный образ. Оригинал хранится в %@ в машине.",
    "limactl create failed: %@":
      "limactl create завершился с ошибкой: %@",
    "limactl list failed: %@":
      "limactl list завершился с ошибкой: %@",
    "limactl not found - install Lima: brew install lima":
      "limactl не найден - установите Lima: brew install lima",
    "limactl start failed: %@\nThe machine's own log: %@":
      "limactl start завершился с ошибкой: %@\nСобственный журнал машины: %@",
    "Machine %@ is running.":
      "Машина %@ работает.",
    "Machine %@ was already running.":
      "Машина %@ уже работала.",
    "Machine:          %@ (%@)":
      "Машина:           %@ (%@)",
    "Machine:          %@":
      "Машина:           %@",
    "Machine:          not created - run: cloudmachine-agent vm-setup":
      "Машина:           не создана - выполните: cloudmachine-agent vm-setup",
    "no answer within the time limit":
      "нет ответа за отведённое время",
    "No image %@ in the machine.":
      "В машине нет образа %@.",
    "No image in the machine yet - point Time Machine at the share and let it create one first.":
      "В машине ещё нет образа - сначала укажите Time Machine общий ресурс и дайте ему создать образ.",
    "No rclone configuration at %@ - connect Google Drive first (configure-remote).":
      "Нет конфигурации rclone в %@ - сначала подключите Google Drive (configure-remote).",
    "no SMB destination":
      "нет места назначения SMB",
    "One check of the machine's upload buffer: pauses Time Machine when it fills, resumes what it paused.":
      "Одна проверка буфера отправки машины: приостанавливает Time Machine при заполнении и возобновляет то, что приостановила сама.",
    "Packing the converted image failed: %@":
      "Не удалось упаковать преобразованный образ: %@",
    "Packing the image failed: %@":
      "Не удалось упаковать образ: %@",
    "No answer from the machine (rclone rc) - the guard would do nothing.":
      "Машина не отвечает (rclone rc) - страж ничего бы не сделал.",
    "Only print what the guard would decide - for trying thresholds on a throwaway machine.":
      "Только вывести, что решил бы страж - для проверки порогов на одноразовой машине.",
    "Pause above this many GiB in the buffer.":
      "Приостанавливать при превышении стольких GiB в буфере.",
    "Pause when the machine has less free than this, in GiB.":
      "Приостанавливать, когда в машине свободно меньше стольких GiB.",
    "Point Time Machine at the machine (once, needs an administrator password):":
      "Укажите Time Machine машину (один раз, потребуется пароль администратора):",
    "punchfs files:    %@ open, limit %@":
      "Файлы punchfs:    открыто %@, лимит %@",
    "rclone configuration already in the machine - kept (--replace-rclone-config replaces it).":
      "Конфигурация rclone уже в машине - оставлена (--replace-rclone-config заменяет её).",
    "rclone configuration copied into the machine.":
      "Конфигурация rclone скопирована в машину.",
    "rclone-tm or punchfs is not running in the machine - see cloudmachine-agent vm-status.":
      "rclone-tm или punchfs не работает в машине - см. cloudmachine-agent vm-status.",
    "Resume below this many GiB (only a backup the guard paused).":
      "Возобновлять при остатке ниже стольких GiB (только копирование, приостановленное стражем).",
    "Service %@: %@":
      "Служба %@: %@",
    "Several images in the machine (%@) - choose one with --bundle.":
      "В машине несколько образов (%@) - выберите один через --bundle.",
    "Shows the machine: address, services, upload buffer, free space and the Time Machine destination.":
      "Показывает машину: адрес, службы, буфер отправки, свободное место и место назначения Time Machine.",
    "SMB password stored in %@ (mode 600).":
      "Пароль SMB сохранён в %@ (права 600).",
    "The converted image does not have %@-byte bands.":
      "У преобразованного образа нет полос по %@ байт.",
    "The converted image has no APFS partition.":
      "В преобразованном образе нет раздела APFS.",
    "The image already takes %@ MB - this command converts only a new, empty image (under %@ MB).":
      "Образ уже занимает %@ MB - эта команда преобразует только новый пустой образ (менее %@ MB).",
    "The image is encrypted - converting encrypted images is not supported.":
      "Образ зашифрован - преобразование зашифрованных образов не поддерживается.",
    "The image was not changed; smbd started again.":
      "Образ не изменён; smbd запущен снова.",
    "The machine does not answer - is it running? cloudmachine-agent vm-status":
      "Машина не отвечает - она работает? cloudmachine-agent vm-status",
    "The machine has no address on the vzNAT network.":
      "У машины нет адреса в сети vzNAT.",
    "The services in the machine did not start - check: cloudmachine-agent vm-status":
      "Службы в машине не запустились - проверьте: cloudmachine-agent vm-status",
    "Time Machine is backing up - stop it first: tmutil stopbackup":
      "Time Machine выполняет копирование - сначала остановите его: tmutil stopbackup",
    "Time Machine:     %@":
      "Time Machine:     %@",
    "Time Machine:     NOT pointing at the machine (%@)":
      "Time Machine:     НЕ указывает на машину (%@)",
    "Time Machine:     tmutil did not answer":
      "Time Machine:     tmutil не ответил",
    "tmutil did not answer - not touching the image while its state is unknown.":
      "tmutil не ответил - не трогаю образ, пока его состояние неизвестно.",
    "unknown":
      "неизвестно",
    "Unpacking the image failed: %@":
      "Не удалось распаковать образ: %@",
    "Still to upload:  %@ GiB in %@ bands, uploading %@ (cache on disk %@ GiB)":
      "К отправке:       %@ GiB в полосах: %@, отправляется %@ (кэш на диске %@ GiB)",
    "Excluded %@ (the machine and its upload buffer) from Time Machine.":
      "%@ (машина и её буфер отправки) исключено из Time Machine.",
    "WARNING: could not exclude %@ from Time Machine - run: tmutil addexclusion %@":
      "ВНИМАНИЕ: не удалось исключить %@ из Time Machine - выполните: tmutil addexclusion %@",
    "Upload buffer:    no answer from rclone (rc %@)":
      "Буфер отправки:   нет ответа от rclone (rc %@)",
    "When Time Machine has created its empty image, stop the backup (tmutil stopbackup) and run: cloudmachine-agent vm-prepare-bundle":
      "Когда Time Machine создаст пустой образ, остановите копирование (tmutil stopbackup) и выполните: cloudmachine-agent vm-prepare-bundle",
    "Unsent %@ GiB, free %@ GiB (pause above %@ GiB unsent or below %@ GiB free, resume below %@ GiB).":
      "Не отправлено %@ GiB, свободно %@ GiB (пауза при более %@ GiB неотправленных или менее %@ GiB свободных, возобновление ниже %@ GiB).",
    "Upload:           Google's daily limit refused an upload %@ ago - rclone retries every 5 min and resumes by itself":
      "Отправка:         суточный лимит Google отклонил отправку %@ назад - rclone повторяет каждые 5 мин и сам возобновит",
    "no":
      "нет",
    "running":
      "идёт",
    "stopped":
      "остановлена",
    "yes":
      "да",
    "%@\nThe previous template is in %@ - copy it back over lima.yaml and run limactl start %@.":
      "%@\nПредыдущий шаблон находится в %@ - скопируйте его обратно поверх lima.yaml и выполните limactl start %@.",
    "Could not read this app's machine template (limactl template copy).":
      "Не удалось прочитать шаблон машины из этого приложения (limactl template copy).",
    "Could not replace %@: %@":
      "Не удалось заменить %@: %@",
    "Machine %@ already runs this app's template.":
      "Машина %@ уже работает на шаблоне из этого приложения.",
    "Machine %@ now runs this app's template; the previous one is in %@.":
      "Машина %@ теперь работает на шаблоне из этого приложения; предыдущий находится в %@.",
    "Moves the machine onto this app's template (two restarts, never during a backup).":
      "Переводит машину на шаблон из этого приложения (два перезапуска, никогда во время копирования).",
    "No machine %@ - create it with: cloudmachine-agent vm-setup":
      "Машины %@ нет - создайте её: cloudmachine-agent vm-setup",
    "Template:         OLDER than this app's - run: cloudmachine-agent vm-update":
      "Шаблон:           СТАРЕЕ, чем в этом приложении - выполните: cloudmachine-agent vm-update",
    "Template:         not compared":
      "Шаблон:           не сравнивался",
    "Template:         this app's":
      "Шаблон:           из этого приложения",
    "The machine has no %@ - run cloudmachine-agent vm-setup first.":
      "В машине нет %@ - сначала выполните cloudmachine-agent vm-setup.",
    "The machine restarted, but not every service is running - check: cloudmachine-agent vm-status. The previous template is in %@.":
      "Машина перезапущена, но работают не все службы - проверьте: cloudmachine-agent vm-status. Предыдущий шаблон находится в %@.",
    "The template changes the machine itself (%@) - that needs a new machine, not an update.":
      "Шаблон меняет саму машину (%@) - для этого нужна новая машина, а не обновление.",
    "The upload to Google Drive hangs":
      "Отправка на Google Drive зависла",
    "Time Machine is backing up - try again when it has finished.":
      "Time Machine выполняет копирование - повторите, когда оно закончится.",
    "Upload:           HANGS - bands in progress, none uploaded for %@ (network?); see /var/log/rclone-tm.log in the machine":
      "Отправка:         ЗАВИСЛА - полосы в процессе, ни одна не отправлена уже %@ (сеть?); см. /var/log/rclone-tm.log в машине",
    "limactl stop failed - nothing was changed.":
      "limactl stop не удался - ничего не изменено.",
    "rclone has bands in progress, but none has been uploaded for %@ - usually a broken network connection, which rclone does not report as an error. Backups since then are only in the machine's buffer. When the network comes back the upload resumes by itself (on 28.10.2026 within 80 s); if it does not, restarting the machine (prepare-shutdown, limactl start) drops the dead connections.":
      "У rclone есть полосы в процессе отправки, но ни одна не отправлена уже %@ - обычно это обрыв сетевого соединения, о котором rclone не сообщает как об ошибке. Копии с тех пор находятся только в буфере машины. Когда сеть вернётся, отправка возобновится сама (28.10.2026 - за 80 s); если нет, перезапуск машины (prepare-shutdown, limactl start) разорвёт мёртвые соединения.",
    "tmutil did not answer - not restarting the machine while its state is unknown.":
      "tmutil не ответил - не перезапускаю машину, пока её состояние неизвестно.",
    "The machine's share cannot be read":
      "Общий ресурс машины не читается",
    "Unknown whether the machine's share can be read":
      "Неизвестно, читается ли общий ресурс машины",
    "Samba in the machine does not answer this Mac":
      "Samba в машине не отвечает этому Mac",
    "Unknown whether Samba in the machine answers this Mac":
      "Неизвестно, отвечает ли Samba в машине этому Mac",
    "Reading 1 byte of %@ in the machine failed: %@. Every service says it is active, yet Time Machine cannot use the image there. Nothing restarts it by itself. Check: cloudmachine-agent vm-status, then in the machine: journalctl -u punchfs -u tm-bands-bind -u rclone-tm":
      "Чтение 1 байта из %@ в машине не удалось: %@. Все службы сообщают, что активны, но Time Machine не может использовать там образ. Ничто не перезапускает это само. Проверьте: cloudmachine-agent vm-status, затем в машине: journalctl -u punchfs -u tm-bands-bind -u rclone-tm",
    "Reading 1 byte of %@ in the machine has not returned for %@ s. That is how a hung punchfs or rclone mount behaves. Nothing is restarted while the state is unknown - a restart under a write still going could lose it. Check in the machine: journalctl -u punchfs -u rclone-tm":
      "Чтение 1 байта из %@ в машине не возвращается уже %@ с. Так ведёт себя зависшее монтирование punchfs или rclone. Пока состояние неизвестно, ничего не перезапускается - перезапуск во время идущей записи может её потерять. Проверьте в машине: journalctl -u punchfs -u rclone-tm",
    "An SMB connection to %@ got no answer within %@ s. Time Machine reaches the machine at this address. Check the machine's network and smbd: cloudmachine-agent vm-status":
      "SMB-подключение к %@ не получило ответа за %@ с. По этому адресу Time Machine обращается к машине. Проверьте сеть машины и smbd: cloudmachine-agent vm-status",
    "The machine did not report its address, so nobody could try an SMB connection. Check: cloudmachine-agent vm-status":
      "Машина не сообщила свой адрес, поэтому никто не смог попробовать SMB-подключение. Проверьте: cloudmachine-agent vm-status",
    "An SMB connection to %@ failed (%@). Time Machine reaches the machine at this address, so no backup is made. Check the machine's network and smbd: cloudmachine-agent vm-status":
      "SMB-подключение к %@ не удалось (%@). По этому адресу Time Machine обращается к машине, поэтому резервная копия не создаётся. Проверьте сеть машины и smbd: cloudmachine-agent vm-status",
    "readable":
      "читается",
    "no image yet":
      "образа пока нет",
    "answers":
      "отвечает",
    "Share read:       %@":
      "Чтение ресурса:   %@",
    "Samba from Mac:   %@":
      "Samba с Mac:      %@",
    "This Mac found no route to %@ (%@). Either the route to the machine is gone, or macOS Local Network privacy has not allowed CloudMachine - then allow it in System Settings > Privacy & Security > Local Network. Check: cloudmachine-agent vm-status":
      "Этот Mac не нашёл маршрута к %@ (%@). Либо маршрут к машине пропал, либо конфиденциальность «Локальная сеть» в macOS не разрешила CloudMachine - тогда разрешите это в Системных настройках > Конфиденциальность и безопасность > Локальная сеть. Проверьте: cloudmachine-agent vm-status",
  ]
}
