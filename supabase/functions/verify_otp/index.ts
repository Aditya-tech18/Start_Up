import { serve } from "https://deno.land/std@0.192.0/http/server.ts";


serve(async (req: Request) => {
  const { email, otp } = await req.json();
  if (!email || !otp) return new Response("Missing data", { status: 400 });

  // TODO: Verify OTP against your Supabase DB

  return new Response(JSON.stringify({ valid: true }), {
    headers: { "content-type": "application/json" }
  });
});
