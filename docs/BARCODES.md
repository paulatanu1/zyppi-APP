# Barcodes and product identification (ADR)

Status: accepted 2026-11-24. Scope: seller app (scan → identify → request a product), catalog staff in the admin panel (barcode per variant, review). The customer app does not scan yet; `barcodes/{gtin}` is public-read so it can later, without a function call.

## Decisions

**Canonical key: GTIN-14.** Every EAN-13, EAN-8, UPC-A and UPC-E is checked with the GS1 mod-10 check digit and stored as a 14-digit, zero-padded **string** (never a number). UPC-E is expanded to UPC-A first. The same item scanned as UPC-A or EAN-13 gives the same key. Code: `functions/src/catalog/gtin.ts`, mirrored in the seller app at `lib/core/barcode/gtin.dart` with the same test vectors. The server re-validates every code.

**Rejected codes.**
- In-store and variable-measure codes (EAN-13 20–29, UPC number system 2, EAN-8 starting 0/2) encode price or weight and are not unique. These items are added by hand, without a barcode.
- Restricted codes (UPC 04x, coupons 05x/98x/99x, refund receipts) are rejected.
- Code 128 and QR are rejected because the catalogue has no internal SKUs. A Code 128 value is never treated as a GTIN.

**Uniqueness scope: one GTIN → one (product, variant)** across the shared master catalogue. A barcode identifies a pack size, so it lives on `variants[].gtin`. Sellers don't own products; they list variants, so any number of sellers share one barcode.

**Reservation.** `barcodes/{gtin14}` = `{productId, variantId, updatedAt}` is written only inside `saveProduct`'s transaction (`functions/src/catalog/products.ts`):
- the transaction reads, and so locks, the reservation;
- it refuses one that another product still carries (`already-exists DUPLICATE_BARCODE {gtin, productId}`);
- it `create`s new reservations, takes over stale ones, and releases removed ones.

Two concurrent approvals of the same GTIN serialize, and one gets the error. `sellerSubmitProduct` pre-checks for a friendly early error (`DUPLICATE_BARCODE`, `BARCODE_PENDING`); that check is advisory. Edits that don't send `gtin` keep it (`mergeVariants`), so the admin editor and the import never drop barcodes silently.

**Lookup: one callable, `sellerLookupBarcode`** (approved seller or `catalog` staff, App Check, 20 calls/min per user). It checks in this order:
1. `barcodes/{gtin}`: Zyppi already sells it. The app opens "Sell this".
2. A pending `productRequests` entry with the gtin: someone already asked. No other seller's details are shown.
3. `barcodeLookups/{gtin}`: cached answer. "Found" is kept 30 days (product data changes slowly; a re-scan after that refreshes it). "Not found" is kept 24 hours, so a product added to OFF shows up the next day.
4. Open Food Facts API **v3** (`/api/v3/product/{code}?product_type=all&fields=…`). v3 is the current API and v2 is deprecated. `product_type=all` redirects to Open Beauty, Open Pet Food and Open Products Facts, so one call covers all four databases.

Failure handling: 429, 503, other 5xx, timeouts (6 s), network errors and unreadable bodies are **"unavailable"**. They are never cached and never shown as "not found". The app then offers manual entry. Identical concurrent lookups on an instance share one call.

The catalogue check goes through the function instead of a direct Firestore read so that one round trip returns every outcome, other sellers' pending requests stay private, and OFF calls stay off devices.

**OFF rate limit.** OFF allows 15 product reads per minute **per IP**. Calls from a function share the Cloud Functions egress IPs, so all sellers share that budget. Calls made directly from phones would count per user but give us no control over abuse or the User-Agent. We cap at 6 OFF calls per minute per instance; functions run on at most 2 instances (`shared/scaling.ts`). Above the cap the answer is "unavailable (busy)" and manual entry still works. If volume grows, import OFF's JSONL dump instead of raising the cap. The User-Agent is `ZyppiSeller/1.0 (<OFF_CONTACT>)`, where `OFF_CONTACT` is a functions param (default `https://zyppi.in`).

**Untrusted data.** OFF answers are mapped by hand (`off_map.ts`):
- text is trimmed, markup and control characters are stripped, and length is capped;
- numbers must be finite and in range;
- tags become plain words;
- images are accepted only as https links on `images.open*facts.org`;
- the raw JSON is never stored.

