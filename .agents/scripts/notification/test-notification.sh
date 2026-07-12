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
if [ "${1:-}" = "display-message" ]; then printf '%s\n' "${FAKE_TMUX_SESSION:-test-session}"; fi
FAKE
chmod +x "$fake_bin/terminal-notifier" "$fake_bin/afplay" "$fake_bin/date" "$fake_bin/tmux"

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
  local adapter="$1" json="$2" profile="${3:-standard}" notifier_fail="${4:-0}"
  [ -x "$repo_root/$adapter" ] || fail "missing executable adapter: $adapter"
  : > "$notifier_log"; : > "$sound_log"; : > "$stdout_log"; : > "$stderr_log"
  printf '%s' "$json" | env -u TMUX -u TMUX_PANE \
    PATH="$fake_bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin" \
    HOME="$repo_root" NOTIFIER_LOG="$notifier_log" SOUND_LOG="$sound_log" \
    ECC_HOOK_PROFILE="$profile" FAKE_NOTIFIER_FAIL="$notifier_fail" "$repo_root/$adapter" \
    >"$stdout_log" 2>"$stderr_log"
  wait_for_sound
}
run_adapter_in_tmux() {
  local adapter="$1" json="$2"
  : > "$notifier_log"; : > "$sound_log"; : > "$stdout_log"; : > "$stderr_log"
  printf '%s' "$json" | env \
    PATH="$fake_bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin" \
    HOME="$repo_root" NOTIFIER_LOG="$notifier_log" SOUND_LOG="$sound_log" \
    ECC_HOOK_PROFILE=standard FAKE_TMUX_SESSION="team's" \
    TMUX="/tmp/tmux'sock,123,0" TMUX_PANE="%7'pane" \
    "$repo_root/$adapter" >"$stdout_log" 2>"$stderr_log"
  wait_for_sound
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

test_codex() {
  run_adapter ".codex/scripts/notify-permission.sh" \
    '{"tool_name":"Bash","tool_input":{"description":"Allow package installation now"},"cwd":"/tmp/codex-project","session_id":"session-x"}'
  assert_notification "🔐 permission - 9:41 AM" '\[codex-project] Allow package installation now' "codex-session-x"
  assert_contains "/System/Library/Sounds/Pop.aiff" "$sound_log" "Codex permission sound"
  pass "Codex permission description"

  run_adapter ".codex/scripts/notify-permission.sh" \
    '{"tool_name":"apply_patch","cwd":"/tmp/codex-project","session_id":"session-x"}'
  assert_equal '\[codex-project] apply_patch' "$(argument_value -message)" "permission tool fallback"
  run_adapter ".codex/scripts/notify-permission.sh" \
    '{"tool_name":"Bash","tool_input":{"description":""},"cwd":"/tmp/codex-project","session_id":"session-x"}'
  assert_equal '\[codex-project] Bash' "$(argument_value -message)" "empty description tool fallback"
  run_adapter ".codex/scripts/notify-permission.sh" '{}'
  assert_notification "🔐 permission - 9:41 AM" '\[codex] Waiting for approval' "codex-default"
  pass "Codex permission fallbacks"

  run_adapter ".codex/scripts/notify-complete.sh" \
    '{"last_assistant_message":"completed the requested Codex task","cwd":"/tmp/codex-project","session_id":"session-x"}'
  assert_notification "🤖 finished - 9:41 AM" '\[codex-project] completed the requested Codex task' "codex-session-x"
  assert_contains "/System/Library/Sounds/Purr.aiff" "$sound_log" "Codex complete sound"
  pass "Codex complete payload"

  run_adapter ".codex/scripts/notify-complete.sh" '{}'
  assert_notification "🤖 finished - 9:41 AM" '\[codex] Task completed' "codex-default"
  pass "Codex complete fallbacks"
}

selected_complete_adapter() {
  if [ "$product" = "codex" ]; then echo ".codex/scripts/notify-complete.sh"; else echo ".claude/scripts/notify-complete.sh"; fi
}
test_shared() {
  local adapter
  adapter=$(selected_complete_adapter)
  run_adapter "$adapter" '{"last_assistant_message":"hidden content","cwd":"/tmp/background","session_id":"background-session"}' minimal
  assert_equal '\[background] Background session' "$(argument_value -message)" "minimal body"
  assert_empty "$sound_log" "minimal sound"
  pass "minimal profile is fixed and silent"

  run_adapter "$adapter" '{}'
  assert_equal "/usr/bin/osascript -e 'tell application \"WezTerm\" to activate'" "$(argument_value -execute)" "non-tmux click action"
  pass "non-tmux click activates WezTerm"

  run_adapter_in_tmux "$adapter" '{}'
  local execute_cmd
  execute_cmd=$(argument_value -execute)
  assert_string_starts_with "'$repo_root/.agents/scripts/notification/focus-tmux-pane.sh'" "$execute_cmd" "quoted tmux focus helper"
  assert_string_contains "$repo_root/.agents/scripts/notification/focus-tmux-pane.sh" "$execute_cmd" "tmux focus helper"
  assert_string_contains "team'\\''s" "$execute_cmd" "escaped tmux session"
  assert_string_contains "%7'\\''pane" "$execute_cmd" "escaped tmux pane"
  assert_string_contains "/tmp/tmux'\\''sock" "$execute_cmd" "escaped tmux socket"
  pass "tmux click action escapes single quotes"

  run_adapter "$adapter" '{}' standard 1
  assert_empty "$stdout_log" "failed notifier stdout"
  assert_contains "terminal-notifier failed" "$stderr_log" "failed notifier guidance"
  pass "failed terminal-notifier is diagnosed and non-fatal"

  local missing_bin="$tmp_dir/missing-bin" status
  mkdir -p "$missing_bin"
  ln -sf "$(command -v jq)" "$missing_bin/jq"
  ln -sf "$fake_bin/date" "$missing_bin/date"
  : > "$stdout_log"; : > "$stderr_log"
  set +e
  printf '%s' '{}' | env -u TMUX -u TMUX_PANE \
    PATH="$missing_bin:/usr/bin:/bin" HOME="$repo_root" ECC_HOOK_PROFILE=standard \
    "$repo_root/$adapter" >"$stdout_log" 2>"$stderr_log"
  status=$?
  set -e
  assert_equal 0 "$status" "missing notifier status"
  assert_empty "$stdout_log" "missing notifier stdout"
  assert_contains "brew install terminal-notifier" "$stderr_log" "missing notifier guidance"
  pass "missing terminal-notifier is non-fatal"
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
  if [ "$product" != "claude" ]; then files+=(.codex/scripts/notify-permission.sh .codex/scripts/notify-complete.sh); fi
  local file
  for file in "${files[@]}"; do
    [ -f "$repo_root/$file" ] || fail "missing shell file: $file"
    bash -n "$repo_root/$file" || fail "bash syntax: $file"
    assert_equal 755 "$(stat -f '%Lp' "$repo_root/$file")" "executable mode: $file"
  done
  pass "shell syntax"
}

test_config() {
  UV_CACHE_DIR="$tmp_dir/uv-cache" uv run python - "$repo_root/.codex/config.toml" <<'PY'
import sys
import tomllib
with open(sys.argv[1], "rb") as f:
    config = tomllib.load(f)
assert config["notify"] == [
    "/Users/tknw/dotfiles/.codex/computer-use/Codex Computer Use.app/Contents/SharedSupport/SkyComputerUseClient.app/Contents/MacOS/SkyComputerUseClient",
    "turn-ended",
]
permission = config["hooks"]["PermissionRequest"]
assert len(permission) == 1
assert permission[0]["matcher"] == ".*"
assert permission[0]["hooks"][0]["type"] == "command"
assert permission[0]["hooks"][0]["command"] == "~/.codex/scripts/notify-permission.sh"
stop = config["hooks"]["Stop"]
assert len(stop) == 1
assert "matcher" not in stop[0]
assert stop[0]["hooks"][0]["type"] == "command"
assert stop[0]["hooks"][0]["command"] == "~/.codex/scripts/notify-complete.sh"
PY
  pass "Codex TOML hooks and Computer Use notify"
}

if [ "$product" != "codex" ]; then test_claude; fi
if [ "$product" != "claude" ]; then test_codex; fi
test_shared
test_syntax
if [ "$product" != "claude" ]; then test_config; fi
echo "1..$pass_count"
