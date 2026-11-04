# Zyppi Grocery App — Upgrade & Development Plan

Approved plan for Claude Code. Repo: `paulatanu1/zyppi-APP`, base branch **`Development`**. Last updated 3 Nov 2026 (backend moved from Supabase to Firebase — Phase 6).

## 1. Summary and audit

The app already exists on `Development` (65 commits, Nov 2024 – Feb 2025): 17 feature screens on Riverpod, freezed and go_router, Firebase + Google sign-in, easy_localization in 4 languages. It runs on Flutter 3.24.3 and talks to an old REST backend over plain HTTP. The plan upgrades it in place, moves data and auth to Supabase (Phases 3–4; replaced by Firebase in Phase 6), builds the missing grocery flow (product search, checkout, order placed, order tracking) and restyles screens to the approved mockup.

| Area | Current state (`Development` @ 2cfeb0c, 3 Feb 2025) | Action |
| --- | --- | --- |
| Branches | `main` has only the initial commit | Branch each phase from `Development`; merge to `main` after Phase 0 |
| Flutter / Dart | Flutter 3.24.3; `sdk: 3.6.0` pinned exactly | FVM 3.47.x; `sdk: ^3.13.0` |
| State / models | Riverpod 2.6 + generator; freezed 2; `freezed_annotation` wrongly in dev_dependencies | Riverpod 3; freezed 3 (`abstract`/`sealed` classes); move annotation to dependencies |
| Backend | `dio` → `http://13.233.47.211:2015/api/v1/` (`lib/core/infrastructure/`) for login, Google login, add address | Replace with Supabase; delete dio + `core/infrastructure/` after migration |
| Auth | REST phone login, `firebase_auth`, `google_sign_in` 6 | Supabase Auth: phone OTP + Google via `signInWithIdToken` |
| Secrets | Google Maps key hard-coded in `lib/core/constants/googleApiKey.dart`; `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist` committed | Restrict/rotate the Maps key; read it from env; restrict Firebase API keys in Google Cloud |
| Android | Groovy DSL, AGP 8.7.2, Kotlin 2.0.0, Gradle 8.9, `compileSdk 34`, `minSdk 23` | Bump AGP/Kotlin/Gradle; `compileSdk = flutter.compileSdkVersion`; `minSdk 24` |
| App id / package | `com.betastechnologies.zippy`; Dart package `zippy` | Keep Dart package `zippy`; Android/iOS id changed to `com.zyppi.one` (2026-10-17, pre-submission) |
| UI | `flutter_screenutil` with swapped MediaQuery design size; Poppins, Montserrat + 3 unused fonts; colors in `core/constants/colors.dart`; curved 5-tab nav | Design size 390×844; tokens from `docs/design-tokens.md`; drop unused fonts |
| Localization | `easy_localization`: `assets/translations/{en-UK,bn-BN,hi-IN,pa-Guru}.json` | Keep |
| Code style | PascalCase folders, camelCase files; `otp_text_field` + `flutter_otp_text_field`; `flutter_lints` mis-indented under `flutter_launcher_icons` (lints off) | snake_case rename pass; one OTP package; lints on |
| Root routing | `ref.listen` in root widget calls `context.goNamed` (context is above the router) | go_router `redirect` + `refreshListenable` |
| Tests | template only | Real tests from Phase 2 |

## 2. Target stack

Flutter **3.47.x stable** (Dart 3.13) pinned with **FVM** (`.fvmrc`). Upgrade with `fvm flutter pub upgrade --major-versions`; add new packages with `fvm flutter pub add`.

