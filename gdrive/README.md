# Warstwa Google Drive - pomiary i wnioski

Dzialajacy system siedzi w aplikacji, nie tutaj. Ten katalog trzyma harnessy
pomiarowe i uzasadnienia decyzji, ktore z tych pomiarow wyszly.

```
Time Machine
  -> /Volumes/CloudMachine          obraz podpiety przez hdiutil; TM widzi zwykly APFS
     -> ~/.cloudmachine/drive       rclone mount na FUSE-T
        -> ~/.cloudmachine/cache    bufor zapisu 100 GB
        -> gdrive:CloudMachine/...  Google Drive
```

Sens ukladu: **w sciezce zapisu nie ma sieciowego systemu plikow.** Time Machine
pisze do lokalnie podpietego obrazu i nie wie, ze pasma leza w chmurze. Odpada
SMB, a z nim najczestsza przyczyna psucia sie backupow sieciowych.

## Gdzie co jest

| Co | Gdzie |
|---|---|
| Bufor (montowanie, cache, kolejka) | `CloudMachineCore/DriveBufferService` |
| Obraz (tworzenie, podpinanie, spojnosc) | `CloudMachineCore/BackupImageService` |
| Dozorca bufora | `CloudMachineCore/BufferGuardService` |
| Instalacja rclone z obsluga montowania | `CloudMachineCore/RcloneInstaller` |
| Rozwiazywanie narzedzi, kontrola FUSE | `CloudMachineCore/CMTooling` |
| Podkomendy | `CloudMachineAgent/DriveCommands` |
| Agenty launchd | `launchd/*.plist.template` |

```sh
cloudmachine-agent install-rclone     # oficjalna binarka (ta z Homebrew nie umie montowac)
cloudmachine-agent configure-remote   # OAuth, klucze z Keychaina
cloudmachine-agent create-image --size-gb 4000
cloudmachine-agent attach-image
cloudmachine-agent drive-status
sudo tmutil setdestination /Volumes/CloudMachine
```

## Rozmiar pasma

Ustawiany wylacznie przy tworzeniu obrazu; pozniej nie da sie go zmienic bez
zaczynania backupu od zera. Dwie sily ciagna w przeciwne strony: Google Drive
przepuszcza okolo **dwoch operacji na plik na sekunde** i ma limit **400 000
plikow**, co premiuje duze pasma - ale kazda zmiana brudzi **cale** pasmo, co
przy dobowym limicie **750 GB** premiuje male.

Zmierzone (`poc-amplification.sh`, obraz 3 GB, zmiana 300 MB):

| Pasmo | Pasm na 3 GB | Rozrzucona zmiana | Dopisanie (jak TM) | Plikow na 200 GB |
|-------|--------------|-------------------|--------------------|------------------|
| 8 MB  | 381          | 2712 MB           | 384 MB             | 25 600           |
| 16 MB | 193          | 3040 MB           | 480 MB             | 12 800           |
| 32 MB | 99           | 3072 MB           | **672 MB**         | **6 400**        |
| 64 MB | 52           | 3136 MB           | 768 MB             | 3 200            |

Przy zmianie **rozrzuconej** po calym wolumenie rozmiar pasma nie ma znaczenia -
brudzi sie prawie kazde pasmo i wysyla sie w praktyce caly obraz. To jednak
najgorszy przypadek, nie ten, ktory nas dotyczy.

Przy **dopisywaniu**, czyli tym, co faktycznie robi Time Machine, transfer
rosnie monotonicznie z rozmiarem pasma: 64 MB kosztuje dokladnie dwa razy tyle
co 8 MB. Duze pasma nie sa darmowe.

Stad **32 MB**: najmniejsze pasmo, przy ktorym pierwsza wysylka przestaje byc
ograniczona tempem operacji Drive'a (6 400 plikow, ~0,9 h) i zaczyna byc
ograniczona pasmem lacza (~1,3 h przy 332 Mb/s).

## Kaprysy montowania FUSE-T

FUSE-T montuje przez NFS, a `hdiutil` na takim wolumenie bywa odrzucany bledem
**`RPC version wrong`**. Zmierzone: blad nie zalezy od rozmiaru obrazu ani od
danych (jeden przebieg padl dla 100 GB i 400 GB, a przeszedl dla 600, 1000
i 1500 GB), tylko od **chwili** - przy pustej kolejce wysylki 5 prob na 5
udanych, przy rclone zajetym losowo. Stad czekanie na cisze i ponawianie
w `BackupImageService`; przy tworzeniu produkcyjnego obrazu pierwsza proba padla,
druga przeszla.

