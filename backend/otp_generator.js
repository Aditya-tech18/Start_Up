import { serve } from "https://deno.land/std@0.192.0/http/server.ts";
const RESEND_API_KEY = "re_M6xchEB9_NQ7B6rzuWFpjcb2aoZhdVFbP"; // <-- Put your Resend API key here
serve(async (req)=>{
  const { email } = await req.json();
  if (!email) {
    return new Response("No email provided", {
      status: 400
    });
  }
  const otp = Math.floor(100000 + Math.random() * 900000).toString();
  // Send OTP using Resend REST API
  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${RESEND_API_KEY}`,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      from: "noreply@prepixo.info",
      to: [
        email
      ],
      subject: "Your OTP Code",
      html: `<p>Your OTP is: <b>${otp}</b></p>`
    })
  });
  const apiResult = await res.json();
  if (!res.ok) {
    return new Response(JSON.stringify({
      success: false,
      error: apiResult
    }), {
      status: 500
    });
  }
  // Optionally: store OTP in DB for verification
  return new Response(JSON.stringify({
    success: true
  }), {
    headers: {
      "content-type": "application/json"
    }
  });
});
