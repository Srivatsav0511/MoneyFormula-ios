import SwiftUI

struct EmptyStateView: View {
    let systemImage: String
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    var ctaTitle: LocalizedStringKey?
    var ctaAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.clear)
                    .glassEffect(in: Circle())
                    .frame(width: 88, height: 88)
                    .overlay(
                        Circle()
                            .strokeBorder(Color(.separator), lineWidth: 0.9)
                    )
                Image(systemName: systemImage)
                    .font(.system(size: 34, weight: .regular))
                    .foregroundStyle(MMPalette.appTint)
            }

            Text(title)
                .font(.title3.weight(.semibold))
            Text(subtitle)
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if let ctaTitle, let ctaAction {
                Button {
                    HapticManager.play(.tap)
                    ctaAction()
                } label: {
                    Text(ctaTitle)
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 16)
                        .frame(minHeight: 44)
                }
                .mmNativeGlassButton(tint: MMPalette.appTint.opacity(0.72))
                .padding(.top, 4)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .mmCardSurface(corner: 20, tint: MMPalette.appTint.opacity(0.3))
        .accessibilityElement(children: .contain)
    }
}
