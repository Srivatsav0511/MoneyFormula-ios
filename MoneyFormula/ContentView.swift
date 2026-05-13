import SwiftUI

struct ContentView: View {
    @AppStorage("settings.theme") private var theme: String = "system"

    var body: some View {
        MainTabView()
            .background(Color(uiColor: .systemBackground).ignoresSafeArea())
            .preferredColorScheme(preferredColorScheme)
            .fontDesign(.default)
            .animation(MMMotion.navigation, value: preferredColorScheme)
    }

    private var preferredColorScheme: ColorScheme? {
        switch theme {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return nil
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
