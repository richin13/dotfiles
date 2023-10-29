CONFIG_DIRS_DOTFILES := $(sort $(dir $(wildcard dotfiles/.config/*/) ) )
CONFIG_DIRS_HOME := $(subst dotfiles, ~, $(CONFIG_DIRS_DOTFILES))

.PHONY: help
help: ## This help message
	@echo -e "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[36m\1\\x1b[m:\2/' | column -c2 -t -s :)"


################################################################################
# Dotfiles
################################################################################
.PHONY: dotfiles
dotfiles: config_directories ## Create the symlinks to the dotfiles
	xstow -t ~ -R dotfiles/

.PHONY: config_directories
config_directories: $(CONFIG_DIRS_HOME) ## Create the directories in the HOME folder

~/.config/%: dotfiles/.config/%
	-mkdir -p $@

################################################################################
# Tools
################################################################################
.PHONY: zinit
zinit: ## Install zinit
	mkdir -p "$$(dirname $$ZINIT_HOME)"
	git clone https://github.com/zdharma-continuum/zinit.git "$$ZINIT_HOME"

.PHONY: asdf-vm
asdf-vm: ## Install asdf-vm
	git clone https://github.com/asdf-vm/asdf.git ~/.config/asdf --branch v0.10.2 --depth=1

.PHONY: vim-packager
vim-packager: ## Install vim-packager
	git clone https://github.com/kristijanhusak/vim-packager ~/.config/nvim/pack/packager/opt/vim-packager

.PHONY: tools
tools: zplug asdf-vim vim-packager ## Install required tools

################################################################################
# Optionals
################################################################################
.PHONY: tpm
tpm: ## Install tpm tmux plugin manager
	git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
	@echo "Remember to execute <prefix>I inside tmux to install your plugins"

.PHONY: rust-tools
rust-tools: ## Install rust tools
	cargo install lsd ripgrep fd-find bat git-delta vivid
