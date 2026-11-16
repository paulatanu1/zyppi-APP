import { isOpenAt, parseHours } from "../shared/hours";
import {
  LISTINGS,
  MARKETPLACE_CONFIG_DOC,
  OFFERS,
  SELLERS,
  ZYPPI_SELLER_ID,
  inventoryIdFor,
  listingIdFor,
} from "../marketplace/model";
import {
  type ListingLite,
  type SellerLite,
  type StoreLite,
  candidateStores,
  listingPriceInput,
  readListing,
  readSellerLite,
  sellerCanSell,
} from "../marketplace/offers";
import { priceListing } from "../marketplace/pricing";
import { marketplaceConfigFrom } from "../marketplace/ranking";
import { newHandoverCode } from "../dispatch/model";
import { DocumentReference, FieldValue, Transaction } from "firebase-admin/firestore";
import { COUPON_MESSAGES, discountFor, normalizeCode } from "../coupons/model";
import { lookupCoupon, problemOf, recordRedemption } from "../coupons/usage";
import { db } from "../shared/firebase";
import { DELIVERY_CONFIG_PATH, deliveryConfigFrom, deliveryFeeFor } from "./delivery_config";
import { AreaLike, findServiceableArea } from "../shared/geo";

/** ₹5 handling fee and free delivery, matching the app's BillCalculator. */
export const HANDLING_FEE_PAISE = 500;
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
  /**
   * Set by the entry points only: stores closed at this time (their
   * `hours`) can't take the order. A paid order is never refused.
   */
  openAt?: Date;
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
  /** Marketplace (docs/MARKETPLACE.md): who sells it and, per unit, what
   * the seller is paid and what Zyppi keeps (pricePaise = payout + margin). */
  offerId: string;
  sellerId: string;
  sellerName: string;
  model: string;
  payoutPaise: number;
  marginPaise: number;
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

export interface PricingProduct {
  name: string;
  isActive: boolean;
  imageUrl: string | null;
  variants: Variant[];
}

/**
 * Prices each cart line and picks the stock rows it takes (pure, so it is
 * unit-tested; quoteOrder does the reads). Zyppi lines are priced from the
 * product; a seller's from their listing at `now`. Stock comes from the
 * fullest row first and spills over to the next.
 */
