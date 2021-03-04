# Zprofile
#
# Set env variables here so that they're available at the session level


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

