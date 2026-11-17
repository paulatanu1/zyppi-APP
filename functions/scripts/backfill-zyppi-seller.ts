/**
 * One-off (Phase 7, docs/MARKETPLACE.md): makes Zyppi's existing stock
 * the marketplace seller `zyppi` and builds every product's offers.
 *   - sellers/zyppi (model own, approved, fulfilment zyppi_store)
 *   - stamps every store without a sellerId as Zyppi's
 *   - offers/{zyppi_<area>_<variant>} + products.{areaBest, rank} for all
 *     products (Zyppi's offers are priced from the product's variants)
 * Safe to re-run. Dry run unless --write (the dry run only counts).
 *
 *   npm --prefix functions run backfill-zyppi-seller -- --project zippy-app-2024
 *   npm --prefix functions run backfill-zyppi-seller -- --project zippy-app-2024 --write
 */
import { initializeApp } from "firebase-admin/app";
import { FieldValue, getFirestore } from "firebase-admin/firestore";

const args = process.argv.slice(2);
const i = args.indexOf("--project");
const projectId = i > -1 ? args[i + 1] : process.env.GCLOUD_PROJECT;
const write = args.includes("--write");

initializeApp(projectId ? { projectId } : undefined);
const db = getFirestore();

(async () => {
  // After initializeApp: shared/firebase reuses this app.
  const { SELLERS, ZYPPI_SELLER_ID } = await import("../src/marketplace/model.js");
  const { rebuildAllOffers } = await import("../src/marketplace/offers_sync.js");

  const [stores, products] = await Promise.all([db.collection("stores").get(), db.collection("products").select().get()]);
  const unstamped = stores.docs.filter((s) => s.get("sellerId") == null);
  if (!write) {
    console.log(
      `Dry run — would create/update sellers/${ZYPPI_SELLER_ID}, stamp ${unstamped.length} store(s) and build offers for ${products.size} product(s).`,
    );
    return;
  }

  await db.collection(SELLERS).doc(ZYPPI_SELLER_ID).set(
    {
      shopName: "Zyppi",
      model: "own",
      fulfilment: "zyppi_store",
      status: "approved",
      rating: { avg: 0, count: 0 },
      stats: { orders: 0, cancelled: 0, lateAccepts: 0 },
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
  const writer = db.bulkWriter();
  for (const s of unstamped) writer.update(s.ref, { sellerId: ZYPPI_SELLER_ID, fulfilment: "zyppi_store" });
  await writer.close();
  const r = await rebuildAllOffers();
  console.log(`Wrote sellers/${ZYPPI_SELLER_ID}; stamped ${unstamped.length} store(s); ${r.changed} offer change(s) over ${r.products} product(s).`);
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
