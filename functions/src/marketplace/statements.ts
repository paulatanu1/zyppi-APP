import { HttpsError, onCall } from "firebase-functions/https";
import { db } from "../shared/firebase";
import { requireRole } from "../shared/roles";
import { SELLERS } from "./model";
import { requireSeller } from "./sellers";
import { type LedgerRow, type TaxRow, buildStatement, monthRange, taxCsv } from "./statements_model";

const EARNINGS = "earnings";

/** Earnings → Monthly statement. Request: {month: "YYYY-MM"}. */
export const sellerStatement = onCall(async (request) => {
  const { sellerId } = await requireSeller(request);
  const range = monthRange(request.data?.month);
  if (!range) throw new HttpsError("invalid-argument", "Pick a month");
  const snap = await db
    .collection(SELLERS)
    .doc(sellerId)
    .collection(EARNINGS)
    .where("day", ">=", range.from)
    .where("day", "<=", range.to)
    .get();
  return { month: request.data.month as string, ...buildStatement(snap.docs.map((d) => d.data() as LedgerRow)) };
});

/**
 * Finance → Seller tax report: per seller net sales, TCS (GST §52, filed in
 * GSTR-8) and TDS (Income-tax §194-O) for a month, plus a CSV.
 * Request: {month: "YYYY-MM"}.
 */
export const adminSellerTaxReport = onCall({ timeoutSeconds: 120, memory: "512MiB" }, async (request) => {
  requireRole(request, ["finance"]);
  const month = request.data?.month;
  const range = monthRange(month);
  if (!range) throw new HttpsError("invalid-argument", "Pick a month");
  const snap = await db
    .collectionGroup(EARNINGS)
    .where("ledger", "==", "seller")
    .where("day", ">=", range.from)
    .where("day", "<=", range.to)
    .get();
  const bySeller = new Map<string, LedgerRow[]>();
  for (const d of snap.docs) {
    const sellerRef = d.ref.parent.parent;
    if (!sellerRef || sellerRef.parent.id !== SELLERS) continue;
    bySeller.set(sellerRef.id, [...(bySeller.get(sellerRef.id) ?? []), d.data() as LedgerRow]);
  }
  const ids = [...bySeller.keys()];
  const sellers = ids.length ? await db.getAll(...ids.map((id) => db.collection(SELLERS).doc(id))) : [];
  const rows: TaxRow[] = sellers
    .map((s) => {
      const st = buildStatement(bySeller.get(s.id) ?? []);
      return {
        sellerId: s.id,
        shopName: (s.get("shopName") as string) ?? "",
        ownerName: (s.get("ownerName") as string) ?? "",
        gstin: (s.get("gstin") as string) ?? "",
        pan: (s.get("pan") as string) ?? "",
        orders: st.orders,
        salesPaise: st.salesPaise,
        tcsPaise: st.tcsPaise,
        tdsPaise: st.tdsPaise,
      };
    })
    .filter((r) => r.orders || r.salesPaise || r.tcsPaise || r.tdsPaise)
    .sort((a, b) => b.salesPaise - a.salesPaise);
  const totals = rows.reduce(
    (t, r) => ({ salesPaise: t.salesPaise + r.salesPaise, tcsPaise: t.tcsPaise + r.tcsPaise, tdsPaise: t.tdsPaise + r.tdsPaise }),
    { salesPaise: 0, tcsPaise: 0, tdsPaise: 0 },
  );
  return { month, rows, totals, csv: taxCsv(month as string, rows) };
});
