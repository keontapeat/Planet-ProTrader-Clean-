//+------------------------------------------------------------------+
//| ProTraderBridgeEA.mq5 - Supabase bridge (file-config version)   |
//+------------------------------------------------------------------+
#property strict
#include <Trade/Trade.mqh>

input bool   USE_CONFIG_FILE    = true;
input string SUPABASE_BASE_URL  = "";
input string SUPABASE_API_KEY   = "";
input int    POLL_SECONDS       = 2;

CTrade   trade;
datetime last_poll = 0;

string g_baseUrl = "";
string g_apiKey  = "";
int    g_poll    = 2;
bool   g_loaded  = false;

bool LoadConfigFromFile() {
   int handle = FileOpen("ProTraderBridgeEA.cfg", FILE_READ|FILE_TXT|FILE_ANSI);
   if(handle == INVALID_HANDLE) return false;

   while(!FileIsEnding(handle)) {
      string token = FileReadString(handle);
      if(StringLen(token) == 0) continue;

      int eq = StringFind(token, "=");
      if(eq > 0) {
         string key = StringSubstr(token, 0, eq);
         string val = StringSubstr(token, eq + 1);
         if(StringCompare(key, "SUPABASE_BASE_URL") == 0) g_baseUrl = val;
         else if(StringCompare(key, "SUPABASE_API_KEY") == 0) g_apiKey = val;
         else if(StringCompare(key, "POLL_SECONDS") == 0) g_poll = (int)StringToInteger(val);
      }
   }
   FileClose(handle);
   return (StringLen(g_baseUrl) > 0 && StringLen(g_apiKey) > 0);
}

int OnInit() {
   g_poll = POLL_SECONDS;
   if(USE_CONFIG_FILE) {
      g_loaded = LoadConfigFromFile();
      if(!g_loaded) {
         Print("ProTraderBridgeEA: waiting for config file in MQL5/Files/ProTraderBridgeEA.cfg");
      }
   }
   if(!g_loaded) {
      g_baseUrl = SUPABASE_BASE_URL;
      g_apiKey  = SUPABASE_API_KEY;
   }
   Print("ProTraderBridgeEA initialized");
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
   Print("ProTraderBridgeEA deinit");
}

void OnTick() {
   if(USE_CONFIG_FILE && !g_loaded) {
      g_loaded = LoadConfigFromFile();
      if(!g_loaded) return;
   }
   if(TimeCurrent() - last_poll < g_poll) return;
   last_poll = TimeCurrent();
   ProcessNextCommand();
}

void ProcessNextCommand() {
   if(StringLen(g_baseUrl)==0 || StringLen(g_apiKey)==0) return;

   string url = g_baseUrl + "/rest/v1/trade_commands?status=eq.pending&order=created_at.asc&limit=1";
   string headers =
      "apikey: " + g_apiKey + "\r\n" +
      "Authorization: Bearer " + g_apiKey + "\r\n" +
      "Accept: application/json\r\n";

   uchar  empty[];
   ArrayResize(empty, 0);
   uchar  result[];
   string result_headers = "";
   ResetLastError();
   int code = WebRequest("GET", url, headers, "", 5000, empty, 0, result, result_headers);
   if(code != 200) {
      Print("GET failed: code=", code, " err=", GetLastError());
      return;
   }

   string body = CharArrayToString(result, 0, -1, CP_UTF8);
   if(StringLen(body) < 5 || StringFind(body, "\"id\"") < 0) {
      return;
   }

   string id     = extract(body, "\"id\":\"", "\"");
   string symbol = extract(body, "\"symbol\":\"", "\"");
   string type   = extract(body, "\"type\":\"", "\"");
   double volume = StringToDouble(extract(body, "\"volume\":", ","));
   if(volume <= 0.0) volume = 0.10;

   bool ok = ExecuteOrder(symbol, type, volume);
   string status = ok ? "executed" : "failed";
   UpdateStatus(id, status);
}

bool ExecuteOrder(string symbol, string type, double volume) {
   MqlTick tick;
   if(!SymbolInfoTick(symbol, tick)) {
      Print("Symbol tick not available: ", symbol);
      return false;
   }
   trade.SetAsyncMode(false);
   bool placed = false;
   if(StringToLower(type) == "buy")
      placed = trade.Buy(volume, symbol, tick.ask, 0, 0, "ProTraderBridge");
   else
      placed = trade.Sell(volume, symbol, tick.bid, 0, 0, "ProTraderBridge");

   if(!placed) {
     Print("Order failed, err=", _LastError);
   } else {
     Print("OK ", StringToUpper(type), " ", DoubleToString(volume, 2), " ", symbol);
   }
   return placed;
}

void UpdateStatus(string id, string status) {
   if(StringLen(g_baseUrl)==0 || StringLen(g_apiKey)==0) return;

   string url = g_baseUrl + "/rest/v1/trade_commands?id=eq." + id;
   string payload = "{\"status\":\"" + status + "\",\"executed_at\":\"" + TimeToISOUTC(TimeCurrent()) + "\"}";
   string headers =
      "apikey: " + g_apiKey + "\r\n" +
      "Authorization: Bearer " + g_apiKey + "\r\n" +
      "Content-Type: application/json\r\n" +
      "Prefer: return=minimal\r\n";

   uchar body_arr[];
   int  body_len = StringToCharArray(payload, body_arr, 0, WHOLE_ARRAY, CP_UTF8);
   if(body_len <= 0) body_len = ArraySize(body_arr);

   uchar  result[];
   string result_headers = "";
   int code = WebRequest("PATCH", url, headers, "", 8000, body_arr, body_len, result, result_headers);
   if(code >= 200 && code < 300) {
      Print("Command ", id, " -> ", status);
   } else {
      Print("PATCH failed: code=", code, " err=", GetLastError());
   }
}

string extract(string src, string left, string right) {
   int a = StringFind(src, left); if(a < 0) return "";
   a += StringLen(left);
   int b = StringFind(src, right, a); if(b < 0) b = StringLen(src);
   return StringSubstr(src, a, b - a);
}

string TimeToISOUTC(datetime t) {
   MqlDateTime dt; TimeToStruct(t, dt);
   string iso = IntegerToString(dt.year, 4) + "-" +
                IntegerToString(dt.mon, 2, '0') + "-" +
                IntegerToString(dt.day, 2, '0') + "T" +
                IntegerToString(dt.hour, 2, '0') + ":" +
                IntegerToString(dt.min, 2, '0') + ":" +
                IntegerToString(dt.sec, 2, '0') + "Z";
   return iso;
}