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
	stow -t ~ -R dotfiles/

.PHONY: config_directories
config_directories: $(CONFIG_DIRS_HOME) ## Create the directories in the HOME folder

~/.config/%: dotfiles/.config/%
	-mkdir -p $@

################################################################################
# Theming and plugins
################################################################################
.PHONY: zplug
zplug: ## Install zplug
	curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh

.PHONY: oh-my-zsh-swag
oh-my-zsh-swag: ## Install the spaceship-prompt theme
	-sh -c "$$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
	-git clone https://github.com/denysdovhan/spaceship-prompt.git "$$ZSH_CUSTOM/themes/spaceship-prompt"
	-ln -fs "./spaceship-prompt/spaceship.zsh-theme" "$$ZSH_CUSTOM/themes/spaceship.zsh-theme"

.PHONY: tmux-swag
tmux-swag: ## Install tpm tmux plugin manager
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
	@echo "Remember to execute <prefix>I inside tmux to install your plugins"

################################################################################
# Tools
################################################################################
.PHONY: pyenv
pyenv: ## Install pyenv and virtualenv plugin
	-git clone https://github.com/pyenv/pyenv.git ~/.pyenv
	-git clone https://github.com/pyenv/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv

.PHONY: poetry
poetry: ## Install Poetry
	curl -sSL https://raw.githubusercontent.com/sdispater/poetry/master/get-poetry.py | python

################################################################################
# Apps
################################################################################
.PHONY: kitty
kitty:
	curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
	-ln -s ~/.local/kitty.app/bin/kitty ~/bin/
	@echo "`kitty` executable is now in '$$HOME/bin'. Make sure it's in your PATH"
