// device_manager.js
const { createClient } = require('@supabase/supabase-js');
const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);

exports.handler = async (event) => {
  const { user_id, device_id } = JSON.parse(event.body);
  if (!user_id || !device_id) return { statusCode: 400, body: 'Missing user_id or device_id' };

  const { data: devices, error } = await supabase
    .from('user_devices')
    .select()
    .eq('user_id', user_id);

  if (error) return { statusCode: 500, body: error.message };

  // Already registered device: just update timestamp
  if (devices.some(d => d.device_id === device_id)) {
    await supabase.from('user_devices').update({ last_active: new Date().toISOString() }).eq('device_id', device_id);
    return { statusCode: 200, body: JSON.stringify({ allowed: true }) };
  }

  // If >=2 devices, remove oldest
  if (devices.length >= 2) {
    const oldest = devices.reduce((a, b) => new Date(a.last_active) < new Date(b.last_active) ? a : b);
    await supabase.from('user_devices').delete().eq('id', oldest.id);
  }

  // Register new device
  await supabase.from('user_devices').insert([{
    user_id,
    device_id,
    last_active: new Date().toISOString(),
  }]);

  return { statusCode: 200, body: JSON.stringify({ allowed: true }) };
};
