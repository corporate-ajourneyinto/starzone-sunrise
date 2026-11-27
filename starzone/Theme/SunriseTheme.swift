import SwiftUI

enum SunriseTheme {
    // Core palette (Sunrise Rewards Designsystem)
    static let background = Color(hex: 0xF7F6F5)
    static let surface = Color.white
    static let border = Color(hex: 0xE6E3DF)
    static let borderStrong = Color(hex: 0xB3AEAA)
    static let ink = Color(hex: 0x3D3935)
    static let muted = Color(hex: 0x5F5955)
    static let subtle = Color(hex: 0x86807C)
    static let red = Color(hex: 0xDA291C)
    static let redHover = Color(hex: 0xB81E13)
    static let orange = Color(hex: 0xEF7C3C)
    static let teal = Color(hex: 0x008187)
    static let sand = Color(hex: 0xF6D6B3)

    static let navGradient = LinearGradient(
        colors: [Color(hex: 0xE2271E), Color(hex: 0xEF7C3C)],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let tierGradient = LinearGradient(
        colors: [Color(hex: 0x008187), Color(hex: 0xF6D6B3)],
        startPoint: .trailing,
        endPoint: .leading
    )
}

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}

struct SunriseCardModifier: ViewModifier {
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(SunriseTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(SunriseTheme.border, lineWidth: 1)
            )
            .shadow(color: SunriseTheme.ink.opacity(0.08), radius: 8, x: 0, y: 3)
    }
}

struct SunriseTierCardModifier: ViewModifier {
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(SunriseTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(SunriseTheme.tierGradient, lineWidth: 2)
            )
            .shadow(color: SunriseTheme.ink.opacity(0.1), radius: 10, x: 0, y: 4)
    }
}

extension View {
    func sunriseCard(padding: CGFloat = 16) -> some View {
        modifier(SunriseCardModifier(padding: padding))
    }

    func sunriseTierCard(padding: CGFloat = 16) -> some View {
        modifier(SunriseTierCardModifier(padding: padding))
    }
}

struct SunrisePillBadge: View {
    let text: String
    var background: Color = SunriseTheme.red.opacity(0.12)
    var foreground: Color = SunriseTheme.red

    var body: some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .foregroundStyle(foreground)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(background)
            .clipShape(Capsule())
    }
}

struct StarzoneBrandHeader<Trailing: View>: View {
    var sectionTitle: String? = nil
    @ViewBuilder var trailing: () -> Trailing

    init(sectionTitle: String? = nil, @ViewBuilder trailing: @escaping () -> Trailing) {
        self.sectionTitle = sectionTitle
        self.trailing = trailing
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image("starzone_header_logo")
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(height: 46, alignment: .leading)
                .accessibilityLabel("starzone presented by Sunrise")

            Spacer(minLength: 8)

            HStack(spacing: 8) {
                if let sectionTitle {
                    Text(sectionTitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SunriseTheme.muted)
                        .lineLimit(1)
                }
                trailing()
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity)
        .background(SunriseTheme.background.ignoresSafeArea(edges: .top))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(SunriseTheme.border)
                .frame(height: 1)
        }
    }
}

extension StarzoneBrandHeader where Trailing == EmptyView {
    init(sectionTitle: String? = nil) {
        self.sectionTitle = sectionTitle
        self.trailing = { EmptyView() }
    }
}

struct StarzoneHeaderIconButton: View {
    let systemImage: String
    var tint: Color = SunriseTheme.ink
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 36, height: 36)
                .background(SunriseTheme.surface)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(SunriseTheme.border, lineWidth: 1)
                )
                .shadow(color: SunriseTheme.ink.opacity(0.06), radius: 4, x: 0, y: 2)
        }
        .accessibilityLabel(accessibilityLabel)
    }
}
