#!/bin/bash
# agent-deck core functions. Sourced by the agent-deck CLI and by tests.sh.
# State layout: one JSON file per tmux pane under "$(deck_panes_dir)".
# AGENT_DECK_STATE_DIR overrides the state root (used by tests).

deck_state_root() {
  echo "${AGENT_DECK_STATE_DIR:-$HOME/.local/state/agent-deck}"
}

deck_panes_dir() {
  echo "$(deck_state_root)/panes"
}

# deck_state_file <pane_id>  (pane_id looks like "%7"; '%' is stripped for the filename)
deck_state_file() {
  echo "$(deck_panes_dir)/${1#%}.json"
}

# deck_format_elapsed <now_epoch> <updated_epoch>
deck_format_elapsed() {
  local diff=$(($1 - $2))
  if [ "$diff" -lt 60 ]; then
    echo "${diff}s"
  elif [ "$diff" -lt 3600 ]; then
    echo "$((diff / 60))m"
  else
    echo "$((diff / 3600))h"
  fi
}

deck_state_icon() {
  case "$1" in
    working) echo "●" ;;
    waiting) echo "◐" ;;
    idle) echo "✔" ;;
    *) echo "?" ;;
  esac
}

# Sort weight: waiting agents surface first, oldest first within a rank.
deck_state_rank() {
  case "$1" in
    waiting) echo 0 ;;
    working) echo 1 ;;
    idle) echo 2 ;;
    *) echo 3 ;;
  esac
}

# deck_write_state <pane_id> <session_name> <tool> <state> <cwd> <branch> [title] [updated_at]
# updated_at defaults to now; pass it explicitly to preserve a prior value
# when only metadata (session/cwd/branch/title) drifted, not the state itself.
deck_write_state() {
  local dir file tmp
  local title="${7:-}" updated_at="${8:-$(date +%s)}"
  dir=$(deck_panes_dir)
  file=$(deck_state_file "$1")
  tmp="${file}.tmp.$$"
  mkdir -p "$dir"
  chmod 700 "$(deck_state_root)"
  jq -n \
    --arg pane_id "$1" \
    --arg session_name "$2" \
    --arg tool "$3" \
    --arg state "$4" \
    --arg cwd "$5" \
    --arg branch "$6" \
    --arg title "$title" \
    --arg updated_at "$updated_at" \
    '{pane_id: $pane_id, session_name: $session_name, tool: $tool,
      state: $state, cwd: $cwd, branch: $branch, title: $title,
      updated_at: ($updated_at | tonumber)}' \
    > "$tmp"
  mv "$tmp" "$file"
}

deck_remove_state() {
  rm -f "$(deck_state_file "$1")"
}

# Push a reload to the dashboard's fzf --listen endpoint, if one is running.
# The dashboard writes fzf-port and fzf-key files on startup (Task 4).
deck_ping() {
  local root port key
  root=$(deck_state_root)
  port=$(cat "$root/fzf-port" 2>/dev/null) || return 0
  key=$(cat "$root/fzf-key" 2>/dev/null) || return 0
  local self_dir
  self_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  curl -s -m 1 -X POST "http://127.0.0.1:${port}" \
    -H "x-api-key: ${key}" \
    -d "reload(${self_dir}/agent-deck list)" >/dev/null 2>&1 || true
}

