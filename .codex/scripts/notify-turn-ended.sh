#!/bin/bash
# Legacy top-level notify adapter — suppresses subagent turn completions.

hook_input="${1:-}"
thread_id=$(printf '%s' "$hook_input" | jq -r '."thread-id" // empty' 2>/dev/null)

if [[ "$thread_id" =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]; then
  if [ -n "${CODEX_STATE_DB:-}" ]; then
    state_dbs=("$CODEX_STATE_DB")
  else
    shopt -s nullglob
    state_dbs=("${CODEX_HOME:-$HOME/.codex}"/state_*.sqlite)
    shopt -u nullglob
  fi

  for state_db in "${state_dbs[@]}"; do
    is_subagent=$(sqlite3 -noheader "file:$state_db?mode=ro" \
      "SELECT 1 FROM thread_spawn_edges WHERE child_thread_id = '$thread_id' LIMIT 1;" \
      2>/dev/null)
    [ "$is_subagent" = "1" ] && exit 0
  done
fi

computer_use_client="${CODEX_SKY_COMPUTER_USE_CLIENT:-$HOME/.codex/computer-use/Codex Computer Use.app/Contents/SharedSupport/SkyComputerUseClient.app/Contents/MacOS/SkyComputerUseClient}"
exec "$computer_use_client" turn-ended "$hook_input"
