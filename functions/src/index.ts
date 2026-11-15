import { setGlobalOptions } from "firebase-functions/options";
import { REGION } from "./shared/firebase";

// Small, short functions: a fraction of a vCPU ("gcf_gen1" = 1st-gen sizing,
// ~0.17 vCPU at 256 MiB, one request per instance) and at most 5 instances
// each. Cloud Run counts cpu x maxInstances of every service against the
// project's regional CPU quota; 29 functions at 1 vCPU x 10 hit it.
setGlobalOptions({ region: REGION, maxInstances: 5, cpu: "gcf_gen1" });

export { placeOrder } from "./orders/place_order";
export { createPayUOrder, signPayUHash, verifyPayUPayment } from "./payments/callables";
export { reconcilePayUIntents } from "./payments/reconcile";
export { payuWebhook } from "./payments/webhook";
export { placesProxy } from "./places";
export { deleteAccount } from "./account";
export { onOrderEventCreated } from "./push";
export { adminUpdateOrderStatus, adminListUsers } from "./admin/orders";
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
} from "./notifications/campaigns";
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
} from "./dispatch/delivery";
export { riderSos, adminResolveSos } from "./dispatch/sos";
export { adminSaveRiderConfig } from "./dispatch/admin";
export {
  riderRequestPayout,
  adminRecordPayout,
  adminAdjustEarnings,
  adminSaveRiderOffer,
  settleIncentives,
} from "./dispatch/pay";
export { riderBookSlot, riderCancelSlot } from "./dispatch/gigs";
export { rateRider } from "./dispatch/rating";
export { onSupportMessageCreated } from "./support/bot";
export { adminSaveKbEntry, adminDeleteKbEntry } from "./support/kb/admin";
export {
  openSupportChat,
  requestSupportAgent,
  adminReplySupport,
  adminCloseSupport,
} from "./support/chat";