# deck_render_fields <state_json> <now_epoch>
# One agent as 7 tab-separated raw fields (no padding):
#   pane_id, icon, tool, project, branch, age, session
# deck_render_table sizes and pads them into display rows. The session
# field is the AI session title when one was taken from the pane's
# terminal title (OSC), else the tmux session name; it stays last because
# titles are variable-length (and possibly multibyte).
# Parse with the ASCII Unit Separator (0x1f): it is not IFS whitespace
# (empty fields survive read), it cannot appear in stored fields, and
# unlike 0x01 it is not bash 3.2's internal escape sentinel.
deck_render_fields() {
  local json="$1" now="$2"
  local pane_id session_name tool state cwd branch title updated_at
  IFS=$'\x1f' read -r pane_id session_name tool state cwd branch title updated_at < <(
    jq -r '[(.pane_id // ""), (.session_name // ""), (.tool // ""), (.state // ""),
            (.cwd // ""), (.branch // ""), (.title // ""), (.updated_at // 0 | tostring)] | join("\u001f")' \
      <<<"$json" 2>/dev/null
  ) || return 0
  [ -n "$pane_id" ] || return 0
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$pane_id" \
    "$(deck_state_icon "$state")" \
    "$tool" \
    "$(basename "$cwd")" \
    "${branch:--}" \
    "$(deck_format_elapsed "$now" "$updated_at")" \
    "${title:-$session_name}"
}

# deck_render_table
# stdin: deck_render_fields lines. stdout: a column-label header line
# (field 1 "HDR", consumed by fzf --header-lines=1) followed by display
# rows ("<pane_id>\t<display>"). Column widths are computed from the
# longest value per column so long branches/projects never shift other
# rows. Widths never drop below the label widths. awk length() counts
# characters, so CJK display width (2 cells) is still approximate.
deck_render_table() {
  awk -F '\t' '
    { n++; id[n]=$1; icon[n]=$2; tool[n]=$3; proj[n]=$4; br[n]=$5; age[n]=$6; sess[n]=$7
      if (length($3) > w3) w3 = length($3)
      if (length($4) > w4) w4 = length($4)
      if (length($5) > w5) w5 = length($5)
      if (length($6) > w6) w6 = length($6) }
    END {
      if (w3 < 4) w3 = 4; if (w4 < 7) w4 = 7
      if (w5 < 6) w5 = 6; if (w6 < 3) w6 = 3
      printf "HDR\t  %-*s %-*s %-*s %-*s %s\n", w3, "TOOL", w4, "PROJECT", w5, "BRANCH", w6, "AGE", "SESSION"
      for (i = 1; i <= n; i++)
        printf "%s\t%s %-*s %-*s %-*s %-*s %s\n", id[i], icon[i], w3, tool[i], w4, proj[i], w5, br[i], w6, age[i], sess[i]
    }'
}

# deck_list <now_epoch> <live_pane_ids>
# Renders every state file whose pane still exists; deletes the rest.
# live_pane_ids is a newline-separated list (from `tmux list-panes -a`).
# Rows are sorted by rank/updated_at, then deck_render_table pads them
# into aligned columns behind a leading HDR label line.
deck_list() {
  local now="$1" live="$2"
  local f json pane_id state updated rank
  for f in "$(deck_panes_dir)"/*.json; do
    [ -e "$f" ] || continue
    json=$(cat "$f" 2>/dev/null) || continue
    pane_id=$(jq -r '.pane_id // empty' <<<"$json" 2>/dev/null || true)
    if [ -z "$pane_id" ]; then
      continue  # unreadable or mid-write; leave it for the next pass
    fi
    if ! grep -qxF "$pane_id" <<<"$live"; then
      rm -f "$f"
      continue
    fi
    state=$(jq -r '.state // empty' <<<"$json" 2>/dev/null || true)
    updated=$(jq -r '.updated_at // 0' <<<"$json" 2>/dev/null || echo 0)
    rank=$(deck_state_rank "$state")
    printf '%s\t%s\t%s\n' "$rank" "$updated" "$(deck_render_fields "$json" "$now")"
  done | sort -t "$(printf '\t')" -k1,1n -k2,2n | cut -f3- | deck_render_table
}

# deck_classify <tool> <screen_text>
# Classify the tail of a pane's live screen into working / waiting / idle.
# Priority: waiting (strict: known approval UI only) > working (activity
# indicator) > idle fallback. Patterns are grep -E per tool and are locked
# by the files under fixtures/ — update patterns and fixtures together.
deck_classify() {
  local tool="$1" text="$2" waiting_pat working_pat
  case "$tool" in
    claude)
      waiting_pat='❯ [0-9]+\.'
      working_pat='↓ [0-9.,]+[kKmM]? tokens|esc to interrupt' ;;
    codex)
      waiting_pat='Allow command\?|› [0-9]+\.'
      working_pat='[Ee]sc to interrupt' ;;
    opencode)
      waiting_pat='Permission required|Allow  Deny'
      working_pat='working\.\.\.|esc to interrupt' ;;
    cursor)
      waiting_pat='Run this command\?'
      working_pat='  [0-9.,]+[kKmM]? tokens|ctrl\+c to stop' ;;
    *)
      echo idle; return 0 ;;
  esac
  if printf '%s\n' "$text" | grep -qE "$waiting_pat"; then
    echo waiting
  elif printf '%s\n' "$text" | grep -qE "$working_pat"; then
    echo working
  else
    echo idle
  fi
}

# deck_match_tool <comm> <args>
# Map one process (executable name + full command line) to a known agent
# tool. Wrapper runtimes (node/bun/deno) are resolved via the command line.
deck_match_tool() {
  local comm args="$2"
  comm=$(basename -- "$1")
  case "$comm" in
    claude | codex | opencode)
      echo "$comm"; return 0 ;;
    cursor-agent)
      echo cursor; return 0 ;;
    node | bun | deno)
      case "$args" in
        *cursor-agent*) echo cursor; return 0 ;;
        *opencode*) echo opencode; return 0 ;;
        *codex*) echo codex; return 0 ;;
        *claude*) echo claude; return 0 ;;
      esac ;;
  esac
  return 1
}

# deck_screen_tail <captured_screen>
# Last 20 non-blank lines of a raw capture-pane dump. A fresh TUI leaves
# the bottom of a tall pane blank, so a raw tail -20 would return only
# blank rows and read as a failed capture.
deck_screen_tail() {
  printf '%s\n' "$1" | awk 'NF' | tail -20
}

# deck_pane_tool <root_pid>
# Breadth-first walk of the process tree under <root_pid>; echo the first
# known agent tool. Depth-capped so a scan pass stays cheap. Returns 1 if
# the pane hosts no known agent.
deck_pane_tool() {
  local queue="$1" next pid tool depth=0
  while [ -n "$queue" ] && [ "$depth" -lt 6 ]; do
    next=""
    # shellcheck disable=SC2086  # queue is a space-separated pid list
    for pid in $queue; do
      if tool=$(deck_match_tool \
        "$(ps -o comm= -p "$pid" 2>/dev/null || true)" \
        "$(ps -o args= -p "$pid" 2>/dev/null || true)"); then
        echo "$tool"
        return 0
      fi
      # -a includes the caller's own ancestors, which plain pgrep -P silently
      # drops (BSD behavior) — without it a scan run from inside an agent's
      # subtree misses that agent's pane.
      next="$next $(pgrep -a -P "$pid" 2>/dev/null | tr '\n' ' ')"
    done
    queue="$next"
    depth=$((depth + 1))
  done
  return 1
}

# deck_extract_title <tool> <pane_title>
# AI session title from the pane's terminal title, which the tool sets
# via OSC escapes (a real metadata channel — not scraped from rendered
# screen content). claude prefixes a one-character status glyph
# ("✳ name", or a braille spinner char while working) and falls back to
# "Claude Code" when the session has no name yet. cursor sets a plain
# per-session title with no glyph and falls back to "Cursor Agent" when
# the session is untitled.
deck_extract_title() {
  local tool="$1" pane_title="$2" glyph rest
  case "$tool" in
    claude)
      glyph="${pane_title%% *}"
      rest="${pane_title#* }"
      if [ "$rest" != "$pane_title" ] \
        && [ "$(printf '%s' "$glyph" | LC_ALL=en_US.UTF-8 wc -m | tr -d ' ')" = "1" ]; then
        pane_title="$rest"
      fi
      [ "$pane_title" = "Claude Code" ] && pane_title=""
      printf '%s\n' "$pane_title" ;;
    cursor)
      [ "$pane_title" = "Cursor Agent" ] && pane_title=""
      printf '%s\n' "$pane_title" ;;
    *) ;;
  esac
  return 0
}
