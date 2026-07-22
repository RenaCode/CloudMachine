# ☁️ CloudMachine

[![License: MIT](https://img.shields.io/badge/Licencja-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: macOS 14+](https://img.shields.io/badge/Platforma-macOS%2014%2B-blue.svg)](#)
[![Status: Experimental](https://img.shields.io/badge/Status-Eksperymentalny-orange.svg)](#)
[![CI](https://github.com/RenaCode/CloudMachine/actions/workflows/ci.yml/badge.svg)](https://github.com/RenaCode/CloudMachine/actions/workflows/ci.yml)

Natywne rozwiązanie Time Machine dla wielu komputerów Mac, tworzące kopie zapasowe na wspólnym dysku Google Drive (np. Google One/Workspace), z twardym limitem przestrzeni nałożonym na każdą maszynę, aby jedna z nich nie zajęła całej puli pamięci.

---

## ⚠️ Status: Eksperymentalny

Ten projekt umożliwia **prawdziwe, natywne kopie zapasowe Time Machine** (z pełną historią wersji, natywnym interfejsem przeglądania „Wehikuł czasu” oraz możliwością przywracania przez Migration Assistant) zamiast prostych narzędzi do synchronizacji plików, takich jak `rsync` lub `restic`.

Działa to poprzez montowanie podfolderu na Google Drive jako lokalnego woluminu za pomocą `rclone nfsmount` (wbudowany serwer NFS w rclone, montowany natywnym klientem NFS w macOS – bez potrzeby instalowania FUSE lub rozszerzeń jądra) i wskazanie go jako cel Time Machine za pomocą `tmutil setdestination`.

Rozwiązanie to **nie jest** oficjalnie wspierane ani przez Apple, ani przez Google. Zanim zaufasz mu w kwestii najważniejszych kopii zapasowych, **koniecznie wykonaj plan testowy** opisany poniżej. Znane ryzyka i ograniczenia:

- **Wydajność i transfer**: Time Machine wykonuje wiele małych, losowych zapisów do plików „band” (~8MB każdy) wewnątrz pakietu kopii zapasowej. Google Drive nie obsługuje częściowej aktualizacji plików – każda zmiana w bandzie wymaga ponownego przesłania całego pliku o rozmiarze 8MB. Może to spowolnić pierwszy backup oraz duże przyrostowe aktualizacje i zużyć dużo transferu sieciowego.
- **Limity API Google Drive**: Domyślny limit to około 10 zapytań na sekundę. Duża liczba operacji na małych plikach (typowa dla Time Machine) może być ograniczana (throttling) przez `rclone`, co dodatkowo spowalnia proces - patrz sekcja "Własny client_id Google" poniżej, jak to złagodzić.
- **Duży przerwany backup może się nie zmieścić w standardowym czasie oczekiwania**: jeśli backup zostanie przerwany (np. Mac zaśnie, Wi-Fi się zerwie) w trakcie kopiowania dużej ilości danych, `rclone` musi dogonić zaległą kolejkę uploadów, zanim wolumin znów stanie się dostępny - i celowo nie uruchamia serwera NFS, dopóki tego nie zrobi. Mount-watchdog (patrz niżej) rozpoznaje ten stan i czeka cierpliwie zamiast przerywać postęp, ale samo dogonienie dużej kolejki może zająć od kilku do kilkudziesięciu minut.
- **Ryzyko spójności**: Montowanie przez lokalną pętlę NFS (nawet z `--vfs-cache-mode full`) nie gwarantuje takiego samego poziomu blokowania plików jak lokalny dysk SSD lub fizyczny udział SMB. Dlatego projekt zawiera skrypt weryfikacji sum kontrolnych (`scripts/verify-backup.sh`) – regularna weryfikacja jest wysoce zalecana.
- **Brak potrzeby FUSE**: Standardowy build `rclone` z Homebrew nie posiada wbudowanego wsparcia FUSE na macOS. Stąd `mount.sh` korzysta z `rclone nfsmount`, które używa wbudowanego klienta NFS systemu macOS. Dzięki temu nie trzeba instalować sterowników firm trzecich (takich jak FUSE-T lub macFUSE) ani wpisywać hasła administratora przy każdym montowaniu.

*Alternatywa*: Jeśli to rozwiązanie okaże się niestabilne dla Twojego przepływu pracy, rozważ użycie [Kopia](https://kopia.io) – narzędzia open-source z natywnym wsparciem dla Google Drive, deduplikacją, szyfrowaniem i politykami retencji. Chociaż Kopia nie integruje się z systemowym Time Machine, struktura katalogów dla wielu maszyn i watchdog mogą być łatwo do niej dostosowane.

---

## 📋 Wymagania

- System macOS 14 (Sonoma) lub nowszy, z uprawnieniami administratora.
- Konto Google z wolną przestrzenią (np. pakiet Google One lub Workspace) i włączonym Google Drive API.
- **Narzędzia**: Homebrew, `rclone` oraz `jq`. Aplikacja GUI (i skrypt `install.sh`) sprawdzą ich obecność i w razie potrzeby zainstalują je automatycznie.

---

## 🚀 Szybki start (aplikacja GUI)

To zalecany sposób instalacji dla większości użytkowników - Kreator w aplikacji wykonuje za Ciebie wszystkie kroki opisane niżej w sekcji "Instalacja z linii poleceń" (zależności, połączenie z Google Drive, montowanie, rejestracja w Time Machine, automatyzacja w tle), łącznie z konfiguracją sudoers (jeden prompt o hasło administratora zamiast ręcznej edycji `/etc/sudoers.d`).

1. Pobierz `CloudMachine-<wersja>.dmg` (patrz [Budowanie aplikacji](#-budowanie-aplikacji-ze-źródeł), jeśli budujesz sam) i przeciągnij `CloudMachine.app` do `/Applications`.
2. **Kliknij prawym przyciskiem myszy** na ikonę aplikacji i wybierz **Otwórz** (zwykłe dwukliknięcie wywoła blokadę Gatekeepera, bo appka nie jest podpisana certyfikatem Apple Developer). Zatwierdź ostrzeżenie o niezidentyfikowanym deweloperze. Każde kolejne uruchomienie działa już zwykłym dwuklikiem.
3. Otwórz appkę z paska menu i przejdź przez **Kreator** krok po kroku: zależności → połączenie z Google Drive → konfiguracja tej maszyny (nazwa + limit) → montowanie i rejestracja w Time Machine → automatyzacja w tle.
4. Zanim zaufasz temu w pełni, wykonaj [plan testowy](#-plan-testowy-zrób-to-zanim-zaufasz-temu-rozwiązaniu) poniżej.
5. Rozważ też [własny Google API client_id](#-własny-client_id-google-zalecane) - domyślny, współdzielony przez wszystkich użytkowników `rclone`, bywa ograniczany (throttling) pod większym obciążeniem.

---

## 🔒 Wymagania dotyczące dostępu do dysku (Full Disk Access)

> [!IMPORTANT]
> Ze względów bezpieczeństwa system macOS wymaga nadania uprawnień **Pełnego dostępu do dysku (Full Disk Access)** dla procesów zarządzających kopiami zapasowymi oraz tworzeniem dysków wirtualnych. Bez tego uprawnienia system operacyjny zablokuje wewnętrzne mechanizmy `hdiutil` (tworzenie i montowanie wirtualnych obrazów APFS) oraz `tmutil` (rejestracja/backup), co doprowadzi do błędów typu `Resource busy` lub `setdestination requires Full Disk Access privileges`.
>
> Przed uruchomieniem skryptów lub aplikacji dodaj aplikację **Terminal** (oraz **CloudMachine.app**, jeśli korzystasz z GUI) w panelu:
> *Ustawienia systemowe -> Prywatność i bezpieczeństwo -> Dostęp do pełnego dysku*.
>
> Jeśli budujesz aplikację samodzielnie ze źródeł: domyślny podpis ad-hoc generuje nowy identyfikator przy **każdej** przebudowie, więc macOS cofa wcześniej przyznane Full Disk Access po każdym rebuildzie. Uruchom `mac-app/scripts/setup-local-signing-cert.sh` raz (tworzy lokalny, samopodpisany certyfikat code-signing), żeby tożsamość appki - a więc i przyznane uprawnienie - przetrwały kolejne przebudowy. `build-app.sh` użyje go automatycznie, jeśli istnieje.

---

## 🩺 Watchdog montowania

`scripts/mount-watchdog.sh` (agent `com.renacode.cloudmachine.mount-watchdog`, instalowany przez krok 5 kreatora / `install-launchd.sh`) sprawdza co 60 sekund, czy wolumin NFS + wirtualny dysk sparsebundle są nie tylko zamontowane, ale też realnie odpowiadają, i naprawia je automatycznie (wymuszone odmontowanie, ubicie zawieszonego procesu `rclone`, ponowne zamontowanie), jeśli nie odpowiadają - dokładnie ten scenariusz "serwer nie odpowiada -> trzeba odłączyć -> proces się zawiesza".

Watchdog rozpoznaje różnicę między "realnie zawieszony" a "`rclone` właśnie dogania dużą zaległą kolejkę uploadów po przerwanym backupie" (patrz ryzyko w sekcji Status wyżej) - w tym drugim przypadku czeka, zamiast przerywać postęp restartem.

Watchdog działa dopóki dysk **powinien** być zamontowany: włącza się automatycznie po udanym montowaniu (przycisk "Zamontuj" / `mount.sh`) i wyłącza się natychmiast po kliknięciu "Odmontuj" (`unmount.sh`) - nie będzie na siłę przywracał montowania, którego jawnie się pozbyłeś. Stan ten trzyma plik `mount-desired.state` obok `machines.json`.

Zanim wolumin zacznie się faktycznie pojawiać jako drugi dysk w Time Machine, zarejestruj go RAZ przyciskiem "Zarejestruj w Time Machine" (krok 4 kreatora) - odtąd `tmutil` rozpoznaje go po UUID i watchdog musi już tylko utrzymywać wolumin zamontowany pod tą samą ścieżką (`/Volumes/CloudMachine-Backup-<maszyna>`).

> [!NOTE]
> Jeśli kiedykolwiek trzeba odtworzyć `backup.sparsebundle` od zera (np. po nieodwracalnym błędzie `hdiutil: no mountable file systems`), dysk dostaje nowy UUID - `tmutil` będzie wtedy pokazywał go jako rozłączony, dopóki nie klikniesz "Zarejestruj w Time Machine" ponownie. Stary, martwy wpis warto potem usunąć: `sudo tmutil removedestination <stare ID z tmutil destinationinfo>`.

---

## 🔑 Własny client_id Google (zalecane)

Domyślnie `rclone` loguje się przez **współdzielony identyfikator aplikacji (client_id)**, z którego korzystają wszyscy użytkownicy `rclone` na świecie - limit zapytań/sekundę do Google Drive API jest więc dzielony globalnie, co pod większym obciążeniem (duży pierwszy backup, dużo małych plików band) prowadzi do throttlingu i spowolnień. Własny, prywatny client_id to darmowe, jednorazowe ustawienie w Google Cloud Console, które daje Ci własny, nieudostępniany limit.

1. Wejdź na [console.cloud.google.com](https://console.cloud.google.com) i zaloguj się kontem Google używanym do Drive.
2. Utwórz nowy projekt (selektor projektu u góry → *Nowy projekt*).
3. **APIs & Services → Library** → wyszukaj **Google Drive API** → **Enable**.
4. **APIs & Services → OAuth consent screen** → User Type: **External** → Create. Wypełnij nazwę appki i e-mail kontaktowy. W sekcji **Test users** dodaj **dokładnie ten adres Gmail**, którego używasz do logowania w CloudMachine.
5. **APIs & Services → Credentials** → **+ Create Credentials → OAuth client ID** → Application type: **Desktop app** → Create.
6. Skopiuj wyświetlone **Client ID** i **Client secret**.
7. Wpisz je do istniejącego remote'a i zaloguj się ponownie (otworzy przeglądarkę):
   ```bash
   rclone config update gdrive-cloudmachine client_id "TWOJ_CLIENT_ID" client_secret "TWOJ_CLIENT_SECRET"
   ```
   Dane już zsynchronizowane na Google Drive pozostają nietknięte - zmienia się tylko sposób logowania.

Jeśli pojawi się błąd Google **"Dostęp zablokowany: aplikacja nie przeszła weryfikacji"** - to znaczy, że logujesz się kontem, którego nie dodałeś jako Test user w kroku 4. Dodaj je i spróbuj ponownie.

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

## 🔒 Automatyczne przycinanie starych kopii (limit miejsca)

Osobny demon, `quota-watchdog.sh` (agent `com.renacode.cloudmachine.watchdog`), pilnuje co 6h, żeby backup tej maszyny nie przekroczył limitu z `config/machines.json`, i w razie potrzeby kasuje najstarsze kopie przez `sudo tmutil delete`.

**W aplikacji GUI** to wszystko konfiguruje się jednym kliknięciem: przycisk "Zezwól na automatyczne przycinanie backupów" (krok 5 kreatora) dopisuje regułę `sudoers` z NOPASSWD dla wszystkich potrzebnych podkomend `tmutil` (`delete`, `setdestination`, `startbackup`, `verifychecksums`, `removedestination`) za jednym poproszeniem o hasło administratora - te same przyciski w Statusie/Kreatorze korzystają potem z tej reguły bez kolejnych promptów.

**Bez GUI** (czysta instalacja z linii poleceń) trzeba dodać tę regułę ręcznie:

```bash
sudo visudo -f /etc/sudoers.d/cloudmachine
```

Wklej (zastąp `TWÓJ_LOGIN` wynikiem polecenia `whoami`):

```
TWÓJ_LOGIN ALL=(root) NOPASSWD: /usr/bin/tmutil delete -p *
TWÓJ_LOGIN ALL=(root) NOPASSWD: /usr/bin/tmutil setdestination -a *
TWÓJ_LOGIN ALL=(root) NOPASSWD: /usr/bin/tmutil startbackup*
TWÓJ_LOGIN ALL=(root) NOPASSWD: /usr/bin/tmutil verifychecksums *
TWÓJ_LOGIN ALL=(root) NOPASSWD: /usr/bin/tmutil removedestination *
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

## 🖥️ Instalacja z linii poleceń (zaawansowane / bez GUI)

Te same kroki co Kreator w aplikacji GUI, wykonywane ręcznie skrypt po skrypcie. Przydatne do automatyzacji, debugowania albo jeśli wolisz nie instalować aplikacji GUI.

### 1. Zainstaluj zależności
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
Rozważ od razu użycie [własnego client_id](#-własny-client_id-google-zalecane) zamiast domyślnego, współdzielonego.

### 4. Zamontuj wolumin
```bash
./scripts/mount.sh
```
*Uwaga:* Przy pierwszym uruchomieniu skrypt automatycznie utworzy wirtualny obraz `.sparsebundle` i wyśle go bezpośrednio do chmury (bypassing NFS). Może to zająć od 15 do 45 sekund w zależności od Twojego łącza i opóźnień API Google Drive. Każde kolejne montowanie będzie natychmiastowe (mniej niż 3 sekundy), o ile nie ma zaległej kolejki uploadów do dogonienia (patrz sekcja Status).

### 5. Zarejestruj cel w Time Machine
```bash
./scripts/setup-timemachine.sh
```

### 6. Włącz automatyzację w tle
```bash
./scripts/install-launchd.sh
```

---

## 🛠️ Budowanie aplikacji ze źródeł

```bash
cd mac-app
./scripts/setup-local-signing-cert.sh   # RAZ - lokalny certyfikat, zeby FDA przetrwalo rebuildy (patrz sekcja FDA)
./scripts/build-app.sh                  # Kompilacja wersji Release, budowanie paczki .app
./scripts/make-dmg.sh                   # Pakowanie build/CloudMachine.app do pliku build/CloudMachine-<wersja>.dmg
```

Aplikacja jest lekką nakładką graficzną na skrypty z folderu `scripts/` - te same skrypty stoją za każdym przyciskiem w GUI, więc CLI i GUI zawsze zachowują się identycznie.

### CI i wydania

- Każdy push/PR uruchamia [CI](.github/workflows/ci.yml): kompilację pakietu Swift oraz sprawdzenie składni i `shellcheck` dla wszystkich skryptów bash.
- Push tagu w formacie `vX.Y.Z` uruchamia [Release DMG](.github/workflows/release.yml): buduje appkę (podpis ad-hoc, bez konta Apple Developer) i publikuje `CloudMachine-<wersja>.dmg` jako załącznik GitHub Release.

---

## 📄 Licencja

Projekt udostępniany na warunkach licencji MIT. Szczegóły w pliku [LICENSE](LICENSE).
