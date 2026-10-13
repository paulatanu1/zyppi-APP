# Zyppi Grocery App — Upgrade & Development Plan

Approved plan for Claude Code. Source of truth: this file. Last updated 14 Oct 2026.

## 1. Summary and repo audit

The repo is still the default Flutter counter template, so the "upgrade" is a toolchain refresh and the grocery app is built new on top of it. Work runs in 6 phases: upgrade, foundations, clickable mock-data prototype, Supabase integration, delivery features, release hardening.

| Area | Current state (`main` @ 537f51e, 17 Sep 2025) | Action |
| --- | --- | --- |
| App code | `lib/main.dart` only, counter demo | Nothing to migrate; replace |
| Dart SDK constraint | `^3.5.4` | Raise to `^3.13.0` |
| Dependencies | `cupertino_icons`; `flutter_lints ^4.0.0` | Add stack below; lints to latest |
| Android build | Groovy DSL, AGP 8.1.0, Kotlin 1.8.22, Gradle 8.3 | Regenerate: Kotlin DSL, current AGP/Kotlin/Gradle |
| Package id | `com.example.zyppi` | `com.zyppi.app` |
| Platforms | android, ios, web, macos, linux, windows | Keep android + ios only |
| Repo hygiene | `.idea/`, `zyppi.iml` committed | Remove, gitignore |
| Tests | template counter test | Replace |

## 2. Target stack

Flutter **3.47.x stable** (Dart 3.13), pinned per repo with **FVM** (`.fvmrc`). Add packages with `fvm flutter pub add <name>` so pub resolves the newest compatible versions; commit `pubspec.lock`.

| Concern | Packages | Phase |
| --- | --- | --- |
| State | `flutter_riverpod`, `riverpod_annotation`; dev: `riverpod_generator`, `riverpod_lint`, `custom_lint` | 1 |
| Routing | `go_router` | 1 |
| Models / JSON | `freezed`, `freezed_annotation`, `json_serializable`, `json_annotation`; dev: `build_runner` | 1 |
| Backend | `supabase_flutter` (Postgres + RPC, phone OTP Auth, Realtime, Storage, Edge Functions); Supabase CLI for migrations | 3 |
| Local storage | `shared_preferences` (settings), `hive_ce` + `hive_ce_flutter` (cart, recent searches) | 1–2 |
| Images / icons | `cached_network_image`, `flutter_svg` | 1 |
| Loading states | `skeletonizer` | 2 |
| Localization | `flutter_localizations`, `intl` with `gen-l10n` | 1 |
| Location / maps | `geolocator`, `geocoding`, `google_maps_flutter` | 4 |
| Push, crash, analytics | `firebase_core`, `firebase_messaging`, `firebase_crashlytics`, `firebase_analytics` (Supabase has no push) | 4–5 |
| Payments | `razorpay_flutter` (UPI, cards, wallets) + COD | 4 |
| Testing | `flutter_test`, `mocktail`, `integration_test` | all |
| Release assets (dev) | `flutter_launcher_icons`, `flutter_native_splash` | 5 |

Environments: `dev`, `staging`, `prod` via `--dart-define-from-file=env/<flavor>.json` plus Android product flavors and iOS schemes. Only `env/*.example.json` is committed.

## 3. Product scope (MVP = customer app)

Launch areas: **Purulia, Raghunathpur, Chelyama**. Currency INR, language English first (Bengali, Hindi later). Rider app and store/admin panel come later; data models are designed for them now.

| # | Screen | Route | Mockup file |
| --- | --- | --- | --- |
| 1 | Onboarding / splash | `/onboarding` | `docs/mockups/Onboarding.dc.html` |
| 2 | Login (phone) | `/login` | `docs/mockups/Login.dc.html` |
| 3 | OTP verify | `/login/otp` | `docs/mockups/Otp.dc.html` |
| 4 | Location setup | `/location` | `docs/mockups/Location.dc.html` |
| 5 | Home | `/` (tab) | `docs/mockups/Main.dc.html` |
| 6 | Category listing | `/category/:id` (Categories tab) | `docs/mockups/Category.dc.html` |
| 7 | Product detail | `/product/:id` | `docs/mockups/Product.dc.html` |
| 8 | Search | `/search` | `docs/mockups/Search.dc.html` |
| 9 | Cart | `/cart` | `docs/mockups/Cart.dc.html` |
| 10 | Checkout | `/checkout` | `docs/mockups/Checkout.dc.html` |
| 11 | Order placed | `/orders/:id/placed` | `docs/mockups/Placed.dc.html` |
| 12 | Order tracking | `/orders/:id/track` | `docs/mockups/Tracking.dc.html` |
| 13 | Orders history | `/orders` (tab) | `docs/mockups/Orders.dc.html` |
| 14 | Profile | `/profile` (tab) | `docs/mockups/Profile.dc.html` |
| 15 | Addresses | `/profile/addresses` | (derive from Location) |
| 16 | Wishlist | `/profile/wishlist` | (derive from Category grid) |

