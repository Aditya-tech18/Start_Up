import { serve } from "https://deno.land/std@0.192.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const RESEND_API_KEY = "re_M6xchEB9_NQ7B6rzuWFpjcb2aoZhdVFbP";

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

serve(async (req: Request) => {
  try {
    const { email, purpose } = await req.json() as {
      email?: string;
      purpose?: string;
    };

    if (!email) {
      return new Response(
        JSON.stringify({ success: false, message: "Email required" }),
        {
          status: 400,
          headers: { "content-type": "application/json" },
        },
      );
    }

    const normalizedEmail = (email as string).toLowerCase();
    const flowPurpose = (purpose === "signup" || purpose === "forgot")
      ? purpose
      : "forgot"; // default

    // Check: public.users table me email exist karta hai ya nahi
    const { data: userRow, error: userErr } = await supabase
      .from("users")
      .select("id")
      .eq("email", normalizedEmail)
      .maybeSingle();

    if (userErr) {
      console.error("otp_generator user check error", userErr);
      return new Response(
        JSON.stringify({ success: false, error: userErr.message }),
        {
          status: 500,
          headers: { "content-type": "application/json" },
        },
      );
    }

    // Agar signup purpose hai to check mat karo user exists ya nahi
    // Agar forgot purpose hai to user must exist
    if (flowPurpose === "forgot" && !userRow) {
      return new Response(
        JSON.stringify({ success: true, user_exists: false }),
        {
          status: 200,
          headers: { "content-type": "application/json" },
        },
      );
    }

    // OTP generate karo
    const otp = Math.floor(100000 + Math.random() * 900000).toString();

    // OTP ko password_reset_otps table me insert karo
    const { error: insertErr } = await supabase
      .from("password_reset_otps")
      .insert({
        email: normalizedEmail,
        otp_code: otp,
        used: false,
        purpose: flowPurpose,
        expires_at: new Date(Date.now() + 5 * 60 * 1000).toISOString(),
      });

    if (insertErr) {
      console.error("otp_generator insert error", insertErr);
      return new Response(
        JSON.stringify({ success: false, error: insertErr.message }),
        {
          status: 500,
          headers: { "content-type": "application/json" },
        },
      );
    }

    // Resend API se email bhejo
    const res = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${RESEND_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: "noreply@prepixo.info",
        to: [normalizedEmail],
        subject: "Your OTP Code",
        html: `<p>Your OTP is: <b>${otp}</b></p>`,
      }),
    });

    const apiResult = await res.text();
    if (!res.ok) {
      console.error("Resend error", apiResult);
      return new Response(
        JSON.stringify({ success: false, error: apiResult }),
        {
          status: 500,
          headers: { "content-type": "application/json" },
        },
      );
    }

    return new Response(
      JSON.stringify({ success: true, user_exists: userRow ? true : false }),
      {
        status: 200,
        headers: { "content-type": "application/json" },
      },
    );
  } catch (e) {
    console.error("otp_generator fatal error", e);
    return new Response(
      JSON.stringify({ success: false, error: String(e) }),
      {
        status: 500,
        headers: { "content-type": "application/json" },
      },
    );
  }
});
