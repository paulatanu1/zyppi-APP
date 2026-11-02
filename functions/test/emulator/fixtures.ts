import { db } from "../../src/shared/firebase";

export const UID = "user-1";
export const AREA = "area-1";
export const STORE_A = "store-a";
export const STORE_B = "store-b";
export const SLOT = "slot-1";

/** Wipes the emulator and loads a small catalog + one user's cart. */
export async function resetData(cart: Record<string, number> = { "v-milk": 2 }) {
  const host = process.env.FIRESTORE_EMULATOR_HOST;
  await fetch(
    `http://${host}/emulator/v1/projects/${process.env.GCLOUD_PROJECT}/databases/(default)/documents`,
    { method: "DELETE" },
  );

  const b = db.batch();
  b.set(db.doc(`serviceAreas/${AREA}`), {
    name: "Purulia", isActive: true, centerLat: 23.3324, centerLng: 86.3617, radiusMeters: 6000,
  });
  b.set(db.doc(`stores/${STORE_A}`), { serviceAreaId: AREA, name: "A", isActive: true });
  b.set(db.doc(`stores/${STORE_B}`), { serviceAreaId: AREA, name: "B", isActive: true });
  b.set(db.doc(`deliverySlots/${SLOT}`), { label: "In 12 minutes", etaMinutes: 12, isExpress: true, isActive: true });
  b.set(db.doc("products/p-milk"), {
    name: "Toned Milk", isActive: true, categoryId: "c1", imageUrl: "https://x/milk.png",
    variants: [{ id: "v-milk", label: "1 L", pricePaise: 6400, mrpPaise: 6800 }],
  });
  b.set(db.doc("products/p-rice"), {
    name: "Basmati Rice", isActive: true, categoryId: "c1", imageUrl: null,
    variants: [{ id: "v-rice", label: "5 kg", pricePaise: 68000, mrpPaise: 75000 }],
  });
  b.set(db.doc(`inventory/${STORE_A}_v-milk`), { quantity: 3 });
  b.set(db.doc(`inventory/${STORE_B}_v-milk`), { quantity: 2 });
  b.set(db.doc(`inventory/${STORE_A}_v-rice`), { quantity: 10 });
  b.set(db.doc("coupons/ZYPPI50"), {
    description: "₹50 off", discountPaise: 5000, minOrderPaise: 30000, isActive: true, expiresAt: null,
  });
  b.set(db.doc(`users/${UID}/addresses/home`), {
    label: "Home", line1: "12 Station Rd", area: "Ward 5", city: "Purulia", state: "WB",
    postalCode: "723101", lat: 23.333, lng: 86.362, isDefault: true,
  });
  b.set(db.doc(`users/${UID}/addresses/far`), {
    label: "Work", line1: "Park St", area: "", city: "Kolkata", state: "WB",
    postalCode: "700016", lat: 22.55, lng: 88.35, isDefault: false,
  });
  const productOf: Record<string, string> = { "v-milk": "p-milk", "v-rice": "p-rice" };
  for (const [variantId, quantity] of Object.entries(cart)) {
    b.set(db.doc(`users/${UID}/cart/${variantId}`), { productId: productOf[variantId], quantity });
  }
  await b.commit();
}

export const params = (over: Partial<Record<string, unknown>> = {}) => ({
  uid: UID,
  addressId: "home",
  deliverySlotId: SLOT,
  couponCode: null as string | null,
  tipPaise: 0,
  paymentMethod: "Cash on delivery",
  ...over,
});