| Concern | Now | Target | Phase |
| --- | --- | --- | --- |
| State | `flutter_riverpod` 2.6, `riverpod_annotation`, `riverpod_generator` | Riverpod 3 + `riverpod_lint`, `custom_lint` | 0 |
| Routing | `go_router` 14 | latest | 0 |
| Models | `freezed` 2, `json_serializable` | `freezed` 3, latest | 0 |
| Backend | `dio` + REST | `cloud_firestore`, `cloud_functions`; Firebase CLI + Cloud Functions (TypeScript, `functions/`). Was `supabase_flutter` in Phases 3–5 | 6 |
| Auth | `firebase_auth`, `google_sign_in` 6 | `firebase_auth` (phone OTP, Google, anonymous guest + linking); `google_sign_in` latest for the ID token. Was Supabase Auth in Phases 3–5 | 6 |
| Local storage | `shared_preferences` | + `hive_ce`, `hive_ce_flutter` (cart, recent searches) | 2 |
| UI kit | `flutter_screenutil`, `carousel_slider`, `smooth_page_indicator`, `curved_navigation_bar`, `flutter_bounce`, `fluttertoast` | Keep first four; SnackBar instead of `fluttertoast`; add `cached_network_image`, `skeletonizer` | 1–2 |
| OTP input | `otp_text_field` + `flutter_otp_text_field` | `flutter_otp_text_field` only | 1 |
| Localization | `easy_localization` | latest | 0 |
| Location / maps | `geolocator`, `google_places_flutter` (client key) | `geolocator`, `geocoding`; Places API (New) via the `placesProxy` Cloud Function. `google_maps_flutter` was added in Phase 4 then removed (2026-10-26): delivery here only needs `lat`/`lng` for the rider to navigate externally, not an embedded map in the customer app — see decisions table | 4 |
| Push / crash / analytics | `firebase_core` | + `firebase_messaging`, `firebase_crashlytics`, `firebase_analytics` | 4–5 |
| Payments | — | `phonepe_payment_sdk` (Standard Checkout) + COD | 4 |
| Testing | `flutter_test` | + `mocktail`, `integration_test` | all |
| Release assets | `flutter_launcher_icons` | + `flutter_native_splash` | 5 |

Environments: dev / staging / prod via `--dart-define-from-file=env/<flavor>.json` + Android product flavors + iOS schemes. Only `env/*.example.json` is committed.

## 3. Product scope (MVP = customer app)

Launch areas **Purulia, Raghunathpur, Chelyama**. INR. Languages en, bn, hi, pa. Existing 5-tab nav stays: **Home, Explore, Cart, Favourite, Account** (Orders under Account). Rider app and admin panel later.

| # | Screen | Existing code (`lib/features/`) | Status | Mockup (`docs/mockups/`) |
| --- | --- | --- | --- | --- |
| 1 | Splash / onboarding | `Intro/` | Exists — restructured (2026-10-28) from a 4-slide carousel to a single screen per the v2 mockup | `Onboarding.dc.html` |
| 2 | Login | `Auth/Login/`, `core/commonWidgets/googleSignInButton.dart` | Exists (REST) | `Login.dc.html` |
| 3 | OTP verify | `Auth/OTPVerification/` | Exists (REST) | `Otp.dc.html` |
| 4 | Location setup | `SearchAddress/`, `HomeScreen/widgets/addressSheet.dart`, `core/sharedProviders/Location/` | Partial | `Location.dc.html` |
| 5 | Home | `HomeScreen/` | Exists | `Main.dc.html` |
| 6 | Explore / category / filter | `Explore/`, `CategoryDetails/`, `Filter/` | Exists | `Category.dc.html` |
| 7 | Product detail | `ProductDetails/` | Exists | `Product.dc.html` |
| 8 | Product search | search bar widget only | **Missing** | `Search.dc.html` |
| 9 | Cart | `MyCart/` | Exists | `Cart.dc.html` |
| 10 | Checkout | — | **Missing** | `Checkout.dc.html` |
| 11 | Order placed | — | **Missing** | `Placed.dc.html` |
| 12 | Order tracking | — | **Missing** | `Tracking.dc.html` |
| 13 | Orders history | `YourOrder/` | Exists | `Orders.dc.html` |
| 14 | Account | `Account/`, `EditProfile/` | Exists | `Profile.dc.html` |
| 15 | Addresses | `MyAddress/` | Exists | restyle from `Location.dc.html` |
| 16 | Favourites | `Favourite/` | Exists | restyle from `Category.dc.html` grid |

