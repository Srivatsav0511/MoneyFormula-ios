import Foundation
import Observation
import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

@MainActor
@Observable
final class AdManager {
    static let admobAppID = "ca-app-pub-5519379714521588~4827272142"
    private static let releaseInterstitialFallbackID = "ca-app-pub-5519379714521588/2712258007"
    static let interstitialAdUnitID: String = {
        #if DEBUG
        // Google test interstitial ad unit (safe for development).
        "ca-app-pub-3940256099942544/4411468910"
        #else
        (Bundle.main.object(forInfoDictionaryKey: "GADInterstitialAdUnitID") as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nonEmpty ?? releaseInterstitialFallbackID
        #endif
    }()
    private static let interstitialCalculationThreshold = 5

    @ObservationIgnored @AppStorage("ads.launchCount") private var launchCount: Int = 0
    @ObservationIgnored @AppStorage("ads.calcCount") private var calculationCount: Int = 0

    var isInterstitialReady: Bool = false

    func markAppLaunch() {
        launchCount += 1
    }

    func initializeSDKs() {
        #if canImport(GoogleMobileAds)
        #if DEBUG
        // Device ID from your logs for guaranteed test ads on this device.
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["00e24ab47c716204eb5a9fd50fdd43f2"]
        print("AdMob DEBUG: test device identifiers configured.")
        #endif

        GADMobileAds.sharedInstance().start { status in
            let adapterStates = status.adapterStatusesByClassName
                .map { "\($0.key): \($0.value.state.rawValue)" }
                .joined(separator: ", ")
            print("AdMob SDK initialized. Adapter states: \(adapterStates)")
        }
        preloadInterstitial()
        #endif
    }

    func maybeShowInterstitialAfterCalculation() {
        #if canImport(GoogleMobileAds) && canImport(UIKit)
        calculationCount += 1
        print("AdMob Interstitial: calculation count = \(calculationCount)")
        guard calculationCount >= Self.interstitialCalculationThreshold else { return }

        shouldPresentWhenReady = true
        presentInterstitialIfPossible()
        #endif
    }

    #if canImport(GoogleMobileAds)
    @ObservationIgnored private var interstitialAd: GADInterstitialAd?
    @ObservationIgnored private var interstitialDelegate: InterstitialDelegate?
    @ObservationIgnored private var shouldPresentWhenReady = false
    @ObservationIgnored private var isPresentingInterstitial = false

    private func preloadInterstitial() {
        guard interstitialAd == nil else { return }
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: Self.interstitialAdUnitID, request: request) { [weak self] ad, error in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.interstitialAd = ad
                self.isInterstitialReady = (ad != nil)
                if let error {
                    print("AdMob Interstitial: failed to load - \(error.localizedDescription)")
                } else {
                    print("AdMob Interstitial: loaded successfully.")
                    self.presentInterstitialIfPossible()
                }
            }
        }
    }

    private func presentInterstitialIfPossible() {
        guard shouldPresentWhenReady else { return }
        guard !isPresentingInterstitial else { return }

        guard let interstitialAd else {
            print("AdMob Interstitial: threshold reached; waiting for ad load.")
            preloadInterstitial()
            return
        }

        guard let rootViewController = topViewController() else {
            print("AdMob Interstitial: threshold reached; waiting for root view controller.")
            preloadInterstitial()
            return
        }

        let delegate = InterstitialDelegate(
            onPresent: { [weak self] in
                guard let self else { return }
                self.isPresentingInterstitial = true
                self.shouldPresentWhenReady = false
                self.calculationCount = 0
            },
            onDismiss: { [weak self] in
                guard let self else { return }
                self.isPresentingInterstitial = false
                self.isInterstitialReady = false
                self.preloadInterstitial()
            },
            onFailToPresent: { [weak self] in
                guard let self else { return }
                self.isPresentingInterstitial = false
                self.shouldPresentWhenReady = true
                if self.calculationCount < Self.interstitialCalculationThreshold {
                    self.calculationCount = Self.interstitialCalculationThreshold
                }
                self.isInterstitialReady = false
                self.preloadInterstitial()
            }
        )
        interstitialAd.fullScreenContentDelegate = delegate
        self.interstitialDelegate = delegate

        self.interstitialAd = nil
        isInterstitialReady = false
        interstitialAd.present(fromRootViewController: rootViewController)
    }

    private final class InterstitialDelegate: NSObject, GADFullScreenContentDelegate {
        private let onPresent: () -> Void
        private let onDismiss: () -> Void
        private let onFailToPresent: () -> Void

        init(onPresent: @escaping () -> Void, onDismiss: @escaping () -> Void, onFailToPresent: @escaping () -> Void) {
            self.onPresent = onPresent
            self.onDismiss = onDismiss
            self.onFailToPresent = onFailToPresent
        }

        func adWillPresentFullScreenContent(_ ad: any GADFullScreenPresentingAd) {
            onPresent()
        }

        func adDidDismissFullScreenContent(_ ad: any GADFullScreenPresentingAd) {
            onDismiss()
        }

        func ad(_ ad: any GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: any Error) {
            print("AdMob Interstitial: failed to present - \(error.localizedDescription)")
            onFailToPresent()
        }
    }
    #endif

    #if canImport(UIKit)
    private func topViewController(base: UIViewController? = nil) -> UIViewController? {
        let root = base ?? UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }
            .first

        if let nav = root as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = root as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }
        if let presented = root?.presentedViewController {
            return topViewController(base: presented)
        }
        return root
    }
    #endif
}

private extension String {
    var nonEmpty: String? { isEmpty ? nil : self }
}
