# MoneyFormula

MoneyFormula is a modern iOS app for fast financial calculations with a premium Liquid Glass UI.  
It helps users explore formulas, calculate results instantly, and save favorites/history for quick reuse.

## Features

- Large collection of market-focused financial formulas
- Smart categories and search/browse flow
- Formula detail pages with guided inputs and results
- Favorites and calculation history
- Native iOS-style settings experience
- Interstitial AdMob integration (shown after every 5 calculations)

## Tech Stack

- Swift
- SwiftUI
- SwiftData
- Google Mobile Ads (AdMob)

## Project Structure

- `MoneyFormula/Views` – UI screens (Home, Search/Browse, History, Settings, Formula details)
- `MoneyFormula/Models` – formula definitions, app models, persistence models
- `MoneyFormula/Managers` – app-level services (ads, haptics, etc.)
- `MoneyFormula/Components` – reusable UI components/design system
- `MoneyFormula/Engine` – formula computation logic

## Requirements

- Xcode 16+
- iOS 18+ (recommended for best Liquid Glass behavior)

## Setup

1. Clone the repository
2. Open the project in Xcode
3. Select the `MoneyFormula` scheme
4. Run on simulator or device

## AdMob Configuration

Set the following in `Info.plist`:

- `GADApplicationIdentifier`
- `GADInterstitialAdUnitID`

> For development, use Google test ad units.  
> For production, use your live AdMob app ID and ad unit ID.

## Privacy Note

This app currently runs ads without ATT tracking prompt (non-personalized ad flow).  
If you later add ATT-based personalization, update:
- `NSUserTrackingUsageDescription`
- App Store Connect App Privacy answers

## Versioning

Use:
- `Version` (`CFBundleShortVersionString`) for public release version (e.g. `1.1`)
- `Build` (`CFBundleVersion`) for internal incrementing build number

## License

MIT License

Copyright (c) 2026 MoneyFormula

