# Production checklist (admin plan A0–A9)

Sign off each box before launch. Project `zippy-app-2024`, region `asia-south1`.
Commands run from `zyppi-APP` unless they say `zyppi-delivery-admin`.
Nothing here is done automatically: every step changes production.

## 1. Deploy the backend

- [ ] `firebase deploy --only functions,firestore:rules,firestore:indexes`
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
       `Callable without App Check`. When unverified calls are only very old installs:
       - set `APP_CHECK_ENFORCE=true` in `functions/.env.zippy-app-2024` and redeploy functions;
       - App Check → APIs → Cloud Firestore and Storage → **Enforce**.
       Also raise `minAppVersion` so installs without App Check get the update screen.

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

## 7. Known limits (accepted for launch)

- No 2-step sign-in for staff: it needs the Identity Platform upgrade, which was declined
  (2026-11-15). Use strong, unique staff passwords and keep the super-admin list short.
- No scheduled Firestore backups (decided 2026-11-15). Reconsider before real order volume:
  `gcloud firestore backups schedules create --database='(default)' --recurrence=daily --retention=14d`.
- `npm run seed:support` replaces the whole knowledge base. Don't run it after the KB editor is in use.
- Customer name search matches from the start of the name only.
- No Content-Security-Policy header on the admin yet (other security headers are set in `firebase.json`).
