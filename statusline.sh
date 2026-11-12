#!/bin/bash
# Status line: model, 5-hour plan usage bar, reset time, this conversation's context tokens.
input=$(cat)
name=$(jq -r '.model.display_name // "Claude"' <<< "$input")
pct=$(jq -r '.rate_limits.five_hour.used_percentage // empty' <<< "$input")
resets=$(jq -r '.rate_limits.five_hour.resets_at // empty' <<< "$input")
used=$(jq -r '.context_window.current_usage | [.input_tokens, .cache_creation_input_tokens, .cache_read_input_tokens] | map(. // 0) | add' <<< "$input")
size=$(jq -r '.context_window.context_window_size // 0' <<< "$input")

cache=~/.claude/.usage_cache
if [ -z "$pct" ]; then
    # Before the first reply there is no rate_limits on stdin; ask the usage endpoint instead (cached 60s).
    if [ -f "$cache" ] && [ $(( $(date +%s) - $(stat -c %Y "$cache") )) -lt 60 ]; then
        read -r pct resets < "$cache"
    else
        tok=$(jq -r '.claudeAiOauth.accessToken' ~/.claude/.credentials.json 2>/dev/null)
        five=$(curl -s --max-time 2 https://api.anthropic.com/api/oauth/usage \
            -H "Authorization: Bearer $tok" -H "anthropic-beta: oauth-2025-04-20" |
            jq -r '.five_hour | select(.utilization) | "\(.utilization) \(.resets_at)"' 2>/dev/null)
        read -r pct iso <<< "$five"
        if [ -n "$pct" ]; then
            resets=$(date -d "$iso" +%s)
            echo "$pct $resets" > "$cache"
        fi
    fi
fi

if [ -z "$pct" ]; then
    out="$name  [□□□□□□□□□□□□□□□□□□□□] --%"
else
    pct=$(awk -v p="$pct" 'BEGIN { c = int(p); if (c < p) c++; if (c > 100) c = 100; print c }')
    bar=""
    for i in $(seq 1 20); do
        if [ "$i" -le $((pct / 5)) ]; then bar+="■"; else bar+="□"; fi
    done
    out="$name  [$bar] $pct%"
fi
[ -n "$resets" ] && out+="  $(date -d "@$resets" +%-I:%M%p)"
printf '%s  %sk / %sk' "$out" $((used / 1000)) $((size / 1000))
