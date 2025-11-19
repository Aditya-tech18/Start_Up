import { serve } from "https://deno.land/std@0.192.0/http/server.ts";


serve(async (req: Request) => {
  const { user_id, device_id } = await req.json();
  if (!user_id || !device_id) {
    return new Response("Missing data", { status: 400 });
  }

  // TODO: Device management logic (limit, evict, update DB)

  return new Response(JSON.stringify({ allowed: true }), {
    headers: { "content-type": "application/json" }
  });
});
