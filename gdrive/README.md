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

## Dwie pulapki, ktore kosztuja dzien szukania

**rclone z Homebrew nie umie montowac.** Odmawia wprost:
`rclone mount is not supported on MacOS when rclone is installed via Homebrew`.
Potrzebna jest oficjalna binarka z rclone.org - stawia ja `install-rclone.sh`
obok instalacji brew, we wlasnym katalogu, bez ruszania systemowego rclone.

**Sparsebundle nie ma sumy kontrolnej,** wiec `hdiutil verify` na nim nie dziala
(`has no checksum`). Do sprawdzania spojnosci sluzy `fsck_apfs` na podpietym
urzadzeniu - patrz `verify-image.sh`.

## Rozmiar pasma

Ustawiany wylacznie przy tworzeniu obrazu; pozniej nie da sie go zmienic bez
zaczynania backupu od zera. Dwie sily ciagna w przeciwne strony:

- Google Drive przepuszcza okolo **dwoch operacji na plik na sekunde** i ma
  limit **400 000 plikow**. To premiuje duze pasma.
- Kazda zmiana brudzi **cale** pasmo i tyle trzeba wyslac od nowa. Przy limicie
  **750 GB uploadu na dobe** to premiuje male pasma.

Zmierzone lokalnie (`poc-amplification.sh`, obraz 3 GB, zmiana 300 MB):

| Pasmo | Pasm na 3 GB | Rozrzucona zmiana | Dopisanie (jak TM) | Plikow na 200 GB |
|-------|--------------|-------------------|--------------------|------------------|
| 8 MB  | 381          | 2712 MB           | 384 MB             | 25 600           |
| 16 MB | 193          | 3040 MB           | 480 MB             | 12 800           |
| 32 MB | 99           | 3072 MB           | **672 MB**         | **6 400**        |
| 64 MB | 52           | 3136 MB           | 768 MB             | 3 200            |

Dwa wnioski, oba wbrew pierwotnemu zalozeniu.

Przy zmianie **rozrzuconej** po calym wolumenie rozmiar pasma nie ma znaczenia -
brudzi sie prawie kazde pasmo i wysyla sie w praktyce caly obraz. Ale to
najgorszy przypadek, nie ten, ktory nas dotyczy.

Przy **dopisywaniu**, czyli tym, co faktycznie robi Time Machine, transfer rosnie
monotonicznie z rozmiarem pasma: 64 MB kosztuje dokladnie dwa razy tyle co 8 MB.
Czyli duze pasma nie sa darmowe, jak zakladalem.

Stad **32 MB**, nie 64: to najmniejsze pasmo, przy ktorym pierwsza wysylka
przestaje byc ograniczona tempem operacji Drive'a (6 400 plikow, ~0,9 h przy
~2 operacjach na sekunde) i zaczyna byc ograniczona pasmem lacza (~1,3 h przy
332 Mb/s). Ponizej tego progu wydluzasz pierwszy backup, powyzej - placisz
wiekszym transferem przy kazdym przyroscie za korzysc, ktorej juz nie ma.

## Co przetrwa smierc warstwy chmurowej

`poc-pullplug.sh` odpina zastepnik montowania w trakcie zapisu do obrazu, czyli
symuluje padniecie procesu rclone albo wysypanie sie FUSE-T. Trzy rundy,
**zero nieodwracalnych strat** - obraz za kazdym razem przeszedl `fsck_apfs`.

Uwaga: zerwanie samego lacza to co innego i jest lagodniejsze. Przy
`--vfs-cache-mode full` zapis idzie do bufora na dysku, wiec brak sieci
wstrzymuje tylko wysylke; montowanie stoi i Time Machine niczego nie zauwaza.

Test ujawnil natomiast dwie pulapki w obsludze, obie juz zalatane w skryptach:

