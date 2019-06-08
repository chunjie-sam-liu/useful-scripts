#!/usr/bin/env bash

# change zsh
chsh -s $(which zsh)

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# add theme powerlevel9k
wget https://gist.githubusercontent.com/chunjie-sam-liu/976bd637294d5cc5dc92f1c6456624ad/raw/da3c9d89915bf6b54a2e392471cfb75776987dcd/.zsh

git clone git@gist.github.com:976bd637294d5cc5dc92f1c6456624ad.git ~
exec $SHELL