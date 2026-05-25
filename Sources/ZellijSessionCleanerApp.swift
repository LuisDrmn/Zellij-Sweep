import SwiftUI

@main
struct ZellijSweepApp: App {
    @State private var store = ZellijSessionStore(client: .live)

    var body: some Scene {
        MenuBarExtra {
            ZellijMenuView(store: store)
                .task {
                    await store.refresh()
                }
        } label: {
            Label("Zellij-Sweep", systemImage: "rectangle.stack.badge.minus")
        }
        .menuBarExtraStyle(.window)
    }
}
