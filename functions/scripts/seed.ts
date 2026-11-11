/**
 * Seeds the catalog into Firestore + Storage (ported from the retired
 * Supabase seed.sql; see git history).
 * Idempotent: re-running overwrites the same documents and images.
 *
 *   # Emulators (from the repo root, `firebase emulators:start` running):
 *   FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 FIREBASE_STORAGE_EMULATOR_HOST=127.0.0.1:9199 \
 *     npm --prefix functions run seed
 *
 *   # Real project (uses your gcloud application-default credentials):
 *   gcloud auth application-default login
 *   npm --prefix functions run seed -- --project zippy-app-2024
 *
 * Stock: 100 units of every variant at every store.
 */
import { randomUUID } from "node:crypto";
import { readFileSync } from "node:fs";
import { join } from "node:path";
import { initializeApp } from "firebase-admin/app";
import { getFirestore, Timestamp } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import { productKeywords } from "../src/shared/keywords";

const projectArg = process.argv.indexOf("--project");
const projectId =
  projectArg > -1 ? process.argv[projectArg + 1] : (process.env.GCLOUD_PROJECT ?? "demo-zyppi");
const bucketName = `${projectId}.firebasestorage.app`;
const emulated = !!process.env.FIRESTORE_EMULATOR_HOST;

initializeApp({ projectId, storageBucket: bucketName });
const db = getFirestore();
const bucket = getStorage().bucket();

const ASSETS = join(__dirname, "..", "..", "assets", "images");

// Storage object path → local asset (same pairs as the retired
// scripts/upload_catalog_images.sh).
const IMAGES: Record<string, string> = {
  "categories/category.png": "category.png",
  "categories/bread.png": "bread.png",
  "categories/rice.png": "rice.png",
  "categories/oil.png": "oil.png",
  "categories/meat.png": "meat.png",
  "categories/beverages.png": "beverages.png",
  "products/veg.png": "veg.png",
  "products/apple.png": "apple.png",
  "products/bread.png": "bread.png",
  "products/rice.png": "rice.png",
  "products/oil.png": "oil.png",
  "products/meat.png": "meat.png",
  "products/milk.png": "milk.png",
  "products/item.png": "item.png",
};

const urls = new Map<string, string>();

async function upload(path: string): Promise<string> {
  const cached = urls.get(path);
  if (cached) return cached;
  const objectPath = `catalog/${path}`;
  const token = randomUUID();
  await bucket.file(objectPath).save(readFileSync(join(ASSETS, IMAGES[path])), {
    contentType: "image/png",
    metadata: { metadata: { firebaseStorageDownloadTokens: token } },
  });
  const host = emulated
    ? `http://${process.env.FIREBASE_STORAGE_EMULATOR_HOST}`
    : "https://firebasestorage.googleapis.com";
  const url = `${host}/v0/b/${bucketName}/o/${encodeURIComponent(objectPath)}?alt=media&token=${token}`;
  urls.set(path, url);
  return url;
}

const AREA = (n: number) => `11111111-0000-0000-0000-00000000000${n}`;
const STORE = (n: number) => `22222222-0000-0000-0000-00000000000${n}`;
const CAT = (n: number) => `33333333-0000-0000-0000-00000000000${n}`;
// Sub-categories (`categories` docs with a `parentId`): the category
// page's left rail.
const SUBCAT = (n: number) => `33333333-1111-0000-0000-${String(n).padStart(12, "0")}`;
const PROD = (n: number) => `44444444-0000-0000-0000-00000000000${n}`;
const VAR = (n: number) => `55555555-0000-0000-0000-00000000000${n}`;
const SLOT = (n: number) => `66666666-0000-0000-0000-00000000000${n}`;
const SECTION = (n: number) => `77777777-0000-0000-0000-00000000000${n}`;

// Approximate town centres; refine against real dark-store addresses.
const areas = [
  { id: AREA(1), name: "Purulia", centerLat: 23.3324, centerLng: 86.3617, radiusMeters: 6000 },
  { id: AREA(2), name: "Raghunathpur", centerLat: 23.5667, centerLng: 86.6667, radiusMeters: 5000 },
  { id: AREA(3), name: "Chelyama", centerLat: 23.4833, centerLng: 86.6333, radiusMeters: 4000 },
];

const stores = [
  { id: STORE(1), serviceAreaId: AREA(1), name: "Zyppi Purulia Dark Store" },
  { id: STORE(2), serviceAreaId: AREA(2), name: "Zyppi Raghunathpur Dark Store" },
  { id: STORE(3), serviceAreaId: AREA(3), name: "Zyppi Chelyama Dark Store" },
];

