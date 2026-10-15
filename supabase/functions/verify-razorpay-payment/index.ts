// Verifies the HMAC-SHA256 signature Razorpay Checkout returns after a
// successful payment, using RAZORPAY_KEY_SECRET (never on the client).
// The client calls this before place_order() and only proceeds if
// {"verified": true} comes back.
//
// Request body:
// {"razorpayOrderId": string, "razorpayPaymentId": string, "razorpaySignature": string}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const keySecret = Deno.env.get("RAZORPAY_KEY_SECRET");
  if (!keySecret) {
    return Response.json(
      { error: "Razorpay keys not configured" },
      { status: 500 },
    );
  }

  let body: {
    razorpayOrderId?: string;
    razorpayPaymentId?: string;
    razorpaySignature?: string;
  };
  try {
    body = await req.json();
  } catch {
    return Response.json({ error: "Invalid request" }, { status: 400 });
  }

  const { razorpayOrderId, razorpayPaymentId, razorpaySignature } = body;
  if (!razorpayOrderId || !razorpayPaymentId || !razorpaySignature) {
    return Response.json({ error: "Invalid request" }, { status: 400 });
  }

  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(keySecret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signatureBytes = await crypto.subtle.sign(
    "HMAC",
    key,
    new TextEncoder().encode(`${razorpayOrderId}|${razorpayPaymentId}`),
  );
  const computedSignature = Array.from(new Uint8Array(signatureBytes))
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");

  return Response.json({ verified: computedSignature === razorpaySignature });
});
