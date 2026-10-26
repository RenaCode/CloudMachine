// Polish translations, keyed by the English text passed to `L10n.tr`.
// Texts added with the second audit (October 2026): the open remote-control
// port, replacing the Google credential, the usage measurement.
extension L10nPolish {
  static let safety: [String: String] = [
    // MachineBudget
    "Usage on Google Drive is not being measured":
      "Zajętość na Google Drive nie jest mierzona",
    "The last measurement (%@ GB) is from %@, %@ ago - rclone size has not answered since. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check drive-status, or press Measure now in the window.":
      "Ostatni pomiar (%@ GB) jest z %@, sprzed %@ - od tamtej pory rclone size nie odpowiada. Dopóki nie odpowie, nikt nie pilnuje limitu %@ GB: alarmy 90%% i 100%% milczą. Sprawdź drive-status albo naciśnij „Zmierz teraz” w oknie.",
    "rclone size has not answered even once. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check drive-status, or press Measure now in the window.":
      "rclone size nie odpowiedział ani razu. Dopóki nie odpowie, nikt nie pilnuje limitu %@ GB: alarmy 90%% i 100%% milczą. Sprawdź drive-status albo naciśnij „Zmierz teraz” w oknie.",
    // RemoteConfigurer: a missing rclone.conf
    "Or rclone.conf is missing: this Mac has already backed up to Google Drive (folders %@), so it is not connected anew blindly. Restore the file from a backup. To connect anyway, create an empty file at the path `%@ config file` prints and run again - the existing folder is kept.":
      "Albo brakuje rclone.conf: ten Mac robił już kopie na Google Drive (foldery %@), więc nie jest łączony od nowa na ślepo. Odtwórz plik z kopii. Żeby mimo to połączyć, utwórz pusty plik pod ścieżką, którą wypisuje `%@ config file`, i uruchom ponownie - istniejący folder zostanie zachowany.",
    // Replacing the Google credential
    "Saved in the Keychain. Connecting Google Drive (configure-remote) will use them.":
      "Zapisane w Keychainie. Łączenie z Google Drive (configure-remote) ich użyje.",
    "Saved in the Keychain. The existing Google Drive connection keeps its old client_id, and on this Mac it should stay that way: a connection made with the new keys (the 'drive.file' scope) cannot see the backup created by the old one. Do not replace the connection here; the new keys are for a Mac that is not connected yet.":
      "Zapisane w Keychainie. Istniejące połączenie z Google Drive zostaje przy starym client_id i na tym Macu tak ma zostać: połączenie z nowymi kluczami (zakres 'drive.file') nie widzi kopii założonej przez stare. Nie wymieniaj tu połączenia; nowe klucze są dla Maca, który jeszcze nie jest połączony.",
    "Remote '%@' was NOT replaced. The new sign-in gets the 'drive.file' scope, which sees only files created under its own client_id. The existing backup was most likely created by the current connection and would become invisible: the mount would show an empty folder, and create-image could start a second, empty backup next to it. Before anything is written, the new token is checked against the existing image, and the replacement is abandoned if it cannot see it. To go ahead, run again with --replace-existing --accept-scope-change.":
      "Remote '%@' NIE został wymieniony. Nowe logowanie dostaje zakres 'drive.file', który widzi tylko pliki założone przez jego własny client_id. Istniejącą kopię najpewniej założyło obecne połączenie i stałaby się niewidoczna: mount pokazałby pusty folder, a create-image mógłby założyć obok drugą, pustą kopię. Zanim cokolwiek zostanie zapisane, nowy token jest sprawdzany na istniejącym obrazie, a wymiana jest porzucana, jeśli go nie widzi. Żeby kontynuować, uruchom ponownie z --replace-existing --accept-scope-change.",
    "Could not check with the current connection whether the backup image is on Google Drive (%@), so remote '%@' was NOT replaced: without that answer the new sign-in cannot be checked against it.":
      "Nie udało się sprawdzić obecnym połączeniem, czy obraz kopii jest na Google Drive (%@), więc remote '%@' NIE został wymieniony: bez tej odpowiedzi nie ma z czym porównać nowego logowania.",
    "it is not there for the new token":
      "dla nowego tokenu go nie ma",
    "The new sign-in does NOT see the existing backup image (%@), so remote '%@' was NOT replaced and rclone.conf is unchanged. With this token the mount would show an empty folder. Keep the current connection, or sign in with the credential (client_id) that created the image.":
      "Nowe logowanie NIE widzi istniejącego obrazu kopii (%@), więc remote '%@' NIE został wymieniony, a rclone.conf jest bez zmian. Z tym tokenem mount pokazałby pusty folder. Zostaw obecne połączenie albo zaloguj się poświadczeniem (client_id), które założyło obraz.",
    "With --replace-existing: confirms that the new sign-in (scope 'drive.file') may not see the existing backup. The new token is still checked against the image first.":
      "Z --replace-existing: potwierdza, że nowe logowanie (zakres 'drive.file') może nie widzieć istniejącej kopii. Nowy token i tak jest najpierw sprawdzany na obrazie.",
    // BackupImageService.create
    "Google Drive does not show the image %@, but this Mac has already used it (trace: %@). NOT creating a new one - that would start an empty backup and orphan the existing one. Most likely the token cannot see it: a connection with the 'drive.file' scope sees only files created under its own client_id. Check the token's permissions (scope and client_id of the remote in rclone.conf). Only if the image really was deleted on purpose: remove %@ and run again.":
      "Google Drive nie pokazuje obrazu %@, a ten Mac już go używał (ślad: %@). NIE tworzę nowego - to zaczęłoby pustą kopię i osierociło istniejącą. Najpewniej token go nie widzi: połączenie z zakresem 'drive.file' widzi tylko pliki założone przez własny client_id. Sprawdź uprawnienia tokenu (scope i client_id remote'a w rclone.conf). Tylko jeśli obraz naprawdę został celowo usunięty: usuń %@ i uruchom ponownie.",

    // The open remote-control port and restarting the mount
    "WARNING: remote control is OPEN on %@ - run restart-mount (or prepare-shutdown, then restart the Mac).":
      "UWAGA: sterowanie rc jest OTWARTE na %@ - uruchom restart-mount (albo prepare-shutdown, potem zrestartuj Maca).",
    "Restarts the Google Drive mount on the private socket: detaches the image, waits for the upload, restarts the mount and attaches the image again.":
      "Restartuje montowanie Google Drive na prywatnym gnieździe: odłącza obraz, czeka na wysyłkę, restartuje montowanie i podłącza obraz z powrotem.",
    "Detaching the image and waiting for the upload, then restarting the mount. This can take several minutes; Time Machine has no destination meanwhile.":
      "Odłączam obraz i czekam na wysyłkę, potem restartuję montowanie. To może potrwać kilka minut; Time Machine nie ma w tym czasie celu.",
    "Restarting the Google Drive mount":
      "Restartowanie montowania Google Drive",
    "Remote control of the Drive mount is open":
      "Sterowanie montowaniem Dysku jest otwarte",
    "The mount was started by an older version of CloudMachine and still takes commands on %@ without a password. Any web page open in a browser can send it one - including deleting the backup on Google Drive, with no trash to restore it from. It moves to a private socket the next time it starts.":
      "Montowanie uruchomiła starsza wersja CloudMachine i nadal przyjmuje polecenia na %@ bez hasła. Każda strona otwarta w przeglądarce może je wysłać - łącznie z usunięciem kopii na Google Drive, bez kosza, z którego dałoby się ją odzyskać. Przejdzie na prywatne gniazdo przy następnym starcie.",
    "Restart the mount: the image is detached, everything waits until it has reached Google Drive, the mount starts again and the image is attached. It takes a few minutes, during which Time Machine has no destination. Or prepare the shutdown and restart the Mac:":
      "Zrestartuj montowanie: obraz zostanie odłączony, wszystko poczeka, aż dotrze na Google Drive, montowanie wystartuje od nowa, a obraz zostanie podłączony. To trwa kilka minut, w tym czasie Time Machine nie ma celu. Albo przygotuj zamknięcie i zrestartuj Maca:",
    "Wait until the backup has finished.":
      "Poczekaj, aż kopia się skończy.",
    "Restart the Google Drive mount now?":
      "Zrestartować teraz montowanie Google Drive?",
    "Restart the mount":
      "Zrestartuj montowanie",
    "Cancel":
      "Anuluj",
    "Time Machine loses its destination for a few minutes. Nothing is stopped until everything waiting has reached Google Drive; if that does not happen, the mount is left as it is.":
      "Time Machine straci cel na kilka minut. Nic nie zostanie zatrzymane, dopóki wszystko, co czeka, nie dotrze na Google Drive; jeśli to się nie uda, montowanie zostaje bez zmian.",
    "Drive remote control is open - restart the mount":
      "Sterowanie Dyskiem jest otwarte - zrestartuj montowanie",
    "The mount was restarted and now listens only on the private socket. The image is attached again.":
      "Montowanie zostało zrestartowane i słucha już tylko na prywatnym gnieździe. Obraz jest znowu podłączony.",
    "Another operation on the image is in progress - the mount was NOT restarted. Try again in a moment.":
      "Trwa inna operacja na obrazie - montowanie NIE zostało zrestartowane. Spróbuj ponownie za chwilę.",
    "Could not read the mount table - it is UNKNOWN whether the image is attached.":
      "Nie udało się odczytać tablicy montowań - NIE WIADOMO, czy obraz jest podłączony.",
    "Time Machine is backing up right now - the mount was NOT restarted. Try again when the backup has finished.":
      "Time Machine właśnie robi kopię - montowanie NIE zostało zrestartowane. Spróbuj ponownie, gdy kopia się skończy.",
    "Could not tell whether Time Machine is backing up (tmutil did not answer) - the mount was NOT restarted.":
      "Nie wiadomo, czy Time Machine robi kopię (tmutil nie odpowiedział) - montowanie NIE zostało zrestartowane.",
    "The Google Drive mount is not running (or its state is unknown) - there is nothing to restart. The agents start it by themselves.":
      "Montowanie Google Drive nie działa (albo jego stan jest nieznany) - nie ma czego restartować. Agenci uruchamiają je sami.",
    "The mount was NOT restarted: %@\nImage: %@":
      "Montowanie NIE zostało zrestartowane: %@\nObraz: %@",
    "Could not stop the mount (launchctl refused) - nothing was restarted. Image: %@":
      "Nie udało się zatrzymać montowania (launchctl odmówił) - nic nie zostało zrestartowane. Obraz: %@",
    "The mount was stopped, but did not come back on the private socket in time. The agents keep trying (backup-health reloads one launchd cannot start). Check: cloudmachine-agent drive-status; if it stays down, restart the Mac.":
      "Montowanie zostało zatrzymane, ale nie wróciło na czas na prywatnym gnieździe. Agenci dalej próbują (backup-health przeładowuje agenta, którego launchd nie potrafi uruchomić). Sprawdź: cloudmachine-agent drive-status; jeśli dalej nie działa, zrestartuj Maca.",
    "The mount runs on the private socket now, but the image did not attach: %@ The attach agent retries every 15 minutes.":
      "Montowanie działa już na prywatnym gnieździe, ale obraz się nie podłączył: %@ Agent podłączania próbuje co 15 minut.",
    "The image kept being refused - the Google Drive mount was restarted: %@":
      "Obraz był wciąż odrzucany - montowanie Dysku Google zostało zrestartowane: %@",
    "CloudMachine: Drive remote control is open":
      "CloudMachine: sterowanie Dyskiem jest otwarte",
    "Any web page can send it commands, including deleting the backup. Open CloudMachine and restart the mount, or run prepare-shutdown and restart the Mac.":
      "Każda strona WWW może wysyłać mu polecenia, łącznie z usunięciem kopii. Otwórz CloudMachine i zrestartuj montowanie albo uruchom prepare-shutdown i zrestartuj Maca.",
  ]
}
