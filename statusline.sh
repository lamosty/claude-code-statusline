#!/bin/bash
# Lightweight Claude Code status line
# Reads JSON from stdin, outputs single line
# Uses jq if available, falls back to grep/sed

# Read JSON from stdin
JSON=$(cat)

# Try jq first (more robust), fall back to grep/sed
if command -v jq &>/dev/null; then
  MODEL=$(echo "$JSON" | jq -r '.model.display_name // "Opus"' 2>/dev/null)
  CTX_TOKENS=$(echo "$JSON" | jq -r '
    .context_window.current_usage |
    ((.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0))
  ' 2>/dev/null)
  USED_PCT=$(echo "$JSON" | jq -r '.context_window.used_percentage // 0' 2>/dev/null)
else
  # Fallback: grep/sed parsing
  MODEL=$(echo "$JSON" | grep -o '"display_name":"[^"]*"' | head -1 | sed 's/"display_name":"//;s/"//')
  MODEL=${MODEL:-Opus}
  INPUT_TOKENS=$(echo "$JSON" | grep -o '"input_tokens":[0-9]*' | tail -1 | sed 's/"input_tokens"://')
  CACHE_CREATE=$(echo "$JSON" | grep -o '"cache_creation_input_tokens":[0-9]*' | sed 's/"cache_creation_input_tokens"://')
  CACHE_READ=$(echo "$JSON" | grep -o '"cache_read_input_tokens":[0-9]*' | sed 's/"cache_read_input_tokens"://')
  CTX_TOKENS=$((${INPUT_TOKENS:-0} + ${CACHE_CREATE:-0} + ${CACHE_READ:-0}))
  USED_PCT=$(echo "$JSON" | grep -o '"used_percentage":[0-9]*' | sed 's/"used_percentage"://')
fi

# Git branch
BRANCH=$(git branch --show-current 2>/dev/null)

# Format context and set color
RESET="\033[0m"
DIM="\033[2m"

if [[ "$CTX_TOKENS" =~ ^[0-9]+$ ]] && [[ "$CTX_TOKENS" -gt 0 ]]; then
  CTX_K=$(awk "BEGIN {printf \"%.1f\", $CTX_TOKENS / 1000}")
  USED_INT=${USED_PCT%.*}
  USED_INT=${USED_INT:-0}
  if [[ "$USED_INT" -gt 80 ]]; then
    COLOR="\033[31m"  # Red
  elif [[ "$USED_INT" -gt 60 ]]; then
    COLOR="\033[33m"  # Yellow
  else
    COLOR="\033[32m"  # Green
  fi
  CTX_DISPLAY="${COLOR}${CTX_K}k${RESET}"
else
  CTX_DISPLAY="${DIM}new${RESET}"
fi

# Output (printf for cross-platform unicode support)
printf '%s | Ctx: %b | ⌀ %s\n' "$MODEL" "$CTX_DISPLAY" "${BRANCH:-no-git}"
