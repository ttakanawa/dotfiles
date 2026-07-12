#!/bin/bash
# Shared desktop notification core for Claude Code and Codex hooks.
# Usage: notify <title> <summary> <cwd> <session_id> <group_prefix> <sound>

notify() {
  local base_title="$1"
  local raw_summary="$2"
  local cwd="$3"
  local session_id="$4"
  local group_prefix="$5"
  local sound="$6"

  if [ "${ECC_HOOK_PROFILE:-standard}" = "minimal" ]; then
    raw_summary="Background session"
    sound=""
  fi

  local time title
  time=$(date "+%-l:%M %p")
  title="${base_title} - ${time}"

  local dir_name
  dir_name=$(basename "${cwd:-$group_prefix}")

  local normalized summary
  normalized=${raw_summary//$'\n'/ }
  summary=$(printf '%s' "$normalized" \
    | awk '{n=(NF<7?NF:7); for(i=1;i<=n;i++) printf "%s%s", $i, (i<n?" ":"")}')

  local body="\\[${dir_name}] ${summary}"
  local group="${group_prefix}-${session_id:-default}"
  local notification_dir focus_script execute_cmd
  notification_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
  focus_script="$notification_dir/focus-tmux-pane.sh"

  if [ -n "${TMUX:-}" ] && [ -n "${TMUX_PANE:-}" ] && [ -x "$focus_script" ]; then
    local tmux_socket session_name sq_focus sq_session sq_pane sq_socket
    tmux_socket=$(printf '%s' "$TMUX" | cut -d',' -f1)
    session_name=$(tmux display-message -p '#{session_name}' 2>/dev/null)
    sq_focus=$(printf '%s' "$focus_script" | sed "s/'/'\\\\''/g")
    sq_session=$(printf '%s' "$session_name" | sed "s/'/'\\\\''/g")
    sq_pane=$(printf '%s' "$TMUX_PANE" | sed "s/'/'\\\\''/g")
    sq_socket=$(printf '%s' "$tmux_socket" | sed "s/'/'\\\\''/g")
    execute_cmd="'$sq_focus' '$sq_session' '$sq_pane' '$sq_socket'"
  else
    execute_cmd="/usr/bin/osascript -e 'tell application \"WezTerm\" to activate'"
  fi

  if ! command -v terminal-notifier >/dev/null 2>&1; then
    echo "notify: terminal-notifier not found (brew install terminal-notifier)" >&2
    return 0
  fi

  if ! terminal-notifier \
      -title "$title" \
      -message "$body" \
      -group "$group" \
      -execute "$execute_cmd" \
      >/dev/null 2>&1; then
    echo "notify: terminal-notifier failed" >&2
  fi

  if [ -n "$sound" ] && command -v afplay >/dev/null 2>&1; then
    afplay -v 0.7 "$sound" </dev/null >/dev/null 2>&1 &
  fi

  return 0
}
