#!/usr/bin/env bash
# Claude Code status line script
# Fields: commit hash | model | token cost | session time | files changed | MCPs

SESSIONS_FILE="${HOME}/.claude/session-starts.json"
SETTINGS_FILE="${HOME}/.claude/settings.json"

# ANSI colors
C_RESET='\033[0m'
C_DIM='\033[2m'
C_BLUE='\033[34m'
C_CYAN='\033[36m'
C_YELLOW='\033[33m'
C_GREEN='\033[32m'
C_RED='\033[31m'

input=$(cat)
now=$(date +%s)

# =============================================================
# 1. Last commit hash (7-char short SHA) — dim
# =============================================================
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // ""')
commit_hash=""
files_changed=0
if [ -n "$cwd" ]; then
  commit_hash=$(git -C "$cwd" --no-optional-locks \
    log -1 --pretty=format:%h 2>/dev/null)
  # Count files with uncommitted changes (staged + unstaged)
  files_changed=$(git -C "$cwd" --no-optional-locks \
    diff --name-only HEAD 2>/dev/null | wc -l | tr -d ' ')
fi

# =============================================================
# 2. Model name — yellow
# =============================================================
model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')

# =============================================================
# 3. Token cost of last command — green if cheap, red if expensive
# Threshold: >= $0.10 per call is "expensive" (red)
# Pricing: input $3/M, output $15/M, cache_write $3.75/M, cache_read $0.30/M
# =============================================================
current=$(echo "$input" | jq -r '.context_window.current_usage // empty')
call_cost_raw=0
if [ -n "$current" ]; then
  in_tok=$(echo "$current"  | jq -r '.input_tokens // 0')
  out_tok=$(echo "$current" | jq -r '.output_tokens // 0')
  c_read=$(echo "$current"  | jq -r '.cache_read_input_tokens // 0')
  c_write=$(echo "$current" | jq -r '.cache_creation_input_tokens // 0')
  call_cost_raw=$(awk "BEGIN {
    printf \"%.6f\", ($in_tok * 3 + $out_tok * 15 + $c_write * 3.75 + $c_read * 0.30) / 1000000
  }")
fi
cost_fmt=$(awk "BEGIN {
  c = $call_cost_raw
  if (c == 0)      printf \"--\"
  else if (c < 0.01) printf \"\$%.4f\", c
  else               printf \"\$%.3f\", c
}")
# Green < $0.10, red >= $0.10
COST_C=$(awk -v c="$call_cost_raw" -v g="$C_GREEN" -v r="$C_RED" \
  'BEGIN { if (c >= 0.10) print r; else print g }')

# =============================================================
# 4. Session elapsed time (HH:MM) — cyan
# Tracks session start by writing a timestamp keyed on session_id.
# Schema: { "<session_id>": <unix_timestamp> }
# =============================================================
session_id=$(echo "$input" | jq -r '.session_id // ""')

if [ ! -f "$SESSIONS_FILE" ]; then
  echo '{}' > "$SESSIONS_FILE"
fi

if [ -n "$session_id" ]; then
  session_start=$(jq -r --arg sid "$session_id" '.[$sid] // empty' \
    "$SESSIONS_FILE" 2>/dev/null)
  if [ -z "$session_start" ]; then
    # First time we see this session — record start time
    jq --arg sid "$session_id" --argjson ts "$now" \
      '.[$sid] = $ts' "$SESSIONS_FILE" > "${SESSIONS_FILE}.tmp" 2>/dev/null \
      && mv "${SESSIONS_FILE}.tmp" "$SESSIONS_FILE"
    session_start=$now
  fi
  elapsed=$(( now - session_start ))
  elapsed_h=$(( elapsed / 3600 ))
  elapsed_m=$(( (elapsed % 3600) / 60 ))
  elapsed_fmt=$(printf "%02d:%02d" "$elapsed_h" "$elapsed_m")
else
  elapsed_fmt="--:--"
fi

# Prune sessions older than 24 hours to keep the file small
jq --argjson cutoff "$(( now - 86400 ))" \
  'with_entries(select(.value > $cutoff))' \
  "$SESSIONS_FILE" > "${SESSIONS_FILE}.tmp" 2>/dev/null \
  && mv "${SESSIONS_FILE}.tmp" "$SESSIONS_FILE"

# =============================================================
# 5. Files changed in git — green if 0, red if > 0
# =============================================================
if [ "$files_changed" -gt 0 ] 2>/dev/null; then
  FILES_C="$C_RED"
  files_fmt="${files_changed} changed"
else
  FILES_C="$C_GREEN"
  files_fmt="0 changed"
fi

# =============================================================
# 6. Connected MCPs — blue
# Reads the mcpServers keys from settings.json as the configured set.
# The status line JSON does not expose runtime MCP connections,
# so this reflects what is configured in ~/.claude/settings.json.
# =============================================================
mcp_str=""
if [ -f "$SETTINGS_FILE" ]; then
  mcp_names=$(jq -r '
    (.mcpServers // {}) | keys[] ' \
    "$SETTINGS_FILE" 2>/dev/null)
  if [ -n "$mcp_names" ]; then
    # Join names with commas, cap at 3 then append count if more
    mcp_count=$(echo "$mcp_names" | wc -l | tr -d ' ')
    if [ "$mcp_count" -le 3 ]; then
      mcp_str=$(echo "$mcp_names" | tr '\n' ',' | sed 's/,$//')
    else
      first3=$(echo "$mcp_names" | head -3 | tr '\n' ',' | sed 's/,$//')
      mcp_str="${first3} +$(( mcp_count - 3 ))"
    fi
  else
    mcp_str="none"
  fi
else
  mcp_str="none"
fi

# =============================================================
# Assemble — 6 fields separated by dim pipes
# =============================================================
sep="$(printf " ${C_DIM}|${C_RESET} ")"
parts=()

# 1. Commit hash
if [ -n "$commit_hash" ]; then
  parts+=("$(printf "${C_DIM}%s${C_RESET}" "$commit_hash")")
else
  parts+=("$(printf "${C_DIM}no git${C_RESET}")")
fi

# 2. Model
parts+=("$(printf "${C_YELLOW}%s${C_RESET}" "$model")")

# 3. Token cost
parts+=("$(printf "${COST_C}%s${C_RESET}" "$cost_fmt")")

# 4. Session elapsed time
parts+=("$(printf "${C_CYAN}%s${C_RESET}" "$elapsed_fmt")")

# 5. Files changed
parts+=("$(printf "${FILES_C}%s${C_RESET}" "$files_fmt")")

# 6. MCPs
parts+=("$(printf "${C_BLUE}mcp:%s${C_RESET}" "$mcp_str")")

result=""
for part in "${parts[@]}"; do
  if [ -z "$result" ]; then
    result="$part"
  else
    result="${result}${sep}${part}"
  fi
done

printf '%s' "$result"
