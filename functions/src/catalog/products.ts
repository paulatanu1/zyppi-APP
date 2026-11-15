import { randomUUID } from "node:crypto";
import { FieldValue } from "firebase-admin/firestore";
import { onDocumentWritten } from "firebase-functions/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import { writeAudit } from "../shared/audit";
import { db } from "../shared/firebase";
import { productKeywords } from "../shared/keywords";
import { type Actor, requireRole } from "../shared/roles";
import {
  CATEGORIES,
  PRODUCTS,
  type ProductInput,
  type Variant,
  assertProduct,
  mergeVariants,
  productAuditView,
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

/** The stored product document (search fields derived here, once). */
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
    keywords: productKeywords(name),
  };
}

function readInput(raw: Record<string, unknown>): ProductInput {
  const variants = Array.isArray(raw.variants) ? raw.variants : [];
  return {
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
    const doc = {
      ...productDoc(input, variants),
      updatedAt: FieldValue.serverTimestamp(),
      updatedBy: actor.uid,
      ...(before ? {} : { createdAt: FieldValue.serverTimestamp() }),
    };
    tx.set(ref, doc, { merge: true });
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
  const after = event.data?.after;
  if (!after?.exists) return;
  const patch = searchFieldsPatch(after.data()!);
  if (patch) await after.ref.update(patch);
});

/** The keywords / variantIds fix-up for a product, or null if in step. */
export function searchFieldsPatch(
  data: Record<string, unknown>,
): { keywords: string[]; variantIds: string[] } | null {
  const name = typeof data.name === "string" ? data.name : "";
  const variants = Array.isArray(data.variants) ? (data.variants as Partial<Variant>[]) : [];
  const keywords = productKeywords(name);
  const variantIds = variants.map((v) => v?.id).filter((x): x is string => typeof x === "string");
  if (sameList(data.keywords, keywords) && sameList(data.variantIds, variantIds)) return null;
  return { keywords, variantIds };
}

function sameList(a: unknown, b: string[]): boolean {
  return Array.isArray(a) && a.length === b.length && a.every((x, i) => x === b[i]);
}
