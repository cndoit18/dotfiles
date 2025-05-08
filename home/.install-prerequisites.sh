#!/bin/bash
set -e

case "$(uname -s)" in
Darwin)
	if [ ! "$(command -v brew)" ]; then
		eval "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		eval "$(env brew shellenv)"
	fi

	if [ ! "$(command -v op)" ]; then
		brew install --cask 1password
		brew install 1password-cli
		if [[ $(op account list | wc -l) -lt 1 ]]; then
			open -a '1Password'
			read -p "Loggin to 1Password and enable 1Password-CLI integration. Enter to continue..." -n 1 -r
		fi
	fi
	;;
Linux)
	if [ ! "$(command -v op)" ]; then
		ARCH=$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/') &&
			wget "https://cache.agilebits.com/dist/1P/op2/pkg/v2.30.3/op_linux_${ARCH}_v2.30.3.zip" -O op.zip &&
			unzip -d op op.zip &&
			sudo mv op/op /usr/local/bin/ &&
			rm -r op.zip op &&
			sudo groupadd -f onepassword-cli &&
			sudo chgrp onepassword-cli /usr/local/bin/op &&
			sudo chmod g+s /usr/local/bin/op
	fi

	if [ ! "$(command -v zsh)" ]; then
		sudo apt-get update
		sudo apt-get install zsh
	fi

	if [ "${SHELL}" != "$(which zsh)" ]; then
		sudo usermod -s "$(which zsh)" "$(whoami)"
	fi
	;;
*)
	echo "unsupported OS"
	exit 1
	;;
esac
