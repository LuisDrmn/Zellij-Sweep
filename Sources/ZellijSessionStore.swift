import Foundation
import Observation

@MainActor
@Observable
final class ZellijSessionStore {
    private static let pinnedSessionIDsKey = "PinnedZellijSessionIDs"

    private let client: ZellijClient
    private let userDefaults: UserDefaults

    private(set) var sessions: [ZellijSession] = []
    private(set) var isRefreshing = false
    private(set) var deletingSessionIDs: Set<ZellijSession.ID> = []
    private(set) var forceDeleteSessionIDs: Set<ZellijSession.ID> = []
    private(set) var deleteErrorMessages: [ZellijSession.ID: String] = [:]
    private(set) var pinnedSessionIDs: Set<ZellijSession.ID>
    var errorMessage: String?

    init(client: ZellijClient, userDefaults: UserDefaults = .standard) {
        self.client = client
        self.userDefaults = userDefaults
        self.pinnedSessionIDs = Set(userDefaults.stringArray(forKey: Self.pinnedSessionIDsKey) ?? [])
    }

    var hasSessions: Bool {
        !sessions.isEmpty
    }

    func refresh() async {
        await refresh(clearErrorOnSuccess: true)
    }

    private func refresh(clearErrorOnSuccess: Bool) async {
        guard !isRefreshing else {
            return
        }

        isRefreshing = true
        defer { isRefreshing = false }

        do {
            sessions = try await client.listSessions()
            let sessionIDs = Set(sessions.map(\.id))
            forceDeleteSessionIDs.formIntersection(sessionIDs)
            deleteErrorMessages = deleteErrorMessages.filter { sessionIDs.contains($0.key) }

            if clearErrorOnSuccess {
                errorMessage = nil
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func delete(_ session: ZellijSession, force: Bool = false) async {
        guard !pinnedSessionIDs.contains(session.id) else {
            deleteErrorMessages[session.id] = "Unpin this session before deleting it."
            return
        }

        guard !deletingSessionIDs.contains(session.id) else {
            return
        }

        deletingSessionIDs.insert(session.id)
        defer { deletingSessionIDs.remove(session.id) }

        do {
            try await client.deleteSession(session.name, force)
            forceDeleteSessionIDs.remove(session.id)
            deleteErrorMessages[session.id] = nil
            errorMessage = nil
            await refresh()
        } catch {
            deleteErrorMessages[session.id] = error.localizedDescription
            if !force, let zellijError = error as? ZellijCommandError, zellijError.requiresForceDelete {
                forceDeleteSessionIDs.insert(session.id)
            }
            await refresh(clearErrorOnSuccess: false)
        }
    }

    func forceDeleteUnpinnedSessions() async {
        let sessionsToDelete = sessions.filter { !pinnedSessionIDs.contains($0.id) }
        guard !sessionsToDelete.isEmpty else {
            return
        }

        for session in sessionsToDelete {
            await delete(session, force: true)
        }
    }

    func togglePin(for session: ZellijSession) {
        if pinnedSessionIDs.contains(session.id) {
            pinnedSessionIDs.remove(session.id)
        } else {
            pinnedSessionIDs.insert(session.id)
            deleteErrorMessages[session.id] = nil
        }

        userDefaults.set(Array(pinnedSessionIDs).sorted(), forKey: Self.pinnedSessionIDsKey)
    }
}
