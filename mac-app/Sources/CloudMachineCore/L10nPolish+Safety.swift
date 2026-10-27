// Polish translations, keyed by the English text passed to `L10n.tr`.
// Texts added with the second audit (October 2026): the open remote-control
// port, replacing the Google credential, the usage measurement.
extension L10nPolish {
  static let safety: [String: String] = [
    // MachineBudget
    "Usage on Google Drive is not being measured":
      "Zajętość na Google Drive nie jest mierzona",
    "The last measurement (%@ GB) is from %@, %@ ago - rclone size has not answered since. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "Ostatni pomiar (%@ GB) jest z %@, sprzed %@ - od tamtej pory rclone size nie odpowiada. Dopóki nie odpowie, nikt nie pilnuje limitu %@ GB: alarmy 90%% i 100%% milczą. Sprawdź vm-status albo naciśnij „Zmierz teraz” w oknie.",
    "rclone size has not answered even once. Until it does, nothing watches the %@ GB limit: the 90%% and 100%% alarms stay silent. Check vm-status, or press Measure now in the window.":
      "rclone size nie odpowiedział ani razu. Dopóki nie odpowie, nikt nie pilnuje limitu %@ GB: alarmy 90%% i 100%% milczą. Sprawdź vm-status albo naciśnij „Zmierz teraz” w oknie.",
    // Replacing the Google credential
    "Saved in the Keychain. Connecting Google Drive (configure-remote) will use them.":
      "Zapisane w Keychainie. Łączenie z Google Drive (configure-remote) ich użyje.",
    "Saved in the Keychain. The existing Google Drive connection keeps its old client_id, and on this Mac it should stay that way: a connection made with the new keys (the 'drive.file' scope) cannot see the backup created by the old one. Do not replace the connection here; the new keys are for a Mac that is not connected yet.":
      "Zapisane w Keychainie. Istniejące połączenie z Google Drive zostaje przy starym client_id i na tym Macu tak ma zostać: połączenie z nowymi kluczami (zakres 'drive.file') nie widzi kopii założonej przez stare. Nie wymieniaj tu połączenia; nowe klucze są dla Maca, który jeszcze nie jest połączony.",
    "it is not there for the new token":
      "dla nowego tokenu jej nie ma",
    "Cancel":
      "Anuluj",
  ]
}
