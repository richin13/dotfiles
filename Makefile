# Inspired in https://raw.githubusercontent.com/pappasam/dotfiles/master/Makefile

CONFIG_DIRS_DOTFILES := $(wildcard dotfiles/.config/*)
CONFIG_DIRS_HOME := $(subst dotfiles, ~, $(CONFIG_DIRS_DOTFILES))

.PHONY: dotfiles
dotfiles: config_directories
	stow -t ~ -R dotfiles/

.PHONY: config_directories
config_directories: $(CONFIG_DIRS_HOME)

~/.config/%: dotfiles/.config/%
	-mkdir -p $@

