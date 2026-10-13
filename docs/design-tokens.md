# Zyppi design tokens (approved mockup, existing Zyppi brand)

Implement in `lib/core/theme/` (`app_colors.dart`, `app_typography.dart`, `app_spacing.dart`, `app_theme.dart`), replacing `lib/core/constants/colors.dart`. Widgets never use literal colors or sizes.

Brand source: `assets/icons/appLogo.png` (blue "ZY", pink "PPi", tagline "Quick Easy Reliable") and the existing `AppColors`.

## Colors

| Token | Hex | Use |
| --- | --- | --- |
| brandPink | `#F32AA0` | Logo pink, decorative accents (existing `primaryButtonColor`) |
| primary | `#D81B87` | Buttons, steppers, header, active tab, links — brand pink darkened so white text passes 4.5:1 |
| primaryDark | `#A8106A` | Pressed state, avatar on header |
| primaryTint | `#FFECF7` | Info/success banners, icon chips, secondary button bg (existing category pink) |
| primarySurface | `#FFF5FB` | Selected option / filled OTP box |
| onPrimaryMuted | `#FFD3EC` | Secondary text on primary |
| brandBlue | `#3158E9` | Logo blue; secondary accent (existing `deepBlue`) |
| navy | `#05416F` | Existing `blue`; optional headings |
| green | `#53B175` | Existing green; success / "delivered" |
| accent | `#FFCB45` | Discount badge, promo banner, onboarding CTA, current timeline step |
| accentTint | `#FFF1C2` | Out-for-delivery badge bg |
| ink | `#17201B` | Primary text |
| muted | `#5B655F` | Secondary text, MRP strike, inactive nav |
| line | `#E4E6E1` | Borders, dividers, inputs |
| divider | `#EEF0EA` | List separators, side-rail bg |
| background | `#F6F7F3` | Default screen bg |
| backgroundAlt | `#F2F3EE` | Cart / checkout / orders / account bg |
| surface | `#FFFFFF` | Cards, sheets, nav bar |
| danger | `#B42318` / tint `#FDECEA` | Logout, errors |

Category tiles (bg / icon): Vegetables `#E6F3E4`/`#2F7D32` · Fruits `#FDECE7`/`#C2410C` · Dairy & Bread `#E8F1FB`/`#1F5FD6` · Eggs & Meat `#FBF1E2`/`#A16207` · Snacks `#FFF5D6`/`#A16207` · Drinks `#F1ECFB`/`#6D3FC0` · Atta, Rice & Dal `#F3EFE6`/`#7A5A20` · Cleaning `#E3F5F3`/`#0F766E`. The existing `AppColors.categoryColors` list can map onto these.

Order status badges: Out for delivery `#FFF1C2`/`#7A5A00` · Delivered `#E7F4EC`/`#0A5A34` · Cancelled `#FDECE7`/`#9A3412`.

## Typography (fonts already bundled in `assets/fonts/`)

| Style | Font | Size / weight |
| --- | --- | --- |
| displayLarge | Montserrat | 34 / 700 |
| headlineMedium | Montserrat | 28 / 700 |
| headlineSmall | Montserrat | 24 / 700 |
| titleLarge | Montserrat | 19–20 / 700 |
| titleMedium | Montserrat | 17 / 700 |
| bodyLarge | Poppins | 15–16 / 400–500 |
| bodyMedium | Poppins | 14 / 500–600 |
| labelLarge | Poppins | 16 / 700 (buttons) |
| bodySmall | Poppins | 12–13 / 500 |
| labelSmall | Poppins | 11 / 600–700 (badges, nav labels, overlines 0.06em) |

Remove unused families from `pubspec.yaml`: Righteous, Aclonica, AirbnbCereal.

## Shape, spacing, sizes

- Radius: 6 badge · 8 chip · 9 add button / stepper · 10–12 inputs, tiles, buttons · 14 cards · 16 banner · 18 pill chips · 22 sheet top corners
- Spacing: 4, 6, 8, 10, 12, 14, 16, 20, 24, 32 · screen padding 16 (12 on dense lists)
- Heights: button 52 · bottom CTA 56 · input 48–56 · ADD / stepper 36 · nav 72 · floating cart bar 52–56 · min touch target 44
- Design size for flutter_screenutil: 390 × 844
- Elevation: flat cards with 1 px `line` border; shadows only on floating cart bar, map buttons, sheets
- Icons: outline, 1.8 stroke, 20–22 px. Existing PNG nav icons in `assets/icons/` may stay until replaced.
