// otp_generator.js (Netlify function style)
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

const RESEND_API_KEY = process.env.RESEND_API_KEY || 're_M6xchEB9_NQ7B6rzuWFpjcb2aoZhdVFbP';

exports.handler = async (event) => {
  try {
    if (event.httpMethod !== 'POST') {
      return {
        statusCode: 405,
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ success: false, message: 'Method not allowed' }),
      };
    }

    const { email } = JSON.parse(event.body || '{}');
    if (!email) {
      return {
        statusCode: 400,
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ success: false, message: 'Email required' }),
      };
    }

    const normalizedEmail = email.toLowerCase();

    // 1) Check if user exists in public.users
    const { data: userRow, error: userErr } = await supabase
      .from('users')
      .select('id')
      .eq('email', normalizedEmail)
      .maybeSingle();

    if (userErr) {
      console.error('otp_generator user check error', userErr);
      return {
        statusCode: 500,
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ success: false, error: userErr.message }),
      };
    }

    if (!userRow) {
      // Email not registered
      return {
        statusCode: 200,
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ success: true, user_exists: false }),
      };
    }

    // 2) Generate OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();

    // 3) Store OTP for verification
    const { error: insertErr } = await supabase
      .from('password_reset_otps')
      .insert({
        email: normalizedEmail,
        otp_code: otp,
        used: false,
        expires_at: new Date(Date.now() + 5 * 60 * 1000).toISOString(), // 5 minutes
      });

    if (insertErr) {
      console.error('otp_generator insert error', insertErr);
      return {
        statusCode: 500,
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ success: false, error: insertErr.message }),
      };
    }

    // 4) Send OTP email with Resend
    const res = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${RESEND_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: 'noreply@prepixo.info',
        to: [normalizedEmail],
        subject: 'Your OTP Code',
        html: `<p>Your OTP is: <b>${otp}</b></p>`,
      }),
    });

    const apiResult = await res.text();
    if (!res.ok) {
      console.error('Resend error', apiResult);
      return {
        statusCode: 500,
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ success: false, error: apiResult }),
      };
    }

    // 5) Success response with user_exists true
    return {
      statusCode: 200,
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ success: true, user_exists: true }),
    };
  } catch (e) {
    console.error('otp_generator fatal', e);
    return {
      statusCode: 500,
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ success: false, error: String(e) }),
    };
  }
};
