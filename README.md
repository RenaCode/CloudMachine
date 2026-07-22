# ☁️ CloudMachine

[![License: MIT](https://img.shields.io/badge/Licencja-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: macOS 14+](https://img.shields.io/badge/Platforma-macOS%2014%2B-blue.svg)](#)
[![Status: Experimental](https://img.shields.io/badge/Status-Eksperymentalny-orange.svg)](#)

Natywne rozwiązanie Time Machine dla wielu komputerów Mac, tworzące kopie zapasowe na wspólnym dysku Google Drive (np. Google One/Workspace), z twardym limitem przestrzeni nałożonym na każdą maszynę, aby jedna z nich nie zajęła całej puli pamięci.

---

## ⚠️ Status: Eksperymentalny

Ten projekt umożliwia **prawdziwe, natywne kopie zapasowe Time Machine** (z pełną historią wersji, natywnym interfejsem przeglądania „Wehikuł czasu” oraz możliwością przywracania przez Migration Assistant) zamiast prostych narzędzi do synchronizacji plików, takich jak `rsync` lub `restic`.

Działa to poprzez montowanie podfolderu na Google Drive jako lokalnego woluminu za pomocą `rclone nfsmount` (wbudowany serwer NFS w rclone, montowany natywnym klientem NFS w macOS – bez potrzeby instalowania FUSE lub rozszerzeń jądra) i wskazanie go jako cel Time Machine za pomocą `tmutil setdestination`.

Rozwiązanie to **nie jest** oficjalnie wspierane ani przez Apple, ani przez Google. Zanim zaufasz mu w kwestii najważniejszych kopii zapasowych, **koniecznie wykonaj plan testowy** opisany poniżej. Znane ryzyka i ograniczenia:

- **Wydajność i transfer**: Time Machine wykonuje wiele małych, losowych zapisów do plików „band” (~8MB każdy) wewnątrz pakietu kopii zapasowej. Google Drive nie obsługuje częściowej aktualizacji plików – każda zmiana w bandzie wymaga ponownego przesłania całego pliku o rozmiarze 8MB. Może to spowolnić pierwszy backup oraz duże przyrostowe aktualizacje i zużyć dużo transferu sieciowego.
- **Limity API Google Drive**: Domyślny limit to około 10 zapytań na sekundę. Duża liczba operacji na małych plikach (typowa dla Time Machine) może być ograniczana (throttling) przez `rclone`, co dodatkowo spowalnia proces.
- **Ryzyko spójności**: Montowanie przez lokalną pętlę NFS (nawet z `--vfs-cache-mode full`) nie gwarantuje takiego samego poziomu blokowania plików jak lokalny dysk SSD lub fizyczny udział SMB. Dlatego projekt zawiera skrypt weryfikacji sum kontrolnych (`scripts/verify-backup.sh`) – regularna weryfikacja jest wysoce zalecana.
- **Brak potrzeby FUSE**: Standardowy build `rclone` z Homebrew nie posiada wbudowanego wsparcia FUSE na macOS. Stąd `mount.sh` korzysta z `rclone nfsmount`, które używa wbudowanego klienta NFS systemu macOS. Dzięki temu nie trzeba instalować sterowników firm trzecich (takich jak FUSE-T lub macFUSE) ani wpisywać hasła administratora przy każdym montowaniu.

*Alternatywa*: Jeśli to rozwiązanie okaże się niestabilne dla Twojego przepływu pracy, rozważ użycie [Kopia](https://kopia.io) – narzędzia open-source z natywnym wsparciem dla Google Drive, deduplikacją, szyfrowaniem i politykami retencji. Chociaż Kopia nie integruje się z systemowym Time Machine, struktura katalogów dla wielu maszyn i watchdog mogą być łatwo do niej dostosowane.

---

## 📋 Wymagania

- System macOS 14 (Sonoma) lub nowszy, z uprawnieniami administratora.
- Konto Google z wolną przestrzenią (np. pakiet Google One lub Workspace) i włączonym Google Drive API.
- **Narzędzia**: Homebrew, `rclone` oraz `jq`. Skrypt instalacyjny sprawdzi ich obecność i w razie potrzeby zainstaluje je automatycznie.

---

## 🚀 Konfiguracja i instalacja (wykonaj na każdym Macu)

### 1. Zainstaluj zależności
Uruchom skrypt instalacyjny, aby automatycznie przygotować wymagane pakiety:
```bash
./scripts/install.sh
```

### 2. Skonfiguruj limity maszyn
Skopiuj przykładowy plik konfiguracyjny i dostosuj nazwy komputerów oraz limity pamięci:
```bash
cp config/machines.example.json config/machines.json
$EDITOR config/machines.json
```
Klucze maszyn w pliku JSON muszą odpowiadać znormalizowanym nazwom komputerów (małe litery, cyfry i myślniki, np. `macbook-pro-biuro`). Jeśli nie masz pewności, jaki klucz generuje Twój Mac, uruchom dowolny skrypt (np. `scripts/common.sh`), który wypisze wykryty identyfikator.

### 3. Połącz z Google Drive
Autoryzuj `rclone` do dostępu do Twojego konta Google Drive (otworzy się przeglądarka w celu zalogowania się przez OAuth):
```bash
./scripts/configure-remote.sh
```

### 4. Zamontuj wolumin
Zamontuj dedykowany folder z Google Drive jako wirtualny wolumin NFS:
```bash
./scripts/mount.sh
```
*Uwaga:* Przy pierwszym uruchomieniu skrypt automatycznie utworzy wirtualny obraz `.sparsebundle` i wyśle go bezpośrednio do chmury (bypassing NFS). Może to zająć od 15 do 45 sekund w zależności od Twojego łącza i opóźnień API Google Drive. Każde kolejne montowanie będzie natychmiastowe (mniej niż 3 sekundy).

### 5. Zarejestruj cel w Time Machine
Zarejestruj zamontowany wirtualny dysk sparsebundle jako cel dla kopii zapasowych (wymaga autoryzacji administratora):
```bash
./scripts/setup-timemachine.sh
```

### 6. Włącz automatyzację w tle
Zainstaluj usługi w tle, które automatycznie zamontują dysk po starcie systemu i będą kontrolować limity przestrzeni w chmurze:
```bash
./scripts/install-launchd.sh
```

---

## 🖥️ Aplikacja GUI (Menu Bar + Dashboard)

Oprócz skryptów konsolowych, w katalogu [`mac-app/`](mac-app) znajduje się natywna aplikacja SwiftUI dla systemu macOS. Oferuje ona ikonę w pasku menu oraz panel sterowania do monitorowania stanu kopii, zarządzania limitami i przeglądania logów.

Jest to lekka nakładka graficzna na skrypty z folderu `scripts/`. W przypadku operacji wymagających uprawnień roota (takich jak rejestracja dysku w Time Machine czy czyszczenie starych kopii) aplikacja wyświetli systemowe okno autoryzacji (Touch ID / hasło) zamiast wymagać ręcznej konfiguracji sudoers.

### Budowanie aplikacji
Aby ręcznie zbudować i spakować aplikację:
```bash
cd mac-app
./scripts/build-app.sh   # Kompilacja wersji Release, budowanie paczki .app i podpis ad-hoc
./scripts/make-dmg.sh    # Pakowanie build/CloudMachine.app do pliku build/CloudMachine-<wersja>.dmg
```

### Pierwsze uruchomienie
Aplikacja jest podpisana ad-hoc (bez certyfikatu Apple Developer):
1. Przeciągnij `CloudMachine.app` z pliku `.dmg` do folderu `/Applications`.
2. **Kliknij prawym przyciskiem myszy** na ikonę aplikacji i wybierz **Otwórz** (zwykłe dwukliknięcie wywoła blokadę Gatekeepera). Zatwierdź ostrzeżenie o niezidentyfikowanym deweloperze.
3. Każde kolejne uruchomienie będzie działać standardowo przez dwuklik.

---

## 🔒 Wymagania dotyczące dostępu do dysku (Full Disk Access)

> [!IMPORTANT]
> Ze względów bezpieczeństwa system macOS wymaga nadania uprawnień **Pełnego dostępu do dysku (Full Disk Access)** dla procesów zarządzających kopiami zapasowymi oraz tworzeniem dysków wirtualnych. Bez tego uprawnienia system operacyjny zablokuje wewnętrzne mechanizmy `hdiutil` (tworzenie i montowanie wirtualnych obrazów APFS), co doprowadzi do zawieszenia podsystemu dysków wirtualnych i błędów typu `No child processes` lub `Resource busy`.
> 
> Przed uruchomieniem skryptów lub aplikacji dodaj aplikację **Terminal** (oraz **CloudMachine.app**, jeśli korzystasz z GUI) w panelu:
> *Ustawienia systemowe -> Prywatność i bezpieczeństwo -> Dostęp do pełnego dysku*.

---

## 🧪 Plan testowy (zrób to, zanim zaufasz temu rozwiązaniu)

1. **Wyklucz duże katalogi**: Tymczasowo wyklucz duże foldery (np. Pobrane rzeczy, ciężkie projekty) w ustawieniach Time Machine (*Ustawienia systemowe -> Time Machine -> Opcje*), aby pierwszy test przebiegł szybko.
2. **Uruchom ręcznie pierwszą kopię**:
   ```bash
   sudo tmutil startbackup --auto --block
   ```
3. **Zweryfikuj integralność**:
   ```bash
   ./scripts/verify-backup.sh
   ```
4. **Przetestuj kopie przyrostowe**: Uruchom proces 2-3 razy. Monitoruj czas trwania i zużycie transferu w logu `~/Library/Logs/CloudMachine/rclone-mount.log`.
5. **Włącz pełny backup**: Jeśli weryfikacje przebiegły bez błędów, usuń tymczasowe wykluczenia i pozwól Time Machine na zabezpieczenie całego dysku.

Jeśli skrypt `verify-backup.sh` zgłosi błąd sumy kontrolnej na dowolnym etapie, **natychmiast zatrzymaj backup** i przejrzyj logi.

---

## 🩺 Watchdog montowania

`scripts/mount-watchdog.sh` (agent `com.renacode.cloudmachine.mount-watchdog`, instalowany przez krok 5 kreatora / `install-launchd.sh`) sprawdza co 60 sekund, czy wolumin NFS + wirtualny dysk sparsebundle są nie tylko zamontowane, ale też realnie odpowiadają, i naprawia je automatycznie (wymuszone odmontowanie, ubicie zawieszonego procesu `rclone`, ponowne zamontowanie), jeśli nie odpowiadają - dokładnie ten scenariusz "serwer nie odpowiada -> trzeba odłączyć -> proces się zawiesza".

Watchdog działa dopóki dysk **powinien** być zamontowany: włącza się automatycznie po udanym montowaniu (przycisk "Zamontuj" / `mount.sh`) i wyłącza się natychmiast po kliknięciu "Odmontuj" (`unmount.sh`) - nie będzie na siłę przywracał montowania, którego jawnie się pozbyłeś. Stan ten trzyma plik `mount-desired.state` obok `machines.json`.

Zanim wolumin zacznie się faktycznie pojawiać jako drugi dysk w Time Machine, zarejestruj go RAZ przyciskiem "Zarejestruj w Time Machine" (krok 4 kreatora) - odtąd `tmutil` rozpoznaje go po UUID i watchdog musi już tylko utrzymywać wolumin zamontowany pod tą samą ścieżką (`/Volumes/CloudMachine-Backup-<maszyna>`).

---

## 🔒 Automatyczne przycinanie i Watchdog limitu

Demon `quota-watchdog.sh` korzysta z polecenia `sudo tmutil delete` w tle. Aby umożliwić mu automatyczne usuwanie najstarszych kopii (bez interaktywnego pytania o hasło administratora), dodaj dedykowaną regułę sudoers:

```bash
sudo visudo -f /etc/sudoers.d/cloudmachine
```

Wklej poniższą linię (zastąp `TWÓJ_LOGIN` wynikiem polecenia `whoami`):

```
TWÓJ_LOGIN ALL=(root) NOPASSWD: /usr/bin/tmutil delete -p *
```

---

## 📊 Monitorowanie logów

Aby śledzić aktywność procesów w tle:
```bash
tail -f ~/Library/Logs/CloudMachine/*.log
launchctl list | grep renacode.cloudmachine
tmutil destinationinfo
```

---

## 🧹 Odinstalowanie

Aby całkowicie usunąć daemony, konfiguracje i cele Time Machine z systemu:

```bash
launchctl unload ~/Library/LaunchAgents/com.renacode.cloudmachine.mount-watchdog.plist
launchctl unload ~/Library/LaunchAgents/com.renacode.cloudmachine.watchdog.plist
rm ~/Library/LaunchAgents/com.renacode.cloudmachine.*.plist
sudo tmutil removedestination <ID z polecenia tmutil destinationinfo>
./scripts/unmount.sh
```

---

## 📄 Licencja

Projekt udostępniany na warunkach licencji MIT. Szczegóły w pliku [LICENSE](LICENSE).
