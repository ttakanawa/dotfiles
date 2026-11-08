#!/usr/bin/env bash
set -euo pipefail

product="all"
if [ "${1:-}" = "--product" ]; then product="${2:-}"; fi
case "$product" in all|claude|codex) ;; *) echo "usage: $0 [--product claude|codex]" >&2; exit 2 ;; esac

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
fake_bin="$tmp_dir/bin"
notifier_log="$tmp_dir/notifier.log"
sound_log="$tmp_dir/sound.log"
tmux_log="$tmp_dir/tmux.log"
osascript_log="$tmp_dir/osascript.log"
stdout_log="$tmp_dir/stdout.log"
stderr_log="$tmp_dir/stderr.log"
mkdir -p "$fake_bin"

cat > "$fake_bin/terminal-notifier" <<'FAKE'
#!/bin/bash
printf '%s\n' "$@" > "$NOTIFIER_LOG"
[ "${FAKE_NOTIFIER_FAIL:-0}" = "1" ] && exit 1
exit 0
FAKE
cat > "$fake_bin/afplay" <<'FAKE'
#!/bin/bash
printf '%s\n' "$@" > "$SOUND_LOG"
FAKE
cat > "$fake_bin/date" <<'FAKE'
#!/bin/bash
printf '%s\n' '9:41 AM'
FAKE
cat > "$fake_bin/tmux" <<'FAKE'
#!/bin/bash
if [ -n "${TMUX_LOG:-}" ]; then
  printf '<%s>' "$@" >> "$TMUX_LOG"
  printf '\n' >> "$TMUX_LOG"
fi
if [ "${1:-}" = "-S" ]; then shift 2; fi
case "${1:-}" in
  display-message)
    [ "${FAKE_TMUX_MISSING_PANE:-0}" = "1" ] && exit 1
    case "${!#}" in
      '#{session_id}') printf '%s\n' "${FAKE_TMUX_SESSION_ID:-live-session}" ;;
      '#{window_id}') printf '%s\n' "${FAKE_TMUX_WINDOW_ID:-@8}" ;;
      *) printf '%s\n' "${FAKE_TMUX_SESSION:-test-session}" ;;
    esac
    ;;
  list-clients) printf '%s\n' '/dev/ttys001' '/dev/ttys002' ;;
esac
FAKE
cat > "$fake_bin/osascript" <<'FAKE'
#!/bin/bash
printf '%s\n' "$@" >> "$OSASCRIPT_LOG"
FAKE
chmod +x "$fake_bin/terminal-notifier" "$fake_bin/afplay" "$fake_bin/date" "$fake_bin/tmux" "$fake_bin/osascript"

pass_count=0
fail() { echo "not ok - $*" >&2; exit 1; }
pass() { pass_count=$((pass_count + 1)); echo "ok $pass_count - $*"; }
assert_equal() {
  [ "$1" = "$2" ] || fail "$3: expected <$1>, got <$2>"
}
assert_empty() {
  [ ! -s "$1" ] || fail "$2: expected empty output, got <$(cat "$1")>"
}
assert_contains() {
  rg -F -- "$1" "$2" >/dev/null || fail "$3: <$1> not found in $2"
}
assert_string_contains() {
  case "$2" in *"$1"*) ;; *) fail "$3: <$1> not found in <$2>" ;; esac
}
assert_string_starts_with() {
  case "$2" in "$1"*) ;; *) fail "$3: <$2> does not start with <$1>" ;; esac
}
argument_value() {
  awk -v flag="$1" '$0 == flag { getline; print; exit }' "$notifier_log"
}
wait_for_sound() {
  local attempt=0
  while [ ! -s "$sound_log" ] && [ "$attempt" -lt 50 ]; do sleep 0.01; attempt=$((attempt + 1)); done
}
run_adapter() {
  local adapter="$1" json="$2" notifier_fail="${3:-0}"
  [ -x "$repo_root/$adapter" ] || fail "missing executable adapter: $adapter"
  : > "$notifier_log"; : > "$sound_log"; : > "$stdout_log"; : > "$stderr_log"
  printf '%s' "$json" | env -u TMUX -u TMUX_PANE \
    PATH="$fake_bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin" \
    HOME="$repo_root" NOTIFIER_LOG="$notifier_log" SOUND_LOG="$sound_log" \
    FAKE_NOTIFIER_FAIL="$notifier_fail" "$repo_root/$adapter" \
    >"$stdout_log" 2>"$stderr_log"
  wait_for_sound
}
run_shared() {
  local notifier_fail="${1:-0}" socket="${2:-}" pane="${3:-}"
  local test_path="${4:-$fake_bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin}"
  local status=0
  : > "$notifier_log"; : > "$sound_log"; : > "$stdout_log"; : > "$stderr_log"; : > "$tmux_log"
  env PATH="$test_path" HOME="$repo_root" \
    NOTIFIER_LOG="$notifier_log" SOUND_LOG="$sound_log" TMUX_LOG="$tmux_log" \
    FAKE_NOTIFIER_FAIL="$notifier_fail" FAKE_TMUX_SESSION="team's" \
    TMUX="$socket" TMUX_PANE="$pane" \
    /bin/bash -c '
      source "$1"
      notify "Test" "Task completed" "/tmp/test-project" test-session test ""
    ' -- "$repo_root/.agents/scripts/notification/notify.sh" \
    >"$stdout_log" 2>"$stderr_log" || status=$?
  wait_for_sound
  return "$status"
}
run_focus_helper() {
  local captured_session="$1" missing_pane="${2:-0}"
  : > "$tmux_log"; : > "$osascript_log"; : > "$stdout_log"; : > "$stderr_log"
  env FAKE_BIN="$fake_bin" TMUX_LOG="$tmux_log" OSASCRIPT_LOG="$osascript_log" \
    FAKE_TMUX_SESSION_ID='$12' FAKE_TMUX_WINDOW_ID='@18' FAKE_TMUX_MISSING_PANE="$missing_pane" \
    bash -c '
      tmux() { "$FAKE_BIN/tmux" "$@"; }
      osascript() { "$FAKE_BIN/osascript" "$@"; }
      source "$1" "$2" "$3" "$4"
    ' -- "$repo_root/.agents/scripts/notification/focus-tmux-pane.sh" \
    "$captured_session" '%27' '/tmp/notification-test.sock' >"$stdout_log" 2>"$stderr_log"
}
assert_notification() {
  assert_equal "$1" "$(argument_value -title)" "notification title"
  assert_equal "$2" "$(argument_value -message)" "notification message"
  assert_equal "$3" "$(argument_value -group)" "notification group"
  assert_empty "$stdout_log" "hook stdout"
}

