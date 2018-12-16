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

POETRY_BINS="$HOME/.poetry/bin"
if [ -d "$POETRY_BINS" ]; then
  path_ladd "$POETRY_BINS"
fi

# EXPORT THE FINAL, MODIFIED PATH
export PATH

# }}}

######################################################
#                                                    #
#                 Session setup                      #
#                                                    #
######################################################
# ZSH setup -------------------------------------{{{
function chpwd() {
  if command -v colorls 2>&1 > /dev/null;then
    colorls
  else
    ls
  fi
}
# }}}
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
  git git-flow pylint python web-search
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
# Creates a directory and cd into it
function mkcd() { mkdir -p "$@" && cd "$_" }

function searchalias() { alias | grep "${*}" }

function ignore() { curl -L -s "https://gitignore.io/api/$@" ;}

function wttr() {
  curl "wttr.in/?0"
}

# Edit the file manipulated in the last command
function manipulate_last_file() {
  cmd="vim" # Default is vim

  if [[ $# -ge 1 ]]; then
    cmd=$@
  fi
  file=$(fc -ln -1 | cut -d " " -f 2-)

  if [[ $file =~ "[\w\d\./]" ]]; then
    eval "$cmd $file"
  else
    echo "$file is not a file"
  fi
}

function clubhouse() {
  echo -e "## Goal\n## Reason\n## Acceptance Criteria" | xsel -ib
}

function exclude() {
  if [ ${#} -ne 1 ]; then
    red "Missing expression"
    bold "Usage: $0 <expression>"
    return 1
  fi

  [[ -f .git/info/exclude ]] && echo $1 >> .git/info/exclude
}

function de4k() {
  if [[ $# -ne 1 ]]; then
    red "Need to specifiy a video filename"
    bold "Usage: $0 <video>"
    return 1
  fi

  video=$1

  ffmpeg -i $video -c:v libx264 -vf scale=1920x1080 -c:a copy "1080-$video"
}

# }}}
# Aliases --- {{{
# Check whether NeoVIM is installed and alias it to vim
[[ -x "$(command -v nvim)" ]] && alias vim="nvim -p"

alias cp="cp -iv"
alias mv="mv -iv"
alias rm="rm -Iv"
alias mkdir="mkdir -v"
alias rf="rm -rf"
alias rmdir="rm -rf"
alias sudo="sudo "
alias o=xdg-open
alias itree="tree -I '__pycache__|venv|node_modules'"
alias srm="shred -n 100 -z -u"
alias ff="grep -rnw . -e"

# Execute the previous command
alias jk="fc -e -"

# APT aliases
alias apti="sudo apt install -y"
alias apts="apt search"
alias aptu="sudo apt remove -y"
alias aptup="sudo apt update && sudo apt upgrade -y"

# Pacman aliases
alias pac="pacman"
alias pacs="sudo pacman -S"
alias pacss="pacman -Ss"
alias pacsy="pacman -Sy"
alias pacsyu="pacman -Syu"
alias pacr="sudo pacman -R"
alias pacrs="sudo pacman -Rs"

# Js ecosystem aliases
alias yadd="yarn add"
alias yrm="yarn remove"
alias cra="create-react-app"

############# Utils ###############
alias so="clear && source ~/.zshrc"
alias cpwd="pwd | xclip"
alias ppwd="cd \`xclip -o\`"

# Join a Zoom Meeting
# (export defined in `sensitive` file)
alias jm="o $ZOOM_MEETING"
alias kgaws="o $AWS_CONSOLE"

alias el="manipulate_last_file"

# I surf these alot :D
alias sam-dotfiles="o https://github.com/pappasam/dotfiles/tree/master/dotfiles"
###################################
# }}}
# Extra scripts: ----------------- {{{
include "$HOME/.zsh-scripts/python.zsh"
# }}}
# Extra swag: ----------------- {{{
fortune ~/.fortunes/zen | cowsay
# }}}
# Google Cloud SDK: ----------------- {{{
# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi
# }}}
