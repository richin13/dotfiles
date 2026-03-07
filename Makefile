CONFIG_DIRS_DOTFILES := $(sort $(dir $(wildcard dotfiles/.config/*/) ) )
CONFIG_DIRS_HOME := $(subst dotfiles, ~, $(CONFIG_DIRS_DOTFILES))

.PHONY: help
help: ## Print each target and its associated help message
	@grep -E '^[%a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


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

.PHONY: skill
skill: ## Bootstrap a new shared agent skill
	./scripts/bootstrap-skill new

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
tools: asdf-vim vim-packager ## Install required tools

################################################################################
# Optionals
################################################################################
.PHONY: tpm
tpm: ## Install tpm tmux plugin manager
	git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
	@echo "Remember to execute <prefix>I inside tmux to install your plugins"

.PHONY: zoxide
zoxide: ## Install zoxide
	curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
