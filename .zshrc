# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:*:make:*' tag-order 'targets'

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

source ~/.config/zsh/plugins.zsh
source ~/.config/zsh/aliases.zsh
source ~/.config/zsh/environment.zsh
