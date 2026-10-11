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
  ]
}