**Zombie urzadzenia.** Po wymuszonym odpieciu urzadzenie obrazu potrafi zostac
w systemie. Podpiecie zwraca wtedy martwy uchwyt, na ktorym `fsck_apfs` melduje
`failed to read container superblock` z UUID z samych zer. Wyglada to jak
skasowany backup, a jest tylko nieczytelnym urzadzeniem - pierwsza wersja tego
testu na tej podstawie trzy razy z rzedu orzekla utrate danych, ktore byly cale.
`cm_purge_stale_devices` w `cm-env.sh` sprzata je przed podpieciem.

**Osierocony punkt montowania.** Po nieczystym odpieciu katalog
`/Volumes/CloudMachine` zostaje i blokuje ponowne podpiecie komunikatem
`no mountable file systems`. Nalezy do uzytkownika, ale lezy w `/Volumes`
nalezacym do roota, wiec `rmdir` odmawia - **agent launchd dzialajacy jako
uzytkownik nie posprzata po sobie sam** i backup stoi do reczne interwencji.
`attach-image.sh` wykrywa to i wypisuje dokladne polecenie do uruchomienia.
Obejsciem docelowym byloby montowanie poza `/Volumes` (patrz `CM_TARGET`), ale
nie wiadomo, czy `tmutil setdestination` przyjmie taki cel.

**Wlasny client_id OAuth** to osobna koniecznosc: wspoldzielony client_id rclone
jest wycofywany i przestanie dzialac w trakcie 2026 roku, a Google limituje
tempo per client_id - na wspoldzielonym konkurujesz ze wszystkimi uzytkownikami
rclone naraz.

## Instalacja

```sh
chmod +x gdrive/*.sh
./gdrive/install-rclone.sh                              # binarka z obsluga mount
brew install macos-fuse-t/homebrew-cask/fuse-t          # FUSE bez kexta
rclone config                                           # remote "gdrive", wlasny client_id
```

Konfiguracja rclone z tokenami OAuth trafia do `~/.config/rclone/rclone.conf`,
poza repozytorium. To repo jest publiczne - nic z sekretami tu nie wchodzi.

