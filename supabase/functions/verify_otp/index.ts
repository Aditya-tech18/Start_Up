import { serve } from "https://deno.land/std@0.192.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

serve(async (req: Request) => {
  try {
    const { email, otp, purpose } = await req.json() as {
      email?: string;
      otp?: string;
      purpose?: string;
    };

    if (!email || !otp) {
      return new Response("Missing data", { status: 400 });
    }

    const normalizedEmail = email.toLowerCase();
    const flowPurpose = (purpose === "signup" || purpose === "forgot")
      ? purpose
      : undefined;

    let query = supabase
      .from("password_reset_otps")
      .select("*")
      .eq("email", normalizedEmail)
      .eq("otp_code", otp)
      .eq("used", false)
      .gte("expires_at", new Date().toISOString());

    if (flowPurpose) {
      query = query.eq("purpose", flowPurpose);
    }

    const { data, error } = await query.single();

    if (error || !data) {
      return new Response(
        JSON.stringify({ valid: false, reason: "Invalid or expired OTP" }),
        { status: 400, headers: { "content-type": "application/json" } },
      );
    }

    await supabase
      .from("password_reset_otps")
      .update({ used: true })
      .eq("id", data.id);

    return new Response(JSON.stringify({ valid: true }), {
      status: 200,
      headers: { "content-type": "application/json" },
    });
  } catch (e) {
    console.error("verify_otp error", e);
    return new Response(
      JSON.stringify({ valid: false, error: String(e) }),
      { status: 500, headers: { "content-type": "application/json" } },
    );
  }
});