Out of scope for MVP: subscriptions, wallet, referrals, multi-store marketplace, rider chat.

## 4. Architecture

Keep the existing feature-first layout; add a `data/` layer so every screen reads through a repository interface. Phase 2 runs on mock JSON; Phase 3 switches to Supabase by changing provider overrides.

```
presentation (screens, widgets)
      ↓
application (Riverpod notifiers + freezed state)
      ↓
domain (entities + repository interfaces)   ← swap point
      ↓                        ↓
data/mock (assets/mock)   data/firebase_* (cloud_firestore, cloud_functions)
```

Target layout after the Phase 1 rename pass:

```text
lib/
  main.dart                  # flavor → bootstrap()
  bootstrap.dart             # EasyLocalization, Firebase (+ emulators), ProviderScope
  app/
    app.dart                 # MaterialApp.router, theme, ScreenUtilInit(390x844)
    router.dart              # go_router + redirect/refreshListenable (onboarding, auth, location)
  core/
    config/env.dart          # String.fromEnvironment(...)
    theme/                   # tokens from docs/design-tokens.md (replaces constants/colors.dart)
    firebase/                # Functions region, emulator setup (firebase_setup.dart)
    storage/                 # shared_preferences, hive boxes
    location/                # from sharedProviders/Location
    utils/  widgets/         # money (paise), formatters; shared widgets (from commonWidgets/)
  features/<feature>/{data,domain,application,presentation,widgets}
    intro auth location home explore category product search cart checkout orders tracking account favourites addresses
assets/mock/                 # categories.json, products.json, orders.json, addresses.json, slots.json, service_areas.json
functions/                   # Cloud Functions (TypeScript), seed + set-admin scripts, emulator tests
firestore.rules  firestore.indexes.json  storage.rules  firebase.json
supabase/                    # legacy (Phases 3–5); delete once Phase 6 is verified end to end
env/                         # *.example.json committed; real files gitignored
```

Conventions: money as `int` paise · theme tokens only · every async screen has loading/empty/error/data · features import only `core/` and themselves · generated files committed · Dart package stays `zippy`.

## 5. Phases

Gates: plan + mockup approved → Phase 0. After Phase 2: prototype reviewed on a phone + Supabase schema agreed. After Phase 5: internal testing tracks.

### Phase 0 — Upgrade the existing app (1–2 days) · `chore/upgrade-flutter-3.47`
- [x] Branch from `Development`
- [x] Restrict/rotate the Google Maps key in git history (Android package + SHA-1, iOS bundle id); move it to `env/*.json`, read via `String.fromEnvironment`; delete `lib/core/constants/googleApiKey.dart`
- [x] FVM: `fvm use 3.47.7` (or newest 3.47.x); commit `.fvmrc`; update README Flutter version
- [x] `environment.sdk: ^3.13.0`; move `freezed_annotation` to dependencies; fix `flutter_lints` placement under dev_dependencies
- [x] `fvm flutter pub upgrade --major-versions`; fix breaking changes: Riverpod 3, freezed 3 (`abstract class`/`sealed class`), google_sign_in, go_router, firebase_*, carousel_slider; `fvm dart run build_runner build -d`
- [x] Android: AGP, Kotlin and Gradle wrapper to the versions the Flutter 3.47 template uses; `compileSdk = flutter.compileSdkVersion`; `minSdk = 24`; keep `applicationId com.betastechnologies.zippy`
- [x] iOS: deployment target 15.0 in Podfile + project; `pod install`
- [x] `ScreenUtilInit(designSize: Size(390, 844))`
- [x] File-level snake_case rename pass (pulled forward from Phase 1) so `flutter_lints`' `file_names` rule is clean; folder casing (PascalCase dirs) stays for Phase 1's full rename

