# Based on @pappasam's dotfiles
#     https://github.com/pappasam/dotfiles
#


######################################################
#                                                    #
#                 Environment setup                  #
#                                                    #
######################################################
# Functions ------------------------------------------------------- {{{

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
# Exported variables: General ------------------------------------- {{{

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

export EDITOR=nvim
export SHELL=zsh

export GDK_SCALE=0

# History: How many lines of history to keep in memory
export HISTSIZE=5000

# XDG Base directory
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share

# }}}
# Path appends + Misc env setup ----------------------------------- {{{

ASDF_ROOT="$HOME/.asdf"
if [ -d "$ASDF_ROOT" ]; then
  export ASDF_ROOT
  . "$ASDF_ROOT/asdf.sh"
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

CARGO_BINS="$HOME/.cargo/bin"
if [ -d "$CARGO_BINS" ]; then
  path_ladd "$CARGO_BINS"
fi

COMPOSER_BINS="$HOME/.config/composer/vendor/bin"
if [ -d "$COMPOSER_BINS" ]; then
  path_ladd "$COMPOSER_BINS"
fi

# EXPORT THE FINAL, MODIFIED PATH
export PATH

# Remove duplicates in $PATH
# https://til.hashrocket.com/posts/7evpdebn7g-remove-duplicates-in-zsh-path
typeset -aU path

# The next line updates PATH for the Google Cloud SDK.
# if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
# if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi
# }}}
# Colors ---------------------------------------------------------- {{{
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
NC='\033[0m'

function bold() { echo -e "${BOLD}$@${NC}" }
function red() { echo -e "${RED}$@${NC}" }
function green() { echo -e "${GREEN}$@${NC}" }
function yellow() { echo -e "${YELLOW}$@${NC}" }

# }}}


######################################################
#                                                    #
#                 Session setup                      #
#                                                    #
######################################################
# Plugins --------------------------------------------------------- {{{
source ~/.zplug/init.zsh

# Old Oh-my-zsh setup
# zplug "plugins/magic-enter", from:oh-my-zsh
zplug "plugins/git", from:oh-my-zsh
zplug "plugins/git-flow", from:oh-my-zsh
zplug "plugins/pylint", from:oh-my-zsh
zplug "plugins/python", from:oh-my-zsh
zplug "plugins/web-search", from:oh-my-zsh
zplug "plugins/docker-compose", from:oh-my-zsh

zplug "lib/completion", from:oh-my-zsh
zplug "lib/compfix", from:oh-my-zsh
zplug "lib/directories", from:oh-my-zsh
zplug "lib/git", from:oh-my-zsh
zplug "lib/history", from:oh-my-zsh
zplug "lib/key-bindings", from:oh-my-zsh

zplug "richin13/0i0.zsh-theme", use:0i0.zsh-theme, as:theme

# Cool stuff
zplug "paulirish/git-open", as:plugin
zplug "zdharma/fast-syntax-highlighting", as:plugin

# zplug "supercrabtree/k"

# Final thoughts
if ! zplug check; then
  zplug install
fi

zplug load

# }}}
# ZSH setup ------------------------------------------------------- {{{
function chpwd() {
  local owner=$(stat -L -c "%U" $PWD)

  if [[ $USER = $owner ]]; then
    ls --color=auto --group-directories-first --classify
  fi
}

setopt auto_cd

# Completion settings
# zstyle ':completion:*' ignored-patterns '__pycache__' '*?.pyc' 'poetry.lock' 'yarn.lock' 'node_modules' 'pip-wheel-metadata' '*.egg-info'
zstyle ":completion:*" ignored-patterns "(*/)#(__pycache__|*.pyc|node_modules|.git|*.egg-info)"

bindkey '^P' up-line-or-beginning-search
bindkey '^N' down-line-or-beginning-search
# }}}
# Exports --------------------------------------------------------- {{{
export MANPAGER="nvim -c 'set ft=man' -"
export DOCS_DIRECTORY=$HOME/.config/docs

# MANPATH: add asdf man pages to my man path
if [ -x "$(command -v fd)" ]; then
  for value in $(fd man1 ~/.asdf/installs --type directory | sort -hr); do
    MANPATH="$MANPATH:$(dirname $value)"
  done
  export MANPATH
fi

export DOTFILES="$HOME/dotfiles"
# }}}
# Key Bindings ---------------------------------------------------- {{{

# Use C-K to clear the screen
bindkey '^K' clear-screen

# }}}
# Functions ------------------------------------------------------- {{{
# Creates a directory and cd into it
function mkcd() { mkdir -p "$@" && cd "$_" }

function sa() { alias | grep "${*}" }

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

function rndpw() {
  </dev/urandom tr -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~' | head -c 13  ; echo
}

function kplr() {
  cd "$KEPLER_FOLDER/$1"
}

_kplr() {
  local state

  _arguments \
    '1: :->dir'

  case $state in
    (dir) _arguments '1:projects:($(ls $KEPLER_FOLDER))' ;;
  esac
}

compdef _kplr kplr

function rocket() {
  cd "$ROCKET_FOLDER/$1"
}

_rocket() {
  local state

  _arguments \
    '1: :->dir'

  case $state in
    (dir) _arguments '1:projects:($(ls $ROCKET_FOLDER))' ;;
  esac
}

compdef _rocket rocket

