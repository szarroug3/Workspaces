# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
  export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="minimal"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(aws chucknorris docker git git-extras gitfast golang history kubectl lol pip python sublime terraform web-search)

source $ZSH/oh-my-zsh.sh
source $ZSH/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh


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

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# ag aliases
alias ag='ag --color --color-line-number=95 --color-path=94 --color-match=31 --hidden'
alias agi='ag -S --color --color-line-number=95 --color-path=94 --color-match=31 --hidden'
alias agit='ag -S --color --color-line-number=95 --color-path=94 --color-match=31 --hidden --ignore="test"'
alias agip='ag -S --color --color-line-number=95 --color-path=94 --color-match=31 --hidden -G ".py"'

# docker aliases
alias drma='docker rm $(docker stop $(docker ps -aq))'

# gh aliases
alias gpcf='gh pr checkout -f'

# git aliases
alias glfp="git log --first-parent --no-merges"
alias gcane="git commit --amend --no-edit"
alias gcfb="git cat-file blob"
alias grlp="git reflog --pretty=fuller"
alias grm="git fetch origin master && git reset --hard origin/master"

# hub aliases
alias hpc='hub pr checkout'
alias hpl='hub pr list'
alias hpp='hub pull-request -p'
alias hppm='hub pull-request -p -m "$(git log --format=%B -n 1)"'

# IPython for specific version of python
alias ipython2='python2 -c "import IPython; IPython.terminal.ipapp.launch_new_instance()"'

# kubectl
alias kd='kubectl describe'
alias kg='kubectl get'
alias kdeleteforce='kubectl delete --force --grace-period=0'

# random things
alias ccat='pygmentize -O style=monokai,linenos=1'
alias emacsc="emacsclient -nw -c"
alias grep='grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}'
alias svim="sudo -E vim"

# devbox
alias dbb='docker build --pull -t devbox ~/sandbox/devbox'
alias dbbl='docker build --build-arg IMAGE=foundation-devenv-local -t devbox ~/sandbox/devbox'
alias dbbv='docker build --build-arg IMAGE=$IMAGE -t devbox ~/sandbox/devbox'
alias db='docker run --rm -it -v $HOME/.tokens:$HOME/.tokens -v $HOME/.ssh:$HOME/.ssh -v $HOME/.docker:$HOME/.docker -v $HOME/.aws/credentials:$HOME/.aws/credentials -v $HOME/.zsh_history:$HOME/.zsh_history -v $HOME/bin:$HOME/bin -v /var/run/docker.sock:/var/run/docker.sock -v $PWD:$PWD --workdir $PWD -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e GITHUB_TOKEN -e REAL_HOME=$HOME -v /sys/fs/cgroup:/sys/fs/cgroup:ro devbox'

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
