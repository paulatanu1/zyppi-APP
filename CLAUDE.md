# Zyppi — rules for Claude Code

Zyppi is a quick-commerce grocery customer app (Flutter, FVM-pinned 3.47.x) on a Firebase backend (project `zippy-app-2024`: Auth, Firestore, Cloud Functions in `asia-south1`, Storage, FCM, Crashlytics, Analytics). The Angular admin panel is the sibling repo `../zyppi-admin`. Repo `paulatanu1/zyppi-APP`; base branch **`Development`**.

## Read first
- `docs/PLAN.md` — the approved plan. Work only on the phase named in the prompt; stop at its "Done when" checks.
- `docs/UI_GUIDE.md` — how to build the v2 UI. **For any UI work, the PNGs in `docs/screens/light` and `docs/screens/dark` are the visual target; match them.**
- `docs/design-tokens.md` — colors, fonts, radii, sizes.
- `docs/mockups/*.dc.html` — screen designs (HTML). Match layout, hierarchy and spacing; ignore the `x-dc` / `support.js` wrapper. PLAN.md §3 maps each screen to existing code.

## Commands
- Always `fvm flutter …` / `fvm dart …`, never a global `flutter`.
- After every change: `fvm dart format .` → `fvm flutter analyze` (0 issues) → `fvm flutter test`.
- After editing freezed / json / riverpod-annotated files: `fvm dart run build_runner build -d`.
- Backend (`functions/`): `npm --prefix functions run build`, then `npm --prefix functions test` (runs the Auth + Firestore emulators; needs Java 21+). Local backend for the app: `firebase emulators:start`, seed with `FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 FIREBASE_STORAGE_EMULATOR_HOST=127.0.0.1:9199 npm --prefix functions run seed`, run the app with `"USE_FIREBASE_EMULATOR": true` in `env/dev.json`.
- Run: `fvm flutter run --flavor dev --dart-define-from-file=env/dev.json` (flavors exist from Phase 1; before that drop `--flavor`). Android Studio: use the checked-in "dev"/"staging"/"prod" run configurations (`.idea/runConfigurations/`) instead of the default flavorless one, which fails to produce an APK on this flavored project.

## Code rules
- This is an existing codebase: extend and refactor it; don't rewrite screens from scratch unless PLAN.md says the screen is missing.
- Dart package name is `zippy` (imports `package:zippy/...`) — do not change. Android application id / iOS bundle id is `com.zyppi.one` (changed from `com.betastechnologies.zippy` 2026-10-17, before any Play Store submission; register this id as the one in Play Console and Firebase).
- Feature-first layout per PLAN.md §4; new files snake_case.
- Riverpod 3 with codegen; freezed 3 for state and models.
- Screens read data only through repository interfaces — never call Firestore, Cloud Functions, Firebase Auth or `assets/mock` from a widget.
- Orders, payments, stock and order status are written only by Cloud Functions; the app never writes `orders`, `paymentIntents` or `inventory`.
- Money = `int` paise, formatted only in the UI.
- No literal colors/font sizes/radii in widgets — use `context.z.*`, `Theme.of(context).textTheme.*`, `ZRadius`, `ZSpace`, `ZSize`.
- Reuse `lib/core/widgets` (ZProductCard, ZAddStepper, ZCategoryTile, ZCartBar, ZNavBar, ZSearchBar, ZSectionHeader, ZEntrance, ZPressable, ZLoop, ZSkeleton) before writing new UI.
- Every screen must look right in both light and dark theme; animations must respect `MediaQuery.disableAnimationsOf`.
- Every async screen: loading (skeleton), empty, error + retry, data.
- User-facing strings via easy_localization; add every new key to all 4 files in `assets/translations/` (en-UK, bn-BN, hi-IN, pa-Guru).
- Commit generated `*.g.dart` / `*.freezed.dart`.

## Secrets
- `env/*.json` is gitignored; only `env/*.example.json` is committed.
- No API keys in Dart source. The Google Maps key moves out of `lib/core/constants/googleApiKey.dart` in Phase 0.
- Only the Firebase client config (google-services.json / GoogleService-Info.plist) may be in the app; PhonePe and Places keys live only in Cloud Functions secrets (`firebase functions:secrets:set`).

## Git
- One branch per phase from `Development` (names in PLAN.md §5); PRs target `Development`.
- Small Conventional Commits (`feat:`, `fix:`, `chore:`, `refactor:`, `test:`, `docs:`). Do not push or open PRs unless asked.

## Ask before
- Adding a package not in PLAN.md §2, or removing one other than those PLAN.md lists.
- Changes to `firestore.rules`, `storage.rules` or the Firestore data model (collections / field names shared with `functions/` and `zyppi-admin`).
- Anything that deletes user data or changes Firebase project settings, or any `firebase deploy`.
