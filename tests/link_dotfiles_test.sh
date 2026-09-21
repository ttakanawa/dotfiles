#!/bin/sh

set -u

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
source_script="$script_dir/../link_dotfiles.sh"
test_root=$(mktemp -d "${TMPDIR:-/tmp}/link-dotfiles-test.XXXXXX")
trap 'rm -rf "$test_root"' EXIT HUP INT TERM

failures=0

fail() {
  printf 'not ok - %s\n' "$1"
  failures=$((failures + 1))
}

pass() {
  printf 'ok - %s\n' "$1"
}

make_fixture() {
  fixture=$1
  fixture_repo="$fixture/repo"
  fixture_home="$fixture/home"

  mkdir -p \
    "$fixture_repo/.config" \
    "$fixture_repo/.agents" \
    "$fixture_repo/.claude" \
    "$fixture_repo/.codex/rules" \
    "$fixture_repo/.codex/scripts" \
    "$fixture_home"

  fixture_repo=$(CDPATH= cd -- "$fixture_repo" && pwd -P)
  fixture_home=$(CDPATH= cd -- "$fixture_home" && pwd -P)

  printf 'zshrc\n' >"$fixture_repo/.zshrc"
  printf 'zshenv\n' >"$fixture_repo/.zshenv"
  printf 'markdownlint\n' >"$fixture_repo/.markdownlint.yaml"
  printf 'instructions\n' >"$fixture_repo/.claude/CLAUDE.md"
  printf '*\n' >"$fixture_repo/.codex/.gitignore"
  printf 'model = "test"\n' >"$fixture_repo/.codex/config.toml"
  ln -s ../.claude/CLAUDE.md "$fixture_repo/.codex/AGENTS.md"
  printf 'prefix_rule()\n' >"$fixture_repo/.codex/rules/default.rules"
  printf '#!/bin/sh\n' >"$fixture_repo/.codex/scripts/custom.sh"
  cp "$source_script" "$fixture_repo/link_dotfiles.sh"
}

run_setup() {
  (
    cd "$fixture_repo" || exit 1
    HOME="$fixture_home" sh ./link_dotfiles.sh >/dev/null
  )
}

assert_managed_links() {
  test_name=$1

  for entry in config.toml AGENTS.md rules scripts; do
    link_path="$fixture_home/.codex/$entry"
    expected_target="$fixture_repo/.codex/$entry"

    if [ ! -L "$link_path" ]; then
      fail "$test_name: $entry is a symlink"
      continue
    fi

    if [ "$(readlink "$link_path")" != "$expected_target" ]; then
      fail "$test_name: $entry points to the repository"
    fi

    case "$entry" in
      rules|scripts)
        if [ ! -d "$link_path" ]; then
          fail "$test_name: $entry resolves to a directory"
        fi
        ;;
      *)
        if [ ! -f "$link_path" ]; then
          fail "$test_name: $entry resolves to a file"
        fi
        ;;
    esac
  done
}

test_migrates_current_codex_layout() {
  test_name='migrates the current Codex directory layout'
  make_fixture "$test_root/migrate"
  mkdir -p "$fixture_repo/.codex/sessions"
  printf 'secret\n' >"$fixture_repo/.codex/auth.json"
  printf 'session\n' >"$fixture_repo/.codex/sessions/session.json"
  ln -s "$fixture_repo/.codex" "$fixture_home/.codex"

  if ! run_setup; then
    fail "$test_name: setup succeeds"
    return
  fi

  if [ -L "$fixture_home/.codex" ] || [ ! -d "$fixture_home/.codex" ]; then
    fail "$test_name: ~/.codex becomes a real directory"
  fi
  if [ ! -f "$fixture_home/.codex/auth.json" ] || [ ! -f "$fixture_home/.codex/sessions/session.json" ]; then
    fail "$test_name: runtime state remains under ~/.codex"
  fi
  if [ -e "$fixture_repo/.codex/auth.json" ] || [ -e "$fixture_repo/.codex/sessions" ]; then
    fail "$test_name: runtime state leaves the repository"
  fi
  if [ ! -f "$fixture_repo/.codex/.gitignore" ]; then
    fail "$test_name: repository-only .gitignore remains tracked"
  fi
  assert_managed_links "$test_name"
  pass "$test_name"
}

test_creates_real_codex_home_on_fresh_setup() {
  test_name='creates a real Codex home on a fresh setup'
  make_fixture "$test_root/fresh"

  if ! run_setup; then
    fail "$test_name: setup succeeds"
    return
  fi

  if [ -L "$fixture_home/.codex" ] || [ ! -d "$fixture_home/.codex" ]; then
    fail "$test_name: ~/.codex is a real directory"
  fi
  assert_managed_links "$test_name"
  pass "$test_name"
}

