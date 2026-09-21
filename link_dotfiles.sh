#!/bin/sh

set -eu

dotfiles_root=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)

path_exists() {
  [ -e "$1" ] || [ -L "$1" ]
}

resolved_link_target() {
  link_path=$1
  destination_path=${2:-$link_path}
  link_target=$(readlink "$link_path") || return 1

  case "$link_target" in
    /*) ;;
    *) link_target="$(dirname -- "$destination_path")/$link_target" ;;
  esac

  link_directory=$(CDPATH= cd -- "$(dirname -- "$link_target")" 2>/dev/null && pwd -P) || return 1
  printf '%s/%s\n' "$link_directory" "$(basename -- "$link_target")"
}

backup_existing_path() {
  path=$1
  backup_path="${path}.pre-manage-dotfiles"

  if path_exists "$backup_path"; then
    echo "backup already exists: $backup_path" >&2
    return 1
  fi

  echo "rename current path: $path"
  mv "$path" "$backup_path"
}

link_codex_entry() {
  entry=$1
  source_path="$dotfiles_root/.codex/$entry"
  target_path="$HOME/.codex/$entry"

  case "$entry" in
    rules|scripts)
      if [ ! -d "$source_path" ]; then
        echo "managed Codex directory does not resolve: $source_path" >&2
        return 1
      fi
      ;;
    *)
      if [ ! -f "$source_path" ]; then
        echo "managed Codex file does not resolve: $source_path" >&2
        return 1
      fi
      ;;
  esac

  if [ -L "$target_path" ] && [ "$(readlink "$target_path")" = "$source_path" ]; then
    return
  fi

  if path_exists "$target_path"; then
    backup_existing_path "$target_path"
  fi

  ln -s "$source_path" "$target_path"
}

link_codex_dotfiles() {
  codex_repo="$dotfiles_root/.codex"
  codex_home="$HOME/.codex"
  migration_path="$HOME/.codex.pre-real-directory"

  if [ -L "$codex_home" ]; then
    linked_directory=$(CDPATH= cd -- "$codex_home" 2>/dev/null && pwd -P) || {
      echo "broken ~/.codex symlink: $codex_home" >&2
      return 1
    }
    repository_directory=$(CDPATH= cd -- "$codex_repo" 2>/dev/null && pwd -P) || {
      echo "Codex repository directory does not exist: $codex_repo" >&2
      return 1
    }

    if [ "$linked_directory" != "$repository_directory" ]; then
      echo "refusing to replace unexpected ~/.codex symlink: $(readlink "$codex_home")" >&2
      return 1
    fi

    if path_exists "$migration_path"; then
      echo "migration path already exists: $migration_path" >&2
      return 1
    fi

    echo "migrate Codex state to a real directory: $codex_home"
    mv "$codex_repo" "$migration_path"
    if ! unlink "$codex_home"; then
      mv "$migration_path" "$codex_repo"
      return 1
    fi
    if ! mv "$migration_path" "$codex_home"; then
      mv "$migration_path" "$codex_repo"
      ln -s "$codex_repo" "$codex_home"
      return 1
    fi
  elif ! path_exists "$codex_home"; then
    mkdir -p "$codex_home"
  elif [ ! -d "$codex_home" ]; then
    echo "~/.codex is not a directory: $codex_home" >&2
    return 1
  fi

  mkdir -p "$codex_repo"

  for entry in .gitignore config.toml AGENTS.md rules scripts; do
    source_path="$codex_home/$entry"
    target_path="$codex_repo/$entry"

    if ! path_exists "$target_path" && path_exists "$source_path"; then
      if [ -L "$source_path" ]; then
        resolved_source=
        if ! resolved_source=$(resolved_link_target "$source_path" "$target_path"); then
          echo "managed Codex link cannot be restored safely: $source_path" >&2
          return 1
        fi
        if [ "$resolved_source" = "$target_path" ]; then
          echo "managed Codex link points to its missing repository path: $source_path" >&2
          return 1
        fi
        if [ ! -e "$resolved_source" ]; then
          echo "managed Codex link would not resolve after restoration: $source_path" >&2
          return 1
        fi
      fi

      mv "$source_path" "$target_path"
    fi
  done

  for entry in config.toml AGENTS.md rules scripts; do
    link_codex_entry "$entry"
  done
}

link_codex_dotfiles

targets='
.zshrc
.zshenv
.config
.agents
.claude
.markdownlint.yaml
'

for target in ${targets}; do
  target_home="$HOME/${target}"
  target_pwd="$dotfiles_root/${target}"

  if [ -L "$target_home" ]; then
    echo "delete current symlink: $(ls -la "$target_home")"
    unlink "$target_home"
  elif path_exists "$target_home"; then
    backup_existing_path "$target_home"
  fi

  ln -si "$target_pwd" "$target_home"
done
