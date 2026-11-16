import { FieldValue } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import { type ProductInput, productProblems } from "../catalog/model";
import { categoryProblem, loadCategories, saveProduct } from "../catalog/products";
import { writeAudit } from "../shared/audit";
import { db } from "../shared/firebase";
import { type Actor, requireRole } from "../shared/roles";
import { SELLERS } from "./model";
import { notifySeller } from "./seller_notify";
import { requireSeller } from "./sellers";

/**
 * Sellers add or edit products through requests catalog staff review
 * (docs/MARKETPLACE.md → Seller app → Products): productRequests/{id}.
 * A new product from a seller, or an edit of one it created, goes live at
 * once when the seller is marked trusted (sellers/{id}.trustedCatalog).
 * Edits to Zyppi's master products always wait for review.
 */
export const PRODUCT_REQUESTS = "productRequests";

/** A product photo the seller uploaded to its own public folder. */
export function sellerImageOk(url: unknown, sellerId: string): url is string {
  if (typeof url !== "string" || url.length > 2048) return false;
  try {
    const u = new URL(url);
    return (
      u.protocol === "https:" &&
      u.hostname === "firebasestorage.googleapis.com" &&
      decodeURIComponent(u.pathname).includes(`/o/sellers/${sellerId}/products/`)
    );
  } catch {
    return false;
  }
}

export interface ProductRequestInput {
  productId: string | null;
  product: ProductInput;
}

/**
 * Reads what the seller app sent. Sellers don't price the master product:
 * each variant's catalog price is its MRP (Zyppi's own stock, if any, is
 * priced by catalog staff); the seller's price lives in their listing.
 */
export function readProductRequest(raw: Record<string, unknown>, sellerId: string): { input: ProductRequestInput; problems: string[] } {
  const variants = (Array.isArray(raw.variants) ? raw.variants : []).slice(0, 20).map((v: Record<string, unknown>) => ({
    id: typeof v?.id === "string" ? v.id : null,
    label: typeof v?.label === "string" ? v.label.trim() : "",
    pricePaise: Number(v?.mrpPaise),
    mrpPaise: Number(v?.mrpPaise),
  }));
  const product: ProductInput = {
    name: typeof raw.name === "string" ? raw.name.trim() : "",
    description: typeof raw.description === "string" ? raw.description.trim().slice(0, 2000) : "",
    categoryId: typeof raw.categoryId === "string" ? raw.categoryId : "",
    subcategoryId: typeof raw.subcategoryId === "string" && raw.subcategoryId ? raw.subcategoryId : null,
    imageUrl: raw.imageUrl == null || raw.imageUrl === "" ? null : (raw.imageUrl as string),
    isActive: true,
    variants,
  };
  const problems = productProblems(product);
  if (product.imageUrl && !sellerImageOk(product.imageUrl, sellerId)) problems.push("Upload the photo from the app");
  const productId = typeof raw.productId === "string" && /^[\w-]{1,128}$/.test(raw.productId) ? raw.productId : null;
  return { input: { productId, product }, problems };
}

/** Request: {productId?, name, description, categoryId, subcategoryId?, imageUrl?, variants: [{id?, label, mrpPaise}]}. */
export const sellerSubmitProduct = onCall(async (request) => {
  const me = await requireSeller(request);
  const { input, problems } = readProductRequest(request.data ?? {}, me.sellerId);
  const catProblem = categoryProblem(await loadCategories(), input.product.categoryId, input.product.subcategoryId);
  if (catProblem) problems.push(catProblem);
  if (problems.length) throw new HttpsError("invalid-argument", problems.join("; "));

  let ownProduct = !input.productId;
  if (input.productId) {
    const p = await db.collection("products").doc(input.productId).get();
    if (!p.exists) throw new HttpsError("not-found", "Product not found");
    ownProduct = p.get("createdBySeller") === me.sellerId;
  }
  const ref = db.collection(PRODUCT_REQUESTS).doc();
  await ref.create({
    sellerId: me.sellerId,
    sellerName: me.seller.get("shopName") ?? "",
    kind: input.productId ? "edit" : "new",
    productId: input.productId,
    payload: input.product,
    status: "pending",
    submittedBy: me.uid,
    at: FieldValue.serverTimestamp(),
  });
  if (ownProduct && me.seller.get("trustedCatalog") === true) {
    const auto: Actor = { uid: me.uid, role: "catalog", email: null };
    const r = await applyRequest(auto, ref.id, "approve", "Trusted seller (auto-approved)");
    return { requestId: ref.id, status: "approved", productId: r.productId };
  }
  return { requestId: ref.id, status: "pending" };
});

async function applyRequest(actor: Actor, requestId: string, action: "approve" | "reject", reason: string) {
  const ref = db.collection(PRODUCT_REQUESTS).doc(requestId);
  const req = await ref.get();
  if (!req.exists) throw new HttpsError("not-found", "Request not found");
  if (req.get("status") !== "pending") throw new HttpsError("failed-precondition", "Already reviewed");
  const sellerId = req.get("sellerId") as string;
  let productId = (req.get("productId") as string | null) ?? null;
  if (action === "approve") {
    const saved = await saveProduct(actor, { ...(req.get("payload") as Record<string, unknown>), ...(productId ? { id: productId } : {}) });
    productId = saved.id;
    if (saved.created) {
      await db.collection("products").doc(productId).update({ createdBySeller: sellerId });
    }
  }
  await ref.update({
    status: action === "approve" ? "approved" : "rejected",
    productId,
    reviewNote: reason || null,
    reviewedBy: actor.uid,
    reviewedAt: FieldValue.serverTimestamp(),
  });
  await notifySeller(sellerId, "", action === "approve" ? "product_approved" : "product_rejected");
  return { productId };
}

/** Catalog staff. Request: {requestId, action: approve|reject, reason?}. */
export const adminReviewProductRequest = onCall(async (request) => {
  const actor = requireRole(request, ["catalog"]);
  const action = request.data?.action;
  if (action !== "approve" && action !== "reject") throw new HttpsError("invalid-argument", "Invalid action");
  const reason = typeof request.data?.reason === "string" ? request.data.reason.trim().slice(0, 300) : "";
  if (action === "reject" && reason.length < 3) throw new HttpsError("invalid-argument", "Tell the seller why");
  return applyRequest(actor, String(request.data?.requestId ?? ""), action, reason);
});

/** Ops / catalog: let a seller's own products go live without review. Request: {sellerId, trusted}. */
export const adminSetSellerTrusted = onCall(async (request) => {
  const actor = requireRole(request, ["catalog"]);
  const ref = db.collection(SELLERS).doc(String(request.data?.sellerId ?? ""));
  if (!(await ref.get()).exists) throw new HttpsError("not-found", "Seller not found");
  const trusted = request.data?.trusted === true;
  await ref.update({ trustedCatalog: trusted });
  await writeAudit(actor, { action: "seller.trustedCatalog", target: ref.path, after: { trusted } });
  return { ok: true };
});
