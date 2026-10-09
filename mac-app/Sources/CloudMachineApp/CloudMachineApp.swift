import SwiftUI

@main
struct CloudMachineApp: App {
  @StateObject private var controller = CloudMachineController()

  var body: some Scene {
    MenuBarExtra("CloudMachine", systemImage: "icloud.and.arrow.up") {
      MenuBarContentView()
        .environmentObject(controller)
        .preferredColorScheme(.dark)
    }
    .menuBarExtraStyle(.window)

    Window("CloudMachine", id: "dashboard") {
      DashboardView()
        .environmentObject(controller)
        .preferredColorScheme(.dark)
        .frame(minWidth: 820, minHeight: 600)
    }
    // No title bar: the sidebar runs up under the traffic lights, as in the
    // RenaCode window design.
    .windowStyle(.hiddenTitleBar)
    .defaultSize(width: 980, height: 760)
  }
}
