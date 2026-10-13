# Zyppi — Claude Code handover guide

## 1. What's in this pack

| Path (repo root) | Purpose |
| --- | --- |
| `CLAUDE.md` | Rules Claude Code loads automatically every session |
| `.claude/commands/phase.md` | Slash command: `/phase 0` … `/phase 5` runs one phase of the plan |
| `docs/PLAN.md` | The approved plan: stack, architecture, phases, decisions |
| `docs/design-tokens.md` | Colors, fonts, radii, sizes from the mockup |
| `docs/mockups/*.dc.html` | 14 screen designs (HTML) + `README.md` mapping them to routes |
| `docs/HANDOVER.md` | This guide |
| `env/dev.example.json` | Env template (copy to `env/dev.json`, which stays gitignored) |

## 2. One-time setup on your machine

1. Install tools: Git, Android Studio (SDK + emulator), Xcode (for iOS, macOS only), Node 18+, [FVM](https://fvm.app), [Supabase CLI](https://supabase.com/docs/guides/cli), Claude Code.
2. Put the pack in the repo:
   ```bash
   git clone git@github.com:paulatanu1/zyppi.git && cd zyppi
   # either apply the patch …
   git checkout -b docs/claude-code-handover
   git am /path/to/0001-docs-add-Claude-Code-handover-pack.patch
   # … or unzip zyppi-handover.zip at the repo root and commit
   git push -u origin docs/claude-code-handover   # then merge to main
   ```
3. Create your local env file (not committed):
   ```bash
   cp env/dev.example.json env/dev.json
   # paste the Supabase publishable key into SUPABASE_ANON_KEY
   ```
   `env/*.json` is already gitignored by this pack (only `*.example.json` is committed).
4. Supabase dashboard (project `dcgjsspymailbciqkhvq`): Auth → Providers → Phone → enable, and add 2–3 **test phone numbers with fixed OTPs** for development.

## 3. Run the phases

Open Claude Code in the repo root (`claude`) on `main` after the pack is merged. Run one phase per session and review before the next.

| Step | In Claude Code | You check before moving on |
| --- | --- | --- |
| Phase 0 | `/phase 0` | App runs on emulator/simulator; `fvm flutter analyze` clean; merge branch |
| Phase 1 | `/phase 1` | Tabbed shell runs per flavor; theme matches tokens; CI green |
| Phase 2 | `/phase 2` — also drag in screenshots of the mockup screens | **Gate:** install the release APK on a phone and walk splash → tracking |
| Phase 3 | `npx skills add supabase/agent-skills`, then `/phase 3` | Migrations reviewed; RLS policies reviewed; real order on staging |
| Phase 4 | `/phase 4` | Razorpay test payment, push, live tracking; MSG91 + DLT ready |
| Phase 5 | `/phase 5` | Internal tracks on Play Console + TestFlight |

If you prefer plain prompts over the slash command: *"Execute Phase N from docs/PLAN.md. Follow CLAUDE.md. Stop when the Done-when checks pass."*

Tips:
- Start each phase in a fresh session; Claude Code re-reads `CLAUDE.md` and the plan.
- Use plan mode (Shift+Tab) for Phases 2 and 3 to review the approach before code is written.
- When Claude Code asks about a package not in the plan, decide and, if yes, add it to PLAN.md §2.
- After a phase merges, tick its boxes in `docs/PLAN.md` so the next session sees progress.

## 4. Things only you can do

| When | Task |
| --- | --- |
| Before Phase 3 | Confirm the Supabase project is on the plan tier you want; create a prod project before release |
| Before Phase 4 | Razorpay account (test keys → `env/dev.json`), Google Maps API key, Firebase project for FCM + Crashlytics (add `google-services.json` / `GoogleService-Info.plist`) |
| Before Phase 4 | MSG91 account and **DLT** registration (sender ID + OTP template) — takes a few days |
| Before Phase 5 | Play Console + Apple Developer accounts, signing keys, store listings |
| Any time | Logo and brand assets to replace the placeholder green/yellow brand |