**Obraz trzeba tworzyc na miejscu, na zamontowanym Drive.** Utworzenie go
lokalnie i przeniesienie daje obraz, ktorego `hdiutil` pozniej nie otwiera
(`CBSDBackingStore::newProbe stat() failed`), mimo ze wszystkie pliki i pasma sa
na swoim miejscu i daja sie czytac.

Pozostale backendy FUSE-T nie pomagaja: `backend=fskit` w ogole sie nie montuje,
`backend=smb` montuje sie, ale `hdiutil create` konczy sie `Is a directory`.

## Co przetrwa smierc warstwy chmurowej

`poc-pullplug.sh` odpina zastepnik montowania w trakcie zapisu, czyli symuluje
padniecie procesu rclone albo wysypanie sie FUSE-T. Trzy rundy, **zero
nieodwracalnych strat** - obraz za kazdym razem przeszedl `fsck_apfs`.

Zerwanie samego lacza jest lagodniejsze: przy `--vfs-cache-mode full` zapis idzie
do bufora, montowanie stoi i Time Machine niczego nie zauwaza.

Dwie pulapki, ktore ten test ujawnil, obie zalatane w `BackupImageService`:

**Zombie urzadzenia.** Po wymuszonym odpieciu urzadzenie obrazu potrafi zostac
w systemie. Podpiecie zwraca wtedy martwy uchwyt, na ktorym `fsck_apfs` melduje
`failed to read container superblock` z UUID z samych zer. Wyglada to jak
skasowany backup, a jest tylko nieczytelnym urzadzeniem - pierwsza wersja tego
testu na tej podstawie trzy razy z rzedu orzekla utrate danych, ktore byly cale.

**Osierocony punkt montowania.** Po nieczystym odpieciu katalog
`/Volumes/CloudMachine` zostaje i blokuje ponowne podpiecie komunikatem
`no mountable file systems`. Nalezy do uzytkownika, ale lezy w `/Volumes`
nalezacym do roota, wiec `rmdir` odmawia - **agent dzialajacy jako uzytkownik
nie posprzata po sobie sam**. Aplikacja wykrywa to i podaje dokladne polecenie.

## Bufor jest limitem miekkim

`--vfs-cache-max-size` nie jest granica twarda: rclone usuwa z bufora tylko dane
juz wyslane, wiec gdy wszystko czeka w kolejce, bufor rosnie dalej i moze
zapelnic dysk. Time Machine pisze do obrazu z predkoscia SSD (zmierzone
267 MB/s), rclone wysyla z predkoscia lacza (~41 MB/s) - na starcie pierwszego
backupu bufor rosl netto o 32 MB/s.

Dlatego `BufferGuardService` wstrzymuje Time Machine powyzej progu i wznawia,
gdy wysylka nadgoni. Pilnuje tez dobowego limitu Drive'a: po jego przekroczeniu
rclone konczy prace z zalozenia i podnoszenie go nic nie da, dopoki limit sie
nie odnowi.

## Harnessy pomiarowe

Nie sa czescia dzialajacego systemu - uruchamia sie je recznie, gdy trzeba cos
zmierzyc albo potwierdzic regresje. Mierza zachowanie `hdiutil` i FUSE-T, czyli
rzeczy, ktorych testem jednostkowym sie nie zmierzy.

```sh
BAND_MB=32 WORKLOAD=append ./poc-amplification.sh   # wzmocnienie zapisu
BAND_MB=32 ROUNDS=3 ./poc-pullplug.sh               # smierc warstwy chmurowej
```

## Czego nadal nie wiadomo

- Jak montowanie zachowa sie pod obciazeniem pelnego, wielogodzinnego backupu.
  Pojedyncze operacje dzialaja (zapis 50 MB przy 267 MB/s), ale to inna skala.
- Czy rclone nigdy nie usuwa z bufora danych jeszcze niewyslanych.
  `poc-pullplug.sh` pokrywa mocniejszy przypadek - smierc calej warstwy - ale
  nie ten konkretny, bo wymaga dzialajacego rclone.
- Czy `tmutil setdestination` przyjmie cel spoza `/Volumes`. Od tego zalezy, czy
  da sie usunac koniecznosc recznej interwencji po nieczystym odpieciu.
- Czy `--rc-no-auth` na petli zwrotnej jest akceptowalne. Kazdy lokalny proces
  moze przez ten interfejs sterowac montowaniem.