function cloneme() {
  if [[ $# -ne 1 ]]; then
    red "Need to specify a repo to clone."
    return 1
  fi

  gcl "git@github.com:richin13/$1.git"
}

function docs() {
  if [[ $# -lt 1 ]]; then
    bold "Available documentations:"
    ls $DOCS_DIRECTORY
  else
    pushd $DOCS_DIRECTORY/$1 > /dev/null
    shift
    python -m http.server $@
    popd > /dev/null
  fi
}

_docs() {
  local state

  _arguments \
    '1: :->dir'

  case $state in
    (dir) _arguments '1:documentations:($(ls $DOCS_DIRECTORY))' ;;
  esac
}

compdef _docs docs

function review-pr() {
  if [[ $# -lt 1 ]]; then
    red "Invalid use: Specify the PR #"
    return 1
  fi
  local pr=$1
  local branch=${2:-"pr-$pr"}

  git fetch origin pull/$1/head:$branch

  if [[ $? -eq 0 ]]; then
    bold "You can review the changes by typing:"
    green "git checkout $branch"
  fi
}


function active_input_port() {
  pactl list sources | grep 'Active Port:' | cut -d ':' -f 2 | xargs
}

function check_input_port() {
  local SOURCE="alsa_input.pci-0000_00_1f.3.analog-stereo"
  local DESIRED_INPUT="analog-input-headset-mic"
  local current=$(active_input_port)
  if [ "$current" != "$DESIRED_INPUT" ]; then
    echo "Changing active port from '$current' to '$DESIRED_INPUT'"
    pactl set-source-port $SOURCE $DESIRED_INPUT

    if [ $? -ne 0 ]; then
      echo "Failed to configure the source port: $DESIRED_INPUT. Maybe not connected?"
      return 1
    fi
  fi
}

function zoomy() {
  check_input_port
  xdg-open "zoommtg://zoom.us/join?action=join&confno=$1" > /dev/null 2>&1
}

# upgrade relevant local systems
function upgrade() {
  sudo apt update
  sudo apt upgrade -y
  sudo apt autoremove -y
  pushd .
  cd ~/dotfiles
  git pull
  popd
  asdf uninstall neovim nightly
  asdf install neovim nightly
  nvim -c 'PlugUpdate'
}

function dbrestore() {
  local backupfile=${1}
  local db_user=${2:-$DB_USER}
  local db_name=${3:-$DB_NAME}

  if [ -z "$backupfile" ]; then
    echo "Need to pass a backup file"
    echo "Usage: dbrestore <backupfile> [db-user] [db-name]"
    return 1
  fi

  pg_restore -U "$db_user" -d "$db_name" -a "$backupfile"
}

# }}}
# Aliases --------------------------------------------------------- {{{
# Check whether NeoVIM is installed and alias it to vim
[[ -x "$(command -v nvim)" ]] && alias vim="nvim"

[[ -x "$(command -v bat)" ]] && alias cat="bat --style='numbers,changes'"

alias ls="ls --color=auto --group-directories-first --classify"
alias ks="ls --color=auto --group-directories-first --classify"
alias cp="cp -iv"
alias mv="mv -iv"
alias rm="rm -Iv"
alias mkdir="mkdir -v"
alias rf="rm -rf"
alias rmdir="rm -rf"
alias sudo="sudo "
alias o=xdg-open
alias itree="tree --dirsfirst -I '__pycache__|venv|node_modules'"
alias srm="shred -n 100 -z -u"
alias ff="grep -rnw . -e"
alias m="make"

if [ -d "$DOTFILES" ]; then
  alias dotfiles="cd $DOTFILES"
  alias vimrc="nvim $DOTFILES/dotfiles/.config/nvim/init.vim"
  alias zshrc="nvim $DOTFILES/dotfiles/.zshrc"
else
  echo "[WARNING] ~/dotfiles does not exist"
  alias dotfiles="echo \"[ERROR] No dotfiles in this system :(\""
  alias vimrc="echo \"[ERROR] No dotfiles in this system :(\""
  alias zshrc="echo \"[ERROR] No dotfiles in this system :(\""
fi

# Execute the previous command
alias jk="fc -e -"

# APT aliases
alias apti="sudo apt install -y"
alias apts="apt search"
alias aptu="sudo apt remove -y"
alias aptup="sudo apt update && sudo apt upgrade -y && sudo apt autoremove"

# Pacman aliases
alias pac="pacman"
alias pacss="pacman -Ss"
alias pacs="sudo pacman -S"
alias pacsy="sudo pacman -Syyy"
alias pacsu="sudo pacman -Su"
alias pacr="sudo pacman -R"
alias pacrs="sudo pacman -Rs"

# Js ecosystem aliases
alias yins="yarn install"
alias yadd="yarn add"
alias yrm="yarn remove"
alias cra="create-react-app"

############# Utils ###############
alias so="clear && exec $SHELL"
alias cpwd="pwd | xclip"
alias ppwd="cd \`xclip -o\`"

alias kgaws="o $AWS_CONSOLE"

alias el="manipulate_last_file"

# I surf these alot :D
alias sam-dotfiles="o https://github.com/pappasam/dotfiles/tree/master/dotfiles"
###################################
# }}}
# Autocompletion -------------------------------------------------- {{{

if [ -d "$ASDF_ROOT" ]; then
  . "$ASDF_ROOT/completions/asdf.bash"
fi
# }}}
# Extra scripts: -------------------------------------------------- {{{
include "$HOME/.zsh-scripts/python.zsh"
include "$HOME/.zsh-scripts/git.zsh"
include "$HOME/.zsh-scripts/docker.zsh"
include "$HOME/.zsh-scripts/ls.zsh"

# Sensitive information includes
include ~/.bash/sensitive
# }}}
# Extra swag: ----------------------------------------------------- {{{
fortune ~/.fortunes/zen | cowsay
# }}}
