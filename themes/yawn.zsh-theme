# fork from https://github.com/robbyrussell/oh-my-zsh/blob/master/themes/gnzh.zsh-theme

setopt prompt_subst

() {

local PR_USER PR_USER_OP PR_PROMPT PR_HOST DAY

# Check UID
if [[ $UID -ne 0 ]]; then # normal user
  PR_USER='%F{green}%n%f'
  PR_USER_OP='%F{green}%#%f'
  PR_PROMPT='➤ '
else # root
  PR_USER='%F{red}%n%f'
  PR_USER_OP='%F{red}%#%f'
  PR_PROMPT='%F{red}%f'
fi

# Check be on SSH or not
if [[ -n "$SSH_CLIENT"  ||  -n "$SSH2_CLIENT" ]]; then
  PR_HOST='%F{red}%M%f' # SSH
else
  PR_HOST='%F{green}%M%f' # no SSH
fi

case $(date +%u) in
    1 ) DAY="Mon." ;;
    2 ) DAY="Tue." ;;
    3 ) DAY="Wed." ;;
    4 ) DAY="Thu." ;;
    5 ) DAY="Fri." ;;
    6 ) DAY="Sat." ;;
    7 ) DAY="Sun." ;;
esac

local datetime="[%F{yellow}%D %* ${DAY}%f]"
local user_host="${PR_USER}%F{cyan}@${PR_HOST}"
local current_dir="%F{blue}%~%f"
local git_branch='$(git_prompt_info)'

local return_code="%(?..%F{red}%? ↵%f)"

PROMPT="╭─${datetime} ${current_dir} ${git_branch}
╰─$PR_PROMPT "
RPROMPT="${return_code}"

ZSH_THEME_GIT_PROMPT_PREFIX="‹%B%F{white}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%f%b›"

}
