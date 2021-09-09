ARG IMAGE=657273346644.dkr.ecr.us-west-2.amazonaws.com/hpe-hcss/foundation-devenv:latest
FROM ${IMAGE}

RUN yes | sudo unminimize
RUN sudo apt upgrade -y
RUN sudo apt install -y emacs fortune locate man-db rxvt-unicode silversearcher-ag tmux zsh

RUN sudo update-alternatives --set x-terminal-emulator /usr/bin/urxvt

COPY requirements.txt .
RUN pip2 install -r requirements.txt
RUN pip3 install -r requirements.txt
RUN rm requirements.txt

COPY .gitignore $HOME
COPY .gitconfig $HOME
COPY .tmux.conf $HOME

COPY terminfo-24bit.src $HOME
RUN tic -x -o $HOME/.terminfo terminfo-24bit.src
RUN rm terminfo-24bit.src

COPY .emacs .
ADD .emacs.d .emacs.d
COPY emacs.service /usr/lib/systemd/user/emacs.service
RUN sudo wget https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl.py -O /usr/local/bin/systemctl
RUN sudo chmod +x /usr/local/bin/systemctl

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

CMD systemctl --user enable --now emacs && stty erase \^H && tmux
