import { setGlobalOptions } from "firebase-functions/options";
import { REGION } from "./shared/firebase";

setGlobalOptions({ region: REGION, maxInstances: 10 });

export { placeOrder } from "./orders/place_order";
export { createPhonePeOrder, verifyPhonePePayment } from "./payments/callables";
export { placesProxy } from "./places";
export { deleteAccount } from "./account";
export { onOrderEventCreated } from "./push";
export { adminUpdateOrderStatus, adminListUsers } from "./admin/orders";
