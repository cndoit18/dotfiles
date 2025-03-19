#!/bin/sh

xcode-select --install

brew bundle --file=/dev/stdin <<EOF

brew "jesseduffield/lazygit/lazygit"
brew "neovim"
brew "fzf"
brew "eza"
brew "mercurial"

EOF
