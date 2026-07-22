import SwiftUI

@main
struct CloudMachineApp: App {
    @StateObject private var controller = CloudMachineController()

    var body: some Scene {
        MenuBarExtra("CloudMachine", systemImage: "icloud.and.arrow.up") {
            MenuBarContentView()
                .environmentObject(controller)
        }
        .menuBarExtraStyle(.window)

        Window("CloudMachine", id: "dashboard") {
            DashboardView()
                .environmentObject(controller)
                .frame(minWidth: 640, minHeight: 480)
        }
        .defaultSize(width: 720, height: 560)
    }
}
