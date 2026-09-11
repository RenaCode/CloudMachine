# CloudMachine / warstwa Google Drive

Time Machine na Google Drive, bez dysku zewnetrznego i bez sprzetu w domu.

```
Time Machine
  -> /Volumes/CloudMachine          obraz podpiety przez hdiutil; TM widzi zwykly APFS
     -> ~/.cloudmachine/drive       rclone mount na FUSE-T
        -> ~/.cloudmachine/cache    bufor zapisu 100 GB
        -> gdrive:CloudMachine/...  Google Drive
```

Sens ukladu: **w sciezce zapisu nie ma sieciowego systemu plikow.** Time Machine
pisze do lokalnie podpietego obrazu i nie wie, ze pasma leza w chmurze. Odpada
SMB, a z nim najczestsza przyczyna psucia sie backupow sieciowych - uszkodzenie
sparsebundle przy zerwaniu polaczenia. Zapis konczy sie w buforze, wysylka idzie
w tle, wiec utrata lacza wstrzymuje drenaz zamiast przerywac backup.

## Dwie decyzje, ktore trzymaja to przy zyciu

**Pasma po 64 MB zamiast domyslnych 8 MB.** Google Drive przepuszcza okolo
dwoch operacji na plik na sekunde i ma limit 400 000 plikow. Dla 200 GB backupu
to roznica miedzy ~25 000 a ~3 200 plikow. Cena: kazda zmiana brudzi cale 64 MB
i tyle trzeba wyslac od nowa. Ustawiane wylacznie przy tworzeniu obrazu -
pozniej nie da sie tego zmienic bez zaczynania od zera.

**Wlasny client_id OAuth.** Wspoldzielony client_id rclone jest wycofywany i
przestanie dzialac w trakcie 2026 roku. Niezaleznie od tego Google limituje
tempo per client_id, wiec na wspoldzielonym konkurujesz ze wszystkimi
uzytkownikami rclone naraz.

## Instalacja

Wymagania: `rclone`, FUSE-T (`brew install macos-fuse-t/homebrew-cask/fuse-t`),
skonfigurowany remote `gdrive` z wlasnym client_id.

```sh
chmod +x gdrive/*.sh

./gdrive/mount-drive.sh &          # albo od razu przez launchd
./gdrive/create-image.sh           # raz, na starcie
./gdrive/attach-image.sh

sudo tmutil setdestination /Volumes/CloudMachine
```

Agenty launchd - podmien `__REPO__` i `__HOME__` na sciezki absolutne:

```sh
for t in gdrive gdrive-attach; do
  sed -e "s|__REPO__|$PWD|g" -e "s|__HOME__|$HOME|g" \
      "gdrive/com.renacode.cloudmachine.$t.plist.template" \
      > ~/Library/LaunchAgents/com.renacode.cloudmachine.$t.plist
  launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.renacode.cloudmachine.$t.plist
done
```

## Pierwszy backup

Ten Mac ma wlaczone usypianie, a spiacy Mac nie wysyla nic do Drive'a. Na czas
pierwszego pelnego transferu:

```sh
caffeinate -dims &
```

## Podglad

```sh
./gdrive/status.sh
```

Liczba, ktora trzeba obserwowac, to `uploadsQueued`. Jesli rosnie i nie wraca do
zera miedzy backupami, wysylka nie nadaza za zapisem i bufor sie zapelnia.

## Czego jeszcze nie sprawdzono

- Czy `hdiutil attach` na obrazie lezacym na wolumenie FUSE-T dziala stabilnie
  pod obciazeniem. FUSE-T montuje przez NFS albo FSKit, wiec obraz lezy
  technicznie na wolumenie sieciowym.
- Czy `tmutil setdestination` na macOS 26.6 przyjmie tak podpiety obraz.
- Czy rclone nigdy nie usuwa z bufora danych jeszcze niewyslanych. Zalozenie
  projektu, do potwierdzenia testem: odciac siec w trakcie backupu, przywrocic,
  odczekac na pelny drenaz, `hdiutil verify` na obrazie. Powtorzyc kilka razy.
- Limit 750 GB/dobe. Pierwszy backup (~200 GB) sie miesci, ale przyrosty
  nalezy zmierzyc. `--drive-stop-on-upload-limit` zatrzymuje rclone zamiast
  pozwalac mu kreci sie w 403.