test_claude() {
  run_adapter ".claude/scripts/notify-waiting.sh" \
    '{"title":"Custom title","notification_type":"permission_prompt","message":"one two three\nfour five six seven eight nine","cwd":"/tmp/my-project","session_id":"session-c"}'
  assert_notification "Custom title - 9:41 AM" '\[my-project] one two three four five six seven' "claude-session-c"
  assert_contains "/System/Library/Sounds/Pop.aiff" "$sound_log" "Claude waiting sound"
  pass "Claude waiting payload"

  run_adapter ".claude/scripts/notify-complete.sh" \
    '{"last_assistant_message":"completed the requested task","cwd":"/tmp/my-project","session_id":"session-c"}'
  assert_notification "🤖 finished - 9:41 AM" '\[my-project] completed the requested task' "claude-session-c"
  assert_contains "/System/Library/Sounds/Purr.aiff" "$sound_log" "Claude complete sound"
  pass "Claude complete payload"

  run_adapter ".claude/scripts/notify-waiting.sh" '{}'
  assert_notification "🤖 waiting - 9:41 AM" '\[claude] Waiting for input' "claude-default"
  pass "Claude missing field fallbacks"
}

test_shared() {
  run_shared
  assert_equal "/usr/bin/osascript -e 'tell application \"WezTerm\" to activate'" "$(argument_value -execute)" "non-tmux click action"
  pass "non-tmux click activates WezTerm"

  run_shared 0 "/tmp/tmux'sock,123,0" "%7'pane"
  local execute_cmd
  execute_cmd=$(argument_value -execute)
  assert_string_starts_with "'$repo_root/.agents/scripts/notification/focus-tmux-pane.sh'" "$execute_cmd" "quoted tmux focus helper"
  assert_string_contains "$repo_root/.agents/scripts/notification/focus-tmux-pane.sh" "$execute_cmd" "tmux focus helper"
  assert_string_contains "team'\\''s" "$execute_cmd" "escaped tmux session"
  assert_string_contains "%7'\\''pane" "$execute_cmd" "escaped tmux pane"
  assert_string_contains "/tmp/tmux'\\''sock" "$execute_cmd" "escaped tmux socket"
  assert_contains "<-S></tmp/tmux'sock><display-message><-p><-t><%7'pane><#{session_name}>" "$tmux_log" "originating pane session lookup"
  pass "tmux click action escapes single quotes"

  run_shared 1
  assert_empty "$stdout_log" "failed notifier stdout"
  assert_contains "terminal-notifier failed" "$stderr_log" "failed notifier guidance"
  pass "failed terminal-notifier is diagnosed and non-fatal"

  local missing_bin="$tmp_dir/missing-bin" status
  mkdir -p "$missing_bin"
  ln -sf "$(command -v jq)" "$missing_bin/jq"
  ln -sf "$fake_bin/date" "$missing_bin/date"
  : > "$stdout_log"; : > "$stderr_log"
  set +e
  run_shared 0 "" "" "$missing_bin:/usr/bin:/bin"
  status=$?
  set -e
  assert_equal 0 "$status" "missing notifier status"
  assert_empty "$stdout_log" "missing notifier stdout"
  assert_contains "brew install terminal-notifier" "$stderr_log" "missing notifier guidance"
  pass "missing terminal-notifier is non-fatal"
}

