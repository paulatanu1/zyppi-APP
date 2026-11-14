import { DocumentReference, FieldValue, Transaction } from "firebase-admin/firestore";
import { COUPON_MESSAGES, discountFor, normalizeCode } from "../coupons/model";
import { lookupCoupon, problemOf, recordRedemption } from "../coupons/usage";
import { db } from "../shared/firebase";
import { AreaLike, findServiceableArea } from "../shared/geo";

/** ₹5 handling fee and free delivery, matching the app's BillCalculator. */
export const HANDLING_FEE_PAISE = 500;
export const DELIVERY_FEE_PAISE = 0;
/** ₹500 tip cap, matching the app's tip selector. */
export const MAX_TIP_PAISE = 50000;

export const COD = "Cash on delivery";
export const ONLINE_METHODS = ["UPI", "Credit or debit card"];

/**
 * A reason an order can't be placed. The messages are the same English
 * sentences the old SQL raised, so the app's checkout_errors mapping keeps
 * matching them ("Insufficient stock for Milk" → translated text).
 */
export class OrderError extends Error {}

export interface OrderParams {
  uid: string;
  /**
   * Areas where new orders are paused (config/features). Only the entry
   * points pass it: a customer who has already paid is never refused.
   */
  closedAreaIds?: readonly string[];
  addressId: string;
  deliverySlotId: string;
  couponCode?: string | null;
  /**
   * The customer has already paid the price quoted with this coupon, so
   * its limits (expiry, uses) are not re-checked; the discount still has
   * to come out the same or the payment goes to review.
   */
  honourCoupon?: boolean;
  tipPaise: number;
  paymentMethod: string;
}

interface Variant {
  id: string;
  label: string;
  pricePaise: number;
  mrpPaise?: number;
}

export interface QuoteLine {
  productId: string;
  variantId: string;
  name: string;
  unit: string;
  image: string | null;
  quantity: number;
  pricePaise: number;
  /** Stock taken from each store: [inventory doc ref, units, current qty]. */
  allocations: { ref: DocumentReference; storeId: string; take: number; current: number }[];
}

export interface AddressSnapshot {
  label: string;
  line1: string;
  area: string;
  city: string;
  state: string;
  postalCode: string;
  landmark: string | null;
  lat: number;
  lng: number;
}

export interface Quote {
  serviceAreaId: string;
  address: AddressSnapshot;
  addressLabel: string;
  addressText: string;
  etaMinutes: number | null;
  /** Set only when it takes something off (counted as a use). */
  couponCode: string | null;
  lines: QuoteLine[];
  cartRefs: DocumentReference[];
  itemTotalPaise: number;
  deliveryFeePaise: number;
  handlingFeePaise: number;
  discountPaise: number;
  tipPaise: number;
  totalPaise: number;
}

/**
 * Validates and prices the user's server cart (port of `quote_order`).
 * Reads only, so it can run inside a transaction before any writes.
 * Throws [OrderError] if the order can't be placed.
 */
