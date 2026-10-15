// Supabase Auth's "Send SMS" hook: called instead of the built-in
// Twilio/MessageBird/Vonage integrations, so OTP delivery goes through
// MSG91's DLT-registered template (PLAN.md Phase 4 - required in India
// for transactional SMS). Registered in supabase/config.toml under
// [auth.hook.send_sms].
//
// Requires Edge Function secrets:
//   SEND_SMS_HOOK_SECRET  - the hook's own signing secret (from the
//                            dashboard when the hook is enabled; also
//                            set as SUPABASE_AUTH_SEND_SMS_HOOK_SECRET
//                            for config.toml's `secrets` field)
//   MSG91_AUTH_KEY         - MSG91 account auth key
//   MSG91_DLT_TEMPLATE_ID  - the approved DLT template id (must contain
//                            a single ##OTP## (or configured) variable)
//
// Dev/staging can keep using Supabase's test phone numbers (PLAN.md
// decisions table) without this hook enabled at all - it's a prod-only
// concern.

import { Webhook } from "npm:standardwebhooks@1.0.0";

Deno.serve(async (req) => {
  const hookSecret = Deno.env.get("SEND_SMS_HOOK_SECRET");
  const authKey = Deno.env.get("MSG91_AUTH_KEY");
  const templateId = Deno.env.get("MSG91_DLT_TEMPLATE_ID");
  if (!hookSecret || !authKey || !templateId) {
    return Response.json({ error: "MSG91/hook secrets not configured" }, { status: 500 });
  }

  const payload = await req.text();
  const headers = Object.fromEntries(req.headers);

  let data: { user?: { phone?: string }; sms?: { otp?: string } };
  try {
    const webhook = new Webhook(hookSecret);
    data = webhook.verify(payload, headers) as typeof data;
  } catch (error) {
    return Response.json(
      { error: `Invalid webhook signature: ${error}` },
      { status: 401 },
    );
  }

  const phone = data.user?.phone;
  const otp = data.sms?.otp;
  if (!phone || !otp) {
    return Response.json({ error: "Missing phone/otp in payload" }, { status: 400 });
  }

  const url = new URL("https://control.msg91.com/api/v5/otp");
  url.searchParams.set("template_id", templateId);
  url.searchParams.set("mobile", phone);
  url.searchParams.set("authkey", authKey);
  url.searchParams.set("otp", otp);

  const response = await fetch(url, { method: "POST" });
  const result = await response.json();

  if (!response.ok || result.type === "error") {
    return Response.json(
      { error: { http_code: 500, message: `MSG91 send failed: ${JSON.stringify(result)}` } },
      { status: 500 },
    );
  }

  return Response.json({});
});
