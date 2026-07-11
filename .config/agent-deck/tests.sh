#!/bin/bash
# Smoke tests for agent-deck lib.sh. Run: bash .config/agent-deck/tests.sh
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DECK_STATE_DIR="$(mktemp -d)"
export AGENT_DECK_STATE_DIR
trap 'rm -rf "$AGENT_DECK_STATE_DIR"' EXIT

# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib.sh"

FAILURES=0
assert_eq() {
  local desc="$1" expected="$2" actual="$3"
  if [ "$expected" = "$actual" ]; then
    echo "ok - $desc"
  else
    echo "FAIL - $desc"
    echo "  expected: $expected"
    echo "  actual:   $actual"
    FAILURES=$((FAILURES + 1))
  fi
}

# --- deck_format_elapsed ---
assert_eq "elapsed seconds" "30s" "$(deck_format_elapsed 1000 970)"
assert_eq "elapsed minutes" "5m" "$(deck_format_elapsed 1300 1000)"
assert_eq "elapsed hours" "2h" "$(deck_format_elapsed 8200 1000)"

# --- deck_state_icon / deck_state_rank ---
assert_eq "icon working" "●" "$(deck_state_icon working)"
assert_eq "icon waiting" "◐" "$(deck_state_icon waiting)"
assert_eq "icon idle" "✔" "$(deck_state_icon idle)"
assert_eq "rank order" "0 1 2" \
  "$(deck_state_rank waiting) $(deck_state_rank working) $(deck_state_rank idle)"

# --- deck_write_state / deck_state_file / deck_remove_state ---
deck_write_state "%7" "main" "claude" "working" "/tmp/proj" "task/1"
f=$(deck_state_file "%7")
assert_eq "state file created" "yes" "$([ -f "$f" ] && echo yes)"
assert_eq "state file tool field" "claude" "$(jq -r '.tool' "$f")"
assert_eq "state file pane_id field" "%7" "$(jq -r '.pane_id' "$f")"
assert_eq "state file updated_at is numeric" "number" "$(jq -r '.updated_at | type' "$f")"
deck_remove_state "%7"
assert_eq "state file removed" "yes" "$([ ! -f "$f" ] && echo yes)"

# --- deck_render_fields: 7 tab-separated raw fields, no padding ---
fixture='{"pane_id":"%3","session_name":"main","tool":"claude","state":"waiting",
          "cwd":"/tmp/myproj","branch":"task/9","updated_at":940}'
line=$(deck_render_fields "$fixture" 1000)
assert_eq "render_fields first field is pane_id" "%3" "$(printf '%s' "$line" | cut -f1)"
assert_eq "render_fields icon field" "◐" "$(printf '%s' "$line" | cut -f2)"
assert_eq "render_fields tool field" "claude" "$(printf '%s' "$line" | cut -f3)"
assert_eq "render_fields project field" "myproj" "$(printf '%s' "$line" | cut -f4)"
assert_eq "render_fields branch field" "task/9" "$(printf '%s' "$line" | cut -f5)"
assert_eq "render_fields age field" "1m" "$(printf '%s' "$line" | cut -f6)"
assert_eq "render_fields session field" "main" "$(printf '%s' "$line" | cut -f7)"

# --- deck_list: ordering and liveness cleanup ---
rm -rf "$(deck_panes_dir)"
deck_write_state "%1" "s1" "claude" "idle" "/tmp/a" ""
deck_write_state "%2" "s2" "codex" "waiting" "/tmp/b" ""
deck_write_state "%3" "s3" "opencode" "working" "/tmp/c" ""
deck_write_state "%4" "s4" "claude" "working" "/tmp/d" ""
live=$'%1\n%2\n%3'
listed=$(deck_list "$(date +%s)" "$live")
assert_eq "list first line is column header" "HDR" \
  "$(printf '%s\n' "$listed" | head -1 | cut -f1)"
assert_eq "list order: waiting, working, idle" "%2 %3 %1" \
  "$(printf '%s\n' "$listed" | tail -n +2 | cut -f1 | tr '\n' ' ' | sed 's/ $//')"
assert_eq "dead pane state file removed" "yes" \
  "$([ ! -f "$(deck_state_file "%4")" ] && echo yes)"

# --- regression: empty branch must not shift field parsing ---
fixture_nb='{"pane_id":"%5","session_name":"s5","tool":"claude","state":"working","cwd":"/tmp/x","branch":"","updated_at":940}'
line_nb=$(deck_render_fields "$fixture_nb" 1000 2>&1)
case "$line_nb" in
  *arithmetic*)
    echo "FAIL - render_fields empty fields emit arithmetic error"
    echo "  actual: $line_nb"
    FAILURES=$((FAILURES + 1)) ;;
  *)
    echo "ok - render_fields empty fields emit no arithmetic error" ;;
