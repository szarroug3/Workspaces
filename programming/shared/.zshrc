# ---------- platform-specific early setup ----------
# Source platform overrides FIRST so agent bridges/paths are set up
# before anything that might depend on them.
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# ---------- antidote / oh-my-zsh ----------
# Location of antidote is platform-specific — allow override via $ANTIDOTE_HOME.
: "${ANTIDOTE_HOME:=/opt/homebrew/opt/antidote/share/antidote}"
if [[ ! -f "$ANTIDOTE_HOME/antidote.zsh" ]]; then
  for _p in /usr/share/zsh-antidote /usr/share/zsh/plugins/antidote "$HOME/.antidote"; do
    [[ -f "$_p/antidote.zsh" ]] && ANTIDOTE_HOME="$_p" && break
  done
  unset _p
fi

if [[ -f "$ANTIDOTE_HOME/antidote.zsh" ]]; then
  source "$ANTIDOTE_HOME/antidote.zsh"
  export ZSH="$(antidote home)/https-COLON--SLASH--SLASH-github.com-SLASH-ohmyzsh-SLASH-ohmyzsh"
  export ZSH_CACHE_DIR="$ZSH/cache"
  mkdir -p "$ZSH_CACHE_DIR/completions"
  export NVM_LAZY_LOAD=true
  export NVM_COMPLETION=true
  # NVM_AUTO_USE=true defeats lazy-load (runs nvm_auto on every shell start,
  # which fully sources nvm.sh — ~1s). Leave it off; run `nvm use` manually
  # or add a chpwd hook if you want per-directory auto-switching.
  [[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"
  autoload -Uz compinit && compinit
  antidote load "$HOME/.zsh_plugins.txt"
else
  echo "zshrc: antidote not installed — plugins disabled" >&2
  autoload -Uz compinit && compinit
fi

# ---------- highlighting / suggestions ----------
ZSH_HIGHLIGHT_STYLES[path]='fg=white'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=green'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=white'
COMPLETION_WAITING_DOTS="true"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=white"
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=50
bindkey '^ ' autosuggest-accept

# ---------- keybindings ----------
bindkey  "^[[H"   beginning-of-line
bindkey  "^[[F"   end-of-line

sebpane-down()  { tmux select-pane -D }
sebpane-up()    { tmux select-pane -U }
sebpane-left()  { tmux select-pane -L }
sebpane-right() { tmux select-pane -R }
zle -N sebpane-down
zle -N sebpane-up
zle -N sebpane-left
zle -N sebpane-right
bindkey '^[j' sebpane-down
bindkey '^[k' sebpane-up
bindkey '^[h' sebpane-left
bindkey '^[l' sebpane-right

# ---------- aliases ----------
# ag
alias ag='ag --color --color-line-number=95 --color-path=94 --color-match=31 --hidden'
alias agi='ag -S --color --color-line-number=95 --color-path=94 --color-match=31 --hidden'
alias agit='ag -S --color --color-line-number=95 --color-path=94 --color-match=31 --hidden --ignore="test"'
alias agip='ag -S --color --color-line-number=95 --color-path=94 --color-match=31 --hidden -G ".py"'

# docker
alias drmc='docker rm $(docker stop $(docker ps -aq))'
alias drmi='docker rmi $(docker images -q)'

# git
alias glfp='git log --first-parent --no-merges'
alias gcane='git commit --amend --no-edit'
alias gcan!='git add -u && git commit --amend --no-edit -a'
alias gcfb='git cat-file blob'
alias grlp='git reflog --pretty=fuller'
alias grm='git fetch origin main && git reset --hard origin/main'
alias gbda='git branch | grep -v "main" | grep -v "master" | xargs git branch -D'
alias gnb='f() { git fetch origin main && git checkout -b $1 origin/main }; f'
alias gfb='git fetch origin main && git rebase -i origin/main'
alias gfco='f() { git fetch origin $1 && git checkout -b $1 origin/$1 }; f'
alias grhc='git reset --hard && git clean -d -f'

# gh
alias gwr='gh workflow run'
alias gwv='gh workflow view'
alias gwvl='f() { gh run list --workflow "$1" --limit 1 --json databaseId --jq ".[] | .databaseId" | xargs gh run view --log; }; f'
alias gwvlp='f() { until gwvl "$1" | grep -v "is still in progress; logs will be available when it is complete"; do sleep 10; done }; f'

# kubectl
alias kd='kubectl describe'
alias kg='kubectl get'
alias kdeleteforce='kubectl delete --force --grace-period=0'

# aws
alias mfa='source ~/bin/mfa Samreen.Zarroug $(op item get --account my.1password.com --vault "Work" --otp "Amazonaws-us-gov")'

alias vets="$HOME/bin/run-va.sh $"

# ---------- environment ----------
export TERM="xterm"
export PATH="$PATH:/usr/local/go/bin"
export PATH="$PATH:$HOME/.rbenv"
export PATH="$PATH:$HOME/bin"
export TALISMAN_HOME="$HOME/.talisman/bin"
export PATH="$HOME/.jenv/bin:$PATH"
export PYENV_ROOT="$HOME/.pyenv"
[[ -d "$PYENV_ROOT/bin" ]] && export PATH="$PYENV_ROOT/bin:$PATH"
export NVM_DIR="$HOME/.nvm"

# rbenv / completions
command -v smartcache >/dev/null && command -v rbenv >/dev/null && smartcache eval rbenv init - zsh

# Cache shell-completion scripts on disk — regenerating them on every shell
# start was costing ~150–200ms. Regenerates when the tool's binary is newer
# than the cache, so updates are picked up automatically.
ZSH_COMPLETION_CACHE="$HOME/.cache/zsh-completions"
[[ -d "$ZSH_COMPLETION_CACHE" ]] || mkdir -p "$ZSH_COMPLETION_CACHE"
_cached_completion() {
  local cmd="$1"; shift
  local bin; bin="$(command -v "$cmd" 2>/dev/null)" || return 0
  local cache="$ZSH_COMPLETION_CACHE/$cmd.zsh"
  if [[ ! -s "$cache" || "$bin" -nt "$cache" ]]; then
    "$cmd" "$@" >| "$cache" 2>/dev/null || { rm -f "$cache"; return 0; }
  fi
  source "$cache"
}
_cached_completion op completion zsh && compdef _op op
_cached_completion uv generate-shell-completion zsh
_cached_completion docker completion zsh

autoload -U +X bashcompinit && bashcompinit
[[ -x /usr/local/bin/terraform ]] && complete -o nospace -C /usr/local/bin/terraform terraform

# NOTE: don't source $NVM_DIR/nvm.sh here — the zsh-nvm plugin (loaded via
# antidote) handles lazy-loading. Sourcing nvm.sh directly loads the full
# ~1.5k-line script at every shell start and defeats NVM_LAZY_LOAD.

# Auto `nvm use` on cd into a directory with an .nvmrc (walks up to find it).
# Cheap parent-walk avoids forcing nvm.sh to load in non-node dirs; only calls
# `nvm` when an .nvmrc is actually found, which triggers the lazy-load shim.
autoload -U add-zsh-hook
_nvmrc_autoload() {
  local dir="$PWD" nvmrc=""
  while [[ -n "$dir" ]]; do
    if [[ -f "$dir/.nvmrc" ]]; then nvmrc="$dir/.nvmrc"; break; fi
    [[ "$dir" == "/" || "$dir" == "$HOME" ]] && break
    dir="${dir:h}"
  done
  [[ -z "$nvmrc" || "$nvmrc" == "${_NVMRC_LAST-}" ]] && return
  _NVMRC_LAST="$nvmrc"
  nvm use >/dev/null
}
add-zsh-hook chpwd _nvmrc_autoload
# Run once so shells started inside a project (e.g. tmux panes) pick up the
# right node version.
_nvmrc_autoload

# ---------- functions ----------
hppm() {
  local base_branch="${1:-main}"
  gh pr create --base "$base_branch" --fill
}

# ---------- 1Password secret helpers ----------
# `op run` resolves op:// references in an env-file and injects them into a
# single child process — secrets never live in the shell environment. The
# biometric unlock happens once per `op` session (~30 min default).

tf-azure-gov() {
  op run --env-file="$HOME/.config/envs/azure-gov.env" -- terraform "$@"
}

tf-azure-commercial() {
  # TF_VAR_bot_data embeds the commercial microsoft_app_id; build it at call
  # time from 1Password so the secret isn't written into an env file.
  local app_id
  app_id=$(op read 'op://Work/azure-commercial/microsoft_app_id') || return
  TF_VAR_bot_data="{ auth=\"$app_id\" }" \
    op run --env-file="$HOME/.config/envs/azure-commercial.env" -- terraform "$@"
}

# Export Sidekiq Enterprise creds into the current shell — needed for
# `bundle install` since bundler reads BUNDLE_ENTERPRISE__CONTRIBSYS__COM
# directly from env. Only run this in shells where you're actually doing
# bundle work.
load-bundler-creds() {
  export BUNDLE_ENTERPRISE__CONTRIBSYS__COM="$(op read 'op://Work/sidekiq-enterprise/credentials')" \
    && echo "BUNDLE_ENTERPRISE__CONTRIBSYS__COM loaded into this shell"
}

# ---------- end ----------
