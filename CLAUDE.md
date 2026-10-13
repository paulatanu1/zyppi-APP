# Zyppi — rules for Claude Code

Zyppi is a quick-commerce grocery customer app (Flutter, FVM-pinned 3.47.x) moving to a Supabase backend. Repo `paulatanu1/zyppi-APP`; base branch **`Development`**.

## Read first
- `docs/PLAN.md` — the approved plan. Work only on the phase named in the prompt; stop at its "Done when" checks.
- `docs/design-tokens.md` — colors, fonts, radii, sizes.
- `docs/mockups/*.dc.html` — screen designs (HTML). Match layout, hierarchy and spacing; ignore the `x-dc` / `support.js` wrapper. PLAN.md §3 maps each screen to existing code.

## Commands
- Always `fvm flutter …` / `fvm dart …`, never a global `flutter`.
- After every change: `fvm dart format .` → `fvm flutter analyze` (0 issues) → `fvm flutter test`.
- After editing freezed / json / riverpod-annotated files: `fvm dart run build_runner build -d`.
- Run: `fvm flutter run --flavor dev --dart-define-from-file=env/dev.json` (flavors exist from Phase 1; before that drop `--flavor`).

## Code rules
- This is an existing codebase: extend and refactor it; don't rewrite screens from scratch unless PLAN.md says the screen is missing.
- Dart package name is `zippy` (imports `package:zippy/...`); Android id `com.betastechnologies.zippy` — do not change either.
- Feature-first layout per PLAN.md §4; new files snake_case.
- Riverpod 3 with codegen; freezed 3 for state and models.
- Screens read data only through repository interfaces — never call Supabase, dio or `assets/mock` from a widget.
- Money = `int` paise, formatted only in the UI.
- No literal colors/font sizes/radii in widgets — use `core/theme` tokens.
- Every async screen: loading (skeleton), empty, error + retry, data.
- User-facing strings via easy_localization; add every new key to all 4 files in `assets/translations/` (en-UK, bn-BN, hi-IN, pa-Guru).
- Commit generated `*.g.dart` / `*.freezed.dart`.

## Secrets
- `env/*.json` is gitignored; only `env/*.example.json` is committed.
- No API keys in Dart source. The Google Maps key moves out of `lib/core/constants/googleApiKey.dart` in Phase 0.
- Only the Supabase publishable/anon key may be in the app; service-role/secret keys live only in Edge Function secrets.

## Git
- One branch per phase from `Development` (names in PLAN.md §5); PRs target `Development`.
- Small Conventional Commits (`feat:`, `fix:`, `chore:`, `refactor:`, `test:`, `docs:`). Do not push or open PRs unless asked.

## Ask before
- Adding a package not in PLAN.md §2, or removing one other than those PLAN.md lists.
- Schema changes outside `supabase/migrations/`.
- Anything that deletes user data or changes Supabase / Firebase project settings.
