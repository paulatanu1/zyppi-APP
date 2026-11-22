# Cost guardrails: budgets, quotas and alerts

Audit OPT-06 (COST-13, COST-03). These steps cap the worst case on the bill and warn before it is reached. **Nothing here is applied automatically.** Each step changes project settings for `zippy-app-2024`, so a person runs it.

Setup:

```sh
PROJECT=zippy-app-2024
gcloud config set project $PROJECT
BILLING=$(gcloud billing projects describe $PROJECT --format='value(billingAccountName)' | sed 's|billingAccounts/||')
```

## 1. Budget with 50 / 90 / 100 % alerts

Set the amount to the expected monthly spend plus some headroom.

```sh
gcloud billing budgets create \
  --billing-account=$BILLING \
  --display-name="Zyppi monthly" \
  --budget-amount=5000INR \
  --filter-projects=projects/$PROJECT \
  --threshold-rule=percent=0.5 \
  --threshold-rule=percent=0.9 \
  --threshold-rule=percent=1.0 \
  --threshold-rule=percent=1.0,basis=forecasted-spend
```

A budget sends alerts; it does not stop spending. The quotas in step 2 are the hard caps.

## 2. Places API daily cap

Open Console → APIs & Services → **Places API (New)** → Quotas & system limits. Set a per-day cap on the autocomplete and place-details requests, at about 3× the busiest day so far. When the cap is reached, `placesProxy` returns `ERROR` and the app falls back to the phone's geocoder. That is the same path as the `placesSearch` switch in Settings → Services.

## 3. Log-based metrics

Gen-2 functions log to `cloud_run_revision`. The log messages below are the ones the code writes today.

```sh
# Paid but couldn't be placed (place_paid_order.ts): someone must refund or place it.
gcloud logging metrics create paid_order_needs_review \
  --description="PayU payments that went to review" \
  --log-filter='resource.type="cloud_run_revision" jsonPayload.message="Paid order needs review"'

# Rate-limited callables (shared/rate_limit.ts → HTTP 429).
gcloud logging metrics create callable_429 \
  --description="Callables refused by rateLimit" \
  --log-filter='resource.type="cloud_run_revision" httpRequest.status=429'

# Tokenless callables, sampled at 1 % (shared/hardening.ts). Multiply by 100.
gcloud logging metrics create app_check_missing_sampled \
  --description="Callables without App Check (1% sample)" \
  --log-filter='resource.type="cloud_run_revision" jsonPayload.message="Callable without App Check"'

# PayU reconciler errors (payments/reconcile.ts).
gcloud logging metrics create payu_reconcile_failed \
  --description="Intents the reconciler couldn't check" \
  --log-filter='resource.type="cloud_run_revision" jsonPayload.message="PayU reconcile failed"'
```

## 4. Alert policies

First create an email notification channel and keep its id:

```sh
gcloud beta monitoring channels create --display-name="Zyppi ops" --type=email \
  --channel-labels=email_address=OPS_EMAIL
CHANNEL=$(gcloud beta monitoring channels list --filter='displayName="Zyppi ops"' --format='value(name)')
```

Then create one policy per row, using the template below.

| Policy | Metric | Condition |
|---|---|---|
| Firestore reads/day | `firestore.googleapis.com/document/read_count` | sum over 1 day > 3× normal daily reads |
| Firestore writes/day (also covers `auditLogs` floods) | `firestore.googleapis.com/document/write_count` | sum over 1 day > 3× normal |
| Needs-review payments | `logging.googleapis.com/user/paid_order_needs_review` | any in 5 min > 0 |
| Callable 429 spike | `logging.googleapis.com/user/callable_429` | sum over 10 min > 50 |
| Reconciler failing | `logging.googleapis.com/user/payu_reconcile_failed` | sum over 30 min > 5 |

Template (`policy.json`). Change `displayName`, `filter`, `alignmentPeriod` and `thresholdValue` for each row:

```json
{
  "displayName": "Firestore reads/day",
  "combiner": "OR",
  "conditions": [{
    "displayName": "reads above threshold",
    "conditionThreshold": {
      "filter": "metric.type=\"firestore.googleapis.com/document/read_count\" resource.type=\"firestore_instance\"",
      "aggregations": [{ "alignmentPeriod": "86400s", "perSeriesAligner": "ALIGN_SUM", "crossSeriesReducer": "REDUCE_SUM" }],
      "comparison": "COMPARISON_GT",
      "thresholdValue": 3000000,
      "duration": "0s"
    }
  }]
}
```

```sh
gcloud monitoring policies create --policy-from-file=policy.json --notification-channels=$CHANNEL
```

For a log-based metric, the filter is `metric.type="logging.googleapis.com/user/<name>" resource.type="cloud_run_revision"`.

**Not covered yet:** orders that are still unassigned after 10 minutes. No log line or metric reports them today. Covering them needs a small code change: a log line with the count from the dispatch sweep. Until then, watch the admin Orders page.

## 5. Turning App Check enforcement on

1. Watch `app_check_missing_sampled` for 7 days after every client ships with App Check. Group by `jsonPayload.caller` and `jsonPayload.path`.
2. When the `caller="app"` count is at or near 0, set `APP_CHECK_ENFORCE=true` in `functions/.env.zippy-app-2024` and redeploy the functions.
3. Do the same for `caller="web"` with `APP_CHECK_ENFORCE_WEB=true`, once the admin panel has its reCAPTCHA Enterprise site key.
4. To roll back, set the flag to `false` and redeploy.
