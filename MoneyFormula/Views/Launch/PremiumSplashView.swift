import SwiftUI

struct PremiumSplashView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme

    let subtitle: String
    @State private var animate = false

    private var titleColor: Color {
        colorScheme == .dark ? .white : Color(red: 0.08, green: 0.13, blue: 0.22)
    }

    private var subtitleColor: Color {
        colorScheme == .dark ? .white.opacity(0.86) : Color(red: 0.16, green: 0.24, blue: 0.36).opacity(0.9)
    }

    private var logoPlateTint: Color {
        colorScheme == .dark ? .white.opacity(0.02) : .white.opacity(0.10)
    }

    private var logoPlateStroke: Color {
        colorScheme == .dark ? .white.opacity(0.22) : .white.opacity(0.55)
    }

    var body: some View {
        GeometryReader { proxy in
            let logoSize = min(max(proxy.size.width * 0.24, 92), 126)
            let titleSize = min(max(proxy.size.width * 0.086, 27), 36)

            ZStack {
                PremiumBackground(primaryColor: MMPalette.toneBlue, secondaryColor: MMPalette.appTint)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: logoSize * 0.28, style: .continuous)
                            .fill(.ultraThinMaterial)
                        RoundedRectangle(cornerRadius: logoSize * 0.28, style: .continuous)
                            .fill(logoPlateTint)
                        RoundedRectangle(cornerRadius: logoSize * 0.28, style: .continuous)
                            .strokeBorder(logoPlateStroke, lineWidth: 0.7)

                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: logoSize * 0.86, height: logoSize * 0.86)
                            .clipShape(RoundedRectangle(cornerRadius: logoSize * 0.22, style: .continuous))
                    }
                    .frame(width: logoSize, height: logoSize)
                    .shadow(color: .black.opacity(colorScheme == .dark ? 0.34 : 0.18), radius: 18, y: 10)
                    .scaleEffect(animate ? 1.0 : 0.97)
                    .opacity(animate ? 1.0 : 0.0)
                    .animation(
                        reduceMotion ? .linear(duration: 0.01) : .spring(response: 0.55, dampingFraction: 0.9).delay(0.04),
                        value: animate
                    )

                    Text("MoneyFormula")
                        .font(.system(size: titleSize, weight: .bold, design: .rounded))
                        .foregroundStyle(titleColor)
                        .opacity(animate ? 1.0 : 0.0)
                        .offset(y: animate ? 0 : 8)
                        .animation(
                            reduceMotion ? .linear(duration: 0.01) : .easeOut(duration: 0.42).delay(0.10),
                            value: animate
                        )

                    Text(subtitle)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(subtitleColor)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .opacity(animate ? 1.0 : 0.0)
                        .offset(y: animate ? 0 : 8)
                        .animation(
                            reduceMotion ? .linear(duration: 0.01) : .easeOut(duration: 0.4).delay(0.16),
                            value: animate
                        )
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: min(proxy.size.width - 40, 460))
            }
            .onAppear {
                animate = true
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("MoneyFormula. \(subtitle)"))
    }
}

#Preview {
    PremiumSplashView(subtitle: "Smarter Math for Real Markets")
}
