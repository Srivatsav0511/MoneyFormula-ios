import SwiftUI

enum FormulaCardLayout {
    case list
    case square
}

struct FormulaCard: View {
    @Environment(\.colorScheme) private var colorScheme

    let formula: FormulaDefinition
    var isAutoFillReady: Bool = false
    var layout: FormulaCardLayout = .list

    var body: some View {
        let narrative = FormulaKnowledge.narrative(for: formula.id, fallbackExpression: "")
        Group {
            if layout == .square {
                squareBody(narrative: narrative)
            } else {
                listBody(narrative: narrative)
            }
        }
    }

    @ViewBuilder
    private func listBody(narrative: FormulaNarrative) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.clear)
                .glassEffect(in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: formula.sfSymbol)
                        .font(.system(size: 18, weight: .semibold))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.primary)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color(.separator), lineWidth: 0.9)
                )

            VStack(alignment: .leading, spacing: 5) {
                Text(FormulaDisplayText.name(for: formula.id))
                    .font(.headline.weight(.semibold))
                    .tracking(-0.15)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.84)

                Text(FormulaDisplayText.shortName(for: formula.id))
                    .font(.caption)
                    .foregroundStyle(.secondary.opacity(0.95))
                    .lineLimit(1)

                Text(narrative.cardExpression)
                    .font(.caption)
                    .foregroundStyle(.secondary.opacity(0.88))
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(MMGrid.x16)
        .frame(minHeight: 98)
        .cardContainer(tint: .clear)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(FormulaDisplayText.name(for: formula.id))
        .accessibilityHint(narrative.fullExpression)
    }

    @ViewBuilder
    private func squareBody(narrative: FormulaNarrative) -> some View {
        VStack(alignment: .leading, spacing: MMGrid.x8) {
            HStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.systemBackground).opacity(colorScheme == .dark ? 0.32 : 0.82))
                    .glassEffect(in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: formula.sfSymbol)
                        .font(.system(size: 17, weight: .semibold))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.96) : .primary)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(
                                colorScheme == .dark ? .white.opacity(0.16) : .black.opacity(0.10),
                                lineWidth: 0.8
                            )
                    )

                Spacer(minLength: 10)

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.tertiary)
                    .frame(width: 24, height: 24)
            }

            Text(formula.category.displayName.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.84) : .primary.opacity(0.76))
                .lineLimit(1)

            Text(FormulaDisplayText.name(for: formula.id))
                .font(.headline.weight(.bold))
                .tracking(-0.15)
                .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.98) : .primary)
                .lineLimit(3)
                .minimumScaleFactor(0.82)

            Text(FormulaDisplayText.shortName(for: formula.id))
                .font(.caption)
                .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.82) : .secondary)
                .lineLimit(1)

            Text(narrative.fullExpression)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(5)
                .minimumScaleFactor(0.82)

            Spacer(minLength: 0)
        }
        .padding(MMGrid.x16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .mmCardSurface(corner: MMGrid.cardRadius, tint: .clear)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(FormulaDisplayText.name(for: formula.id))
        .accessibilityHint(narrative.fullExpression)
    }
}

private extension View {
    @ViewBuilder
    func cardContainer(tint: Color = .clear) -> some View {
        self.mmCardSurface(corner: MMGrid.cardRadius, tint: tint)
    }
}
