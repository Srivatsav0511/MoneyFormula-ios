import SwiftUI

struct CardPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        PressableCard(configuration: configuration)
    }
}

private struct PressableCard: View {
    let configuration: ButtonStyle.Configuration
    @State private var hasTriggeredPressHaptic = false

    var body: some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.985 : 1.0)
            .opacity(configuration.isPressed ? 0.992 : 1.0)
            .brightness(configuration.isPressed ? -0.01 : 0)
            .shadow(
                color: .black.opacity(configuration.isPressed ? 0.05 : 0.0),
                radius: configuration.isPressed ? 4 : 0,
                x: 0,
                y: configuration.isPressed ? 2 : 0
            )
            .animation(.easeOut(duration: 0.18), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    if !hasTriggeredPressHaptic {
                        HapticManager.impact(.light)
                        hasTriggeredPressHaptic = true
                    }
                } else {
                    hasTriggeredPressHaptic = false
                }
            }
    }
}
