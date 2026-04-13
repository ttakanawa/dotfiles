#!/bin/bash
# Focus a specific tmux pane, invoked by terminal-notifier click handler.
# Runs outside the tmux session's shell, so PATH and $TMUX must be re-established.

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

session_name="$1"
pane_id="$2"
tmux_socket="$3"

if [ -n "$session_name" ] && [ -n "$pane_id" ] && [ -n "$tmux_socket" ]; then
  # Iterate over all attached clients on this socket and switch each of them.
  tmux -S "$tmux_socket" list-clients -F '#{client_tty}' 2>/dev/null | while read -r client_tty; do
    [ -z "$client_tty" ] && continue
    tmux -S "$tmux_socket" switch-client -t "$session_name" -c "$client_tty" 2>/dev/null
    tmux -S "$tmux_socket" select-pane -t "$pane_id" 2>/dev/null
  done
fi

osascript -e 'tell application "WezTerm" to activate' 2>/dev/null
exit 0
