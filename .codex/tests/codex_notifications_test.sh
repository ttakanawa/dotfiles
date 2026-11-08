#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
scripts_dir="$repo_root/.codex/scripts"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
fake_bin="$test_dir/bin"
mkdir -p "$fake_bin"
ln -s "$(command -v jq)" "$fake_bin/jq"
session='01a1b92f-c7db-7991-bbc4-9faecd7d5d2c'
other_session='01a1b720-6e55-77c0-a342-af6cf8c6eb30'
pass_count=0
case_count=0

fail() { printf 'not ok - %s\n' "$*" >&2; exit 1; }
pass() { pass_count=$((pass_count + 1)); printf 'ok %s - %s\n' "$pass_count" "$*"; }
assert_equal() {
  [ "$1" = "$2" ] || fail "$3: expected <$1>, got <$2>"
}

cat > "$fake_bin/command" <<'FAKE'
#!/bin/bash
set -euo pipefail
name=${0##*/}
case "$name" in
  ps) jq -r '.tty' "$NOTIFY_FIXTURE" ;;
  date)
    if [ "${1:-}" = '+%s' ]; then printf '%s\n' '1700000000';
    else printf '%s\n' '9:41 AM'; fi
    ;;
  terminal-notifier|afplay)
    if [ "$name" = 'terminal-notifier' ]; then log=$NOTIFIER_LOG; else log=$SOUND_LOG; fi
    printf '%s\0' "$@" | jq -Rsc 'split("\u0000")[:-1]' >> "$log"
    ;;
  tmux)
    argv=$(printf '%s\0' "$@" | jq -Rsc 'split("\u0000")[:-1]')
    jq -cn --argjson argv "$argv" --arg tmux "${TMUX-}" --arg pane "${TMUX_PANE-}" \
      '{argv:$argv, TMUX:$tmux, TMUX_PANE:$pane}' >> "$TMUX_LOG"
    socket=''
    if [ "${1:-}" = '-S' ]; then socket=$2; shift 2; fi
    action=${1:-}
    shift || :
    case "$action" in
      list-panes)
        [ -n "$socket" ] || socket=$(jq -r '.default_socket' "$NOTIFY_FIXTURE")
        jq -r --arg socket "$socket" \
          '.panes[] | select(.socket == $socket) | [.socket,.id,.program,.tty,.height] | @tsv' \
          "$NOTIFY_FIXTURE"
        ;;
      capture-pane)
        pane=''
        while [ "$#" -gt 0 ]; do
          if [ "$1" = '-t' ]; then pane=$2; shift 2; else shift; fi
        done
        if jq -e --arg pane "$pane" '(.capture_fail // []) | index($pane)' "$NOTIFY_FIXTURE" >/dev/null; then exit 1; fi
        delay=$(jq -r --arg pane "$pane" '.capture_delay[$pane] // 0' "$NOTIFY_FIXTURE")
        [ "$delay" = 0 ] || sleep "$delay"
        jq -r --arg socket "$socket" --arg pane "$pane" \
          '.panes[] | select(.socket == $socket and .id == $pane) | .footer' "$NOTIFY_FIXTURE"
        ;;
      display-message) jq -r '.session_name' "$NOTIFY_FIXTURE" ;;
      *) exit 2 ;;
    esac
    ;;
  *) exit 2 ;;
esac
FAKE
chmod +x "$fake_bin/command"
for command in ps tmux terminal-notifier afplay date; do
  ln -s command "$fake_bin/$command"
done

setup_case() {
  case_count=$((case_count + 1))
  case_dir="$test_dir/case-$case_count"
  fake_home="$case_dir/home"
  fake_tmp="$case_dir/tmp"
  fixture="$case_dir/fixture.json"
  notifier_log="$case_dir/notifier.jsonl"
  sound_log="$case_dir/sound.jsonl"
  tmux_log="$case_dir/tmux.jsonl"
  focus_log="$case_dir/focus.json"
  socket="$case_dir/tmux.sock"
  inherited_tmux="$socket,947,1"
  inherited_pane='%2'
  mkdir -p "$fake_home/.agents/scripts/notification" "$fake_tmp"
  cp "$repo_root/.agents/scripts/notification/notify.sh" "$fake_home/.agents/scripts/notification/notify.sh"
  cat > "$fake_home/.agents/scripts/notification/focus-tmux-pane.sh" <<'FAKE'
#!/bin/bash
printf '%s\0' "$@" | jq -Rsc 'split("\u0000")[:-1]' > "$FOCUS_LOG"
FAKE
  chmod +x "$fake_home/.agents/scripts/notification/focus-tmux-pane.sh"
  : > "$notifier_log"; : > "$sound_log"; : > "$tmux_log"
  jq -n --arg socket "$socket" --arg session "$session" '{
    tty:"??", default_socket:$socket, session_name:"renamed session",
    panes:[{socket:$socket,id:"%134",program:"codex",tty:"/dev/ttys034",height:38,
            footer:("status line | " + $session + " | 42% context left")}]
  }' > "$fixture"
  event=$(jq -cn --arg session "$session" '{hook_event_name:"Stop",session_id:$session,
    cwd:"/Users/example/dotfiles",last_assistant_message:"Task completed"}')
}