export async function quoteOrder(tx: Transaction, p: OrderParams): Promise<Quote> {
  if (!Number.isInteger(p.tipPaise) || p.tipPaise < 0 || p.tipPaise > MAX_TIP_PAISE) {
    throw new OrderError("Invalid tip");
  }

  const userRef = db.collection("users").doc(p.uid);
  const addressSnap = await tx.get(userRef.collection("addresses").doc(p.addressId));
  const address = addressSnap.data();
  if (!address) throw new OrderError("Address not found or not serviceable");

  // The area is derived from the address's coordinates on the server, not
  // trusted from the client.
  const areasSnap = await tx.get(db.collection("serviceAreas"));
  const areas: AreaLike[] = areasSnap.docs.map((d) => ({
    id: d.id,
    isActive: d.get("isActive") === true,
    centerLat: d.get("centerLat") ?? null,
    centerLng: d.get("centerLng") ?? null,
    radiusMeters: d.get("radiusMeters") ?? null,
  }));
  const area = findServiceableArea(areas, address.lat, address.lng);
  if (!area) throw new OrderError("Address not found or not serviceable");
  if (p.closedAreaIds?.includes(area.id)) {
    throw new OrderError("Ordering is paused in your area right now");
  }

  const storesSnap = await tx.get(
    db.collection("stores")
      .where("serviceAreaId", "==", area.id)
      .where("isActive", "==", true),
  );
  if (storesSnap.empty) throw new OrderError("We do not deliver to this address yet");

  const slotSnap = await tx.get(db.collection("deliverySlots").doc(p.deliverySlotId));
  if (slotSnap.get("isActive") !== true) {
    throw new OrderError("Delivery slot is not available");
  }

  const cartSnap = await tx.get(userRef.collection("cart"));
  const cart = cartSnap.docs
    .map((d) => ({
      ref: d.ref,
      variantId: d.id,
      productId: d.get("productId") as string,
      quantity: d.get("quantity") as number,
    }))
    .filter((c) => Number.isInteger(c.quantity) && c.quantity > 0);
  if (cart.length === 0) throw new OrderError("Cart is empty");

  const productIds = [...new Set(cart.map((c) => c.productId))];
  const productSnaps = await tx.getAll(
    ...productIds.map((id) => db.collection("products").doc(id)),
  );
  const products = new Map(productSnaps.map((s) => [s.id, s]));

  // Every (store, variant) stock row, read up front.
  const inventoryRefs = cart.flatMap((c) =>
    storesSnap.docs.map((s) => db.collection("inventory").doc(`${s.id}_${c.variantId}`)),
  );
  const inventorySnaps = await tx.getAll(...inventoryRefs);
  const stock = new Map(
    inventorySnaps.map((s) => [s.ref.path, (s.get("quantity") as number | undefined) ?? 0]),
  );

  const lines: QuoteLine[] = [];
  let itemTotal = 0;
  for (const item of cart) {
    const product = products.get(item.productId);
    const name = (product?.get("name") as string | undefined) ?? "item";
    if (!product?.exists || product.get("isActive") !== true) {
      throw new OrderError(`Product unavailable: ${name}`);
    }
    const variant = ((product.get("variants") as Variant[] | undefined) ?? []).find(
      (v) => v.id === item.variantId,
    );
    if (!variant) throw new OrderError(`Product unavailable: ${name}`);

    // Take from the fullest store first, spilling over to the next, so
    // stock spread across stores in the area can still fill the order.
    const candidates = storesSnap.docs
      .map((s) => {
        const ref = db.collection("inventory").doc(`${s.id}_${item.variantId}`);
        return { ref, storeId: s.id, current: stock.get(ref.path) ?? 0 };
      })
      .sort((a, b) => b.current - a.current);
    const available = candidates.reduce((sum, c) => sum + Math.max(c.current, 0), 0);
    if (available < item.quantity) {
      throw new OrderError(`Insufficient stock for ${name}`);
    }
    let remaining = item.quantity;
    const allocations: QuoteLine["allocations"] = [];
    for (const c of candidates) {
      if (remaining === 0) break;
      const take = Math.min(remaining, c.current);
      if (take <= 0) continue;
      allocations.push({ ref: c.ref, storeId: c.storeId, take, current: c.current });
      remaining -= take;
    }

    itemTotal += variant.pricePaise * item.quantity;
    lines.push({
      productId: item.productId,
      variantId: item.variantId,
      name,
      unit: variant.label,
      image: (product.get("imageUrl") as string | undefined) ?? null,
      quantity: item.quantity,
      pricePaise: variant.pricePaise,
      allocations,
    });
  }

  // Coupons: below the minimum it just gives nothing (the cart says "add
  // ₹X more"); any other problem refuses the order, so the customer never
  // pays a different total from the one they saw.
  let discount = 0;
  let couponCode: string | null = null;
  const rawCode = p.couponCode?.trim();
  if (rawCode) {
    const code = normalizeCode(rawCode);
    const lookup = code ? await lookupCoupon(tx, code, p.uid) : null;
    const problem = lookup ? problemOf(lookup, area.id) : "invalid";
    if (problem && !p.honourCoupon) throw new OrderError(COUPON_MESSAGES[problem]);
    if (lookup?.terms) {
      discount = discountFor(lookup.terms, itemTotal);
      if (discount > 0) couponCode = lookup.code;
    }
  }

  const addressText = [address.line1, address.area, address.city, address.postalCode]
    .filter((part: unknown) => typeof part === "string" && part.trim() !== "")
    .join(", ");

  return {
    serviceAreaId: area.id,
    address: {
      label: address.label,
      line1: address.line1,
      area: address.area ?? "",
      city: address.city ?? "",
      state: address.state ?? "",
      postalCode: address.postalCode ?? "",
      landmark: address.landmark ?? null,
      lat: address.lat,
      lng: address.lng,
    },
    addressLabel: address.label,
    addressText,
    etaMinutes: (slotSnap.get("etaMinutes") as number | undefined) ?? null,
    couponCode,
    lines,
    cartRefs: cartSnap.docs.map((d) => d.ref),
    itemTotalPaise: itemTotal,
    deliveryFeePaise: DELIVERY_FEE_PAISE,
    handlingFeePaise: HANDLING_FEE_PAISE,
    discountPaise: discount,
    tipPaise: p.tipPaise,
    totalPaise: itemTotal + DELIVERY_FEE_PAISE + HANDLING_FEE_PAISE + p.tipPaise - discount,
  };
}

