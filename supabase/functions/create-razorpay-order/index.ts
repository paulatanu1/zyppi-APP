// Creates a Razorpay order server-side (RAZORPAY_KEY_SECRET never reaches
// the client - PLAN.md Phase 4). The client opens Razorpay Checkout with
// the returned order id, then calls verify-razorpay-payment before
// place_order().
//
// Requires Edge Function secrets RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET:
// `supabase secrets set RAZORPAY_KEY_ID=... RAZORPAY_KEY_SECRET=...`.
//
// Request body: {"amountPaise": number}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const keyId = Deno.env.get("RAZORPAY_KEY_ID");
  const keySecret = Deno.env.get("RAZORPAY_KEY_SECRET");
  if (!keyId || !keySecret) {
    return Response.json(
      { error: "Razorpay keys not configured" },
      { status: 500 },
    );
  }

  let body: { amountPaise?: number };
  try {
    body = await req.json();
  } catch {
    return Response.json({ error: "Invalid request" }, { status: 400 });
  }

  if (!body.amountPaise || body.amountPaise <= 0) {
    return Response.json({ error: "Invalid amountPaise" }, { status: 400 });
  }

  const response = await fetch("https://api.razorpay.com/v1/orders", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Basic ${btoa(`${keyId}:${keySecret}`)}`,
    },
    body: JSON.stringify({
      amount: body.amountPaise,
      currency: "INR",
      receipt: `zyppi-${Date.now()}`,
    }),
  });

  const data = await response.json();
  if (!response.ok) {
    return Response.json(data, { status: response.status });
  }

  return Response.json({
    orderId: data.id,
    amountPaise: data.amount,
    currency: data.currency,
    keyId,
  });
});
