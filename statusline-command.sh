#!/usr/bin/env bash
# Claude Code status line script
# Fields: git branch | model | balance | monthly spend | claude status

# ---------------------------------------------------------------
# USER CONFIG — edit these two values to match your Anthropic plan
MONTHLY_BUDGET=40.00      # USD: your monthly Claude Code spend budget
ACCOUNT_BALANCE=40.00     # USD: current prepaid credit balance (update manually when you top up)
# ---------------------------------------------------------------

SPEND_FILE="${HOME}/.claude/monthly-spend.json"
THIS_MONTH=$(date +%Y-%m)

# ANSI colors
C_RESET='\033[0m'
C_DIM='\033[2m'
C_CYAN='\033[36m'
C_YELLOW='\033[33m'
C_GREEN='\033[32m'
C_RED='\033[31m'

input=$(cat)

# =============================================================
# 1. Git branch
# =============================================================
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // ""')
git_branch=""
if [ -n "$cwd" ]; then
  git_branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
fi

# =============================================================
# 2. Model name
# =============================================================
model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')

# =============================================================
# 3 & 4. Monthly spend tracking -> balance + budget fields
# spend file schema: { "month": "YYYY-MM", "sessions": { "<id>": <cost_float> } }
# Each session key holds the cost of the most recent API call for that session.
# =============================================================
session_id=$(echo "$input" | jq -r '.session_id // ""')
current=$(echo "$input" | jq -r '.context_window.current_usage // empty')
call_cost_raw=0

if [ -n "$current" ]; then
  input_tokens=$(echo "$current" | jq -r '.input_tokens // 0')
  output_tokens=$(echo "$current" | jq -r '.output_tokens // 0')
  cache_read=$(echo "$current" | jq -r '.cache_read_input_tokens // 0')
  cache_write=$(echo "$current" | jq -r '.cache_creation_input_tokens // 0')
  # Pricing: input $3/M, output $15/M, cache_write $3.75/M, cache_read $0.30/M
  call_cost_raw=$(awk "BEGIN {
    printf \"%.6f\", ($input_tokens * 3 + $output_tokens * 15 + $cache_write * 3.75 + $cache_read * 0.30) / 1000000
  }")
fi

# Reset spend file if missing or it's a new month
if [ ! -f "$SPEND_FILE" ]; then
  echo "{\"month\":\"${THIS_MONTH}\",\"sessions\":{}}" > "$SPEND_FILE"
else
  file_month=$(jq -r '.month // ""' "$SPEND_FILE" 2>/dev/null)
  if [ "$file_month" != "$THIS_MONTH" ]; then
    echo "{\"month\":\"${THIS_MONTH}\",\"sessions\":{}}" > "$SPEND_FILE"
  fi
fi

# Write latest call cost for this session
if [ -n "$session_id" ] && [ "$call_cost_raw" != "0" ] && [ "$call_cost_raw" != "0.000000" ]; then
  jq --arg sid "$session_id" --argjson cost "$call_cost_raw" \
    '.sessions[$sid] = $cost' "$SPEND_FILE" > "${SPEND_FILE}.tmp" 2>/dev/null \
    && mv "${SPEND_FILE}.tmp" "$SPEND_FILE"
fi

# Sum all sessions for month-to-date spend
monthly_spend=$(jq '[.sessions | to_entries[] | .value] | add // 0' "$SPEND_FILE" 2>/dev/null)
monthly_spend=${monthly_spend:-0}

# --- Balance (field 3) ---
balance_val=$(awk "BEGIN { printf \"%.2f\", $ACCOUNT_BALANCE - $monthly_spend }")
balance_fmt="\$${balance_val}"
# Green > 50% remaining, yellow 20-50%, red <= 20%
BAL_C=$(awk -v bal="$balance_val" -v acct="$ACCOUNT_BALANCE" \
  -v g="$C_GREEN" -v y="$C_YELLOW" -v r="$C_RED" \
  'BEGIN { ratio = bal / acct; if (ratio > 0.50) print g; else if (ratio > 0.20) print y; else print r }')

