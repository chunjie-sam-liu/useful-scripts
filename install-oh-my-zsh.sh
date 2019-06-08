#!/usr/bin/env bash

# change zsh
chsh -s $(which zsh)

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# add theme powerlevel9k

git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k

# load .zshrc
wget https://gist.githubusercontent.com/chunjie-sam-liu/976bd637294d5cc5dc92f1c6456624ad/raw/78f57d974fc805dfff44b7165c16bd6ef80c2fe1/.zshrc

exec $SHELL