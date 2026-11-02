import { createClient, SupabaseClient } from "jsr:@supabase/supabase-js@2";

/// Service-role client: bypasses RLS, so only use it after [requireUser]
/// has established who the caller is.
export function adminClient(): SupabaseClient {
  return createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    { auth: { persistSession: false } },
  );
}

/// The signed-in caller's user id from the request's JWT, or null.
/// (verify_jwt = true already rejects missing/invalid tokens at the
/// gateway; this resolves *which* user it is.)
export async function requireUser(req: Request): Promise<string | null> {
  const token = req.headers.get("Authorization")?.replace("Bearer ", "");
  if (!token) return null;

  const { data, error } = await adminClient().auth.getUser(token);
  if (error || !data.user) return null;
  return data.user.id;
}
