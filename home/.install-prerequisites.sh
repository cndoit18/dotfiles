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
Linux)
	if [ ! "$(command -v op)" ]; then
		curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
		echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | sudo tee /etc/apt/sources.list.d/1password.list
		sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
		curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
		sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
		curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
		sudo apt update && sudo apt install -y 1password-cli
	fi
	;;
*)
	echo "unsupported OS"
	exit 1
	;;
esac
