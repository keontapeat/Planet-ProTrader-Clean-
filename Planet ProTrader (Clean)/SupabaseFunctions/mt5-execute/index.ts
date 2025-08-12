// Supabase Edge Function: mt5-execute
// Deploy: supabase functions deploy mt5-execute
// Invoke from app: POST https://<PROJECT>.supabase.co/functions/v1/mt5-execute
// Body: { symbol, volume, type: "buy"|"sell", accountLogin?, accountServer?, botId, botName, mode }

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req: Request) => {
  if (req.method !== "POST") {
    return new Response("Method Not Allowed", { status: 405 });
  }

  try {
    const { symbol, volume, type, accountLogin, accountServer, botId, botName, mode } = await req.json();

    if (!symbol || !volume || !type || !botId || !botName) {
      return Response.json({ error: "Missing fields" }, { status: 400 });
    }

    const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
    const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    const payload = {
      id: crypto.randomUUID(),
      created_at: new Date().toISOString(),
      status: "pending",
      symbol,
      volume,
      type,
      account_login: accountLogin ?? null,
      account_server: accountServer ?? null,
      bot_id: botId,
      bot_name: botName,
      mode: mode ?? "flip",
    };

    const { error } = await supabase.from("trade_commands").insert(payload);
    if (error) throw error;

    return Response.json({ ok: true, id: payload.id });
  } catch (e) {
    console.error("mt5-execute error:", e);
    return Response.json({ error: String(e) }, { status: 500 });
  }
});