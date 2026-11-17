/**
 * Monthly seller statements and Zyppi's TCS/TDS report, built from the
 * seller ledger (sellers/{id}/earnings, `day` = India date YYYY-MM-DD).
 * Pure, for the tests. Rates are whatever config/marketplace.settlement
 * held when each row was written; a CA confirms them before filing.
 */
export interface LedgerRow {
  type?: string;
  amountPaise?: number;
  grossPaise?: number;
  payoutPaise?: number;
  tcsPaise?: number;
  tdsPaise?: number;
  duesPaise?: number;
}

export interface Statement {
  orders: number;
  /** Customer price of the seller's items (net of returns and cancellations). */
  salesPaise: number;
  /** The seller's own price for them. */
  payoutPaise: number;
  tcsPaise: number;
  tdsPaise: number;
  reversalsPaise: number;
  returnsPaise: number;
  adjustmentsPaise: number;
  /** Credited this month after TCS/TDS, returns, reversals and adjustments. */
  netPaise: number;
  paidOutPaise: number;
  /** Subscription fees taken from payouts. */
  feesDeductedPaise: number;
}

const n = (v: unknown) => (typeof v === "number" && Number.isFinite(v) ? Math.round(v) : 0);

export function emptyStatement(): Statement {
  return {
    orders: 0,
    salesPaise: 0,
    payoutPaise: 0,
    tcsPaise: 0,
    tdsPaise: 0,
    reversalsPaise: 0,
    returnsPaise: 0,
    adjustmentsPaise: 0,
    netPaise: 0,
    paidOutPaise: 0,
    feesDeductedPaise: 0,
  };
}

export function buildStatement(rows: LedgerRow[]): Statement {
  const s = emptyStatement();
  for (const r of rows) {
    const amount = n(r.amountPaise);
    switch (r.type) {
      case "order":
        s.orders += 1;
        s.salesPaise += n(r.grossPaise);
        s.payoutPaise += n(r.payoutPaise);
        s.tcsPaise += n(r.tcsPaise);
        s.tdsPaise += n(r.tdsPaise);
        s.netPaise += amount;
        break;
      case "reversal":
      case "return":
        if (r.type === "reversal") s.reversalsPaise += amount;
        else s.returnsPaise += amount;
        // These rows carry negative gross / payout / taxes.
        s.salesPaise += n(r.grossPaise);
        s.payoutPaise += n(r.payoutPaise);
        s.tcsPaise += n(r.tcsPaise);
        s.tdsPaise += n(r.tdsPaise);
        s.netPaise += amount;
        break;
      case "adjustment":
        s.adjustmentsPaise += amount;
        s.netPaise += amount;
        break;
      case "payout": {
        const dues = n(r.duesPaise);
        s.feesDeductedPaise += dues;
        s.paidOutPaise += -amount - dues;
        break;
      }
    }
  }
  return s;
}

/** "2026-11" → the first and last `day` strings of that month; null if invalid. */
export function monthRange(month: unknown): { from: string; to: string } | null {
  if (typeof month !== "string" || !/^\d{4}-(0[1-9]|1[0-2])$/.test(month)) return null;
  const [y, m] = month.split("-").map(Number);
  const last = new Date(Date.UTC(y, m, 0)).getUTCDate();
  return { from: `${month}-01`, to: `${month}-${String(last).padStart(2, "0")}` };
}

/** One row of the TCS (GSTR-8) / TDS (194-O) working sheet. */
export interface TaxRow {
  sellerId: string;
  shopName: string;
  ownerName: string;
  gstin: string;
  pan: string;
  orders: number;
  salesPaise: number;
  tcsPaise: number;
  tdsPaise: number;
}

/** Comma-separated, Excel-safe (quotes, no formula injection). */
export function taxCsv(month: string, rows: TaxRow[]): string {
  const cell = (v: string | number) => {
    let s = String(v);
    if (/^[=+\-@]/.test(s)) s = `'${s}`;
    return /[",\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
  };
  const rupees = (p: number) => (p / 100).toFixed(2);
  const head = ["Month", "Seller ID", "Shop", "Owner", "GSTIN", "PAN", "Orders", "Net sales (₹)", "TCS (₹)", "TDS (₹)"];
  const body = rows.map((r) =>
    [month, r.sellerId, r.shopName, r.ownerName, r.gstin, r.pan, r.orders, rupees(r.salesPaise), rupees(r.tcsPaise), rupees(r.tdsPaise)]
      .map(cell)
      .join(","),
  );
  return [head.join(","), ...body].join("\n");
}
