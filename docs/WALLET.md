# Wallet and "Report a problem"

Backend: `functions/src/wallet/` (`model.ts` holds the pure rules, `ledger.ts` the wallet writes, `claims.ts` the callables).

## Wallet
The wallet is closed-loop store credit:
- **Filled only by:** cancellations, approved claims, and staff credits.
- **Spent only on:** Zyppi orders.
- **Never:** topped up, transferred or withdrawn.
- **Refunded money never expires.**

Ask your CA to confirm this stays a closed-system prepaid instrument under RBI rules.

| Where | What |
|---|---|
| `users/{uid}.walletPaise` | Spendable balance. Never below 0, and the app can't write it. |
| `users/{uid}/wallet/{id}` | History. The customer can read it; only functions write it. |

History entries use fixed ids, written with `tx.create`, so a retry can never credit or debit twice:

| Id | Meaning |
|---|---|
| `order_{orderId}` | Spent on a cash or wallet-only order |
| `pay_{txnid}` | Reserved for a PayU payment: `held` → `spent` or `released` |
| `release_{txnid}` | A reservation given back because the payment failed, expired, or went to review |
| `cancel_{orderId}` | The wallet part of a cancelled order |
| `claim_{issueId}` | An approved claim, or a cancelled replacement |
| `admin_{requestId}` | A finance credit |

### Checkout: the balance is always checked before the order is created
- **Cash or wallet-only (`placeOrder`).**
  - The app sends `useWallet` and `walletPaise`, the amount it showed the customer.
  - Inside the order transaction the server re-reads the balance and works out the wallet amount itself. If that amount differs from what the app showed, the order is refused with `WALLET_BALANCE_CHANGED` and nothing is charged. The app then reloads and asks again.
  - The debit and the new order are written in that same transaction, so two orders at the same moment can't both spend the same money.
  - The rider collects only `cashToCollectPaise`.
- **UPI or card plus wallet (`createPayUOrder`).**
  - The balance is checked and the wallet part reserved in the same transaction that creates the payment intent.
  - PayU charges only the rest.
  - When PayU settles, the reservation becomes spent, in the transaction that creates the order.
  - If the payment fails, expires or goes to review, the reservation goes back to the wallet.
  - If the wallet alone covers the order, the call is refused with `WALLET_COVERS_ORDER`; the app should then use `placeOrder` with method `"Wallet"`.
- **Order fields.**
  - `walletPaise` is the wallet part.
  - `payment.amountPaise` is the PayU or cash part.
  - `totalPaise` is the sum of the two.
  - `paymentMethod` is `"Wallet"` for wallet-only orders and `"Replacement"` for free replacements.

### Cancelling
- The wallet part always goes back to the wallet.
- The online part is refunded through PayU, as before.

### Deleting an account
The balance is lost with the account. `deleteAccount` refuses with `WALLET_NOT_EMPTY` until the app has warned the customer and sends `forfeitWallet: true`.

## Report a problem (`orderIssues/{id}`)
- **Who and when.** The customer can report up to **2 hours after delivery**, with one open claim per order.
- **What.** They choose the items and quantities, and for each item whether it was `missing`, `wrong`, `damaged` or `expired`.
- **Photos.** 1–3 photos are required unless the item is missing. The app compresses them and sends them in the `reportOrderIssue` call. The server checks each one really is a JPEG, PNG or WebP of 2 MB or less, then stores it at `users/{uid}/claims/{orderId}/`. Nobody can write to that folder directly; only the customer and ops, support or finance staff can read it.
- **What they can ask for.**
  - `wallet`: always available.
  - `original`: back to the online payment, for UPI or card orders only. Cash orders always get wallet credit.
  - `replacement`.
- **Claim value.** The item price less that item's share of the coupon discount, rounded down. Claims and refunds together can never exceed the order total.
- **Approval.** Ops approve every claim with `adminResolveIssue`:
  - Wallet credit is written in the same transaction as the approval.
  - A refund to the original payment goes through `createRefund`. Any part the online payment can't take goes to the wallet.
  - A replacement is a new free order (`replacementOf`, no fees). It comes from the best offer in stock, starting with the same seller. If nothing is in stock, ops get `REPLACEMENT_UNAVAILABLE` and can choose the wallet instead. If the replacement is cancelled later, the claim is credited to the wallet automatically.
  - Ticking **seller at fault** takes back the seller's credit for those units (`returnSellerItem`, the same as Orders → Return / damage).
- **Rejection.** `adminRejectIssue` takes a reason the customer sees. While the 2 hours are still running, they can report again.
- **Repeat claimers.** `users/{uid}.claimStats.{count,lastAt}` is shown to ops next to each claim.
- **Later problems.** A problem found after the 2 hours goes through the support chat; finance can use `adminCreditWallet` (₹5,000 at most per credit, audited).

## Deploying
Run `firebase deploy --only functions,firestore,storage`. This deploys the new callables, the rules, and the 3 `orderIssues` indexes.
