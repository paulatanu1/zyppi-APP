// Creates a PhonePe Standard Checkout order for the caller's *server* cart.
//
// The amount is never taken from the client: quote_order() validates the
// address, slot, stock and coupon and computes the total from live prices,
// so an order that can't be placed is rejected *before* the customer pays.
// The quote and the order's parameters are stored as a payment_intent;
// verify-phonepe-payment later turns that intent into the order.
//
// Requires Edge Function secrets: PHONEPE_CLIENT_ID, PHONEPE_CLIENT_SECRET,
// PHONEPE_CLIENT_VERSION, PHONEPE_MERCHANT_ID, PHONEPE_ENV (SANDBOX or
// PRODUCTION).
//
// Request body:
//   {"paymentMethod": "UPI" | "Credit or debit card", "addressId": uuid,
//    "deliverySlotId": uuid, "couponCode"?: string, "tipPaise"?: number}
// Response: {merchantOrderId, orderId, token, merchantId, amountPaise}

import { adminClient, requireUser } from "../_shared/auth.ts";
import { getPhonePeAccessToken, phonePeBase } from "../_shared/phonepe.ts";

const PAYMENT_METHODS = ["UPI", "Credit or debit card"];

function paymentModeConfig(paymentMethod: string) {
  if (paymentMethod === "Credit or debit card") {
    return {
      enabledPaymentModes: [
        { type: "CARD", cardTypes: ["DEBIT_CARD", "CREDIT_CARD"] },
      ],
    };
  }
  return {
    enabledPaymentModes: [
      { type: "UPI_INTENT" },
      { type: "UPI_COLLECT" },
      { type: "UPI_QR" },
    ],
  };
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const merchantId = Deno.env.get("PHONEPE_MERCHANT_ID");
  if (!merchantId) {
    return Response.json({ error: "PhonePe keys not configured" }, { status: 500 });
  }

  const userId = await requireUser(req);
  if (!userId) {
    return Response.json({ error: "Not authenticated" }, { status: 401 });
  }

  let body: {
    paymentMethod?: string;
    addressId?: string;
    deliverySlotId?: string;
    couponCode?: string | null;
    tipPaise?: number;
  };
  try {
    body = await req.json();
  } catch {
    return Response.json({ error: "Invalid request" }, { status: 400 });
  }

  const paymentMethod = body.paymentMethod ?? "UPI";
  const tipPaise = Math.trunc(body.tipPaise ?? 0);
  if (!PAYMENT_METHODS.includes(paymentMethod) || !body.addressId || !body.deliverySlotId) {
    return Response.json({ error: "Invalid request" }, { status: 400 });
  }

  const db = adminClient();

  // Validates everything place_order would, and prices it server-side.
  const { data: quote, error: quoteError } = await db
    .rpc("quote_order", {
      p_user_id: userId,
      p_address_id: body.addressId,
      p_delivery_slot_id: body.deliverySlotId,
      p_coupon_code: body.couponCode ?? null,
      p_tip_paise: tipPaise,
    })
    .single();
  if (quoteError || !quote) {
    // e.g. "Insufficient stock for Milk" — shown to the user as-is.
    return Response.json(
      { error: quoteError?.message ?? "Could not price order", code: "QUOTE_FAILED" },
      { status: 409 },
    );
  }

  const amountPaise = (quote as { total_paise: number }).total_paise;
  const merchantOrderId = `zyppi-${crypto.randomUUID()}`;

  const { error: intentError } = await db.from("payment_intents").insert({
    merchant_order_id: merchantOrderId,
    user_id: userId,
    amount_paise: amountPaise,
    payment_method: paymentMethod,
    address_id: body.addressId,
    delivery_slot_id: body.deliverySlotId,
    coupon_code: body.couponCode ?? null,
    tip_paise: tipPaise,
  });
  if (intentError) {
    return Response.json({ error: intentError.message }, { status: 500 });
  }

  let accessToken: string;
  try {
    accessToken = await getPhonePeAccessToken();
  } catch (error) {
    return Response.json({ error: String(error) }, { status: 502 });
  }

  const response = await fetch(`${phonePeBase()}/checkout/v2/sdk/order`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `O-Bearer ${accessToken}`,
    },
    body: JSON.stringify({
      merchantOrderId,
      amount: amountPaise,
      paymentFlow: {
        type: "PG_CHECKOUT",
        paymentModeConfig: paymentModeConfig(paymentMethod),
      },
    }),
  });

  const data = await response.json();
  if (!response.ok) {
    await db
      .from("payment_intents")
      .update({ status: "failed", failure_reason: JSON.stringify(data) })
      .eq("merchant_order_id", merchantOrderId);
    return Response.json(data, { status: response.status });
  }

  return Response.json({
    merchantOrderId,
    orderId: data.orderId,
    token: data.token,
    merchantId,
    amountPaise,
  });
});
