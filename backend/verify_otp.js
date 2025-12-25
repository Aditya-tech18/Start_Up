// netlify/functions/verify_otp.js
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

exports.handler = async (event) => {
  try {
    if (event.httpMethod !== 'POST') {
      return {
        statusCode: 405,
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ valid: false, reason: 'Method not allowed' }),
      };
    }

    const { email, otp } = JSON.parse(event.body || '{}');

    if (!email || !otp) {
      return {
        statusCode: 400,
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ valid: false, reason: 'Missing email or OTP' }),
      };
    }

    const normalizedEmail = String(email).toLowerCase();

    // 1) Find OTP for email, unused and not expired
    const { data, error } = await supabase
      .from('password_reset_otps')
      .select('*')
      .eq('email', normalizedEmail)
      .eq('otp_code', otp)
      .eq('used', false)
      .gte('expires_at', new Date().toISOString())
      .single();

    if (error || !data) {
      return {
        statusCode: 400,
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ valid: false, reason: 'Invalid or expired OTP' }),
      };
    }

    // 2) Mark OTP as used
    const { error: updateErr } = await supabase
      .from('password_reset_otps')
      .update({ used: true })
      .eq('id', data.id);

    if (updateErr) {
      console.error('verify_otp update error', updateErr);
      return {
        statusCode: 500,
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ valid: false, reason: 'Failed to mark OTP used' }),
      };
    }

    // 3) Success
    return {
      statusCode: 200,
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ valid: true, email: normalizedEmail }),
    };
  } catch (e) {
    console.error('verify_otp fatal error', e);
    return {
      statusCode: 500,
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ valid: false, error: String(e) }),
    };
  }
};
