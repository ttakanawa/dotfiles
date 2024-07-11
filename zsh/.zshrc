autoload -U compinit && compinit

export DOTFILES=$HOME/dotfiles

source $DOTFILES/antigen/antigen.zsh

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

# Bundles from the default repo (robbyrussell's oh-my-zsh).
antigen bundle z

# Bundles from git repos.
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-autosuggestions

# antigen theme $HOME/dotfiles plugins/nvm

# Load the theme.
antigen theme ttakanawa/dotfiles themes/yawn

# Tell Antigen that you're done.
antigen apply

# 🎃 🎃 🎃 🎃 🎃 🎃 🎃 🎃 🎃 🎃 ^ antigen preferences

HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# The older command is removed from the history list if a new command line duplicated an older one,
setopt hist_ignore_all_dups
# Share command history data
setopt share_history
# Do not add history command to the history list.
setopt hist_no_store
# Strip superfluous blanks from each command line being added to the history list
setopt hist_reduce_blanks
# Zsh sessions will append their history list to the history file, rather than replace it
setopt append_history
# Add to the history list incrementally
setopt inc_append_history
# Use wild card correctly
setopt nonomatch

# android sdk
export ANDROID_SDK="$HOME/Library/Android/sdk"
export PATH="$ANDROID_SDK/emulator:$PATH"
export PATH="$ANDROID_SDK/platform-tools:$PATH"

if [ `uname -m` = "arm64" ]; then
    # visual studio code
    export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"
fi

export PATH="$HOME/bin:$PATH"

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# https://man7.org/linux/man-pages/man1/time.1.html
TIMEFMT=$'\n'\
'executed command: %J'$'\n'\
'Time'$'\n'\
'  real %E'$'\n'\
'  user %U'$'\n'\
'  sys %S'$'\n'\
'  cpu usage %P'$'\n'\
'Memory'$'\n'\
'  avg shared (code):         %X KB'$'\n'\
'  avg unshared (data/stack): %D KB'$'\n'\
'  avg total:                 %K KB'$'\n'\
'  max rss:                   %M KB'$'\n'\
'  major page faults:         %F times'$'\n'\
'  minor page faults:         %R times'
# 🎃 🎃 🎃 🎃 🎃 🎃 🎃 🎃 🎃 🎃 ^ environment variables

alias lg="lazygit"
alias gget="ghq get --shallow"
alias c="code ."
alias dc="docker-compose"
alias p="pstorm ."

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

function ssh-ls () {
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
   local src=$(ghq list | fzf --preview "bat --theme=\"Monokai Extended\" --color=always --style=header,grid --line-range :80 $(ghq root)/{}/README.*")
  if [ -n "$src" ]; then
    BUFFER="cd $(ghq root)/$src"
    zle accept-line
  fi
  zle -R -c
}
zle -N ghq-fzf
bindkey '^]' ghq-fzf

function git-open() {
  # Check if the current directory is a Git repository
  git rev-parse --is-inside-work-tree &>/dev/null || { echo "The current directory is not a Git repository."; return; }

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
zle -N git-open
bindkey '^[' git-open

# 🎃 🎃 🎃 🎃 🎃 🎃 🎃 🎃 🎃 🎃 ^ functions
