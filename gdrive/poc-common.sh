#!/bin/bash
# Wspolne czesci harnessow pomiarowych.
#
# Same harnessy mierza zachowanie hdiutil i FUSE-T, a nie nasz kod - dlatego
# zostaly, gdy reszta skryptow trafila do aplikacji (CloudMachineCore).
# Nie sa czescia dzialajacego systemu; uruchamia sie je recznie, gdy trzeba
# cos zmierzyc albo potwierdzic regresje.

CM_AGENT="${CM_AGENT:-/Applications/CloudMachine.app/Contents/MacOS/cloudmachine-agent}"

# Urzadzenia /dev/diskN podpiete pod wskazany obraz.
#
# Po wymuszonym odpieciu urzadzenie potrafi zostac w systemie jako zombie.
# Podpiecie zwraca wtedy martwy uchwyt, na ktorym fsck_apfs melduje
# "failed to read container superblock" z UUID z samych zer - wyglada to jak
# skasowany backup, a jest tylko nieczytelnym urzadzeniem.
cm_devices_for_image() {
  hdiutil info | awk -v img="$1" '
    /^image-path/ { sub(/^image-path[ \t]*:[ \t]*/, ""); path = $0; next }
    /^\/dev\/disk[0-9]+[ \t]/ { if (path == img) print $1 }
  ' | sort -u
}

cm_purge_stale_devices() {
  local d
  for d in $(cm_devices_for_image "$1"); do
    hdiutil detach "$d" -force -quiet 2>/dev/null || true
  done
}
