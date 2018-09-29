# Inspired in https://raw.githubusercontent.com/pappasam/dotfiles/master/Makefile
.EXPORT_ALL_VARIABLES:
ZSH_CUSTOM=$(HOME)/.oh-my-zsh/custom

CONFIG_DIRS_DOTFILES := $(wildcard dotfiles/.config/*)
CONFIG_DIRS_HOME := $(subst dotfiles, ~, $(CONFIG_DIRS_DOTFILES))

.PHONY: dotfiles
dotfiles: config_directories
	stow -t ~ -R dotfiles/

.PHONY: config_directories
config_directories: $(CONFIG_DIRS_HOME)

~/.config/%: dotfiles/.config/%
	-mkdir -p $@

.PHONY: oh-my-zsh-swag
oh-my-zsh-swag:
	-sh -c "$$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
	-git clone https://github.com/denysdovhan/spaceship-prompt.git "$$ZSH_CUSTOM/themes/spaceship-prompt"
	-ln -s "$$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$$ZSH_CUSTOM/themes/spaceship.zsh-theme"

.PHONY: pyenv-virtualenv
pyenv-virtualenv:
	-git clone https://github.com/pyenv/pyenv-virtualenv.git $$(pyenv root)/plugins/pyenv-virtualenv

.PHONY: tmux-swag
tmux-swag:
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
