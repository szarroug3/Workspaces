ARG IMAGE=657273346644.dkr.ecr.us-west-2.amazonaws.com/hpe-hcss/foundation-devenv:latest
FROM ${IMAGE}

RUN sudo apt upgrade -y
RUN sudo apt install -y emacs fortune locate rxvt-unicode silversearcher-ag tmux zsh

RUN sudo update-alternatives --set x-terminal-emulator /usr/bin/urxvt

COPY .gitignore $HOME
COPY .gitconfig $HOME
COPY .tmux.conf $HOME

COPY terminfo-24bit.src $HOME
RUN tic -x -o $HOME/.terminfo terminfo-24bit.src
RUN rm terminfo-24bit.src

COPY .emacs .
ADD .emacs.d .emacs.d

RUN sudo updatedb

RUN sudo chsh -s $(which zsh) $(whoami)
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN rm -rf ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
COPY .zprofile $HOME
COPY .zshrc $HOME

ENV TERM xterm-256color
ENV LANG=C.UTF-8
ENV LC_CTYPE="C.UTF-8"
ENV LC_NUMERIC="C.UTF-8"
ENV LC_TIME="C.UTF-8"
ENV LC_COLLATE="C.UTF-8"
ENV LC_MONETARY="C.UTF-8"
ENV LC_MESSAGES="C.UTF-8"
ENV LC_PAPER="C.UTF-8"
ENV LC_NAME="C.UTF-8"
ENV LC_ADDRESS="C.UTF-8"
ENV LC_TELEPHONE="C.UTF-8"
ENV LC_MEASUREMENT="C.UTF-8"
ENV LC_IDENTIFICATION="C.UTF-8"

# REMOVE WHEN TERRAFORM GETS ADDED TO FOUNDATION-DEVENV
RUN sudo apt install -y software-properties-common
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
RUN sudo add-apt-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
RUN sudo apt update -y
RUN sudo apt install -y terraform
# STOP REMOVING HERE

CMD stty erase \^H && tmux
