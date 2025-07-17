export EDITOR="nvim"

# android sdk
export ANDROID_SDK="$HOME/Library/Android/sdk"
export PATH="$ANDROID_SDK/emulator:$PATH"
export PATH="$ANDROID_SDK/platform-tools:$PATH"

export PATH="/Applications/IntelliJ IDEA.app/Contents/MacOS:$PATH"
export XDG_CONFIG_HOME="$HOME/.config"

export JAVA_HOME="/Library/Java/JavaVirtualMachines/temurin-21.jdk/Contents/Home"

if [ $(uname -m) = "arm64" ]; then
  # visual studio code
  export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"
fi

export PATH="$HOME/bin:$PATH"

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH=/usr/local/go/bin:$PATH
export PATH="$(brew --prefix)/opt/python@3.11/libexec/bin:$PATH"

export PATH="/Applications/WezTerm.app/Contents/MacOS:$PATH"

# bun completions
[ -s "/Users/tknw/.bun/_bun" ] && source "/Users/tknw/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"

typeset -U PATH 