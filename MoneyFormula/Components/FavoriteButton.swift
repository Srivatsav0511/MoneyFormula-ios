import SwiftUI

struct FavoriteButton: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @Binding var isFavorite: Bool
    let action: (Bool) -> Void

    @State private var particles: [ParticleData] = []
    @State private var heartBounce = false

    struct ParticleData: Identifiable {
        let id = UUID()
        var opacity: Double = 1
        var offset: CGSize = .zero
    }

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Image(systemName: "heart.fill")
                    .font(.system(size: 7))
                    .foregroundStyle(MMPalette.tonePink)
                    .opacity(particle.opacity)
                    .offset(particle.offset)
            }

            Button {
                toggle()
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(isFavorite ? MMPalette.tonePink : .secondary)
                        .scaleEffect(heartBounce ? 1.3 : 1)

                    if isFavorite {
                        Text("Saved")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(MMPalette.tonePink)
                            .transition(.opacity.combined(with: .scale))
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .frame(minWidth: 44, minHeight: 44)
            }
            .mmNativeGlassButton(tint: isFavorite ? MMPalette.tonePink : .secondary.opacity(0.75))
            .accessibilityLabel("Favorite")
            .accessibilityValue(isFavorite ? "Saved" : "Not saved")
            .accessibilityHint("Toggles favorite state")
        }
    }

    private func toggle() {
        HapticManager.impact(.medium)
        withAnimation(reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.7)) {
            isFavorite.toggle()
            heartBounce = true
        }
        withAnimation(reduceMotion ? .none : .spring(response: 0.2, dampingFraction: 0.7).delay(0.08)) {
            heartBounce = false
        }
        action(isFavorite)

        if isFavorite && !reduceMotion {
            burst()
        }
    }

    private func burst() {
        particles = []
        for _ in 0..<6 {
            let angle = Double.random(in: 0...360) * .pi / 180
            let distance = CGFloat.random(in: 20...36)
            var particle = ParticleData()
            particles.append(particle)
            withAnimation(.easeOut(duration: 0.45)) {
                if let index = particles.indices.last {
                    particle.opacity = 0
                    particle.offset = CGSize(width: cos(angle) * distance, height: sin(angle) * distance)
                    particles[index] = particle
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            particles = []
        }
    }
}