Done when: `fvm flutter analyze` 0 issues, every existing screen still opens, app runs on Android emulator + iOS simulator, `fvm flutter build apk --debug` succeeds.

### Phase 1 — Foundations (3–4 days) · `feat/foundations`
- [x] Rename pass: snake_case files, lowercase folders (one refactor-only commit) — file names were pulled forward into Phase 0; folders done here
- [x] `data/` layer + repository interfaces per feature; notifiers under `application/` — added for the features that already have a provider/application layer (home_screen, explore, product_details, search_address, auth/login, auth/otp_verification, auth/google_sign_in). Screens that are still presentation-only today (cart, account, addresses, orders, favourites, category details) get their entities + mock repositories in Phase 2, per this doc's own Phase 2 checklist
- [x] Theme from `docs/design-tokens.md`, replacing `core/constants/colors.dart`; remove Righteous, Aclonica, AirbnbCereal fonts — `lib/core/theme/{app_colors,app_typography,app_spacing,app_theme}.dart` added; legacy neutrals kept as tokens until Phase 2's per-screen mockup restyle
- [x] Router: `redirect` + `refreshListenable` for onboarding/auth/location; remove `ref.listen` + `context.goNamed` from the root widget — implemented for the existing auth gate; there's no location-gating redirect to migrate yet (none exists today)
- [x] `bootstrap()`, dev/staging/prod flavors, `env/*.example.json`, `Supabase.initialize` from env (skipped in mock mode) — Android flavors done; iOS per-flavor Xcode schemes still needed (flagged, needs Xcode)
- [x] easy_localization stays; every new string in all 4 JSON files — no new user-facing strings added this phase
- [x] Shared widgets aligned to mockup: primary button, quantity stepper, product card, price tag, skeletons; keep one OTP package; SnackBar instead of fluttertoast — new reusable primitives added (PrimaryButton restyled in place, QuantityStepper/PriceTag/AppSkeleton added); existing screens aren't rewired to them yet, that happens during Phase 2's mockup restyle. otp_text_field (unused) removed, fluttertoast replaced with SnackBar
- [x] GitHub Actions: format, analyze, test on PRs to `Development`

Done when: each flavor boots, existing screens use tokens, CI green.

