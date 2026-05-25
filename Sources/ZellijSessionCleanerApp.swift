import SwiftUI

@main
struct ZellijSweepApp: App {
    @State private var store = ZellijSessionStore(client: .live)
    @State private var launchAtLoginStore = LaunchAtLoginStore()

    var body: some Scene {
        MenuBarExtra {
            ZellijMenuView(store: store)
                .task {
                    await store.refresh()
                    launchAtLoginStore.refresh()
                }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "rectangle.stack.badge.minus")
                Text("\(store.sessions.count)")
            }
            .accessibilityLabel("Zellij-Sweep, \(store.sessions.count) sessions")
            .task {
                await store.refresh()
                launchAtLoginStore.refresh()
            }
        }
        .menuBarExtraStyle(.window)

        Settings {
            ZellijSettingsView(launchAtLoginStore: launchAtLoginStore)
        }
    }
}
