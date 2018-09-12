# Based on @pappasam's dotfiles
#     https://github.com/pappasam/dotfiles
#

######################################################
#                                                    #
#                 Environment setup                  #
#                                                    #
######################################################
# Functions --- {{{

path_ladd() {
  # Takes 1 argument and adds it to the beginning of the PATH
  if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
    PATH="$1${PATH:+":$PATH"}"
  fi
}

path_radd() {
  # Takes 1 argument and adds it to the end of the PATH
  if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
    PATH="${PATH:+"$PATH:"}$1"
  fi
}

include () {
  [[ -f "$1" ]] && source "$1"
}

# }}}
# Exported variable: LS_COLORS --- {{{

# Colors when using the LS command
# NOTE:
# Color codes:
#   0   Default Colour
#   1   Bold
#   4   Underlined
#   5   Flashing Text
#   7   Reverse Field
#   31  Red
#   32  Green
#   33  Orange
#   34  Blue
#   35  Purple
#   36  Cyan
#   37  Grey
#   40  Black Background
#   41  Red Background
#   42  Green Background
#   43  Orange Background
#   44  Blue Background
#   45  Purple Background
#   46  Cyan Background
#   47  Grey Background
#   90  Dark Grey
#   91  Light Red
#   92  Light Green
#   93  Yellow
#   94  Light Blue
#   95  Light Purple
#   96  Turquoise
#   100 Dark Grey Background
#   101 Light Red Background
#   102 Light Green Background
#   103 Yellow Background
#   104 Light Blue Background
#   105 Light Purple Background
#   106 Turquoise Background
# Parameters
#   di 	Directory
LS_COLORS="di=1;34:"
#   fi 	File
LS_COLORS+="fi=0:"
#   ln 	Symbolic Link
LS_COLORS+="ln=1;36:"
#   pi 	Fifo file
LS_COLORS+="pi=5:"
#   so 	Socket file
LS_COLORS+="so=5:"
#   bd 	Block (buffered) special file
LS_COLORS+="bd=5:"
#   cd 	Character (unbuffered) special file
LS_COLORS+="cd=5:"
#   or 	Symbolic Link pointing to a non-existent file (orphan)
LS_COLORS+="or=31:"
#   mi 	Non-existent file pointed to by a symbolic link (visible with ls -l)
LS_COLORS+="mi=0:"
#   ex 	File which is executable (ie. has 'x' set in permissions).
LS_COLORS+="ex=1;92:"
# additional file types as-defined by their extension
LS_COLORS+="*.rpm=90"

# Finally, export LS_COLORS
export LS_COLORS

# }}}
# Exported variables: General --- {{{