# --- Monthly spend vs budget (field 4) ---
spend_fmt=$(awk "BEGIN {
  s = $monthly_spend
  if (s < 0.01) printf \"\$%.4f\", s
  else printf \"\$%.2f\", s
}")
budget_fmt="\$$(awk "BEGIN { printf \"%.0f\", $MONTHLY_BUDGET }")"
budget_pct=$(awk "BEGIN { printf \"%.0f\", ($monthly_spend / $MONTHLY_BUDGET) * 100 }")
# Green <= 50%, yellow 50-80%, red > 80%
SPD_C=$(awk -v spend="$monthly_spend" -v budget="$MONTHLY_BUDGET" \
  -v g="$C_GREEN" -v y="$C_YELLOW" -v r="$C_RED" \
  'BEGIN { ratio = spend / budget; if (ratio >= 0.80) print r; else if (ratio >= 0.50) print y; else print g }')

# =============================================================
# 5. Claude status — fetched from status.claude.com, cached 5 min
# Uses the Atlassian Statuspage JSON API: /api/v2/summary.json
# Indicator values: "none" = all good, anything else = incident/outage
# =============================================================
STATUS_CACHE="${HOME}/.claude/claude-status-cache.json"
STATUS_TTL=300   # seconds (5 minutes)

# Determine whether the cache is still fresh
cache_valid=false
if [ -f "$STATUS_CACHE" ]; then
  cache_mtime=$(stat -f "%m" "$STATUS_CACHE" 2>/dev/null || stat -c "%Y" "$STATUS_CACHE" 2>/dev/null)
  now=$(date +%s)
  if [ -n "$cache_mtime" ] && [ $(( now - cache_mtime )) -lt $STATUS_TTL ]; then
    cache_valid=true
  fi
fi

if [ "$cache_valid" = true ]; then
  status_json=$(cat "$STATUS_CACHE" 2>/dev/null)
else
  status_json=$(curl -sf --max-time 3 \
    "https://status.claude.com/api/v2/summary.json" 2>/dev/null)
  if [ -n "$status_json" ]; then
    echo "$status_json" > "$STATUS_CACHE"
  else
    # Fetch failed — use stale cache if available, otherwise mark unknown
    status_json=$(cat "$STATUS_CACHE" 2>/dev/null)
  fi
fi

# Parse: .status.indicator is "none" when all systems operational
if [ -n "$status_json" ]; then
  indicator=$(echo "$status_json" | jq -r '.status.indicator // "unknown"' 2>/dev/null)
  # Also check for any active incidents as a secondary signal
  incident_count=$(echo "$status_json" | jq '.incidents | length' 2>/dev/null)
else
  indicator="unknown"
  incident_count=0
fi

if [ "$indicator" = "none" ] && [ "${incident_count:-0}" -eq 0 ]; then
  claude_status="Systems Online"
  STATUS_C="$C_GREEN"
elif [ "$indicator" = "unknown" ]; then
  claude_status="Status Unknown"
  STATUS_C="$C_DIM"
else
  claude_status="Outage"
  STATUS_C="$C_RED"
fi

# =============================================================
# Assemble — 5 fields separated by dim pipes
# =============================================================
sep="$(printf " ${C_DIM}|${C_RESET} ")"
parts=()

# 1. Git branch
if [ -n "$git_branch" ]; then
  parts+=("$(printf "${C_CYAN}\ue0a0 %s${C_RESET}" "$git_branch")")
else
  parts+=("$(printf "${C_DIM}no git${C_RESET}")")
fi

# 2. Model
parts+=("$(printf "${C_YELLOW}%s${C_RESET}" "$model")")

# 3. Balance
parts+=("$(printf "${BAL_C}bal %s${C_RESET}" "$balance_fmt")")

# 4. Monthly spend vs budget
parts+=("$(printf "${SPD_C}%s/%s (%s%%)${C_RESET}" "$spend_fmt" "$budget_fmt" "$budget_pct")")

# 5. Claude status
parts+=("$(printf "${STATUS_C}%s${C_RESET}" "$claude_status")")

result=""
for part in "${parts[@]}"; do
  if [ -z "$result" ]; then
    result="$part"
  else
    result="${result}${sep}${part}"
  fi
done

printf '%s' "$result"
