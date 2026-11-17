# Zyppi Marketplace — design

> Approved 2026-11-17. Phase 7 in [PLAN.md](PLAN.md) tracks progress; this file holds the design.


## Context
Today every store is a Zyppi-run dark store with no owner. Each variant has one global `pricePaise`/`mrpPaise` (`functions/src/catalog/model.ts`), and `quoteOrder` (`functions/src/orders/quote.ts`) prices orders from it. Zyppi now wants outside shops to sell through the platform in two ways.

- **Subscription seller.** The seller pays a 1-, 3- or 6-month fee and sets their own selling price. An admin can add an **add-on** on top of that price. The customer sees seller price + add-on. The seller is paid their own price, and Zyppi keeps the add-on as well as the fee.
- **Supply seller.** The seller supplies Zyppi at a discounted rate. Zyppi sets the customer price, pays the seller the agreed supply price, and keeps the difference.

Decisions you made:
- **Fulfilment** is set per seller: either from the seller's own shop (the rider picks up there) or from stock placed in a Zyppi dark store.
- **Seller tool:** a separate **seller mobile app** (Flutter, new repo; you will provide it). This replaces the earlier idea of a seller login inside `zyppi-admin`, which now only gets the admin side of seller management. See "Seller app" below.
- **Subscription fees** are deducted from payouts, or paid offline and recorded by finance.
- **When several sellers sell the same product,** the customer chooses which one to buy from. Offers are ranked automatically by price, rating and reliability.

PLAN.md §3 currently lists "multi-store marketplace" as out of scope, so this needs a new **Phase 7 — Marketplace** in PLAN.md. Approving this plan also approves the data-model and `firestore.rules`/`storage.rules` changes below, which CLAUDE.md says need your sign-off.

## Core idea: separate the product from the offer
- `products` stays the single master catalog that Zyppi curates (name, images, variants, MRP). Sellers never create duplicate products. They list against an existing variant, or request a new one for an admin to approve.
- An **offer (listing)** means "seller X sells variant Y from store Z at price P". It holds all the money fields.
- Zyppi's own stock is just another seller (`sellerId: "zyppi"`, model `own`). Ranking, cart, quote and settlement then follow one code path for everyone.

### Pricing rules
These are one pure, unit-tested function, `functions/src/marketplace/pricing.ts`:

| Model | Customer `pricePaise` | Seller `payoutPaise` (per unit) | Zyppi margin |
|---|---|---|---|
| `subscription` | sellerPrice + addon | sellerPrice | addon (+ subscription fee) |
| `supply` | set by Zyppi admin | agreed supply price | price − supply |
| `own` | set by Zyppi admin | 0 | price |

- **Special discount (seller-funded).** A seller can set `specialDiscount{type: fixed|percent, value, startsAt, endsAt}` on a listing. While it is active, `effectiveSellerPrice = sellerPrice − discount`. The customer price is `effectiveSellerPrice + addon`, and the payout is `effectiveSellerPrice`. Zyppi's add-on is untouched, and the customer sees the MRP struck through with an "x% off" badge.
- The add-on is stored as `{type: fixed|percent, value}` and turned into paise on save. A percent add-on follows the seller's price changes automatically.
- **The price can never exceed MRP** (Legal Metrology). The add-on must be ≥ 0. If a supply margin is negative, the save is rejected unless an admin overrides it with a reason.
- Coupons, delivery fee, handling fee and tip stay Zyppi-funded. They never change seller payouts. A `fundedBy` field can be added to coupons later.

## Data model (new and changed Firestore)
- **`sellers/{sellerId}`** (new)
  - Identity: `name, legalName, model (subscription|supply), fulfilment (seller_shop|zyppi_store), status (applied|approved|suspended|rejected)`.
  - Compliance and contact: `gstin, pan, fssaiNo, fssaiExpiry, address, phone`.
  - Running numbers: `rating{avg,count}`, `stats{orders,cancelled,lateAccepts}`, `subscription{planId,status: active|grace|expired,periodEnd}`.
  - Balances: `earningsBalancePaise, heldPaise, earnedTotalPaise, paidOutTotalPaise, duesPaise`.
  - Subcollections: `private/bank` (finance and owner only), `earnings/`, `payouts/`, `subscriptions/` (billing periods), `inbox/`.
- **`sellerUsers/{uid}` → `{sellerId, role: owner|staff}`** (new). Also set as custom claim `sellerId`, so security rules can check it.
- **`sellerPlans/{planId}`** (new): `name, months (1|3|6), feePaise, maxListings, isActive`.
- **`listings/{sellerId}_{areaId}_{variantId}`** (new, private: readable only by that seller and staff).
  - One per seller, area and variant. It holds the price; stock stays per store in `inventory`.
  - Fields: `sellerId, serviceAreaId, productId, variantId, model, sellerPricePaise, zyppiPricePaise, addon{type,value}, specialDiscount, allowNegativeMargin, isActive`, the computed `pricePaise / payoutPaise / marginPaise / addonPaise` at save time, `nextPriceChangeAt`, `updatedBy, updatedAt`.
  - Every price change is appended to `listings/{id}/priceHistory`, and staff changes also go through `writeAudit`.
  - **Zyppi's own stock has no listing docs.** Its offers are priced from the product's variants, which `adminSaveProduct` still edits (decided in M1).
