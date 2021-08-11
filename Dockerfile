FROM 657273346644.dkr.ecr.us-west-2.amazonaws.com/hpe-hcss/foundation-devenv

RUN sudo apt upgrade -y
RUN sudo apt install -y emacs tmux zsh fortune rxvt-unicode locate
RUN sudo apt install -y systemctl
RUN sudo apt autoremove -y

RUN sudo update-alternatives --set x-terminal-emulator /usr/bin/urxvt

COPY .gitignore /root/
COPY .gitconfig /root/
COPY .tmux.conf /root/

COPY terminfo-24bit.src .
RUN tic -x -o /root/.terminfo terminfo-24bit.src
RUN rm terminfo-24bit.src

COPY .emacs /root/
ADD .emacs.d /root/.emacs.d
COPY emacs.service  /usr/lib/systemd/user/emacs.service

RUN sudo updatedb

RUN sudo chsh -s $(which zsh) $(whoami)
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN rm -rf ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
COPY .zprofile /root/
COPY .zshrc /root/

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

CMD systemctl --user enable --now emacs && tmux
