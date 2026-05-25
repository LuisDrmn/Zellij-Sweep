import SwiftUI

struct ZellijSessionRowView: View {
    let session: ZellijSession
    let isDeleting: Bool
    let isPinned: Bool
    let showsForceDelete: Bool
    let errorMessage: String?
    let togglePinAction: () -> Void
    let deleteAction: () -> Void
    let forceDeleteAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.name)
                        .font(.body.weight(.medium))
                        .lineLimit(1)
                        .truncationMode(.middle)

                    Text(session.detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                Button(action: togglePinAction) {
                    Image(systemName: isPinned ? "star.fill" : "star")
                        .frame(width: 16, height: 16)
                        .foregroundStyle(isPinned ? .yellow : .secondary)
                }
                .buttonStyle(.borderless)
                .disabled(isDeleting)
                .help(isPinned ? "Unpin \(session.name)" : "Pin \(session.name)")

                if !isPinned {
                    if showsForceDelete {
                        Button(role: .destructive, action: forceDeleteAction) {
                            Text("Force")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.white)
                        }
                        .buttonStyle(.borderless)
                        .controlSize(.small)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.red, in: RoundedRectangle(cornerRadius: 5))
                        .disabled(isDeleting)
                        .opacity(isDeleting ? 0.5 : 1)
                        .help("Force delete \(session.name)")
                    }

                    Button(role: .destructive, action: deleteAction) {
                        if isDeleting {
                            ProgressView()
                                .controlSize(.small)
                                .frame(width: 16, height: 16)
                        } else {
                            Image(systemName: "trash")
                                .frame(width: 16, height: 16)
                        }
                    }
                    .buttonStyle(.borderless)
                    .disabled(isDeleting)
                    .help("Delete \(session.name)")
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(.quaternary.opacity(0.45), in: RoundedRectangle(cornerRadius: 6))
    }
}
