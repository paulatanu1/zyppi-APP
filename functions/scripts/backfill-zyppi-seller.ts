/**
 * One-off (Phase 7 M0, docs/MARKETPLACE.md): makes Zyppi's existing stock
 * the marketplace seller `zyppi`.
 *   - sellers/zyppi (model own, approved, fulfilment zyppi_store)
 *   - stamps every store without a sellerId as Zyppi's
 *   - one own listing per Zyppi store × product variant, at the variant's
 *     current price: listings/{storeId}_{variantId} (= the inventory id)
 * Safe to re-run: existing listings keep their prices (only missing ones
 * are created). Dry run unless --write.
 *
 *   npm --prefix functions run backfill-zyppi-seller -- --project zippy-app-2024
 *   npm --prefix functions run backfill-zyppi-seller -- --project zippy-app-2024 --write
 */
import { initializeApp } from "firebase-admin/app";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import type { Variant } from "../src/catalog/model";
import { LISTINGS, SELLERS, ZYPPI_SELLER_ID, isZyppiStore, listingIdFor } from "../src/marketplace/model";
import { priceListing } from "../src/marketplace/pricing";

const args = process.argv.slice(2);
const i = args.indexOf("--project");
const projectId = i > -1 ? args[i + 1] : process.env.GCLOUD_PROJECT;
const write = args.includes("--write");

initializeApp(projectId ? { projectId } : undefined);
const db = getFirestore();

(async () => {
  const [stores, products, existing] = await Promise.all([
    db.collection("stores").get(),
    db.collection("products").get(),
    db.collection(LISTINGS).where("sellerId", "==", ZYPPI_SELLER_ID).select().get(),
  ]);
  const have = new Set(existing.docs.map((d) => d.id));
  const zyppiStores = stores.docs.filter((s) => isZyppiStore(s.get("sellerId")));
  const writer = db.bulkWriter();
  let stamped = 0;
  let created = 0;
  let skipped = 0;

  if (write) {
    writer.set(
      db.collection(SELLERS).doc(ZYPPI_SELLER_ID),
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
  }

  for (const s of zyppiStores) {
    if (s.get("sellerId") == null) {
      stamped++;
      if (write) writer.update(s.ref, { sellerId: ZYPPI_SELLER_ID, fulfilment: "zyppi_store" });
    }
    for (const p of products.docs) {
      for (const v of (p.get("variants") as Variant[] | undefined) ?? []) {
        const id = listingIdFor(s.id, ZYPPI_SELLER_ID, v.id);
        if (have.has(id)) continue;
        let price;
        try {
          price = priceListing({ model: "own", mrpPaise: v.mrpPaise, sellerPricePaise: 0, zyppiPricePaise: v.pricePaise });
        } catch (e) {
          skipped++;
          console.warn(`skip ${p.id}/${v.id} (${v.label}): ${(e as Error).message}`);
          continue;
        }
        created++;
        if (write) {
          writer.create(db.collection(LISTINGS).doc(id), {
            sellerId: ZYPPI_SELLER_ID,
            storeId: s.id,
            serviceAreaId: s.get("serviceAreaId") ?? null,
            productId: p.id,
            variantId: v.id,
            model: "own",
            sellerPricePaise: 0,
            zyppiPricePaise: v.pricePaise,
            mrpPaise: v.mrpPaise,
            addon: null,
            specialDiscount: null,
            ...price,
            isActive: p.get("isActive") === true,
            updatedBy: "backfill-zyppi-seller",
            createdAt: FieldValue.serverTimestamp(),
            updatedAt: FieldValue.serverTimestamp(),
          });
        }
      }
    }
  }
  await writer.close();
  console.log(
    `${write ? "Wrote" : "Dry run —"} seller ${ZYPPI_SELLER_ID}; ${stamped} store(s) stamped; ` +
      `${created} listing(s) ${write ? "created" : "to create"}; ${skipped} skipped; ${have.size} already there.`,
  );
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
