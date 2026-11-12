# Zyppi design tokens — v2 (Sora + Manrope, light + dark)

**Brand (2026-11):** the app uses the logo purple everywhere (pink removed). Brand surfaces carry the splash texture — purple fill + aurora blobs + film grain — via `ZBrandTexture` (`lib/core/widgets/z_brand_texture.dart`): hero headers on the main tabs and key moments (`ZHeroHeader`), filled buttons, the cart and checkout bars. Detail screens use the light app bar from the theme. The PNGs in `docs/screens` still show the old magenta and are out of date on colour.

**Source of truth is code:** `lib/core/theme/` (ZColors, ZyppiTheme, ZSpace, ZRadius, ZSize, ZMotion). This file is the human-readable copy. Visual truth is `docs/screens/{light,dark}/*.png`.

Rules: widgets never use literal colours, font sizes or radii — read `context.z.<token>`, `Theme.of(context).textTheme.<style>`, `ZRadius.*`, `ZSpace.*`.

## Colours

| Token (`context.z.`) | Light | Dark | Use |
| --- | --- | --- | --- |
| `bg` | `#F6F5F2` | `#0D0E11` | Scaffold background |
| `surface` | `#FFFFFF` | `#16171C` | Cards, sheets, nav bar, app bar |
| `surface2` | `#F0EEE9` | `#1E2026` | Image tiles, wells, ETA chip |
| `surface3` | `#E8E5DF` | `#272930` | Progress track, skeleton highlight |
| `line` / `line2` | `#E4E1DA` / `#D6D2C9` | `#2A2C33` / `#383B43` | Borders / input + outline-button borders |
| `ink` / `ink2` / `ink3` | `#141519` / `#55585F` / `#83868D` | `#F2F2F4` / `#A8AAB2` / `#787B84` | Text: primary / secondary / captions |
| `brand` | `#673AB7` | `#7E57C2` | Logo purple: primary buttons (textured), stepper, cart bar (textured), active states |
| `brandText` | `#5E35B1` | `#B39DDB` | Links, ADD outline, active tab icon (text-safe brand) |
| `brandSoft` / `brandSoft2` | `#EDE7F6` / `#D1C4E9` | `#1F1533` / `#2D1F4A` | Active tab pill, See-all pill, selected option bg |
| `header` | `#673AB7` | `#2A1658` | Textured hero headers (`ZBrandTexture` / `ZHeroHeader`) |
| `blue` / `blueText` / `blueSoft` | `#2443D6` / `#2443D6` / `#E7EBFD` | `#4865F0` / `#97A9FF` / `#1A2150` | "% OFF" badge, secondary accent |
| `deal` / `dealInk` | `#FFC83D` / `#3B2A00` | same | Promo banner |
| `ok` / `okSoft` | `#138A4A` / `#E2F4E9` | `#3FD27F` / `#0F2E1D` | Savings, delivered, success |
| `warn` / `warnSoft` | `#9A5B00` / `#FFF1CF` | `#F6B73C` / `#33270A` | "On the way" |
| `danger` / `dangerSoft` | `#C2263A` / `#FDE8EA` | `#FF6B7D` / `#3A1218` | Errors, cancelled, log out |
| `tileVeg … tileAll` | see `zyppi_colors.dart` | | Category / product tile tints |

## Typography (bundled in `assets/fonts/`)

| Style (`textTheme.`) | Font | Size / weight | Example |
| --- | --- | --- | --- |
| `displaySmall` | Sora | 31 / 700 | "Groceries at your door in 12 minutes" |
| `headlineMedium` | Sora | 27 / 700 | "Log in or sign up" |
| `headlineSmall` | Sora | 24 / 700 | "12 minutes" (home), product title 22 |
| `titleLarge` | Sora | 18 / 700 | App-bar titles |
| `titleMedium` | Sora | 17 / 700 | Section headers |
| `bodyLarge` | Manrope | 15 / 500, ink2 | Paragraphs |
| `bodyMedium` | Manrope | 14 / 500 | Default |
| `labelLarge` | Manrope | 14 / 700 | Product names, list rows |
| `labelMedium` | Manrope | 13 / 700 | Chips, links |
| `bodySmall` | Manrope | 12 / 600, ink3 | Weight, captions |
| `labelSmall` | Manrope | 11 / 800, +0.08em, ink3 | Overlines, badges |
| `.price` / `.mrp` (extension) | Manrope | 15 / 800 · 12 / 600 struck | ₹149 ₹179 |

Headings use letter-spacing −0.02em. All numbers use tabular figures. For Bengali/Hindi/Punjabi bundle Noto Sans Bengali / Devanagari / Gurmukhi (already listed as fallbacks).

## Shape, spacing, sizes

- Radius: badge 7 · control (ADD, stepper) 11 · tile 16 · button/input 16 · card 18 · chip 18 (stadium) · sheet 26
- Spacing: 4-pt grid — 4, 8, 12, 16, 20, 24, 32. Screen padding 16.
- Heights: primary button 54 · input 56 · search 50 · ADD/stepper 34 · cart bar 60 · nav bar 66 + safe area · touch ≥ 44
- Tiles: product image 112 high; category tile 76 × 72
- Elevation: flat cards with 1 px `line` border. Shadows only on cart bar, map buttons, sheets.

## Motion (`ZMotion`, widgets in `z_motion.dart`)

| What | Spec | Widget |
| --- | --- | --- |
| Press feedback | scale 0.96, 120 ms | `ZPressable` |
| Screen entrance | fade + 14 px rise, 420 ms, 60 ms stagger | `ZEntrance(index:)` |
| Cart bar / sheets | slide up 500 ms, emphasized curve | `ZCartBar` (built in) |
| ADD → stepper | scale + fade 240 ms; count slides | `ZAddStepper` |
| ETA bolt | pulse 1.6 s loop | `ZLoop(kind: pulse)` |
| Illustrations | bob 2.4 s / float 4 s | `ZLoop(kind: bob/float)` |
| Loading | shimmer 1.2 s | `ZSkeleton` |
| Order placed | check pop + ring + confetti | build per screen |

All motion is skipped when `MediaQuery.disableAnimationsOf(context)` is true.

## Icons

Material Symbols rounded/outlined (`Icons.*_rounded`, `Icons.*_outlined`) at 20–22 px. No extra icon package needed.
