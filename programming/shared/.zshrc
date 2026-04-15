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
  export NVM_AUTO_USE=true
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
command -v op >/dev/null && eval "$(op completion zsh)" && compdef _op op
command -v uv >/dev/null && eval "$(uv generate-shell-completion bash)"
command -v docker >/dev/null && source <(docker completion zsh)

autoload -U +X bashcompinit && bashcompinit
[[ -x /usr/local/bin/terraform ]] && complete -o nospace -C /usr/local/bin/terraform terraform

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# ---------- functions ----------
hppm() {
  local base_branch="${1:-main}"
  gh pr create --base "$base_branch" --fill
}

# ---------- end ----------
