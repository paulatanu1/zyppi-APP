import { setGlobalOptions } from "firebase-functions/options";
import { REGION } from "./shared/firebase";

setGlobalOptions({ region: REGION, maxInstances: 10 });

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
export { adminImportProducts } from "./catalog/import";
export { onSupportMessageCreated } from "./support/bot";
export {
  openSupportChat,
  requestSupportAgent,
  adminReplySupport,
  adminCloseSupport,
} from "./support/chat";
