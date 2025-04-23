# Aliases
alias lg="lazygit"
alias ld="lazydocker"
alias gget="ghq get"
alias c="cursor ."
alias v="nvim ."
alias vim="nvim ."

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
  local task=$(aws --profile "$profile" ecs list-tasks --cluster "$cluster" --query "taskArns[]" --output text | sed 's|.*/||' | fzf --height=10 --prompt="Select ECS Task: ")

  if [ -z "$task" ]; then
    echo "No ECS task selected. Aborting."
    return 1
  fi

  # 実行するコマンドを組み立て
  echo "Executing command:"
  local cmd="aws --profile $profile ecs execute-command \\
      --cluster $cluster \\
      --task $task \\
      --container app \\
      --interactive \\
      --command \"/bin/sh\""

  # コマンドを出力
  echo "$cmd"

  # コマンド実行
  aws --profile "$profile" ecs execute-command --cluster "$cluster" \
    --task "$task" \
    --container app \
    --interactive \
    --command "/bin/sh"
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
      wezterm ssh "$ssh"
      # TODO: save to zsh history
    fi
    echo "$ssh"
  fi
}

function ghq-fzf() {
  local src=$(ghq list | fzf --preview "bat --theme=\"Monokai Extended\" --color=always --style=header,grid --line-range :80 $(ghq root)/{}/README.*")
  if [ -n "$src" ]; then
    BUFFER="cd $(ghq root)/$src"
    zle accept-line
  fi
  zle -R -c
}
zle -N ghq-fzf
bindkey '^]' ghq-fzf

function g() {
  # Check if the current directory is a Git repository
  git rev-parse --is-inside-work-tree &>/dev/null || {
    echo "The current directory is not a Git repository."
    return
  }

  # Get the remote URL of the Git repository
  remote_url=$(git config --get remote.origin.url)

  if [[ $remote_url == http* ]]; then
    # If the URL is http, use it as is
    open_url=$remote_url
  elif [[ $remote_url == git@* ]]; then
    # If the URL is in git@ format, convert it to http format
    open_url=$(echo $remote_url | sed -E 's/git@([^:]+):(.+)/https:\/\/\1\/\2/')
  elif [[ $remote_url == ssh://git@* ]]; then
    # If the URL is in ssh:// format, convert it to http format
    open_url=$(echo $remote_url | sed -E 's/ssh:\/\/git@([^\/]+)\/(.+)/https:\/\/\1\/\2/')
  else
    echo "Unknown Git repository URL format."
    return
  fi

  # For GitHub URLs, remove .git (applicable to other Git hosting services as well)
  open_url=${open_url%.git}

  # Open in browser
  open "$open_url" || xdg-open "$open_url" || start "$open_url"
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
