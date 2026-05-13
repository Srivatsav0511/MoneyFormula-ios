import SwiftData
import SwiftUI

struct FavoritesView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \FavoriteFormula.sortOrder) private var pinnedFormulas: [FavoriteFormula]
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: MMGrid.sectionGap) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("BOOKMARKS")
                            .font(MMType.sectionEyebrow)
                            .tracking(1.8)
                            .foregroundStyle(.secondary)
                        Text("Pinned Formulas")
                            .font(.largeTitle.weight(.bold))
                            .foregroundStyle(.primary)
                        Text("Your quick-access calculator shelf.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if pinnedFormulas.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "heart.slash")
                                .font(.system(size: 56, weight: .regular))
                                .foregroundStyle(.quaternary)
                            Text("No Bookmarked Formulas")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(.secondary)
                            Text("Tap heart on any formula to add it here.")
                                .font(MMType.cardSubtitle)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 28)
                    } else {
                        LazyVGrid(
                            columns: [GridItem(.flexible(), spacing: MMGrid.x16), GridItem(.flexible(), spacing: MMGrid.x16)],
                            spacing: MMGrid.x16
                        ) {
                            ForEach(pinnedFormulas, id: \.id) { item in
                                if let formula = formulaByID(item.formulaID) {
                                    NavigationLink {
                                        FormulaDetailView(formula: formula)
                                    } label: {
                                        FormulaCard(formula: formula, layout: .square)
                                            .aspectRatio(1, contentMode: .fit)
                                    }
                                    .buttonStyle(CardPressStyle())
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            modelContext.delete(item)
                                            HapticManager.impact(.rigid)
                                        } label: {
                                            Label("Remove Bookmark", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, MMGrid.horizontalPadding)
                .padding(.top, MMGrid.x20)
                .safeAreaPadding(.bottom, 96)
            }
            .background(PremiumBackground())
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    SettingsGlassButton {
                        showingSettings = true
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                NavigationStack {
                    SettingsView()
                }
                .mmNativePopupSheet()
            }
        }
    }
    private func formulaByID(_ id: String) -> FormulaDefinition? {
        AllFormulas.all.first { $0.id == id }
    }
}
