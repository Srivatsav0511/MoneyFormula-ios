import StoreKit
import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.requestReview) private var requestReview
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(CurrencyManager.self) private var currencyManager

    @Query private var history: [CalculationHistory]
    @Query private var favorites: [FavoriteFormula]

    @AppStorage("settings.theme") private var theme: String = "system"
    @AppStorage("settings.haptics") private var hapticsEnabled: Bool = true

    @State private var confirmClearHistory: Bool = false
    @State private var confirmClearFavorites: Bool = false

    var body: some View {
        Form {
            appearanceSection
            preferencesSection
            dataSection
            aboutSection
        }
        .listStyle(.insetGrouped)
        .tint(Color(uiColor: .systemBlue))
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .alert("Clear all history?", isPresented: $confirmClearHistory) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                HapticManager.play(.warning)
                history.forEach(modelContext.delete)
            }
        } message: {
            Text("This permanently removes all saved calculations.")
        }
        .alert("Clear all favorites?", isPresented: $confirmClearFavorites) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                HapticManager.play(.warning)
                favorites.forEach(modelContext.delete)
            }
        } message: {
            Text("This removes every favorited formula.")
        }
    }

    private var appearanceSection: some View {
        Section("Appearance") {
            Picker("Currency", selection: Binding(
                get: { currencyManager.currencyCode },
                set: { currencyManager.setCurrency(code: $0) }
            )) {
                ForEach(currencyManager.supportedCurrencies, id: \.code) { option in
                    Text("\(option.code)  \(option.symbol)").tag(option.code)
                }
            }

            Picker("Theme", selection: $theme) {
                Text("System").tag("system")
                Text("Light").tag("light")
                Text("Dark").tag("dark")
            }
        }
    }

    private var preferencesSection: some View {
        Section("Preferences") {
            Toggle("Haptic Feedback", isOn: $hapticsEnabled)
        }
    }

    private var dataSection: some View {
        Section("Data") {
            Button(role: .destructive) {
                confirmClearHistory = true
            } label: {
                Label("Clear All History", systemImage: "trash")
            }

            Button(role: .destructive) {
                confirmClearFavorites = true
            } label: {
                Label("Clear Favorites", systemImage: "heart.slash")
            }

            Text("All data stays on this device only.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var aboutSection: some View {
        Section("About") {
            LabeledContent("Version") {
                Text(appVersion)
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
            }

            Button {
                HapticManager.play(.tap)
                requestReview()
            } label: {
                Label("Rate Us", systemImage: "star")
            }
        }
    }

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }
}
