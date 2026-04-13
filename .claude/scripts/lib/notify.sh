#!/bin/bash
# Shared notification sender for Claude Code hooks.
# Usage: notify <title> <summary> <hook_input_json>
# The caller resolves hook-specific fields (title, summary); this module only
# reads fields common to every Claude Code hook payload (cwd, session_id) and
# dispatches to terminal-notifier with a click-to-focus action.

notify() {
  local base_title="$1"
  local raw_summary="$2"
  local hook_input="$3"

  # cwd and session_id are common to every Claude Code hook payload.
  local cwd session_id
  IFS=$'\t' read -r cwd session_id < <(
    echo "$hook_input" | jq -r '[.cwd // "", .session_id // ""] | @tsv'
  )

  local time title
  time=$(date "+%-l:%M %p")
  title="${base_title} - ${time}"

  # Display the basename of the hook payload's cwd so notifications identify
  # which project sent them.
  local dir_name
  dir_name=$(basename "${cwd:-claude}")

  # Normalize newlines, then truncate to the first 7 words on a single line.
  # awk -v is avoided on purpose: it would interpret backslash escapes
  # (\n, \t, \\) inside raw_summary, which often contains literal backslash
  # sequences from assistant messages.
  local normalized summary
  normalized=${raw_summary//$'\n'/ }
  summary=$(printf '%s' "$normalized" \
    | awk '{n=(NF<7?NF:7); for(i=1;i<=n;i++) printf "%s%s", $i, (i<n?" ":"")}')

  # Leading '[' must be escaped so terminal-notifier renders it verbatim.
  local body="\\[${dir_name}] ${summary}"

  # Group per Claude session so notifications from different sessions don't
  # clobber each other; fall back to a constant when session_id is missing.
  local group="claude-${session_id:-default}"

  local focus_script="$HOME/.claude/scripts/focus-tmux-pane.sh"
  local execute_cmd

  # Build click action: focus the originating tmux pane via the external helper.
  # terminal-notifier passes -execute to /bin/sh -c, so any value interpolated
  # into a single-quoted string must have embedded single quotes escaped to
  # prevent command injection (tmux session names are settable by any process
  # that can reach the server).
  if [ -n "$TMUX" ] && [ -n "$TMUX_PANE" ] && [ -x "$focus_script" ]; then
    local tmux_socket session_name
    tmux_socket=$(echo "$TMUX" | cut -d',' -f1)
    session_name=$(tmux display-message -p '#{session_name}' 2>/dev/null)
    local sq_session sq_pane sq_socket
    sq_session=$(printf "%s" "$session_name" | sed "s/'/'\\\\''/g")
    sq_pane=$(printf "%s" "$TMUX_PANE" | sed "s/'/'\\\\''/g")
    sq_socket=$(printf "%s" "$tmux_socket" | sed "s/'/'\\\\''/g")
    execute_cmd="$focus_script '$sq_session' '$sq_pane' '$sq_socket'"
  else
    execute_cmd="/usr/bin/osascript -e 'tell application \"WezTerm\" to activate'"
  fi

  if ! command -v terminal-notifier >/dev/null 2>&1; then
    echo "notify: terminal-notifier not found (brew install terminal-notifier)" >&2
    return 1
  fi

  terminal-notifier \
    -title "$title" \
    -message "$body" \
    -group "$group" \
    -execute "$execute_cmd" \
    >/dev/null 2>&1
}
