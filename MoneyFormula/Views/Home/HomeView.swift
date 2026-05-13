import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Query(sort: \FavoriteFormula.sortOrder) private var favoriteFormulas: [FavoriteFormula]
    @State private var showingSettings = false
    @State private var featuredPage = 0
    @State private var featuredScrollID: Int?
    @State private var pauseFeaturedAutoCycle = false
    @State private var autoAdvancingFeatured = false
    private let featuredAutoAdvanceSeconds: Double = 4.0
    private let featuredResumeDelaySeconds: Double = 2.0

    private var allFormulaFeed: [FormulaDefinition] {
        AllFormulas.marketSorted(AllFormulas.all)
    }

    private var formulasByCategory: [FormulaCategory: [FormulaDefinition]] {
        Dictionary(grouping: allFormulaFeed, by: \.category)
    }

    private var featuredFormulas: [FormulaDefinition] {
        let lookup = Dictionary(uniqueKeysWithValues: allFormulaFeed.map { ($0.id, $0) })
        var seen = Set<String>()
        var favorites: [FormulaDefinition] = []

        for favorite in favoriteFormulas {
            guard let formula = lookup[favorite.formulaID] else { continue }
            guard seen.insert(formula.id).inserted else { continue }
            favorites.append(formula)
        }

        if !favorites.isEmpty {
            return Array(favorites.prefix(8))
        }

        let priority = allFormulaFeed.filter(\.isPriority)
        return Array((priority.isEmpty ? allFormulaFeed : priority).prefix(8))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        browseHeader
                        featuredSection

                        ForEach(FormulaCategory.ordered) { category in
                            if let formulas = formulasByCategory[category], !formulas.isEmpty {
                                browseShelf(category: category, formulas: Array(formulas.prefix(8)))
                                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                            }
                        }

                    }
                    .mmScreenPadding(top: 10, bottom: 112)
                }
                .safeAreaPadding(.top, 2)

                VStack {
                    HStack {
                        Spacer()
                        SettingsGlassButton {
                            HapticManager.play(.tap)
                            showingSettings = true
                        }
                    }
                    .padding(.horizontal, MMGrid.horizontalPadding)
                    .padding(.top, 8)
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSettings) {
                NavigationStack { SettingsView() }
                    .mmNativePopupSheet()
                    .presentationDragIndicator(.hidden)
            }
        }
    }

    private var browseHeader: some View {
        HStack(spacing: 12) {
            Text("MoneyFormula")
                .font(.largeTitle.weight(.bold))
                .tracking(-0.5)
                .foregroundStyle(.primary)
        }
    }

    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .lastTextBaseline) {
                Text("Featured")
                    .font(.largeTitle.weight(.bold))
                    .tracking(-0.45)
                    .foregroundStyle(.primary)

                Spacer()

                NavigationLink {
                    FavoritesView()
                } label: {
                    Text("See all")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary.opacity(0.9))
                }
                .buttonStyle(.plain)
            }

            if favoriteFormulas.isEmpty {
                Text("Add formulas to Favorites for faster access here.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            GeometryReader { proxy in
                let cardWidth = max(proxy.size.width - 6, 280)

                VStack(spacing: 10) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(Array(featuredFormulas.enumerated()), id: \.element.id) { index, formula in
                                NavigationLink {
                                    FormulaDetailView(formula: formula)
                                } label: {
                                    BrowseFeaturedCard(formula: formula)
                                        .frame(width: cardWidth, alignment: .leading)
                                }
                                .buttonStyle(CardPressStyle())
                                .id(index)
                            }
                        }
                        .padding(.horizontal, 1)
                        .padding(.vertical, 2)
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
                    .scrollPosition(id: $featuredScrollID)
                    .simultaneousGesture(
                        // Pause autoplay while the user interacts with the carousel.
                        DragGesture(minimumDistance: 14)
                            .onChanged { _ in
                                pauseFeaturedAutoCycle = true
                            }
                            .onEnded { _ in
                                DispatchQueue.main.asyncAfter(deadline: .now() + featuredResumeDelaySeconds) {
                                    pauseFeaturedAutoCycle = false
                                }
                            }
                    )
                    .onChange(of: featuredScrollID) { _, next in
                        guard let next else { return }
                        if next != featuredPage {
                            featuredPage = next
                        }
                    }
                    .onChange(of: featuredPage) { _, next in
                        if featuredScrollID != next {
                            featuredScrollID = next
                        }
                        // Manual page changes should temporarily pause autoplay.
                        guard !autoAdvancingFeatured else { return }
                        pauseFeaturedAutoCycle = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + featuredResumeDelaySeconds) {
                            pauseFeaturedAutoCycle = false
                        }
                    }
                    .task(id: featuredFormulas.map(\.id).joined(separator: ",")) {
                        featuredPage = 0
                        featuredScrollID = 0
                        guard featuredFormulas.count > 1, !reduceMotion else { return }
                        while !Task.isCancelled {
                            try? await Task.sleep(nanoseconds: UInt64(featuredAutoAdvanceSeconds * 1_000_000_000))
                            guard !Task.isCancelled else { break }
                            guard !pauseFeaturedAutoCycle else { continue }
                            await MainActor.run {
                                let next = (featuredPage + 1) % featuredFormulas.count
                                featuredPage = next
                                autoAdvancingFeatured = true
                                withAnimation(.easeInOut(duration: 0.42)) {
                                    featuredScrollID = next
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                    autoAdvancingFeatured = false
                                }
                            }
                        }
                    }

                    HStack(spacing: 7) {
                        ForEach(featuredFormulas.indices, id: \.self) { idx in
                            Capsule(style: .continuous)
                                .fill(idx == featuredPage ? Color.primary.opacity(0.52) : Color.primary.opacity(0.18))
                                .frame(width: idx == featuredPage ? 16 : 7, height: 7)
                                .animation(MMMotion.selection, value: featuredPage)
                        }
                    }
                }
            }
            .frame(height: 272)
        }
    }

    private func browseShelf(category: FormulaCategory, formulas: [FormulaDefinition]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(category.localizedDisplayName)
                    .font(.title2.weight(.bold))
                    .tracking(-0.3)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Spacer()

                NavigationLink {
                    CategoryCollectionView(category: category)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(formulas, id: \.id) { formula in
                        NavigationLink {
                            FormulaDetailView(formula: formula)
                        } label: {
                            BrowseFormulaMiniCard(formula: formula)
                        }
                        .buttonStyle(CardPressStyle())
                    }
                }
                .padding(.horizontal, 1)
                .padding(.vertical, 2)
            }
        }
    }
}

