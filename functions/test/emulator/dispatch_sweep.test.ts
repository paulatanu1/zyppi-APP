import { Timestamp } from "firebase-admin/firestore";
import { beforeEach, describe, expect, it } from "vitest";
import { db } from "../../src/shared/firebase";
import { waitingOrders } from "../../src/dispatch/dispatch";

describe("dispatch sweep picks (DA-10)", () => {
  beforeEach(async () => {
    const host = process.env.FIRESTORE_EMULATOR_HOST;
    await fetch(`http://${host}/emulator/v1/projects/${process.env.GCLOUD_PROJECT}/databases/(default)/documents`, { method: "DELETE" });
  });

  it("skips closed orders that still say unassigned, and takes the longest-waiting first", async () => {
    const b = db.batch();
    for (let i = 0; i < 60; i++) {
      b.set(db.doc(`orders/closed-${i}`), {
        status: i % 2 ? "cancelled" : "delivered",
        dispatch: { state: "unassigned", updatedAt: Timestamp.fromMillis(1_000 + i) },
      });
    }
    b.set(db.doc("orders/newer"), { status: "placed", dispatch: { state: "unassigned", updatedAt: Timestamp.fromMillis(9_000) } });
    b.set(db.doc("orders/older"), { status: "packed", dispatch: { state: "unassigned", updatedAt: Timestamp.fromMillis(5_000) } });
    b.set(db.doc("orders/offered"), { status: "placed", dispatch: { state: "offered", updatedAt: Timestamp.fromMillis(1) } });
    await b.commit();

    const picked = (await waitingOrders().get()).docs.map((d) => d.id);
    expect(picked).toEqual(["older", "newer"]);
    expect((await waitingOrders(1).get()).docs.map((d) => d.id)).toEqual(["older"]);
  });
});
