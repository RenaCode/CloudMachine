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
    // RemoteConfigurer
    "unknown error": "nieznany błąd",
    "rclone did not answer": "rclone nie odpowiedział",
    "rclone lsf ended with an error": "rclone lsf zakończyło się błędem",
  ]
}
