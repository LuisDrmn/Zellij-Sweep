import Foundation
import Observation
import ServiceManagement

@MainActor
@Observable
final class LaunchAtLoginStore {
    private(set) var isEnabled = false
    private(set) var requiresApproval = false
    var errorMessage: String?

    init() {
        refresh()
    }

    func refresh() {
        let status = SMAppService.mainApp.status
        isEnabled = status == .enabled
        requiresApproval = status == .requiresApproval

        if requiresApproval {
            errorMessage = "Open System Settings to approve launch at login."
        }
    }

    func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }

            errorMessage = nil
            refresh()
        } catch {
            refresh()
            errorMessage = error.localizedDescription
        }
    }
}
