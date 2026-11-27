import SwiftUI
import UIKit

@main
struct StarzoneApp: App {
    @State private var store = FestivalStore()

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
            MainTabView()
                .environment(store)
                .tint(SunriseTheme.red)
                .preferredColorScheme(.light)
        }
    }
}
