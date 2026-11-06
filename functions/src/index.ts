import { setGlobalOptions } from "firebase-functions/options";
import { REGION } from "./shared/firebase";

setGlobalOptions({ region: REGION, maxInstances: 10 });

export { placeOrder } from "./orders/place_order";
export { createPayUOrder, signPayUHash, verifyPayUPayment } from "./payments/callables";
export { placesProxy } from "./places";
export { deleteAccount } from "./account";
export { onOrderEventCreated } from "./push";
export { adminUpdateOrderStatus, adminListUsers } from "./admin/orders";
export { onSupportMessageCreated } from "./support/bot";
export {
  openSupportChat,
  requestSupportAgent,
  adminReplySupport,
  adminCloseSupport,
} from "./support/chat";