update_fixture() {
  jq "$@" "$fixture" > "$fixture.next"
  mv "$fixture.next" "$fixture"
}

run_hook() {
  local payload=$1 suffix=${2:-run} script=${3:-} status event_name handler
  if [ -z "$script" ]; then
    event_name=$(printf '%s' "$payload" | jq -r 'if type == "object" then .hook_event_name // "" else "" end' 2>/dev/null) || event_name=
    case "$event_name" in
      PermissionRequest) script=notify-permission.sh ;;
      PreToolUse) script=notify-question.sh ;;
      *) script=notify-complete.sh ;;
    esac
  fi
  handler="$scripts_dir/$script"
  printf '%s' "$payload" > "$case_dir/$suffix.input"
  if env -i HOME="$fake_home" TMPDIR="$fake_tmp" PATH="$fake_bin:/usr/bin:/bin" \
    LANG=en_US.UTF-8 TMUX="$inherited_tmux" TMUX_PANE="$inherited_pane" \
    NOTIFY_FIXTURE="$fixture" NOTIFIER_LOG="$notifier_log" SOUND_LOG="$sound_log" \
    TMUX_LOG="$tmux_log" FOCUS_LOG="$focus_log" \
    /bin/bash "$handler" < "$case_dir/$suffix.input" \
    > "$case_dir/$suffix.stdout" 2> "$case_dir/$suffix.stderr"; then :
  else
    status=$?
    cat "$case_dir/$suffix.stderr" >&2
    fail "handler exited $status"
  fi
  cmp -s <(printf '{}\n') "$case_dir/$suffix.stdout" || fail 'hook stdout must be exactly {}'
}

delivery_count() { jq -s 'length' "$notifier_log"; }
argument_value() {
  jq -rs --arg flag "$1" '.[0] | index($flag) as $i | .[$i+1]' "$notifier_log"
}
assert_notification() {
  local kind=$1 title=$2 text=$3 sound=$4 attempt=0
  assert_equal 1 "$(delivery_count)" 'delivery count'
  assert_equal "$title - 9:41 AM" "$(argument_value -title)" 'title'
  assert_equal "\\[dotfiles] $text" "$(argument_value -message)" 'full body'
  assert_equal "codex-$session:$kind" "$(argument_value -group)" 'group'
  while [ ! -s "$sound_log" ] && [ "$attempt" -lt 50 ]; do
    sleep 0.01
    attempt=$((attempt + 1))
  done
  jq -es --arg sound "/System/Library/Sounds/$sound.aiff" \
    '. == [["-v","0.7",$sound]]' "$sound_log" >/dev/null || fail 'notification sound'
}
assert_callback() {
  local callback
  callback=$(argument_value -execute)
  env -i PATH="$fake_bin:/usr/bin:/bin" FOCUS_LOG="$focus_log" /bin/bash -c "$callback"
  jq -e --arg socket "$socket" '. == ["renamed session","%134",$socket]' "$focus_log" >/dev/null \
    || fail 'callback must retain the resolved pane and socket'
}

for script in notify-complete.sh notify-permission.sh notify-question.sh lib/notify.sh; do
  [ -f "$scripts_dir/$script" ] || fail "missing script: $script"
  bash -n "$scripts_dir/$script"
done

setup_case
text=$(jq -nr '"日本語の完了内容\n" + ("one two three four five six seven eight nine " * 8)')
expected=$(printf '%s' "$text" | jq -Rs 'gsub("\n";" ") | .[:200]' | jq -r .)
payload=$(printf '%s' "$event" | jq --arg text "$text" '.last_assistant_message=$text')
run_hook "$payload"
assert_notification finished '🤖 finished' "$expected" Purr
assert_equal 200 "$(printf '%s' "$expected" | jq -Rs 'length')" 'Unicode character limit'
pass 'completion preserves the full first 200 characters'

