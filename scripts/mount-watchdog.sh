#!/bin/bash
# Pilnuje, zeby montowanie dysku Google (NFS + wirtualny dysk sparsebundle,
# ktory Time Machine widzi jako drugi dysk) dzialalo NIEPRZERWANIE, tak dlugo
# jak uzytkownik chce miec je zamontowane - az do jawnego "Odmontuj".
#
# Uruchamiane cyklicznie przez launchd, patrz
# launchd/com.renacode.cloudmachine.mount-watchdog.plist.template (StartInterval).
# Kazde uruchomienie:
#   1. Jesli user nie chcial miec dysku zamontowanego (cm_mount_desired=off,
#      ustawiane przez mount.sh/unmount.sh) - nic nie robi.
#   2. Sprawdza czy NFS i sparsebundle sa nie tylko WIDOCZNE w tabeli `mount`,
#      ale realnie ODPOWIADAJA (patrz cm_probe_responsive w common.sh) -
#      zawieszony serwer NFS ("serwer nie odpowiada") dalej tam widnieje,
#      mimo ze kazda operacja I/O na nim blokuje sie w nieskonczonosc.
#   3. Jesli sa zdrowe - dopina sparsebundle jesli akurat brakuje i konczy.
#   4. Jesli nie - wymusza odmontowanie, ubija zawieszony proces rclone i
#      probuje zamontowac ponownie przez mount.sh.
#
# Celowo BEZ `set -e`: to jest petla naprawcza, kazdy krok ma wlasne
# zabezpieczenie na blad (`|| true`), zeby pojedyncza nieudana komenda w
# trakcie naprawy nie przerwala calego przebiegu w polowie.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ./common.sh
set +e

cm_require_config
cm_require_jq

# mount.sh wywolane ponizej moze legalnie czekac dlugo (bez sztywnego limitu
# czasu) na kazda z 2 prob, dopoki rclone aktywnie dogania duza zalegla
# kolejke uploadow (patrz cm_rclone_busy_draining) - blokada jest wiec oparta
# o zywotnosc PID (patrz cm_acquire_lock w common.sh), nie o staly czas, zeby
# kolejny cykl watchdoga (co 60s) nie uznal wciaz pracujacej instancji za
# "osierocona" i nie odpalil drugiego, rownoleglego przebiegu.
if ! cm_acquire_lock "mount-watchdog"; then
  exit 0
fi

if [ "$(cm_mount_desired)" != "on" ]; then
  exit 0
fi

# Samo-naprawa na wypadek, gdyby proces caffeinate padl niezaleznie od
# mountu (np. ubity recznie) - patrz komentarz przy cm_start_caffeinate w
# common.sh, dlaczego to krytyczne dla stabilnosci backupu.
cm_start_caffeinate

MACHINE_KEY="$(cm_machine_key)"
LOCAL_DIR="$(cm_local_machine_mount_dir "$MACHINE_KEY")"
SP_MOUNT="$(cm_sparsebundle_mount_dir "$MACHINE_KEY")"
REMOTE_PATH="$(cm_remote_path_for "$MACHINE_KEY")"

# Plik licznika kolejnych "wolnych" odpowiedzi - jeden pojedynczy wolny probe
# (np. pierwszy `stat` po swiezym montowaniu zanim vfs-cache sie rozgrzeje,
# albo chwilowy skok latencji Google Drive API, zwlaszcza przy czestych
# odpytaniach) NIE powinien od razu wywalac zdrowego mountu. Naprawiamy
# dopiero po 3 kolejnych nieudanych cyklach pod rzad (~2-3 minuty sumarycznie,
# zblizone do tego, po jakim czasie macOS sam pokazuje uzytkownikowi dialog
# "serwer nie odpowiada" dla prawdziwie zawieszonego NFS) - to realnie
# odroznia zawieszenie od zwyklej chwilowej zwloki API.
SLOW_STREAK_FILE="$CM_LOG_DIR/.mount-watchdog-slow-streak"
SLOW_STREAK_THRESHOLD=3

nfs_listed=0
mount | grep -q "$LOCAL_DIR" && nfs_listed=1

healthy=0
needs_repair=0
if [ "$nfs_listed" = "1" ]; then
  if cm_probe_responsive "$LOCAL_DIR" 20; then
    healthy=1
    rm -f "$SLOW_STREAK_FILE"
  else
    streak=$(( $(cat "$SLOW_STREAK_FILE" 2>/dev/null || echo 0) + 1 ))
    echo "$streak" > "$SLOW_STREAK_FILE"
    if [ "$streak" -ge "$SLOW_STREAK_THRESHOLD" ]; then
      cm_log "[mount-watchdog] $LOCAL_DIR nie odpowiada od $streak kolejnych sprawdzen - traktuje jako zawieszone."
      needs_repair=1
      rm -f "$SLOW_STREAK_FILE"
    else
      cm_log "[mount-watchdog] $LOCAL_DIR nie odpowiedzialo w 20s (proba $streak/$SLOW_STREAK_THRESHOLD) - czekam na potwierdzenie w kolejnym cyklu przed naprawa."
    fi
  fi
else
  if cm_rclone_busy_draining "$REMOTE_PATH" 45; then
    # rclone zyje i aktywnie cos wysyla (log rosl w ostatnich 45s) - to
    # normalne, ze NFS jeszcze sie nie pojawilo, jesli dogania duza zalegla
    # kolejke po przerwanym backupie. NIE przerywamy - patrz komentarz przy
    # cm_rclone_busy_draining w common.sh.
    cm_log "[mount-watchdog] $LOCAL_DIR jeszcze nie zamontowane, ale rclone wciaz aktywnie pracuje (prawdopodobnie doganiam zalegle wysylki po przerwanym backupie) - czekam, nie przerywam."
  else
    cm_log "[mount-watchdog] $LOCAL_DIR nie jest zamontowane, mimo ze powinno byc."
    needs_repair=1
    rm -f "$SLOW_STREAK_FILE"
  fi
