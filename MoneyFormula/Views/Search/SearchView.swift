import SwiftUI

struct SearchView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var query = ""
    @FocusState private var isSearchFocused: Bool

    private let gridSpacing: CGFloat = 12
    private let horizontalPadding: CGFloat = 16
    private var columns: [GridItem] {
        if dynamicTypeSize.isAccessibilitySize {
            [GridItem(.flexible(), spacing: gridSpacing)]
        } else {
            [
                GridItem(.flexible(), spacing: gridSpacing),
                GridItem(.flexible(), spacing: gridSpacing)
            ]
        }
    }

    private var all: [FormulaDefinition] {
        AllFormulas.marketSorted(AllFormulas.all)
    }

    private var normalizedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private var searchResults: [FormulaDefinition] {
        guard !normalizedQuery.isEmpty else { return [] }
        return all.filter { formula in
            [formula.displayName, formula.alias, formula.category.localizedDisplayName, formula.cardExpression]
                .joined(separator: " ")
                .lowercased()
                .contains(normalizedQuery)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()

                topAmbientGlow
                    .ignoresSafeArea(edges: .top)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        searchHeader

                        if normalizedQuery.isEmpty {
                            categorySection
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        } else {
                            resultsSection
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, 8)
                    .padding(.bottom, 128)
                    .mmAdaptiveReadableWidth(980)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .scrollDismissesKeyboard(.interactively)
        }
    }

    private var searchHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Browse")
                    .font(.system(size: 33, weight: .bold, design: .rounded))
                    .tracking(-0.6)
                Text("Search formulas and browse categories")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary.opacity(0.86))
            }

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(.secondary)

                TextField("Search formulas", text: $query)
                    .focused($isSearchFocused)
                    .submitLabel(.search)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .onSubmit {
                        isSearchFocused = false
                    }

                if !query.isEmpty {
                    Button {
                        query = ""
                        HapticManager.play(.selection)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear search")
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 56)
            .background {
                let shape = RoundedRectangle(cornerRadius: 18, style: .continuous)
                shape
                    .fill(Color.clear)
                    .glassEffect(in: shape)
                    .overlay {
                        shape.fill(.ultraThinMaterial.opacity(colorScheme == .dark ? 0.40 : 0.52))
                    }
                    .overlay {
                        shape.strokeBorder(.white.opacity(colorScheme == .dark ? 0.22 : 0.50), lineWidth: 0.85)
                    }
            }
            .shadow(color: .black.opacity(colorScheme == .dark ? 0.34 : 0.06), radius: 18, x: 0, y: 8)
        }
    }

    private var topAmbientGlow: some View {
        LinearGradient(
            colors: [
                MMPalette.toneBlue.opacity(colorScheme == .dark ? 0.17 : 0.12),
                MMPalette.tonePurple.opacity(colorScheme == .dark ? 0.14 : 0.08),
                .clear
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .frame(height: 210)
        .blur(radius: 20)
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 13) {
            Text("CATEGORIES")
                .mmSectionEyebrowStyle()
                .padding(.leading, 2)

            LazyVGrid(columns: columns, spacing: gridSpacing) {
                ForEach(FormulaCategory.ordered) { category in
                    NavigationLink {
                        CategoryCollectionView(category: category)
                    } label: {
                        ZStack(alignment: .topLeading) {
                            HStack {
                                Spacer(minLength: 0)
                                categoryCardArtwork(category)
                            }
                            .padding(.top, 10)
                            .padding(.trailing, 10)

                            VStack(alignment: .leading, spacing: 6) {
                                Spacer(minLength: 0)

                                Text(categoryCardTitle(category))
                                    .font(.headline.weight(.bold))
                                    .tracking(-0.15)
                                    .foregroundStyle(categoryTitleColor)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.82)
                            }
                        }
                        .padding(14)
                        .frame(
                            maxWidth: .infinity,
                            minHeight: dynamicTypeSize.isAccessibilitySize ? 128 : 112,
                            alignment: .topLeading
                        )
                        .background { categoryCardBackground(category) }
                        .overlay { categoryCardBorder }
                    }
                    .buttonStyle(SearchCardPressStyle())
                    .simultaneousGesture(TapGesture().onEnded {
                        HapticManager.play(.selection)
                    })
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private func categoryCardBackground(_ category: FormulaCategory) -> some View {
        let shape = RoundedRectangle(cornerRadius: 18, style: .continuous)
        if colorScheme == .dark {
            shape
                .fill(
                    LinearGradient(
                        colors: categoryCardGradientColorsDark(category),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    shape.fill(
                        LinearGradient(
                            colors: [.white.opacity(0.14), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                }
        } else {
            shape
                .fill(
                    LinearGradient(
                        colors: categoryCardGradientColors(category),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    shape.fill(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.18),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                }
                .overlay {
                    shape.fill(
                        RadialGradient(
                            colors: [
                                .white.opacity(0.15),
                                .clear
                            ],
                            center: UnitPoint(x: 0.12, y: 0.1),
                            startRadius: 0,
                            endRadius: 110
                        )
                    )
                }
        }
    }

    private var categoryCardBorder: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .strokeBorder(
                colorScheme == .dark ? .white.opacity(0.22) : .white.opacity(0.34),
                lineWidth: 0.8
            )
    }

    private func categoryCardArtwork(_ category: FormulaCategory) -> some View {
        return ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(colorScheme == .dark ? .white.opacity(0.09) : .white.opacity(0.14))
                .frame(width: 76, height: 76)

            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(colorScheme == .dark ? .black.opacity(0.18) : .white.opacity(0.16))
                .frame(width: 62, height: 62)
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(colorScheme == .dark ? Color.white.opacity(0.14) : .white.opacity(0.32), lineWidth: 0.7)
                }

            VStack(spacing: 5) {
                Image(systemName: category.sfSymbol)
                    .font(.title3.weight(.black))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(colorScheme == .dark ? Color.white : Color.white.opacity(0.96))

                RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                    .fill(colorScheme == .dark ? Color.white.opacity(0.45) : Color.white.opacity(0.70))
                    .frame(width: 20, height: 3)
            }
        }
    }

    private var categoryTitleColor: Color {
        .white
    }

    private func categoryCardGradientColors(_ category: FormulaCategory) -> [Color] {
        switch category {
        case .portfolio:
            return [Color(red: 0.18, green: 0.48, blue: 0.90), Color(red: 0.26, green: 0.67, blue: 0.92)]
        case .sipAndMF:
            return [Color(red: 0.04, green: 0.60, blue: 0.66), Color(red: 0.12, green: 0.74, blue: 0.64)]
        case .returns:
            return [Color(red: 0.90, green: 0.50, blue: 0.24), Color(red: 0.93, green: 0.63, blue: 0.30)]
        case .taxation:
            return [Color(red: 0.86, green: 0.35, blue: 0.39), Color(red: 0.90, green: 0.47, blue: 0.34)]
        case .valuation:
            return [Color(red: 0.29, green: 0.46, blue: 0.90), Color(red: 0.35, green: 0.63, blue: 0.92)]
        case .fundamental:
            return [Color(red: 0.14, green: 0.57, blue: 0.82), Color(red: 0.18, green: 0.70, blue: 0.88)]
        case .planning:
            return [Color(red: 0.20, green: 0.64, blue: 0.55), Color(red: 0.29, green: 0.75, blue: 0.63)]
        case .risk:
            return [Color(red: 0.44, green: 0.49, blue: 0.84), Color(red: 0.55, green: 0.54, blue: 0.88)]
        case .technical:
            return [Color(red: 0.40, green: 0.48, blue: 0.88), Color(red: 0.50, green: 0.57, blue: 0.90)]
        case .bonds:
            return [Color(red: 0.20, green: 0.58, blue: 0.84), Color(red: 0.25, green: 0.71, blue: 0.86)]
        case .options:
            return [Color(red: 0.48, green: 0.43, blue: 0.88), Color(red: 0.62, green: 0.52, blue: 0.90)]
        }
    }

    private func categoryCardGradientColorsDark(_ category: FormulaCategory) -> [Color] {
        switch category {
        case .portfolio:
            return [Color(red: 0.08, green: 0.26, blue: 0.62), Color(red: 0.15, green: 0.40, blue: 0.74)]
        case .sipAndMF:
            return [Color(red: 0.04, green: 0.36, blue: 0.44), Color(red: 0.10, green: 0.50, blue: 0.44)]
        case .returns:
            return [Color(red: 0.66, green: 0.32, blue: 0.10), Color(red: 0.78, green: 0.45, blue: 0.16)]
        case .taxation:
            return [Color(red: 0.58, green: 0.18, blue: 0.20), Color(red: 0.70, green: 0.28, blue: 0.22)]
        case .valuation:
            return [Color(red: 0.13, green: 0.24, blue: 0.64), Color(red: 0.20, green: 0.39, blue: 0.76)]
        case .fundamental:
            return [Color(red: 0.08, green: 0.36, blue: 0.56), Color(red: 0.14, green: 0.48, blue: 0.70)]
        case .planning:
            return [Color(red: 0.11, green: 0.42, blue: 0.34), Color(red: 0.18, green: 0.52, blue: 0.40)]
        case .risk:
            return [Color(red: 0.28, green: 0.30, blue: 0.54), Color(red: 0.38, green: 0.38, blue: 0.66)]
        case .technical:
            return [Color(red: 0.20, green: 0.29, blue: 0.65), Color(red: 0.29, green: 0.40, blue: 0.74)]
        case .bonds:
            return [Color(red: 0.12, green: 0.36, blue: 0.56), Color(red: 0.18, green: 0.48, blue: 0.66)]
        case .options:
            return [Color(red: 0.30, green: 0.24, blue: 0.60), Color(red: 0.42, green: 0.32, blue: 0.70)]
        }
    }

    private func categoryBaseTone(_ category: FormulaCategory) -> Color {
        switch category {
        case .portfolio, .valuation:
            return MMPalette.toneBlue
        case .sipAndMF, .fundamental:
            return MMPalette.toneGreen
        case .returns, .risk:
            return MMPalette.toneOrange
        case .taxation, .planning, .technical, .bonds, .options:
            return MMPalette.tonePurple
        }
    }

    private func categoryCardTitle(_ category: FormulaCategory) -> String {
        switch category {
        case .portfolio: return "Stocks"
        case .sipAndMF: return "SIP"
        case .returns: return "Returns"
        case .taxation: return "Taxes"
        case .valuation: return "Valuation"
        case .fundamental: return "Retirement"
        case .planning: return "Planning"
        case .risk: return "Loans"
        case .technical: return "Business"
        case .bonds: return "Insurance"
        case .options: return "Crypto"
        }
    }

    @ViewBuilder
    private var resultsSection: some View {
        if searchResults.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "magnifyingglass.circle")
                    .font(.largeTitle.weight(.light))
                    .foregroundStyle(.secondary.opacity(0.5))
                Text("No formulas found for \"\(query)\"")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 18)
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text("RESULTS")
                    .mmSectionEyebrowStyle()

                ForEach(searchResults, id: \.id) { formula in
                    NavigationLink {
                        FormulaDetailView(formula: formula)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: formula.sfSymbol)
                                .font(.subheadline.weight(.semibold))
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(formula.category.color)
                                .frame(width: 30)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(formula.displayName)
                                    .font(.headline.weight(.semibold))
                                    .tracking(-0.15)
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                Text(formula.category.localizedDisplayName)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary.opacity(0.9))
                                    .lineLimit(1)
                            }

                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.tertiary)
                        }
                        .padding(14)
                        .mmCardSurface(corner: 16, tint: MMPalette.categoryAccent(formula.category).opacity(colorScheme == .dark ? 0.0 : 0.24))
                    }
                    .buttonStyle(SearchCardPressStyle())
                    .simultaneousGesture(TapGesture().onEnded {
                        HapticManager.play(.selection)
                    })
                }
            }
        }
    }
}

private struct SearchCardPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .opacity(configuration.isPressed ? 0.992 : 1)
            .brightness(configuration.isPressed ? -0.01 : 0)
            .animation(MMMotion.press, value: configuration.isPressed)
    }
}
