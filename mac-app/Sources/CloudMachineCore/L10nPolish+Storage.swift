// Polish translations, keyed by the English text passed to `L10n.tr`.
extension L10nPolish {
  static let storage: [String: String] = [
    // UploadState
    "ACTION NEEDED": "WYMAGA REAKCJI",
    "WILL PASS BY ITSELF — DO NOTHING": "MINIE SAMO — NIC NIE RÓB",
    "UNKNOWN — CHECK AGAIN SHORTLY": "NIE WIADOMO — SPRAWDŹ ZA CHWILĘ",
    "ALL GOOD": "W PORZĄDKU",
    "Upload is not working": "Wysyłka nie działa",
    "Upload stopped — no space left on Google Drive": "Wysyłka stoi — brak miejsca na Google Drive",
    "%@ backup fragments not uploaded": "Nie wysłano %@ fragmentów kopii",
    "Upload cannot keep up with writes": "Wysyłka nie nadąża za zapisem",
    "Upload paused — Google daily limit": "Wysyłka wstrzymana — dobowy limit Google",
    "Uploading to Google Drive — %@ queued": "Wysyłanie na Google Drive — %@ w kolejce",
    "Everything uploaded to Google Drive": "Wszystko wysłane na Google Drive",
    "Unknown what is waiting in the queue": "Nie wiadomo, co czeka w kolejce",
    "There is no connection to Google Drive, so backups are only made on this Mac. If this does not pass by itself within a few minutes, check the network and the connection to Drive.":
      "Nie ma połączenia z Google Drive, więc kopie powstają tylko na tym Macu. Jeśli to nie minie samo w kilka minut, sprawdź sieć i połączenie z Dyskiem.",
    "There is no space left on Google Drive. This will NOT pass by itself — you need to free up space on Drive. Until then Time Machine is paused, so that it does not fill up this Mac's disk.":
      "Na Google Drive nie ma już miejsca. To NIE minie samo — trzeba zwolnić miejsce na Dysku. Do tego czasu Time Machine jest wstrzymany, żeby nie zapełnić dysku tego Maca.",
    "%@ backup fragments could not be uploaded and rclone stopped trying. These fragments exist only on this Mac, so the backup on Drive is incomplete. This needs checking.":
      "%@ fragmentów kopii nie udało się wysłać i rclone przestał próbować. Te fragmenty istnieją wyłącznie na tym Macu, więc kopia na Dysku jest niekompletna. To wymaga sprawdzenia.",
    "Time Machine is writing faster than the upload goes, and the buffer has filled up. The backup will be paused until the upload catches up — this is a safeguard against filling up the disk, not a failure.":
      "Time Machine pisze szybciej, niż idzie wysyłka, i bufor się zapełnił. Backup zostanie wstrzymany, aż wysyłka nadgoni — to zabezpieczenie przed zapełnieniem dysku, nie awaria.",
    "Google accepts 750 GB per day and that limit has been used up. There is nothing to do: the limit renews by itself, usually within a few hours. Time Machine backups are made normally in the meantime and wait in the buffer — they will be uploaded as soon as Google starts accepting again.":
      "Google przyjmuje 750 GB na dobę i ten limit został wyczerpany. Nie trzeba nic robić: limit odnawia się sam, zwykle w kilka godzin. Kopie Time Machine powstają przez ten czas normalnie i czekają w buforze — wyślą się, gdy tylko Google znów zacznie przyjmować.",
    "%@ backup fragments are queued and on their way to Drive.":
      "%@ fragmentów kopii czeka w kolejce i leci na Dysk.",
    "Nothing is waiting in the queue — the backup on Google Drive is complete.":
      "Nic nie czeka w kolejce — kopia na Google Drive jest kompletna.",
    "rclone did not answer the question about the queue, so it is unknown how many backups are still waiting to be uploaded. This does not mean something broke — under load the answer can be late. It only means that right now nobody knows. If it persists, the backup cycle check will report it.":
      "rclone nie odpowiedział na pytanie o kolejkę, więc nie wiadomo, ile kopii czeka jeszcze na wysłanie. To nie znaczy, że coś się zepsuło — pod obciążeniem odpowiedź potrafi się spóźnić. Znaczy tylko tyle, że w tej chwili nikt tego nie wie. Jeśli utrzymuje się dłużej, zgłosi to kontrola cyklu backupu.",
    // BackupImageService
    "%@: another image operation is in progress (creating, attaching, detaching or verifying) - NOTHING was done. Try again shortly.":
      "%@: inna operacja na obrazie jest w toku (tworzenie, podpinanie, odpinanie albo sprawdzanie) - NIE zrobiono nic. Spróbuj za chwilę.",
    "NOT ATTACHED": "BRAK",
    "DEAD - in the mount table, but reads fail (errno %@); attach-image attaches it again":
      "MARTWY - w tablicy montowań, ale odczyt pada (errno %@); attach-image podpina na nowo",
    "UNKNOWN - in the mount table, but the readability probe did not answer within %@ s":
      "NIE WIADOMO - w tablicy montowań, ale sonda czytelności nie odpowiedziała w %@ s",
    "UNKNOWN - could not read the mount table":
      "NIE WIADOMO - nie udało się odczytać tablicy montowań",
    "Creating the image": "Tworzenie obrazu",
    "Drive is not mounted - start the buffer first.":
      "Drive nie jest zamontowany - najpierw uruchom bufor.",
    "Could not read the mount table - it is UNKNOWN whether the buffer is mounted. NOT creating the image.":
      "Nie udało się odczytać tablicy montowań - NIE WIADOMO, czy bufor jest zamontowany. NIE tworzę obrazu.",
    "The buffer did not come up within %@ min - NOT creating the image.":
      "Bufor nie stanął w %@ min - NIE tworzę obrazu.",
    "The image already exists. Deleting it erases the whole backup - do it deliberately.":
      "Obraz już istnieje. Usunięcie go kasuje cały backup - zrób to świadomie.",
    "The image already exists on Google Drive (the mount cache did not show it, but the remote has it). Deleting it erases the whole backup - do it deliberately.":
      "Obraz już istnieje na Google Drive (cache montowania go nie pokazywał, ale zdalny go ma). Usunięcie go kasuje cały backup - zrób to świadomie.",
    "Could not confirm on Google Drive that the image is not there yet (%@) - ABORTING. Creating the image over an existing backup is irreversible, so I do not start without that answer.":
      "Nie udało się potwierdzić na Google Drive, że obrazu tam jeszcze nie ma (%@) - PRZERYWAM. Tworzenie obrazu na istniejącym backupie jest nieodwracalne, więc bez tej odpowiedzi nie zaczynam.",
    "Could not create the image: %@": "Nie udało się utworzyć obrazu: %@",
    "unknown error": "nieznany błąd",
    "Created a %@ GB image, band size %@ MB.": "Utworzono obraz %@ GB, pasmo %@ MB.",
    "rclone did not answer": "rclone nie odpowiedział",
    "rclone lsf ended with an error": "rclone lsf zakończyło się błędem",
    "Attaching the image": "Podpinanie obrazu",
    "Drive is not mounted.": "Drive nie jest zamontowany.",
    "Could not read the mount table - it is UNKNOWN whether the buffer is mounted. NOT attaching the image.":
      "Nie udało się odczytać tablicy montowań - NIE WIADOMO, czy bufor jest zamontowany. NIE podpinam obrazu.",
    "No image - create it first.": "Brak obrazu - najpierw go utwórz.",
    "Already attached: %@": "Już podpięte: %@",
    "The image is in the mount table, but the readability probe did not answer within %@ s - it is UNKNOWN whether the device is alive. NOT force-detaching and NOT attaching.":
      "Obraz jest w tablicy montowań, ale sonda czytelności nie odpowiedziała w %@ s - NIE WIADOMO, czy urządzenie żyje. NIE odpinam na siłę i NIE podpinam.",
    "Could not read the mount table - it is UNKNOWN whether the image is attached. NOT attaching.":
      "Nie udało się odczytać tablicy montowań - NIE WIADOMO, czy obraz jest podpięty. NIE podpinam.",
    "Image dead (errno %@) and could not be detached: %@":
      "Obraz martwy (errno %@) i nie dał się odpiąć: %@",
    "An orphaned mount point blocks the attach: %@\nRemove it and try again:  sudo rmdir '%@'":
      "Osierocony punkt montowania blokuje podpięcie: %@\nUsuń go i spróbuj ponownie:  sudo rmdir '%@'",
    "Could not attach the image: %@": "Nie udało się podpiąć obrazu: %@",
    "Attached: %@": "Podpięte: %@",
    "Detaching the image": "Odpinanie obrazu",
    "Could not detach - the image is held by browsed backup snapshots that could not be unmounted:\n%@\nClose the Time Machine / Finder window on the backup and try again.":
      "Nie udało się odpiąć - obraz trzymają przeglądane migawki backupu, których nie dało się odmontować:\n%@\nZamknij okno Time Machine / Findera na backupie i spróbuj ponownie.",
    "Could not detach.": "Nie udało się odpiąć.",
    "Detached (without waiting for the upload - the data may be local only).":
      "Odpięte (bez czekania na wysyłkę - dane mogą być tylko lokalnie).",
    "Detached, but the upload did NOT finish in time - do not delete the buffer.":
      "Odpięte, ale wysyłka NIE zakończyła się w czasie - nie kasuj bufora.",
    "Detached, but rclone ABANDONED %@ backup fragments - they exist only on this Mac and are not on Google Drive. Do not delete the buffer.":
      "Odpięte, ale rclone PORZUCIŁ %@ fragmentów kopii - istnieją wyłącznie na tym Macu i na Google Drive ich nie ma. Nie kasuj bufora.",
    "Detached, everything uploaded to Google Drive.": "Odpięte, wszystko wysłane na Google Drive.",
    "Verifying the image": "Sprawdzanie obrazu",
    "No image.": "Brak obrazu.",
    "The image is attached - detach it before verifying.":
      "Obraz jest podpięty - odepnij go przed sprawdzeniem.",
    "Could not find an APFS device in the image.": "Nie znalazłem urządzenia APFS w obrazie.",
    "Could not run %@ - the image's consistency REMAINS UNCHECKED.":
      "Nie udało się uruchomić %@ - spójność obrazu POZOSTAJE NIESPRAWDZONA.",
    "Check INTERRUPTED - device %@ disappeared midway (someone force-detached the image). This is not a result about the backup's state: the image's consistency REMAINS UNCHECKED. Repeat the check.":
      "Sprawdzenie PRZERWANE - urządzenie %@ zniknęło w trakcie (ktoś odpiął obraz na siłę). To nie jest wynik o stanie backupu: spójność obrazu POZOSTAJE NIESPRAWDZONA. Powtórz sprawdzenie.",
    "Image consistent.": "Obraz spójny.",
    "Image INCONSISTENT: %@": "Obraz NIESPÓJNY: %@",
    // BufferGuardService
    "CloudMachine: upload to Drive is stalled": "CloudMachine: wysyłka na Dysk stoi",
    "Upload to Google Drive is stalled - daily limit exhausted.":
      "Wysyłka na Google Drive stoi - wyczerpany limit dobowy.",
  ]
}
