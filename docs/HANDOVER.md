# Zyppi — Claude Code handover guide

## 1. What's in this pack

| Path (repo root) | Purpose |
| --- | --- |
| `CLAUDE.md` | Rules Claude Code loads automatically every session |
| `.claude/commands/phase.md` | Slash command: `/phase 0` … `/phase 5` runs one phase of the plan |
| `docs/PLAN.md` | Approved plan: audit of the existing app, stack, architecture, phases, decisions |
| `docs/design-tokens.md` | Colors, fonts, radii, sizes (existing Zyppi brand) |
| `docs/mockups/*.dc.html` | 14 screen designs (HTML) + `README.md` |
| `docs/HANDOVER.md` | This guide |
| `env/dev.example.json` | Env template → copy to `env/dev.json` (gitignored) |
| `.gitignore` | Adds `.fvm/` and `env/*.json` (keeps `*.example.json`) |

## 2. Do this first (today)

The repo is public and `lib/core/constants/googleApiKey.dart` contains a Google Maps API key, so it is readable in git history. In Google Cloud Console → APIs & Services → Credentials, restrict that key (Android: package `com.betastechnologies.zippy` + SHA-1; iOS: bundle id; limit to the Maps/Places APIs) or delete it and create a new one. Then set the repo back to private if you want. Phase 0 moves the key out of source.

## 3. One-time setup

1. Tools: Git, Android Studio (SDK + emulator), Xcode + CocoaPods, Node 22, Java 21+ (for the Firebase emulators; Android Studio's bundled JBR works), [FVM](https://fvm.app), [Firebase CLI](https://firebase.google.com/docs/cli) (`firebase login`), Claude Code.
2. Add the pack on top of `Development`:
   ```bash
   git clone git@github.com:paulatanu1/zyppi-APP.git && cd zyppi-APP
   git checkout Development
   git checkout -b docs/claude-code-handover
   git am /path/to/0001-docs-add-Claude-Code-handover-pack.patch
   #   (or unzip zyppi-APP-handover.zip at the repo root and commit)
   git push -u origin docs/claude-code-handover
   # open a PR into Development and merge it
   ```
3. Local env (not committed):
   ```bash
   cp env/dev.example.json env/dev.json
   # set DATA_SOURCE to "firebase" (or keep "mock"); USE_FIREBASE_EMULATOR=true for a local backend
   ```
4. Firebase console (project `zippy-app-2024`, Blaze plan):
   - Firestore (region `asia-south1`) and Storage enabled.
   - Authentication → Sign-in method: Phone (add 2–3 test numbers with fixed codes), Google, Anonymous, Email/Password (admin logins).
   - Project settings → Android app `com.zyppi.one`: add the debug and release SHA-1 and SHA-256 fingerprints. iOS app `com.zyppi.one`: upload the APNs key.
   - Secrets: `firebase functions:secrets:set PHONEPE_CLIENT_ID` (and `PHONEPE_CLIENT_SECRET`, `PHONEPE_CLIENT_VERSION`, `PHONEPE_MERCHANT_ID`, `GOOGLE_PLACES_API_KEY`).
   - Deploy: `firebase deploy --only firestore,storage,functions`; seed: `gcloud auth application-default login && npm --prefix functions run seed -- --project zippy-app-2024`.
   - Admin: create an Email/Password user in the console, then `npm --prefix functions run set-admin -- <email> --project zippy-app-2024`.

## 4. Run the phases

Open Claude Code at the repo root (`claude`) on an up-to-date `Development`. One phase per session; review before the next.

| Step | In Claude Code | You check before moving on |
| --- | --- | --- |
| Phase 0 | `/phase 0` | All existing screens still open; analyze clean; runs on Android + iOS. Merge to `Development` (and `main`) |
| Phase 1 | `/phase 1` | Rename pass compiles; theme matches tokens; flavors boot; CI green |
| Phase 2 | `/phase 2` + drag in screenshots of the mockup screens | **Gate:** install the release APK on a phone and walk splash → tracking |
| Phase 3 | `npx skills add supabase/agent-skills`, then `/phase 3` | Review migrations + RLS policies; real order on staging |
| Phase 4 | `/phase 4` | Razorpay test payment, push, live tracking; MSG91 + DLT ready |
| Phase 5 | `/phase 5` | Internal tracks on Play Console + TestFlight |
| Phase 6 | Firebase migration (done on `feat/firebase-migration`) | Console setup + deploy above; OTP/Google/guest sign-in, COD order, live status + push on a real phone |

Plain prompt alternative: *"Execute Phase N from docs/PLAN.md on a branch from Development. Follow CLAUDE.md. Stop when the Done-when checks pass."*

Tips: fresh session per phase · use plan mode (Shift+Tab) for Phases 1–3 · tick boxes in `docs/PLAN.md` after each merge · tell your teammates (axelrod69, swagatapal) to pull `Development` after the Phase 1 rename commit, since it touches most file paths.

## 5. Things only you can do

| When | Task |
| --- | --- |
| Now | Restrict/rotate the Google Maps key; restrict the API keys in the committed Firebase config files |
| Before Phase 6 | Firebase Blaze plan; console setup in §3 step 4 (Supabase is retired) |
| Before Phase 4 | Razorpay account (test keys → `env/dev.json`); Firebase Cloud Messaging + Crashlytics on the existing Firebase project |
| Before Phase 4 | MSG91 account + **DLT** registration (sender ID, OTP template) — takes a few days |
| Before Phase 5 | Play Console + Apple Developer accounts, signing keys, store listings |
