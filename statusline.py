#!/usr/bin/env python3
# Status line: model, 5-hour plan usage bar, reset time, this conversation's context tokens.
import json, sys, time, os, urllib.request
from datetime import datetime

CACHE = os.path.expanduser("~/.claude/.usage_cache.json")

def fetch_usage():
    # Before the first reply there is no rate_limits on stdin; ask the usage endpoint instead (cached 60s).
    try:
        c = json.load(open(CACHE))
        if time.time() - c["t"] < 60:
            return c["pct"], c["resets"]
    except Exception:
        pass
    try:
        tok = json.load(open(os.path.expanduser("~/.claude/.credentials.json")))["claudeAiOauth"]["accessToken"]
        req = urllib.request.Request("https://api.anthropic.com/api/oauth/usage",
            headers={"Authorization": "Bearer " + tok, "anthropic-beta": "oauth-2025-04-20"})
        f = json.load(urllib.request.urlopen(req, timeout=2))["five_hour"]
        pct, resets = f["utilization"], datetime.fromisoformat(f["resets_at"]).timestamp()
        json.dump({"t": time.time(), "pct": pct, "resets": resets}, open(CACHE, "w"))
        return pct, resets
    except Exception:
        return None, None

raw = sys.stdin.read()
d = json.loads(raw or '{}')
name = (d.get('model') or {}).get('display_name', 'Claude')
five = (d.get("rate_limits") or {}).get("five_hour") or {}
pct, resets = five.get("used_percentage"), five.get("resets_at")
if pct is None:
    pct, resets = fetch_usage()

ctx = d.get("context_window") or {}
u = ctx.get("current_usage") or {}
used = sum(u.get(k) or 0 for k in ("input_tokens", "cache_creation_input_tokens", "cache_read_input_tokens"))
size = ctx.get("context_window_size") or 0

if pct is None:
    out = f"{name}  [{'□' * 20}] --%"
else:
    pct = min(100, -int(-pct // 1))  # round up
    out = f"{name}  [{'■' * (pct // 5)}{'□' * (20 - pct // 5)}] {pct}%"
if resets:
    out += "  " + time.strftime("%-I:%M%p", time.localtime(resets))
print(f"{out}  {used // 1000}k / {size // 1000}k", end="")
