// Confirms a PhonePe payment server-side and, once it has COMPLETED for the
// quoted amount, creates the order (place_paid_order, service role). The
// app only reports what happened; it can't create a prepaid order itself.
//
// Safe to call repeatedly: a completed intent returns the same order id.
// If the app dies after paying, calling this again (e.g. on next launch)
// still creates the order.
//
// Request body: {"merchantOrderId": string}
// Response: {verified, pending, orderId, needsReview}
//   verified    – PhonePe says COMPLETED for the right amount
//   pending     – not settled yet; poll again shortly
//   orderId     – the created order (null if not created)
//   needsReview – paid, but the order couldn't be created (stock ran out,
//                 amount mismatch…); support must refund or fulfil it

import { adminClient, requireUser } from "../_shared/auth.ts";
import { getPhonePeAccessToken, phonePeBase } from "../_shared/phonepe.ts";

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const userId = await requireUser(req);
  if (!userId) {
    return Response.json({ error: "Not authenticated" }, { status: 401 });
  }

  let body: { merchantOrderId?: string };
  try {
    body = await req.json();
  } catch {
    return Response.json({ error: "Invalid request" }, { status: 400 });
  }
  const { merchantOrderId } = body;
  if (!merchantOrderId) {
    return Response.json({ error: "Invalid request" }, { status: 400 });
  }

  const db = adminClient();

  // Only the payer may check (and complete) their own payment.
  const { data: intent } = await db
    .from("payment_intents")
    .select("user_id, status, order_id")
    .eq("merchant_order_id", merchantOrderId)
    .maybeSingle();
  if (!intent || intent.user_id !== userId) {
    return Response.json({ error: "Unknown payment" }, { status: 404 });
  }

  if (intent.order_id) {
    return Response.json({
      verified: true,
      pending: false,
      orderId: intent.order_id,
      needsReview: false,
    });
  }
  if (intent.status === "needs_review") {
    return Response.json({ verified: true, pending: false, orderId: null, needsReview: true });
  }

  let accessToken: string;
  try {
    accessToken = await getPhonePeAccessToken();
  } catch (error) {
    return Response.json({ error: String(error) }, { status: 502 });
  }

  const response = await fetch(
    `${phonePeBase()}/checkout/v2/order/${encodeURIComponent(merchantOrderId)}/status?details=true`,
    { headers: { Authorization: `O-Bearer ${accessToken}` } },
  );
  const data = await response.json();
  if (!response.ok) {
    return Response.json(data, { status: response.status });
  }

  if (data.state === "PENDING") {
    return Response.json({ verified: false, pending: true, orderId: null, needsReview: false });
  }
  if (data.state !== "COMPLETED") {
    await db
      .from("payment_intents")
      .update({ status: "failed", failure_reason: data.state, updated_at: new Date().toISOString() })
      .eq("merchant_order_id", merchantOrderId)
      .eq("status", "created");
    return Response.json({ verified: false, pending: false, orderId: null, needsReview: false });
  }

  // COMPLETED can briefly come back without its transaction details.
  const transactionId = data.paymentDetails?.[0]?.transactionId;
  if (!transactionId) {
    return Response.json({ verified: false, pending: true, orderId: null, needsReview: false });
  }

  const { data: orderId, error } = await db.rpc("place_paid_order", {
    p_merchant_order_id: merchantOrderId,
    p_transaction_id: transactionId,
    p_paid_amount_paise: data.amount,
  });

  if (error || !orderId) {
    // Paid but not placed: the intent is now `needs_review` with the reason.
    return Response.json({ verified: true, pending: false, orderId: null, needsReview: true });
  }

  return Response.json({ verified: true, pending: false, orderId, needsReview: false });
});
