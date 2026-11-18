import { type DocumentReference, FieldValue, type Transaction } from "firebase-admin/firestore";
import { db } from "../shared/firebase";
import { distanceM, isPoint } from "../dispatch/model";
import type { ClaimLine } from "../wallet/model";
import { type Allocation, RETURNS, type ReturnLine, newReturnCode, splitByStore } from "./model";

/** One return to create: the doc and its two codes. */
export interface PlannedReturn {
  ref: DocumentReference;
  data: Record<string, unknown>;
  /** Where to collect: only the assigned rider and staff read it (the
   * store reads the return itself and never sees the customer). */
  customer: { addressText: string; area: string; lat: number | null; lng: number | null; phone: string | null };
  pickupCode: string;
  storeCode: string;
}

/**
 * Inside the claim's transaction, before any write: one return per store
 * the claimed units came from, with the store's place and contact read
 * now. Null when the order has no store to send items back to (then the
 * claim waits for ops).
 */
export async function readReturnPlan(
  tx: Transaction,
  input: {
    issueId: string;
    orderId: string;
    order: Record<string, unknown>;
    lines: ClaimLine[];
    resolution: string;
  },
): Promise<PlannedReturn[] | null> {
  const { order } = input;
  const items = (order.items ?? []) as { unit?: string }[];
  const allocations = ((order.allocations ?? []) as Allocation[]).filter((a) => typeof a.storeId === "string");
  const fallback = allocations[0]?.storeId ?? null;
  if (!fallback) return null;
  const byStore = splitByStore(
    input.lines.map((l) => ({
      index: l.index,
      productId: l.productId,
      variantId: l.variantId,
      name: l.name,
      unit: items[l.index]?.unit ?? "",
      quantity: l.quantity,
      kind: l.kind,
      sellerId: l.sellerId,
      amountPaise: l.amountPaise,
    })),
    allocations,
    fallback,
  );
  const storeIds = [...byStore.keys()];
  const stores = await tx.getAll(...storeIds.map((id) => db.collection("stores").doc(id)));
  const address = (order.address ?? {}) as Record<string, unknown>;
  return storeIds.map((storeId, i) => {
    const store = stores[i];
    const lines = byStore.get(storeId) as ReturnLine[];
    const customer = {
      addressText: (order.addressText as string | undefined) ?? "",
      // Rough area for the rider's offer card (no street or house number).
      area: [address.area, address.city].filter((x) => typeof x === "string" && x).join(", ").slice(0, 80),
      lat: typeof address.lat === "number" ? address.lat : null,
      lng: typeof address.lng === "number" ? address.lng : null,
      phone: (order.contactPhone as string | undefined) ?? null,
    };
    const storeLat = (store.get("lat") as number | undefined) ?? null;
    const storeLng = (store.get("lng") as number | undefined) ?? null;
    const from = { lat: customer.lat, lng: customer.lng };
    const to = { lat: storeLat, lng: storeLng };
    return {
      ref: db.collection(RETURNS).doc(`${input.issueId}_${storeId}`),
      customer,
      pickupCode: newReturnCode(),
      storeCode: newReturnCode(),
      data: {
        issueId: input.issueId,
        orderId: input.orderId,
        userId: order.userId ?? null,
        serviceAreaId: order.serviceAreaId ?? null,
        storeId,
        storeName: (store.get("name") as string | undefined) ?? "Store",
        storeAddress: (store.get("address") as string | undefined) ?? null,
        storeLat,
        storeLng,
        storePhone: (store.get("phone") as string | undefined) ?? null,
        // Who receives it: the shop's seller, or Zyppi for its own stores
        // (dark-store staff sign in to the seller app as Zyppi staff).
        sellerId: (store.get("sellerId") as string | undefined) || "zyppi",
        // Customer → store, for the rider's pay (no address on this doc).
        legM: isPoint(from) && isPoint(to) ? Math.round(distanceM(from, to)) : 0,
        lines,
        amountPaise: lines.reduce((a, l) => a + l.amountPaise, 0),
        resolution: input.resolution,
        status: "requested",
        riderId: null,
        riderName: null,
        riderPhone: null,
        tries: 0,
        dispatch: { state: "searching", tried: [] },
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      },
    };
  });
}

/** Writes the planned returns and their codes (after every read). */
export function writeReturnPlan(tx: Transaction, plan: PlannedReturn[]): void {
  for (const r of plan) {
    tx.create(r.ref, r.data);
    tx.create(r.ref.collection("private").doc("customer"), r.customer);
    // The customer shows this one to the rider at the door…
    tx.create(r.ref.collection("private").doc("pickup"), { code: r.pickupCode, attempts: 0 });
    // …and the rider shows this one to the store.
    tx.create(r.ref.collection("private").doc("store"), { code: r.storeCode, attempts: 0 });
  }
}
