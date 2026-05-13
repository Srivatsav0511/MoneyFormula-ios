import SwiftUI

enum MMPalette {
    static let appTint: Color = Color(uiColor: .systemBlue)
    static let positive: Color = Color(uiColor: .systemGreen)
    static let negative: Color = Color(uiColor: .systemRed)
    static let warning: Color = Color(uiColor: .systemOrange)
    static let neutral: Color = .secondary
    static let toneBlue: Color = Color(uiColor: .systemBlue)
    static let toneGreen: Color = Color(uiColor: .systemGreen)
    static let toneOrange: Color = Color(uiColor: .systemOrange)
    static let tonePurple: Color = Color(uiColor: .systemPurple)
    static let tonePink: Color = Color(uiColor: .systemPink)
    static let toneIndigo: Color = Color(uiColor: .systemIndigo)
    static let toneMint: Color = Color(uiColor: .systemMint)
    static let toneTeal: Color = Color(uiColor: .systemTeal)
    static let toneBrown: Color = Color(uiColor: .systemBrown)

    static let baseBackground: Color = Color(.systemBackground)
    static let elevatedBackground: Color = Color(.secondarySystemBackground)
    static let border: Color = Color(.separator)

    static func categoryAccent(_ category: FormulaCategory) -> Color {
        switch category {
        case .portfolio: Color(uiColor: .systemBlue)
        case .sipAndMF: Color(uiColor: .systemTeal)
        case .returns: Color(uiColor: .systemOrange)
        case .taxation: Color(uiColor: .systemRed)
        case .valuation: Color(uiColor: .systemBlue)
        case .fundamental: Color(uiColor: .systemCyan)
        case .planning: Color(uiColor: .systemTeal)
        case .risk: Color(uiColor: .systemGray)
        case .technical: Color(uiColor: .systemMint)
        case .bonds: Color(uiColor: .systemGray)
        case .options: Color(uiColor: .systemCyan)
        }
    }
}

enum MMGrid {
    static let x8: CGFloat = 8
    static let x12: CGFloat = 12
    static let x16: CGFloat = 16
    static let x20: CGFloat = 20
    static let x24: CGFloat = 24
    static let x32: CGFloat = 32

    static let horizontalPadding: CGFloat = x20
    static let sectionGap: CGFloat = x32
    static let cardGap: CGFloat = x16
    static let cardRadius: CGFloat = 20
    static let largeCardRadius: CGFloat = 20
    static let controlHeight: CGFloat = 44
    static let textFieldHeight: CGFloat = 52
}

enum MMType {
    static let screenTitle = Font.largeTitle.weight(.bold)
    static let sectionTitle = Font.title2.weight(.semibold)
    static let cardTitle = Font.headline.weight(.semibold)
    static let cardSubtitle = Font.subheadline
    static let body = Font.body
    static let monoMeta = Font.system(size: 11, weight: .medium, design: .monospaced)
    static let sectionEyebrow = Font.system(size: 10, weight: .bold, design: .monospaced)
    static let primaryValue = Font.system(size: 30, weight: .bold, design: .rounded)
    static let secondaryValue = Font.system(size: 22, weight: .semibold, design: .rounded)
}

enum MMMotion {
    static let press = Animation.easeOut(duration: 0.18)
    static let selection = Animation.snappy(duration: 0.30, extraBounce: 0.08)
    static let navigation = Animation.smooth(duration: 0.36)
    static let content = Animation.smooth(duration: 0.40)
    static let ambient = Animation.easeInOut(duration: 2.2)
    static let fadeSlide = AnyTransition.move(edge: .bottom).combined(with: .opacity)
}

extension View {
    func mmCardSurface(corner: CGFloat = MMGrid.cardRadius, tint: Color = .clear) -> some View {
        self.modifier(MMCardSurfaceModifier(corner: corner, tint: tint))
    }

    func mmSectionEyebrowStyle() -> some View {
        self
            .font(MMType.sectionEyebrow)
            .tracking(1.2)
            .foregroundStyle(.tertiary)
    }

    func mmPrimaryValueStyle() -> some View {
        self
            .font(MMType.primaryValue)
            .tracking(-0.4)
            .foregroundStyle(.primary)
    }

    func mmChipSurface(selected: Bool, accent: Color = MMPalette.appTint) -> some View {
        self.modifier(MMChipSurfaceModifier(selected: selected, accent: accent))
    }

    func mmSoftPressScale(_ pressed: Bool) -> some View {
        self
            .scaleEffect(pressed ? 0.985 : 1)
            .opacity(pressed ? 0.992 : 1)
            .brightness(pressed ? -0.01 : 0)
            .animation(MMMotion.press, value: pressed)
    }

