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
antigen theme yawnkinsfolk/dotfiles themes/yawn

# Tell Antigen that you're done.
antigen apply

# 🎃 🎃 🎃 🎃 🎃 🎃 🎃 🎃 🎃 🎃

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

# php TODO: manage on brew
export PATH="/usr/local/opt/php@7.0/bin:$PATH"
export PATH="/usr/local/opt/php@7.0/sbin:$PATH"
#export PATH="/usr/local/opt/php/bin:$PATH"
#export PATH="/usr/local/opt/php/sbin:$PATH"
# export PATH=/usr/local/opt/php@7.2/bin:$PATH
# export PATH=/usr/local/opt/php@7.2/sbin:$PATH
# export PATH=/usr/local/opt/php@7.3/bin:$PATH
# export PATH=/usr/local/opt/php@7.3/sbin:$PATH

# java
if [ `uname` = "Darwin" ]; then
  export JAVA_HOME=$(/usr/libexec/java_home)
fi

# android sdk
export ANDROID_SDK="$HOME/Library/Android/sdk"
export PATH="$ANDROID_SDK/emulator:$PATH"
export PATH="$ANDROID_SDK/platform-tools:$PATH"

# rbenv
if command -v rbenv 1>/dev/null 2>&1; then
  eval "$(rbenv init -)"
fi

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# golang
export PATH="/usr/local/go/bin:$PATH"

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# 🎃 🎃 🎃 🎃 🎃 🎃 🎃 🎃 🎃 🎃

alias ls="ls -G"
alias git-reset="git reset --hard ORIG_HEAD"
alias idea="idea ./"
alias phpstorm="phpstorm ./"
alias webstorm="webstorm ./"
alias goland="goland ./"
alias pycharm="pycharm ./"
alias appcode="appcode ./"
alias rubymine="rubymine ./"
alias datagrip="datagrip ./"

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
    docker exec -it "$container" /bin/bash
    registerInHistory "docker exec -it ${container} /bin/bash"
}


function ssh-ls () {
    local ssh=$(
        less ~/.ssh/config |
        grep -iE "^host[[:space:]]+[^*]" |
        sed -e "s/^Host //" |
        sort |
        fzf
    )
    if [[ -n "$ssh" ]]; then
        echo "Are you to connect to ${ssh}?  (y/n) :"
        if read -q; then
            ssh "$ssh"
            registerInHistory "ssh ${ssh}"
        fi
        echo "$ssh"
    fi
}
