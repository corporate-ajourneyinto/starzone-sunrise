import SwiftUI
import UIKit

@main
struct StarzoneApp: App {
    @State private var store = FestivalStore()
    @State private var showStartupScreen = true

    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(red: 0.969, green: 0.965, blue: 0.961, alpha: 1)
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance

        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(red: 0.969, green: 0.965, blue: 0.961, alpha: 1)
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor(red: 0.239, green: 0.224, blue: 0.208, alpha: 1)]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView()
                    .environment(store)
                    .scaleEffect(showStartupScreen ? 0.97 : 1.0)
                    .animation(.easeOut(duration: 0.45), value: showStartupScreen)

                if showStartupScreen {
                    StarzoneStartupView {
                        withAnimation(.easeInOut(duration: 0.42)) {
                            showStartupScreen = false
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .identity,
                        removal: .opacity.combined(with: .scale(scale: 1.06))
                    ))
                    .zIndex(10)
                }
            }
            .tint(SunriseTheme.red)
            .preferredColorScheme(showStartupScreen ? .dark : .light)
        }
    }
}

// MARK: - Animated Startup Screen

private struct StarzoneSparkleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let midX = rect.midX
        let midY = rect.midY
        let w = rect.width
        let h = rect.height
        let ctrlX = w * 0.14
        let ctrlY = h * 0.14

        var path = Path()
        path.move(to: CGPoint(x: midX, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: midY), control: CGPoint(x: midX + ctrlX, y: midY - ctrlY))
        path.addQuadCurve(to: CGPoint(x: midX, y: rect.maxY), control: CGPoint(x: midX + ctrlX, y: midY + ctrlY))
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: midY), control: CGPoint(x: midX - ctrlX, y: midY + ctrlY))
        path.addQuadCurve(to: CGPoint(x: midX, y: rect.minY), control: CGPoint(x: midX - ctrlX, y: midY - ctrlY))
        path.closeSubpath()
        return path
    }
}

