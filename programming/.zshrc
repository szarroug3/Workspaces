# setup antibody
source <(antibody init)

# Path to your oh-my-zsh installation.
export ZSH="$(antibody home)/https-COLON--SLASH--SLASH-github.com-SLASH-ohmyzsh-SLASH-ohmyzsh"
source $ZSH/oh-my-zsh.sh

# Load antibody bundles
antibody bundle "
    # oh-my-zsh
    ohmyzsh/ohmyzsh path:lib
    ohmyzsh/ohmyzsh path:plugins/aws
    ohmyzsh/ohmyzsh path:plugins/docker
    ohmyzsh/ohmyzsh path:plugins/git
    ohmyzsh/ohmyzsh path:plugins/git-extras
    ohmyzsh/ohmyzsh path:plugins/gitfast
    ohmyzsh/ohmyzsh path:plugins/history
    ohmyzsh/ohmyzsh path:plugins/kubectl
    ohmyzsh/ohmyzsh path:plugins/python
    ohmyzsh/ohmyzsh path:plugins/virtualenv
    ohmyzsh/ohmyzsh path:plugins/web-search
 
    # mine
    szarroug3/zsh-bundles kind:zsh path:themes/monokai.zsh-theme
 
    # external
    QuarticCat/zsh-smartcache
    zsh-users/zsh-syntax-highlighting
    zsh-users/zsh-autosuggestions
"

# zsh-syntax-highlighting options
ZSH_HIGHLIGHT_STYLES[path]='fg=black'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=green'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=black'

# zsh-autosuggestions options
COMPLETION_WAITING_DOTS="true"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=white"

# Use zsh-autosuggestions ctrl+space
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=50
bindkey '^ ' autosuggest-accept

# Bind home and End keys
bindkey  "^[[H"   beginning-of-line
bindkey  "^[[F"   end-of-line

# tmux/emacs bindings
sebpane-down() { tmux select-pane -D }
sebpane-up() { tmux select-pane -U }
sebpane-left() { tmux select-pane -L }
sebpane-right() { tmux select-pane -R }
zle -N sebpane-down
zle -N sebpane-up
zle -N sebpane-left
zle -N sebpane-right
bindkey '^[j' sebpane-down
bindkey '^[k' sebpane-up
bindkey '^[h' sebpane-left
bindkey '^[l' sebpane-right

# ag aliases
alias ag='ag --color --color-line-number=95 --color-path=94 --color-match=31 --hidden'
alias agi='ag -S --color --color-line-number=95 --color-path=94 --color-match=31 --hidden'
alias agit='ag -S --color --color-line-number=95 --color-path=94 --color-match=31 --hidden --ignore="test"'
alias agip='ag -S --color --color-line-number=95 --color-path=94 --color-match=31 --hidden -G ".py"'

# docker aliases
alias drma='docker rm $(docker stop $(docker ps -aq))'

# git aliases
alias glfp="git log --first-parent --no-merges"
alias gcane="git commit --amend --no-edit"
alias gcan!="git commit --amend --no-edit -a"
alias gcfb="git cat-file blob"
alias grlp="git reflog --pretty=fuller"
alias grm="git fetch origin master && git reset --hard origin/master"

# kubectl
alias kd='kubectl describe'
alias kg='kubectl get'
alias kdeleteforce='kubectl delete --force --grace-period=0'

# random things
alias talisman="$HOME/.talisman/bin/talisman_darwin_amd64"

# environment variables
export TERM="xterm"
export PATH=$PATH:/usr/local/go/bin
export TALISMAN_HOME="$HOME/.talisman/bin"
export PATH="$HOME/.jenv/bin:$PATH"
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

smartcache eval jenv init -
smartcache eval rbenv init - zsh
eval "$(op completion zsh)"; compdef _op op
