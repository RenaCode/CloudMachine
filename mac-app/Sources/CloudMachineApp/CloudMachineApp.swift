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
        .frame(minWidth: 780, minHeight: 560)
    }
    .defaultSize(width: 920, height: 680)
  }
}
