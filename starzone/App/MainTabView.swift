import SwiftUI

struct MainTabView: View {
    @Environment(FestivalStore.self) private var store
    @State private var focusedStageId: StageId = .mainstage

    var body: some View {
        @Bindable var bindableStore = store

        ZStack(alignment: .top) {
            TabView(selection: $bindableStore.activeTab) {
                MapLineupView(selectedStageId: $focusedStageId)
                    .tabItem {
                        Label(MainTab.map.rawValue, systemImage: MainTab.map.systemImage)
                    }
                    .tag(MainTab.map)

                QuestsGamesView()
                    .tabItem {
                        Label(MainTab.quests.rawValue, systemImage: MainTab.quests.systemImage)
                    }
                    .tag(MainTab.quests)

                CommunityView()
                    .tabItem {
                        Label(MainTab.community.rawValue, systemImage: MainTab.community.systemImage)
                    }
                    .tag(MainTab.community)

                VotingWalletView()
                    .tabItem {
                        Label(MainTab.wallet.rawValue, systemImage: MainTab.wallet.systemImage)
                    }
                    .tag(MainTab.wallet)

                LiveCamBackstageView()
                    .tabItem {
                        Label(MainTab.livecam.rawValue, systemImage: MainTab.livecam.systemImage)
                    }
                    .tag(MainTab.livecam)

                PortalsView()
                    .tabItem {
                        Label(MainTab.portals.rawValue, systemImage: MainTab.portals.systemImage)
                    }
                    .tag(MainTab.portals)
            }

            if !store.toasts.isEmpty {
                PushToastOverlay(
                    toasts: store.toasts,
                    onDismiss: { store.dismissToast(id: $0) },
                    onSelectStage: { stageId in
                        focusedStageId = stageId
                        store.activeTab = .map
                    }
                )
            }
        }
    }
}
