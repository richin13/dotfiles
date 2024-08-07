# Bash config file
# Includes the base configuration for my shell
# While I mainly use ZSH this file will contain the base configuration
# I want to have for both shells. Zsh will source this and expand it with
# zsh-only features.
# Author: Ricardo Madriz
#
# shellcheck disable=SC2033

# Exports ----------------------------------------------------------- {{{
function path_ladd() {
  # Takes 1 argument and adds it to the beginning of the PATH
  if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
    PATH="$1${PATH:+":$PATH"}"
  fi
}

function path_radd() {
  # Takes 1 argument and adds it to the end of the PATH
  if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
    PATH="${PATH:+"$PATH:"}$1"
  fi
}

function include() {
  # shellcheck disable=SC1090
  [[ -f "$1" ]] && source "$1"
}

export SHELL=bash
export PAGER="less"
export LESS='FRSX~' #: Global less options
## History file configuration
if [ -n "$BASH_VERSION" ]; then
  export HISTFILE="$HOME/.bash_history"
  export HISTSIZE=50000
  export HISTFILESIZE=10000
fi

if [ -x "$(command -v nvim)" ]; then
  export EDITOR=nvim
  export VISUAL=nvim
  export MANPAGER='nvim +Man!' #: Use nvim as pager for man pages
else
  export EDITOR=vim
  export VISUAL=vim
fi

#: colored GCC warnings and errors (for when we install from source)
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# XDG Base directory
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share

export ZPLUG_ROOT="$XDG_CONFIG_HOME/zplug"
export ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

DISTRO=$(grep '^ID' /etc/os-release | cut -d '=' -f 2 | head -n1)
export DISTRO

export REPOS_FOLDER="$HOME/src"
export DOCS_FOLDER="$XDG_CONFIG_HOME/docs"
export FORTUNES_FOLDER="$XDG_CONFIG_HOME/fortunes"
export DOTFILES="$HOME/dotfiles"

CARGO_BINS="$HOME/.cargo/bin"
if [ -d "$CARGO_BINS" ]; then
  path_ladd "$CARGO_BINS"
fi

COMPOSER_BINS="$HOME/.config/composer/vendor/bin"
if [ -d "$COMPOSER_BINS" ]; then
  path_ladd "$COMPOSER_BINS"
fi

export ANDROID_SDK_ROOT="$HOME/.config/Android/Sdk"
export ANDROID_HOME=$ANDROID_SDK_ROOT
if [ -d "$ANDROID_SDK_ROOT" ]; then
  path_ladd "$ANDROID_SDK_ROOT/platform-tools"
  path_ladd "$ANDROID_SDK_ROOT/emulator"
  path_ladd "$ANDROID_SDK_ROOT/cmdline-tools/latest/bin"
fi

LOCAL_BINS="$HOME/.local/bin"
if [ -d "$LOCAL_BINS" ]; then
  path_ladd "$LOCAL_BINS"
fi

# EXPORT THE FINAL, MODIFIED PATH
export PATH

#: Setup mise
if [ -f "$HOME/.local/bin/mise" ] && [ -n "$BASH_VERSION" ]; then
  eval "$(~/.local/bin/mise activate bash)"
fi

[[ -x "$(command -v vivid)" ]] && export LS_COLORS="$(vivid generate dracula)"

if [ -x "$(command -v zoxide)" ]; then
  if [ -n "$BASH_VERSION" ]; then
    eval "$(zoxide init --cmd cd bash)"
  fi
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
NC='\033[0m'

function bold() {
  echo -e "${BOLD}$*${NC}"
}
function red() {
  echo -e "${RED}$*${NC}"
}
function green() {
  echo -e "${GREEN}$*${NC}"
}
function yellow() {
  echo -e "${YELLOW}$*${NC}"
}

# If on arch linux, setup the SSH_AUTH_SOCK and run ssh-add
if [ "$DISTRO" = "arch" ]; then
  export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
  ssh-add >/dev/null 2>&1
fi

export DEFAULT_PYTHON_VENV_DIR=.venv
export DEFAULT_PYTHON_PACKAGES=(pip ipython ruff)

# }}}
# Functions --------------------------------------------------------- {{{
function mkcd() { #: Combine mkdir and cd
  mkdir -p "$@" && cd "$_" || return 1
}

function sa() { #: Search aliases
  alias | grep "${*}"
}

function ignore() { #: Generate a gitignore file
  curl -L -s "https://gitignore.io/api/$*"
}

