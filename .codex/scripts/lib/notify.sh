#!/bin/bash
# Codex-specific pane resolution, duplicate suppression, and notification delivery.

resolve_terminal() {
  local inherited="${TMUX:-}" tty socket pane program pane_tty height rows footer entry
  local seen=() matches=() tty_matches=() sockets=() command=() choices=()
  local format=$'#{socket_path}\t#{pane_id}\t#{pane_current_command}\t#{pane_tty}\t#{pane_height}'
  local session="$1" pattern= duplicate
  # A shared daemon can inherit TMUX variables from an older CLI client.
  unset TMUX TMUX_PANE
  tty=$(ps -o tty= -p "$$" 2>/dev/null) || tty=
  tty=${tty//[[:space:]]/}
  case "$tty" in '?'|'??'|'-') tty= ;; esac
  [ -z "$tty" ] || [ -n "$inherited" ] || return 0

  if [ -n "$inherited" ]; then
    socket=${inherited%,*}
    sockets+=("${socket%,*}")
  fi
  sockets+=("") # Also query the default server, without stale TMUX variables.
  if [[ "$session" =~ ^[[:xdigit:]]{8}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{12}$ ]]; then
    pattern="(^|[^[:alnum:]_-])${session}([^[:alnum:]_-]|$)"
  fi
  # Budget between local queries; hooks.json also limits the whole hook to 5s.
  SECONDS=0
  for socket in "${sockets[@]}"; do
    [ "$SECONDS" -lt 2 ] || return 1
    command=(tmux)
    [ -z "$socket" ] || command+=(-S "$socket")
    rows=$("${command[@]}" list-panes -a -F "$format" 2>/dev/null) || continue
    while IFS=$'\t' read -r socket pane program pane_tty height; do
      [ "$SECONDS" -lt 2 ] || return 1
      case "$program" in codex|CodexCLI) ;; *) continue ;; esac
      [[ "$height" =~ ^[0-9]+$ ]] || continue
      duplicate=
      for entry in "${seen[@]}"; do
        [ "$entry" != "$socket"$'\t'"$pane" ] || duplicate=1
      done
      [ -z "$duplicate" ] || continue
      seen+=("$socket"$'\t'"$pane")
      if [ -n "$tty" ] && [ "${pane_tty##*/}" = "$tty" ]; then
        tty_matches+=("$socket"$'\t'"$pane")
      fi
      if [ -n "$pattern" ]; then
        footer=$(tmux -S "$socket" capture-pane -p -t "$pane" -S "$((height > 3 ? height - 3 : 0))" 2>/dev/null) || continue
        [[ "$footer" =~ $pattern ]] && matches+=("$socket"$'\t'"$pane")
      fi
    done <<< "$rows"
  done
  [ "$SECONDS" -lt 2 ] || return 1
  choices=("${matches[@]}")
  [ "${#tty_matches[@]}" -eq 0 ] || choices=("${tty_matches[@]}")
  [ "${#choices[@]}" -eq 1 ] || return 1
  IFS=$'\t' read -r socket pane <<< "${choices[0]}"
  export TMUX="$socket,0,0" TMUX_PANE="$pane"
}

first_delivery() {
  local input="$1" key directory status=0
  # macOS lockf releases the lock when the cache update process exits.
  # Only event hashes and timestamps are stored, never notification text.
  key=$(printf '%s' "$input" | jq -Sc . | shasum -a 256) || return 0
  key=${key%% *}
  [[ "$key" =~ ^[[:xdigit:]]{64}$ ]] || return 0
  directory="${TMPDIR:-/tmp}/codex-notifications-$UID"
  (umask 077; mkdir -p "$directory") || return 0
  (
    umask 077
    lockf -k -t 1 "$directory/lock" /bin/bash -c '
      updated=$(cat "$1/recent.json" 2>/dev/null | jq -Rsc --arg key "$2" "
        now as \$now |
        (try fromjson catch {}) |
        (if type == \"object\" then . else {} end) |
        with_entries(select(.value | type == \"number\") |
                     select(\$now - .value >= 0 and \$now - .value < 2)) |
        if has(\$key) then empty else . + {(\$key): \$now} end
      ") || exit 0
      [ -n "$updated" ] || exit 1
      printf "%s\n" "$updated" > "$1/recent.json" || exit 0
    ' -- "$directory" "$key" >/dev/null
  ) || status=$?
  [ "$status" -ne 1 ] # Cache failures must not suppress notifications.
}

notify_codex() {
  local kind="$1" title="$2" sound="$3" summary_filter="$4"
  local input field fields=() filter
  trap 'printf "{}\n"' EXIT
  trap 'exit 0' HUP INT TERM
  input=$(cat)
  filter='
    select(type == "object") |
    select((.agent_id // "") == "") |
    select((.tool_input // {}) | type == "object") |
    . as $event |
    ('"$summary_filter"') as $summary |
    [$summary, ($event.cwd // ""), ($event.session_id // "default")] |
    select(all(.[]; type == "string")) |
    .[0] |= (gsub("\u0000"; "") | gsub("\n"; " ") | .[0:200]) |
    .[] | ., "\u0000"
  '
  while IFS= read -r -d '' field; do fields+=("$field"); done < <(
    printf '%s' "$input" | jq -j "$filter" 2>/dev/null
  )
  [ "${#fields[@]}" -eq 3 ] || return 0
  if ! resolve_terminal "${fields[2]}"; then
    echo 'Codex notification skipped: no unique CLI pane; keep thread-id visible in the status line.' >&2
    return 0
  fi
  first_delivery "$input" || return 0
  source "$HOME/.agents/scripts/notification/notify.sh" || return 0
  notify "$title" "${fields[0]}" "${fields[1]}" "${fields[2]}:$kind" \
    codex "/System/Library/Sounds/$sound.aiff" full >/dev/null
  return 0
}
