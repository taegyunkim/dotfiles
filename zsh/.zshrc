# Interactive zsh setup. Keep login-shell startup in ~/.zprofile minimal, so
# interactive shells behave the same whether or not they are login shells.
typeset -U path PATH

_path_prepend() {
  local dir="$1"
  path=("$dir" "${(@)path:#$dir}")
}

_path_prepend_if_dir() {
  [[ -d "$1" ]] && _path_prepend "$1"
}

if [[ "$OSTYPE" == darwin* ]]; then
  export BROWSER='open'
fi

if [[ -z "$LANG" ]]; then
  export LANG='en_US.UTF-8'
fi

export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"

# Set PATH, MANPATH, etc., for Homebrew.
if [[ -x "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x "/usr/local/bin/brew" ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
elif [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

[[ -s "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

if [[ -d "$HOME/.volta" ]]; then
  export VOLTA_HOME="$HOME/.volta"
  _path_prepend "$VOLTA_HOME/bin"
fi

# Prefer user-installed shims and scripts over system tools from /usr/bin.
_path_prepend "$HOME/.local/bin"
_path_prepend_if_dir "/usr/local/go/bin"

if (( $+commands[go] )); then
  _path_prepend "$(go env GOPATH)/bin"
fi

_path_prepend_if_dir "$PYENV_ROOT/bin"

if command -v pyenv > /dev/null; then
  # Keep pyenv shims ahead of package-manager Pythons.
  _path_prepend "$PYENV_ROOT/shims"
fi

if [[ -d "$HOME/.local/share/coursier/bin" ]]; then
  export COURSIER_BIN_DIR="$HOME/.local/share/coursier/bin"
  _path_prepend "$COURSIER_BIN_DIR"
fi

_path_prepend_if_dir "$HOME/.nimble/bin"

if [[ -d "/usr/local/cuda/bin" ]]; then
  _path_prepend "/usr/local/cuda/bin"
  export LD_LIBRARY_PATH=/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
fi

export PATH

if (( $+commands[nvim] )); then
  export EDITOR='nvim'
  export VISUAL='nvim'
else
  export EDITOR='vim'
  export VISUAL='vim'
fi
export PAGER='less'

# Less
# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'

# Set the Less input preprocessor.
if (( $+commands[lesspipe.sh] )); then
  export LESSOPEN='| /usr/bin/env lesspipe.sh %s 2>&-'
fi

[[ -r "$HOME/.privilegesalias" ]] && source "$HOME/.privilegesalias"

# Antigen for zsh plugins/modules
if [[ -f "$HOME/.dotfiles/zsh/antigen/antigen.zsh" ]]; then
  source "$HOME/.dotfiles/zsh/antigen/antigen.zsh"
fi

zstyle ':omz:plugins:nvm' lazy yes
zstyle ':omz:plugins:nvm' lazy-cmd vim nvim code

antigen bundle ag
antigen bundle colored-man-pages
antigen bundle command-not-found
antigen bundle common-aliases
# antigen bundle git
antigen bundle gnu-utils
# antigen bundle rkh/zsh-jj
antigen bundle nvm
antigen bundle mroth/evalcache
antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-history-substring-search
antigen bundle zsh-users/zsh-autosuggestions

antigen apply

# DataDog environment. Mirrors what the ansible playbook writes on a
# DD-managed machine, plus a few personal preferences. Only runs when
# $HOME/dd exists, so non-DD machines are unaffected.
if [[ -d "$HOME/dd" ]]; then
  if [[ $OSTYPE == "darwin"* ]]; then
    # Force certain more-secure behaviours from homebrew
    export HOMEBREW_NO_INSECURE_REDIRECT=1
    export HOMEBREW_CASK_OPTS=--require-sha
    export HOMEBREW_DIR=/opt/homebrew
    export HOMEBREW_BIN=/opt/homebrew/bin
  fi

  # Ruby shims (rbenv installed by ansible on DD machines)
  if command -v rbenv > /dev/null; then
    _evalcache rbenv init - --no-rehash
  fi

  if [[ $OSTYPE == "darwin"* ]]; then
    # Prefer GNU binaries to Macintosh binaries.
    export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"

    # gcloud (homebrew install path)
    [[ -f "/opt/homebrew/share/google-cloud-sdk/path.zsh.inc" ]] && \
      source "/opt/homebrew/share/google-cloud-sdk/path.zsh.inc"
    [[ -f "/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc" ]] && \
      source "/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc"
  fi

  # DD devtools and Go workspace
  _path_prepend "$HOME/dd/devtools/bin"
  export GOPATH="$HOME/go"
  _path_prepend "$GOPATH/bin"
  export DATADOG_ROOT="$HOME/dd"
  # Tell the devenv vm to mount $GOPATH/src rather than just dd-go
  export MOUNT_ALL_GO_SRC=1

  # AWS Vault: store key in the login keychain instead of a hidden one,
  # and bump session times so we don't re-enter passwords every 5min.
  export AWS_VAULT_KEYCHAIN_NAME=login
  export AWS_SESSION_TTL=24h
  export AWS_ASSUME_ROLE_TTL=1h

  # Helm: keep storing objects in configmaps (legacy default we still use).
  export HELM_DRIVER=configmap

  # Go module configuration for DD private repos.
  export GO111MODULE=auto
  export GOPRIVATE=github.com/DataDog
  export GOPROXY="binaries.ddbuild.io,proxy.golang.org,direct"
  export GONOSUMDB="github.com/DataDog,go.ddbuild.io"

  # Personal preferences (not part of the ansible block).
  export DD_FAST_BUILD=1
  export DD_USE_SCCACHE=1
  export CMAKE_BUILD_PARALLEL_LEVEL=$(nproc)
  export BP_INFRA_HOME="$HOME/dd/benchmarking-platform-tools/bp-infra"
  _path_prepend "$BP_INFRA_HOME"
  if [[ $OSTYPE == "darwin"* ]] && command -v dd-gitsign > /dev/null; then
    _evalcache dd-gitsign load-key
  fi
fi

# colorful ls command
if [[ -s "$HOME/.dir_colors" ]]; then
  if [[ $OSTYPE == 'darwin'* ]]; then
    _evalcache gdircolors "$HOME/.dir_colors"
  else
    _evalcache dircolors "$HOME/.dir_colors"
  fi
fi
alias ls='ls --color=auto'
(( $+commands[nvim] )) && alias vim='nvim'

# zsh completion and history search
source ~/.dotfiles/zsh/completion.zsh
source ~/.dotfiles/zsh/history.zsh

alias vpn='sudo openconnect --background --user tk2374 --authgroup "NYU VPN: NYU-NET Traffic Only" vpn.nyu.edu'
alias vpnall='sudo openconnect --background --user tk2374 --authgroup "NYU VPN: All Traffic" vpn.nyu.edu'
alias killvpn='sudo killall -SIGINT openconnect'

# to know the key binding for a key, run `od -c` and press the key
bindkey -v '^?' backward-delete-char
bindkey '^[[3~' delete-char       # [DEL] key proper behaviour
bindkey '^[[1;5C' forward-word    # [Ctrl-RightArrow] - move forward one word
bindkey '^[[1;5D' backward-word   # [Ctrl-LeftArrow] - move backward one word
bindkey "^[[H" beginning-of-line  # [Home] - goes at the begining of the line
bindkey "^[[F" end-of-line        # [End] - goes at the end of the line
bindkey "^[[1~" beginning-of-line # [Home] - goes at the begining of the line
bindkey "^[[4~" end-of-line       # [End] - goes at the end of the line
bindkey '^[[A' history-substring-search-up # or '\eOA'
bindkey '^[[B' history-substring-search-down # or '\eOB'
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1

# Pyenv installed with pyenv installer/homebrew

if [[ ! -d "$HOME/dd" ]]; then
  alias brew='env PATH="${PATH//$(pyenv root)\/shims:/}" brew'
fi

if command -v pyenv > /dev/null; then
  # Interactive shell integration only; PATH ordering lives in zprofile.
  if [[ -z "${PYENV_SHELL:-}" ]]; then
    _evalcache pyenv init - --no-push-path --no-rehash
  fi
  # pyenv virtualenv-init disabled (~1.2s precmd penalty per command).
  # Use `pyenv activate <env>` / `pyenv deactivate` manually.
fi

pyenv-brew-relink() {
  rm -f "$HOME/.pyenv/versions/*-brew"
  for i in $(brew --cellar)/python@*; do
    echo "$i"
    ln -s -f -v "$i" "$HOME/.pyenv/versions/${i##/*/}-brew"
  done
  pyenv rehash
}

if [[ ! -d "$HOME/dd" ]]; then
  if [[ $OSTYPE == 'linux-gnu' && -s "/usr/lib/jvm/default-java" ]]; then
    export JAVA_HOME=/usr/lib/jvm/default-java
  fi

  # TODO: use https://github.com/matthieusb/zsh-sdkman for faster loading.
  # https://github.com/sdkman/sdkman-cli/issues/977
  # THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
  export SDKMAN_DIR="$HOME/.sdkman"
  [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

if [[ -r ~/.opam/opam-init/init.zsh ]]; then
  source ~/.opam/opam-init/init.zsh > /dev/null 2> /dev/null
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Starship prompt. Guarded so machines without starship still get a bare zsh
# prompt; _evalcache caches the init output for faster shell startup.
if command -v starship > /dev/null; then
  _evalcache starship init zsh
fi

timezsh() {
  shell=${1-$SHELL}
  for i in $(seq 1 10); do /usr/bin/time $shell -i -c exit; done
}

git-remove-deleted-branches() {
  git fetch --prune origin

  git for-each-ref --format='%(refname:short) %(upstream:track)' refs/heads \
  | awk '$2=="[gone]" {print $1}' \
  | while read -r br; do
      wt=$(git worktree list --porcelain | awk -v b="refs/heads/$br" '
        $1=="worktree"{w=$2}
        $1=="branch" && $2==b {print w; exit}
      ')
      if [ -n "$wt" ]; then
        git worktree remove --force "$wt"
      fi
      git branch -D "$br"
    done

  git worktree prune
}

ulimit -c unlimited
command -v mise > /dev/null && eval "$(mise activate zsh)"
