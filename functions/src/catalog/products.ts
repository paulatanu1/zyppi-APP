import { randomUUID } from "node:crypto";
import { FieldValue } from "firebase-admin/firestore";
import { onDocumentWritten } from "firebase-functions/firestore";
import { rebuildProductOffers } from "../marketplace/offers_sync";
import { HttpsError, onCall } from "firebase-functions/https";
import { writeAudit } from "../shared/audit";
import { db } from "../shared/firebase";
import { productKeywords } from "../shared/keywords";
import { type Actor, requireRole } from "../shared/roles";
import {
  BARCODES,
  CATEGORIES,
  PRODUCTS,
  type ProductInput,
  type Variant,
  assertProduct,
  mergeVariants,
  productAuditView,
  readBrandField,
  readDetailsField,
  readGtinField,
} from "./model";

export interface CategoryRow {
  id: string;
  name: string;
  parentId: string | null;
}

export async function loadCategories(): Promise<CategoryRow[]> {
  const snap = await db.collection(CATEGORIES).get();
  return snap.docs.map((d) => ({
    id: d.id,
    name: (d.get("name") as string) ?? "",
    parentId: (d.get("parentId") as string | null | undefined) ?? null,
  }));
}

/** Category must be top level; the sub-category (if any) must sit under it. */
export function categoryProblem(
  cats: CategoryRow[],
  categoryId: string,
  subcategoryId: string | null,
): string | null {
  const cat = cats.find((c) => c.id === categoryId);
  if (!cat) return "Category not found";
  if (cat.parentId) return "Pick a top-level category (the sub-category goes separately)";
  if (subcategoryId) {
    const sub = cats.find((c) => c.id === subcategoryId);
    if (!sub) return "Sub-category not found";
    if (sub.parentId !== categoryId) return "That sub-category belongs to another category";
  }
  return null;
}

/** Brand words searchable like the name ("amul" finds Amul Taaza). */
export function brandWords(brand: unknown): string[] {
  if (typeof brand !== "string") return [];
  return brand
    .toLowerCase()
    .replace(/[^\p{L}\p{N}\s]/gu, " ")
    .split(/\s+/)
    .filter((w) => w.length >= 2);
}

/**
 * The stored product document (search fields derived here, once). brand /
 * details are written only when the input has them (merge keeps the rest).
 */
export function productDoc(p: ProductInput, variants: Variant[]) {
  const name = p.name.trim();
  return {
    name,
    description: p.description.trim(),
    categoryId: p.categoryId,
    subcategoryId: p.subcategoryId || null,
    imageUrl: p.imageUrl || null,
    isActive: p.isActive,
    variants,
    variantIds: variants.map((v) => v.id),
    keywords: productKeywords(name, brandWords(p.brand)),
    ...(p.brand !== undefined ? { brand: p.brand } : {}),
    ...(p.details !== undefined ? { details: p.details } : {}),
  };
}

/**
 * Barcode reservations to add (or re-point to another variant) and release
 * when a product's variants change. Pure, for the tests.
 */
export function planBarcodeChanges(
  before: Pick<Variant, "id" | "gtin">[],
  after: Pick<Variant, "id" | "gtin">[],
): { add: { gtin: string; variantId: string }[]; remove: string[] } {
  const was = new Map(before.filter((v) => v.gtin).map((v) => [v.gtin!, v.id]));
  const now = new Map(after.filter((v) => v.gtin).map((v) => [v.gtin!, v.id]));
  const add = [...now].filter(([g, id]) => was.get(g) !== id).map(([gtin, variantId]) => ({ gtin, variantId }));
  const remove = [...was.keys()].filter((g) => !now.has(g));
  return { add, remove };
}

export const DUPLICATE_BARCODE = "DUPLICATE_BARCODE";

/** True if `data` (another product) still carries `gtin` on a variant. */
export function productHasGtin(data: Record<string, unknown> | undefined, gtin: string): boolean {
  const variants = Array.isArray(data?.variants) ? (data!.variants as Partial<Variant>[]) : [];
  return variants.some((v) => v?.gtin === gtin);
}

function readInput(raw: Record<string, unknown>): ProductInput {
  const variants = Array.isArray(raw.variants) ? raw.variants : [];
  const { details, problems } = readDetailsField(raw.details);
  if (problems.length) throw new HttpsError("invalid-argument", problems.join("; "));
  return {
    brand: readBrandField(raw.brand),
    details,
    name: typeof raw.name === "string" ? raw.name : "",
    description: typeof raw.description === "string" ? raw.description : "",
    categoryId: typeof raw.categoryId === "string" ? raw.categoryId : "",
    subcategoryId: typeof raw.subcategoryId === "string" && raw.subcategoryId ? raw.subcategoryId : null,
    imageUrl: typeof raw.imageUrl === "string" && raw.imageUrl ? raw.imageUrl : null,
    isActive: raw.isActive !== false,
    variants: variants.map((v: Record<string, unknown>) => ({
      id: typeof v?.id === "string" ? v.id : null,
      label: typeof v?.label === "string" ? v.label : "",
      pricePaise: Number(v?.pricePaise),
      mrpPaise: Number(v?.mrpPaise),
      gtin: readGtinField(v?.gtin),
    })),
  };
}

