# Production checklist (admin plan A0–A9)

Sign off each box before launch. Project `zippy-app-2024`, region `asia-south1`.
Commands run from `zyppi-APP` unless they say `zyppi-delivery-admin`.
Nothing here is done automatically: every step changes production.

## 1. Deploy the backend

Release 2 of the audit fixes (branch `feat/audit-p1`, on top of release 1 `fix/audit-p0`):
customer cancel, trip pay / failed-delivery return, seller "can't fulfil", weekly rider
settlement, rider trips + tighter rules, tracking TTL, rate limits, PayU hash narrowing, ETA
with packing time, service-area cache, admin CSP. If release 1 is already live, steps 1–2
below are only needed for this release's admin changes. Order matters:

1. [ ] Run the emulator suite once on a dev machine: `npm --prefix functions test`.
2. [ ] Deploy the admin panel first (`zyppi-delivery-admin`): rider payouts now send a one-time
       `requestId`, which the new backend requires for manual payouts. The hosting deploy runs
       `scripts/check-csp.mjs` and stops if the build's inline scripts aren't in the CSP.
3. [ ] Backfill rider trips **before** the rules change, so riders' History keeps old orders:
       `npm --prefix functions run backfill-rider-trips -- --project zippy-app-2024 --write`
4. [ ] `firebase deploy --only functions,firestore:indexes` (the deploy asks to delete the unused
       `adminListUsers`: yes).
5. [ ] Release the rider app (History reads `riders/{uid}/trips`; "I'm back at the store"), the
       seller app ("Can't fulfil this order") and the customer app ("Cancel order").
6. [ ] Once most riders are on the new rider app: `firebase deploy --only firestore:rules`
       (riders read an order only while they hold it and 2 h after; customers can't read
       `config/riders`; address field allow-list).
- [ ] Indexes finished building (Firebase console → Firestore → Indexes: none "Building").
- [ ] Stats backfill re-run after the deploy, at a quiet time:
      `npm --prefix functions run backfill-stats -- --project zippy-app-2024 --write`

## 2. Store settings (admin → Store settings)

- [ ] **Delivery pricing** saved. Without `config/delivery`, delivery is free with no minimum.
- [ ] **Service areas** (Purulia, Raghunathpur, Chelyama): real dark-store centres and radii.
- [ ] **Stores**: area, phone and opening hours. A store outside its hours takes no orders.
- [ ] **Delivery slots** in the order checkout should show.
- [ ] **App & support**: support phone, WhatsApp, email.

## 3. Services & switches (super admin → Services & switches)

- [ ] PayU in PRODUCTION mode (functions `PAYU_ENV`), UPI and card on.
- [ ] Places search, support bot and phone OTP on, or deliberately off for cost.
- [ ] Maintenance off. `minAppVersion` empty, or the version currently on Play.

## 4. App Check (rolls out in monitor mode)

1. [ ] Android app: Firebase console → App Check → Apps → Android → **Play Integrity**.
       Add the **Play app signing** SHA-256 (Play Console → App integrity) to the
       Android app in Project settings, and link the Play Console app to this
       Google Cloud project.
2. [ ] Admin web app: App Check → Apps → Web → **reCAPTCHA Enterprise** → create a key
       for `zyppi-admin.web.app` (add `localhost` only if needed). Put the site key in
       `zyppi-delivery-admin/src/environments/environment.base.ts` → `appCheckSiteKey`,
       then rebuild and redeploy the admin.
3. [ ] Debug builds: run the dev app or `npm start` once, copy the debug token from
       logcat or the browser console, and add it under App Check → Apps → ⋮ → Manage debug tokens.
4. [ ] Release the new app build to Play (it sends App Check tokens).
5. [ ] Watch App Check → APIs → Cloud Functions / Firestore metrics, and Logs Explorer for
       `Callable without App Check` (each line says `caller: app` or `caller: web`).
6. [ ] **Apps first** (customer, rider and seller apps all register Play Integrity — do step 1 for
       `com.zyppi.delivery` and the seller app too): when `caller: app` lines are only very old
       installs, set `APP_CHECK_ENFORCE=true` in `functions/.env.zippy-app-2024` and redeploy
       functions. Raise `minAppVersion` so installs without App Check get the update screen.
