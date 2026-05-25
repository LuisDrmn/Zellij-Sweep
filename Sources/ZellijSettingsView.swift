import SwiftUI

struct ZellijSettingsView: View {
    @Bindable var launchAtLoginStore: LaunchAtLoginStore

    var body: some View {
        TabView {
            generalSettings
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }

            aboutSettings
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .padding(20)
        .frame(width: 420, height: 200)
    }

    private var generalSettings: some View {
        Form {
            Toggle(isOn: Binding(
                get: { launchAtLoginStore.isEnabled },
                set: { launchAtLoginStore.setEnabled($0) }
            )) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Open at Login")
                    Text("Start Zellij-Sweep automatically when you log in.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .disabled(launchAtLoginStore.requiresApproval)

            if let errorMessage = launchAtLoginStore.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .formStyle(.automatic)
        .task {
            launchAtLoginStore.refresh()
        }
    }

    private var aboutSettings: some View {
        VStack(alignment: .center, spacing: 20) {
            HStack(alignment: .center, spacing: 28) {
                appIcon

                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("Zellij-Sweep")
                            .font(.title2.bold())
                        Text("Version \(appVersion)")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }

                    Text(copyright)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    private var appIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.quaternary)
                .frame(width: 88, height: 88)
                .shadow(color: .black.opacity(0.18), radius: 8, y: 4)

            Image(systemName: "rectangle.stack.badge.minus")
                .font(.system(size: 42, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.blue)
        }
    }

    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (\(build))"
    }

    private var copyright: String {
        Bundle.main.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as? String
            ?? "Zellij-Sweep © [Jean-Louis Darmon]"
    }

    private var bundleIdentifier: String {
        Bundle.main.bundleIdentifier ?? "dev.jldrmn.Zellij-Sweep"
    }
}