setup_case
payload=$(printf '%s' "$event" | jq '.hook_event_name="PermissionRequest" | .tool_name="exec_command" |
  .tool_input={description:"Install the requested package",command:"unused fallback"}')
run_hook "$payload"
assert_notification permission '🔐 permission' 'Install the requested package' Pop
pass 'permission description, title, group, and sound'

setup_case
for field in justification command cmd; do
  payload=$(printf '%s' "$event" | jq --arg field "$field" '.hook_event_name="PermissionRequest" |
    .tool_input={($field):("Use " + $field)}')
  run_hook "$payload"
done
payload=$(printf '%s' "$event" | jq '.hook_event_name="PermissionRequest" | .tool_input={}')
run_hook "$payload"
jq -es 'map(.[index("-message")+1]) == ["\\[dotfiles] Use justification",
  "\\[dotfiles] Use command","\\[dotfiles] Use cmd","\\[dotfiles] Approval requested"]' \
  "$notifier_log" >/dev/null || fail 'permission fallbacks'
pass 'permission summary fallbacks'

setup_case
payload=$(printf '%s' "$event" | jq '.hook_event_name="PreToolUse" | .tool_name="request_user_input" |
  .tool_input={questions:[{header:"Choose",question:"Which branch should I use?"},
                         {question:"Should I run the full checks?"}]}')
run_hook "$payload"
assert_notification question '❓ question' 'Which branch should I use? / Should I run the full checks?' Pop
pass 'normal questions use question fields'

setup_case
payload=$(printf '%s' "$event" | jq '.hook_event_name="PreToolUse" | .tool_name="request_user_input_async" |
  .tool_input={questions:[{title:"Choose a deployment target",question:"Unused field"}]}')
run_hook "$payload"
assert_notification question '❓ question' 'Choose a deployment target' Pop
pass 'async questions use title fields'

setup_case
for filter in \
  '.hook_event_name="SessionStart"' \
  '.hook_event_name="PostToolUse" | .tool_name="request_user_input"' \
  '.hook_event_name="PreToolUse" | .tool_name="exec_command" | .tool_input={cmd:"true"}' \
  '.agent_id="child-agent"' \
  '.hook_event_name="PermissionRequest" | .agent_id="guardian" | .tool_input={cmd:"true"}' \
  '.hook_event_name="PreToolUse" | .agent_id="child-agent" | .tool_name="request_user_input_async" | .tool_input={questions:[{title:"Do this?"}]}'
do
  run_hook "$(printf '%s' "$event" | jq "$filter")"
done
assert_equal 0 "$(delivery_count)" 'unrelated events and subagent deliveries'
[ ! -s "$tmux_log" ] || fail 'suppressed event must not query tmux'
pass 'unrelated events, tools, and subagents are suppressed before terminal queries'

setup_case
run_hook "$event" wrong-permission notify-permission.sh
run_hook "$event" wrong-question notify-question.sh
payload=$(printf '%s' "$event" | jq '.hook_event_name="PermissionRequest" | .tool_input={description:"Approve?"}')
run_hook "$payload" wrong-completion notify-complete.sh
assert_equal 0 "$(delivery_count)" 'events routed to the wrong script'
[ ! -s "$tmux_log" ] || fail 'wrong event must not query tmux'
pass 'each entry point ignores events belonging to another notification type'

setup_case
for payload in '{' '[]' 'null' '"text"' \
  "$(printf '%s' "$event" | jq '.tool_input=["invalid"]')" \
  "$(printf '%s' "$event" | jq '.last_assistant_message=42')" \
  "$(printf '%s' "$event" | jq '.hook_event_name="PreToolUse" | .tool_name="request_user_input" | .tool_input={questions:[{question:42}]}')"
do
  run_hook "$payload"
done
assert_equal 0 "$(delivery_count)" 'invalid payload deliveries'
pass 'invalid JSON and payload types are ignored with {} stdout'

setup_case
run_hook "$event"
run_hook "$(printf '%s' "$event" | jq 'to_entries | reverse | from_entries')"
assert_equal 1 "$(delivery_count)" 'sequential duplicate deliveries'
pass 'global and project copies of the same event deliver once'

setup_case
run_hook "$event" first & first_pid=$!
run_hook "$event" second & second_pid=$!
wait "$first_pid"
wait "$second_pid"
assert_equal 1 "$(delivery_count)" 'parallel duplicate deliveries'
pass 'parallel copies of the same event deliver once'

setup_case
cache_dir="$fake_tmp/codex-notifications-$UID"
mkdir -p "$cache_dir"
for content in '{' '[]' '{"invalid":"timestamp"}'; do
  printf '%s' "$content" > "$cache_dir/recent.json"
  payload=$(printf '%s' "$event" | jq --arg content "$content" '.last_assistant_message=$content')
  run_hook "$payload"
done
assert_equal 3 "$(delivery_count)" 'deliveries after corrupt cache recovery'
pass 'corrupt or invalid cache contents do not suppress notifications'

setup_case
run_hook "$event"
run_hook "$(printf '%s' "$event" | jq '.hook_event_name="PermissionRequest" | .tool_input={description:"Approve?"}')"
run_hook "$(printf '%s' "$event" | jq '.hook_event_name="PreToolUse" | .tool_name="request_user_input" | .tool_input={questions:[{question:"Choose?"}]}')"
jq -es --arg session "$session" 'map(.[index("-group")+1]) ==
  ["codex-"+$session+":finished","codex-"+$session+":permission","codex-"+$session+":question"]' \
  "$notifier_log" >/dev/null || fail 'distinct event groups'
pass 'different event kinds are not deduplicated'

setup_case
update_fixture --arg other "$other_session" '.panes =
  [(.panes[0] | .id="%2" | .program="zsh" | .footer=$other)] + .panes'
run_hook "$event"
assert_callback
jq -es '[.[] | select(.argv | index("list-panes"))] | length > 0 and
  all(.[]; .TMUX == "" and .TMUX_PANE == "")' "$tmux_log" >/dev/null \
  || fail 'pane discovery must clear stale tmux variables'
jq -es --arg socket "$socket" '[.[] | select(.argv | index("capture-pane")) | .argv] ==
  [["-S",$socket,"capture-pane","-p","-t","%134","-S","35"]]' "$tmux_log" >/dev/null \
  || fail 'only the CLI footer should be captured'
pass 'stale pane %2 is replaced by footer-matching pane %134'

setup_case
update_fixture '.tty="ttys034" | .panes[0].footer="no thread id"'
run_hook "$event"
assert_callback
pass 'a direct controlling terminal identifies its pane without a footer match'

setup_case
update_fixture --arg other "$other_session" '.panes =
  [(.panes[0] | .id="%133" | .footer=$other)] + .panes | .capture_fail=["%133"]'
run_hook "$event"
assert_callback
pass 'a pane disappearing during capture does not hide a valid match'

setup_case
update_fixture '.tty="ttys034"'
inherited_tmux=''
run_hook "$event"
assert_equal "/usr/bin/osascript -e 'tell application \"WezTerm\" to activate'" \
  "$(argument_value -execute)" 'non-tmux callback'
[ ! -s "$tmux_log" ] || fail 'direct non-tmux terminal must not query tmux'
pass 'a direct terminal outside tmux keeps the activation callback'

setup_case
update_fixture --arg other "$other_session" '.panes[0].footer=$other'
inherited_tmux=''
run_hook "$event"
assert_equal 0 "$(delivery_count)" 'GUI deliveries without a matching footer'
pass 'GUI events without a matching CLI footer do not notify'

setup_case
update_fixture '.panes += [(.panes[0] | .id="%135")]'
run_hook "$event"
assert_equal 0 "$(delivery_count)" 'ambiguous footer deliveries'
pass 'multiple matching CLI panes suppress the notification'

setup_case
update_fixture '.panes[0].program="zsh"'
run_hook "$event"
assert_equal 0 "$(delivery_count)" 'non-Codex foreground deliveries'
pass 'a matching UUID in another foreground application is ignored'

setup_case
update_fixture --arg session "$session" '.panes[0].footer="prefix-"+$session+"-suffix"'
run_hook "$event"
assert_equal 0 "$(delivery_count)" 'partial UUID deliveries'
pass 'a UUID inside a longer identifier is not a footer match'

setup_case
update_fixture '.panes += [(.panes[0] | .id="%135")] | .capture_delay={"%134":2.1}'
run_hook "$event"
assert_equal 0 "$(delivery_count)" 'incomplete pane discovery deliveries'
pass 'an incomplete pane scan cannot claim a unique match'

setup_case
update_fixture --arg other "$other_session" '.panes += [(.panes[0] | .id="%135" | .footer=$other)] |
  .capture_delay={"%135":2.1}'
run_hook "$event"
assert_equal 0 "$(delivery_count)" 'pane discovery exceeding its budget on the last query'
pass 'the final capture must finish within the discovery budget'

setup_case
marker="$case_dir/must-not-exist"
socket="$case_dir/socket 'quoted'; \$(touch $marker)"
inherited_tmux="$socket,947,1"
update_fixture --arg socket "$socket" '.default_socket=$socket | .panes[0].socket=$socket'
text="Keep \$(touch $marker) and 'quotes' and \`backticks\` literal"
payload=$(printf '%s' "$event" | jq --arg text "$text" '.last_assistant_message=$text')
run_hook "$payload"
assert_notification finished '🤖 finished' "$text" Purr
assert_callback
[ ! -e "$marker" ] || fail 'quoted input must not execute shell code'
pass 'quoted sockets and message text remain literal through the click callback'

setup_case
cache_dir="$fake_tmp/codex-notifications-$UID"
mkdir -p "$cache_dir"
sleep 0.01 & stale_pid=$!
wait "$stale_pid"
printf '%s\n' "$stale_pid" > "$cache_dir/lock"
run_hook "$event"
run_hook "$event"
assert_equal 1 "$(delivery_count)" 'idle lockfile must permit delivery and duplicate suppression'
pass 'an existing idle lockfile does not interfere with notification deduplication'

printf '1..%s\n' "$pass_count"
