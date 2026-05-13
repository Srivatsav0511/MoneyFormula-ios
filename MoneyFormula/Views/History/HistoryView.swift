import SwiftData
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

private enum HistoryFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case today = "Today"
    case week = "This Week"
    case positive = "Positive"
    case negative = "Negative"

    var id: String { rawValue }
}

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query(sort: \CalculationHistory.timestamp, order: .reverse) private var allHistory: [CalculationHistory]
    @AppStorage("settings.currency") private var selectedCurrencyCode: String = "INR"

    @State private var filter: HistoryFilter = .all

    private var filteredHistory: [CalculationHistory] {
        let calendar = Calendar.current
        return allHistory.filter { item in
            switch filter {
            case .all:
                return true
            case .today:
                return calendar.isDateInToday(item.timestamp)
            case .week:
                return calendar.isDate(item.timestamp, equalTo: Date(), toGranularity: .weekOfYear)
            case .positive:
                return item.resultIsPositive
            case .negative:
                return !item.resultIsPositive
            }
        }
    }

    private var positiveCount: Int {
        allHistory.filter(\.resultIsPositive).count
    }

    private var sections: [(title: String, items: [CalculationHistory])] {
        let grouped = Dictionary(grouping: filteredHistory) { item in
            sectionTitle(for: item.timestamp)
        }
        let order: [String: Int] = ["Today": 0, "Yesterday": 1, "This Week": 2, "Earlier": 3]
        return grouped
            .map { (title: $0.key, items: $0.value) }
            .sorted { (order[$0.title] ?? 99) < (order[$1.title] ?? 99) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("History")
                            .font(.largeTitle.weight(.bold))
                            .tracking(-0.4)
                            .foregroundStyle(.primary)
                        summaryHeader
                        filterChips

                        if filteredHistory.isEmpty {
                            EmptyStateView(
                                systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90",
                                title: "No history yet",
                                subtitle: "Calculated formulas will show up here for quick revisit."
                            )
                            .padding(.top, 18)
                        } else {
                            ForEach(sections, id: \.title) { section in
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(section.title.uppercased())
                                        .mmSectionEyebrowStyle()

                                    ForEach(section.items, id: \.id) { item in
                                        historyCard(for: item)
                                    }
                                }
                            }
                        }

                    }
                    .mmScreenPadding(top: 10, bottom: 112)
                }
            }
            .safeAreaPadding(.top, 2)
            .navigationBarHidden(true)
        }
    }

    private var summaryHeader: some View {
        HStack(spacing: 12) {
            metricCard(
                title: "Total",
                value: "\(allHistory.count)",
                subtitle: "calculations"
            )

            metricCard(
                title: "Positive",
                value: "\(positiveCount)",
                subtitle: "results"
            )
        }
    }

    private func metricCard(title: String, value: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .mmSectionEyebrowStyle()

            Text(value)
                .font(MMType.secondaryValue)
                .tracking(-0.2)
                .foregroundStyle(.primary.opacity(0.96))

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary.opacity(0.88))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .mmCardSurface(corner: 16, tint: .clear)
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(HistoryFilter.allCases) { item in
                    let selected = filter == item
                    Button {
                        HapticManager.play(.selection)
                        withAnimation(MMMotion.selection) {
                            filter = item
                        }
                    } label: {
                        Text(item.rawValue)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(selected ? AnyShapeStyle(.primary) : AnyShapeStyle(.secondary.opacity(0.9)))
                            .padding(.horizontal, 14)
                            .frame(minHeight: MMGrid.controlHeight)
                            .mmChipSurface(selected: selected, accent: MMPalette.appTint)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 1)
        }
    }

    private func historyCard(for item: CalculationHistory) -> some View {
        let category = FormulaCategory(rawValue: item.category) ?? .portfolio
        return NavigationLink {
            if let formula = AllFormulas.all.first(where: { $0.id == item.formulaID }) {
                FormulaDetailView(formula: formula)
            }
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.formulaName)
                            .font(.headline.weight(.bold))
                            .tracking(-0.15)
                            .foregroundStyle(.primary)
                            .lineLimit(2)

                        Text(category.localizedDisplayName)
                            .font(.caption)
                            .foregroundStyle(.secondary.opacity(0.9))
                    }

                    Spacer()

                    Text(relativeDate(item.timestamp))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                HStack(alignment: .lastTextBaseline) {
                    Text(item.resultPrimary)
                        .font(MMType.secondaryValue)
                        .tracking(-0.25)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)

                    Text(localizedCurrencyUnit(item.resultUnit))
                        .font(.caption)
                        .foregroundStyle(.secondary.opacity(0.85))

                    Spacer()

                    Image(systemName: item.resultIsPositive ? "arrow.up.right" : "arrow.down.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(item.resultIsPositive ? .green : .red)
                }

                if !item.interpretation.isEmpty {
                    Text(item.interpretation)
                        .font(.subheadline)
                        .foregroundStyle(.secondary.opacity(0.86))
                        .lineLimit(2)
                }
            }
            .padding(14)
            .mmCardSurface(corner: 18, tint: .clear)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture().onEnded {
            HapticManager.play(.selection)
        })
        .contextMenu {
            Button("Copy Result") {
                HapticManager.play(.copy)
#if canImport(UIKit)
                UIPasteboard.general.string = "\(item.formulaName): \(item.resultPrimary) \(localizedCurrencyUnit(item.resultUnit))"
#endif
            }
            Button("Delete", role: .destructive) {
                HapticManager.play(.warning)
                modelContext.delete(item)
            }
        }
    }

    private func sectionTitle(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        if calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) { return "This Week" }
        return "Earlier"
    }

    private func relativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    private func localizedCurrencyUnit(_ rawUnit: String) -> String {
        let symbol = currencySymbol(for: selectedCurrencyCode)
        return rawUnit
            .replacingOccurrences(of: "₹", with: symbol)
            .replacingOccurrences(of: "$", with: symbol)
            .replacingOccurrences(of: "€", with: symbol)
            .replacingOccurrences(of: "£", with: symbol)
            .replacingOccurrences(of: "¥", with: symbol)
    }

    private func currencySymbol(for code: String) -> String {
        switch code.uppercased() {
        case "USD": return "$"
        case "EUR": return "€"
        case "GBP": return "£"
        case "JPY": return "¥"
        default: return "₹"
        }
    }
}
