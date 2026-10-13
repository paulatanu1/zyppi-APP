# Zyppi design tokens (from the approved mockup)

Implement these in `lib/core/theme/` (e.g. `app_colors.dart`, `app_typography.dart`, `app_spacing.dart`, `app_theme.dart`). Widgets never use literal colors or sizes.

## Colors

| Token | Hex | Use |
| --- | --- | --- |
| primary | `#0E7C47` | Header, primary buttons, steppers, active nav, links |
| primaryDark | `#0A5A34` | Pressed/hover, avatar bg on header, success text |
| primaryTint | `#E7F4EC` | Success banners, icon chips, secondary button bg |
| primarySurface | `#F3FAF6` | Selected option card / filled OTP box |
| onPrimaryMuted | `#CFE9DA` | Secondary text on primary (e.g. "You save ₹31") |
| accent | `#FFCB45` | Promo banner, discount badge, onboarding CTA, "current" timeline dot |
| accentTint | `#FFF1C2` | Out-for-delivery badge bg |
| accentTintAlt | `#FFF5D6` | Banner icon circle |
| ink | `#17201B` | Primary text |
| muted | `#5B655F` | Secondary text, MRP strike, inactive nav |
| line | `#E4E6E1` | Card borders, dividers, input borders |
| divider | `#EEF0EA` | List row separators, side-rail bg tone |
| background | `#F6F7F3` | Default screen bg |
| backgroundAlt | `#F2F3EE` | Cart / checkout / orders / profile bg |
| surface | `#FFFFFF` | Cards, sheets, nav bar |
| danger | `#B42318` | Logout, errors |
| dangerTint | `#FDECEA` | Danger icon chip |
| mapBg | `#E9ECE4` | Map placeholder |

Category tints (tile bg / icon color):

| Category | Bg | Icon |
| --- | --- | --- |
| Vegetables | `#E6F3E4` | `#2F7D32` |
| Fruits | `#FDECE7` | `#C2410C` |
| Dairy & Bread | `#E8F1FB` | `#1F5FD6` |
| Eggs & Meat | `#FBF1E2` | `#A16207` |
| Snacks | `#FFF5D6` | `#A16207` |
| Drinks | `#F1ECFB` | `#6D3FC0` |
| Atta, Rice & Dal | `#F3EFE6` | `#7A5A20` |
| Cleaning | `#E3F5F3` | `#0F766E` |

Order status badges: Out for delivery `#FFF1C2`/`#7A5A00` · Delivered `#E7F4EC`/`#0A5A34` · Cancelled `#FDECE7`/`#9A3412`.

## Typography

- Display / headings: **Bricolage Grotesque** 600–700, letter-spacing −0.01em
- Body / UI: **Figtree** 400–700
- Bundle both in `assets/fonts/` (Google Fonts, OFL); do not fetch at runtime.

| Style | Font | Size / weight |
| --- | --- | --- |
| displayLarge | Bricolage | 34 / 700 (onboarding) |
| headlineMedium | Bricolage | 28 / 700 (login, OTP) |
| headlineSmall | Bricolage | 24 / 700 (home ETA, product title, page titles) |
| titleLarge | Bricolage | 19–20 / 700 (app bar titles, banner) |
| titleMedium | Bricolage | 17 / 700 (section headers) |
| bodyLarge | Figtree | 15–16 / 400–500 |
| bodyMedium | Figtree | 14 / 500–600 (product names, list rows) |
| labelLarge | Figtree | 16 / 700 (buttons) |
| bodySmall | Figtree | 12–13 / 500 (meta, captions) |
| labelSmall | Figtree | 11 / 600–700 (badges, nav labels, overlines with 0.06em tracking) |

## Shape, spacing, sizes

- Radius: 6 badge · 8 small chip · 9 add button / stepper · 10–12 inputs, tiles, buttons · 14 cards · 16 promo banner · 18 pill chips · 22 bottom-sheet top corners
- Spacing scale: 4, 6, 8, 10, 12, 14, 16, 20, 24, 32
- Screen padding: 16 horizontal (12 on dense list screens)
- Heights: primary button 52 · bottom CTA 56 · input 48–56 · ADD / stepper 36 · bottom nav 72 · floating cart bar 52–56 · min touch target 44
- Elevation: flat cards with 1px `line` border; shadows only on floating cart bar, map buttons, bottom sheets
- Icons: outline, 1.8 stroke, 20–22 px (Lucide-style); use `lucide_icons_flutter` or Material Symbols Outlined
