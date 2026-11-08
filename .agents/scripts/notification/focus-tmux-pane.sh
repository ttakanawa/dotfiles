#!/bin/bash
# Focus a specific tmux pane, invoked by terminal-notifier's click handler.

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

session_name="${1:-}"
pane_id="${2:-}"
tmux_socket="${3:-}"

if [ -n "$pane_id" ] && [ -n "$tmux_socket" ]; then
  # Panes can move and sessions can be renamed after the notification is sent.
  live_session=$(tmux -S "$tmux_socket" display-message -p -t "$pane_id" '#{session_id}' 2>/dev/null) || live_session=
  window_id=$(tmux -S "$tmux_socket" display-message -p -t "$pane_id" '#{window_id}' 2>/dev/null) || window_id=
  [ -n "$live_session" ] && session_name="$live_session"

  if [ -n "$session_name" ] && [ -n "$window_id" ]; then
    tmux -S "$tmux_socket" list-clients -F '#{client_tty}' 2>/dev/null | while read -r client_tty; do
      [ -z "$client_tty" ] && continue
      tmux -S "$tmux_socket" switch-client -t "$session_name" -c "$client_tty" 2>/dev/null
      tmux -S "$tmux_socket" select-window -t "$session_name:$window_id" 2>/dev/null
      tmux -S "$tmux_socket" select-pane -t "$pane_id" 2>/dev/null
    done
  fi
fi

osascript -e 'tell application "WezTerm" to activate' 2>/dev/null
exit 0