7. [ ] **Web second**, only after step 2 is live (the admin panel and its rider sign-up portal
       send no App Check token without the site key, so enforcing earlier locks staff out):
       `APP_CHECK_ENFORCE_WEB=true`, redeploy functions.
8. [ ] Last: App Check → APIs → Cloud Firestore and Storage → **Enforce** (this covers the admin
       panel's direct reads too, so only after step 7 works).

## 4b. Staging project (so tests never touch production data)

Today dev, staging and prod builds all use `zippy-app-2024`. Billable: a second Blaze project
(usually pennies at test volume) — your call.

1. [ ] Create the project (e.g. `zyppi-staging`) in asia-south1; enable Auth (phone, Google),
       Firestore, Storage, Functions (Blaze), App Check.
2. [ ] `firebase use --add` → alias `staging` (adds it to `.firebaserc`).
3. [ ] Register the three Android apps in it; put each app's staging `google-services.json`
       in `android/app/src/staging/` (the Gradle plugin picks the flavor's file over
       `android/app/google-services.json`). Same for `dev` in `android/app/src/dev/` if dev
       should use staging too.
4. [ ] `functions/.env.<staging-project-id>` from `functions/.env.zippy-app-2024`, with
       `PAYU_ENV=test`; set the PayU test secrets with
       `firebase functions:secrets:set ... --project staging`.
5. [ ] Deploy everything with `--project staging`, seed it
       (`npm --prefix functions run seed -- --project <staging-project-id>`), and point
       `env/staging.json` / the admin's staging environment at it.

## 5. Admin on Firebase Hosting

1. [ ] `firebase hosting:sites:create zyppi-admin` (run in `zyppi-delivery-admin`).
2. [ ] Authentication → Settings → Authorized domains → add `zyppi-admin.web.app`.
3. [ ] `npm run deploy` in `zyppi-delivery-admin` (check, build, `hosting:admin`).
4. [ ] Open https://zyppi-admin.web.app. Check sign in, the dashboard, and
       deep links such as `/orders/<id>` after a reload.
5. [ ] Rider sign-up link for applicants: https://zyppi-admin.web.app/rider.
6. [ ] Retire the old Netlify site, if it's still up.

## 6. Real-phone checks (new release build on Android)

- [ ] **A5:** a scheduled banner appears and expires; an area-only banner shows only in its area.
- [ ] **A6:** a segment push reaches the phone and opens the product.
- [ ] **A7:** a test order shows in the dashboard feed and today's numbers. A Reports
      XLSX export opens and its totals match.
- [ ] **A8:** switch each flag off, then back on, and check the app:
      maintenance · minimum version · phone OTP · Places search · UPI · card · support bot ·
      closed area · announcement · blocked customer · store outside hours.
- [ ] Support: "Talk to a person" reaches the inbox. The reply arrives as a push and in the chat.

## 7. Zyppi Delivery (rider app, repo `zyppi-delivery-app`)

**Backend**: the rider functions, rules and indexes ship with step 1 (`firebase deploy --only functions,firestore:rules,firestore:indexes`).
Customer orders placed **before** that deploy have no delivery code; riders can deliver them without one.

**Admin → Rider settings** (ops), before the first rider goes online:
- [ ] Dispatch: auto-assign on, "look for a rider" (placed / packed), seconds to accept, riders to try, max distance.
- [ ] Pay: default rate (base, per km, min, max), per-area rates if they differ, peak hours, surge.
- [ ] Gig slots: book-ahead days, cancel window, slot times / riders per slot / on-time bonus per area.
- [ ] Safety & cash: ambulance (108), police (112), **accident-team number**, door wait time, cash-in-hand limit
      (riders at the limit get no cash orders; 0 = no limit), trip pay % for orders cancelled after pickup.
- [ ] Store settings → Stores: **packing time** per store (the delivery time customers are promised; default 8 min).
- [ ] Optional: `config/marketplace.autoCancelLateMinutes` (Firestore) — cancel and refund an order a seller
      still hasn't accepted this many minutes after the late alert (0 / unset = ops decides).
- [ ] Store settings → Stores: **pickup latitude / longitude** for each dark store (navigation and dispatch distance; else the area centre is used).

**Firebase / Google**:
- [ ] Android app `com.zyppi.delivery` is registered (done 2026-11-16). Add its **SHA-1 and SHA-256** (debug keystore for dev builds; Play app-signing key for release) in Project settings → needed for Google sign-in and Play Integrity / App Check.
- [ ] App Check → Apps → Zyppi Delivery → Play Integrity (same as the customer app); register the debug token from logcat for dev phones.

**Play Console** (new app listing "Zyppi Delivery"):
- [ ] Release keystore: create one, keep it safe, and fill `android/key.properties` (gitignored) — `storeFile`, `storePassword`, `keyAlias`, `keyPassword`.
- [ ] Build: `fvm flutter build appbundle --flavor prod --release --obfuscate --split-debug-info=build/symbols --dart-define-from-file=env/prod.json` (fill `env/prod.json` from the example: real `SUPPORT_PHONE`, `RIDER_PORTAL_URL`, `PRIVACY_POLICY_URL`).
- [ ] Release builds are obfuscated (class and method names scrambled, so the app is harder to read back). Keep `build/symbols` from each release and upload it so Crashlytics shows readable stack traces: `firebase crashlytics:symbols:upload --app=<Firebase Android app id> build/symbols`.
- [ ] App content → **Foreground service: location** declaration (video of: go online → notification "You're online" → orders while the screen is off). The app never asks for background location.
- [ ] App content → Data safety: precise location (collected while online, for dispatch and customer ETA, not shared for ads), phone number, name.
- [ ] Privacy policy URL that covers rider location.
- [ ] Internal testing track → install on 2 rider phones.

**Phone checks** (2 rider phones + 1 customer phone, after the deploy):
- [ ] Rider signs in (phone OTP), pending rider sees their application status, approved rider lands on Home.
- [ ] Swipe online → location disclosure → permission → "You're online" notification; mock-location app on → refused.
- [ ] Customer places an order → the **nearer** free rider gets the offer with a ring (app open and app closed); reject → the other rider gets it; nobody → Dispatch board "Needs a rider" with a chime.
- [ ] Accept → navigate to store (phone's maps) → reached → checklist → swipe picked up only after ops marks it packed.
- [ ] Customer tracking shows the code and "Rider is x km away"; See on map opens the phone's maps.
- [ ] Swipe arrived → customer push "Your rider is here"; wrong code refused (5 tries max); right code + cash ticked → delivered.
- [ ] Pocket shows order pay + tip; request payout → Admin → Rider payouts → record with UTR → Pocket shows it paid.
- [ ] Book a slot → online in it → dispatch priority + on-time bonus; incentive target reached → paid after midnight.
- [ ] Emergency → each button dials; Dispatch board shows the SOS with the rider's location and alarm; resolve.
- [ ] Can't deliver → reason ("customer unreachable" only after the door wait) → Dispatch board shows the
      issue; at the store, "I'm back at the store" cancels the order, refunds and pays the trip.
- [ ] Customer cancels a placed order from tracking → stock back, refund recorded (Payments), seller told.
- [ ] Seller taps "Can't fulfil this order" on a new order → order cancelled and refunded.
- [ ] Monday 06:00: weekly rider settlement opens payout requests (Rider payouts).
- [ ] Message riders from Dispatch → push + Messages in the app.

## 8. Known limits (accepted for launch)

- No 2-step sign-in for staff: it needs the Identity Platform upgrade, which was declined
  (2026-11-15). Use strong, unique staff passwords and keep the super-admin list short.
- No scheduled Firestore backups (decided 2026-11-15). Reconsider before real order volume:
  `gcloud firestore backups schedules create --database='(default)' --recurrence=daily --retention=14d`.
- `npm run seed:support` replaces the whole knowledge base. Don't run it after the KB editor is in use.
- Customer name search matches from the start of the name only.
- Rider app v2 (not built): batching 2 orders per trip, an in-app map, instant withdrawals (needs a paid payout API), masked calling, document-expiry reminders.
- Riders' location stops if Android kills the app (aggressive battery savers on some phones): the server marks them offline after 10 minutes without a ping. Ask riders to exempt Zyppi Delivery from battery optimisation.
- Admin CSP allows inline styles (ng-zorro needs them); inline scripts are pinned by hash.
- A seller who can't fulfil (or is too late, when auto-cancel is on) cancels the whole order: lines
  aren't moved to another seller, the customer re-orders.
- Stock held for a PayU payment is released 15–25 min after an unpaid start; a later capture still
  becomes an order if stock allows, else goes to review.