fi

if [ "$healthy" = "1" ]; then
  # NFS zdrowy - dopinamy sparsebundle jesli akurat go brakuje (np. po tym,
  # jak macOS sam go odmontowal, ale NFS pod nim nadal dziala poprawnie).
  if ! mount | grep -q "$SP_MOUNT"; then
    cm_log "[mount-watchdog] NFS zdrowy, ale wirtualny dysk sparsebundle nie jest zamontowany pod $SP_MOUNT - montuje."
    hdiutil attach -noverify -noautoopen -nobrowse -mountpoint "$SP_MOUNT" "$LOCAL_DIR/backup.sparsebundle" >>"$CM_LOG_DIR/cloudmachine.log" 2>&1
    if [ $? -ne 0 ]; then
      cm_log "[mount-watchdog] Nie udalo sie zamontowac sparsebundle w tym przebiegu, sprobuje ponownie w nastepnym cyklu."
    fi
  fi
  exit 0
fi

if [ "$needs_repair" != "1" ]; then
  # Pierwszy nieudany probe - czekamy na potwierdzenie w kolejnym cyklu (patrz wyzej).
  exit 0
fi

cm_log "[mount-watchdog] Wykryto niezdrowe/zawieszone montowanie. Naprawiam..."

# WAZNE: ponizszy agresywny demontaz (force-unmount + kill) odpalamy TYLKO gdy
# NFS naprawde widnieje w tabeli mount, ale nie odpowiada (czyli jest
# realnie zawieszone). Jesli po prostu nic jeszcze nie jest zamontowane
# (nfs_listed=0), NIE wolno tu z wyprzedzeniem zabijac procesow rclone -
# mount.sh (wywolane ponizej) moze wtedy trafic w sam srodek juz trwajacego,
# zdrowego montowania (np. reczne klikniecie "Zamontuj" ktore jeszcze nie
# zdazylo pojawic sie w tabeli mount - samo `rclone nfsmount --daemon` do
# osiagniecia pelnego montowania potrzebuje kilkunastu sekund) - w takim
# przypadku ubicie "osieroconego" procesu ubijaloby de facto zdrowe,
# powstajace wlasnie montowanie. mount.sh samo bezpiecznie obsluzy sprzatanie
# prawdziwych sierot pod wlasna blokada ("mount-${MACHINE_KEY}"), wiec
# ponizej po prostu je wywolujemy - jesli inna instancja juz dziala, mount.sh
# grzecznie sie wycofa (log: "Inna instancja mount.sh... juz dziala").
if [ "$nfs_listed" = "1" ]; then
  # 1. Odepnij sparsebundle, jesli jest zamontowany (wymuszone, bo skoro NFS
  #    pod nim jest zawieszony, zwykle odmontowanie prawdopodobnie tez by sie zawiesilo).
  if mount | grep -q "$SP_MOUNT"; then
    hdiutil detach -force "$SP_MOUNT" >/dev/null 2>&1
    if mount | grep -q "$SP_MOUNT"; then
      diskutil unmount force "$SP_MOUNT" >/dev/null 2>&1
    fi
  fi

  # 2. Wymuszone odmontowanie NFS w tle - zwykle `umount` na zawieszonym
  #    punkcie tez moze sie zawiesic, wiec nie czekamy na nie synchronicznie
  #    w nieskonczonosc.
  ( diskutil unmount force "$LOCAL_DIR" >/dev/null 2>&1 || umount -f "$LOCAL_DIR" >/dev/null 2>&1 ) &
  disown 2>/dev/null
  waited=0
  while [ "$waited" -lt 10 ]; do
    mount | grep -q "$LOCAL_DIR" || break
    sleep 1
    waited=$((waited + 1))
  done

  # 3. Ubij zawieszony proces rclone dla tego remote (SIGTERM, potem KILL) -
  #    dopiero teraz wiemy, ze byl naprawde zawieszony, a nie w trakcie
  #    normalnego montowania.
  cm_kill_rclone_for_remote "$REMOTE_PATH"

  if mount | grep -q "$LOCAL_DIR"; then
    cm_log "[mount-watchdog] Punkt montowania nadal widnieje w tabeli po probie wymuszonego odmontowania - mount.sh przeniesie go na bok i utworzy nowy."
  fi
fi

cm_log "[mount-watchdog] Probuje zamontowac ponownie przez mount.sh."
# Bez przekierowania do cloudmachine.log - mount.sh juz sam pisze tam kazda
# linie przez cm_log (ktory uzywa `tee -a`); dodatkowe przekierowanie tutaj
# duplikowaloby kazdy wpis.
CM_MACHINE_KEY="$MACHINE_KEY" ./mount.sh
if [ $? -eq 0 ]; then
  cm_log "[mount-watchdog] Naprawa zakonczona powodzeniem."
  if command -v osascript >/dev/null 2>&1; then
    osascript -e 'display notification "Wykryto zawieszone montowanie dysku Google i naprawiono je automatycznie." with title "CloudMachine"' >/dev/null 2>&1
  fi
else
  cm_log "[mount-watchdog] Naprawa nie powiodla sie w tym przebiegu, sprobuje ponownie przy nastepnym cyklu watchdoga."
fi
