# MoneyFormula UI Spec v1

## 1) Product Visual Direction
- Style: premium, dense, dark-first financial utility UI.
- Tone: clean, sharp, non-generic, native iOS.
- Principle: clarity before decoration.
- Current rule: avoid gradient-heavy/tinted UI treatment for main surfaces.

## 2) Global Theme
- Background style: solid dark.
- Core background component: `PremiumBackground` currently renders `SCBackground` only.
- No glassmorphism overlays in primary content areas.

## 3) Color System (Assets Only)
Use only `Assets.xcassets` named colors in Swift code.

- `SCBackground`: global app background
- `SCSurfaceL1`: primary card/list surface
- `SCSurfaceL2`: elevated surface / input container
- `SCSurfaceL3`: pressed/alternate surface
- `SCBorder`: standard stroke
- `SCBorderActive`: focused/active stroke
- `SCAccentTeal`: primary accent
- `SCAccentBlue`: secondary accent
- `SCAccentGold`: premium/favorite accent
- `SCPositive`: positive results
- `SCNegative`: negative/error results
- `SCWarning`: caution/warning state
- `SCNeutral`: neutral state

Category color assets:
- `SCCategoryReturns`
- `SCCategoryValuation`
- `SCCategoryRisk`
- `SCCategoryTechnical`
- `SCCategoryFundamental`
- `SCCategoryPortfolio`
- `SCCategoryBonds`
- `SCCategorySIPMF`
- `SCCategoryOptions`

## 4) Typography
- Font family: SF system fonts only.
- Screen/app title: heavy display style.
- Formula expression text: monospaced style for readability.
- Labels/captions: compact and secondary emphasis.

Current app title treatment:
- Top-left brand includes `BrandMarkView` + `MoneyFormula` text.
- Subtitle style used for supporting brand line (small uppercase tracking).

## 5) Spacing & Shape
- Card corner radius: 16.
- Input corner radius: 12.
- Primary button corner radius: 14.
- Section spacing in main formula list: consistent 8/12/16 rhythm.
- Minimum touch targets: 44x44 for actionable controls.

## 6) Navigation Structure
- `TabView` with 4 tabs:
  - Calculate
  - History
  - Favorites
  - Search
- Home top-right: settings only.
- Import action removed from home toolbar.

## 7) Formula Card Pattern
File: `Components/FormulaCard.swift`

Each card shows:
- Formula full name
- Short alias
- Mathematical expression
- Optional `Popular` badge
- Optional `Auto-fill` badge

Removed:
- Category badge pill row (e.g., “Portfolio Tools” style badge).

## 8) Formula Detail Pattern
File: `Views/Calculate/FormulaDetailView.swift`

Contains:
- Category chip + formula title
- Formula explanation card (`FORMULA`, `WHERE`, disclosure)
- Input fields
- Calculate button
- Result + chart section
- Favorite heart action (formula-level favorite)

Keyboard behavior:
- Single `Done` button in keyboard toolbar at screen level.
- Tap outside or calculate action dismisses keyboard.

## 9) Favorites Behavior
- Favorites are for formulas only.
- Saved calculations are not used as favorites.
- Favorite toggle persists through SwiftData (`FavoriteFormula`).

## 10) Performance Rules
- Avoid per-row drag gestures on large lists.
- Keep background rendering simple (solid fill in shared background).
- Prefer light shadows and single-stroke borders.
- Avoid redundant layered backgrounds inside lists.

## 11) Startup/Blank-Screen Guard
- `ContentView` includes a startup fallback state with:
  - dark background
  - brand mark
  - app title
  - progress indicator
- Prevents empty/blank visual at launch transitions.

## 12) File Ownership Map (UI)
- App shell: `MoneyFormulaApp.swift`, `ContentView.swift`
- Tab shell: `Views/Main/MainTabView.swift`
- Calculate: `Views/Calculate/*`
- History: `Views/History/HistoryView.swift`
- Favorites: `Views/Favorites/FavoritesView.swift`
- Settings: `Views/Settings/SettingsView.swift`
- Shared UI: `Components/*`
- Tokens: `Assets.xcassets/*`

## 13) Update Policy
When changing UI:
1. Update asset colors first (if needed).
2. Reuse existing components before adding new ones.
3. Keep formula readability as top priority.
4. Preserve dark-first consistency across all tabs.
5. Avoid introducing gradients/tints for core layout surfaces unless explicitly requested.