const categories = [
  [CAT(1), "Fresh Fruits & Vegetables", "categories/category.png", "1A53B175", "FF53B175"],
  [CAT(2), "Bread & Eggs", "categories/bread.png", "FFFFECF7", "FFFB54B6"],
  [CAT(3), "Atta, Rice & Dals", "categories/rice.png", "1AF8A44C", "FFFABD7C"],
  [CAT(4), "Masala & Dry Fruits", "categories/category.png", "FFEDF7FD", "FF52BAF4"],
  [CAT(5), "Cooking Oil & Ghee", "categories/oil.png", "1AF8A44C", "B2F8A44C"],
  [CAT(6), "Meat & Fish", "categories/meat.png", "3FF7A593", "FFF7A593"],
  [CAT(7), "Bakery & Snacks", "categories/bread.png", "3FFDE598", "FFFDE598"],
  [CAT(8), "Beverages", "categories/beverages.png", "3FB7DFF5", "FFB7DFF5"],
] as const;

// [id, parentId, name, image]
const subcategories = [
  [SUBCAT(1), CAT(1), "Fresh Fruits", "products/apple.png"],
  [SUBCAT(2), CAT(1), "Daily Veggies", "products/veg.png"],
  [SUBCAT(3), CAT(1), "Exotic", "categories/category.png"],
  [SUBCAT(4), CAT(2), "Bread", "products/bread.png"],
  [SUBCAT(5), CAT(2), "Eggs", "categories/bread.png"],
  [SUBCAT(6), CAT(8), "Milk", "products/milk.png"],
  [SUBCAT(7), CAT(8), "Juices & Drinks", "categories/beverages.png"],
] as const;

type V = [string, string, number, number];
const products: {
  id: string;
  categoryId: string;
  subcategoryId?: string;
  name: string;
  image: string;
  description: string;
  variants: V[];
}[] = [
  {
    id: PROD(1), categoryId: CAT(1), subcategoryId: SUBCAT(2), name: "Fresh Tomatoes", image: "products/veg.png",
    description: "Farm-fresh red tomatoes, picked ripe for curries, salads and chutneys.",
    variants: [[VAR(1), "500 g", 2500, 3000]],
  },
  {
    id: PROD(2), categoryId: CAT(1), subcategoryId: SUBCAT(1), name: "Apple", image: "products/apple.png",
    description: "Crisp, sweet apples — a ready snack and great in salads.",
    variants: [[VAR(2), "1 kg", 18000, 20000]],
  },
  {
    id: PROD(3), categoryId: CAT(2), subcategoryId: SUBCAT(4), name: "Brown Bread", image: "products/bread.png",
    description: "Soft whole-wheat brown bread, baked fresh for sandwiches and toast.",
    variants: [[VAR(3), "400 g", 4500, 5000]],
  },
  {
    id: PROD(4), categoryId: CAT(3), name: "Basmati Rice", image: "products/rice.png",
    description: "Long-grain aged basmati rice that cooks up fluffy and fragrant.",
    variants: [[VAR(4), "1 kg", 14500, 16000], [VAR(5), "5 kg", 68000, 75000]],
  },
  {
    id: PROD(5), categoryId: CAT(5), name: "Sunflower Oil", image: "products/oil.png",
    description: "Light sunflower oil for everyday frying and cooking.",
    variants: [[VAR(6), "1 L", 15000, 17000]],
  },
  {
    id: PROD(6), categoryId: CAT(6), name: "Chicken Curry Cut", image: "products/meat.png",
    description: "Fresh, cleaned chicken curry cut, bone-in, ready to cook.",
    variants: [[VAR(7), "500 g", 15500, 17500]],
  },
  {
    id: PROD(7), categoryId: CAT(8), subcategoryId: SUBCAT(6), name: "Toned Milk", image: "products/milk.png",
    description: "Pasteurised toned milk, delivered chilled.",
    variants: [[VAR(8), "1 L", 6400, 6800]],
  },
  {
    id: PROD(8), categoryId: CAT(7), name: "Butter Cookies", image: "products/item.png",
    description: "Crunchy, buttery cookies — perfect with tea.",
    variants: [[VAR(9), "200 g", 5600, 6000]],
  },
];

const slots = [
  [SLOT(1), "In 12 minutes", 12, true],
  [SLOT(2), "Today, 4:00 PM - 6:00 PM", 180, false],
  [SLOT(3), "Today, 6:00 PM - 8:00 PM", 300, false],
  [SLOT(4), "Tomorrow, 8:00 AM - 10:00 AM", 900, false],
  [SLOT(5), "Tomorrow, 10:00 AM - 12:00 PM", 1020, false],
] as const;

