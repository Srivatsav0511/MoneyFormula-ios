import SwiftUI

enum Tab: String, CaseIterable, Identifiable {
    case home = "Home"
    case history = "History"
    case search = "Browse"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .home: "house.fill"
        case .history: "clock.arrow.circlepath"
        case .search: "magnifyingglass"
        }
    }

    var color: Color {
        switch self {
        case .home: .blue
        case .history: .mint
        case .search: .indigo
        }
    }
}

struct PremiumTabBar: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @Binding var selected: Tab
    @State private var bouncing: Tab?

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            ZStack {
                Capsule()
                    .fill(Color.clear)
                    .glassEffect(in: Capsule())
                Capsule()
                    .fill(selected.color.opacity(0.06))
                    .animation(.easeInOut(duration: 0.3), value: selected)

                VStack {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.16), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 24)
                    Spacer()
                }

                Capsule()
                    .strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.22), .white.opacity(0.06)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: .black.opacity(0.38), radius: 20, y: 8)
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }

    private func tabButton(for tab: Tab) -> some View {
        Button {
            guard selected != tab else { return }
            HapticManager.impact(.soft)
            bouncing = tab
            withAnimation(.spring(response: 0.30, dampingFraction: 0.62)) {
                selected = tab
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
                bouncing = nil
            }
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    if selected == tab {
                        Capsule()
                            .fill(tab.color.opacity(0.18))
                            .overlay(
                                Capsule()
                                    .strokeBorder(tab.color.opacity(0.30), lineWidth: 0.5)
                            )
                            .frame(width: 46, height: 28)
                            .transition(.scale.combined(with: .opacity))
                    }

                    Image(systemName: tab.icon)
                        .font(.system(size: 18, weight: selected == tab ? .semibold : .regular))
                        .foregroundStyle(selected == tab ? tab.color : .secondary)
                        .scaleEffect(bouncing == tab && !reduceMotion ? 1.22 : 1.0)
                        .animation(.spring(response: 0.22, dampingFraction: 0.48), value: bouncing)
                }
                .frame(height: 28)

                Text(tab.rawValue)
                    .font(.system(size: 10, weight: selected == tab ? .semibold : .regular))
                    .foregroundStyle(selected == tab ? tab.color : .secondary)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
