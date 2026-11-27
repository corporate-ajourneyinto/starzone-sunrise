import AVFoundation
import SwiftUI
import UIKit

struct LiveCamBackstageView: View {
    @Environment(FestivalStore.self) private var store

    @State private var selectedStageName = "Nordstern Hauptbühne"
    @State private var captionText = ""
    @State private var cameraActive = false
    @State private var showLightstickFullscreen = false
    @State private var lightstickColor: Color = SunriseTheme.red

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    seeMeStudioCard
                    lightstickCard
                    liveBroadcastsFeedCard
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(SunriseTheme.background)
            .navigationTitle("Live-Kamera & Show")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $showLightstickFullscreen) {
                LightstickFullscreenView(baseColor: $lightstickColor)
            }
        }
    }

    // MARK: - See Me! Stage-Screen Studio

    private var seeMeStudioCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("See me! · Stage-Screen Studio")
                        .font(.headline.weight(.bold))
                    Text("Sende deinen Live-Clip direkt auf die Stage-Wings & Social Wall")
                        .font(.caption)
                        .foregroundStyle(SunriseTheme.muted)
                }
                Spacer()
                SunrisePillBadge(text: "LIVE", background: SunriseTheme.red, foreground: .white)
            }

            ZStack {
                if cameraActive {
                    NativeCameraPreview()
                        .frame(height: 210)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    ZStack {
                        Image("festival_secret_stage")
                            .resizable()
                            .scaledToFill()
                            .frame(height: 210)
                            .clipped()
                            .overlay(Color.black.opacity(0.45))

                        VStack(spacing: 8) {
                            Image(systemName: "video.circle.fill")
                                .font(.system(size: 42))
                                .foregroundStyle(.white)
                            Text("Kamera-Vorschau starten")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(.white)
                            Text("Nutzt native iOS-Kamera (AVFoundation)")
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .onTapGesture {
                        cameraActive = true
                    }
                }
            }

            HStack {
                Button(cameraActive ? "Kamera pausieren" : "Live-Kamera öffnen") {
                    cameraActive.toggle()
                }
                .font(.caption.weight(.bold))
                .foregroundStyle(SunriseTheme.ink)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(SunriseTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(SunriseTheme.borderStrong))

                Spacer()

                Picker("Bühne", selection: $selectedStageName) {
                    ForEach(store.state.stages) { stage in
                        Text(stage.name).tag(stage.name)
                    }
                }
                .pickerStyle(.menu)
            }

            TextField("Dein Gruß für die Bühnenleinwand…", text: $captionText)
                .font(.subheadline)
                .padding(10)
                .background(SunriseTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Button {
                store.publishBroadcast(stageName: selectedStageName, caption: captionText)
                captionText = ""
            } label: {
                Label("Auf Stage-Screen senden (+160 XP)", systemImage: "paperplane.fill")
                    .font(.subheadline.weight(.bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .foregroundStyle(.white)
                    .background(captionText.trimmingCharacters(in: .whitespaces).isEmpty ? SunriseTheme.borderStrong : SunriseTheme.red)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .disabled(captionText.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .sunriseCard()
    }

    // MARK: - Stars Sparkling Lightstick

    private var lightstickCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Stars sparkling: „Lights on“")
                        .font(.headline.weight(.bold))
                    Text("Synchronisierte Vollbild-Lightstick-Show für dein iPhone-Display")
                        .font(.caption)
                        .foregroundStyle(SunriseTheme.muted)
                }
                Spacer()
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundStyle(SunriseTheme.red)
            }

            HStack(spacing: 10) {
                colorDot(SunriseTheme.red, label: "Sunrise")
                colorDot(SunriseTheme.orange, label: "Sunset")
                colorDot(SunriseTheme.teal, label: "Lagoon")
                colorDot(.purple, label: "Encore")
            }

            Button {
                store.activateLightstickQuest()
                showLightstickFullscreen = true
            } label: {
                Label("Vollbild-Lightstick starten (+140 XP)", systemImage: "sun.max.fill")
                    .font(.subheadline.weight(.bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .foregroundStyle(.white)
                    .background(SunriseTheme.navGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .sunriseTierCard()
    }

    // MARK: - Live Broadcasts Feed

    private var liveBroadcastsFeedCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Aktuelle Stage-Screen-Momente")
                .font(.headline.weight(.bold))

            ForEach(store.state.broadcasts) { clip in
                VStack(alignment: .leading, spacing: 8) {
                    if let asset = clip.assetImageName {
                        Image(asset)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 150)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(clip.author)
                                .font(.subheadline.weight(.bold))
                            Text("\(clip.stageName) · \(clip.timestamp)")
                                .font(.caption2)
                                .foregroundStyle(SunriseTheme.muted)
                        }
                        Spacer()
                        Button {
                            store.cheerBroadcast(id: clip.id)
                        } label: {
                            Label("\(clip.cheers)", systemImage: "hands.clap.fill")
                                .font(.caption.weight(.bold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .foregroundStyle(SunriseTheme.red)
                                .background(SunriseTheme.red.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }

                    Text(clip.caption)
                        .font(.subheadline)
                }
                .padding(12)
                .background(SunriseTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .sunriseCard()
    }

    private func colorDot(_ color: Color, label: String) -> some View {
        Button {
            lightstickColor = color
        } label: {
            VStack(spacing: 4) {
                Circle()
                    .fill(color)
                    .frame(width: 30, height: 30)
                    .overlay(
                        Circle().stroke(SunriseTheme.ink, lineWidth: lightstickColor == color ? 2.5 : 0)
                    )
                Text(label)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(SunriseTheme.muted)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Fullscreen Lightstick Show

private struct LightstickFullscreenView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var baseColor: Color
    @State private var pulse = false
    @State private var previousBrightness: CGFloat = 0.5

    var body: some View {
        ZStack {
            baseColor
                .opacity(pulse ? 1.0 : 0.72)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.65).repeatForever(autoreverses: true), value: pulse)

            VStack(spacing: 20) {
                Spacer()
                Image(systemName: "sparkles")
                    .font(.system(size: 72))
                    .foregroundStyle(.white)
                    .scaleEffect(pulse ? 1.18 : 0.92)
                    .animation(.easeInOut(duration: 0.65).repeatForever(autoreverses: true), value: pulse)

                Text("STARS SPARKLING · LIGHTS ON")
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(.white)
                    .tracking(1.5)

                Text("Halte dein iPhone hoch Richtung Bühne!")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))

                Spacer()

                Button("Beenden") {
                    dismiss()
                }
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 12)
                .background(.black.opacity(0.35))
                .clipShape(Capsule())
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            previousBrightness = UIScreen.main.brightness
            UIScreen.main.brightness = 1.0
            pulse = true
        }
        .onDisappear {
            UIScreen.main.brightness = previousBrightness
        }
    }
}

// MARK: - Native AVFoundation Camera Preview (with Simulator Fallback)

private struct NativeCameraPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> CameraContainerView {
        CameraContainerView()
    }

    func updateUIView(_ uiView: CameraContainerView, context: Context) {}
}

private final class CameraContainerView: UIView {
    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        setupCameraIfAvailable()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCameraIfAvailable() {
        #if targetEnvironment(simulator)
        showFallbackLabel("Live-Kamera Vorschau (auf echtem iPhone aktiv)")
        #else
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) ??
                AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            showFallbackLabel("Kamera-Berechtigung in iOS-Einstellungen aktivieren")
            return
        }
        session.addInput(input)
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        self.layer.addSublayer(layer)
        self.previewLayer = layer
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
        #endif
    }

    private func showFallbackLabel(_ text: String) {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }

    deinit {
        if session.isRunning {
            session.stopRunning()
        }
    }
}