# React
export REACT_EDITOR='less'

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Configure less (de-initialization clears the screen)
# Gives nicely-colored man pages
export PAGER=less
export LESS='--ignore-case --status-column --LONG-PROMPT --RAW-CONTROL-CHARS --HILITE-UNREAD --tabs=4 --clear-screen'
export LESS_TERMCAP_mb=$'\E[1;31m'     # begin bold
export LESS_TERMCAP_md=$'\E[1;36m'     # begin blink
export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\E[01;44;33m' # begin reverse video
export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

# tmuxinator
export EDITOR=vim
export SHELL=bash

# environment variable controlling difference between HI-DPI / Non HI_DPI
# turn off because it messes up my pdf tooling
export GDK_SCALE=0

# History: How many lines of history to keep in memory
export HISTSIZE=5000

# }}}
# Path appends + Misc env setup --- {{{

PYENV_ROOT="$HOME/.pyenv"
if [ -d "$PYENV_ROOT" ]; then
  export PYENV_ROOT
  path_radd "$PYENV_ROOT/bin"
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi

NODENV_ROOT="$HOME/.nodenv"
if [ -d "$NODENV_ROOT" ]; then
  export NODENV_ROOT
  path_radd "$NODENV_ROOT/bin"
  eval "$(nodenv init -)"
fi

HOME_BIN="$HOME/bin"
if [ -d "$HOME_BIN" ]; then
  path_ladd "$HOME_BIN"
fi

STACK_LOC="$HOME/.local/bin"
if [ -d "$STACK_LOC" ]; then
  path_ladd "$STACK_LOC"
fi

YARN_BINS="$HOME/.yarn/bin"
if [ -d "$YARN_BINS" ]; then
  path_ladd "$YARN_BINS"
fi

# EXPORT THE FINAL, MODIFIED PATH
export PATH

# }}}

######################################################
#                                                    #
#                 Session setup                      #
#                                                    #
######################################################
# Colors --- {{{
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
NC='\033[0m'

function bold() { echo -e "${BOLD}$@${NC}" }
function red() { echo -e "${RED}$@${NC}" }
function green() { echo -e "${GREEN}$@${NC}" }
function yellow() { echo -e "${YELLOW}$@${NC}" }
# function green_bold() { bold $(green $@) }

# }}}
# Oh My ZSH setup --- {{{
export ZSH="/home/$USER/.oh-my-zsh"

SPACESHIP_PROMPT_ORDER=(
  dir
  host
  git
  package
  node
  docker
  aws
  pyenv
  exec_time
  line_sep
  vi_mode
  jobs
  exit_code
  char
)
ZSH_THEME="spaceship"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Oh-my-zsh plugins
plugins=(
  git git-flow pylint python
)

source $ZSH/oh-my-zsh.sh
# }}}
# Sensitive information includes --- {{{
include ~/.bash/sensitive
# }}}
# Exports ------------ {{{
if [[ $ZSH_THEME -eq "spaceship" ]]; then
  export VIRTUAL_ENV_DISABLE_PROMPT=1
fi
# }}}
# Functions --- {{{
#
# Creates a directory and cd into it
function mkcd() { mkdir -p "$@" && cd "$_" }

function searchalias() { alias | grep "${*}" }

# Enable Pyenv version in the current directory
function epenv() { echo "${*}" > .python-version > /dev/null 2>&1 }

function ignore() { curl -L -s "https://gitignore.io/api/$@" ;}

function mypy_ini() {
  echo -e "[mypy]\n\n" > mypy.ini

  for pkg in $@; do
    echo -e "[mypy-$pkg.*]\nignore_missing_imports = True\n\n" >> mypy.ini
  done
}

function flask_makefile() {
  if [ ${#} -lt 1 ]; then
    echo -e "[${RED}ERROR${NC}]: Missing required paramater <application-package>"
    echo -e "Usage: flask_makefile <application-package>"
    return 1
  fi
  pkg=$1

  cat > Makefile << EOF
help: ## Show this help.
	  @fgrep -h "##" \$(MAKEFILE_LIST) | \\
		fgrep -v fgrep | \\
		    sed -e 's/\\\$\$//' | \\
		    sed -e 's/##//'

.PHONY: build-container
build-container: lint test ## Build the application container
	docker build -t basic-backend .

.PHONY: deploy-local
deploy-local: build-container ## Run the application container
	docker run -d -p 4000:80 basic-backend

.PHONY: run
run: ## Run the development server
	FLASK_APPLICATION=${pkg} FLASK_ENV=development FLASK_DEBUG=1 flask run

.PHONY: test
test: ## Run the tests
	pytest --disable-pytest-warnings

.PHONY: lint
lint: ## Lint the application's code
	pylint ${pkg}
	mypy ${pkg}

.PHONY: clean
clean: ## Deletes the python generated files and directories
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -delete
EOF
}

function fsetup() {
  if [ ${#} -lt 1 ]; then
    echo -e "[${RED}ERROR${NC}]: Missing required paramater <app-name>"
    echo -e "Usage: fsetup <app-name>"
    return 1
  elif [[ -d $@ ]]; then
    echo -e "[${RED}ERROR${NC}]: App $@ already exists"
  else
    pkg=application
    app=$@
    mkdir $app
    pushd $app > /dev/null 2>&1
    # First step is to create a new virtual environment for the project
    green "Creating virtual environment for $app"
    pyenv virtualenv "$app-venv" > /dev/null 2>&1
    epenv "$app-venv"

    green "Creating .gitignore file"
    ignore "python,vim" > .gitignore > /dev/null 2>&1

    green "Creating basic app skeleton"
    mkdir ./instance
    mkdir ./$pkg # This should configurable maybe?
    mkdir -p "./test/unit" # test is a reserved keyword
    mkdir -p "./test/integration"
    touch ./instance/config.py
    touch ./config.py
    touch ./$pkg/__init__.py
    touch "./test/__init__.py"

    green "Installing dependencies"
    $(pyenv which pip) install flask flask-sqlalchemy mixer pytest pylint mypy > /dev/null 2>&1
    $(pyenv which pip) freeze > requirements.txt 2> /dev/null

    green "Setting up Git"
    git init > /dev/null 2>&1
    git add --all > /dev/null 2>&1
    git commit -m "Initial commit" > /dev/null 2>&1

    green "Genereating default settings for tools"
    mypy_ini flask flask-sqlalchemy
    flask_makefile $pkg

    popd > /dev/null 2>&1

    echo "Done!"
    echo " \$ cd $app/"
  fi
}

# Delete the virtual env version of the current project
function dvenv() { [[ -f .python-version ]] && pyenv uninstall -f $(cat .python-version) }

# Determine whether NeoVIM should be used every time I type `vim`
function vim_who() {
  which nvim > /dev/null

  if [[ $? -eq 0 ]]; then
    nvim $@
  else
    /usr/bin/vim $@
  fi
}
# }}}
# Aliases --- {{{
alias vim=vim_who
alias o=xdg-open
alias itree="tree -I '__pycache__|venv|node_modules'"

# Execute the previous command
alias jk="fc -e -"

# APT aliases
alias apti="sudo apt install -y"
alias apts="apt search"
alias aptu="sudo apt remove -y"

# Pacman aliases
alias pac="pacman"
alias pacs="sudo pacman -S"
alias pacss="pacman -Ss"
alias pacsy="pacman -Sy"
alias pacsyu="pacman -Syu"
alias pacr="sudo pacman -R"
alias pacrs="sudo pacman -Rs"

# Pip aliases
alias pipi="pip install"
alias pipf="pip freeze"
alias pipff="pip freeze > requirements.txt"
alias pipu="pip uninstall"
alias pips="pip search"

# Js ecosystem aliases
alias yadd="yarn add"
alias yrm="yarn remove"
alias cra="create-react-app"

############# Utils ###############
alias so="source ~/.zshrc"
alias cpwd="pwd | xclip"
alias ppwd="cd \`xclip -o\`"

# Delete a folder
alias rf="rm -rf"

alias django="python manage.py"
###################################
# }}}
