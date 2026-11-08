---
name: zyppi-ui-design
description: Build, restyle or review Zyppi Flutter screens to match the v2 design (docs/screens PNGs, docs/UI_GUIDE.md) using the existing ZColors/ZSpace/ZRadius tokens, lib/core/widgets components and easy_localization, without touching business logic.
---

# Zyppi UI Design

Use this skill when you build, restyle or review a screen in the Zyppi app. `CLAUDE.md` takes precedence if anything here conflicts with it.

## 1. Visual references (source of truth)
- Read `CLAUDE.md`, `docs/UI_GUIDE.md` and `docs/design-tokens.md` first.
- The target for each screen is `docs/screens/light/<NN-name>.png` and `docs/screens/dark/<NN-name>.png`, rendered at 390 × 844. Look at both PNGs before writing code. The exact sizes come from `docs/mockups/<File>.dc.html`, with styles in `docs/mockups/zyppi.css`; ignore the `x-dc` / `support.js` wrapper. The screen table in `docs/UI_GUIDE.md` maps each PNG to its mockup and to the existing feature code.
- Build to the patterns in `lib/design_v2/home_v2_screen.dart`, the reference implementation. Do not introduce a different design language.
- Widget sizes are logical pixels equal to the mockup's CSS pixels. Do not wrap them in flutter_screenutil `.w` / `.h` / `.sp`.
- If a screen has no PNG, or the PNG, mockup and guide disagree, say so and ask. Do not invent a convention.

## 2. Design tokens
- Read the definitions before using them. Never guess a name or value.
  - Colors: `context.z.*`, from the `ZColors` ThemeExtension in `lib/core/theme/zyppi_colors.dart`, with a light and a dark set.
  - Spacing, radius, size and motion: `ZSpace`, `ZRadius`, `ZSize` and `ZMotion` in `lib/core/theme/zyppi_tokens.dart`.
  - Text: `Theme.of(context).textTheme.*`, built from `lib/core/theme/zyppi_typography.dart` (Sora for display, Manrope for body).
- Do not put literal colors, font sizes, radii or ad-hoc spacing in widgets, and do not add new constants when an existing token fits. If one is genuinely missing, propose adding it to `zyppi_tokens.dart` or `zyppi_colors.dart`, in both themes.
- `lib/core/theme/app_colors.dart`, `app_spacing.dart` (`AppSpacing`, `AppRadius`, `AppSizes`) and `app_colors_ext.dart` are an older, parallel token set that many screens still use. Some of its values differ: `AppRadius.badge` is 8 but `ZRadius.badge` is 7. Use the Z tokens in new and restyled code. Do not extend the legacy classes.

## 3. Reusable widgets
- Check `lib/core/widgets/` before writing new UI:
  - `z_product_card.dart`: `ZProductCard`
  - `z_commerce.dart`: `ZAddStepper`, `ZPrice`, `ZOffBadge`, `ZEtaBadge`, `ZImageTile`
  - `z_chrome.dart`: `ZSectionHeader`, `ZCategoryTile`, `ZSearchBar`, `ZCartBar`, `ZNavBar`
  - `z_motion.dart`: `ZEntrance`, `ZPressable`, `ZLoop`, `ZSkeleton`
- If a shared widget is close but not quite right, extend it with a parameter rather than copying it. New shared widgets follow the `Z*` naming and token-only styling.
- Wrap sections in `ZEntrance` with increasing `index`. Animations must respect `MediaQuery.disableAnimationsOf`.
- Widgets render state only. Data comes from the existing Riverpod providers and repository interfaces. Never call Firestore, Cloud Functions, Firebase Auth or `assets/mock` from a widget.

## 4. Localization
- Strings use `easy_localization`: string keys with `'key'.tr()`. There is no generated `LocaleKeys` class and no codegen step.
- Add every new key, with the same name, to all four files: `assets/translations/en-UK.json`, `bn-BN.json`, `hi-IN.json` and `pa-Guru.json`. The locales are registered in `lib/bootstrap.dart`, with en-UK as the fallback.
- No hardcoded user-facing strings. Reuse an existing key when its meaning matches.
- Run `fvm flutter test test/core/translations_parity_test.dart` to check that the four files have the same keys.

## 5. Safe implementation
- Change the UI layer only. Keep providers, navigation (go_router routes), cart logic, auth, Firebase integrations, Firestore schema, payments and order flows as they are unless the task explicitly asks for a change.
- Money is `int` paise. Format it only in the UI, with the existing helpers and `ZPrice`.
- Do not add packages, unrelated refactors, or mock data in production flows.
- Every async screen needs four states: skeleton loading (`ZSkeleton`), empty, error with retry, and data. It must also look right in light and dark themes, at small widths, and with large text scaling. Touch targets must be at least `ZSize.touch`.
- After changes, run `fvm dart format .`, then `fvm flutter analyze` (0 issues), then `fvm flutter test`. If you edited freezed, json or riverpod-annotated files, also run `fvm dart run build_runner build -d` and commit the generated files.

## 6. Workflow
1. Open the screen's PNGs (light and dark), its mockup, the existing feature code and the shared widgets it should use.
2. List the specific differences from the reference and propose the changes before any substantial refactor.
3. Implement one screen, or one coherent group of components, at a time.
4. When a device, simulator or screenshot tool is available, run the app (`fvm flutter run --flavor dev --dart-define-from-file=env/dev.json`), capture light and dark screenshots, and compare them with the PNGs.
5. Report the changed files, the format/analyze/test results, and any remaining visual differences or unresolved issues. Never claim the UI was visually verified unless you inspected a rendered screen.
