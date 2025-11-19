// verify_otp.js
const { createClient } = require('@supabase/supabase-js');
const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);

exports.handler = async (event) => {
  const { email, otp } = JSON.parse(event.body);
  if (!email || !otp) return { statusCode: 400, body: 'Missing email or OTP' };

  // Find OTP for email, unused and not expired
  const { data, error } = await supabase
    .from('password_reset_otps')
    .select()
    .eq('email', email)
    .eq('otp_code', otp)
    .eq('used', false)
    .gte('expires_at', new Date().toISOString())
    .single();

  if (error || !data) return { statusCode: 400, body: 'Invalid or expired OTP' };

  // Mark as used
  await supabase
    .from('password_reset_otps')
    .update({ used: true })
    .eq('id', data.id);

  return { statusCode: 200, body: JSON.stringify({ valid: true }) };
};