esac
assert_eq "render_fields empty branch becomes dash" "-" \
  "$(printf '%s' "$line_nb" | cut -f5)"
assert_eq "render_fields empty branch keeps age field" "1m" \
  "$(printf '%s' "$line_nb" | cut -f6)"

rm -rf "$(deck_panes_dir)"
deck_write_state "%6" "s6" "codex" "idle" "/tmp/y" ""
noise=$(deck_list 1000 "%6" 2>&1 >/dev/null)
assert_eq "deck_list stderr clean with empty fields" "" "$noise"

# --- regression: unparseable state file is skipped, not deleted ---
rm -rf "$(deck_panes_dir)"
mkdir -p "$(deck_panes_dir)"
printf 'not json' > "$(deck_panes_dir)/999.json"
out=$(deck_list 1000 "%1" 2>&1)
assert_eq "malformed state file is not rendered" "" \
  "$(printf '%s\n' "$out" | tail -n +2)"
assert_eq "empty list still emits header line" "HDR" \
  "$(printf '%s\n' "$out" | head -1 | cut -f1)"
assert_eq "malformed state file survives cleanup" "yes" \
  "$([ -f "$(deck_panes_dir)/999.json" ] && echo yes)"

# --- deck_classify: fixture-driven, one case per tool per state ---
for tool in claude codex opencode cursor; do
  for state in working waiting idle; do
    fx="$SCRIPT_DIR/fixtures/${tool}-${state}.txt"
    assert_eq "classify $tool $state" "$state" \
      "$(deck_classify "$tool" "$(cat "$fx")")"
  done
done
assert_eq "classify unknown tool falls back to idle" "idle" \
  "$(deck_classify mystery "whatever is on screen")"
assert_eq "classify waiting beats working" "waiting" \
  "$(deck_classify claude "$(printf 'esc to interrupt\n❯ 1. Yes')")"
assert_eq "classify codex legacy uppercase working indicator" "working" \
  "$(deck_classify codex "▌ Working (3s · Esc to interrupt)")"
assert_eq "classify claude prose 'Do you want' stays idle" "idle" \
  "$(deck_classify claude "Do you want me to update the tests as well?")"
assert_eq "classify claude selector on option 2 is waiting" "waiting" \
  "$(deck_classify claude "$(printf 'Do you want to proceed?\n  1. Yes\n❯ 2. No')")"
assert_eq "classify cursor spinner token line is working" "working" \
  "$(deck_classify cursor " ⠘⠤ Globbing  609 tokens")"
assert_eq "classify cursor input hint is working" "working" \
  "$(deck_classify cursor "Add a follow-up    ctrl+c to stop")"
assert_eq "classify cursor prose token count stays idle" "idle" \
  "$(deck_classify cursor "The summary used about 1,200 tokens in total.")"

# --- deck_match_tool: pure process-identity matching ---
assert_eq "match_tool direct binary" "claude" \
  "$(deck_match_tool /opt/homebrew/bin/claude 'claude')"
assert_eq "match_tool codex" "codex" \
  "$(deck_match_tool codex 'codex resume')"
assert_eq "match_tool node wrapper resolves via args" "opencode" \
  "$(deck_match_tool /usr/local/bin/node 'node /Users/x/.opencode/bin/opencode')"
assert_eq "match_tool plain shell is no match" "none" \
  "$(deck_match_tool /bin/zsh '-zsh' || echo none)"
assert_eq "match_tool unrelated node process is no match" "none" \
  "$(deck_match_tool node 'node server.js' || echo none)"
assert_eq "match_tool cursor bundled node resolves via args" "cursor" \
  "$(deck_match_tool /Users/x/.local/share/cursor-agent/versions/2026.07.08/node \
    '/Users/x/.local/bin/agent --use-system-ca /Users/x/.local/share/cursor-agent/versions/2026.07.08/index.js')"
assert_eq "match_tool direct cursor-agent binary" "cursor" \
  "$(deck_match_tool /Users/x/.local/bin/cursor-agent 'cursor-agent')"
assert_eq "match_tool bare agent comm is no match" "none" \
  "$(deck_match_tool agent 'agent chat' || echo none)"

# --- deck_pane_tool: live smoke test (this test tree contains no agent) ---
assert_eq "pane_tool finds nothing under the test shell" "none" \
  "$(deck_pane_tool $$ || echo none)"

