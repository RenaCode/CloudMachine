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
  ]
}
