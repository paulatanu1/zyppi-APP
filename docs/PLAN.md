# Zyppi Grocery App — Upgrade & Development Plan

Approved plan for Claude Code. Repo: `paulatanu1/zyppi-APP`, base branch **`Development`**. Last updated 14 Oct 2026.

## 1. Summary and audit

The app already exists on `Development` (65 commits, Nov 2024 – Feb 2025): 17 feature screens on Riverpod, freezed and go_router, Firebase + Google sign-in, easy_localization in 4 languages. It runs on Flutter 3.24.3 and talks to an old REST backend over plain HTTP. The plan upgrades it in place, moves data and auth to Supabase, builds the missing grocery flow (product search, checkout, order placed, order tracking) and restyles screens to the approved mockup.

| Area | Current state (`Development` @ 2cfeb0c, 3 Feb 2025) | Action |
| --- | --- | --- |
| Branches | `main` has only the initial commit | Branch each phase from `Development`; merge to `main` after Phase 0 |
| Flutter / Dart | Flutter 3.24.3; `sdk: 3.6.0` pinned exactly | FVM 3.47.x; `sdk: ^3.13.0` |
| State / models | Riverpod 2.6 + generator; freezed 2; `freezed_annotation` wrongly in dev_dependencies | Riverpod 3; freezed 3 (`abstract`/`sealed` classes); move annotation to dependencies |
| Backend | `dio` → `http://13.233.47.211:2015/api/v1/` (`lib/core/infrastructure/`) for login, Google login, add address | Replace with Supabase; delete dio + `core/infrastructure/` after migration |
| Auth | REST phone login, `firebase_auth`, `google_sign_in` 6 | Supabase Auth: phone OTP + Google via `signInWithIdToken` |
| Secrets | Google Maps key hard-coded in `lib/core/constants/googleApiKey.dart`; `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist` committed | Restrict/rotate the Maps key; read it from env; restrict Firebase API keys in Google Cloud |
| Android | Groovy DSL, AGP 8.7.2, Kotlin 2.0.0, Gradle 8.9, `compileSdk 34`, `minSdk 23` | Bump AGP/Kotlin/Gradle; `compileSdk = flutter.compileSdkVersion`; `minSdk 24` |
| App id / package | `com.betastechnologies.zippy`; Dart package `zippy` | Keep both |
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
| Backend | `dio` + REST | `supabase_flutter`; Supabase CLI | 3 |
| Auth | `firebase_auth`, `google_sign_in` 6 | Supabase Auth; `google_sign_in` latest for the ID token | 3 |
| Local storage | `shared_preferences` | + `hive_ce`, `hive_ce_flutter` (cart, recent searches) | 2 |
| UI kit | `flutter_screenutil`, `carousel_slider`, `smooth_page_indicator`, `curved_navigation_bar`, `flutter_bounce`, `fluttertoast` | Keep first four; SnackBar instead of `fluttertoast`; add `cached_network_image`, `skeletonizer` | 1–2 |
| OTP input | `otp_text_field` + `flutter_otp_text_field` | `flutter_otp_text_field` only | 1 |
| Localization | `easy_localization` | latest | 0 |
| Location / maps | `geolocator`, `google_places_flutter` (client key) | `geolocator`, `geocoding`, `google_maps_flutter`; Places via Edge Function | 4 |
| Push / crash / analytics | `firebase_core` | + `firebase_messaging`, `firebase_crashlytics`, `firebase_analytics` | 4–5 |
| Payments | — | `razorpay_flutter` + COD | 4 |
| Testing | `flutter_test` | + `mocktail`, `integration_test` | all |
| Release assets | `flutter_launcher_icons` | + `flutter_native_splash` | 5 |

Environments: dev / staging / prod via `--dart-define-from-file=env/<flavor>.json` + Android product flavors + iOS schemes. Only `env/*.example.json` is committed.

## 3. Product scope (MVP = customer app)

Launch areas **Purulia, Raghunathpur, Chelyama**. INR. Languages en, bn, hi, pa. Existing 5-tab nav stays: **Home, Explore, Cart, Favourite, Account** (Orders under Account). Rider app and admin panel later.

