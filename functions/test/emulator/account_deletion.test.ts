import { beforeEach, describe, expect, it } from "vitest";
import { deleteSellerAccount } from "../../src/marketplace/seller_delete";
import { deleteRiderAccount } from "../../src/riders/delete";
import { auth, db } from "../../src/shared/firebase";
import { AREA, resetData } from "./fixtures";

const now = new Date(Date.UTC(2026, 10, 23, 6));

async function resetAuth() {
  await fetch(
    `http://${process.env.FIREBASE_AUTH_EMULATOR_HOST}/emulator/v1/projects/${process.env.GCLOUD_PROJECT}/accounts`,
    { method: "DELETE" },
  );
}

beforeEach(async () => {
  await resetData({});
  await resetAuth();
});

async function rider(over: Record<string, unknown> = {}): Promise<string> {
  const { uid } = await auth.createUser({ email: `r${Math.random()}@zyppi.test` });
  await auth.setCustomUserClaims(uid, { rider: true });
  await db.doc(`riders/${uid}`).set({
    status: "approved",
    fullName: "Raju Mahato",
    phone: "+919800011111",
    dob: "1998-05-20",
    address: "Ward 5, Station Road",
    serviceAreaId: AREA,
    vehicleType: "bike",
    vehicleNumber: "WB 56 AB 1234",
    drivingLicenceNumber: "WB5620190001234",
    docs: { selfie: `riders/${uid}/kyc/selfie.jpg` },
    payout: { method: "upi", upiId: "raju@okaxis" },
    pushTokens: ["t1"],
    presence: { online: true, lat: 23.3, lng: 86.3 },
    deliveredCount: 12,
    codBalancePaise: 0,
    earningsBalancePaise: 0,
    ...over,
  });
  await db.doc(`riders/${uid}/private/payout`).set({ method: "upi", upiId: "raju@okaxis" });
  await db.doc(`riders/${uid}/earnings/o1_trip`).set({ type: "trip", amountPaise: 3000 });
  return uid;
}

describe("rider account deletion", () => {
  it("waits until the rider and Zyppi are square", async () => {
    const held = await rider({ codBalancePaise: 45000 });
    await expect(deleteRiderAccount(held, now)).rejects.toThrow("CASH_HELD");
    const owed = await rider({ earningsBalancePaise: 5000 });
    await expect(deleteRiderAccount(owed, now)).rejects.toThrow("EARNINGS_UNPAID");
    const busy = await rider({ presence: { online: true, activeOrderId: "o9" } });
    await expect(deleteRiderAccount(busy, now)).rejects.toThrow("ACTIVE_DELIVERY");
    const waiting = await rider();
    await db.doc(`riders/${waiting}/payouts/p1`).set({ status: "requested", amountPaise: 20000 });
    await expect(deleteRiderAccount(waiting, now)).rejects.toThrow("PAYOUT_PENDING");
    expect((await db.doc(`riders/${held}`).get()).get("status")).toBe("approved");
  });

  it("removes personal data, keeps the ledger, frees slots and deletes the login", async () => {
    const uid = await rider();
    await db.doc(`riders/${uid}/slots/2026-11-25_08:00`).set({ date: "2026-11-25", start: "08:00", status: "booked" });
    await db.doc(`riders/${uid}/slots/2026-11-20_08:00`).set({ date: "2026-11-20", start: "08:00", status: "booked" });
    await db.doc(`gigSlots/${AREA}_2026-11-25_08:00`).set({ booked: 3 });
    await db.doc("orders/o1").set({ riderId: uid, riderName: "Raju Mahato", riderPhone: "+919800011111", status: "delivered" });
    await db.doc("orders/o1/tracking/live").set({ lat: 23.3, lng: 86.3 });
    await db.doc("sosAlerts/s1").set({ riderId: uid, riderName: "Raju Mahato", riderPhone: "+919800011111" });

    expect(await deleteRiderAccount(uid, now)).toEqual({ deleted: true, loginDeleted: true });

    const r = (await db.doc(`riders/${uid}`).get()).data()!;
    expect(r).toMatchObject({ status: "deleted", serviceAreaId: AREA, deliveredCount: 12, presence: { online: false } });
    for (const k of ["fullName", "phone", "dob", "address", "vehicleNumber", "drivingLicenceNumber", "docs", "payout", "pushTokens"]) {
      expect(r[k], k).toBeUndefined();
    }
    expect((await db.doc(`riders/${uid}/private/payout`).get()).exists).toBe(false);
    expect((await db.doc(`riders/${uid}/earnings/o1_trip`).get()).exists).toBe(true);
    expect((await db.doc(`riders/${uid}/slots/2026-11-25_08:00`).get()).get("status")).toBe("cancelled");
    expect((await db.doc(`riders/${uid}/slots/2026-11-20_08:00`).get()).get("status")).toBe("booked");
    expect((await db.doc(`gigSlots/${AREA}_2026-11-25_08:00`).get()).get("booked")).toBe(2);
    expect((await db.doc("orders/o1").get()).data()).toMatchObject({ riderId: uid, riderName: null, riderPhone: null });
    expect((await db.doc("orders/o1/tracking/live").get()).exists).toBe(false);
    expect((await db.doc("sosAlerts/s1").get()).get("riderPhone")).toBeNull();
    await expect(auth.getUser(uid)).rejects.toThrow();

    // Repeating is harmless.
    expect(await deleteRiderAccount(uid, now)).toEqual({ deleted: true, loginDeleted: true });
  });

  it("keeps a login that is also a customer, without the rider claim", async () => {
    const uid = await rider();
    await db.doc(`users/${uid}`).set({ name: "Raju" });
    expect(await deleteRiderAccount(uid, now)).toEqual({ deleted: true, loginDeleted: false });
    const user = await auth.getUser(uid);
    expect(user.customClaims?.rider).toBeUndefined();
  });
});