/**
 * Creates the order from the user's server cart inside [tx] (port of
 * `place_order_internal`): quotes it, decrements stock, writes the order
 * and its first event, and empties the cart. Every read happens in
 * [quoteOrder] before the first write, as Firestore transactions require.
 */
export async function placeOrderInTx(
  tx: Transaction,
  p: OrderParams,
  payment: { status: "pending" | "succeeded"; providerReference: string | null },
  expectedTotalPaise?: number,
): Promise<string> {
  const quote = await quoteOrder(tx, p);
  if (expectedTotalPaise != null && quote.totalPaise !== expectedTotalPaise) {
    throw new OrderError("PAYMENT_AMOUNT_MISMATCH");
  }

  // UUID ids keep the app's shortOrderId ("#3F2A9C1B") format.
  const orderRef = db.collection("orders").doc(crypto.randomUUID());
  const now = FieldValue.serverTimestamp();

  for (const line of quote.lines) {
    for (const a of line.allocations) {
      tx.update(a.ref, { quantity: a.current - a.take, updatedAt: now });
      // Stock history (admin Inventory): sales show next to adjustments.
      tx.create(db.collection("inventoryMovements").doc(), {
        storeId: a.storeId,
        productId: line.productId,
        variantId: line.variantId,
        delta: -a.take,
        before: a.current,
        after: a.current - a.take,
        reason: "order",
        note: null,
        orderId: orderRef.id,
        actorUid: null,
        actorEmail: null,
        at: now,
      });
    }
  }

  tx.create(orderRef, {
    userId: p.uid,
    status: "placed",
    placedAt: now,
    addressId: p.addressId,
    addressLabel: quote.addressLabel,
    addressText: quote.addressText,
    // Full copy for the admin panel / invoices; survives address edits
    // and account deletion.
    address: quote.address,
    serviceAreaId: quote.serviceAreaId,
    deliverySlotId: p.deliverySlotId,
    etaMinutes: quote.etaMinutes,
    couponCode: quote.couponCode,
    paymentMethod: p.paymentMethod,
    payment: {
      method: p.paymentMethod,
      amountPaise: quote.totalPaise,
      status: payment.status,
      providerReference: payment.providerReference,
    },
    itemTotalPaise: quote.itemTotalPaise,
    deliveryFeePaise: quote.deliveryFeePaise,
    handlingFeePaise: quote.handlingFeePaise,
    tipPaise: quote.tipPaise,
    discountPaise: quote.discountPaise,
    totalPaise: quote.totalPaise,
    // Counted against the coupon's limits; cancelling gives the use back.
    couponRedeemed: quote.couponCode != null,
    riderName: null,
    riderPhone: null,
    // Which store's stock filled each line, so a cancellation puts it back
    // where it came from.
    allocations: quote.lines.flatMap((l) =>
      l.allocations.map((a) => ({
        storeId: a.storeId,
        productId: l.productId,
        variantId: l.variantId,
        quantity: a.take,
      })),
    ),
    items: quote.lines.map((l) => ({
      productId: l.productId,
      variantId: l.variantId,
      name: l.name,
      unit: l.unit,
      image: l.image,
      quantity: l.quantity,
      pricePaise: l.pricePaise,
    })),
  });
  tx.create(orderRef.collection("events").doc(), { status: "placed", createdAt: now });
  for (const ref of quote.cartRefs) tx.delete(ref);
  if (quote.couponCode) {
    recordRedemption(tx, quote.couponCode, p.uid, orderRef.id, quote.discountPaise);
  }

  return orderRef.id;
}
