// Deletes the caller's account (Google Play requires an in-app deletion
// path for apps that create accounts).
//
// Deleting the auth user cascades to everything personal: profile,
// addresses, cart, favourites, payment intents. Orders are kept for
// accounting but lose their link to the person (orders.user_id and
// address_id are ON DELETE SET NULL; see 20261101120000_secure_payments.sql)
// — the address text snapshot on each order remains, as invoices require.
//
// Request: POST with the user's JWT, body {"confirm": "DELETE"}.

import { adminClient, requireUser } from "../_shared/auth.ts";

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const userId = await requireUser(req);
  if (!userId) {
    return Response.json({ error: "Not authenticated" }, { status: 401 });
  }

  let body: { confirm?: string } = {};
  try {
    body = await req.json();
  } catch {
    // fall through to the check below
  }
  // A second, explicit confirmation so a stray call can't delete anything.
  if (body.confirm !== "DELETE") {
    return Response.json({ error: "Confirmation required" }, { status: 400 });
  }

  const { error } = await adminClient().auth.admin.deleteUser(userId);
  if (error) {
    return Response.json({ error: error.message }, { status: 500 });
  }

  return Response.json({ deleted: true });
});
