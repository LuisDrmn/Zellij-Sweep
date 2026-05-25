import SwiftUI

struct ZellijMenuView: View {
    @Bindable var store: ZellijSessionStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            if let errorMessage = store.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }

            sessionContent

            Divider()

            footer
        }
        .padding(14)
        .frame(width: 360)
    }

    private var header: some View {
        HStack(spacing: 8) {
            Image(systemName: "terminal")
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text("Zellij Sessions")
                    .font(.headline)
                Text("\(store.sessions.count) found")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                Task { await store.refresh() }
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .buttonStyle(.borderless)
            .disabled(store.isRefreshing)
            .help("Refresh sessions")
        }
    }

    @ViewBuilder
    private var sessionContent: some View {
        if store.isRefreshing && !store.hasSessions {
            ProgressView()
                .frame(maxWidth: .infinity, minHeight: 80)
        } else if store.hasSessions {
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(store.sessions) { session in
                        ZellijSessionRowView(
                            session: session,
                            isDeleting: store.deletingSessionIDs.contains(session.id),
                            isPinned: store.pinnedSessionIDs.contains(session.id),
                            showsForceDelete: store.forceDeleteSessionIDs.contains(session.id),
                            errorMessage: store.deleteErrorMessages[session.id],
                            togglePinAction: {
                                store.togglePin(for: session)
                            },
                            deleteAction: {
                                Task { await store.delete(session) }
                            },
                            forceDeleteAction: {
                                Task { await store.delete(session, force: true) }
                            }
                        )
                    }
                }
            }
            .frame(maxHeight: 320)
        } else {
            ContentUnavailableView(
                "No Sessions",
                systemImage: "checkmark.circle",
                description: Text("Zellij did not report any sessions.")
            )
            .frame(minHeight: 120)
        }
    }

    private var footer: some View {
        HStack {
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")

            Spacer()

            if store.isRefreshing {
                ProgressView()
                    .controlSize(.small)
            }

            Button(role: .destructive) {
                Task { await store.forceDeleteUnpinnedSessions() }
            } label: {
                Text("Force Delete All")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
            }
            .buttonStyle(.borderless)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.red, in: RoundedRectangle(cornerRadius: 5))
            .disabled(!hasUnpinnedSessions || store.isRefreshing || !store.deletingSessionIDs.isEmpty)
            .opacity((!hasUnpinnedSessions || store.isRefreshing || !store.deletingSessionIDs.isEmpty) ? 0.5 : 1)
            .help("Force delete every unpinned session")
        }
    }

    private var hasUnpinnedSessions: Bool {
        store.sessions.contains { !store.pinnedSessionIDs.contains($0.id) }
    }
}