```sh
./gdrive/mount-drive.sh &
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

`buffer-guard.sh` pilnuje, zeby bufor nie zjadl dysku. Time Machine pisze do
obrazu z predkoscia SSD, rclone wysyla z predkoscia lacza - roznica zostaje
w buforze. Limit `--vfs-cache-max-size` jest **miekki**: rclone usuwa z bufora
tylko dane juz wyslane, wiec gdy wszystko czeka w kolejce, bufor rosnie dalej.
Dozorca wstrzymuje Time Machine powyzej progu i wznawia, gdy wysylka nadgoni.
Pilnuje tez dobowego limitu Google Drive - po jego przekroczeniu rclone konczy
prace i nie ma sensu go podnosic, dopoki limit sie nie odnowi.

```sh
./gdrive/buffer-guard.sh          # progi: CM_BUFFER_HIGH, CM_BUFFER_LOW, CM_FREE_MIN
```


Ten Mac ma wlaczone usypianie, a spiacy Mac nie wysyla nic do Drive'a. Na czas
pierwszego pelnego transferu:

```sh
caffeinate -dims &
```

## Kaprysy montowania FUSE-T

FUSE-T montuje przez NFS (`fuse-t:/gdrive ... (nfs)`), a `hdiutil` na takim
wolumenie bywa odrzucany bledem **`RPC version wrong`**. Zmierzone zachowanie:

- Blad nie zalezy od rozmiaru obrazu ani od danych. Przy jednym przebiegu padly
  proby dla 100 GB i 400 GB, a przeszly dla 600 GB, 1000 GB i 1500 GB.
- Zalezy od **chwili**: przy pustej kolejce wysylki 5 prob na 5 udanych, przy
  rclone zajetym wysylka lub kasowaniem - losowo.

Dlatego `create-image.sh` i `attach-image.sh` czekaja na cisze (`cm_wait_quiet`,
czyta `vfs/stats` przez interfejs rc) i ponawiaja do pieciu razy. Przy tworzeniu
produkcyjnego obrazu pierwsza proba padla, druga przeszla - mechanizm nie jest
teoretyczny.

**Obraz trzeba tworzyc na miejscu, na zamontowanym Drive.** Utworzenie go
lokalnie i przeniesienie przez `mv` daje obraz, ktorego `hdiutil` pozniej nie
otwiera (`CBSDBackingStore::newProbe stat() failed`), mimo ze wszystkie pliki
i pasma sa na swoim miejscu i daja sie czytac.

Dwa inne backendy FUSE-T nie pomagaja: `backend=fskit` w ogole sie nie montuje,
`backend=smb` montuje sie, ale `hdiutil create` konczy sie `Is a directory`.

## Zabezpieczenia przed zapetleniem

Agent bufora ma `KeepAlive`, wiec kazdy blad startowy powtarzalby sie co 30 s
w nieskonczonosc. `mount-drive.sh` sprawdza dlatego przed uruchomieniem, czy
FUSE w ogole jest - bez tego rclone konczylby natychmiast bledem `cgofuse:
cannot find FUSE`, a log rosl bez konca. Ten projekt ma juz za soba incydent
logu na 3,3 GiB, wiec log rclone jest dodatkowo przycinany przy starcie po
przekroczeniu 100 MB.

## Podglad

```sh
./gdrive/status.sh
```

Liczba, ktora trzeba obserwowac, to `uploadsQueued`. Jesli rosnie i nie wraca do
zera miedzy backupami, wysylka nie nadaza za zapisem i bufor sie zapelnia.

## Skrypty testowe

`poc-local.sh` - przepuszcza caly lancuch bez Drive'a i bez FUSE-T, podstawiajac
lokalny obraz w miejsce montowania rclone. Dowodzi, ze obraz powstaje, podpina
sie, przyjmuje dane i przezywa odpiecie z ponownym podpieciem.

`poc-amplification.sh` - mierzy, ile megabajtow trzeba wyslac na kazdy megabajt
faktycznej zmiany. `BAND_MB` wybiera rozmiar pasma, `WORKLOAD` scenariusz
(`scatter` - najgorszy przypadek, `append` - wzorzec Time Machine).

`poc-pullplug.sh` - wyrywa warstwe chmurowa spod obrazu w trakcie zapisu
i sprawdza, czy backup da sie odzyskac.

`poc-launchd.sh` - laduje agenty z zaslepka w miejsce rclone i sprawdza, czy
bufor wstaje, czy agent podpinajacy czeka na niego zamiast wyscigowac sie z nim
i czy KeepAlive podnosi bufor po padnieciu. Uzywa wlasnych etykiet `poc-*`,
wiec nie koliduje z produkcyjnymi agentami, i sprzata po sobie.

`verify-image.sh` - sprawdza spojnosc obrazu przez `fsck_apfs`.

## Czego jeszcze nie sprawdzono

- Czy `tmutil setdestination` na macOS 26.6 przyjmie tak podpiety obraz.
- Jak zachowa sie montowanie pod obciazeniem prawdziwego backupu. Pojedyncze
  operacje dzialaja (zapis 50 MB przy 267 MB/s), ale kilkugodzinny pierwszy
  transfer to inna skala.
- Czy rclone nigdy nie usuwa z bufora danych jeszcze niewyslanych. Na tym stoi
  cala obietnica nieprzerywalnosci. Test: odciac siec w trakcie backupu,
  przywrocic, odczekac na pelny drenaz, `verify-image.sh`. Powtorzyc kilka razy.
  (`poc-pullplug.sh` pokrywa mocniejszy przypadek - smierc calej warstwy - ale
  nie ten konkretny, bo wymaga dzialajacego rclone.)
- Czy `tmutil setdestination` przyjmie cel spoza `/Volumes`. Od tego zalezy,
  czy da sie usunac koniecznosc recznej interwencji po nieczystym odpieciu.
- Rzeczywiste wzmocnienie zapisu przy prawdziwych backupach Time Machine,
  a nie przy symulacji.
- Czy `--rc-no-auth` na 127.0.0.1:5572 jest akceptowalne. Interfejs slucha tylko
  na petli zwrotnej, ale kazdy lokalny proces moze przez niego sterowac
  montowaniem. Do rozwazenia `--rc-user`/`--rc-pass`.
