import { randomUUID } from "node:crypto";
import { FieldValue } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import { writeAudit } from "../shared/audit";
import { db } from "../shared/firebase";
import { type Actor, requireRole } from "../shared/roles";
import { CATEGORIES, PRODUCTS, isHttpsUrl, normalizeColor } from "./model";
import { loadCategories } from "./products";

/**
 * Two levels only: top-level categories (parentId null) and their
 * sub-categories (the app's left menu). Exported for the emulator tests.
 */
export async function saveCategory(actor: Actor, raw: Record<string, unknown>) {
  const name = typeof raw.name === "string" ? raw.name.trim() : "";
  if (name.length < 2 || name.length > 60) {
    throw new HttpsError("invalid-argument", "Name must be 2–60 characters");
  }
  const parentId = typeof raw.parentId === "string" && raw.parentId ? raw.parentId : null;
  const imageUrl = typeof raw.imageUrl === "string" && raw.imageUrl ? raw.imageUrl : null;
  if (imageUrl && !isHttpsUrl(imageUrl)) {
    throw new HttpsError("invalid-argument", "Image must be an https:// URL");
  }
  const colorHex = normalizeColor(raw.colorHex);
  const borderColorHex = normalizeColor(raw.borderColorHex);
  const id = typeof raw.id === "string" && raw.id ? raw.id : null;

  const cats = await loadCategories();
  if (id && !cats.some((c) => c.id === id)) throw new HttpsError("not-found", "Category not found");
  if (parentId) {
    const parent = cats.find((c) => c.id === parentId);
    if (!parent) throw new HttpsError("invalid-argument", "Parent category not found");
    if (parent.parentId) throw new HttpsError("invalid-argument", "Sub-categories can’t have children");
    if (parentId === id) throw new HttpsError("invalid-argument", "A category can’t be its own parent");
    if (id && cats.some((c) => c.parentId === id)) {
      throw new HttpsError(
        "failed-precondition",
        "This category has sub-categories, so it must stay top level",
      );
    }
  }
  const siblings = cats.filter((c) => c.parentId === parentId && c.id !== id);
  const duplicate = siblings.find((c) => c.name.toLowerCase() === name.toLowerCase());
  if (duplicate) throw new HttpsError("already-exists", `“${name}” already exists here`);

  const ref = db.collection(CATEGORIES).doc(id ?? randomUUID());
  return db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const before = snap.data();
    const movedParent = before && (before.parentId ?? null) !== parentId;
    const doc: Record<string, unknown> = {
      name,
      parentId,
      imageUrl,
      colorHex,
      borderColorHex,
      updatedAt: FieldValue.serverTimestamp(),
      updatedBy: actor.uid,
    };
    // New (or moved) categories go to the end of their list.
    if (!before || movedParent) doc.sortOrder = siblings.length;
    tx.set(ref, doc, { merge: true });
    writeAudit(
      actor,
      {
        action: before ? "category.update" : "category.create",
        target: `${CATEGORIES}/${ref.id}`,
        before: before ? { name: before.name, parentId: before.parentId ?? null } : null,
        after: { name, parentId },
      },
      tx,
    );
    return { id: ref.id };
  });
}

/** Refuses while anything still points at the category. */
export async function deleteCategory(actor: Actor, id: string) {
  const ref = db.collection(CATEGORIES).doc(id);
  const snap = await ref.get();
  if (!snap.exists) throw new HttpsError("not-found", "Category not found");
  const [children, asCategory, asSub] = await Promise.all([
    db.collection(CATEGORIES).where("parentId", "==", id).limit(1).get(),
    db.collection(PRODUCTS).where("categoryId", "==", id).limit(1).get(),
    db.collection(PRODUCTS).where("subcategoryId", "==", id).limit(1).get(),
  ]);
  if (!children.empty) {
    throw new HttpsError("failed-precondition", "Delete or move its sub-categories first");
  }
  if (!asCategory.empty || !asSub.empty) {
    throw new HttpsError("failed-precondition", "Products still use this category. Move them first");
  }
  await ref.delete();
  await writeAudit(actor, {
    action: "category.delete",
    target: `${CATEGORIES}/${id}`,
    before: { name: snap.get("name"), parentId: snap.get("parentId") ?? null },
    after: null,
  });
  return { ok: true };
}

/** New order of one level (all siblings, top to bottom). */
export async function reorderCategories(actor: Actor, parentId: string | null, ids: unknown) {
  if (!Array.isArray(ids) || ids.length === 0 || ids.length > 200) {
    throw new HttpsError("invalid-argument", "Invalid order");
  }
  const cats = await loadCategories();
  const siblings = cats.filter((c) => c.parentId === parentId).map((c) => c.id);
  const same =
    ids.length === siblings.length && siblings.every((s) => (ids as unknown[]).includes(s));
  if (!same) throw new HttpsError("failed-precondition", "The list changed. Reload and try again");
  const batch = db.batch();
  (ids as string[]).forEach((id, i) =>
    batch.update(db.collection(CATEGORIES).doc(id), { sortOrder: i }),
  );
  await batch.commit();
  await writeAudit(actor, {
    action: "category.reorder",
    target: parentId ? `${CATEGORIES}/${parentId}` : CATEGORIES,
    before: null,
    after: { order: ids },
  });
  return { ok: true };
}

export const adminSaveCategory = onCall(async (request) =>
  saveCategory(requireRole(request, ["catalog"]), (request.data ?? {}) as Record<string, unknown>),
);

export const adminDeleteCategory = onCall(async (request) => {
  const id = request.data?.id;
  if (typeof id !== "string" || !id) throw new HttpsError("invalid-argument", "Invalid id");
  return deleteCategory(requireRole(request, ["catalog"]), id);
});

export const adminReorderCategories = onCall(async (request) => {
  const parentId =
    typeof request.data?.parentId === "string" && request.data.parentId ? request.data.parentId : null;
  return reorderCategories(requireRole(request, ["catalog"]), parentId, request.data?.ids);
});
