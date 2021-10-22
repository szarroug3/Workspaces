export DESPINA=/home/ubuntu/work/git/hpe/cluster-despina/kubeconfig.yaml
export NESO=/home/ubuntu/work/git/hpe/cluster-neso/kubeconfig.yaml
export OBERON=/home/ubuntu/work/git/hpe/cluster-oberon/kubeconfig.yaml

export TERM=xterm-24bits

export EDITOR="emacsclient -t"
export VISUAL="emacsclient -t"

. "$HOME/.cargo/env"
export PATH=/usr/local/bin:$PATH
export PATH=$PATH:/usr/local/go/bin
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/bin:$PATH

source ~/.tokens
