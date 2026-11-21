#!/usr/bin/env bash
# Redeploys the functions that failed with "Quota exceeded for total
# allowable CPU per project per region", ONE AT A TIME so only one old and
# one new revision are counted against the regional CPU quota at once.
# Retries each up to 3 times. Run from the repo root:
#   bash scripts/deploy-failed-functions.sh
set -u
cd "$(dirname "$0")/.."

# 1. onReturnReceived is a FAILED leftover that was created as an HTTPS
#    function; the code is a Firestore trigger, which Firebase can't convert.
#    It has never run, so it is safe to delete and recreate.
echo "== Deleting the broken onReturnReceived stub"
firebase functions:delete onReturnReceived --region asia-south1 --force || true

FUNCS=(
  onReturnReceived reportOrderIssue riderReturnPickedUp riderReturnedToStore
  adminRefreshRefund requestSupportAgent adminReplySupport onSupportMessageCreated
  adminSaveKbEntry legalStatus adminPublishLegalDoc adminReviewSeller
  adminSaveSellerPlan sellerSetOnline sellerAddStaff sellerSubmitProduct
  adminReviewProductRequest adminSetSellerTrusted sellerSaveListing adminSaveListing
  sellerAdjustStock onListingWritten onInventoryWritten adminForcePickup
  onOrderSettleSellers adminReturnSellerItem adminSetSellerPlan sellerRequestPayout
  adminRecordSellerPayout adminRecordSellerFee adminAdjustSellerEarnings rateSellers
  adminScheduleCampaign dispatchCampaigns sendScheduledCampaign adminSellerTaxReport
)

failed=()
for f in "${FUNCS[@]}"; do
  ok=0
  for attempt in 1 2 3; do
    echo "== $f (attempt $attempt)"
    if firebase deploy --only "functions:$f"; then ok=1; break; fi
    sleep 30
  done
  [ "$ok" = 1 ] || failed+=("$f")
  sleep 10
done

echo
if [ ${#failed[@]} -eq 0 ]; then
  echo "All functions deployed."
else
  echo "Still failing: ${failed[*]}"
fi
