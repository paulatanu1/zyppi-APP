import { setGlobalOptions } from "firebase-functions/options";
import { REGION } from "./shared/firebase";
import { DEFAULT_MAX_INSTANCES } from "./shared/scaling";

// Small, short functions: a fraction of a vCPU ("gcf_gen1" = 1st-gen sizing,
// ~0.17 vCPU at 256 MiB, one request per instance). The regional Cloud Run
// CPU quota (20 vCPU in asia-south1) counts running instances, and a deploy
// starts one per updated function: deploy with scripts/deploy-functions.sh
// (batches). maxInstances caps a runaway function; busy paths get 5
// (shared/scaling.ts HOT).
setGlobalOptions({ region: REGION, maxInstances: DEFAULT_MAX_INSTANCES, cpu: "gcf_gen1" });

export { placeOrder } from "./orders/place_order";
export { cancelMyOrder } from "./orders/cancel_order";
export { createPayUOrder, signPayUHash, verifyPayUPayment } from "./payments/callables";
export { reconcilePayUIntents } from "./payments/reconcile";
export { payuWebhook } from "./payments/webhook";
export { reportOrderIssue, adminResolveIssue, adminRejectIssue, adminCreditWallet } from "./wallet/claims";
export { recoverStuckPayouts } from "./wallet/recovery";
export { onReturnCreated, returnsSweep } from "./returns/dispatch";
export {
  riderRespondReturnOffer,
  riderReturnReachedCustomer,
  riderReturnPickedUp,
  riderReturnMismatch,
  riderReturnNotHome,
  riderReturnReachedStore,
} from "./returns/rider";
export { storeReceiveReturn, onReturnReceived, adminUpdateReturn } from "./returns/store";
export { adminSetZyppiStoreStaff } from "./marketplace/sellers";
export { adminSaveClaimsConfig } from "./returns/admin";
export { placesProxy } from "./places";
export { logSearch, adminSearchInsights } from "./search/search_stats";
export { deleteAccount, onUserProfileCreated } from "./account";
export { riderDeleteAccount } from "./riders/delete";
export { sellerDeleteAccount } from "./marketplace/seller_delete";
export { onOrderEventCreated } from "./push";
export { adminUpdateOrderStatus } from "./admin/orders";
export { adminUpdateFeatures } from "./admin/features";
export { adminSetRole } from "./admin/staff";
export {
  adminSaveServiceArea,
  adminSaveStore,
  adminSaveDeliverySlot,
  adminSaveDeliveryConfig,
  adminSaveAppConfig,
} from "./admin/settings";
export {
  adminGetCustomerAuth,
  adminSetCustomerBlocked,
  adminPushCustomer,
} from "./admin/customers";
export { adminSaveProduct, onProductWritten } from "./catalog/products";
export { sellerLookupBarcode } from "./catalog/barcode_lookup";
export {
  adminSaveCategory,
  adminDeleteCategory,
  adminReorderCategories,
} from "./catalog/categories";
export { adminAdjustStock } from "./catalog/inventory";
export {
  riderSaveApplication,
  adminReviewRider,
  adminSettleRiderCash,
} from "./riders/riders";
export {
  adminRefundPayment,
  adminRefreshRefund,
  adminResolveIntent,
  reconcileRefunds,
} from "./payments/refunds";
export { adminImportProducts } from "./catalog/import";
export {
  adminSaveHomeSection,
  adminReorderHomeSections,
  adminDeleteHomeSection,
  trackBannerClick,
} from "./home/home";
export { checkCoupon, adminSaveCoupon, adminDeleteCoupon } from "./coupons/coupons";
export {
  adminSaveCampaign,
  adminEstimateAudience,
  adminScheduleCampaign,
  adminCancelCampaign,
  adminTestCampaign,
  adminSaveTemplate,
  adminDeleteTemplate,
  trackCampaignOpen,
  dispatchCampaigns,
  sendScheduledCampaign,
  sendCampaignChunk,
} from "./notifications/campaigns";
export { registerPushToken, unregisterPushToken } from "./notifications/devices";
export { adminSellerTaxReport, sellerStatement } from "./marketplace/statements";
export { onOrderWritten } from "./stats/stats";
export { onOrderDispatch, dispatchSweep } from "./dispatch/dispatch";
export {
  riderSetOnline,
  riderPing,
  riderBreak,
  riderRegisterDevice,
  riderRespondOffer,
} from "./dispatch/presence";
export {
  riderReachedStore,
  riderPickUp,
  riderArrived,
  riderDeliver,
  riderCannotDeliver,
  riderReturnedToStore,
} from "./dispatch/delivery";
export { riderSos, adminResolveSos } from "./dispatch/sos";
export { onOrderForRiders } from "./dispatch/trips";
export { adminSaveRiderConfig } from "./dispatch/admin";
export {
  riderRequestPayout,
  adminRecordPayout,
  adminAdjustEarnings,
  adminSaveRiderOffer,
  settleIncentives,
  weeklyRiderSettlement,
} from "./dispatch/pay";
export { riderBookSlot, riderCancelSlot } from "./dispatch/gigs";
export { rateRider } from "./dispatch/rating";
export { adminAnnounceToRiders } from "./dispatch/announce";
export { onSupportMessageCreated } from "./support/bot";
export { adminSaveKbEntry, adminDeleteKbEntry } from "./support/kb/admin";
export {
  openSupportChat,
  requestSupportAgent,
  adminReplySupport,
  adminCloseSupport,
} from "./support/chat";
export {
  sellerSaveApplication,
  adminReviewSeller,
  adminSaveSellerPlan,
  sellerSetOnline,
  sellerAddStaff,
  sellerRemoveStaff,
} from "./marketplace/sellers";
export { sellerSubmitProduct, adminReviewProductRequest, adminSetSellerTrusted } from "./marketplace/product_requests";
export { legalStatus, acceptLegal, adminPublishLegalDoc } from "./legal/legal";
export { sellerSaveListing, adminSaveListing, sellerAdjustStock } from "./marketplace/listings";
export {
  onListingWritten,
  onInventoryWritten,
  onSellerWritten,
  onStoreWritten,
  refreshTimedOffers,
  applyListingPriceChange,
} from "./marketplace/offers_sync";
export {
  sellerAcceptOrder,
  sellerRejectOrder,
  sellerMarkReady,
  storeConfirmPickup,
  sellerReportIssue,
  sellerRegisterDevice,
  onOrderForSellers,
  escalateLateSellers,
  checkSellerAccept,
  adminForcePickup,
} from "./marketplace/seller_orders";
export {
  onOrderSettleSellers,
  adminReturnSellerItem,
  adminSetSellerPlan,
  sellerRequestPayout,
  adminRecordSellerPayout,
  adminRecordSellerFee,
  adminAdjustSellerEarnings,
  sellerDaily,
} from "./marketplace/settlement";
export { rateSellers } from "./marketplace/ratings";
export { sellerStoreIdSignIn, sellerStoreCode } from "./marketplace/store_code_auth";
