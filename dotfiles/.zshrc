# My Zsh configuration
# Extends my base configuration defined in .bashrc and adds zsh-specific stuff
# Author: Ricardo Madriz

if [ -f "$HOME/.bashrc" ]; then
  source "$HOME/.bashrc"
fi

# Sensitive information includes
if [ -f "$XDG_CONFIG_HOME/zsh/sensitive.zsh" ]; then
  include "$XDG_CONFIG_HOME/zsh/sensitive.zsh"
fi

# Remove duplicates in $PATH
# https://til.hashrocket.com/posts/7evpdebn7g-remove-duplicates-in-zsh-path
typeset -aU path

export SHELL=zsh
export ZINIT_HOME=$XDG_DATA_HOME/zinit/zinit.git
export WORDCHARS=''

## History file configuration
[ -z "$HISTFILE" ] && HISTFILE="$HOME/.zsh_history"
[ "$HISTSIZE" -lt 50000 ] && HISTSIZE=50000
[ "$SAVEHIST" -lt 10000 ] && SAVEHIST=10000

#: Profiling
if [ ! -z $ZPROF ]; then
  zmodload zsh/zprof
fi

#: Zsh settings
#: See https://zsh.sourceforge.io/Doc/Release/Options.html#Options
unsetopt flow_control
unsetopt menu_complete        # do not autoselect the first completion entry
setopt auto_cd                # cd to directory without typing `cd`
setopt auto_pushd             # push directory into stack after `cd`
setopt prompt_subst           # enable prompt expansion
setopt pushd_ignore_dups      # dont push duplicated directories into stack
setopt pushd_minus            # push directory into stack with `-` prefix
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data
setopt auto_menu              # show completion menu on successive tab press
setopt always_to_end          # move cursor to end of line after autocomplete

source ${ZINIT_HOME}/zinit.zsh

# Old Oh-my-zsh setup
zinit snippet OMZL::git.zsh
zinit snippet OMZL::key-bindings.zsh

#: Theme
zinit ice src"dracula.zsh-theme"
zinit light richin13/dracula.zsh-theme

# Cool stuff
zinit light paulirish/git-open
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zdharma-continuum/history-search-multi-word

# Completions ----------------------------------------------------- {{{
zmodload -i zsh/complist

zstyle ':completion:*:*:*:*:*' menu select #: Use menu select instead of cycling
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'
#: Ignore some patterns when completing
zstyle ":completion:*" ignored-patterns "(*/)#(__pycache__|*.pyc|node_modules|.git|*.egg-info)"
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path $ZSH_CACHE_DIR
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:users' ignored-patterns \
        adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna \
        clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
        gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm \
        ldap lp mail mailman mailnull man messagebus  mldonkey mysql nagios \
        named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn \
        operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
        rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp \
        usbmux uucp vcsa wwwrun xfs '_*'
zstyle '*' single-ignored show #: Show ignored when pressing tab twice

autoload -Uz compinit && compinit

autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

_repos() {
  local state

  _arguments \
    '1: :->dir'

  case $state in
    dir) _arguments '1:projects:($(ls $REPOS_FOLDER))' ;;
  esac
}
compdef _repos repos

_docs() {
  local state

  _arguments \
    '1: :->dir'

  case $state in
    dir) _arguments '1:documentations:($(ls $DOCS_FOLDER))' ;;
  esac
}
compdef _docs docs

if command -v mise &> /dev/null; then
  #: mise completion
  eval "$(mise completion zsh)"
fi

zinit cdreplay -q
# }}}

bindkey '^P' up-line-or-beginning-search
bindkey '^N' down-line-or-beginning-search
bindkey '^K' clear-screen #: Use C-K to clear the screen
bindkey -M menuselect '^o' accept-and-infer-next-history

#: Hook functions (https://zsh.sourceforge.io/Doc/Release/Functions.html#Hook-Functions)
function chpwd() {
  local owner=$(stat -L -c "%U" $PWD)

  if [[ $USER = $owner ]]; then
    ls
  fi
}

function _py_venv_activation_hook() {
  local ret=$?

  if [ -n "$VIRTUAL_ENV" ]; then
    source $DEFAULT_PYTHON_VENV_DIR/bin/activate 2>/dev/null || deactivate || true
  else
    source $DEFAULT_PYTHON_VENV_DIR/bin/activate 2>/dev/null || true
  fi

  return $ret
}

typeset -g -a precmd_functions
if [[ -z $precmd_functions[(r)_py_venv_activation_hook] ]]; then
  precmd_functions=(_py_venv_activation_hook $precmd_functions);
fi

if [ ! -z $ZPROF ]; then
  zprof
fi

#: https://github.com/rsteube/carapace-bin (external autocompletion for docker compose)
if [ $commands[carapace] ]; then
  source <(carapace docker);
  source <(carapace docker-compose);
fi

if [ -f ~/.local/bin/mise ]; then
  eval "$(~/.local/bin/mise activate zsh)"
fi
