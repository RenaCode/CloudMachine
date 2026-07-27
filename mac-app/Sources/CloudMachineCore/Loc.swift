import Foundation

public enum Loc {
    public static var currentLanguage: String {
        get {
            UserDefaults.standard.string(forKey: "CM_Language") ?? "pl"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "CM_Language")
            NotificationCenter.default.post(name: Notification.Name("CMLanguageChanged"), object: nil)
        }
    }

    private static let translations: [String: [String: String]] = [
        "en": [
            "Narzędzia": "Tools",
            "Status": "Status",
            "Kreator": "Wizard",
            "Maszyny i limity": "Machines & Limits",
            "Logi systemowe": "System Logs",
            "Stan systemu": "System Status",
            "Kreator konfiguracji": "Configuration Wizard",
            "Zarządzanie maszynami i limitami": "Machine & Limit Management",
            "Logi konsoli": "Console Logs",
            "Problem z konfiguracją": "Configuration Problem",
            "Połączono z chmurą": "Connected to Cloud",
            "Montowanie...": "Mounting...",
            "Błąd montowania": "Mounting Error",
            "Brak połączenia": "No Connection",
            "NFS wolumin gotowy": "NFS Volume Ready",
            "Nawiązywanie połączenia...": "Connecting...",
            "Dysk nie jest zamontowany": "Disk is not mounted",
            "Wyloguj": "Log Out",
            "Język": "Language",
            "Język / Language": "Language",
            // SetupWizardView
            "Konfiguracja CloudMachine": "CloudMachine Setup",
            "Ten kreator pomoże Ci skonfigurować połączenie z Google Drive przy użyciu Rclone, zainstalować demona montującego i ustawić pierwszą maszynę.": "This wizard will help you set up connection to Google Drive using Rclone, install the mount daemon, and set up your first machine.",
            "Połączenie Google Drive": "Google Drive Connection",
            "Nazwa pilota Rclone": "Rclone remote name",
            "Ścieżka w chmurze (katalog główny)": "Cloud root path",
            "Całkowity rozmiar dysku (GB)": "Total drive size (GB)",
            "Margines bezpieczeństwa (%)": "Safety margin (%)",
            "Pierwsza maszyna": "First Machine",
            "Nazwa komputera (klucz, np. macbook-pro)": "Computer key (e.g., macbook-pro)",
            "Nazwa wyświetlana (np. MacBook Pro)": "Display name (e.g., MacBook Pro)",
            "Limit dysku (GB)": "Disk limit (GB)",
            "Zainstaluj demona": "Install Daemon",
            "Wymagane hasło sudo w konsoli": "Sudo password required in console",
            "Zapisz konfigurację": "Save Configuration",
            "Dalej": "Next",
            "Wstecz": "Back",
            "Zakończ": "Finish",
            // LogsView
            "Filtruj logi...": "Filter logs...",
            "Wyczyść": "Clear",
            "Odśwież": "Refresh",
            "Wszystkie": "All",
            "Błędy": "Errors",
            "Transfery rclone": "rclone transfers",
            "Szukaj w logach...": "Search logs...",
            "Filtr:": "Filter:",
            "Autoprzewijanie": "Auto-scroll",
            "Folder logów": "Log Folder",
            "Brak wpisów pasujących do wybranych filtrów.": "No entries matching selected filters.",
            // MenuBarContentView
            "Pokaż główne okno": "Show Main Window",
            "Zamontuj dysk": "Mount Disk",
            "Odmontuj dysk": "Unmount Disk",
            "Zakończ CloudMachine": "Quit CloudMachine",
            "Rozpocznij backup teraz": "Start Backup Now",
            "Panel sterowania": "Control Panel",
            "Połączono": "Connected",
            "Łączenie...": "Connecting...",
            "Rozłączono": "Disconnected",
            "Błąd": "Error",
            "Nieznany": "Unknown",
            "Limit przestrzeni": "Space Limit",
            // StatusView
            "Stan połączenia": "Connection Status",
            "Aktywne zadania": "Active Tasks",
            "Konfiguracja": "Configuration",
            "Zarządzaj": "Manage",
            "Szczegóły": "Details",
            "Margines": "Margin",
            "Zajęte miejsce": "Used Space",
            "Darmowe miejsce": "Free Space",
            "Limity maszyn": "Machine Limits",
            "Razem przydzielono": "Total Allocated",
            "Budżet bezpieczeństwa": "Safety Budget",
            "Kopia zapasowa Time Machine": "Time Machine Backup",
            "Nie skonfigurowano dysku Time Machine": "Time Machine backup not configured",
            "Ostatnia weryfikacja": "Last verification",
            "Nigdy": "Never",
            "Weryfikacja w toku": "Verification in progress",
            "Rozpocznij weryfikację": "Start Verification",
            "Uruchom demona": "Start Daemon",
            "Zatrzymaj demona": "Stop Daemon",
            "Otwórz katalog w Finderze": "Open Folder in Finder",
            "Otwórz w Finderze": "Open in Finder",
            // MachinesConfigView
            "Dodaj maszynę": "Add Machine",
            "Dodawanie nowej maszyny": "Adding New Machine",
            "Klucz maszyny": "Machine key",
            "Nazwa wyświetlana": "Display name",
            "Limit (GB)": "Limit (GB)",
            "Anuluj": "Cancel",
            "Dodaj": "Add",
            "Brak maszyn": "No machines",
            "Przekroczono budżet bezpieczeństwa!": "Safety budget exceeded!",
            "Suma limitów maszyn wynosi": "The sum of machine limits is",
            "GB, podczas gdy bezpieczny budżet to": "GB, while the safety budget is",
            "GB. Zmniejsz limity lub zwiększ rozmiar dysku w Ustawieniach.": "GB. Decrease limits or increase drive size in Settings.",
            "Zapisano pomyślnie": "Saved successfully",
            "Błąd zapisu": "Error saving",
            "Zapisz zmiany": "Save Changes",
            "Zarządzanie maszyną": "Machine Management",
        ]
    ]

    public static func translate(_ text: String) -> String {
        let lang = currentLanguage
        if lang == "en" {
            return translations["en"]?[text] ?? text
        }
        return text
    }
}

extension String {
    public var localized: String {
        return Loc.translate(self)
    }
}
