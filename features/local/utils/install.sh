i#! /usr/bin/env bash
set -e

echo "Installing ripgrep and fd"
sudo DEBIAN_FRONTEND=noninteractive apt update
sudo DEBIAN_FRONTEND=noninteractive apt install -y ripgrep fd-find

echo "Installing tmux"
sudo DEBIAN_FRONTEND=noninteractive apt install -y tmux
echo "unset TMUX" >> /home/coder/.bashrc
git clone https://github.com/samoshkin/tmux-config.git /home/coder/tmux-config
tee /home/coder/tmux-config/tmux/tmux-conf.patch <<EOF
18c18
< set -g prefix C-a
---
> set -g prefix M-q
41,42c41,42
< unbind }    # swap-pane -D
< unbind {    # swap-pane -U
---
> unbind \}    # swap-pane -D
> unbind \{    # swap-pane -U
98c98
< bind \ if '[ #{pane_index} -eq 1 ]' \
---
> bind \\ if '[ #{pane_index} -eq 1 ]' \
EOF
patch /home/coder/tmux-config/tmux/tmux.conf /home/coder/tmux-config/tmux/tmux-conf.patch
./home/coder/tmux-config/install.sh

echo "Installing clangd"
sudo DEBIAN_FRONTEND=noninteractive apt install -y clangd-12
sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-12 100

#echo "Updating /home/coder/.gitconfig"
#tee /home/coder/update_gitconfig.sh > /dev/null \
#<<EOF
##!/bin/sh
#set -e
#git config --global user.name "Shruti Shivakumar"
#git config --global user.email "shruti.shivakumar@gmail.com"
#git config --global user.signingkey "/home/coder/.ssh/github-signing.pub"
#git config --global gpg.format ssh
#git config --global gpg.ssh.allowedSignersFile "/home/coder/.ssh/allowed_signers"
#git config --global commit.gpgsign true
#git config --global tag.gpgsign true
#git config --global merge.gpgsign true
#EOF
#./home/coder/update_gitconfig.sh
