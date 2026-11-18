# Automatic returns

When a customer reports wrong, damaged or expired items, a rider collects them and the refund goes out once the store receives them. No admin step is needed. Code lives in `functions/src/returns/`. The claims and wallet side is in [WALLET.md](WALLET.md).

## When a claim skips ops
`reportOrderIssue` decides as the claim is created (`returns/model.ts → autoReturnDecision`). The limits live in `config/claims`.

| Rule | Default | Otherwise |
|---|---|---|
| `autoReturns` | on | Every claim waits for ops |
| No missing items in the claim | — | Ops reviews it, since the store or the rider may be at fault |
| Claim at or under `autoMaxPaise` | ₹500 | Ops reviews it |
| Fewer than `autoMaxClaims30d` claims in 30 days, this one included | 3 | Ops reviews it |

Claims that go to ops keep the existing Claims-queue flow.

## The flow
1. **Customer.** They start from the support chat (bot topic `missing_item`, action `return_flow`) or from Order details → Report a problem. They choose the items, what is wrong, 1–3 photos, and wallet, original payment or replacement. The claim gets status `returning`.
2. **One return per store.** A return is created for each store the units came from, using `order.allocations`, as `returns/{issueId}_{storeId}`. Its codes are in `private/pickup` (the customer shows it to the rider) and `private/store` (the rider shows it to the store). The store or seller is alerted with `return_coming`.
3. **Rider offer** (`returns/dispatch.ts`). The nearest free rider to the customer gets an offer in `riders/{uid}/returnOffers` and a push of type `return_offer`. It times out and moves on under the same rules as order offers. If nobody accepts, the return shows as unassigned for ops. A rider on a return gets no order offers.
4. **At the door** (`returns/rider.ts`). The rider must be within 200 m. They enter the customer's code and take 1–3 photos, which marks the return `picked_up`. Two other outcomes:
   - **Doesn't match:** the return goes to `review`, the claim goes back to the ops queue, and the rider is paid for the trip.
   - **Not home:** the first time, the customer is told and the rider waits `waitMinutes`. The second time, the return is `failed` and the rider is paid.
5. **At the store.** The rider must be within 150 m, and the store is alerted with `return_arrived`. The store enters the rider's code in the Seller app; dark-store staff do the same with a Zyppi staff login. For each line they pick **Back on shelf** or **Write off**. Damaged and expired items default to write-off. The return becomes `received`. Stock and an `inventoryMovements` row are written, and the rider is paid (rider ledger row `{returnId}_return`, on the rate card).
6. **Automatically** (`onReturnReceived` → `returns/settle.ts`):
   - **Money:** a refund to the wallet (`claim_{returnId}`), or to PayU with any rest going to the wallet. Cash orders always go to the wallet.
   - **Replacement:** a free order is placed. If nothing is in stock anywhere, the customer gets the wallet credit instead.
   - **Seller charge:** an outside seller is charged for wrong, damaged or expired items (`returnSellerItem`).
   - **Closing the claim:** once every return of the claim is finished, the claim becomes `approved`. If nothing could be collected it becomes `rejected`, and uncollected units can be claimed again.
   - If any step fails, the return is marked `settle.state: failed` and the claim goes to ops. Nothing is retried blindly.

The customer gets a push in their language at each step: booked, rider on the way, at the door, collected, refunded, under review, cancelled. When the claim started in the support chat, the same message is posted there.

Ops can cancel a return, or send it to review, with `adminUpdateReturn`.

## Deploying
- Run `firebase deploy --only functions,firestore,storage`. This adds the functions, the rules and 3 `returns` indexes.
- Then re-seed the support topics (`npm --prefix functions run seed:support`) so the `missing_item` topic offers "Start a return".
- Rider apps without return support never see return offers. Such returns wait as unassigned on the Dispatch board until riders update.