function wttr() { #: Check the weather
  if [[ $# -ge 1 ]]; then
    curl "wttr.in/$1?format=1"
    return
  fi
  curl "wttr.in/${WTTR_DEFAULT_CITY:"?0"}?format=1"
}

function exclude() {
  if [ ${#} -ne 1 ]; then
    red "Missing expression"
    bold "Usage: $0 <expression>"
    return 1
  fi

  [[ -f .git/info/exclude ]] && echo "$1" >>.git/info/exclude
}

function rndpw() {
  tr </dev/urandom -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~' | head -c 14
  echo
}

function repos() { #: Navigate to the repos folder
  if [ -z "$REPOS_FOLDER" ]; then
    red "REPOS_FOLDER is not set"
    return 1
  fi
  cd "$REPOS_FOLDER/$1" || return 1
}

function cloneme() { #: Clone a repo from my github
  if [[ $# -ne 1 ]]; then
    red "Need to specify a repo to clone."
    return 1
  fi

  gcl "git@github.com:richin13/$1.git"
}

function docs() { #: Serve documentation directory
  if [[ $# -lt 1 ]]; then
    bold "Available documentations:"
    ls "$DOCS_FOLDER"
  else
    pushd "$DOCS_FOLDER/$1" >/dev/null || return 1
    shift
    python -m http.server "$*"
    popd >/dev/null || return 1
  fi
}

function zoomy() { #: Open a zoom meeting
  xdg-open "zoommtg://zoom.us/join?action=join&confno=$1" >/dev/null 2>&1
}

function despace() {
  local in="$*"
  if [ -z "$in" ]; then
    while read -r in; do
      mv "$in" "$(printf "%s" "$in" | tr -s ' ' '_')"
    done
  else
    for filename in $in; do
      mv "$filename" "$(printf "%s" "$filename" | tr -s ' ' '_')"
    done
  fi
}

function bsfd() { #: Base64 Decode a string
  if [[ $# -lt 1 ]]; then
    red "Please specify the string to decode using base64 -d"
    return 1
  fi

  echo "$1" | base64 -d
}

function bsfe() { #: Base64 Encode a string
  if [[ $# -lt 1 ]]; then
    red "Please specify the string to encode using base64"
    return 1
  fi

  echo "$1" | base64
}

function wnip() { #: Open what's new in python web page
  xdg-open "https://docs.python.org/3/whatsnew/$1.html"
}

function dmp3() { #: Download a yt as mp3
  yt-dlp -x --audio-format mp3 --audio-quality 0 --embed-metadata "$@"
}

function d() {
  if [[ -n $1 ]]; then
    cd "-$1" || return 1
  else
    dirs -v | head -n 10
  fi
}

function va() { #: Create a virtualenv
  local venv_name=$DEFAULT_PYTHON_VENV_DIR
  if [ ${#} -eq 1 ]; then
    venv_name=$1
  fi

  if [[ -d $venv_name ]]; then
    if [[ -z "$VIRTUAL_ENV" ]]; then
      yellow "Virtualenv exists but it's not activated"
    else
      yellow "Virtualenv already activated"
    fi
    return 1
  fi

  python -m venv "$venv_name"

  # shellcheck disable=SC1091
  source "$venv_name/bin/activate" && pip install -U pip "${DEFAULT_PYTHON_PACKAGES[@]}"
}
function vd() {
  local venv_name=$DEFAULT_PYTHON_VENV_DIR
  if [ ${#} -eq 1 ]; then
    venv_name=$1
  fi

  [[ -n "$VIRTUAL_ENV" ]] && deactivate

  [[ -d $venv_name ]] &&
    rm -rf "$venv_name" >/dev/null &&
    green "Deleted ./$venv_name/"
}

function pyclean() {
  find "${@:-.}" -type f -name "*.py[co]" -delete
  find "${@:-.}" -type d -name "__pycache__" -delete
  find "${@:-.}" -depth -type d -name ".mypy_cache" -exec sh -c 'rm -r $1' shell {} \;
  find "${@:-.}" -depth -type d -name ".pytest_cache" -exec sh -c 'rm -r $1' shell {} \;
  find "${@:-.}" -depth -type d -name ".ruff_cache" -exec sh -c 'rm -r $1' shell {} \;
  find "${@:-.}" -depth -type d -name ".tox" -exec sh -c 'rm -r $1' shell {} \;
}

function groot() { #: Go to the root of the git repository
  if [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" ]; then
    cd "$(git rev-parse --show-toplevel)" || return 1
  else
    echo "'$PWD' is not inside a git repository"
    return 1
  fi
}

function gccd() { #: Clone and cd into a repo
  command git clone --recurse-submodules "$@"
  local lastarg=$_
  [[ -d $lastarg ]] && cd "$lastarg" && return
  lastarg=${lastarg##*/}
  cd "${lastarg%.git}" || return 1
}

# Ubuntu-only functions
if [ "$DISTRO" = "ubuntu" ]; then
  function upgradezoom() { #: Upgrade zoom
    local filename=zoom_amd64.deb
    curl -L "https://zoom.us/client/latest/$filename" -o $filename
    sudo dpkg -i $filename
    sudo apt-get install -f
    rm -rf $filename
  }

  function upgrade() { #: Do a full system upgrade
    sudo apt update
    sudo apt upgrade -y
    sudo apt autoremove -y
    pushd .
    cd ~/dotfiles || return 1
    git pull
    popd || return 1
    mise install -f neovim@nightly
    nvim -c 'PlugUpdate' -c 'CocUpdate'
  }

  function update-ff-dev() { #: Upgrade firefox developer edition
    wget "https://download.mozilla.org/?product=firefox-devedition-latest-ssl&os=linux64&lang=en-US" -O Firefox-dev.tar.bz2
    sudo tar xjf Firefox-dev.tar.bz2 -C /opt/
  }
fi

function relwords() { #: Fetch related words from relatedwords.org
  local url="https://relatedwords.org/api/related?"
  local term=$1
  echo "$term"
  curl -s "$url" -G --data-urlencode "term=$term" | jq -r '.[] | .word'
}

function restart-plasma() { #: Restart plasma
  kquitapp5 plasmashell && kstart5 plasmashell
}

function p() { #: Runs a python REPL (on batteries, if installed)
  if [ -x "$(command -v ipython)" ]; then
    ipython --no-confirm-exit
  elif [ -x "$(command -v bpython)" ]; then
    bpython
  else
    python
  fi
}

function gh-install() { #: Install the latest deb package from a Github release
  local repo=$1
  if [ -z "$repo" ]; then
    red "Please provide a repo name: user/repo"
    return 1
  fi
  if ! echo "$repo" | grep -q '/'; then
    red "Invalid repo name: $repo, must be user/repo"
    return 1
  fi
  local url="https://api.github.com/repos/$repo/releases/latest"
  local arch
  local url
  local filename
  arch=$(dpkg --print-architecture)
  url=$(curl -s "$url" | jq -r ".assets[] | .browser_download_url" | grep 'amd64' | grep 'linux' | grep '.deb')
  if [ -z "$url" ]; then
    red "No deb package found for $arch in https://github.com/$repo"
    return 1
  fi
  filename=$(basename "$url")
  curl -L "$url" -o "$filename"
  sudo dpkg -i "$filename"
  rm -rf "$filename"
}

function install-language-servers() {
  local npm_packages=(
    #: https://github.com/bash-lsp/bash-language-server
    bash-language-server
    #: https://github.com/rcjsuen/dockerfile-language-server-nodejs
    dockerfile-language-server-nodejs
    #: https://github.com/microsoft/compose-language-service
    @microsoft/compose-language-service
    #: https://github.com/microsoft/pyright
    pyright
    #: https://github.com/typescript-language-server/typescript-language-server
    typescript
    typescript-language-server
    #: https://github.com/iamcco/vim-language-server
    vim-language-server
    #: https://github.com/hrsh7th/vscode-langservers-extracted
    vscode-langservers-extracted
  )
  echo "Installing language servers with npm: ${npm_packages[*]}..."
  npm install -g "${npm_packages[@]}"

  local pip_packages=(
    #: https://github.com/termux/termux-language-server/
    termux-language-server
  )
  echo "Installing language servers with pipx: ${pip_packages[*]}..."
  pipx install "${pip_packages[@]}"

  if [ "$DISTRO" = "ubuntu" ]; then
    echo "Installing lua-language-server..."
    rm -rf ~/.local/bin/lls && mkdir ~/.local/bin/lls
    curl -Ss "https://api.github.com/repos/LuaLS/lua-language-server/releases/latest" |
      jq -r ".assets[] | .browser_download_url" |
      grep 'linux-x64.tar.gz' |
      xargs -I {} curl -sL {} |
      tar -xzf - -C ~/.local/bin/lls &&
      ln -s ~/.local/bin/lls/bin/lua-language-server ~/.local/bin/lua-language-server &&
      chmod +x ~/.local/bin/lua-language-server

    # https://rust-analyzer.github.io/manual.html#rust-analyzer-language-server-binary
    echo "Installing rust-analyzer"
    curl -sL https://github.com/rust-lang/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-unknown-linux-gnu.gz |
      gunzip -c - >~/.local/bin/rust-analyzer &&
      chmod +x ~/.local/bin/rust-analyzer
  fi
}

# }}}
# Aliases ----------------------------------------------------------- {{{
#: General aliases
alias cat!="/usr/bin/cat"
alias cp!="/usr/bin/cp -f"
alias cp="cp -iv"
alias cpwd="pwd | xclip" #: Copy the current working directory to the clipboard
alias ff="grep -rnw . -e"
alias fixm="autorandr --change"
alias jk="fc -e -" #: Execute the previous command
alias l!="/usr/bin/ls"
alias lsa='ls -lah'
alias l='ls -lah'
alias ll='ls -lh'
alias la='ls -lAh'
alias m="make"
alias mkdir="mkdir -pv"
alias mv="mv -iv"
alias o=xdg-open
alias ppwd="cd \`xclip -o\`" #: cd to the directory in the clipboard
alias rf="rm -rf"
alias rm!="/usr/bin/rm -rf"
alias rm="rm -Iv"
alias servedir="python -m http.server"
alias srm="shred -n 100 -z -u" #: Securely delete a file
alias ssol="aws sso login"
alias tks="tmux kill-server"
alias tree="lsd --tree -I __pycache__ -I .venv -I node_modules -I .git"
alias zzz="systemctl suspend"

if [ -n "$BASH_VERSION" ]; then
  alias ..="cd .." #: No auto_cd in bash :(
  alias ...="cd ../.."
  alias ....="cd ../../.."
  alias .....="cd ../../../.."
  alias ......="cd ../../../../.."
else
  alias -g ...='../..'
  alias -g ....='../../..'
  alias -g .....='../../../..'
  alias -g ......='../../../../..'
fi

[[ -x "$(command -v nvim)" ]] && alias vim="nvim"
[[ -x "$(command -v bat)" ]] && alias cat="bat --style='numbers,changes'"
[[ -x "$(command -v lsd)" ]] && alias ls="lsd"
[[ -x "$(command -v rg)" ]] || alias rg="red 'rg is not installed' && grep -rnw . -e"
[[ -x "$(command -v fd)" ]] || alias fd="red 'fd is not installed' && find . -type f -iname"

#: Config files aliases
alias bashrc='nvim $HOME/.bashrc'
alias zshrc='nvim $HOME/.zshrc'
alias vimrc='nvim $XDG_CONFIG_HOME/nvim/init.vim'
alias tmuxconf='nvim $HOME/.tmux.conf'
alias coc-settings='vim $XDG_CONFIG_HOME/nvim/coc-settings.json'

if [ -z "$DOTFILES" ] && [ -d "$DOTFILES" ]; then
  alias dotfiles='cd $DOTFILES'
fi

#: Arch Linux-only aliases
if [ "$DISTRO" = "arch" ]; then
  alias pacss="pacman -Ss"
  alias pacs="sudo pacman -S --noconfirm --needed"
  alias pacsy="sudo pacman -Syyy"
  alias pacsu="sudo pacman -Syyu"
  alias pacrs="sudo pacman -Rs"
  alias pkg="makepkg -cris"
fi

#: Ubuntu-only aliases
if [ -x "$(command -v apt)" ]; then
  alias apti="sudo apt install -y"
  alias apts="apt search"
  alias aptu="sudo apt remove -y"
  alias aptup="sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y"
  alias aptar="sudo apt autoremove -y"
fi

#: Python aliases
alias py="python"
alias pipi="pip install"
alias pipu="pip uninstall -y"
alias pipf="pip freeze"
alias pip-dev='pipi -U $DEFAULT_PYTHON_PACKAGES'
alias pa="poetry add"
alias pad="poetry add --group dev"
alias pi="poetry install"
alias pu="poetry update"
alias pr="poetry remove"
alias prd="poetry remove --group=dev"
alias django="python manage.py"
alias cc="cookiecutter"
alias vaa='source $DEFAULT_PYTHON_VENV_DIR/bin/activate'

#: Git aliases
alias g="git"
alias ga="git add"
alias gaa="git add --all"
alias gapa="git add --patch"
alias gb="git branch"
alias gba="git branch --all"
alias gbd="git branch --delete"
alias gbD="git branch --delete --force"
alias gbd!="git branch --delete --force"
alias gco="git checkout"
alias gcf="git clean -fd"
alias gcl="git clone --recurse-submodules"
alias gcam="git commit --all --message"
alias gcmsg="git commit --message"
alias gcsmg="git commit --message"
alias gc!="git commit -v --amend --no-edit"
alias gcc!="git commit -v --amend"
alias gcnv="git commit --no-verify -m"
alias gd="git diff"
alias gd!="GIT_PAGER=less git diff"
alias gds="git diff --staged"
alias gds!="GIT_PAGER=less git diff --staged"
alias gdw="git diff --word-diff"
alias gdlc="git diff HEAD~1..HEAD"
alias gf="git fetch"
alias gfa="git fetch --all --prune"
alias glog="git log --oneline --decorate --graph"
alias gloga="git log --oneline --decorate --graph --all"
alias gm="git merge"
alias gup="git pull --rebase"
alias gp="git push"
alias gpf!="git push --force"
alias grb="git rebase"
alias grba="git rebase --abort"
alias grbc="git rebase --continue"
alias grbi="git rebase --interactive"
alias grv="git remote --verbose"
alias gra="git remote add"
alias grrm="git remote remove"
alias grh="git reset"
alias grhh!="git reset --hard"
alias grs="git restore"
alias grss="git restore --staged"
alias gsta="git stash push"
alias gstp="git stash pop"
alias gstd="git stash drop"
alias gstl="git stash list"
alias gst="git status"
alias gsw="git switch"
alias gcb="git switch -c"
alias gcd="git switch develop"
alias gcm="git switch main || git switch master"
# Edit modified files
alias vemd="vim \$(git status --porcelain=v2 | grep -P '\.M' | cut -d ' ' -f 9)"
alias wip='git add -A; command git rm $(git ls-files --deleted) 2> /dev/null; command git commit --no-verify --no-gpg-sign --message "--wip-- [skip ci]"'
alias unwip="git rev-list --max-count=1 --format=\"%s\" HEAD | grep -q \"\--wip--\" && git reset HEAD~1"

#: Docker aliases
alias dc="docker compose"
alias dcbuild="dc build"
alias dcdown="dc down --remove-orphans --volumes"
alias dcexec="dc exec"
alias dclogs="dc logs --follow"
alias dcps="dc ps"
alias dcrestart="dc restart"
alias dcrun="dc run --rm"
alias dcup="dc up"

#: Kubernetes aliases
alias k="kubectl"
alias kaf="kubectl apply -f"
alias kaf!="kubectl apply -f --force"
alias kd="kubectl describe"
alias kdp="kubectl describe pod"
alias kga="kubectl get pods --all-namespaces"

#: Js / yarn aliases
alias yi="yarn install"
alias ya="yarn add"
alias yad="yarn add -D"
alias yr="yarn remove"

#: PHP / Laravel aliases
alias sail="bash vendor/bin/sail"
alias artisan="sail artisan"

# Pentesting / Bug Bounting
alias nmap="sudo nmap"
alias nmapq="nmap -T4 -F "                         #: Quick
alias nmapqp="nmap -sV -T4 -O -F --version-light " #: Quick plus
alias nmapatcp="nmap -p- -T4 -A -sC -Pn "          #: All TCP, no ping
alias nmapa!="nmap -sS -sU -T4 -A -v -Pn "         #: All TCP and UDP, no ping
alias gobusterz='gobuster dir -w /usr/share/dirbuster/wordlists/directory-list-lowercase-2.3-medium.txt -u '
# }}}
# Prompt config ----------------------------------------------------- {{{

green='\[\e[0;32m\]'
purple="\[\e[0;34m\]"
pink="\[\e[0;35m\]"
reset='\[\e[0m\]'
export PS1="${green}\u@\h${reset}:${purple?}\w${reset}\n${pink}\$${reset} "

# }}}
if [ -d "$FORTUNES_FOLDER" ] && [ -x "$(command -v fortune)" ]; then
  fortune_=$(fortune -a -e "$FORTUNES_FOLDER")

  if [ -x "$(command -v cowsay)" ]; then
    cowsay "$fortune_"
  else
    echo "$fortune_"
  fi
fi
