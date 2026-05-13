import SwiftUI

struct LiquidGlassCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme

    let categoryColor: Color
    var cornerRadius: CGFloat = 20
    var contentPadding: CGFloat = 16
    let isPressed: Bool
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(contentPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .mmCardSurface(corner: cornerRadius, tint: categoryColor)
            .mmNativeGlassContainer()
            .brightness(isPressed ? -0.03 : 0)
            .scaleEffect(isPressed ? 0.97 : 1)
            .shadow(color: categoryColor.opacity(colorScheme == .dark ? 0.16 : 0.08), radius: 8, y: 4)
            .animation(.spring(response: 0.26, dampingFraction: 0.74), value: isPressed)
    }
}
