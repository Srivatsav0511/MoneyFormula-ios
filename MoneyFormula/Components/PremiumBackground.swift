import SwiftUI

struct PremiumGlassBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var primaryColor: Color = MMPalette.toneBlue
    var secondaryColor: Color = MMPalette.appTint

    private var baseColor: Color {
        colorScheme == .dark ? Color(.systemGroupedBackground) : Color(.systemBackground)
    }

    private var primaryOrbOpacity: Double {
        colorScheme == .dark ? 0.10 : 0.035
    }

    private var secondaryOrbOpacity: Double {
        colorScheme == .dark ? 0.07 : 0.025
    }

    private var grainScale: Double {
        colorScheme == .dark ? 0.7 : 0.3
    }

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width

            ZStack {
                baseColor

                LinearGradient(
                    colors: [
                        .clear,
                        .black.opacity(colorScheme == .dark ? 0.10 : 0.07)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                Rectangle()
                    .fill(.ultraThinMaterial)
                    .opacity(colorScheme == .dark ? 0.18 : 0.22)

                RadialGradient(
                    colors: [
                        primaryColor.opacity(primaryOrbOpacity),
                        primaryColor.opacity(colorScheme == .dark ? 0.05 : 0.02),
                        .clear
                    ],
                    center: UnitPoint(x: 0.3, y: 0.1),
                    startRadius: 0,
                    endRadius: width * 0.8
                )
                .blendMode(.screen)

                RadialGradient(
                    colors: [
                        secondaryColor.opacity(secondaryOrbOpacity),
                        .clear
                    ],
                    center: UnitPoint(x: 0.8, y: 0.9),
                    startRadius: 0,
                    endRadius: width * 0.6
                )
                .blendMode(.screen)

                RadialGradient(
                    colors: [
                        .white.opacity(colorScheme == .dark ? 0.05 : 0.02),
                        .clear
                    ],
                    center: UnitPoint(x: 0.15, y: 0.85),
                    startRadius: 0,
                    endRadius: width * 0.55
                )
                .blendMode(.screen)

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .white.opacity(colorScheme == .dark ? 0.03 : 0.06),
                                .clear,
                                .white.opacity(colorScheme == .dark ? 0.01 : 0.03)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .opacity(grainScale)
            }
            .ignoresSafeArea()
        }
    }
}

struct PremiumBackground: View {
    var primaryColor: Color = MMPalette.toneBlue
    var secondaryColor: Color = MMPalette.appTint

    var body: some View {
        PremiumGlassBackground(primaryColor: primaryColor, secondaryColor: secondaryColor)
    }
}
