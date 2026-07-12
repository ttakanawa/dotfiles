#!/usr/bin/env bash

clv2_observer_supported_providers() {
  printf '%s\n' 'claude, claude-zai, claude-ollama, codex'
}

clv2_observer_provider_supported() {
  case "${1:-}" in
    claude|claude-zai|claude-ollama|codex)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

clv2_observer_required_command() {
  case "${1:-}" in
    claude|claude-zai|claude-ollama)
      printf 'claude\n'
      ;;
    codex)
      printf 'codex\n'
      ;;
    *)
      return 1
      ;;
  esac
}

clv2_observer_ollama_model() {
  printf '%s\n' "${CLV2_OBSERVER_OLLAMA_MODEL:-gpt-oss:20b}"
}

clv2_observer_ollama_url() {
  printf '%s\n' "${CLV2_OBSERVER_OLLAMA_URL:-http://127.0.0.1:11434}"
}