### Phase 2 — Clickable prototype on mock data (1.5–2 weeks) · `feat/prototype`
- [x] freezed entities: Category, Product, ProductVariant, CartItem, Address, DeliverySlot, Coupon, Order, OrderItem, OrderStatus, ServiceArea — all under `lib/core/domain/` (not a single feature's domain) since they're used by multiple features and CLAUDE.md restricts features to importing only `core/` and themselves
- [x] `assets/mock/*.json` (categories, products, addresses, slots, orders, service_areas, coupons) + mock repositories via `MockDataSource` (300–800 ms delay, a `simulateErrors` toggle)
- [x] Build missing screens 8 (search), 10 (checkout), 11 (order placed), 12 (order tracking)
- [x] Restyle existing screens to the mockup — all 16 screens from §3's table: onboarding/slider, login, OTP verify, home, explore, category details, product details, search, cart, checkout, order placed, order tracking, orders history, account/profile, addresses, filter. A few sub-pieces are explicitly deferred to later phases rather than faked: category details' sub-category rail (no sub-category relationship in the catalog data model), filter's brand facet (no brand field), product details' "similar items" row (no recommendation logic), search's recent/trending chips (no search-history persistence), and addresses' map-pin picker (needs `google_maps_flutter`, Phase 4) — that screen is list-only for now.
- [x] Cart in `hive_ce`: steppers, item total, savings, delivery fee, handling fee, tip, coupon — `core/cart/`
- [x] Fake order lifecycle timer: placed → packed → out for delivery → delivered — `OrderTrackingProvider`, 5s/step
- [x] Unit tests for bill math; widget tests for cart and product card — surfaced and fixed a real ItemCard layout overflow bug in the process

Done when: release APK runs splash → tracking fully offline and matches the mockup. The offline golden path (splash → login → otp → home → product → cart → checkout → placed → tracking) works; "matches the mockup" visually is still open.

### Phase 3 — Supabase integration (2–3 weeks) · `feat/supabase-integration`
- [x] `npx skills add supabase/agent-skills`
- [x] Supabase project ref `dcgjsspymailbciqkhvq` = dev; prod project before release; `supabase/` via CLI (migrations, `seed.sql`, functions)
- [x] Schema: profiles, addresses, service_areas, stores, categories, products, product_variants, inventory, carts, cart_items, orders, order_items, order_events, payments, delivery_slots, coupons
- [x] RLS on every table; catalog read-only for clients
- [x] Auth: phone OTP (dev: Supabase test numbers) + Google via `signInWithIdToken`; remove REST login and `firebase_auth`
- [x] `place_order` RPC: re-checks stock, prices, coupon, serviceability in one transaction
- [x] Supabase repositories: catalog, search (Postgres full-text), cart sync, addresses, orders; images in Supabase Storage — flavor-switched on `Env.dataSource` throughout. Search uses a generated `tsvector` column + GIN index (`20261015120300_product_search.sql`) via `textSearch()`, debounced client-side. Cart syncs to `cart_items` (delete-all-then-upsert on every save — no diffing); orders read/placed via `place_order()`. Images: a public `catalog-images` Storage bucket (`20261015120400_catalog_images_storage.sql`, read-only to clients); `categories`/`products.image` holds an object path that `SupabaseCatalogRepository` resolves to a public URL; `CatalogImage` (new shared widget, replacing raw `Image.asset` at all 6 catalog-image call sites) renders that URL via `cached_network_image` or falls back to the mock flavor's bundled asset path. The actual PNGs (`assets/images/*.png`) still need uploading to that bucket once per project — seed.sql only inserts the rows that reference them. Status updates and cross-device cart/order refresh stay client-side mock-only until Phase 4's Realtime tracking
- [x] Delete `dio`, `lib/core/infrastructure/`, old base URL — old REST auth (`Url.login`/`googleSignIn`) and the old REST add-address path are gone: `AddressRepository.addAddress()` now writes to Supabase (Mock keeps it in-memory for the session), and `search_address_screen`'s save flow uses that. Also removed a hardcoded bearer JWT that `header.dart` was sending on that old POST. `dio`/`core/infrastructure/` itself stays — `search_address`'s Places autocomplete and `get_current_location_provider`'s reverse-geocode still call Google's API directly with the client Maps key; PLAN.md's own Phase 4 ("Places autocomplete through an Edge Function") owns retiring that, so full deletion waits until then
- [x] Only the publishable/anon key in the app; service-role key only in Edge Functions
- [x] Flavor-based provider overrides; mock flavor still works

Done when: staging flavor places a real order end to end; mock flavor still runs. ✅ Done — four Phase 3 bugs blocking staging checkout end to end were fixed (see `5e8496c`); mock flavor still runs offline.

### Phase 4 — Delivery features (~2 weeks) · `feat/delivery-features`
- [x] Location: permission, current position, reverse geocode, serviceability vs `service_areas`; Places autocomplete through an Edge Function (no client Maps key for Places) — `search_address_screen.dart` resolves a location via GPS (`geolocator`) or place search (reverse-geocoded via the `geocoding` package, the OS's own geocoder — no API key needed), with editable address-line/landmark text instead of a dragged map pin; "use current location" button; serviceability banner; saved-addresses quick-pick. This replaced the old REST-era screen that hardcoded every new address's area/city/state/postalCode to Kolkata regardless of what was picked. `serviceable_area()` RPC (haversine vs radius) + a new `ServiceAreaRepository` back the serviceability check against the three launch towns' approximate centers (`20261015120500_service_area_geofence.sql` — refine the coordinates against real dark-store addresses before launch). Places autocomplete/details move behind `supabase/functions/places-proxy`; `dio` and `lib/core/infrastructure/` are now fully deleted (both remaining call sites — geocoding, Places — are gone), closing Phase 3's "full deletion waits until Phase 4" note. Also found and fixed a live Google Maps API key hardcoded in `AndroidManifest.xml`/`AppDelegate.swift` since Phase 0 — it briefly moved to per-flavor `env/<flavor>.json` (Android) / a gitignored `Secrets.xcconfig` (iOS), then **`google_maps_flutter` itself was removed entirely (2026-10-26)**: this is a remote-area delivery app where the rider navigates with their own phone's Maps app from the order's `lat`/`lng`, not an embedded map in the customer app, so there's no client Maps key left to rotate or restrict at all — the leaked key in git history is now moot for the app (it was never used server-side)
- [x] PhonePe (Standard Checkout) order creation + status verification in Edge Functions; COD — the app never had a real Razorpay account, so the original Razorpay integration was replaced (2026-10-26) with PhonePe: `create-phonepe-order` / `verify-phonepe-payment` keep `PHONEPE_CLIENT_SECRET` off the client; the app opens PhonePe's hosted PAY_PAGE via `phonepe_payment_sdk`'s `startTransaction`, then checkout verifies the order's status before ever calling `place_order()`, which now records a real `payments` row (`provider_reference` holds PhonePe's `transactionId`). Mock flavor places every order directly (no gateway to open) — **not yet exercised against a live PhonePe sandbox account**, needs `PHONEPE_CLIENT_ID`/`PHONEPE_CLIENT_SECRET`/`PHONEPE_CLIENT_VERSION`/`PHONEPE_MERCHANT_ID`/`PHONEPE_ENV` as Edge Function secrets (pending from the PhonePe Business Dashboard) and a real device for the SDK's PAY_PAGE redirect flow
- [x] FCM push on `order_events` insert (Edge Function); deep link to tracking — `push-on-order-event` mints its own OAuth2 token from a Firebase service-account secret and sends via FCM v1; a new `on_order_event_notify` trigger calls it via `pg_net` (the same mechanism the dashboard's Database Webhooks UI generates, checked into migrations instead). It no-ops with a warning until two per-project GUCs (`app.settings.edge_functions_url`, `app.settings.service_role_key`) are set — can't be done from inside a migration since they differ per environment. `profiles.fcm_token` + `PushTokenRepository` register the token on refresh and right after login. **Not yet verified on a real device** — also needs the Push Notifications + Background Modes capabilities added in Xcode and APNs configured for iOS (carries forward Phase 1's already-flagged "needs Xcode" gap)
- [x] Live tracking via Supabase Realtime — `orders` joins the `supabase_realtime` publication; `SupabaseOrderRepository.watch()` streams Postgres Changes instead of `Stream.empty()`, and `OrderTrackingProvider` re-reads the order on every event. The tracking screen's map stays decorative-only (already the case since Phase 2) — there's no rider/location data source behind it; that's explicitly out of scope until a rider app exists (§3)
- [x] Express vs scheduled slot picker — `delivery_slots` now seeds four concrete scheduled windows alongside the express one (previously one generic "Schedule for later" row with no actual times); checkout's delivery-time section is the mockup's two-card Express/Schedule toggle, revealing the windows as choice chips. Window labels are static per seed, not date-relative at runtime — same follow-up bucket as §6's "realistic express ETA per town"
- [x] Production SMS: MSG91 through the Supabase Send SMS Hook; DLT sender ID + template — `send-sms-hook` verifies Supabase Auth's `standardwebhooks` signature and sends via MSG91's OTP API with a DLT template id. Registered in `config.toml` but left **disabled**; dev/staging keep Supabase's test phone numbers per §6's own decision, and this only needs flipping on once a real MSG91 account + DLT template + project-ref are in hand

Done when: PhonePe test payment succeeds, background push arrives, tracking map updates. ⚠️ Not yet verified — every piece above is implemented and code-complete (`fvm flutter analyze` 0 issues, tests pass), but all three checks need things this environment doesn't have: a staging `env/*.json` with real Supabase/PhonePe keys, the Edge Functions' secrets set (they are now deployed, to both the dev and prod Supabase projects), the two Postgres GUCs for the push trigger, and a physical device for push/location/payment UI. Treat Phase 4 as code-complete, not verified end-to-end.

### Phase 5 — Release hardening (1–2 weeks) · `chore/release-hardening`
- [x] Integration test for the order flow; unit/widget tests across domain + application — `integration_test/order_flow_test.dart` drives home → add to cart → checkout → order placed → tracking against the mock flavor (login always goes through live Supabase per `bootstrap.dart`, so it's bypassed via a pre-seeded auth token rather than driven). Getting it running on a real emulator surfaced and fixed three real bugs: `bootstrap()` was awaiting the location/push permission dialogs before `runApp()`, blocking the whole app (not just those features) until answered — now fire-and-forget; `GetCurrentLocationProvider` (autoDispose) wrote to `state` after an `await` with no `mounted` check, crashing with "used after dispose" when navigated away mid-request; Crashlytics' error hook fully replaced `FlutterError.onError` instead of chaining, which silently broke `expect()`'s own error capturing under `flutter_test`. **The test itself did not reach a fully green run in this sandbox** — an Android 13+ permission dialog intermittently steals focus during the automated run (environment/CI-setup flakiness, not an app bug); also added `test/core/utils/parsed_address_test.dart` and `test/core/data/mock_service_area_repository_test.dart` for Phase 4's address-parsing and serviceability logic
- [x] Crashlytics + analytics (`view_item`, `add_to_cart`, `begin_checkout`, `purchase`) — wired at product-detail load, cart add, checkout open, and order placed; not yet verified against a live Firebase project
- [x] Performance + accessibility passes — tooltips added to every icon-only button that lacked one (screen readers were announcing a bare "button"); found two real bugs this surfaced rather than went looking for: `splash_screen.dart` was dead code (never routed to) referencing a missing asset and the wrong-case route, now deleted since `flutter_native_splash` already covers that moment; the launcher icon and new native splash were both built from `appLogo.png`, a 303×111 non-square wordmark — the icon was being squished (pre-existing since Phase 0) and the splash was blurry from upscaling. Both now source from `appIconMark.png` (the bicycle/gift mark alone, cropped and padded square) — no more distortion, still soft since the source is only ~71×68px natively; a real fix needs a proper high-res icon asset
- [x] Launcher icon, native splash — see above; release signing — `android/app/build.gradle`'s release build was hardcoded to debug-sign with the real keystore commented out; now uses `android/key.properties` automatically once supplied (gitignored, `key.properties.example` documents the fields), falling back to debug signing so local release builds keep working without one
- [ ] Play internal testing + TestFlight — needs a Play Console / App Store Connect account and a real signed build; not something this environment can do
- [ ] Remove Supabase test phone numbers — this is a Supabase dashboard setting (Authentication → Phone Auth), not anything in this repo; flagging as a pre-launch checklist item rather than a code change

Done when: both store test tracks run a week of internal use with no crashes. ⚠️ Not reachable from here — needs real signing, store accounts, and a week of real usage.

### Phase 6 — Move to Firebase · `feat/firebase-migration`
Supabase (Postgres, Auth, Storage, Realtime, Edge Functions) is replaced by Firebase on the existing project `zippy-app-2024`.
- [x] `firebase.json`, `.firebaserc`, `firestore.rules`, `firestore.indexes.json`, `storage.rules`. Catalog is public-read/admin-write; `users/{uid}` + `addresses`/`cart`/`favourites` are owner-only; `orders`, `paymentIntents`, `inventory` are written only by Cloud Functions. Admins = custom claim `admin: true` (`functions/scripts/set-admin.ts`)
- [x] Cloud Functions (`functions/`, TypeScript, Node 22, `asia-south1`): `placeOrder` (COD), `createPhonePeOrder`, `verifyPhonePePayment` (idempotent paid orders, mismatches → `needs_review`), `placesProxy`, `deleteAccount`, `onOrderEventCreated` (FCM push), `adminUpdateOrderStatus`, `adminListUsers`. Ported from `quote_order` / `place_order_internal` / `place_paid_order`; stock now spills across an area's stores instead of failing when no single store has enough
- [x] `functions/scripts/seed.ts` loads the old `seed.sql` catalog + images into Firestore/Storage; search uses a `keywords` prefix array
- [x] App: one `firebase_*_repository_impl.dart` per interface; Firebase Auth for phone OTP, Google, guest and guest upgrade (`linkWithCredential`); order tracking listens to Firestore; `supabase_flutter` removed
- [x] Admin panel (`zyppi-admin`): Firebase Auth email/password + admin claim, Firestore services, Storage uploads
- [x] Tests: functions emulator suite (pricing, coupons, stock, rollback, idempotency, rules) in CI; Dart tests for distance and error mapping
- [ ] Console: Blaze plan, Firestore (`asia-south1`), Storage, Auth providers (Phone, Google, Anonymous, Email/Password), SHA-1/SHA-256 fingerprints, APNs key; secrets `PHONEPE_*`, `GOOGLE_PLACES_API_KEY`
- [ ] Deploy (`firebase deploy --only firestore,storage,functions`), seed, create the admin login + `set-admin`
- [ ] Verify end to end on a device, then delete `supabase/` and `scripts/upload_catalog_images.sh`

Done when: on a real phone against `zippy-app-2024` — OTP, Google and guest sign-in work; a COD order is placed and appears in the admin panel; an admin status change updates tracking live and sends a push; delete account works.

## 6. Decisions

| Decision | Value |
| --- | --- |
| Repo / base branch | `paulatanu1/zyppi-APP`, `Development` |
| App id / package | `com.zyppi.one` (changed from `com.betastechnologies.zippy` on 2026-10-17, pre-submission), Dart package `zippy` |
| Scope | Customer app first, admin panel (`zyppi-admin`, Angular) alongside; rider later |
| Backend | Firebase project `zippy-app-2024` for every flavor (Firestore + Cloud Functions in `asia-south1`, Auth, Storage) — Phase 6, 2026-11-03. Supabase (`dcgjsspymailbciqkhvq`) retired; started fresh, catalog re-seeded, no user data copied |
| Launch areas | Purulia, Raghunathpur, Chelyama |
| Delivery model | Dark store per area; express + scheduled slots |
| Payments | PhonePe (Standard Checkout) + COD |
| SMS / OTP | Firebase Phone Auth (sends the SMS itself). Dev: Firebase test phone numbers |
| Brand | Existing Zyppi brand (pink, blue, Poppins/Montserrat) — mockup re-themed |
| Navigation | Home, Explore, Cart, Favourite, Account |
| Localization | easy_localization: en, bn, hi, pa |
| Platforms | Android, iOS |
| State | Riverpod 3 + codegen |

Open: production SMS provider sign-up; realistic express ETA per town; PhonePe Business Dashboard credentials (`PHONEPE_CLIENT_ID`/`SECRET`/`VERSION`/`MERCHANT_ID`) still need setting as Cloud Functions secrets (`firebase functions:secrets:set`); `zyppi-admin` (sibling repo) should surface a per-order "Navigate" link (e.g. `https://www.google.com/maps/dir/?api=1&destination=lat,lng`) built from the `orders`/`addresses` data this app already writes, for whoever is handling deliveries until a rider app exists — not implemented here, this repo's data model already supports it.