- **`offers/{sellerId}_{areaId}_{variantId}`** (new, public-read; Zyppi's are `zyppi_{areaId}_{variantId}`).
  - The offers trigger (`marketplace/offers_sync.ts`) fills it from the product, the listings, the sellers and stock. It **never contains payout or margin fields**.
  - Fields: `productId, variantId, serviceAreaId, sellerId, sellerName, sellerRating, ratingCount, fulfilment, pricePaise, mrpPaise, regularPricePaise, discountActive, inStock, rankScore, isActive`.
- **`products/{id}`** gains `areaBest.{areaId}.{variantId} = {offerId, pricePaise, mrpPaise, offerCount}` and `rank.{areaId}`. The trigger keeps both up to date, so list screens still read one doc per product.
- **`stores`** gains `sellerId` and `fulfilment`:
  - A seller's shop is a store with that seller's `sellerId`.
  - A supply seller's stock in a Zyppi dark store stays on the Zyppi store; the seller is attributed through the listing.
- **`inventory`**
  - Existing rows `{storeId}_{variantId}` stay as Zyppi's own stock, so no migration is needed.
  - Seller stock uses `{storeId}_{sellerId}_{variantId}` with an added `sellerId` field. It can be in the seller's shop, or in a Zyppi store for supply sellers.
  - `adminAdjustStock` (now with an optional `sellerId` per row) and `inventoryMovements` are reused, plus `sellerAdjustStock`, which is scoped to the caller's own shop.
- **Cart** `users/{uid}/cart/{offerId}` with `{productId, variantId, offerId, quantity}`. Old docs keyed by `variantId` are read as "best offer in the area".
- **Order snapshot**
  - Each entry in `items[]` gains `offerId, sellerId, sellerName, payoutPaise, marginPaise` (frozen at order time).
  - `allocations[]` gains `listingId`.
  - The order gains `sellerIds[]` (for seller queries) and `sellerStatus.{sellerId} = pending|accepted|ready|rejected`.
- **`config/marketplace`**: ranking weights, settlement hold days, acceptance SLA minutes, grace days.
- **Rules:**
  - `sellers`, `listings`, `payouts` and `earnings`: the seller can read its own; finance can read everything.
  - `offers`: public-read.
  - All writes go through Cloud Functions (the current pattern).
  - `storage.rules`: a `sellers/{sellerId}/kyc/**` path for KYC documents.

## Ranking (automatic indexing)
`rankOffer()` is a pure function in `functions/src/marketplace/ranking.ts`. It is recomputed whenever a listing, stock, seller rating or seller stats change.

```
score = wPrice*(minPriceInGroup/price) + wRating*bayes(avg,count,prior=4.0,C=20)/5
      + wReliability*(1 - cancelRate) + wStock*(inStock?1:0) - wEta*etaPenalty
```
- The weights live in `config/marketplace.ranking`, so admins can tune them.
- The Bayesian average stops a seller with one 5★ review outranking one with 300 reviews at 4.6★.
- **Product details** shows offers sorted by `rankScore`. The top offer is the default price on cards.
- **Category and search lists** can sort by `products.rank.{areaId}`, which combines the best offer's score with the product's rating and sales.
- **Ratings** come only from delivered orders, one per order line, through an extended `rateOrder` callable. These update both seller and product rating aggregates. The seller's own phone or uid is excluded, to stop self-rating fraud.

## Order, fulfilment and settlement flow
1. **Quote.** `quoteOrder` reads cart → offer → listing inside the transaction. The price comes from the listing, never from the client. Stock is allocated from that listing's inventory row and no longer spills across stores for seller offers. Zyppi's own offers keep today's spill-over.
2. **Seller shop orders.** On placement, each seller with `seller_shop` fulfilment is notified by FCM web push to the portal and an inbox entry. The seller then has an SLA (for example 5 minutes) to accept and mark ready.
   - A scheduled check auto-cancels any line that misses the SLA, refunds it through the existing `createRefund`, and counts it in `stats.lateAccepts`.
   - Repeated misses auto-pause the seller's listings.
   - Riders pick up using the existing multi-`pickups` dispatch, with the seller's store as a pickup point.
3. **Delivered.** In the delivery transaction, the seller's ledger gets a credit row `sellers/{id}/earnings/${orderId}_${listingId}`. The deterministic id makes the credit idempotent, the same way rider earnings work in `dispatch/earnings.ts`.
   - The row is created with `status: held, releaseAt = deliveredAt + holdDays`.
   - A daily `releaseSellerEarnings` job moves held money to available.
4. **Cancel or refund after delivery.** A negative `reversal` row is written, using the same idempotent id style.
5. **Payout.** The seller requests a payout of `available − duesPaise − TCS/TDS`. Finance records the payout and UTR. This copies `riderRequestPayout`/`adminRecordPayout` from `functions/src/dispatch/pay.ts`.

## Subscriptions
- **Fee and dues.** An admin assigns a plan. Each billing period writes `sellers/{id}/subscriptions/{periodId}` (`feePaise, start, end, status: due|paid, paidVia: deduction|upi|bank, reference`), and the fee is added to `duesPaise`.
- **Settling dues.** Dues are settled either automatically at the next payout or by finance recording an offline payment (`adminRecordSellerFee`).
- **Daily `checkSellerSubscriptions` job:**
  - Reminders go out 7, 3 and 1 days before the period ends.
  - After the end date there is a grace period (`graceDays`).
  - When grace runs out, the subscription is set to `expired`. The offers trigger hides every offer from that seller, and they come back as soon as the seller renews.
- Supply sellers need no subscription.

## Seller app: "Zyppi Seller" (repo `git@github.com:paulatanu1/Zyppi-Marketplace.git`, id `com.zyppi.seller`)
Clone it as a sibling, `../Zyppi-Marketplace`, when S1 starts. The display name can be changed before the first release.
- **Stack:** the same as the rider app (`zyppi-delivery-app`): Flutter + FVM, Riverpod 3, freezed, easy_localization (4 languages), light and dark themes, Firebase Auth by phone OTP. Its backend lives in this repo's `functions/src/marketplace/`.
- **Name.** "Zyppi Seller" is recommended. Alternatives are "Zyppi Dukaan" and "Zyppi Store Partner". "Zyppi Partner" is not recommended because riders are usually called "delivery partners".

### Screens and options
1. **Onboarding and KYC.**
   - Phone OTP, then shop details (name, address with a map pin, hours).
   - Choose the model (subscription or supply) and fulfilment.
   - Upload GSTIN, PAN, FSSAI and bank/UPI details.
   - Accept the seller agreement, then wait on an "Under review" status screen.
2. **Home dashboard.**
   - An **Online/Offline toggle** (shop open for orders).
   - Today's orders and sales, pending orders, rating, and a subscription status banner (days left, renew).
3. **New-order alert** (your requirement).
   - A loud **ringing sound that repeats** until accepted, plus vibration.
   - A **full-screen order card**: order number, items with quantity and variant, your earning for the order, pickup time, and a countdown.
   - A **"Slide to accept"** control. There is **no reject or cancel button**.
   - It must work even if the app is in the background or the phone is locked: high-priority FCM data push → a notification channel with a custom sound → full-screen intent while the seller is online.
   - The rider app's incoming-offer flow is the pattern to reuse here.
   - If the seller doesn't accept within the SLA, it rings louder, then escalates to Zyppi ops (call or auto-reassign). The seller never cancels; only Zyppi ops can.
4. **Orders.** Tabs for New, Preparing, Ready for pickup and Completed.
   - A pack checklist per item, then a "Mark ready" step.
   - The rider's name and ETA, and the 4-digit handover code shown to the rider.
5. **Products.**
   - **Add product:** search the Zyppi master catalog first. If the product isn't there, create a new one (name, images, category, variants, MRP, barcode scan).
   - **Edit product:** name, images, description and variants.
     - Changes to a product the seller created go live after a quick admin approval. Trusted sellers can be set to auto-approve.
     - Edits to a shared master product become a change request instead.
   - **Price:** the seller price per variant takes effect instantly. The seller sees the customer price, including the add-on, as read-only.
   - **Special discount:** fixed amount or %, with start and end dates, and a preview of the final customer price and "x% off".
   - **Stock:** quick +/− and "Out of stock" toggles, plus bulk edit.
   - **Product status:** live, pending review, rejected (with reason) or paused.
6. **Earnings and payouts.** Held, available and dues balances; the ledger per order; a "Request payout" button; payout history with UTR; monthly statement download (sales, discounts, fees, TCS/TDS).
7. **Subscription.** Current plan, expiry, history, and how to pay (deducted from payouts, UPI or bank).
8. **Ratings and reviews.** The seller's rating and each line's customer rating.
9. **Inbox and notifications.** Admin announcements and product approval results.
10. **Profile and settings.** Shop hours, holiday mode, bank/UPI, staff logins (owner and staff roles), language, theme, help/support call, logout.

### Backend additions for the app
- Callables:
  - Profile and KYC: `sellerApply`, `sellerSetOnline`.
  - Listings: `sellerSaveListing` (price and special discount), `sellerAdjustStock`.
  - Catalog: `sellerSubmitProduct` (create or edit → `productRequests/{id}` for admin review; image upload to `storage sellers/{sellerId}/products/**`).
  - Orders: `sellerAcceptOrder` (idempotent, only `pending → accepted`), `sellerMarkReady`.
  - Payouts: `sellerRequestPayout`.
- A per-seller FCM token in `sellers/{id}/devices`.
- A scheduled `escalateUnacceptedOrders` job.

## Rider (delivery boy): pickups from one or more stores, each OTP-verified
**What exists today** in `functions/src/dispatch/delivery.ts`:
- `storesOf()` works out which stores to visit from `order.allocations`.
- `riderReachedStore` / `riderPickUp` write `pickups.{storeId}.reachedAt/pickedAt`.
- After the last store, the order becomes `out_for_delivery`, and delivery needs the customer's 4-digit `private/handover` code.

**Gaps:**
- There is no OTP at the store.
- Pickup needs the whole order to be `packed`, so one slow store blocks the others.
- Rider pay counts the distance from the first store only (`pickupPoint` in `dispatch/earnings.ts`).

### Data
At order placement (`quoteOrder`/`placeOrderInTx`), build one **pickup stop** per store from `allocations`:
```
orders/{id}.pickups.{storeId} = {
  seq, storeName, sellerId, fulfilment, address, lat, lng, phone,
  items: [{productId, variantId, name, unit, quantity}],
  status: pending → accepted → ready → picked | issue,
  acceptedAt, readyAt, reachedAt, pickedAt, otpAttempts
}
orders/{id}/pickupCodes/{storeId} = { code: 4-digit, attempts }   // assigned rider + staff only; never the customer or the store
```
- **Stop count.** The order has `pickupCount`; a single-store order is just one stop, so it follows the same flow.
- **Order status.** A seller-only order becomes `packed` when every seller's stop is `ready`. Zyppi's own stores keep today's flow: ops marks the order packed, then the rider taps "picked up" (built in M1b).
- **Ops alerts** (late accept, item issue) go in `opsAlerts.*`, not `dispatch.state`, so they never stop rider assignment.
- **Where the code is shown.** The rider can read their own order's pickup codes (rule: the assigned rider only). The store never sees the code.

### OTP handover flow (each store)
1. **Rider assigned.** Rider app shows "Pickup 1 of N": store name, address, navigate, call the store, and the items to collect.
2. **Rider reaches the store.** `riderReachedStore` is now **geofenced**: the rider must be within about 150 m of the store's lat/lng, and the existing mocked-GPS refusal applies. The store gets a push: "Rider arrived for #1234".
3. **Code shown.** Rider app shows that store's **pickup OTP** (4 digits plus a QR code).
4. **Store enters the code.**
   - Staff enter or scan it in the Zyppi Seller app with **"Hand over to rider"**. Zyppi's own dark-store staff use the same Seller app with a staff login on the `zyppi` seller.
   - The new `storeConfirmPickup({orderId, storeId, code})` checks that the stop is `ready`, the code matches, attempts are under 5 (then it locks and alerts ops), and the rider has reached the store. It then sets `pickedAt` and writes an order event.
   - This proves the **assigned rider was physically there and the store handed over the items**. Seller payouts and disputes rely on that.
5. **Next stop.** The rider app moves to the next stop automatically. After the last stop the order becomes `out_for_delivery` and the customer OTP flow at the door is unchanged.
6. **Rider can no longer self-mark pickup.** `riderPickUp` without a verified code is removed. It stays available to ops only as `adminForcePickup` with a reason, recorded in the audit log.

### Route, dispatch and pay
- **Stop order.** Stops are sorted by a nearest-neighbour route: rider → stores → customer. This is a pure function `routeStops()` in `dispatch/model.ts` with unit tests.
- **Dispatch.** The rider is chosen by distance to the **first stop** of that route.
- **Pick up when ready.** The rider can collect from any stop that is `ready`; they no longer wait for the whole order.
- **Customer tracking** shows "Collecting from 2 of 3 stores".
- **Rider pay** counts the full route distance, plus a **multi-pickup bonus** for each extra store (`config/riders.pay.extraPickupPaise`). `pickupPoint` becomes `routeDistance()`.
- **Store caps** (`config/marketplace`), checked at quote time:
  - At most 3 stores per order.
  - At most about 2 km between stores.
  - The best-offer logic prefers offers from stores already in the cart.
  - If a cap is exceeded, the customer is asked to choose a nearer seller.

### Problems at the store
- **Store not ready when the rider arrives.** A wait timer runs and the store gets a push. After N minutes ops are alerted, and the rider gets waiting pay (`waitPaisePerMin`).
- **Item missing at handover.** Store marks the stop `issue` with "Report item issue". Ops then remove the item and part-refund it, or substitute it. The rider carries on with the rest.
- **Wrong rider or code shared.** The geofence, the attempt lock and showing the code only to the assigned rider all protect against this. Each failed attempt is logged.

### Rider app changes (`zyppi-delivery-app`)
- A multi-stop pickup list with progress and navigation for each stop.
- The pickup OTP and QR screen.
- Items-to-collect checklist for each store.
- The "waiting at store" timer.
- Removal of the self-tap "Picked up" button.

## Terms & Conditions and consent (every app and every web registration)
### One shared, versioned legal-document system
Writes go through callables only, and documents are public-read.
```
legalDocs/{type}                      type: customer_terms | privacy_policy | rider_agreement | seller_agreement | refund_policy
  currentVersion, requiresReaccept (bool), updatedAt
legalDocs/{type}/versions/{v}         title, bodyMarkdown (per language: en, bn, hi, pa), sha256, effectiveFrom, publishedBy
{users|riders|sellers}/{id}/consents/{type}_{v}
  type, version, sha256, acceptedAt (server time), method (checkbox|signature+otp),
  appId, appVersion, platform, ip (from callable rawRequest), userAgent, signaturePath?
```
- **Recording acceptance.** A single callable, `acceptLegal({type, version})`, used by every app and web form. It checks that the version is current, stores a hash of exactly the text the person saw, and is idempotent.
- **Gating.** Every registration callable (`riderApply`, `sellerApply`, and the customer's first sign-in profile) **rejects with `TERMS_NOT_ACCEPTED`** unless consent for the current version exists.
- **Updates.** When an admin publishes a new version with `requiresReaccept`, the app shows a blocking "Updated terms — review & accept" screen on its next start. This uses a shared `LegalGate` widget, ported to each app.
- **Hosting.**
  - The same documents are published as web pages on Firebase Hosting, e.g. `zyppi.app/legal/seller-agreement`. Play Store needs public URLs for the privacy policy and terms.
  - `zyppi-admin` gets a "Legal documents" editor: Markdown, preview, publish a version. It is super_admin only and audited.

### Where acceptance happens
| App / flow | Documents | Method |
|---|---|---|
| Customer app (this repo) — login/OTP screen | customer_terms, privacy_policy, refund_policy | "By continuing you agree…" with links, plus an unticked checkbox (required) |
| Rider app (`zyppi-delivery-app`) — registration | rider_agreement, privacy_policy | Scroll-to-end + checkbox + **drawn signature** + OTP confirmation |
| Zyppi Marketplace app/web — seller registration | seller_agreement, privacy_policy | Scroll-to-end + checkbox + **drawn signature** + OTP confirmation |

### The drafted documents
I'll write them into `docs/legal/*.md` and seed them into `legalDocs`. These are **drafts for a lawyer to review before go-live**; I'm not a lawyer.

- **Seller Agreement**
  - Who can sell, and the KYC needed (PAN, GSTIN, FSSAI, bank account, selfie, shop photo).
  - The two models (subscription / supply) and how the price is made up. It says plainly that **Zyppi may add a platform add-on to the seller's price, and the seller is paid only their own price**.
  - Special discounts are paid for by the seller.
  - Subscription fees and renewal, grace and expiry, and no refunds for a part-used period.
  - Payouts: hold period, deductions (dues, TCS under GST §52, TDS under Income-tax §194-O, chargebacks).
  - Product rules: FSSAI, Legal Metrology (price ≤ MRP, required labels), banned items, honest images and descriptions, and a licence for Zyppi to use the seller's images and content.
  - **Order duties:** once accepted, an order cannot be cancelled by the seller. There is an acceptance SLA, stock must be kept accurate, and handover to the rider needs the pickup OTP. Penalties and listing pauses for misses.
  - Ratings and ranking: no manipulation, and offers are ranked by price, rating and reliability.
  - Suspension and termination, indemnity, limit of liability, and confidentiality.
  - Data protection under the DPDP Act 2023: what data is collected and why, and how long it is kept.
  - **Electronic acceptance** is valid under IT Act 2000 §10A; the signature + OTP is kept as evidence.
  - Grievance officer, governing law and courts (West Bengal), and how changes to the terms are handled.
- **Rider Agreement**
  - The rider is an independent partner, not an employee.
  - Licence, vehicle papers and insurance.
  - Consent to location tracking while on duty.
  - Cash-on-delivery handling and settlement.
  - Pickup and delivery OTP duties, and no mocked GPS.
  - Rules of conduct, SOS, the pay rate card and payouts, deactivation, and the same legal clauses as the seller agreement.
- **Customer Terms + Refund Policy**
  - Accounts and eligibility.
  - Marketplace disclosure: "Sold by" the named seller, with Zyppi as the platform for those items.
  - Pricing and MRP, coupons, delivery, cancellations and refunds (timelines, how refunds reach PayU vs COD customers), the delivery OTP, ratings, and prohibited use.
- **Privacy Policy** covering all apps
  - Data collected: phone, location, selfie and KYC documents, device and payment metadata.
  - Purposes, who it is shared with (riders, sellers, PayU, Firebase/Google), how long it is kept.
  - User rights under DPDP: access, correction, erasure, withdrawing consent. Account deletion links to the existing delete-account flow.
  - Contact details of the grievance officer.

## Seller registration (Marketplace app + web): selfie, shop photo, digital signature
The steps run as a wizard that saves progress. Each step saves to `sellers/{id}` with `status: draft`, so the seller can stop and come back.

1. **Phone OTP** (Firebase Auth).
2. **Owner details:** name, email, PAN, Aadhaar last 4 (never the full number).
3. **Live selfie.**
   - **Camera only, no gallery.** It uses the front camera with on-device face detection: exactly one face, eyes open, and a blink prompt as a basic liveness check.
   - It uploads to `storage sellers/{id}/kyc/selfie.jpg` and records the capture time and device.
4. **Shop details and shop photo.**
   - Shop name, category, address with a map pin, hours.
   - **One to three shop photos from the camera**, including the signboard. Each is stamped with GPS and time and must be within about 200 m of the map pin.
   - Photos are stored in `storage sellers/{id}/shop/*`.
5. **Business and compliance:** GSTIN (optional below the threshold, but required for some categories), FSSAI number and expiry plus a photo of the certificate, and bank or UPI details. Bank details go in `private/bank`.
6. **Model and fulfilment:** subscription plan (1/3/6 months) or supply; own shop or Zyppi store.
7. **Agreement and digital signature.**
   - The seller scrolls through the Seller Agreement, ticks "I agree", and **draws a signature** on a signature pad.
   - Then an **OTP sent to the registered phone** confirms the signing. That gives intent plus identity.
   - The server records the consent row together with `signaturePath`, the document's sha256, IP, device and time.
   - A function produces a **signed agreement PDF** (agreement text + signature + selfie thumbnail + consent metadata) at `sellers/{id}/kyc/agreement_v{n}.pdf`. Both the seller and the admin can download it.
   - Later, if you want stronger signing: Aadhaar eSign through a provider such as Digio or Leegality. It is paid per signature, so it stays out of the MVP.
8. **Submit.** Status becomes `applied`. Admin reviews in `zyppi-admin`, viewing the selfie, shop photos, documents and signed PDF side by side, then approves, rejects (with a reason) or asks for changes. The seller gets a push and an inbox message.

**Rules.** The KYC Storage paths can be written only by that seller while in `draft`. They can be read only by the owner and staff (ops/finance/super_admin), and they are never public. Images are compressed on the device, and the size and content type are enforced in `storage.rules`.

**Rider registration** in `zyppi-delivery-app` gets the same building blocks: the live-selfie, signature-pad and consent steps. Only the documents differ (licence, RC, insurance).

## Device permissions (rider app + Zyppi Marketplace app)
Both apps get one **"Permissions" setup screen**. It runs after registration and again whenever a required permission is missing.
- Each row shows an icon, *why we need it* (in all 4 languages), its status and an **Allow / Open settings** button.
- The app re-checks when it comes back to the foreground.
- **Go Online stays disabled until every required permission is granted.**
- A **"Test alert"** button plays the ring and shows the overlay, so the user can check their phone.

| Permission (Android) | What it's for | Rider | Seller | Notes |
|---|---|---|---|---|
| **Display over other apps** (`SYSTEM_ALERT_WINDOW`) | Pop the incoming-order / new-offer card with slide-to-accept over any app | Required | Required | Granted in system settings (`ACTION_MANAGE_OVERLAY_PERMISSION`). Paired with **`USE_FULL_SCREEN_INTENT`** for the locked screen; Android 14+ asks the user to allow this separately. |
| **Notifications** (`POST_NOTIFICATIONS`, Android 13+) | Order and offer push, payout and approval messages | Required | Required | A high-importance "New orders" channel that **plays our ringtone with alarm-level loudness** (`USAGE_ALARM`) and vibrates. |
| **Location — precise** (`ACCESS_FINE_LOCATION`) | Exact lat/lng: rider tracking, geofenced store/customer arrival, the shop pin and photo geostamp at registration | Required | Required (registration and shop pin; foreground only) | The app refuses to continue on "Approximate only" (it checks location accuracy) and asks again. |
| **Location — all the time** (`ACCESS_BACKGROUND_LOCATION` + `FOREGROUND_SERVICE_LOCATION`) | Rider tracking while the phone is locked during a delivery | Required while on duty | Not needed | Play requires an **in-app disclosure screen** before asking and a Play Console declaration with a video. The foreground "On duty" notification shows while tracking. |
| **Alert sound ("Music and audio")** | Loud repeating order ring | — | — | **Playing our own bundled ringtone needs no permission.** Android's "Music and audio" permission (`READ_MEDIA_AUDIO`) only reads songs saved on the phone. Play may reject apps that ask for it without a reason, so we don't request it. The ring uses a foreground `mediaPlayback` service + `WAKE_LOCK` + `VIBRATE`. **Optional:** "Do Not Disturb access" (`ACCESS_NOTIFICATION_POLICY`) so the ring can sound during DND. |
| **Phone** (`CALL_PHONE`) | One-tap call to customer, store, rider or Zyppi support | Optional | Optional | Recommended: the dialer intent (`ACTION_DIAL`), which needs no permission; `CALL_PHONE` places the call directly if granted. We never ask for `READ_PHONE_STATE` or the call log, which are restricted on Play. |
| **Camera** (`CAMERA`) | Live selfie, shop/vehicle photos, QR scan for the pickup OTP | Required | Required | Asked when first used. |
| **Ignore battery optimisation** (`REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`) | Phone-maker battery savers (Xiaomi, Vivo, Oppo, Realme) otherwise kill the order ring | Required | Required | Includes a guide to "Autostart" for each phone brand. |
| **Restart after reboot** (`RECEIVE_BOOT_COMPLETED`) | Bring the online/on-duty service back after a phone restart | Yes | Yes | No user prompt. |

**Web (Marketplace registration only):** browser camera and geolocation prompts; overlay and background permissions don't apply.

**Packages to approve:**
- `permission_handler` (permission checks and requests).
- `flutter_overlay_window` (draw over other apps).
- `flutter_local_notifications` (full-screen intent and channels).
- `flutter_foreground_task` (on-duty/online foreground service).
- `just_audio` (looping ring).
- `geolocator` (precise location and its accuracy setting).

All are free. The rider app may already include some of these; check them during R1.

## How the apps are built
- **One shared Flutter package, `zyppi_kit`,** holds the pieces the three apps would otherwise copy:
  - design tokens (`ZColors/ZSpace/ZRadius`), the common widgets, `LegalGate`, the live-selfie, signature-pad and camera-with-geostamp widgets, callable error mapping, money formatting, and the shared models (Offer, Pickup stop, Consent).
  - It is used as a git dependency with a pinned tag. It could live as a folder in `Zyppi-Marketplace` at first and move to its own repo later.
- **Stack (same as today):**
  - Flutter on FVM 3.47.x, Riverpod 3 + codegen, freezed 3, go_router, feature-first folders.
  - Repository interfaces with Firebase behind them.
  - Writes **only through Cloud Functions callables**.
  - easy_localization in 4 languages, Material 3 light/dark using the tokens.
- **Flavors** dev/staging/prod for each app, using `--dart-define-from-file=env/*.json`.
- **Security:**
  - **App Check** with Play Integrity, already used in `checkAppCheck`.
  - Custom claims scoped per role.
  - Deterministic, idempotent ids for every money and status write.
  - An audit log for every admin action.
- **Reliability:**
  - Crashlytics and Analytics.
  - Remote Config / `config/features` kill switches (e.g. `marketplaceEnabled`, `sellerSignupOpen`).
  - The Firestore offline cache for the seller's product list.
- **Quality:**
  - Pure-function unit tests for all money, ranking, OTP and route logic.
  - Widget tests for each screen state (loading/empty/error/data).
  - A GitHub Actions workflow on every PR: format, analyze, test and build.
- **Web registration.** The Marketplace app is built for **Android and Flutter web**, so the same code serves the web signup on Firebase Hosting. On the web, the camera, selfie and signature steps use browser camera capture.
- **Packages to approve** for the new app and `zyppi_kit`:
  - `camera` (live selfie and shop photos), `google_mlkit_face_detection` (on-device liveness; Android only, with web falling back to a selfie-only check), `signature` (signature pad), `geolocator` (geostamp).
  - `audioplayers` or `just_audio` with `flutter_local_notifications` (looping order ring + full-screen intent), `slide_to_act` (slide to accept, or a custom widget built on `ZPressable`).
  - `pdf_lib`/`pdfkit` in `functions/` (signed agreement PDF).
  - They are free and have no Firebase billing impact. I'll confirm each before adding it.

## Things you may have missed (recommended)
1. **Legal display of the seller** (Consumer Protection (E-Commerce) Rules 2020). Marketplace listings must show the seller's name, address and contact, and the platform needs a grievance officer. Show "Sold by X" on product details, cart, order details and the invoice.
2. **GST.** You will most likely need a CA, because Zyppi becomes an e-commerce operator.
   - **TCS (GST §52):** Zyppi collects it on marketplace sellers' net sales and files GSTR-8.
   - **TDS under Income-tax §194-O** also applies.
   - **Invoices:** each seller's lines need an invoice in that seller's name. Zyppi invoices its own sales and its delivery and handling fees.
   - **Supply model:** decide whether it is *consignment* (paid on sale, as in this plan) or *outright purchase*, since the tax treatment differs.
   - Please confirm all rates with your CA. The plan stores `taxRates` in config rather than hard-coding them.
3. **FSSAI licence** for every food seller, with an expiry check. Listings are paused automatically when the licence expires.
4. **Oversell from seller shops.** These sellers also sell over the counter, so their stock in Zyppi will drift from reality. The acceptance SLA, a "mark out of stock" button and auto-pausing after misses protect customers.
5. **One cart, several sellers.** Decide whether there is one delivery fee per order or one per extra pickup. The plan keeps one fee per order, as today, and caps the number of sellers per order (config, for example 3) so delivery times don't blow out.
6. **Returns and damage.** Debit the seller when the fault is theirs, and hold settlement for the return window (`holdDays`).
7. **Seller agreement.** Record the accepted terms version and time on the seller doc, and keep a commission field ready in case a "% commission" plan is added later. It plugs straight into `pricing.ts`.
8. **Statements.** Sellers need a monthly statement of sales, add-on/margin, fees, TCS and payouts. Finance needs a margin report showing how much Zyppi earned per seller.
9. **No-cancel risk.** Sellers also sell over the counter, so an item they accepted may turn out to be out of stock. Without a cancel button, give them a **"Report item issue → Zyppi support"** action. Ops can then substitute or part-refund the item. Track this as a reliability metric that feeds the ranking.
10. **Android alert limits.** Android 14+ restricts full-screen-intent permission. The seller app must ask for it, plus exemption from battery optimisation and notification permission, during onboarding, and show a test-ring button.
11. **Anti-abuse.** Limit how often a seller can change prices, and flag sudden price jumps.

## Delivery phases
Each phase gets its own branch from `Development` (`feat/marketplace-<n>-…`) and stops at its "Done when".

- **M0 — Foundations (backend).**
  - Work: seller, plan and listing models; `requireSeller` (modelled on `requireRider` in `dispatch/rider_auth.ts`); a `sellerId` claim; `adminReviewSeller`, `adminSavePlan`, `adminSaveSeller`; rules and indexes; and a migration script that creates the `zyppi` seller plus own listings and offers from current `variants[]`.
  - Done when the unit tests for models and pricing pass.
- **M1 — Offers, ranking, quote.**
  - Work: `saveListing` (seller and admin, with add-on); the trigger that keeps offers and `areaBest` up to date; `ranking.ts`; offer-aware `quoteOrder`; and order item snapshots. Old variant-keyed carts keep working.
- **M2 — Customer app (Flutter).**
  - Domain and data:
    - New `Offer` freezed model.
    - `CatalogRepository.fetchOffers(productId, areaId)`.
    - `areaBest` used in `firebase_catalog_repository_impl.dart`.
    - `CartItem.offerId`.
  - UI:
    - Product details gets a "Sold by X ★4.3 · N more sellers" row and a bottom sheet sorted by rank.
    - "Sold by" in the cart and order details.
    - A small seller info page.
    - Built from `lib/core/widgets`, in both themes, with all four translation files.
- **M3 — Settlement and subscriptions.**
  - Work: seller ledger credits and reversals; `releaseSellerEarnings`; payouts; `checkSellerSubscriptions`; dues deduction; and the TCS/TDS lines.
- **L0 — Legal & consent** (first, because every registration depends on it).
  - Draft `docs/legal/*.md` for lawyer review; add `legalDocs`, `acceptLegal`, consent gating in the registration callables, the agreement PDF function and rules.
  - Customer app: a terms checkbox on login and a `LegalGate`.
  - Admin: the legal-document editor.
- **M1b — Multi-store pickups with OTP (backend).**
  - Work: pickup stops and codes written at placement; `storeConfirmPickup`; the geofenced `riderReachedStore`; per-stop readiness; `routeStops`/`routeDistance`; the extra-pickup bonus; and `adminForcePickup`.
  - Done when the unit tests for the route, the OTP attempts/lock and the state changes pass.
- **R1 — Rider app** (`zyppi-delivery-app`): the multi-stop pickup UI, the OTP/QR screen, the permissions setup screen, and the overlay + ring for new offers. Also the consent and signature steps in registration.
- **M4 — zyppi-admin (admin side only).**
  - Screens: sellers and KYC review, plans, listings with the add-on editor, a product-request approval queue, subscriptions, payouts and the margin report.
  - Note: the local `zyppi-admin` checkout is stale and writes directly to Firestore. Rebase on the callable-based admin first.
- **S1–S4 — Zyppi Seller app** (repo `paulatanu1/Zyppi-Marketplace`). Work starts after M1.
  - S0: project setup (flavors, Firebase, CI) and the `zyppi_kit` package.
  - S1: the registration wizard (selfie, shop photo, signature + OTP, agreement), the "under review" screen and the dashboard. Android and web.
  - S2: the permissions setup screen, the new-order overlay + looping ring, slide to accept, and the orders flow.
  - S3: products, price, discount, stock and the new-product requests.
  - S4: earnings, payouts, subscription and settings.
- **M5 — Ratings and reports.**
  - Work: per-line ratings; seller and product aggregates; ranking tuning; monthly statements; the margin report.

## Critical files
- **Backend:**
  - `functions/src/catalog/{model,products,inventory}.ts`
  - `functions/src/orders/{quote,place_order,place_paid_order}.ts`
  - `functions/src/admin/{orders,settings}.ts`, which handles cancellation reversal and store `sellerId`.
  - `functions/src/shared/{roles,callable,audit}.ts`
  - The new `functions/src/marketplace/*`.
  - Rider pickups: `functions/src/dispatch/{delivery,dispatch,earnings,model}.ts` and the handover code creation in `functions/src/orders/quote.ts`.
  - Reuse the patterns in `functions/src/dispatch/{pay,earnings}.ts` and `functions/src/riders/riders.ts`.
- **Rules and indexes:** `firestore.rules`, `firestore.indexes.json`, `storage.rules`.
- **App:**
  - Models: `lib/core/domain/{product,product_variant,cart_item,order_item}.dart`
  - Data: `lib/core/data/{catalog_repository,firebase_catalog_repository_impl}.dart`
  - Cart: `lib/core/cart/domain/{cart_line,bill_calculator}.dart`
  - Screens: `lib/features/product_details/presentation/product_details_screen.dart`, `features/my_cart/*` and `features/your_order/presentation/order_details_screen.dart`.
- **Admin:** `zyppi-admin/frontend/src/app/core/services/*`, `core/guards/auth.guard.ts`, `layout/default-layout/_nav.ts`.
- **Docs:** add Phase 7 to `docs/PLAN.md`, and seller items to `docs/PRODUCTION_CHECKLIST.md`.

## Verification
- **Backend** (unit tests only, no emulators):
  - Pure-function tests for `pricing.ts` (each model, MRP cap, percent add-on, negative margin), `ranking.ts` (Bayesian ordering, ties, out-of-stock), settlement math (hold and release, reversal, dues, TCS/TDS) and subscription state changes (active → grace → expired → renewed).
  - Then `npm --prefix functions run build`.
- **App:**
  - `fvm dart run build_runner build -d`, `fvm dart format .`, `fvm flutter analyze` (0 issues) and `fvm flutter test`.
  - Widget tests for the sellers sheet, sold-by row and old-cart fallback.
  - Android dev build on a device, checked in light and dark themes.
- **End to end on dev,** after you deploy (no `firebase deploy` from me):
  1. Create a subscription seller, a ₹50 listing and a ₹5 add-on. The customer should see ₹55.
  2. Place an order. The seller accepts it and it is delivered. The ledger should show ₹50 held, then available after the hold.
  3. Record the payout. The margin report should show ₹5.
  4. Let the subscription expire. That seller's offers should disappear.

## Added on 2026-11-17
- **Returns and damage.** Use `adminReturnSellerItem` from Orders → Return…. When the seller is at fault, it takes back their credit for those units: from held money first, otherwise from their balance. Later releases and cancellations then count only what is left. The customer refund stays a separate action (Refund…).
- **Statements.** `sellerStatement` gives a month of one seller's ledger; the seller app shows it under Earnings → Monthly statement. `adminSellerTaxReport` (Money → Seller tax) gives net sales, TCS (GSTR-8) and TDS (194-O) per seller, with a CSV for the CA.
- **Legal.** Admin → Settings → Legal documents edits and publishes versions; `publishProblems` refuses any text with `[PLACEHOLDERS]`. The rider portal's last step reads, agrees, draws a signature and confirms with an OTP, so the rider agreement can now be published.
- **Phone setup** (rider and seller apps). Notifications, display over other apps, battery exemption, full-screen alerts and location, plus a test ring. Going online needs the required ones. The seller app also runs a `remoteMessaging` foreground service while online, which restarts after a reboot, and checks selfies on the phone with ML Kit.
- **Play Console declarations.** The seller app needs the `specialUse` (overlay) and `remoteMessaging` foreground-service types, plus `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`. The rider app needs `specialUse` (overlay) and the existing background location.
