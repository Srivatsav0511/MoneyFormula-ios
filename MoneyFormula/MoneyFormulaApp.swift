//
//  MoneyFormulaApp.swift
//  MoneyFormula
//
//  Created by Srivatsav Karamala on 3/27/26.
//

import SwiftUI
import SwiftData

@main
struct MoneyFormulaApp: App {
    @State private var adManager = AdManager()
    @State private var currencyManager = CurrencyManager()
    @State private var showsSplash = true

    var sharedModelContainer: ModelContainer = {
        let schemaTypes: [any PersistentModel.Type] = [
            CalculationHistory.self,
            FavoriteFormula.self,
            FinancialGoal.self,
            AppSettings.self
        ]

        let fileManager = FileManager.default
        let appSupportURL = (try? fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )) ?? fileManager.temporaryDirectory
        let storeURL = appSupportURL.appending(path: "MoneyFormula.store")

        func makePersistentContainer() throws -> ModelContainer {
            try ModelContainer(
                for: CalculationHistory.self,
                FavoriteFormula.self,
                FinancialGoal.self,
                AppSettings.self,
                configurations: ModelConfiguration(url: storeURL)
            )
        }

        do {
            return try makePersistentContainer()
        } catch {
            // Attempt one-time store recovery in case of a corrupted SQLite store.
            try? fileManager.removeItem(at: storeURL)
            try? fileManager.removeItem(at: URL(fileURLWithPath: storeURL.path + "-shm"))
            try? fileManager.removeItem(at: URL(fileURLWithPath: storeURL.path + "-wal"))

            if let recovered = try? makePersistentContainer() {
                return recovered
            }

            if let memoryContainer = try? ModelContainer(
                for: CalculationHistory.self,
                FavoriteFormula.self,
                FinancialGoal.self,
                AppSettings.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            ) {
                return memoryContainer
            }

            fatalError("Unable to initialize SwiftData container for schema: \(schemaTypes)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()

                if showsSplash {
                    PremiumSplashView(subtitle: "Smarter Math for Real Markets")
                        .zIndex(1)
                }
            }
            .environment(adManager)
            .environment(currencyManager)
            .task {
                await runStartupSequence()
            }
        }
        .modelContainer(sharedModelContainer)
    }

    /// Performs launch analytics, non-blocking SDK initialization, and splash dismissal.
    private func runStartupSequence() async {
        adManager.markAppLaunch()

        Task(priority: .utility) {
            adManager.initializeSDKs()
        }

        try? await Task.sleep(for: .seconds(1))
        await MainActor.run {
            showsSplash = false
        }
    }
}
