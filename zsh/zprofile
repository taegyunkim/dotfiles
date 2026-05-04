if [[ "$OSTYPE" == darwin* ]]; then
  export BROWSER='open'
fi

if (( $+commands[nvim] )); then
  export EDITOR='nvim'
  export VISUAL='nvim'
else
  export EDITOR='vim'
  export VISUAL='vim'
fi
export PAGER='less'

if [[ -z "$LANG" ]]; then
  export LANG='en_US.UTF-8'
fi

export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"

if [[ -r "$HOME/.privilegesalias" ]]; then
  source "$HOME/.privilegesalias"
fi

# Less
# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'

# Set the Less input preprocessor.
if (( $+commands[lesspipe.sh] )); then
  export LESSOPEN='| /usr/bin/env lesspipe.sh %s 2>&-'
fi

# Set PATH, MANPATH, etc., for Homebrew.
if [ -x "/opt/homebrew/bin/brew" ]; then
  eval $(/opt/homebrew/bin/brew shellenv)
elif [ -x "/usr/local/bin/brew" ]; then
  eval $(/usr/local/bin/brew shellenv)
elif [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

[ -s "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

if [[ -d "$HOME/.volta" ]]; then
  export VOLTA_HOME="$HOME/.volta"
  path=("$VOLTA_HOME/bin" ${path:#$VOLTA_HOME/bin})
fi

# Prefer user-installed shims and scripts over system tools from /usr/bin.
path=("$HOME/.local/bin" ${path:#$HOME/.local/bin})

if [[ -d "/usr/local/go/bin" ]]; then
  path=("/usr/local/go/bin" ${path:#/usr/local/go/bin})
fi

if [[ $+commands[go] ]]; then
  gopath_bin="$(go env GOPATH)/bin"
  path=("$gopath_bin" ${path:#$gopath_bin})
fi

if [[ -d "$PYENV_ROOT/bin" ]]; then
  path=("$PYENV_ROOT/bin" ${path:#$PYENV_ROOT/bin})
fi

if command -v pyenv > /dev/null; then
  # Keep pyenv shims ahead of package-manager Pythons in login shells and automation.
  path=("$PYENV_ROOT/shims" ${path:#$PYENV_ROOT/shims})
fi

if [[ -d "$HOME/.local/share/coursier/bin" ]]; then
  export COURSIER_BIN_DIR="$HOME/.local/share/coursier/bin"
  path=("$COURSIER_BIN_DIR" ${path:#$COURSIER_BIN_DIR})
fi

if [[ -d "$HOME/.nimble/bin" ]]; then
  path=("$HOME/.nimble/bin" ${path:#$HOME/.nimble/bin})
fi

if [[ -d "/usr/local/cuda/bin" ]]; then
  path=("/usr/local/cuda/bin" ${path:#/usr/local/cuda/bin})
  export LD_LIBRARY_PATH=/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
fi

export PATH