test_preserves_existing_real_codex_home() {
  test_name='preserves an existing real Codex home'
  make_fixture "$test_root/existing"
  mkdir -p "$fixture_home/.codex"
  printf 'runtime\n' >"$fixture_home/.codex/history.jsonl"
  printf 'local config\n' >"$fixture_home/.codex/config.toml"

  if ! run_setup; then
    fail "$test_name: setup succeeds"
    return
  fi

  if [ ! -f "$fixture_home/.codex/history.jsonl" ]; then
    fail "$test_name: runtime state is not moved aside"
  fi
  if [ "$(cat "$fixture_home/.codex/config.toml.pre-manage-dotfiles" 2>/dev/null)" != 'local config' ]; then
    fail "$test_name: conflicting managed files are backed up"
  fi
  assert_managed_links "$test_name"
  pass "$test_name"
}

test_is_idempotent() {
  test_name='keeps Codex links and runtime state on repeated setup'
  make_fixture "$test_root/idempotent"

  if ! run_setup; then
    fail "$test_name: first setup succeeds"
    return
  fi
  printf 'runtime\n' >"$fixture_home/.codex/history.jsonl"
  if ! run_setup; then
    fail "$test_name: second setup succeeds"
    return
  fi

  if [ ! -f "$fixture_home/.codex/history.jsonl" ]; then
    fail "$test_name: repeated setup preserves runtime state"
  fi
  assert_managed_links "$test_name"
  pass "$test_name"
}

test_refuses_unexpected_codex_symlink() {
  test_name='refuses an unexpected ~/.codex symlink'
  make_fixture "$test_root/unexpected-link"
  mkdir -p "$test_root/unexpected-link/other-codex"
  ln -s "$test_root/unexpected-link/other-codex" "$fixture_home/.codex"

  if run_setup; then
    fail "$test_name: setup exits unsuccessfully"
    return
  fi

  if [ "$(readlink "$fixture_home/.codex")" != "$test_root/unexpected-link/other-codex" ]; then
    fail "$test_name: unexpected symlink is left untouched"
  fi
  pass "$test_name"
}

test_refuses_dangling_managed_link() {
  test_name='refuses a dangling managed Codex link'
  make_fixture "$test_root/dangling-managed-link"
  mkdir -p "$fixture_home/.codex"
  rm "$fixture_repo/.codex/rules/default.rules"
  rmdir "$fixture_repo/.codex/rules"
  ln -s "$fixture_repo/.codex/rules" "$fixture_home/.codex/rules"

  if run_setup; then
    fail "$test_name: setup exits unsuccessfully"
    return
  fi

  if [ "$(readlink "$fixture_home/.codex/rules")" != "$fixture_repo/.codex/rules" ]; then
    fail "$test_name: dangling Home link is left untouched"
  fi
  if path_exists_for_test "$fixture_repo/.codex/rules"; then
    fail "$test_name: no self-referential repository link is created"
  fi
  pass "$test_name"
}

path_exists_for_test() {
  [ -e "$1" ] || [ -L "$1" ]
}

test_codex_gitignore_allows_only_managed_code() {
  test_name='allows Codex rules and scripts while ignoring runtime state'
  fixture="$test_root/gitignore"
  mkdir -p "$fixture/.codex/rules" "$fixture/.codex/scripts" "$fixture/.codex/sessions"
  cp "$script_dir/../.codex/.gitignore" "$fixture/.codex/.gitignore"
  printf 'prefix_rule()\n' >"$fixture/.codex/rules/default.rules"
  printf '#!/bin/sh\n' >"$fixture/.codex/scripts/custom.sh"
  printf 'secret\n' >"$fixture/.codex/auth.json"
  printf 'session\n' >"$fixture/.codex/sessions/session.json"
  git -C "$fixture" init -q

  if git -C "$fixture" check-ignore -q .codex/rules/default.rules; then
    fail "$test_name: rules are available for Git tracking"
  fi
  if git -C "$fixture" check-ignore -q .codex/scripts/custom.sh; then
    fail "$test_name: scripts are available for Git tracking"
  fi
  if ! git -C "$fixture" check-ignore -q .codex/auth.json; then
    fail "$test_name: authentication state remains ignored"
  fi
  if ! git -C "$fixture" check-ignore -q .codex/sessions/session.json; then
    fail "$test_name: session state remains ignored"
  fi
  pass "$test_name"
}

test_migrates_current_codex_layout
test_creates_real_codex_home_on_fresh_setup
test_preserves_existing_real_codex_home
test_is_idempotent
test_refuses_unexpected_codex_symlink
test_refuses_dangling_managed_link
test_codex_gitignore_allows_only_managed_code

if [ "$failures" -ne 0 ]; then
  printf '%s test assertion(s) failed\n' "$failures" >&2
  exit 1
fi

printf 'all link_dotfiles tests passed\n'