export function priceCartLines(input: {
  cart: { offerId: string | null; productId: string; variantId: string; quantity: number }[];
  products: Map<string, PricingProduct | null>;
  sellerOf: string[];
  listings: (ListingLite | null)[];
  sellers: Map<string, SellerLite | undefined>;
  candidates: { storeId: string; ref: DocumentReference; current: number }[][];
  areaId: string;
  now: Date;
}): { lines: QuoteLine[]; itemTotal: number } {
  const lines: QuoteLine[] = [];
  let itemTotal = 0;
  for (const [i, item] of input.cart.entries()) {
    const product = input.products.get(item.productId) ?? null;
    const name = product?.name ?? "item";
    if (!product || !product.isActive) {
      throw new OrderError(`Product unavailable: ${name}`);
    }
    const variant = product.variants.find((v) => v.id === item.variantId);
    if (!variant) throw new OrderError(`Product unavailable: ${name}`);

    const sellerId = input.sellerOf[i];
    let price = { pricePaise: variant.pricePaise, payoutPaise: 0, marginPaise: variant.pricePaise };
    let sellerName = "Zyppi";
    let model = "own";
    if (sellerId !== ZYPPI_SELLER_ID) {
      const seller = input.sellers.get(sellerId);
      const listing = input.listings[i];
      if (!listing || !listing.isActive || !sellerCanSell(seller)) throw new OrderError(`Product unavailable: ${name}`);
      try {
        price = priceListing(listingPriceInput(listing, variant.mrpPaise ?? 0), input.now);
      } catch {
        throw new OrderError(`Product unavailable: ${name}`);
      }
      sellerName = seller!.name;
      model = listing.model;
    }

    const candidates = [...input.candidates[i]].sort((a, b) => b.current - a.current);
    if (candidates.length === 0) throw new OrderError("STORES_CLOSED");
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

    itemTotal += price.pricePaise * item.quantity;
    lines.push({
      productId: item.productId,
      variantId: item.variantId,
      name,
      unit: variant.label,
      image: product.imageUrl,
      quantity: item.quantity,
      pricePaise: price.pricePaise,
      offerId: item.offerId ?? listingIdFor(ZYPPI_SELLER_ID, input.areaId, item.variantId),
      sellerId,
      sellerName,
      model,
      payoutPaise: price.payoutPaise,
      marginPaise: price.marginPaise,
      allocations,
    });
  }
  return { lines, itemTotal };
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
  const allStores: StoreLite[] = storesSnap.docs.map((st) => ({
    id: st.id,
    serviceAreaId: area.id,
    isActive: true,
    sellerId: (st.get("sellerId") as string | undefined) ?? null,
  }));
  const openIds = new Set(
    (p.openAt
      ? storesSnap.docs.filter((st) => isOpenAt(parseHours(st.get("hours")), p.openAt!))
      : storesSnap.docs
    ).map((st) => st.id),
  );
  if (openIds.size === 0) throw new OrderError("STORES_CLOSED");

  const slotSnap = await tx.get(db.collection("deliverySlots").doc(p.deliverySlotId));
  if (slotSnap.get("isActive") !== true) {
    throw new OrderError("Delivery slot is not available");
  }

  // Cart rows: legacy ones are keyed by variant id (Zyppi's own stock);
  // marketplace ones by offer id with `offerId` + `variantId` fields.
  const cartSnap = await tx.get(userRef.collection("cart"));
  const cart = cartSnap.docs
    .map((d) => ({
      ref: d.ref,
      offerId: (d.get("offerId") as string | undefined) ?? null,
      variantId: (d.get("variantId") as string | undefined) ?? d.id,
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

  // Which seller each line buys from (the offer says; legacy rows: Zyppi).
  const offerIds = [...new Set(cart.flatMap((c) => (c.offerId ? [c.offerId] : [])))];
  const offerSnaps = offerIds.length ? await tx.getAll(...offerIds.map((id) => db.collection(OFFERS).doc(id))) : [];
  const offers = new Map(offerSnaps.map((s) => [s.id, s]));
  const nameOf = (productId: string) => (products.get(productId)?.get("name") as string | undefined) ?? "item";
  const sellerOf = cart.map((c) => {
    if (!c.offerId) return ZYPPI_SELLER_ID;
    const offer = offers.get(c.offerId);
    if (
      !offer?.exists ||
      offer.get("variantId") !== c.variantId ||
      offer.get("productId") !== c.productId ||
      offer.get("serviceAreaId") !== area.id
    ) {
      throw new OrderError(`Product unavailable: ${nameOf(c.productId)}`);
    }
    return offer.get("sellerId") as string;
  });
  const outsideSellers = [...new Set(sellerOf.filter((id) => id !== ZYPPI_SELLER_ID))];
  const config = marketplaceConfigFrom((await tx.get(db.doc(MARKETPLACE_CONFIG_DOC))).data());
  if (new Set(sellerOf).size > config.maxSellersPerOrder) {
    throw new OrderError(`TOO_MANY_SELLERS:${config.maxSellersPerOrder}`);
  }
  const sellerSnaps = outsideSellers.length
    ? await tx.getAll(...outsideSellers.map((id) => db.collection(SELLERS).doc(id)))
    : [];
  const sellers = new Map(sellerSnaps.map((s) => [s.id, s]));
  const listingSnaps = await Promise.all(
    cart.map((c, i) =>
      sellerOf[i] === ZYPPI_SELLER_ID
        ? Promise.resolve(null)
        : tx.get(db.collection(LISTINGS).doc(listingIdFor(sellerOf[i], area.id, c.variantId))),
    ),
  );

  // Every stock row that could fill each line, read up front (same stores
  // as the offers use, open now).
  const candidatesOf = cart.map((c, i) =>
    candidateStores(allStores, area.id, sellerOf[i])
      .filter((st) => openIds.has(st.id))
      .map((st) => ({ storeId: st.id, ref: db.collection("inventory").doc(inventoryIdFor(st.id, sellerOf[i], c.variantId)) })),
  );
  const inventoryRefs = candidatesOf.flat().map((c) => c.ref);
  const inventorySnaps = inventoryRefs.length ? await tx.getAll(...inventoryRefs) : [];
  const stock = new Map(
    inventorySnaps.map((s) => [s.ref.path, (s.get("quantity") as number | undefined) ?? 0]),
  );

  const { lines, itemTotal } = priceCartLines({
    cart,
    products: new Map(
      [...products].map(([id, snap]) => [
        id,
        snap.exists
          ? {
              name: (snap.get("name") as string | undefined) ?? "item",
              isActive: snap.get("isActive") === true,
              imageUrl: (snap.get("imageUrl") as string | undefined) ?? null,
              variants: (snap.get("variants") as Variant[] | undefined) ?? [],
            }
          : null,
      ]),
    ),
    sellerOf,
    listings: listingSnaps.map((l) => (l?.exists ? readListing(l.id, l.data()!) : null)),
    sellers: new Map([...sellers].map(([id, snap]) => [id, readSellerLite(snap.data())])),
    candidates: candidatesOf.map((list) => list.map((c) => ({ ...c, current: stock.get(c.ref.path) ?? 0 }))),
    areaId: area.id,
    now: p.openAt ?? new Date(),
  });

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

  const delivery = deliveryConfigFrom(await tx.get(db.doc(DELIVERY_CONFIG_PATH)));
  if (itemTotal < delivery.minOrderPaise) {
    throw new OrderError(`MIN_ORDER_NOT_MET:${delivery.minOrderPaise}`);
  }
  const deliveryFee = deliveryFeeFor(itemTotal, delivery);

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
    deliveryFeePaise: deliveryFee,
    handlingFeePaise: HANDLING_FEE_PAISE,
    discountPaise: discount,
    tipPaise: p.tipPaise,
    totalPaise: itemTotal + deliveryFee + HANDLING_FEE_PAISE + p.tipPaise - discount,
  };
}

/**
 * Per order: the outside sellers in it (seller app queries
 * `sellerIds array-contains`), each one's status (they accept / mark
 * ready in the seller app) and what each is owed. Zyppi's own lines only
 * count towards the margin.
 */
export function sellerSummary(lines: Pick<QuoteLine, "sellerId" | "quantity" | "pricePaise" | "payoutPaise" | "marginPaise">[]) {
  const sellerIds = [...new Set(lines.map((l) => l.sellerId).filter((id) => id !== ZYPPI_SELLER_ID))];
  const sellerTotals: Record<string, { itemTotalPaise: number; payoutPaise: number }> = {};
  for (const l of lines) {
    if (l.sellerId === ZYPPI_SELLER_ID) continue;
    const t = (sellerTotals[l.sellerId] ??= { itemTotalPaise: 0, payoutPaise: 0 });
    t.itemTotalPaise += l.pricePaise * l.quantity;
    t.payoutPaise += l.payoutPaise * l.quantity;
  }
  return {
    sellerIds,
    sellerStatus: Object.fromEntries(sellerIds.map((id) => [id, "pending"])),
    sellerTotals,
    payoutTotalPaise: Object.values(sellerTotals).reduce((a, t) => a + t.payoutPaise, 0),
    marginTotalPaise: lines.reduce((a, l) => a + l.marginPaise * l.quantity, 0),
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
  // Last read before the writes: which (non-cancelled) order this is for the
  // customer, for the new-vs-repeat report.
  const userSnap = await tx.get(db.collection("users").doc(p.uid));
  const priorOrders = userSnap.get("orderCount");
  const customerOrderNo = (typeof priorOrders === "number" && priorOrders > 0 ? priorOrders : 0) + 1;

  // UUID ids keep the app's shortOrderId ("#3F2A9C1B") format.
  const orderRef = db.collection("orders").doc(crypto.randomUUID());
  const now = FieldValue.serverTimestamp();

  for (const line of quote.lines) {
    for (const a of line.allocations) {
      tx.update(a.ref, { quantity: a.current - a.take, updatedAt: now });
      // Stock history (admin Inventory): sales show next to adjustments.
      tx.create(db.collection("inventoryMovements").doc(), {
        storeId: a.storeId,
        sellerId: line.sellerId === ZYPPI_SELLER_ID ? null : line.sellerId,
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
    // Added to users/{uid}.orderCount / totalSpentPaise (see below).
    countedForUser: true,
    // 1 = the customer's first order (stats: new vs repeat).
    customerOrderNo,
    // Rider app: the delivery partner's call button.
    contactPhone: (userSnap.get("phone") as string | undefined) ?? null,
    riderName: null,
    riderPhone: null,
    // Which store's stock filled each line, so a cancellation puts it back
    // where it came from.
    allocations: quote.lines.flatMap((l) =>
      l.allocations.map((a) => ({
        storeId: a.storeId,
        sellerId: l.sellerId,
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
      // Frozen at order time: who sold it, what the seller is paid and
      // what Zyppi keeps per unit (settlement, invoices, margin report).
      offerId: l.offerId,
      sellerId: l.sellerId,
      sellerName: l.sellerName,
      model: l.model,
      payoutPaise: l.payoutPaise,
      marginPaise: l.marginPaise,
    })),
    ...sellerSummary(quote.lines),
  });
  tx.create(orderRef.collection("events").doc(), { status: "placed", createdAt: now });
  // 4-digit code the customer tells the rider at the door (riderDeliver).
  // Only the customer and staff can read it (firestore.rules).
  tx.create(orderRef.collection("private").doc("handover"), { code: newHandoverCode(), attempts: 0 });
  for (const ref of quote.cartRefs) tx.delete(ref);
  if (quote.couponCode) {
    recordRedemption(tx, quote.couponCode, p.uid, orderRef.id, quote.discountPaise);
  }
  // Customer aggregates for notification segments (cancelling takes the
  // order back off; lastOrderAt stays).
  tx.set(
    db.collection("users").doc(p.uid),
    {
      orderCount: FieldValue.increment(1),
      totalSpentPaise: FieldValue.increment(quote.totalPaise),
      lastOrderAt: now,
      serviceAreaId: quote.serviceAreaId,
    },
    { merge: true },
  );

  return orderRef.id;
}
