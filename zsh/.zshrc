# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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

antigen theme romkatv/powerlevel10k

antigen apply

# powerlevel10k config, to customize prompt, run `p10k configure` or
# edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# DataDog environment. Mirrors what the ansible playbook writes on a
# DD-managed machine, plus a few personal preferences. Only runs when
# $HOME/dd exists, so non-DD machines are unaffected.
if [[ -d "$HOME/dd" ]]; then
  if [[ $OSTYPE == "darwin"* ]]; then
    _evalcache /opt/homebrew/bin/brew shellenv

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
  export PATH="$HOME/dd/devtools/bin:$PATH"
  export GOPATH="$HOME/go"
  export PATH="$GOPATH/bin:$PATH"
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
  export PATH="$BP_INFRA_HOME:$PATH"
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
eval "$(/home/bits/.local/bin/mise activate zsh)"
