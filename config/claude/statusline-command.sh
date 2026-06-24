#!/usr/bin/env bash
# Claude Code statusLine — robbyrussell-inspired + model + context % + 5h rate limit
# Receives JSON on stdin from Claude Code

input=$(cat)

cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // ""')
dir=$(basename "$cwd")

model_name=$(echo "$input" | jq -r '.model.display_name // .model.id // ""')
model_id=$(echo "$input" | jq -r '.model.id // ""')
transcript=$(echo "$input" | jq -r '.transcript_path // ""')

# Context window: 1M if model id contains "1m", else 200k
if echo "$model_id" | grep -qi '1m'; then
  ctx_limit=1000000
  ctx_label="1M"
else
  ctx_limit=200000
  ctx_label="200k"
fi

# Compute context tokens from latest assistant usage in transcript
ctx_tokens=0
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  ctx_tokens=$(tac "$transcript" 2>/dev/null | jq -r '
    select(.message.usage != null) |
    .message.usage |
    ((.input_tokens // 0) + (.cache_read_input_tokens // 0) + (.cache_creation_input_tokens // 0))
  ' 2>/dev/null | head -n 1)
  [ -z "$ctx_tokens" ] && ctx_tokens=0
fi

ctx_pct=0
if [ "$ctx_tokens" -gt 0 ] && [ "$ctx_limit" -gt 0 ]; then
  ctx_pct=$(( ctx_tokens * 100 / ctx_limit ))
fi

# Format token count human-readable
fmt_tokens() {
  local t=$1
  if [ "$t" -ge 1000000 ]; then
    awk -v n="$t" 'BEGIN{printf "%.2fM", n/1000000}'
  elif [ "$t" -ge 1000 ]; then
    awk -v n="$t" 'BEGIN{printf "%.1fk", n/1000}'
  else
    echo "$t"
  fi
}
ctx_human=$(fmt_tokens "$ctx_tokens")

# Git branch (skip optional locks to avoid conflicts)
git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
git_dirty=$(git -C "$cwd" status --porcelain 2>/dev/null | grep -q . && echo "dirty" || echo "clean")

# ANSI colors
GREEN="\033[1;32m"
CYAN="\033[0;36m"
BLUE="\033[1;34m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
MAGENTA="\033[0;35m"
GRAY="\033[0;37m"
RESET="\033[0m"

# Color for context % — green <50, yellow <80, red otherwise
if [ "$ctx_pct" -lt 50 ]; then
  ctx_color="$GREEN"
elif [ "$ctx_pct" -lt 80 ]; then
  ctx_color="$YELLOW"
else
  ctx_color="$RED"
fi

arrow="${GREEN}➜${RESET}"
dir_part="${CYAN}${dir}${RESET}"

if [ -n "$git_branch" ]; then
  if [ "$git_dirty" = "dirty" ]; then
    git_part=" ${BLUE}git:(${RED}${git_branch}${BLUE}) ${YELLOW}✗${RESET}"
  else
    git_part=" ${BLUE}git:(${RED}${git_branch}${BLUE})${RESET}"
  fi
else
  git_part=""
fi

model_part=""
[ -n "$model_name" ] && model_part=" ${MAGENTA}[${model_name}]${RESET}"

ctx_part=""
if [ "$ctx_tokens" -gt 0 ]; then
  ctx_part=" ${GRAY}|${RESET} ${ctx_color}${ctx_human}/${ctx_label} (${ctx_pct}%)${RESET}"
fi

# 5-hour rolling usage window (Claude.ai subscriber rate limit)
# Field: rate_limits.five_hour.used_percentage — absent when not a subscriber
# or before the first API response of the session.
five_h_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_h_part=""
if [ -n "$five_h_pct" ]; then
  five_h_int=$(printf '%.0f' "$five_h_pct")
  if [ "$five_h_int" -lt 50 ]; then
    five_h_color="$GREEN"
  elif [ "$five_h_int" -lt 80 ]; then
    five_h_color="$YELLOW"
  else
    five_h_color="$RED"
  fi
  five_h_part=" ${GRAY}|${RESET} ${five_h_color}5h:${five_h_int}%${RESET}"
fi

printf '%b' "${arrow} ${dir_part}${git_part}${model_part}${ctx_part}${five_h_part}"