// Home sections. `items[].data` keeps the snake_case keys the app's
// section widgets read (category_id, image_url, …).
const homeSections: {
  id: string;
  type: string;
  title: string | null;
  config: Record<string, unknown>;
  items: Record<string, unknown>[];
}[] = [
  {
    id: SECTION(1), type: "category_tabs", title: null, config: { sticky: true },
    items: [
      { label: "All", icon: "grid_view" },
      { label: "Fruits & Veg", icon: "eco", category_id: CAT(1) },
      { label: "Dairy & Bakery", icon: "bakery_dining", category_id: CAT(2) },
      { label: "Beverages", icon: "local_drink", category_id: CAT(8) },
    ],
  },
  {
    id: SECTION(2), type: "banner_carousel", title: null, config: { autoplay: true },
    items: [
      { title: "Fresh fruits, flat 20% off", cta_text: "Shop now", link_type: "category", link_target: CAT(1), image_url: "products/apple.png" },
      { title: "Free delivery above ₹299", cta_text: "Order now", link_type: "category", link_target: null, image_url: "categories/category.png" },
    ],
  },
  {
    id: SECTION(3), type: "category_grid", title: "Shop by category", config: { columns: 4 },
    items: [1, 2, 3, 4, 5, 6, 7, 8].map((n) => ({ category_id: CAT(n) })),
  },
  {
    id: SECTION(4), type: "product_carousel", title: "Deals for you", config: {},
    items: [1, 2, 7, 8].map((n) => ({ product_id: PROD(n) })),
  },
  {
    id: SECTION(5), type: "category_cluster", title: "Frequently bought", config: {},
    items: [
      { label: "Fruits & Vegetables", category_id: CAT(1), count: 8 },
      { label: "Atta, Rice & Dals", category_id: CAT(3), count: 10 },
      { label: "Oil & Ghee", category_id: CAT(5), count: 3 },
    ],
  },
  {
    id: SECTION(6), type: "spotlight_cards", title: "Featured this week", config: {},
    items: [
      { badge: "Newly launched", product_id: PROD(6) },
      { badge: "Featured", product_id: PROD(5) },
      { badge: "Customer favourite", product_id: PROD(4) },
    ],
  },
];

async function main() {
  console.log(`Seeding ${projectId}${emulated ? " (emulators)" : ""}…`);
  const batch = db.batch();
  const now = Timestamp.now();

  for (const a of areas) {
    batch.set(db.collection("serviceAreas").doc(a.id), { ...a, isActive: true });
  }
  for (const s of stores) {
    batch.set(db.collection("stores").doc(s.id), { ...s, isActive: true });
  }
  for (const [id, name, image, colorHex, borderColorHex] of categories) {
    batch.set(db.collection("categories").doc(id), {
      name, imageUrl: await upload(image), colorHex, borderColorHex,
      sortOrder: categories.findIndex((c) => c[0] === id),
      parentId: null,
    });
  }
  for (const [i, [id, parentId, name, image]] of subcategories.entries()) {
    const parent = categories.find((c) => c[0] === parentId)!;
    batch.set(db.collection("categories").doc(id), {
      name, imageUrl: await upload(image), colorHex: parent[3], borderColorHex: parent[4],
      // After every top-level category, in rail order.
      sortOrder: categories.length + i,
      parentId,
    });
  }
  for (const p of products) {
    batch.set(db.collection("products").doc(p.id), {
      name: p.name,
      imageUrl: await upload(p.image),
      description: p.description,
      categoryId: p.categoryId,
      subcategoryId: p.subcategoryId ?? null,
      isActive: true,
      keywords: productKeywords(p.name),
      variants: p.variants.map(([id, label, pricePaise, mrpPaise]) => ({ id, label, pricePaise, mrpPaise })),
      // Lets the admin panel find a variant's product (array-contains).
      variantIds: p.variants.map(([id]) => id),
      createdAt: now,
    });
    for (const s of stores) {
      for (const [variantId] of p.variants) {
        batch.set(db.collection("inventory").doc(`${s.id}_${variantId}`), {
          storeId: s.id, variantId, productId: p.id, quantity: 100, updatedAt: now,
        });
      }
    }
  }
  for (const [id, label, etaMinutes, isExpress] of slots) {
    batch.set(db.collection("deliverySlots").doc(id), { label, etaMinutes, isExpress, isActive: true });
  }
  batch.set(db.collection("coupons").doc("ZYPPI50"), {
    description: "Flat ₹50 off on orders above ₹300",
    discountPaise: 5000, minOrderPaise: 30000, isActive: true, expiresAt: null, createdAt: now,
  });
  for (const [order, s] of homeSections.entries()) {
    const items = [];
    for (const [i, data] of s.items.entries()) {
      const resolved = { ...data };
      if (typeof resolved.image_url === "string") resolved.image_url = await upload(resolved.image_url);
      items.push({ id: `${s.id}-${i}`, data: resolved });
    }
    batch.set(db.collection("homeSections").doc(s.id), {
      type: s.type, title: s.title, subtitle: null, config: s.config,
      displayOrder: order, isActive: true, items,
    });
  }

  await batch.commit();
  console.log("Done.");
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
