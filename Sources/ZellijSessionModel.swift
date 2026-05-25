import Foundation

struct ZellijSession: Identifiable, Equatable {
    let name: String
    let detail: String

    var id: String { name }
}

extension ZellijSession {
    init?(listOutputLine line: String) {
        let trimmedLine = line
            .removingANSIEscapeSequences
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedLine.isEmpty else {
            return nil
        }

        let nameEnd = trimmedLine.firstIndex(where: { $0 == " " || $0 == "[" || $0 == "(" }) ?? trimmedLine.endIndex
        let name = String(trimmedLine[..<nameEnd]).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            return nil
        }

        let detail = trimmedLine.zellijBracketedDetail ?? trimmedLine
        self.init(name: name, detail: detail)
    }
}

private extension String {
    var zellijBracketedDetail: String? {
        guard let start = firstIndex(of: "["), let end = self[start...].firstIndex(of: "]"), start < end else {
            return nil
        }

        return String(self[index(after: start)..<end])
    }

    var removingANSIEscapeSequences: String {
        replacingOccurrences(
            of: #"\u{001B}\[[0-?]*[ -/]*[@-~]"#,
            with: "",
            options: .regularExpression
        )
    }
}