async function shop(over: Record<string, unknown> = {}) {
  const { uid } = await auth.createUser({ email: `o${Math.random()}@zyppi.test` });
  const sellerId = uid;
  await auth.setCustomUserClaims(uid, { sellerId, sellerRole: "owner" });
  await db.doc(`sellers/${sellerId}`).set({
    status: "approved",
    ownerUid: uid,
    ownerName: "Mita Das",
    phone: "+919800022222",
    email: "mita@shop.test",
    pan: "ABCDE1234F",
    aadhaarLast4: "1234",
    shopName: "Mita Stores",
    gstin: "19ABCDE1234F1Z5",
    address: "Bazar Road, Chelyama",
    lat: 23.5,
    lng: 86.5,
    storeCode: "ZS123456",
    fulfilment: "seller_shop",
    isOnline: true,
    earningsBalancePaise: 0,
    heldPaise: 0,
    duesPaise: 0,
    ...over,
  });
  await db.doc(`sellerUsers/${uid}`).set({ sellerId, role: "owner" });
  await db.doc("sellerStoreCodes/ZS123456").set({ sellerId });
  await db.doc(`stores/seller_${sellerId}`).set({ name: "Mita Stores", address: "Bazar Road", phone: "+919800022222", isActive: true, sellerId });
  await db.doc(`sellers/${sellerId}/private/payout`).set({ method: "upi", upiId: "mita@okaxis" });
  await db.doc(`sellers/${sellerId}/earnings/e1`).set({ amountPaise: 1000 });

  const staff = await auth.createUser({ email: `s${Math.random()}@zyppi.test` });
  await auth.setCustomUserClaims(staff.uid, { sellerId, sellerRole: "staff" });
  await db.doc(`sellerUsers/${staff.uid}`).set({ sellerId, role: "staff" });
  return { owner: uid, sellerId, staff: staff.uid };
}

describe("seller account deletion", () => {
  it("a staff login only leaves the shop", async () => {
    const { sellerId, staff } = await shop();
    expect(await deleteSellerAccount(staff)).toEqual({ deleted: true, shopClosed: false, loginDeleted: true });
    expect((await db.doc(`sellerUsers/${staff}`).get()).exists).toBe(false);
    expect((await db.doc(`sellers/${sellerId}`).get()).get("status")).toBe("approved");
  });

  it("waits for open orders, payouts, balances and dues", async () => {
    const a = await shop({ duesPaise: 49900 });
    await expect(deleteSellerAccount(a.owner)).rejects.toThrow("DUES_UNPAID");
    const b = await shop({ heldPaise: 1200 });
    await expect(deleteSellerAccount(b.owner)).rejects.toThrow("BALANCE_UNPAID");
    const c = await shop();
    await db.doc(`sellers/${c.sellerId}/orders/o1`).set({ status: "packed" });
    await expect(deleteSellerAccount(c.owner)).rejects.toThrow("OPEN_ORDERS");
  });

  it("the owner closes the shop: data removed, records kept, every login out", async () => {
    const { owner, sellerId, staff } = await shop();
    await db.doc(`sellers/${sellerId}/orders/o1`).set({ status: "delivered", customer: { name: "A" } });

    expect(await deleteSellerAccount(owner)).toEqual({ deleted: true, shopClosed: true, loginDeleted: true });

    const s = (await db.doc(`sellers/${sellerId}`).get()).data()!;
    expect(s).toMatchObject({ status: "deleted", isOnline: false, shopName: "Mita Stores", gstin: "19ABCDE1234F1Z5" });
    for (const k of ["ownerName", "phone", "email", "pan", "aadhaarLast4", "address", "lat", "lng", "storeCode", "ownerUid"]) {
      expect(s[k], k).toBeUndefined();
    }
    expect((await db.doc("sellerStoreCodes/ZS123456").get()).exists).toBe(false);
    expect((await db.doc(`stores/seller_${sellerId}`).get()).data()).toMatchObject({ isActive: false, address: null, phone: null });
    expect((await db.doc(`sellers/${sellerId}/private/payout`).get()).exists).toBe(false);
    expect((await db.doc(`sellers/${sellerId}/orders/o1`).get()).exists).toBe(false);
    expect((await db.doc(`sellers/${sellerId}/earnings/e1`).get()).exists).toBe(true);
    expect((await db.doc(`sellerUsers/${staff}`).get()).exists).toBe(false);
    expect((await auth.getUser(staff)).customClaims?.sellerId).toBeUndefined();
    await expect(auth.getUser(owner)).rejects.toThrow();
  });

  it("an applicant who was never approved just goes", async () => {
    const { uid } = await auth.createUser({ email: "applicant@zyppi.test" });
    await db.doc(`sellers/${uid}`).set({ status: "draft", ownerUid: uid, ownerName: "New", phone: "+919800033333" });
    expect(await deleteSellerAccount(uid)).toEqual({ deleted: true, shopClosed: true, loginDeleted: true });
    expect((await db.doc(`sellers/${uid}`).get()).get("ownerName")).toBeUndefined();
  });
});