Nutrition keeps its **basis** (per 100 g, per 100 ml or per serving with the serving size) and is in grams, with energy in kcal and kJ. Out-of-range values are dropped. When a pair disagrees, the less reliable value goes: kJ vs kcal (Indian labels print kcal), sugars above carbohydrates, saturated fat above fat. If macros add up to more than 100 g per 100 g, the whole table is discarded. The same checks run on what people submit (`details.ts`).

**Review, provenance, no auto-save.** Nothing from OFF reaches the catalogue without a person:
1. The seller reviews and corrects the data and adds their **own photo**.
2. `sellerSubmitProduct` creates a `productRequests` entry.
3. Catalog staff approve it (trusted sellers' own products are auto-approved, as before).

`details.provenance` records per field whether a value is `off`, `off_edited` or `manual`. `details.source` records `{provider, url, fetchedAt}` for attribution. The server keeps OFF provenance only if it really looked that barcode up (a "found" `barcodeLookups` entry); otherwise those fields count as manual. There is no "verified" flag: the existing approval step is the review.

**Licence (decided: pre-fill only, own photos).**
- OFF data is ODbL and its images are CC BY-SA. OFF only pre-fills the form. What is stored is each reviewed record with its provenance and source link; the raw payload lives only in the expiring cache.
- OFF images are shown only as a reference, captioned "Photo: Open Food Facts, CC BY-SA", and are **never copied** to Storage.
- Wherever OFF-sourced fields are shown (seller review screen, admin request review), the attribution "Product data from Open Food Facts (ODbL)" links to the product page.
- Before customers are shown OFF-derived details, have the lawyer confirm the share-alike position.

## Data
- `products/{id}`: `variants[].gtin?`, `brand?`, `details?`. Only callables write products, barcodes and the cache. Rules: `barcodes` public read, no writes; `barcodeLookups` no client access.
- `productRequests/{id}`: `payload.brand`, `payload.details`, `payload.variants[].gtin`, and a top-level `gtins[]`. Index: `(gtins CONTAINS, status)`.
- `barcodeLookups/{gtin}`: `{status: found|not_found, product, fetchedAt, expireAt}`. TTL policy on `expireAt` (fieldOverrides in `firestore.indexes.json`); expiry is also checked at read time.
- Migration: no product has a barcode today, so there is nothing to backfill. Existing ids are unchanged.

## Cost per seller scan
| Path | Reads | Writes | Invocations | OFF |
|---|---|---|---|---|
| Catalogue hit | 2 | 0 | 1 | 0 |
| Cache hit | 3 | 0 | 1 | 0 |
| OFF found / not found | 3 | 1 | 1 | 1 |

At 1,000 scans a day, the worst case is about 3k reads and 1k writes a day plus 30k invocations a month. That is within the free quotas. The seller app also caches results for 10 minutes per session.

## Deploy (run by you)
1. Optional: in `functions/.env.zippy-app-2024`, set `OFF_CONTACT=<support email or URL>`. Optionally fill in OFF's API usage form.
2. Run `npm --prefix functions test` (emulators). This includes `test/emulator/barcodes.test.ts`: concurrent creation, and rules for each role.
3. Run `firebase deploy --only firestore:rules,firestore:indexes,functions`. The index on `productRequests` has to finish building before lookups that query pending requests succeed. The TTL policy can take up to a day to activate.

## Known gaps
- Edits made in the Console or by scripts bypass the reservation transaction, so they can't be kept unique.
- A recycled GTIN can be moved by catalog staff: clear it on the old variant, then set it on the new one.
- OFF attribution follows the barcode: if a seller clears the scanned barcode before sending, the server can't confirm the lookup, so it marks every field `manual` and drops `details.source`, even when the text came from OFF.
- The admin panel shows barcodes and OFF details, but can't look a barcode up itself yet. `sellerLookupBarcode` already accepts catalog staff.
- The buyer app doesn't scan. `barcodes/{gtin}` is public-read, so a later buyer scan can be 1 read with no function call.
- Android can't tell "denied" from "denied permanently". The scanner always shows Try again and Open settings, and retries on return only after Settings was opened.

## Clients
- Seller app (`Zyppi-Marketplace`): `lib/core/barcode/gtin.dart` mirrors `gtin.ts`. `lib/features/barcode/` holds the scanner, the lookup cache (10 min, in flight shared, never caches `unavailable`), the flow, and the review values (provenance, nutrition checks). `lib/features/products/request_product_screen.dart` is the review form.
- Admin (`zyppi-delivery-admin`): `features/catalog/gtin.ts` is a copy of `gtin.ts`. The product editor has a brand field and a barcode per size. Product requests show barcodes, details, provenance and the source link.
