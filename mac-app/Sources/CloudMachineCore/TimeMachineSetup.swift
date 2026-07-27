import Foundation

/// Port `setup-timemachine.sh` - rejestruje zamontowany wolumin sparsebundle
/// jako cel Time Machine (`tmutil setdestination -a`). Uzywa `-a` (dodaj),
/// zeby nie kasowac ewentualnego istniejacego lokalnego dysku TM - Time
/// Machine potrafi rotacyjnie/rownolegle korzystac z wielu celow.
public enum TimeMachineSetup {
    public static func isRegistered(machineKey: String) async -> Bool {
        await TimeMachineStatus.destinationInfoContains("CloudMachine-Backup-\(machineKey)")
    }

    /// Rejestracja przez `sudo -n` - dla CLI/watchdogow (wymaga skonfigurowanej
    /// reguly sudoers). GUI uzywa wlasnego mechanizmu autoryzacji AppleScript
    /// (`runTmutilPrivileged` w CloudMachineController) i nie woła tej funkcji.
    public static func registerUnattended(machineKey: String) async -> CMActionResult {
        let spMount = CMPaths.sparsebundleMountDir(machineKey: machineKey).path
        guard await MountHealth.isMounted(spMount) else {
            return CMActionResult(succeeded: false, message: "Wirtualny dysk sparsebundle pod \(spMount) nie jest zamontowany. Uruchom najpierw montowanie.")
        }
        let result = try? await ProcessRunner.runTmutilUnattended(["setdestination", "-a", spMount])
        guard result?.succeeded == true else {
            return CMActionResult(succeeded: false, message: "Rejestracja celu Time Machine nie powiodla sie (sudo bez hasla niedostepne lub inny blad).")
        }
        return CMActionResult(succeeded: true, message: "Zarejestrowano \(spMount) jako cel Time Machine.")
    }
}