# --- deck_screen_tail: fresh TUI content at top of a tall blank pane ---
banner=$(printf 'Claude Code v2.1.205\nHaiku 4.5\n%s' "$(printf '\n%.0s' $(seq 1 70))")
assert_eq "screen_tail keeps top content of a mostly blank pane" \
  "Claude Code v2.1.205 Haiku 4.5" \
  "$(deck_screen_tail "$banner" | tr '\n' ' ' | sed 's/ $//')"
assert_eq "screen_tail of all-blank screen is empty" "" \
  "$(deck_screen_tail "$(printf '\n\n\n')")"

# --- deck_write_state: optional explicit updated_at (metadata refresh) ---
deck_write_state "%8" "s8" "claude" "idle" "/tmp/q" "main" "" 1234
assert_eq "write_state honors explicit updated_at" "1234" \
  "$(jq -r '.updated_at' "$(deck_state_file "%8")")"
deck_write_state "%8" "s8" "claude" "idle" "/tmp/q" "main"
assert_eq "write_state defaults updated_at to now" "number" \
  "$(jq -r '.updated_at | type' "$(deck_state_file "%8")")"
deck_remove_state "%8"

# --- deck_extract_title: from tmux pane_title (OSC terminal title) ---
assert_eq "extract_title strips status glyph" "dotfiles hi" \
  "$(deck_extract_title claude "✳ dotfiles hi")"
assert_eq "extract_title strips braille spinner glyph" "fix-pane-metadata-staleness" \
  "$(deck_extract_title claude "⠂ fix-pane-metadata-staleness")"
assert_eq "extract_title multibyte title survives" "スタンドアップでレビュータスクの引き継ぎが漏れている" \
  "$(deck_extract_title claude "✳ スタンドアップでレビュータスクの引き継ぎが漏れている")"
assert_eq "extract_title untitled default is empty" "" \
  "$(deck_extract_title claude "✳ Claude Code")"
assert_eq "extract_title glyphless title kept whole" "my session" \
  "$(deck_extract_title claude "my session")"
assert_eq "extract_title unsupported tool is empty" "" \
  "$(deck_extract_title codex "✳ whatever")"
assert_eq "extract_title cursor session title survives" "my cursor task" \
  "$(deck_extract_title cursor "my cursor task")"
assert_eq "extract_title cursor untitled default is empty" "" \
  "$(deck_extract_title cursor "Cursor Agent")"

# --- render: title wins, falls back to tmux session name; session is last (f7) ---
ft='{"pane_id":"%6","session_name":"tmuxsess","tool":"claude","state":"idle",
    "cwd":"/tmp/p","branch":"b","title":"my-ai-session","updated_at":940}'
assert_eq "render_fields shows title when present" "my-ai-session" \
  "$(deck_render_fields "$ft" 1000 | cut -f7)"
fnt='{"pane_id":"%6","session_name":"tmuxsess","tool":"claude","state":"idle",
     "cwd":"/tmp/p","branch":"b","title":"","updated_at":940}'
assert_eq "render_fields falls back to session_name" "tmuxsess" \
  "$(deck_render_fields "$fnt" 1000 | cut -f7)"

# --- deck_render_table: header line + per-column widths from longest value ---
r=$(printf '%%1\t●\tclaude\tp\ta\t1m\ts1\n%%2\t◐\tclaude\tp\ttask/very-long-branch-name\t2m\ts2\n' \
  | deck_render_table)
assert_eq "table header first field is HDR" "HDR" \
  "$(printf '%s\n' "$r" | head -1 | cut -f1)"
case "$(printf '%s\n' "$r" | head -1)" in
  *TOOL*PROJECT*BRANCH*AGE*SESSION) echo "ok - table header labels in order" ;;
  *) echo "FAIL - table header labels in order"; FAILURES=$((FAILURES + 1)) ;;
esac
pos1=$(printf '%s\n' "$r" | awk -F '\t' 'NR==2 {print index($2, " 1m")}')
pos2=$(printf '%s\n' "$r" | awk -F '\t' 'NR==3 {print index($2, " 2m")}')
assert_eq "table AGE position found" "yes" \
  "$([ "${pos1:-0}" -gt 0 ] 2>/dev/null && echo yes)"
assert_eq "table aligns AGE across rows" "$pos1" "$pos2"

# --- write_state persists title ---
deck_write_state "%9" "s9" "claude" "idle" "/tmp/r" "main" "some-title"
assert_eq "write_state persists title" "some-title" \
  "$(jq -r '.title' "$(deck_state_file "%9")")"
deck_remove_state "%9"

echo "---"
if [ "$FAILURES" -gt 0 ]; then
  echo "$FAILURES test(s) failed"
  exit 1
fi
echo "all tests passed"
