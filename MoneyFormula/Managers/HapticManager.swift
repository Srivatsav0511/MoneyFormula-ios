import UIKit

enum HapticManager {
    enum Semantic {
        case tap
        case success
        case warning
        case error
        case selection
        case copy
        case favorite
    }

    private static var lastFireTime: TimeInterval = 0
    private static let minimumInterval: TimeInterval = 0.045

    private static let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private static let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private static let softImpact = UIImpactFeedbackGenerator(style: .soft)
    private static let notification = UINotificationFeedbackGenerator()

    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard isEnabled, canFireNow() else { return }
        let generator = impactGenerator(for: style)
        generator.prepare()
        generator.impactOccurred()
        lastFireTime = CACurrentMediaTime()
    }

    static func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isEnabled, canFireNow() else { return }
        notification.prepare()
        notification.notificationOccurred(type)
        lastFireTime = CACurrentMediaTime()
    }

    static func play(_ semantic: Semantic) {
        guard isEnabled else { return }
        switch semantic {
        case .tap:
            impact(.light)
        case .success:
            notify(.success)
        case .warning:
            notify(.warning)
        case .error:
            notify(.error)
        case .selection:
            impact(.soft)
        case .copy:
            impact(.light)
        case .favorite:
            impact(.medium)
        }
    }

    private static var isEnabled: Bool {
        if UserDefaults.standard.object(forKey: "settings.haptics") == nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: "settings.haptics")
    }

    private static func canFireNow() -> Bool {
        CACurrentMediaTime() - lastFireTime >= minimumInterval
    }

    private static func impactGenerator(for style: UIImpactFeedbackGenerator.FeedbackStyle) -> UIImpactFeedbackGenerator {
        switch style {
        case .light:
            return lightImpact
        case .medium, .heavy, .rigid:
            return mediumImpact
        case .soft:
            return softImpact
        @unknown default:
            return lightImpact
        }
    }
}
