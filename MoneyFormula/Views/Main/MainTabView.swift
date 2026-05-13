import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tag(Tab.home)
                .tabItem {
                    Label(Tab.home.rawValue, systemImage: Tab.home.icon)
                }

            HistoryView()
                .tag(Tab.history)
                .tabItem {
                    Label(Tab.history.rawValue, systemImage: Tab.history.icon)
                }

            SearchView()
                .tag(Tab.search)
                .tabItem {
                    Label(Tab.search.rawValue, systemImage: Tab.search.icon)
                }
        }
        .tint(MMPalette.appTint)
        .tabBarMinimizeBehavior(.onScrollDown)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(.regularMaterial, for: .tabBar)
        .toolbarColorScheme(nil, for: .tabBar)
        .onChange(of: selectedTab) { _, _ in
            HapticManager.play(.selection)
        }
    }
}

struct SettingsGlassButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "gearshape.fill")
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.primary)
                .font(.system(size: 17, weight: .medium, design: .default))
                .frame(width: 36, height: 36)
        }
        .tint(.primary)
        .mmNativeGlassButton()
        .accessibilityLabel("Settings")
        .accessibilityHint("Opens app settings")
    }
}
