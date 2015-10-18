#!/usr/bin/env bash

echo "******************************************"
echo "Provision script by Palli Moon"
echo "******************************************"

add-apt-repository ppa:djcj/screenfetch
apt-get update
apt-get install -y git g++ zsh sl tree keychain build-essentials

# Install zsh with oh my zsh
if [ ! -d ~vagrant/.oh-my-zsh ]; then
  git clone https://github.com/robbyrussell/oh-my-zsh.git ~vagrant/.oh-my-zsh
fi
cp ~vagrant/.oh-my-zsh/templates/zshrc.zsh-template ~vagrant/.zshrc
chown vagrant: ~vagrant/.zshrc
chsh -s /bin/zsh vagrant

# Clone dotfiles repository into user directory
git clone https://github.com/Palli-Moon/dotfiles.git ~vagrant/dotfiles

# Start keychain on ssh
echo 'eval `keychain --eval --agents ssh id_rsa id_dsa`' >> ~vagrant/.zshrc

