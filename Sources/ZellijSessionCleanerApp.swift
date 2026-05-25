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
            HStack(spacing: 4) {
                Image(systemName: "rectangle.stack.badge.minus")
                Text("\(store.sessions.count)")
            }
            .accessibilityLabel("Zellij-Sweep, \(store.sessions.count) sessions")
            .task {
                await store.refresh()
            }
        }
        .menuBarExtraStyle(.window)
    }
}