test_focus_tmux_pane() {
  run_focus_helper "old-session-name"
  assert_contains '<-S></tmp/notification-test.sock><switch-client><-t><$12><-c></dev/ttys001>' "$tmux_log" "first client switches to the live pane session"
  assert_contains '<-S></tmp/notification-test.sock><switch-client><-t><$12><-c></dev/ttys002>' "$tmux_log" "existing all-client focus policy"
  assert_contains '<-S></tmp/notification-test.sock><select-window><-t><$12:@18>' "$tmux_log" "moved pane window is selected"
  assert_contains '<-S></tmp/notification-test.sock><select-pane><-t><%27>' "$tmux_log" "original pane is selected"
  assert_contains 'tell application "WezTerm" to activate' "$osascript_log" "click activates WezTerm"
  assert_empty "$stdout_log" "focus helper stdout"
  pass "notification click follows a moved pane or renamed session"

  run_focus_helper ""
  assert_contains '<switch-client><-t><$12>' "$tmux_log" "live pane resolves without a captured session name"
  pass "notification click can recover an unavailable original session name"

  run_focus_helper "old-session-name" 1
  if rg -q '<(switch-client|select-window|select-pane)>' "$tmux_log"; then
    fail "vanished pane must not switch clients to a stale session"
  fi
  assert_contains 'tell application "WezTerm" to activate' "$osascript_log" "vanished pane still activates WezTerm"
  pass "notification click ignores a pane that no longer exists"
}

test_syntax() {
  local files=(
    .agents/scripts/notification/notify.sh
    .agents/scripts/notification/focus-tmux-pane.sh
    .agents/scripts/notification/test-notification.sh
    .claude/scripts/lib/notify.sh
    .claude/scripts/focus-tmux-pane.sh
    .claude/scripts/notify-waiting.sh
    .claude/scripts/notify-complete.sh
  )
  if [ "$product" != "claude" ]; then files+=(.codex/scripts/notify-permission.sh .codex/scripts/notify-complete.sh .codex/scripts/notify-question.sh .codex/scripts/lib/notify.sh); fi
  local file
  for file in "${files[@]}"; do
    [ -f "$repo_root/$file" ] || fail "missing shell file: $file"
    bash -n "$repo_root/$file" || fail "bash syntax: $file"
    assert_equal 755 "$(stat -f '%Lp' "$repo_root/$file")" "executable mode: $file"
  done
  pass "shell syntax"
}

test_config() {
  awk '
    /^\[/ { section = $0 }
    section == "" && /^[[:space:]]*notify[[:space:]]*=/ { bad = 1 }
    /^\[\[hooks\.(Stop|PermissionRequest|PreToolUse)\]\]/ { bad = 1 }
    section == "[tui]" && /^[[:space:]]*notifications[[:space:]]*=[[:space:]]*false[[:space:]]*$/ { disabled = 1 }
    section == "[tui]" && /^[[:space:]]*status_line[[:space:]]*=/ && /"thread-id"/ { thread_id = 1 }
    END { exit bad || !disabled || !thread_id }
  ' "$repo_root/.codex/config.toml" || fail "Codex TUI notification configuration"
  jq -e --arg complete 'bash "$HOME/.codex/scripts/notify-complete.sh"' \
    --arg permission 'bash "$HOME/.codex/scripts/notify-permission.sh"' \
    --arg question 'bash "$HOME/.codex/scripts/notify-question.sh"' '
    .hooks as $hooks |
    all(({Stop:$complete, PermissionRequest:$permission, PreToolUse:$question} | to_entries)[];
      .key as $event | .value as $command |
      [$hooks[$event][] | select(any(.hooks[]; .command == $command))] as $groups |
      ($groups | length) == 1 and
      $groups[0].hooks == [{type:"command", command:$command, timeout:5}] and
      (if $event == "PreToolUse" then
         $groups[0].matcher == "^(request_user_input|request_user_input_async)$"
       else $groups[0] | has("matcher") | not end))
  ' "$repo_root/.codex/hooks.json" >/dev/null || fail "Codex event hook registrations"
  pass "Codex event hooks without duplicate native notifications"
}

if [ "$product" != "codex" ]; then test_claude; fi
test_shared
test_focus_tmux_pane
test_syntax
if [ "$product" != "claude" ]; then test_config; fi
echo "1..$pass_count"
