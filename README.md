```markdown
# MoneyFormula

![iOS](https://img.shields.io/badge/iOS-18%2B-black?style=for-the-badge&logo=apple)
![Swift](https://img.shields.io/badge/Swift-6-orange?style=for-the-badge&logo=swift)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-blue?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

MoneyFormula is a premium iOS financial calculator app built for speed, clarity, and daily use.  
From SIP and returns to valuation and planning formulas, it gives users instant results in a modern, Apple-native Liquid Glass experience.

## Download on the App Store

[![Download on the App Store](https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg)](https://apps.apple.com/in/app/moneyformula-finance-calc/id6762509637)

App link: https://apps.apple.com/in/app/moneyformula-finance-calc/id6762509637

---

## Why MoneyFormula

Financial calculators are often cluttered or slow. MoneyFormula focuses on:

- Fast formula discovery
- Clean, guided input experience
- Clear result presentation
- Reusable history and favorites
- Native iOS interactions and visual polish

---

## Core Features

- Powerful formula library across multiple financial categories
- Browse + search-first navigation
- Detailed formula screens with structured inputs and outputs
- Favorite formulas for one-tap access
- Calculation history for quick review
- Native settings flow
- AdMob interstitial integration (after every 5 calculations)

---

## Product Experience

- Apple-style UI patterns with Liquid Glass-inspired surfaces
- Smooth SwiftUI transitions and touch feedback
- Optimized for both light and dark themes
- Built for quick one-hand usage and repeat calculations

---

## Screens

Add your screenshots here:

- Home
- Browse/Search
- Formula Detail
- Results
- History
- Settings

Example:

```md
![Home](docs/screens/home.png)
![Browse](docs/screens/browse.png)
![Formula Detail](docs/screens/formula-detail.png)
```

---

## Tech Stack

- **Language:** Swift
- **UI:** SwiftUI
- **Persistence:** SwiftData
- **Ads:** Google Mobile Ads (AdMob)
- **Architecture:** Modular feature + manager-based structure

---

## Project Structure

```text
MoneyFormula/
├─ Components/      # Reusable UI elements and design system
├─ Engine/          # Calculation logic
├─ Managers/        # Ads, haptics, app services
├─ Models/          # Formula and persistence models
├─ Views/           # Home, Search, History, Settings, Formula screens
└─ Assets.xcassets/ # App assets
```

---

## Getting Started

### Requirements

- Xcode 16+
- iOS 18+ recommended

### Run Locally

1. Clone this repository
2. Open the project in Xcode
3. Select the `MoneyFormula` scheme
4. Build and run on simulator/device

---

## AdMob Setup

Configure these keys in `Info.plist`:

- `GADApplicationIdentifier`
- `GADInterstitialAdUnitID`

Recommended flow:

- Use Google test IDs in debug/dev
- Use production IDs only for release builds
- Validate interstitial trigger behavior before submission

---

## Privacy

This build is configured for **non-ATT ad flow** (no tracking permission prompt).  
If you later enable personalized tracking ads, update:

- `NSUserTrackingUsageDescription`
- ATT request flow in code
- App Store Connect Privacy declarations

---

## Versioning

- `CFBundleShortVersionString` -> user-facing version (e.g. `1.1`)
- `CFBundleVersion` -> internal build number (must increase each upload)

---

## Roadmap

- More formula packs
- Advanced chart-based outputs
- iPad layout optimization
- Localization support

---

## Contributing

Contributions are welcome.  
Please open an issue first for major changes and include screenshots for UI changes.

---

## License

MIT License

Copyright (c) 2026 MoneyFormula

