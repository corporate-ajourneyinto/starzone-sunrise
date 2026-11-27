import SwiftUI

struct PushToastOverlay: View {
    let toasts: [PushNotificationItem]
    let onDismiss: (String) -> Void
    let onSelectStage: (StageId) -> Void

    var body: some View {
        VStack(spacing: 8) {
            ForEach(toasts) { toast in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: toast.category.systemImage)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(accentColor(for: toast.category))
                        .frame(width: 28, height: 28)
                        .background(accentColor(for: toast.category).opacity(0.12))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(toast.title)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(SunriseTheme.ink)
                            Spacer()
                            Text(toast.timestamp)
                                .font(.caption2)
                                .foregroundStyle(SunriseTheme.subtle)
                        }
                        Text(toast.message)
                            .font(.caption)
                            .foregroundStyle(SunriseTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)

                        if let stageId = toast.stageId {
                            Button("Auf Karte zeigen") {
                                onSelectStage(stageId)
                                onDismiss(toast.id)
                            }
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(SunriseTheme.red)
                            .padding(.top, 2)
                        }
                    }

                    Button {
                        onDismiss(toast.id)
                    } label: {
                        Image(systemName: "xmark")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(SunriseTheme.subtle)
                            .padding(4)
                    }
                }
                .padding(12)
                .background(.ultraThinMaterial)
                .background(Color.white.opacity(0.92))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(SunriseTheme.border, lineWidth: 1)
                )
                .shadow(color: SunriseTheme.ink.opacity(0.16), radius: 12, x: 0, y: 4)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 6)
        .animation(.spring(response: 0.32, dampingFraction: 0.85), value: toasts)
    }

    private func accentColor(for category: PushCategory) -> Color {
        switch category {
        case .wetter, .konflikt: return SunriseTheme.orange
        case .quest: return SunriseTheme.teal
        default: return SunriseTheme.red
        }
    }
}
