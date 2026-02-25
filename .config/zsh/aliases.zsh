# Aliases
alias lg="lazygit"
alias ld="lazydocker"
alias gget="ghq get"
alias v="nvim"
alias vim="nvim"
alias c="claude"
alias c-dev='claude --system-prompt "$(cat ~/.claude/contexts/dev.md)"'
alias c-review='claude --system-prompt "$(cat ~/.claude/contexts/review.md)"'
alias c-research='claude --system-prompt "$(cat ~/.claude/contexts/research.md)"'

# Functions
function awsin() {
  local profile=$(aws configure list-profiles | fzf --height=10 --prompt="Select AWS Profile: ")
  aws sso login --profile "$profile"
}

function ecsin() {
  # aws profile を fzf で選択
  local profile=$(aws configure list-profiles | fzf --height=10 --prompt="Select AWS Profile: ")

  if [ -z "$profile" ]; then
    echo "No AWS profile selected. Aborting."
    return 1
  fi

  # クラスターのリストを取得して fzf で選択
  local cluster=$(aws --profile "$profile" ecs list-clusters --query "clusterArns[]" --output text | tr '\t' '\n' | sed 's|.*/||' | fzf --height=10 --prompt="Select ECS Cluster: ")

  if [ -z "$cluster" ]; then
    echo "No ECS cluster selected. Aborting."
    return 1
  fi

  # クラスターに関連するタスクのリストを取得して fzf で選択
  local task=$(aws --profile "$profile" ecs list-tasks --cluster "$cluster" --query "taskArns[]" --output text | tr '\t' '\n' | sed 's|.*/||' | fzf --height=10 --prompt="Select ECS Task: ")

  if [ -z "$task" ]; then
    echo "No ECS task selected. Aborting."
    return 1
  fi

  # コンテナ名を fzf に選択
  local container=$(aws --profile "$profile" ecs describe-tasks --cluster "$cluster" --tasks "$task" --query "tasks[0].containers[].name" --output text | tr '\t' '\n' | fzf --height=10 --prompt="Select Container: ")

  if [ -z "$container" ]; then
    echo "No container selected. Aborting."
    return 1
  fi

  # 実行するコマンドを fzf に選択
  local command=$(echo -e "/bin/sh\n/bin/bash" | fzf --height=10 --prompt="Select Command: ")

  if [ -z "$command" ]; then
    echo "No command selected. Aborting."
    return 1
  fi

  # 実行するコマンドを組み立て
  echo "Executing command:"
  local cmd="aws --profile $profile ecs execute-command \\
      --cluster $cluster \\
      --task $task \\
      --container $container \\
      --interactive \\
      --command \"$command\""

  # コマンドを出力
  echo "$cmd"

  # コマンド実行
  aws --profile "$profile" ecs execute-command --cluster "$cluster" \
    --task "$task" \
    --container "$container" \
    --interactive \
    --command "$command"
}

function docin() {
  local container
  container=$(docker ps --format "{{.Names}}")
  if [[ -z "$container" ]]; then
    echo Error: You don\'t have any containers.
    return
  fi
  container=$(docker ps --format "{{.Names}}" | fzf)
  if [[ -z "$container" ]]; then
    echo Error: You don\'t have any containers.
    return
  fi
  if [ $# -eq 0 ]; then
    docker exec -it "$container" bash
    return
  fi
  docker exec -it "$container" "$1"
  # TODO: save to zsh history
}

function ssh-ls() {
  local ssh=$(
    less $HOME/.ssh/config |
      grep -iE "^host[[:space:]]+[^*]" |
      sed -e "s/^Host //" |
      sort |
      fzf
  )
  if [[ -n "$ssh" ]]; then
    echo "Are you to connect to ${ssh}?  (y/n) :"
    if read -q; then
      ssh "$ssh"
      # TODO: save to zsh history
    fi
    echo "$ssh"
  fi
}

function ghq-fzf() {
  local src=$(ghq list | fzf --preview "bat --theme=ansi --color=always --style=header,grid --line-range :80 $(ghq root)/{}/README.*")
  if [ -n "$src" ]; then
    BUFFER="cd $(ghq root)/$src"
    zle accept-line
  fi
  zle -R -c
}
zle -N ghq-fzf
bindkey '^[g' ghq-fzf

function git-remote-url() {
  git rev-parse --is-inside-work-tree &>/dev/null || {
    echo "The current directory is not a Git repository." >&2
    return 1
  }

  local remote_url
  remote_url=$(git config --get remote.origin.url)

  local open_url
  if [[ $remote_url == http* ]]; then
    open_url=$remote_url
  elif [[ $remote_url == git@* ]]; then
    open_url=$(echo $remote_url | sed -E 's/git@([^:]+):(.+)/https:\/\/\1\/\2/')
  elif [[ $remote_url == ssh://git@* ]]; then
    open_url=$(echo $remote_url | sed -E 's/ssh:\/\/git@([^\/]+)\/(.+)/https:\/\/\1\/\2/')
  else
    echo "Unknown Git repository URL format." >&2
    return 1
  fi

  echo "${open_url%.git}"
}

function g() {
  if [ $# -eq 0 ]; then
    local url
    url=$(git-remote-url) || return
    open "$url" || xdg-open "$url" || start "$url"
    return
  fi

  local host
  host=$(git remote get-url origin | sed -E 's#(https?://|git@)([^:/]+).*#\2#')
  if glab auth status --hostname "$host" >/dev/null 2>&1; then
    if [ $# -ge 2 ]; then
      local url
      url=$(git-remote-url) || return
      open "$url/-/blob/$1/$2"
    else
      glab repo view --web -b "$1"
    fi
  else
    if [ $# -ge 2 ]; then
      gh browse "$2" --branch "$1"
    else
      gh browse "$1"
    fi
  fi
}

function go-install() {
  go install golang.org/dl/$1@latest
  $1 download
}

function go-ls() {
  go=$(ls ~/sdk | fzf)
  if [[ -z "$go" ]]; then
    echo Error: You don\'t have any gos.
    return
  fi
  export GOROOT=$($go env GOROOT)
  export PATH=$GOROOT/bin:$PATH
  go version
  # TODO: save to zsh history
}
