# when you load your local file, run below.
# % antigen theme $HOME/dotfiles themes/yawn --no-local-clone
setopt prompt_subst
autoload -U colors && colors

() {

# Datetime
__datetime() {
  echo -n "%D{%Y/%m/%d} %* "
}

# Username.
# If user is root, then pain it in red. Otherwise, just print in yellow.
__user() {
  if [[ $USER == 'root' ]]; then
    echo -n "%{$fg_bold[red]%}"
  else
    echo -n "%{$fg[green]%}"
  fi
  echo -n "%n"
  echo -n "%{$reset_color%}"
}

__host() {
  if [[ -n "$SSH_CONNECTION" || -n "$SSH_CLIENT"  ||  -n "$SSH2_CLIENT" ]]; then
    echo -n "%B@%b"
    echo -n "%{$fg_bold[green]%}"
    echo -n "%M"
    echo -n "%{$reset_color%}"
#     echo -n " %Bin%b "
  elif [[ $LOGNAME != $USER ]] || [[ $USER == 'root' ]]; then
#     echo -n " %Bin%b "
    echo -n "%{$reset_color%}"
  else
    echo -n "%B@%b"
    echo -n "%{$fg[green]%}"
    echo -n "%M"
    echo -n "%{$reset_color%}"
  fi
}


# Current directory.
# Return only three last items of path
__current_dir() {
  echo -n "%{$fg_bold[blue]%}"
  echo -n "%3~"
  echo    "%{$reset_color%}"
}

# Git status.
# Collect indicators, git branch and pring string.
__git_status() {
  echo -n "%{$fg[yellow]%}"
#   echo -n "$(git_current_branch)"
  echo -n "$(git_prompt_info)"
  echo -n "%{$reset_color%}"
}
ZSH_THEME_GIT_PROMPT_PREFIX=""
ZSH_THEME_GIT_PROMPT_SUFFIX=""

__r_prompt() {
  if [[ $USER == 'root' ]]; then
    echo -n "%{$fg_bold[red]%}"
    echo -n "➤ "
  else
    echo -n "➤ "
  fi
  echo -n "%{$reset_color%}"
}

# Command prompt.
# Pain $PROMPT_SYMBOL in red if previous command was fail and
# pain in green if all OK.
__return_status() {
  echo -n "%(?.%{$fg[green]%}.%{$fg[red]%})"
  echo -n "%B${__PROMPT_SYMBOL}%b"
  echo    "%{$reset_color%}"
}

PROMPT='╭─$(__datetime)$(__user)$(__host) $(__current_dir) $(__git_status)
╰─$(__r_prompt) $(__return_status)'
RPROMPT='$(__return_status)'

}
