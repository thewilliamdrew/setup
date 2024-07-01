#!/bin/zsh
# Script to set up William's neuroimaging environment on a mac
# Heavily borrowed from https://github.com/bchcohenlab/macbook-setup
# Run this if setting up a mac from scratch


echo "This will set up your zsh environment and install a bunch of useful software on an Apple Silicon Mac"
echo "There will be two parts to this script: installing within an arm64 environment, and installing within an x86_64 environment"

if [[ `arch` = "i386" ]]; then
  echo "This is an Intel Mac or a Rosetta terminal"
  exit
else
  echo "This is an Apple Silicon mac/terminal"
  # Install Rosetta 2 if not already installed
	echo "0) Installing Rosetta2 if not already installed"
	if [ ! -f /usr/local/bin/brew ]; then
		echo "0b) Intel brew not installed, triggering Rosetta install just in case"
		/usr/sbin/softwareupdate --install-rosetta --agree-to-license
	else
		echo "0b) Found Intel brew, Rosetta must be installed"
	fi
fi

# Set up .zshenv to check for architecture, then append to PATH as appropriate
echo ""
echo "Setting up .zshenv to check for correct architecture"
echo 'if [[ "$(arch)" = "arm64" ]]; then' >> ~/.zshenv
echo '    echo "Detected ARM ..."' >> ~/.zshenv
echo '    export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshenv
echo 'elif [[ "$(arch)" = "i386" ]]; then' >> ~/.zshenv
echo '    echo "Detected x86 ..."' >> ~/.zshenv
echo '    export PATH="/usr/local/Homebrew/bin:$PATH"' >> ~/.zshenv
echo 'else' >> ~/.zshenv
echo '    echo "Unknown architecture."' >> ~/.zshenv
echo 'fi' >> ~/.zshenv
echo 'eval $(brew shellenv)' >> ~/.zshenv

# Install the Apple Silicon Homebrew if needed
echo ""
if [ -f /opt/homebrew/bin/brew ]; then
	echo "1) Found Apple Silicon brew"
	eval "$(/opt/homebrew/bin/brew shellenv)"
else
	echo "1) Installing brew"
	echo "   FYI: The Command Line Tools for Xcode step can take a looong time :-("
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Install basic utilities
echo ""
echo "2) Updating brew maintained packages then installing some basic unix utilities"
brew upgrade
brew upgrade --cask
brew install \
	bash \
	csvkit \
	dcm2niix \
	gh \
	git \
	htop \
	parallel \
	powerlevel10k \
	rclone \
	rsync \
	tig \
	tmux \
	tree \
	wget
brew install --cask \
	bettermouse \
	discord \
	docker \
	firefox \
	forklift \
	github \
	google-drive \
	horos \
	iterm2 \
	itsycal \
	lepton \
	mambaforge \
	messenger \
	microsoft-edge \
	microsoft-office \
	obsidian \
	osirix-quicklook \
	qlmarkdown \
	quicklook-csv \
	quicklook-json \
	r \
	rectangle \
	rstudio \
	shottr \
	slack \
	slicer \
	steam \
	sublime-text \
	sublime-merge \
	syntax-highlight \
	tg-pro \
	visual-studio-code \
	whatsapp \
	xquartz \
	zoom \
	zotero
qlmanage -r

echo "source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme" >> ~/.zshrc

# Initialize arm version of conda/python
cat ~/repos/thewilliamdrew/setup/apple-silicon/mambaforge_arm_init >> ~/.zshrc

. ~/.zshrc

arch --x86_64 /bin/zsh ~/repos/thewilliamdrew/setup/apple-silicon/install_software_x86_64.zsh

echo "Don't forget to install Yoink and Magnet from the App Store"
