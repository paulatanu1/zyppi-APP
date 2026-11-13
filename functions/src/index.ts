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
export { adminSaveProduct, onProductWritten } from "./catalog/products";
export {
  adminSaveCategory,
  adminDeleteCategory,
  adminReorderCategories,
} from "./catalog/categories";
export { adminAdjustStock } from "./catalog/inventory";
export {
  adminRefundPayment,
  adminRefreshRefund,
  adminResolveIntent,
  reconcileRefunds,
} from "./payments/refunds";
export { adminImportProducts } from "./catalog/import";
export { onSupportMessageCreated } from "./support/bot";
export {
  openSupportChat,
  requestSupportAgent,
  adminReplySupport,
  adminCloseSupport,
} from "./support/chat";