/** Create (no id) or update a product. Exported for the emulator tests. */
export async function saveProduct(
  actor: Actor,
  raw: Record<string, unknown>,
): Promise<{ id: string; created: boolean }> {
  const input = readInput(raw);
  assertProduct(input);
  const problem = categoryProblem(await loadCategories(), input.categoryId, input.subcategoryId);
  if (problem) throw new HttpsError("invalid-argument", problem);

  const id = typeof raw.id === "string" && raw.id ? raw.id : null;
  const ref = id ? db.collection(PRODUCTS).doc(id) : db.collection(PRODUCTS).doc(randomUUID());
  return db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (id && !snap.exists) throw new HttpsError("not-found", "Product not found");
    const before = snap.data();
    const variants = mergeVariants((before?.variants as Variant[]) ?? [], input.variants);

    // Barcode uniqueness: reservations are read (and so locked) in this
    // transaction; a concurrent save of the same GTIN retries and fails.
    const plan = planBarcodeChanges((before?.variants as Variant[]) ?? [], variants);
    const addRefs = plan.add.map((a) => db.collection(BARCODES).doc(a.gtin));
    const removeRefs = plan.remove.map((g) => db.collection(BARCODES).doc(g));
    const addSnaps = addRefs.length ? await tx.getAll(...addRefs) : [];
    const removeSnaps = removeRefs.length ? await tx.getAll(...removeRefs) : [];
    const owners = addSnaps.map((s) => s.get("productId") as string | undefined);
    const otherIds = [...new Set(owners.filter((o): o is string => !!o && o !== ref.id))];
    const otherSnaps = otherIds.length ? await tx.getAll(...otherIds.map((o) => db.collection(PRODUCTS).doc(o))) : [];
    const others = new Map(otherSnaps.map((s) => [s.id, s.data()]));
    plan.add.forEach((a, i) => {
      const owner = owners[i];
      if (owner && owner !== ref.id && productHasGtin(others.get(owner), a.gtin)) {
        throw new HttpsError("already-exists", DUPLICATE_BARCODE, { gtin: a.gtin, productId: owner });
      }
    });

    const doc = {
      ...productDoc(input, variants),
      updatedAt: FieldValue.serverTimestamp(),
      updatedBy: actor.uid,
      ...(before ? {} : { createdAt: FieldValue.serverTimestamp() }),
    };
    tx.set(ref, doc, { merge: true });
    plan.add.forEach((a, i) => {
      const reservation = { productId: ref.id, variantId: a.variantId, updatedAt: FieldValue.serverTimestamp() };
      // create() where nothing was there: a racing writer can't slip in.
      if (addSnaps[i].exists) tx.set(addRefs[i], reservation);
      else tx.create(addRefs[i], reservation);
    });
    removeSnaps.forEach((s, i) => {
      if (s.get("productId") === ref.id) tx.delete(removeRefs[i]);
    });
    writeAudit(
      actor,
      {
        action: before ? "product.update" : "product.create",
        target: `${PRODUCTS}/${ref.id}`,
        before: productAuditView(before),
        after: productAuditView(doc),
      },
      tx,
    );
    return { id: ref.id, created: !before };
  });
}

/** Catalog → Products → Save. Request: product fields (+ id to update). */
export const adminSaveProduct = onCall(async (request) => {
  const actor = requireRole(request, ["catalog"]);
  return saveProduct(actor, (request.data ?? {}) as Record<string, unknown>);
});

/**
 * Safety net for edits made outside the admin callables (console, seed,
 * scripts): keeps `keywords` (app search) and `variantIds` in step with the
 * name and variants. Writes only when they differ, so it never loops.
 */
export const onProductWritten = onDocumentWritten(`${PRODUCTS}/{productId}`, async (event) => {
  const before = event.data?.before;
  const after = event.data?.after;
  // Marketplace offers follow the product's prices, MRPs and active flag
  // (Zyppi's own offers are priced from the variants). The offers rebuild
  // writes areaBest/rank back here, which changes neither, so it settles.
  if (offersDependOnChange(before?.data(), after?.data())) {
    await rebuildProductOffers(event.params.productId);
  }
  if (!after?.exists) return;
  const patch = searchFieldsPatch(after.data()!);
  if (patch) await after.ref.update(patch);
});

/** Variants (price, MRP, ids) or isActive changed, or the product came / went. */
export function offersDependOnChange(
  before: Record<string, unknown> | undefined,
  after: Record<string, unknown> | undefined,
): boolean {
  if (!before || !after) return before !== after;
  return (
    before.isActive !== after.isActive ||
    JSON.stringify(before.variants ?? null) !== JSON.stringify(after.variants ?? null)
  );
}

/** The keywords / variantIds fix-up for a product, or null if in step. */
export function searchFieldsPatch(
  data: Record<string, unknown>,
): { keywords: string[]; variantIds: string[] } | null {
  const name = typeof data.name === "string" ? data.name : "";
  const variants = Array.isArray(data.variants) ? (data.variants as Partial<Variant>[]) : [];
  const keywords = productKeywords(name, brandWords(data.brand));
  const variantIds = variants.map((v) => v?.id).filter((x): x is string => typeof x === "string");
  if (sameList(data.keywords, keywords) && sameList(data.variantIds, variantIds)) return null;
  return { keywords, variantIds };
}

function sameList(a: unknown, b: string[]): boolean {
  return Array.isArray(a) && a.length === b.length && a.every((x, i) => x === b[i]);
}
