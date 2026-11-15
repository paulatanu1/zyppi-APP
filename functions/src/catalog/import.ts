import { randomUUID } from "node:crypto";
import { FieldValue, type WriteBatch } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import { writeAudit } from "../shared/audit";
import { db } from "../shared/firebase";
import { type Actor, requireRole } from "../shared/roles";
import {
  PRODUCTS,
  type ProductInput,
  type Variant,
  mergeVariants,
  productAuditView,
  productProblems,
} from "./model";
import { type CategoryRow, categoryProblem, loadCategories, productDoc } from "./products";

/** One spreadsheet row = one variant. Parsed and typed by the admin panel. */
export interface ImportRow {
  /** 1-based spreadsheet row, echoed back in the report. */
  row: number;
  /** Existing product to update; empty creates a new product. */
  productId?: string | null;
  /** Groups the rows of one new product (else the name groups them). */
  key?: string | null;
  name?: string | null;
  description?: string | null;
  /** Category / sub-category id or name. */
  category?: string | null;
  subcategory?: string | null;
  variant?: string | null;
  pricePaise?: number | null;
  mrpPaise?: number | null;
  imageUrl?: string | null;
  active?: boolean | null;
}

export interface RowResult {
  row: number;
  status: "created" | "updated" | "error";
  productId?: string;
  message?: string;
}

export const MAX_IMPORT_ROWS = 300;

const text = (v: unknown) => (typeof v === "string" ? v.trim() : "");

function findCategory(cats: CategoryRow[], ref: string, parentId: string | null) {
  const want = ref.trim().toLowerCase();
  return (
    cats.find((c) => c.id === ref && c.parentId === parentId) ??
    cats.find((c) => c.parentId === parentId && c.name.trim().toLowerCase() === want)
  );
}

/**
 * Creates or updates products from spreadsheet rows. Every row is checked;
 * a product with any bad row is skipped as a whole, the rest are written.
 * Updates keep variants that aren't in the sheet. Exported for the tests.
 */
export async function importProducts(actor: Actor, rows: unknown) {
  if (!Array.isArray(rows) || rows.length === 0 || rows.length > MAX_IMPORT_ROWS) {
    throw new HttpsError("invalid-argument", `Send 1–${MAX_IMPORT_ROWS} rows per request`);
  }
  const input = rows as ImportRow[];
  const cats = await loadCategories();

  // Group rows into products.
  const groups = new Map<string, ImportRow[]>();
  for (const r of input) {
    const id = text(r.productId);
    const k = id ? `id:${id}` : text(r.key) ? `key:${text(r.key).toLowerCase()}` : `name:${text(r.name).toLowerCase()}|${text(r.category).toLowerCase()}`;
    groups.set(k, [...(groups.get(k) ?? []), r]);
  }

  const existingIds = [...groups.keys()].filter((k) => k.startsWith("id:")).map((k) => k.slice(3));
  const existing = new Map(
    existingIds.length
      ? (await db.getAll(...existingIds.map((id) => db.collection(PRODUCTS).doc(id)))).map((s) => [s.id, s])
      : [],
  );

  const results: RowResult[] = [];
  const writes: { id: string; doc: Record<string, unknown>; before?: Record<string, unknown> }[] = [];

  for (const [key, group] of groups) {
    const fail = (message: string) =>
      group.forEach((r) => results.push({ row: r.row, status: "error", message }));
    const pick = (f: keyof ImportRow) => group.map((r) => r[f]).find((v) => v != null && v !== "");

    const productId = key.startsWith("id:") ? key.slice(3) : null;
    const snap = productId ? existing.get(productId) : undefined;
    if (productId && !snap?.exists) {
      fail(`No product with id ${productId}`);
      continue;
    }
    const before = snap?.data();

    // Category: from the sheet, else (updates) keep the current one.
    const catRef = text(pick("category"));
    const cat = catRef ? findCategory(cats, catRef, null) : undefined;
    if (catRef && !cat) {
      fail(`Unknown category “${catRef}”`);
      continue;
    }
    const categoryId = cat?.id ?? (before?.categoryId as string | undefined) ?? "";
    const subRef = text(pick("subcategory"));
    const sub = subRef ? findCategory(cats, subRef, categoryId) : undefined;
    if (subRef && !sub) {
      fail(`Unknown sub-category “${subRef}” under this category`);
      continue;
    }
    const subcategoryId =
      sub?.id ?? (cat && cat.id !== before?.categoryId ? null : ((before?.subcategoryId as string | null) ?? null));

    const variants = group
      .filter((r) => text(r.variant) || r.pricePaise != null || r.mrpPaise != null)
      .map((r) => ({
        label: text(r.variant),
        pricePaise: Number(r.pricePaise),
        mrpPaise: Number(r.mrpPaise ?? r.pricePaise),
      }));

    const product: ProductInput = {
      name: text(pick("name")) || ((before?.name as string) ?? ""),
      description: text(pick("description")) || ((before?.description as string) ?? ""),
      categoryId,
      subcategoryId,
      imageUrl: text(pick("imageUrl")) || ((before?.imageUrl as string | null) ?? null),
      isActive: (pick("active") as boolean | undefined) ?? (before ? before.isActive !== false : true),
      variants: before && variants.length === 0 ? ((before.variants as Variant[]) ?? []) : variants,
    };
    const problems = [
      ...productProblems(product),
      ...(categoryId ? [categoryProblem(cats, categoryId, subcategoryId)].filter((p): p is string => !!p) : []),
    ];
    if (problems.length) {
      fail(problems.join("; "));
      continue;
    }

    const merged = mergeVariants((before?.variants as Variant[]) ?? [], product.variants, true);
    const id = productId ?? randomUUID();
    writes.push({ id, doc: productDoc(product, merged), before });
    group.forEach((r) =>
      results.push({ row: r.row, status: before ? "updated" : "created", productId: id }),
    );
  }

  // 1 write per product; batches of 400.
  for (let i = 0; i < writes.length; i += 400) {
    const batch: WriteBatch = db.batch();
    for (const w of writes.slice(i, i + 400)) {
      batch.set(
        db.collection(PRODUCTS).doc(w.id),
        {
          ...w.doc,
          updatedAt: FieldValue.serverTimestamp(),
          updatedBy: actor.uid,
          ...(w.before ? {} : { createdAt: FieldValue.serverTimestamp() }),
        },
        { merge: true },
      );
    }
    await batch.commit();
  }

  const created = writes.filter((w) => !w.before).length;
  const updated = writes.length - created;
  const failedRows = results.filter((r) => r.status === "error").length;
  if (writes.length) {
    await writeAudit(actor, {
      action: "product.import",
      target: PRODUCTS,
      before: null,
      after: {
        created,
        updated,
        failedRows,
        sample: writes.slice(0, 5).map((w) => productAuditView(w.doc)?.name),
      },
    });
  }
  results.sort((a, b) => a.row - b.row);
  return { created, updated, failedRows, results };
}

/** Catalog → Products → Import. Request: {rows: ImportRow[]} (≤ 300). */
export const adminImportProducts = onCall({ timeoutSeconds: 120 }, async (request) =>
  importProducts(requireRole(request, ["catalog"]), request.data?.rows),
);
