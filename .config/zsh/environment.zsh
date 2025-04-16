# android sdk
export ANDROID_SDK="$HOME/Library/Android/sdk"
export PATH="$ANDROID_SDK/emulator:$PATH"
export PATH="$ANDROID_SDK/platform-tools:$PATH"

export PATH="/Applications/IntelliJ IDEA.app/Contents/MacOS:$PATH"
# export XDG_CONFIG_HOME="$HOME/.config"

export JAVA_HOME="/Library/Java/JavaVirtualMachines/temurin-21.jdk/Contents/Home"

if [ $(uname -m) = "arm64" ]; then
  # visual studio code
  export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"
fi

export PATH="$HOME/bin:$PATH"

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# The next line updates PATH for the Google Cloud SDK.
# if [ -f '/Users/tomonori.takanawa/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/tomonori.takanawa/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
# if [ -f '/Users/tomonori.takanawa/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/tomonori.takanawa/google-cloud-sdk/completion.zsh.inc'; fi

# export GOPATH=$HOME/go
# export GOPATH=$HOME/go/bin/go1.22.5
export PATH=$HOME/go/bin:$PATH
export PATH="$(brew --prefix)/opt/python@3.11/libexec/bin:$PATH"

export PATH="/Applications/WezTerm.app/Contents/MacOS:$PATH"

typeset -U PATH 