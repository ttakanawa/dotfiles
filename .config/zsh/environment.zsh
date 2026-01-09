export EDITOR="nvim"

# doom emacs
export PATH="$HOME/.config/emacs/bin:$PATH"

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

export PATH=/usr/local/go/bin:$PATH
export PATH="$(brew --prefix)/opt/python@3.11/libexec/bin:$PATH"

export PATH="/Applications/WezTerm.app/Contents/MacOS:$PATH"

# bun completions
[ -s "/Users/tknw/.bun/_bun" ] && source "/Users/tknw/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"

export ZK_NOTEBOOK_DIR="$HOME/workspace/notes"

# Added by Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

typeset -U PATH