private struct StarzoneStartupView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let onFinish: () -> Void

    @State private var glowActive = false
    @State private var logoVisible = false
    @State private var ringsExpanded = false
    @State private var shimmerOffset: CGFloat = -260
    @State private var taglineVisible = false
    @State private var equalizerActive = false
    @State private var sparklesTwinkle = false
    @State private var didFinish = false

    private struct SparkleSpec: Identifiable {
        let id: Int
        let xOffset: CGFloat
        let yOffset: CGFloat
        let size: CGFloat
        let delay: Double
    }

    private let sparkles: [SparkleSpec] = [
        SparkleSpec(id: 0, xOffset: -125, yOffset: -135, size: 18, delay: 0.15),
        SparkleSpec(id: 1, xOffset: 118, yOffset: -108, size: 24, delay: 0.25),
        SparkleSpec(id: 2, xOffset: -140, yOffset: 55, size: 13, delay: 0.35),
        SparkleSpec(id: 3, xOffset: 132, yOffset: 78, size: 16, delay: 0.20),
        SparkleSpec(id: 4, xOffset: 42, yOffset: -165, size: 12, delay: 0.40),
        SparkleSpec(id: 5, xOffset: -58, yOffset: 148, size: 15, delay: 0.30)
    ]

    private let barHeights: [CGFloat] = [14, 24, 30, 20, 16]

    var body: some View {
        ZStack {
            // Base Sunrise Red matching UILaunchScreen seamlessly
            SunriseTheme.red
                .ignoresSafeArea()

            // Animated warm festival sunrise gradient overlay
            LinearGradient(
                colors: [
                    Color(hex: 0xB81E13),
                    SunriseTheme.red,
                    SunriseTheme.orange.opacity(0.92)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .opacity(glowActive ? 1.0 : 0.0)
            .ignoresSafeArea()

            // Radial concert horizon glow
            RadialGradient(
                colors: [
                    Color.white.opacity(0.24),
                    SunriseTheme.sand.opacity(0.14),
                    Color.clear
                ],
                center: .center,
                startRadius: 10,
                endRadius: glowActive ? 320 : 120
            )
            .ignoresSafeArea()

            // Expanding stage pulse rings
            if !reduceMotion {
                ForEach(0..<2, id: \.self) { index in
                    Circle()
                        .stroke(Color.white.opacity(ringsExpanded ? 0.0 : 0.34), lineWidth: index == 0 ? 2.5 : 1.5)
                        .frame(width: 170, height: 170)
                        .scaleEffect(ringsExpanded ? (index == 0 ? 2.15 : 2.75) : 0.65)
                        .animation(
                            .easeOut(duration: 1.55).delay(Double(index) * 0.22),
                            value: ringsExpanded
                        )
                }
            }

            // Twinkling 4-point starzone sparkles
            if !reduceMotion {
                ForEach(sparkles) { sparkle in
                    StarzoneSparkleShape()
                        .fill(Color.white.opacity(sparklesTwinkle ? 0.92 : 0.0))
                        .frame(width: sparkle.size, height: sparkle.size)
                        .scaleEffect(sparklesTwinkle ? 1.0 : 0.2)
                        .rotationEffect(.degrees(sparklesTwinkle ? 0 : -40))
                        .shadow(color: .white.opacity(0.65), radius: 6)
                        .offset(x: sparkle.xOffset, y: sparkle.yOffset)
                        .animation(
                            .spring(response: 0.7, dampingFraction: 0.65).delay(sparkle.delay),
                            value: sparklesTwinkle
                        )
                }
            }

            // Center Brand Lockup & Tagline
            VStack(spacing: 26) {
                ZStack {
                    Image("starzone_header_logo")
                        .renderingMode(.template)
                        .resizable()
                        .interpolation(.high)
                        .scaledToFit()
                        .foregroundStyle(.white)
                        .frame(width: 248)
                        .shadow(color: Color.black.opacity(0.22), radius: 16, x: 0, y: 8)
                        .overlay {
                            if !reduceMotion {
                                LinearGradient(
                                    colors: [.clear, .white.opacity(0.65), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .frame(width: 85)
                                .rotationEffect(.degrees(18))
                                .offset(x: shimmerOffset)
                                .mask(
                                    Image("starzone_header_logo")
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 248)
                                )
                            }
                        }
                }
                .scaleEffect(logoVisible ? 1.0 : 0.78)
                .opacity(logoVisible ? 1.0 : 0.0)
                .offset(y: logoVisible ? 0 : 18)

                // Animated live festival equalizer
                HStack(spacing: 5) {
                    ForEach(0..<barHeights.count, id: \.self) { i in
                        Capsule()
                            .fill(Color.white.opacity(0.92))
                            .frame(
                                width: 4,
                                height: equalizerActive ? barHeights[i] : 6
                            )
                            .animation(
                                reduceMotion
                                    ? .default
                                    : .easeInOut(duration: 0.42)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(i) * 0.09),
                                value: equalizerActive
                            )
                    }
                }
                .frame(height: 32)
                .opacity(taglineVisible ? 1.0 : 0.0)

                VStack(spacing: 10) {
                    Text("LIVE · FESTIVAL 2026")
                        .font(.caption.weight(.heavy))
                        .tracking(1.6)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(.white.opacity(0.18))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(.white.opacity(0.35), lineWidth: 1)
                        )

                    Text("Dein Festival Companion")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.92))
                }
                .opacity(taglineVisible ? 1.0 : 0.0)
                .offset(y: taglineVisible ? 0 : 12)
            }
            .padding(.horizontal, 32)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            finishIfNeeded()
        }
        .task {
            await runAnimationTimeline()
        }
    }

    @MainActor
    private func runAnimationTimeline() async {
        if reduceMotion {
            withAnimation(.easeOut(duration: 0.35)) {
                glowActive = true
                logoVisible = true
                taglineVisible = true
            }
            try? await Task.sleep(for: .milliseconds(1050))
            finishIfNeeded()
            return
        }

        withAnimation(.easeOut(duration: 0.75)) {
            glowActive = true
        }
        withAnimation(.spring(response: 0.65, dampingFraction: 0.74)) {
            logoVisible = true
        }
        ringsExpanded = true
        sparklesTwinkle = true

        try? await Task.sleep(for: .milliseconds(320))
        withAnimation(.easeInOut(duration: 0.78)) {
            shimmerOffset = 260
        }
        withAnimation(.easeOut(duration: 0.5)) {
            taglineVisible = true
        }
        equalizerActive = true

        try? await Task.sleep(for: .milliseconds(1750))
        finishIfNeeded()
    }

    private func finishIfNeeded() {
        guard !didFinish else { return }
        didFinish = true
        onFinish()
    }
}
