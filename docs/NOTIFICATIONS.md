# Notifications

| Piece | Where |
|---|---|
| Saved notification list | `users/{uid}/notifications` (customers), `sellers/{id}/inbox`, `riders/{uid}/inbox` |
| One-off timers | Cloud Tasks queues (task functions below) |
| Processing | Cloud Functions Gen 2, `asia-south1` |
| Delivery | FCM, to every signed-in device (`pushTokens`, max 5, plus legacy `fcmToken`) |
| Cleanup | Firestore TTL on `expireAt` (`firestore.indexes.json` → `fieldOverrides`) |
| Recurring jobs | Cloud Scheduler (settlement, payouts, subscriptions, refunds, dispatch) |

## Timers on Cloud Tasks
| Task function | Queued by | Fires at | Safety net (Scheduler) |
|---|---|---|---|
| `sendScheduledCampaign` | `adminScheduleCampaign` | campaign `sendAt` | `dispatchCampaigns`, hourly |
| `sendCampaignChunk` | `sendCampaign`, if more than 4 FCM batches | at once, 5/s | stalled sends are marked failed after 2 h |
| `checkSellerAccept` | `onOrderForSellers` when the order is created | `sellerAcceptDeadline` | `escalateLateSellers`, every 15 min |
| `applyListingPriceChange` | `onListingWritten` | `nextPriceChangeAt` | `refreshTimedOffers`, hourly |

Rules every handler follows:
- **At least once.** A task can arrive twice or early, so each handler re-reads Firestore and does nothing unless the work is still due.
- **Campaign batches are claimed once.** Each batch creates `campaigns/{id}/chunks/{i}` before it sends.
- **Fixed task ids** such as `campaign-{id}-v{n}`, `seller-accept-{orderId}` and `price-{listing}-{ms}`, so a retried trigger can't queue the same work twice.
- **Rescheduling** bumps `taskVersion`, so an old task does nothing when it fires.
- **30-day limit.** Cloud Tasks takes times at most 30 days ahead. Anything later waits for the hourly safety net, which queues it once it is inside that window.

## Deploying
1. Run `firebase deploy --only functions,firestore --project zippy-app-2024`. This creates the queues, the new indexes and the two TTL policies.
2. If the first deploy reports missing permissions: give the functions' runtime service account (default compute SA) **Cloud Tasks Enqueuer** and **Service Account User** in IAM.

Cost: Cloud Tasks gives the first 1M operations a month free. Each TTL deletion is billed as a normal Firestore delete.
