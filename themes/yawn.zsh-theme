# when you load your local file, run below.
# % antigen reset; 
# % zsh;
# % antigen theme $HOME/dotfiles themes/yawn --no-local-clone
setopt prompt_subst
autoload -U colors && colors

() {

__user() {
  if [[ $USER == 'root' ]]; then
    echo -n "%{$fg[red]%}"
  else
    echo -n "%{$fg[green]%}"
  fi
  echo -n "%n"
  echo -n "%{$reset_color%}"
}

__host() {
  if [[ -n "$SSH_CONNECTION" || -n "$SSH_CLIENT"  ||  -n "$SSH2_CLIENT" ]]; then
    echo -n "%{$fg[green]%}"
    echo -n "%M"
    echo -n "%{$reset_color%}"
#     echo -n " %Bin%b "
  elif [[ $LOGNAME != $USER ]] || [[ $USER == 'root' ]]; then
#     echo -n " %Bin%b "
    echo -n "%{$reset_color%}"
  else
    echo -n "%{$fg[green]%}"
    echo -n "%M"
    echo -n "%{$reset_color%}"
  fi
}

# Current directory. Return only three last items of path.
__current_dir() {
  echo -n "%{$fg[blue]%}"
  echo -n "%3~"
  echo -n "%{$reset_color%}"
}

__git_status() {
  echo -n "%{$fg[yellow]%}"
#   echo -n "$(git_current_branch)"
  echo -n "$(git_prompt_info)"
  echo -n "%{$reset_color%}"
}
ZSH_THEME_GIT_PROMPT_PREFIX=""
ZSH_THEME_GIT_PROMPT_SUFFIX=""

PROMPT='$(__user)@$(__host) $(__current_dir) $(__git_status)
%# '

# RPROMPT='$(__datetime)'
}