private struct BrowseFeaturedCard: View {
    let formula: FormulaDefinition

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.quaternary.opacity(0.48))
                    Image(systemName: formula.sfSymbol)
                        .font(.headline.weight(.semibold))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.primary.opacity(0.92))
                }
                .frame(width: 40, height: 40)
                .modifier(PremiumSymbolBadgeStyle(cornerRadius: 12))

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.subheadline.weight(.semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.tertiary.opacity(0.9))
            }

            Text(formula.displayName)
                .font(.title2.weight(.bold))
                .tracking(-0.35)
                .foregroundStyle(.primary)
                .lineLimit(2)

            Text(formula.alias)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary.opacity(0.92))
                .lineLimit(1)

            Text(formula.narrativeDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary.opacity(0.86))
                .lineLimit(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(minHeight: 222, alignment: .topLeading)
        .modifier(PremiumCardStyle(cornerRadius: 20, elevated: true))
    }
}

private struct BrowseFormulaMiniCard: View {
    let formula: FormulaDefinition

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Image(systemName: formula.sfSymbol)
                .font(.headline.weight(.semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.primary.opacity(0.92))

            Spacer(minLength: 0)

            Text(formula.displayName)
                .font(.subheadline.weight(.semibold))
                .tracking(-0.15)
                .foregroundStyle(.primary)
                .lineLimit(2)

            Text(formula.category.localizedDisplayName)
                .font(.caption)
                .foregroundStyle(.secondary.opacity(0.88))
                .lineLimit(1)
        }
        .padding(12)
        .frame(width: 176, height: 146, alignment: .leading)
        .modifier(PremiumCardStyle(cornerRadius: 16))
    }
}

private struct PremiumCardStyle: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    let cornerRadius: CGFloat
    var elevated: Bool = false

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        content
            .background {
                shape
                    .fill(
                        Color(
                            uiColor: colorScheme == .dark
                                ? (elevated ? .tertiarySystemBackground : .secondarySystemBackground)
                                : .systemBackground
                        )
                    )
            }
            .overlay {
                shape
                    .strokeBorder(
                        colorScheme == .dark ? .white.opacity(elevated ? 0.15 : 0.12) : .black.opacity(0.08),
                        lineWidth: elevated ? 0.8 : 0.7
                    )
            }
            .overlay(alignment: .top) {
                shape
                    .strokeBorder(.white.opacity(colorScheme == .dark ? 0.08 : 0.22), lineWidth: 0.5)
                    .mask(
                        LinearGradient(
                            colors: [.white, .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .shadow(
                color: .black.opacity(colorScheme == .dark ? 0.14 : 0.04),
                radius: 1,
                x: 0,
                y: 1
            )
    }
}

private struct PremiumSymbolBadgeStyle: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        content
            .overlay {
                shape
                    .strokeBorder(colorScheme == .dark ? .white.opacity(0.10) : .black.opacity(0.10), lineWidth: 0.6)
            }
            .overlay(alignment: .top) {
                shape
                    .strokeBorder(.white.opacity(colorScheme == .dark ? 0.08 : 0.24), lineWidth: 0.5)
                    .mask(
                        LinearGradient(
                            colors: [.white, .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
    }
}