Out of scope for MVP: subscriptions, wallet, referrals, multi-store marketplace, rider chat.

## 4. Architecture

Feature-first, four layers. Screens read data only through repository interfaces, so Phase 2 runs on mock JSON and Phase 3 switches to Supabase by changing provider overrides.

```
Presentation (screens, widgets)
      ↓
Application (Riverpod notifiers)
      ↓
Domain (entities + repository interfaces)   ← swap point
      ↓                       ↓
Mock data source         Supabase data source
(assets/mock/*.json)     (supabase_flutter)
```

```text
lib/
  main.dart                  # reads flavor, calls bootstrap()
  bootstrap.dart             # Supabase.initialize, ProviderScope, error handlers, Firebase init
  app/
    app.dart                 # MaterialApp.router, theme, l10n
    router.dart              # go_router + onboarding/auth/location redirects
  core/
    config/env.dart          # String.fromEnvironment('SUPABASE_URL'), ...
    theme/                   # tokens from docs/design-tokens.md
    supabase/                # client provider, error mapping
    storage/                 # hive boxes, prefs
    utils/                   # money (paise), formatters, validators
    widgets/                 # ZButton, QuantityStepper, ProductCard, PriceTag, SectionHeader, skeletons
  features/<feature>/{data,domain,application,presentation}
    onboarding auth location home catalog search product cart checkout orders tracking profile
assets/mock/                 # categories.json, products.json, orders.json, addresses.json, slots.json
assets/fonts/                # Bricolage Grotesque, Figtree (bundled, not fetched at runtime)
supabase/                    # migrations/, seed.sql, functions/ (Phase 3+)
env/                         # dev.example.json committed; dev.json etc. gitignored
test/  integration_test/
```

Conventions:
- Money is integer **paise**; format only in the UI.
- Colors, type, spacing, radius only from `core/theme` tokens (see `docs/design-tokens.md`).
- Every async screen: loading (skeleton), empty, error + retry, data.
- Features import only `core/` and themselves.
- Generated `*.g.dart` / `*.freezed.dart` are committed.
- Material 3; adaptive dialogs/pickers on iOS.

## 5. Phased roadmap

Gate before Phase 0: this plan + mockup approved. Gate after Phase 2: prototype reviewed on a device and Supabase schema agreed. Gate after Phase 5: internal testing on Play Console and TestFlight.

### Phase 0 — Upgrade toolchain (~1 day) · branch `chore/upgrade-flutter-3.47`
- [ ] Install FVM; `fvm use 3.47.7` (or newest 3.47.x); commit `.fvmrc`; add `.fvm/` to `.gitignore`
- [ ] `git rm -r --cached .idea zyppi.iml`; add `.idea/`, `*.iml`, `env/*.json`, `!env/*.example.json` to `.gitignore`
- [ ] Delete `android/ ios/ web/ macos/ linux/ windows/`; run `fvm flutter create --org com.zyppi --project-name zyppi --platforms android,ios .`
- [ ] Set Android `applicationId` and iOS bundle id to `com.zyppi.app`; Android `minSdk = 24`; iOS deployment target 15.0
- [ ] `environment.sdk: ^3.13.0`; `fvm flutter pub upgrade --major-versions`
- [ ] Replace counter demo with placeholder `ZyppiApp`; fix the widget test

Done when: `fvm flutter analyze` = 0 issues, tests pass, app runs on Android emulator + iOS simulator, `fvm flutter build apk --debug` succeeds.

### Phase 1 — Foundations (3–4 days) · branch `feat/foundations`
- [ ] Folder structure above; `analysis_options.yaml` with `riverpod_lint` + stricter rules
- [ ] Theme from `docs/design-tokens.md`; bundle fonts in `assets/fonts/`
- [ ] `go_router` `StatefulShellRoute` bottom nav (Home, Categories, Orders, Profile) + redirects
- [ ] `bootstrap()` with `ProviderScope`, global error handling, `Supabase.initialize` from env (no-op for mock flavor)
- [ ] `gen-l10n` English; paise money formatter
- [ ] Flavors dev/staging/prod + `env/*.example.json`
- [ ] Shared widgets: primary button, quantity stepper, product card, price tag, section header, skeletons
- [ ] GitHub Actions: `dart format --set-exit-if-changed`, analyze, test on PRs

