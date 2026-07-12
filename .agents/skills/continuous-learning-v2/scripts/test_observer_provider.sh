#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
. "${SCRIPT_DIR}/observer-provider.sh"

assert_eq() {
  local expected="$1"
  local actual="$2"
  local label="$3"

  if [ "$expected" != "$actual" ]; then
    printf 'not ok - %s\nexpected: %s\nactual: %s\n' "$label" "$expected" "$actual" >&2
    exit 1
  fi
}

assert_success() {
  local label="$1"
  shift

  if ! "$@"; then
    printf 'not ok - %s\n' "$label" >&2
    exit 1
  fi
}

assert_failure() {
  local label="$1"
  shift

  if "$@"; then
    printf 'not ok - %s\n' "$label" >&2
    exit 1
  fi
}

assert_success "supports claude-ollama" clv2_observer_provider_supported claude-ollama
assert_success "supports claude-zai" clv2_observer_provider_supported claude-zai
assert_success "supports codex" clv2_observer_provider_supported codex
assert_failure "rejects unknown provider" clv2_observer_provider_supported not-real

assert_eq "claude" "$(clv2_observer_required_command claude-ollama)" "claude-ollama requires claude"
assert_eq "codex" "$(clv2_observer_required_command codex)" "codex requires codex"
assert_eq "gpt-oss:20b" "$(clv2_observer_ollama_model)" "default Ollama model"
assert_eq "http://127.0.0.1:11434" "$(clv2_observer_ollama_url)" "default Ollama URL"

CLV2_OBSERVER_OLLAMA_MODEL="gpt-oss:20b"
CLV2_OBSERVER_OLLAMA_URL="http://localhost:11434"
assert_eq "gpt-oss:20b" "$(clv2_observer_ollama_model)" "override Ollama model"
assert_eq "http://localhost:11434" "$(clv2_observer_ollama_url)" "override Ollama URL"

printf 'ok - observer provider helpers\n'
