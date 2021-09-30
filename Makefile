# Inspired in https://raw.githubusercontent.com/pappasam/dotfiles/master/Makefile
.EXPORT_ALL_VARIABLES:
ZSH_CUSTOM=./dotfiles/.oh-my-zsh/custom

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
.PHONY: zplug
zplug: ## Install zplug
	curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh

.PHONY: asdf-vm
asdf-vm: ## Install asdf-vm
	git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.4 --depth=1

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
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
	@echo "Remember to execute <prefix>I inside tmux to install your plugins"

.PHONY: poetry
poetry: ## Install Poetry
	curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python - --no-modify-path

.PHONY: optionals
optionals: tpm poetry ## Install optional tools
