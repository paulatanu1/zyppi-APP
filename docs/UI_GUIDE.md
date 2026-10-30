# Building the v2 UI with Claude Code

Why the earlier attempt didn't match: Claude Code only had a token list. It could not see the screens and had no Flutter components to build from, so it improvised. This pack gives it three things:

1. **Pictures:** `docs/screens/light/*.png` and `docs/screens/dark/*.png` — every screen rendered at 390 × 844 (@2x).
2. **Code:** `lib/core/theme/` (complete light + dark theme) and `lib/core/widgets/` (product card, ADD stepper, category tile, cart bar, nav bar, search bar, motion helpers).
3. **A worked example:** `lib/design_v2/home_v2_screen.dart` — the Home screen fully built with those widgets.

## One-time setup (Phase "UI v2", before any screen work)

Paste into Claude Code:

```
Read CLAUDE.md, docs/UI_GUIDE.md and docs/design-tokens.md.
Set up the v2 design system:
1. In pubspec.yaml: add the Sora and Manrope font families exactly as in docs/UI_GUIDE.md "pubspec", add assets/images/products/ to assets. Remove the Righteous, Aclonica and AirbnbCereal families.
2. In the MaterialApp: theme: ZyppiTheme.light, darkTheme: ZyppiTheme.dark, themeMode from a Riverpod provider persisted in shared_preferences (light / dark / system).
3. Add a temporary route /design-v2 that opens HomeV2Screen.
4. Run fvm flutter analyze and fix anything in lib/core/theme, lib/core/widgets and lib/design_v2 (they were written without a compiler).
5. Run the app, open /design-v2 and compare it side by side with docs/screens/light/05-home.png and docs/screens/dark/05-home.png. Fix differences until they match.
Do not change any other screen yet.
```

## Then one screen per prompt

```
Rebuild the <SCREEN> screen to match docs/screens/light/<NN-file>.png and docs/screens/dark/<NN-file>.png exactly.
Use only lib/core/theme tokens and lib/core/widgets components; follow the patterns in lib/design_v2/home_v2_screen.dart.
The HTML source with exact sizes is docs/mockups/<File>.dc.html (styles in docs/mockups/zyppi.css).
Keep the existing providers and navigation; change the UI layer only. Wrap sections in ZEntrance with increasing index.
When done, run the app in light and dark, take a screenshot of each, and list any remaining differences from the PNGs.
```

| Screen | PNG | HTML source | Existing code |
| --- | --- | --- | --- |
| Onboarding | `01-onboarding.png` | `Onboarding.dc.html` | `features/Intro` |
| Login | `02-login.png` | `Login.dc.html` | `features/Auth/Login` |
| OTP | `03-otp.png` | `Otp.dc.html` | `features/Auth/OTPVerification` |
| Location | `04-location.png` | `Location.dc.html` | `features/SearchAddress` |
| Home | `05-home.png` | `Main.dc.html` | `features/HomeScreen` (see `design_v2/home_v2_screen.dart`) |
| Category | `06-category.png` | `Category.dc.html` | `features/CategoryDetails`, `features/Explore` |
| Product | `07-product.png` | `Product.dc.html` | `features/ProductDetails` |
| Search | `08-search.png` | `Search.dc.html` | new |
| Cart | `09-cart.png` | `Cart.dc.html` | `features/MyCart` |
| Checkout | `10-checkout.png` | `Checkout.dc.html` | new |
| Order placed | `11-order-placed.png` | `Placed.dc.html` | new |
| Tracking | `12-tracking.png` | `Tracking.dc.html` | new |
| Orders | `13-orders.png` | `Orders.dc.html` | `features/YourOrder` |
| Account | `14-account.png` | `Profile.dc.html` | `features/Account` |

Tip: drag the two PNGs for the screen into the Claude Code prompt as well — it reads images directly.

## pubspec

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/translations/
    - assets/icons/
    - assets/images/
    - assets/images/products/
  fonts:
    - family: Sora
      fonts:
        - asset: assets/fonts/Sora/Sora-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Sora/Sora-Bold.ttf
          weight: 700
        - asset: assets/fonts/Sora/Sora-ExtraBold.ttf
          weight: 800
    - family: Manrope
      fonts:
        - asset: assets/fonts/Manrope/Manrope-Medium.ttf
          weight: 500
        - asset: assets/fonts/Manrope/Manrope-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Manrope/Manrope-Bold.ttf
          weight: 700
        - asset: assets/fonts/Manrope/Manrope-ExtraBold.ttf
          weight: 800
```

Keep the existing Poppins/Montserrat entries until every screen is migrated, then delete them.

## flutter_screenutil

The widgets use plain logical pixels, which equal the mockup's CSS pixels at the 390 × 844 design size. Don't wrap their sizes in `.w`/`.h`/`.sp`; text scaling is handled by the OS setting.

## Fonts licence

Sora and Manrope are under the SIL Open Font License (`assets/fonts/*/OFL.txt`). Free for commercial apps.
