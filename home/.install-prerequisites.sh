#!/bin/bash
set -ex

case "$(uname -s)" in
Darwin)
	if [ ! "$(command -v brew)" ]; then
		eval "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		eval "$(env brew shellenv)"
	fi

	brew list 1password &>/dev/null || brew install --cask 1password
	brew list 1password-cli &>/dev/null || brew install 1password-cli

	if [[ $(op account list | wc -l) -lt 1 ]]; then
		open -a '1Password'
		read -p "Loggin to 1Password and enable 1Password-CLI integration. Enter to continue..." -n 1 -r
	fi
	;;
*)
	echo "unsupported OS"
	exit 1
	;;
esac