    func mmAdaptiveReadableWidth(_ maxWidth: CGFloat = 980) -> some View {
        self
            .frame(maxWidth: maxWidth)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    func mmScreenPadding(top: CGFloat = MMGrid.x12, bottom: CGFloat = 110) -> some View {
        self
            .padding(.horizontal, MMGrid.horizontalPadding)
            .padding(.top, top)
            .padding(.bottom, bottom)
            .mmAdaptiveReadableWidth(920)
    }

    @ViewBuilder
    func mmNativeGlass(corner: CGFloat) -> some View {
        let shape = RoundedRectangle(cornerRadius: corner, style: .continuous)
        self.glassEffect(in: shape)
    }

    @ViewBuilder
    func mmNativeGlassContainer() -> some View {
        GlassEffectContainer { self }
    }

    func mmNativeGlassButton(tint: Color? = nil) -> some View {
        self
            .buttonStyle(.glass)
            .ifLet(tint) { view, tint in
                view.tint(tint)
            }
    }

    func mmNativeProminentGlassButton(tint: Color? = nil) -> some View {
        self
            .buttonStyle(.glassProminent)
            .ifLet(tint) { view, tint in
                view.tint(tint)
            }
    }

    func mmNativeSectionSurface(corner: CGFloat = MMGrid.cardRadius, tint: Color = .clear) -> some View {
        self
            .padding(.horizontal, MMGrid.x16)
            .padding(.vertical, MMGrid.x12)
            .mmCardSurface(corner: corner, tint: tint)
            .mmNativeGlassContainer()
    }

    func mmNativePopupSheet() -> some View {
        self
            .presentationBackground(.ultraThinMaterial)
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(28)
    }

    func mmAppBackground() -> some View {
        background(Color(uiColor: .systemBackground).ignoresSafeArea())
    }

    @ViewBuilder
    func mmTransitionSource<ID: Hashable>(_ id: ID, in namespace: Namespace.ID, reduceMotion: Bool) -> some View {
        if reduceMotion {
            self
        } else if #available(iOS 18.0, *) {
            self.matchedTransitionSource(id: id, in: namespace)
        } else {
            self
        }
    }

    @ViewBuilder
    func mmZoomNavigationTransition<ID: Hashable>(_ id: ID, in namespace: Namespace.ID, reduceMotion: Bool) -> some View {
        if reduceMotion {
            self
        } else if #available(iOS 18.0, *) {
            self.navigationTransition(.zoom(sourceID: id, in: namespace))
        } else {
            self
        }
    }
}

private struct MMCardSurfaceModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    let corner: CGFloat
    let tint: Color

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: corner, style: .continuous)
        content
            .background {
                shape
                    .fill(
                        Color(
                            uiColor: colorScheme == .dark
                                ? .secondarySystemBackground
                                : .systemBackground
                        )
                    )
            }
            .overlay {
                shape
                    .fill(tint.opacity(colorScheme == .dark ? 0.10 : 0.05))
            }
            .overlay {
                shape
                    .strokeBorder(
                        colorScheme == .dark ? .white.opacity(0.13) : .black.opacity(0.07),
                        lineWidth: 0.75
                    )
            }
            .overlay(alignment: .top) {
                shape
                    .strokeBorder(.white.opacity(colorScheme == .dark ? 0.06 : 0.20), lineWidth: 0.5)
                    .mask(
                        LinearGradient(
                            colors: [.white, .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .shadow(
                color: .black.opacity(colorScheme == .dark ? 0.20 : 0.0),
                radius: colorScheme == .dark ? 8 : 0,
                x: 0,
                y: colorScheme == .dark ? 4 : 0
            )
    }
}

private struct MMChipSurfaceModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    let selected: Bool
    let accent: Color

    func body(content: Content) -> some View {
        let shape = Capsule(style: .continuous)
        content
            .background {
                shape
                    .fill(Color(uiColor: colorScheme == .dark ? .secondarySystemBackground : .systemBackground))
            }
            .overlay {
                shape
                    .fill(.ultraThinMaterial)
                    .opacity(colorScheme == .dark ? 0.10 : 0.22)
            }
            .overlay {
                if selected {
                    shape.fill(accent.opacity(colorScheme == .dark ? 0.28 : 0.16))
                }
            }
            .overlay {
                shape
                    .strokeBorder(
                        selected
                            ? accent.opacity(colorScheme == .dark ? 0.46 : 0.30)
                            : (colorScheme == .dark ? .white.opacity(0.14) : .black.opacity(0.12)),
                        lineWidth: selected ? 0.9 : 0.7
                    )
            }
    }
}

private extension View {
    @ViewBuilder
    func ifLet<T, Content: View>(_ value: T?, @ViewBuilder transform: (Self, T) -> Content) -> some View {
        if let value {
            transform(self, value)
        } else {
            self
        }
    }
}
