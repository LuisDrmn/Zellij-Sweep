import Foundation

struct ZellijClient: Sendable {
    var listSessions: @Sendable () async throws -> [ZellijSession]
    var deleteSession: @Sendable (_ name: String, _ force: Bool) async throws -> Void
}

extension ZellijClient {
    static let live = ZellijClient(
        listSessions: {
            let result = try await ZellijCommandRunner.run(arguments: ["list-sessions", "--no-formatting"])
            return result.standardOutput
                .split(whereSeparator: \.isNewline)
                .compactMap { ZellijSession(listOutputLine: String($0)) }
        },
        deleteSession: { name, force in
            var arguments = ["delete-session"]
            if force {
                arguments.append("--force")
            }
            arguments.append(name)

            _ = try await ZellijCommandRunner.run(arguments: arguments)
        }
    )
}

enum ZellijCommandError: LocalizedError {
    case commandFailed(command: String, status: Int32, output: String)
    case unreadableOutput

    var errorDescription: String? {
        switch self {
        case .commandFailed(let command, let status, let output):
            let message = output.trimmingCharacters(in: .whitespacesAndNewlines)
            if message.isEmpty {
                return "\(command) failed with exit code \(status)."
            }

            return "\(command) failed with exit code \(status): \(message)"
        case .unreadableOutput:
            return "Zellij returned output that could not be decoded."
        }
    }

    var requiresForceDelete: Bool {
        guard case .commandFailed(_, _, let output) = self else {
            return false
        }

        return output.localizedCaseInsensitiveContains("exists and is active")
            && output.localizedCaseInsensitiveContains("use --force")
    }
}

private enum ZellijCommandRunner {
    struct Result: Sendable {
        let standardOutput: String
        let standardError: String
    }

    static func run(arguments: [String]) async throws -> Result {
        try await Task.detached(priority: .userInitiated) {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
            process.arguments = ["zellij"] + arguments
            process.environment = commandEnvironment

            let standardOutput = Pipe()
            let standardError = Pipe()
            process.standardOutput = standardOutput
            process.standardError = standardError

            try process.run()
            process.waitUntilExit()

            let outputData = standardOutput.fileHandleForReading.readDataToEndOfFile()
            let errorData = standardError.fileHandleForReading.readDataToEndOfFile()

            guard
                let output = String(data: outputData, encoding: .utf8),
                let error = String(data: errorData, encoding: .utf8)
            else {
                throw ZellijCommandError.unreadableOutput
            }

            guard process.terminationStatus == 0 else {
                throw ZellijCommandError.commandFailed(
                    command: "zellij \(arguments.joined(separator: " "))",
                    status: process.terminationStatus,
                    output: error.isEmpty ? output : error
                )
            }

            return Result(standardOutput: output, standardError: error)
        }.value
    }

    private static var commandEnvironment: [String: String] {
        var environment = ProcessInfo.processInfo.environment
        let fallbackPath = [
            "/opt/homebrew/bin",
            "/usr/local/bin",
            "/usr/bin",
            "/bin",
            "/usr/sbin",
            "/sbin",
        ].joined(separator: ":")

        if let path = environment["PATH"], !path.isEmpty {
            environment["PATH"] = "\(fallbackPath):\(path)"
        } else {
            environment["PATH"] = fallbackPath
        }

        return environment
    }
}
