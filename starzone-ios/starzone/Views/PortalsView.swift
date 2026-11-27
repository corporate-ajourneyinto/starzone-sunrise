import SwiftUI

struct PortalsView: View {
    @Environment(FestivalStore.self) private var store

    private enum PortalDestination: String, CaseIterable, Identifiable {
        case starzoneHome = "starzone.ch"
        case starzoneEvents = "Events"
        case sunriseMoments = "Sunrise Moments"
        case sunriseOffers = "Angebote"

        var id: String { rawValue }

        var url: URL {
            switch self {
            case .starzoneHome:
                return URL(string: "https://starzone.ch/de")!
            case .starzoneEvents:
                return URL(string: "https://starzone.ch/de/page/events")!
            case .sunriseMoments:
                return URL(string: "https://www.sunrise.ch/de/rewards/this-is-moments/")!
            case .sunriseOffers:
                return URL(string: "https://www.sunrise.ch/de/rewards/offers/")!
            }
        }
    }

    @State private var selectedPortal: PortalDestination = .starzoneHome
    @State private var reloadToken = 0
    @State private var showSafariSheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(PortalDestination.allCases) { portal in
                            Button {
                                selectedPortal = portal
                            } label: {
                                Text(portal.rawValue)
                                    .font(.caption.weight(.bold))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    .foregroundStyle(selectedPortal == portal ? .white : SunriseTheme.ink)
                                    .background(selectedPortal == portal ? SunriseTheme.red : SunriseTheme.background)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                }
                .background(Color.white)
                .overlay(alignment: .bottom) {
                    Divider()
                }

                EmbeddedWebView(url: selectedPortal.url, reloadToken: reloadToken)
                    .ignoresSafeArea(edges: .bottom)
            }
            .navigationTitle("starzone & Sunrise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        reloadToken += 1
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }

                    Button {
                        showSafariSheet = true
                    } label: {
                        Image(systemName: "safari")
                    }

                    Menu {
                        Button("Demo-Daten zurücksetzen", role: .destructive) {
                            store.resetDemoData()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showSafariSheet) {
                SafariSheetView(url: selectedPortal.url)
                    .ignoresSafeArea()
            }
        }
    }
}
