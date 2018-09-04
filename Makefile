# Inspired in https://raw.githubusercontent.com/pappasam/dotfiles/master/Makefile

CONFIG_DIRS_DOTFILES := $(wildcard dotfiles/.config/*)
CONFIG_DIRS_HOME := $(subst dotfiles, ~, $(CONFIG_DIRS_DOTFILES))

dotfiles: config_directories
	@#stow -t ~ -R dotfiles/
	@echo "Doing dotfiles"

config_directories: $(CONFIG_DIRS_HOME)

~/.config/%: dotfiles/.config/%
	-mkdir -p $@

.PHONY: dotfiles config_directories
