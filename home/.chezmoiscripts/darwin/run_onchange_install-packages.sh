#!/bin/sh

if [ ! "$(command -v brew)" ]; then
	eval "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	eval "$(/opt/homebrew/bin/brew shellenv)"

fi

brew bundle --file=/dev/stdin <<EOF

brew "neovim"

EOF
