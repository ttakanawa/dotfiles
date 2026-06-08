eval "$(sheldon source)"

eval "$(zoxide init zsh)"

eval "$(direnv hook zsh)"

eval "$(~/.local/bin/mise activate zsh)"

# AWS CLI completion
autoload bashcompinit && bashcompinit
complete -C '/usr/local/bin/aws_completer' aws