Done when: each flavor boots into the tabbed shell with placeholder screens and CI is green.

### Phase 2 — Clickable prototype (1.5–2 weeks) · branch `feat/prototype`
- [ ] freezed entities: Category, Product, ProductVariant, CartItem, Address, DeliverySlot, Coupon, Order, OrderItem, OrderStatus, ServiceArea
- [ ] Mock JSON (~8 categories, ~60 products, service areas for Purulia, Raghunathpur, Chelyama) + mock repositories with 300–800 ms delay and error toggle
- [ ] Screens 1–14 matching `docs/mockups/*.dc.html`
- [ ] Cart in `hive_ce`: steppers, item total, MRP savings, delivery fee (free above threshold), handling fee, tip, coupon
- [ ] Fake order lifecycle timer: placed → packed → out for delivery → delivered
- [ ] Unit tests for bill math; widget tests for cart + product card

Done when: release APK runs splash → tracking fully offline and matches the mockup.

### Phase 3 — Supabase integration (2–3 weeks) · branch `feat/supabase-integration`
- [ ] Run `npx skills add supabase/agent-skills` once in the repo
- [ ] Existing project ref `dcgjsspymailbciqkhvq` = dev; create prod project before release; `supabase/` via Supabase CLI (migrations, `seed.sql`, functions)
- [ ] Schema: profiles, addresses, service_areas, stores, categories, products, product_variants, inventory, carts, cart_items, orders, order_items, order_events, payments, delivery_slots, coupons
- [ ] RLS on every table: users only touch their own carts/addresses/orders; catalog read-only for clients
- [ ] Phone OTP via Supabase Auth; dev uses Supabase **test phone numbers** (no SMS cost)
- [ ] `place_order` Postgres function (RPC): re-checks stock, prices, coupon, serviceability in one transaction
- [ ] Supabase repositories: catalog, search (Postgres full-text, debounced), cart sync, addresses, orders; images in Supabase Storage
- [ ] Only the publishable/anon key in the app (via env); service-role key only in Edge Functions
- [ ] Flavor-based provider overrides; mock flavor keeps working

Done when: staging flavor places a real order end to end; mock flavor still runs.

### Phase 4 — Delivery features (~2 weeks) · branch `feat/delivery-features`
- [ ] Location permission, geolocator, reverse geocoding, map-pin address picker, serviceability check against `service_areas`
- [ ] Razorpay: order creation + signature verification in Edge Functions; COD
- [ ] FCM push on order status (Edge Function on `order_events` insert); deep link to tracking
- [ ] Live tracking via Supabase Realtime (rider location)
- [ ] Express vs scheduled slot picker
- [ ] Production SMS: MSG91 through Supabase **Send SMS Hook** (Edge Function); DLT sender ID + template registered

Done when: Razorpay test payment succeeds, background push arrives, tracking map updates.

### Phase 5 — Release hardening (1–2 weeks) · branch `chore/release-hardening`
- [ ] Integration test for the order flow; unit/widget coverage on domain + application
- [ ] Crashlytics + analytics events (`view_item`, `add_to_cart`, `begin_checkout`, `purchase`)
- [ ] Performance (image sizes, list builders, startup trace) and accessibility (semantics, text scaling, contrast)
- [ ] App icon, native splash, release signing, Play internal testing + TestFlight
- [ ] Remove Supabase test phone numbers

Done when: both store test tracks run a week of internal use with no crashes.

## 6. Decisions

| Decision | Value |
| --- | --- |
| Package id | `com.zyppi.app` |
| Scope | Customer app first; rider + admin later |
| Backend | Supabase from scratch (project ref `dcgjsspymailbciqkhvq` = dev) |
| Launch areas | Purulia, Raghunathpur, Chelyama |
| Delivery model | Dark store per area; express + scheduled slots (confirm express ETA per town) |
| Payments | Razorpay + COD |
| SMS / OTP | Dev: Supabase test numbers. Prod: MSG91 via Send SMS Hook (~₹0.40–0.60/OTP) + optional Google sign-in |
| Currency / language | INR; English first |
| Platforms | Android, iOS |
| State management | Riverpod 3 + codegen |
| Brand | Placeholder green/yellow from mockup until a logo/brand is supplied |

Open: logo/brand assets; final SMS provider sign-up; express ETA realistic for each town.
