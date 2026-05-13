import SwiftUI

struct CategoryCollectionView: View {
    let category: FormulaCategory

    init(category: FormulaCategory) {
        self.category = category
    }

    private var formulas: [FormulaDefinition] {
        AllFormulas.marketSorted(
            AllFormulas.all.filter { $0.category == category }
        )
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                Text("CATEGORY")
                    .mmSectionEyebrowStyle()

                Text(category.localizedDisplayName.replacingOccurrences(of: "&", with: ""))
                    .font(.largeTitle.weight(.bold))
                    .tracking(-0.45)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)

                ForEach(formulas, id: \.id) { formula in
                    NavigationLink {
                        FormulaDetailView(formula: formula)
                    } label: {
                        FormulaListCell(formula: formula)
                    }
                    .buttonStyle(.plain)
                }
            }
            .mmScreenPadding(top: 10, bottom: 112)
        }
        .background(Color.clear)
        .navigationTitle("Browse")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaPadding(.top, 2)
    }
}

private struct FormulaListCell: View {
    @Environment(\.colorScheme) private var colorScheme
    let formula: FormulaDefinition

    private var traitA: String {
        formula.category.localizedDisplayName.components(separatedBy: "&").first?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() ?? "CORE"
    }

    private var traitB: String {
        formula.alias.uppercased()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color(.tertiarySystemFill))
                    Image(systemName: formula.sfSymbol)
                        .font(.system(size: 14, weight: .semibold))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.primary)
                }
                .frame(width: 32, height: 32)

                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.tertiary)
                    .padding(.top, 2)
            }

            Text(formula.displayName)
                .font(.title.weight(.bold))
                .tracking(-0.25)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.65)

            Text(formula.narrativeDescription)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Text(traitA)
                Spacer()
                Text(traitB)
            }
            .font(.system(size: 11, weight: .bold, design: .monospaced))
            .tracking(0.8)
            .foregroundStyle(.secondary.opacity(0.9))
            .padding(.top, 4)
        }
        .padding(14)
        .mmCardSurface(corner: 18, tint: MMPalette.categoryAccent(formula.category).opacity(colorScheme == .dark ? 0.14 : 0.22))
    }
}
