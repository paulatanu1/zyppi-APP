# Zyppi — rules for Claude Code

Zyppi is a grocery delivery customer app: Flutter (FVM-pinned 3.47.x) + Supabase.

## Read first
- `docs/PLAN.md` — the approved plan. Work only on the phase named in the prompt; stop at its "Done when" checks.
- `docs/design-tokens.md` — every color, font, radius and size.
- `docs/mockups/*.dc.html` — screen designs (HTML). Match layout, hierarchy and spacing; ignore the `x-dc` / `support.js` wrapper.

## Commands
- Always `fvm flutter …` / `fvm dart …`, never a global `flutter`.
- After every change: `fvm dart format .` → `fvm flutter analyze` (must be 0 issues) → `fvm flutter test`.
- After editing freezed / json / riverpod-annotated files: `fvm dart run build_runner build -d`.
- Run a flavor: `fvm flutter run --flavor dev --dart-define-from-file=env/dev.json`.

## Code rules
- Feature-first layout from PLAN.md §4; features import only `core/` and themselves.
- Riverpod 3 with codegen (`@riverpod`); no `setState` beyond purely local UI state.
- Screens talk to repository interfaces only — never call Supabase or read `assets/mock` from a widget.
- Money = `int` paise. Format with the core money formatter only at the UI edge.
- No literal colors, font sizes or radii in widgets — use `core/theme` tokens.
- Every async screen handles loading (skeleton), empty, error + retry, and data.
- Commit generated `*.g.dart` / `*.freezed.dart`.

## Secrets
- `env/*.json` is gitignored; only `env/*.example.json` is committed.
- Only the Supabase publishable/anon key may appear in app config. The service-role/secret key lives only in Supabase Edge Function secrets.
- Never print keys in logs or commit them.

## Git
- One branch per phase (names in PLAN.md). Small Conventional Commits (`feat:`, `fix:`, `chore:`, `refactor:`, `test:`, `docs:`).
- Do not push or open PRs unless asked.

## Ask before
- Adding a package not listed in PLAN.md §2.
- Changing the database schema outside a migration in `supabase/migrations/`.
- Anything that deletes user data or changes Supabase project settings.