| # | Screen | Existing code (`lib/features/`) | Status | Mockup (`docs/mockups/`) |
| --- | --- | --- | --- | --- |
| 1 | Splash / onboarding | `Intro/` | Exists | `Onboarding.dc.html` |
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
data/mock (assets/mock)   data/supabase (supabase_flutter)
```

Target layout after the Phase 1 rename pass:

```text
lib/
  main.dart                  # flavor → bootstrap()
  bootstrap.dart             # EasyLocalization, Firebase, Supabase.initialize, ProviderScope
  app/
    app.dart                 # MaterialApp.router, theme, ScreenUtilInit(390x844)
    router.dart              # go_router + redirect/refreshListenable (onboarding, auth, location)
  core/
    config/env.dart          # String.fromEnvironment(...)
    theme/                   # tokens from docs/design-tokens.md (replaces constants/colors.dart)
    supabase/                # client provider, error mapping (replaces infrastructure/ in Phase 3)
    storage/                 # shared_preferences, hive boxes
    location/                # from sharedProviders/Location
    utils/  widgets/         # money (paise), formatters; shared widgets (from commonWidgets/)
  features/<feature>/{data,domain,application,presentation,widgets}
    intro auth location home explore category product search cart checkout orders tracking account favourites addresses
assets/mock/                 # categories.json, products.json, orders.json, addresses.json, slots.json, service_areas.json
supabase/                    # migrations/, seed.sql, functions/ (Phase 3+)
env/                         # *.example.json committed; real files gitignored
```

Conventions: money as `int` paise · theme tokens only · every async screen has loading/empty/error/data · features import only `core/` and themselves · generated files committed · Dart package stays `zippy`.

## 5. Phases

Gates: plan + mockup approved → Phase 0. After Phase 2: prototype reviewed on a phone + Supabase schema agreed. After Phase 5: internal testing tracks.

### Phase 0 — Upgrade the existing app (1–2 days) · `chore/upgrade-flutter-3.47`
- [ ] Branch from `Development`
- [ ] Restrict/rotate the Google Maps key in git history (Android package + SHA-1, iOS bundle id); move it to `env/*.json`, read via `String.fromEnvironment`; delete `lib/core/constants/googleApiKey.dart`
- [ ] FVM: `fvm use 3.47.7` (or newest 3.47.x); commit `.fvmrc`; update README Flutter version
- [ ] `environment.sdk: ^3.13.0`; move `freezed_annotation` to dependencies; fix `flutter_lints` placement under dev_dependencies
- [ ] `fvm flutter pub upgrade --major-versions`; fix breaking changes: Riverpod 3, freezed 3 (`abstract class`/`sealed class`), google_sign_in, go_router, firebase_*, carousel_slider; `fvm dart run build_runner build -d`
- [ ] Android: AGP, Kotlin and Gradle wrapper to the versions the Flutter 3.47 template uses; `compileSdk = flutter.compileSdkVersion`; `minSdk = 24`; keep `applicationId com.betastechnologies.zippy`
- [ ] iOS: deployment target 15.0 in Podfile + project; `pod install`
- [ ] `ScreenUtilInit(designSize: Size(390, 844))`

Done when: `fvm flutter analyze` 0 issues, every existing screen still opens, app runs on Android emulator + iOS simulator, `fvm flutter build apk --debug` succeeds.

### Phase 1 — Foundations (3–4 days) · `feat/foundations`
- [ ] Rename pass: snake_case files, lowercase folders (one refactor-only commit)
- [ ] `data/` layer + repository interfaces per feature; notifiers under `application/`
- [ ] Theme from `docs/design-tokens.md`, replacing `core/constants/colors.dart`; remove Righteous, Aclonica, AirbnbCereal fonts
- [ ] Router: `redirect` + `refreshListenable` for onboarding/auth/location; remove `ref.listen` + `context.goNamed` from the root widget
- [ ] `bootstrap()`, dev/staging/prod flavors, `env/*.example.json`, `Supabase.initialize` from env (skipped in mock mode)
- [ ] easy_localization stays; every new string in all 4 JSON files
- [ ] Shared widgets aligned to mockup: primary button, quantity stepper, product card, price tag, skeletons; keep one OTP package; SnackBar instead of fluttertoast
- [ ] GitHub Actions: format, analyze, test on PRs to `Development`

Done when: each flavor boots, existing screens use tokens, CI green.

### Phase 2 — Clickable prototype on mock data (1.5–2 weeks) · `feat/prototype`
- [ ] freezed entities: Category, Product, ProductVariant, CartItem, Address, DeliverySlot, Coupon, Order, OrderItem, OrderStatus, ServiceArea
- [ ] `assets/mock/*.json` (move hard-coded screen lists there; service areas Purulia, Raghunathpur, Chelyama) + mock repositories (300–800 ms delay, error toggle)
- [ ] Restyle existing screens to the mockup; build missing screens 8, 10, 11, 12
- [ ] Cart in `hive_ce`: steppers, item total, savings, delivery fee, handling fee, tip, coupon
- [ ] Fake order lifecycle timer: placed → packed → out for delivery → delivered
- [ ] Unit tests for bill math; widget tests for cart and product card

Done when: release APK runs splash → tracking fully offline and matches the mockup.

### Phase 3 — Supabase integration (2–3 weeks) · `feat/supabase-integration`
- [ ] `npx skills add supabase/agent-skills`
- [ ] Supabase project ref `dcgjsspymailbciqkhvq` = dev; prod project before release; `supabase/` via CLI (migrations, `seed.sql`, functions)
- [ ] Schema: profiles, addresses, service_areas, stores, categories, products, product_variants, inventory, carts, cart_items, orders, order_items, order_events, payments, delivery_slots, coupons
- [ ] RLS on every table; catalog read-only for clients
- [ ] Auth: phone OTP (dev: Supabase test numbers) + Google via `signInWithIdToken`; remove REST login and `firebase_auth`
- [ ] `place_order` RPC: re-checks stock, prices, coupon, serviceability in one transaction
- [ ] Supabase repositories: catalog, search (Postgres full-text), cart sync, addresses, orders; images in Supabase Storage
- [ ] Delete `dio`, `lib/core/infrastructure/`, old base URL
- [ ] Only the publishable/anon key in the app; service-role key only in Edge Functions
- [ ] Flavor-based provider overrides; mock flavor still works

Done when: staging flavor places a real order end to end; mock flavor still runs.

### Phase 4 — Delivery features (~2 weeks) · `feat/delivery-features`
- [ ] Location: permission, current position, reverse geocode, map-pin picker, serviceability vs `service_areas`; Places autocomplete through an Edge Function (no client Maps key for Places)
- [ ] Razorpay order creation + signature verification in Edge Functions; COD
- [ ] FCM push on `order_events` insert (Edge Function); deep link to tracking
- [ ] Live tracking via Supabase Realtime
- [ ] Express vs scheduled slot picker
- [ ] Production SMS: MSG91 through the Supabase Send SMS Hook; DLT sender ID + template

Done when: Razorpay test payment succeeds, background push arrives, tracking map updates.

### Phase 5 — Release hardening (1–2 weeks) · `chore/release-hardening`
- [ ] Integration test for the order flow; unit/widget tests across domain + application
- [ ] Crashlytics + analytics (`view_item`, `add_to_cart`, `begin_checkout`, `purchase`)
- [ ] Performance + accessibility passes
- [ ] Launcher icon, native splash, release signing, Play internal testing + TestFlight
- [ ] Remove Supabase test phone numbers

Done when: both store test tracks run a week of internal use with no crashes.

## 6. Decisions

| Decision | Value |
| --- | --- |
| Repo / base branch | `paulatanu1/zyppi-APP`, `Development` |
| App id / package | Keep `com.betastechnologies.zippy`, Dart package `zippy` |
| Scope | Customer app first; rider + admin later |
| Backend | Supabase from scratch (project ref `dcgjsspymailbciqkhvq` = dev); old REST API retired |
| Launch areas | Purulia, Raghunathpur, Chelyama |
| Delivery model | Dark store per area; express + scheduled slots |
| Payments | Razorpay + COD |
| SMS / OTP | Dev: Supabase test numbers. Prod: MSG91 via Send SMS Hook |
| Brand | Existing Zyppi brand (pink, blue, Poppins/Montserrat) — mockup re-themed |
| Navigation | Home, Explore, Cart, Favourite, Account |
| Localization | easy_localization: en, bn, hi, pa |
| Platforms | Android, iOS |
| State | Riverpod 3 + codegen |

Open: production SMS provider sign-up; Maps key rotation; realistic express ETA per town.
