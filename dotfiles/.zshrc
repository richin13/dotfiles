# My Zsh configuration
# Extends my base configuration defined in .bashrc and adds zsh-specific stuff
# Author: Ricardo Madriz

if [ -f "$HOME/.bashrc" ]; then
  source "$HOME/.bashrc"
fi

# Sensitive information includes
if [ -f "$XDG_CONFIG_HOME/zsh/sensitive.zsh" ]; then
  include "$XDG_CONFIG_HOME/zsh/sensitive.zsh"
  alias sensitive="vim $XDG_CONFIG_HOME/zsh/sensitive.zsh"
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

#: Completions
if [ -d "$XDG_CONFIG_HOME/zsh/completions" ]; then
  fpath=($XDG_CONFIG_HOME/zsh/completions $fpath)
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

# Cool stuff
zinit light paulirish/git-open
zinit light zsh-users/zsh-syntax-highlighting
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

if ! type compinit &>/dev/null; then
  autoload -Uz compinit && compinit
fi

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

if command -v uv &> /dev/null; then
  eval "$(uv generate-shell-completion zsh)"
fi

zinit cdreplay -q
# }}}

bindkey '^P' up-line-or-beginning-search
bindkey '^N' down-line-or-beginning-search
bindkey '^K' clear-screen #: Use C-K to clear the screen
bindkey -M menuselect '^o' accept-and-infer-next-history

function vfd() {
  files=("${(@f)$(fd "$@")}")
  (( ${#files} )) && nvim "${files[@]}"
}

#: Hook functions (https://zsh.sourceforge.io/Doc/Release/Functions.html#Hook-Functions)
function chpwd() {
  [[ $- != *i* ]] && return
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
  source <(carapace _carapace);
fi

if [ -f ~/.local/bin/mise ]; then
  eval "$(~/.local/bin/mise activate zsh)"
fi

if [ $commands[starship] ]; then
  eval "$(starship init zsh)"
fi

if [ $commands[fzf] ]; then
  source <(fzf --zsh)

  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

  export FZF_DEFAULT_OPTS="
    --height 60%
    --layout reverse
    --border rounded
    --border-label-pos 3
    --prompt '  '
    --pointer '▶'
    --marker '✓'
    --ansi
    --cycle
    --bind 'ctrl-/:toggle-preview'
    --bind 'ctrl-space:toggle+down'
    --bind 'ctrl-a:select-all'
    --bind 'ctrl-d:deselect-all'
    --bind 'ctrl-f:preview-page-down'
    --bind 'ctrl-b:preview-page-up'
    --bind 'ctrl-u:preview-half-page-up'
    --bind 'ctrl-e:preview-half-page-down'
    --bind '?:toggle-preview'
    --color 'fg:#cdd6f4,fg+:#cdd6f4,bg:#1e1e2e,bg+:#313244'
    --color 'hl:#89b4fa,hl+:#89dceb,border:#585b70,header:#cba6f7'
    --color 'label:#cba6f7,prompt:#cba6f7,pointer:#f38ba8,marker:#a6e3a1'
    --color 'spinner:#f38ba8,info:#585b70'
  "

  # ── Ctrl-T: file picker ──────────────────────────────────────

  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_CTRL_T_OPTS="
    --border-label ' Files '
    --preview 'bat --color=always --style=numbers,changes --line-range=:300 {}'
    --preview-window 'right:55%:wrap'
  "

  # ── Ctrl-R: history ──────────────────────────────────────────

  export FZF_CTRL_R_OPTS="
    --border-label ' History '
    --preview 'echo {}'
    --preview-window 'down:3:wrap:hidden'
    --bind 'ctrl-/:toggle-preview'
    --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
    --color header:italic
    --header 'ctrl-y: copy to clipboard'
  "

  # ── Alt-C: directory jump ────────────────────────────────────

  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  export FZF_ALT_C_OPTS="
    --border-label ' Directories '
    --preview 'eza --tree --color=always --icons --level=2 {}'
    --preview-window 'right:40%'
  "

  gvim() {
    local files
    files=$(
      (git diff --name-only; git ls-files --others --exclude-standard) \
      | fzf -m --preview 'git diff --color {} 2>/dev/null || bat --color=always {}'
    )
    [[ -n "$files" ]] && nvim $(echo "$files")
  }

  fe() {
    local result file line
    result=$(
      rg --color=always --line-number --no-heading --smart-case "${*:-}" \
      | fzf \
          --ansi \
          --border-label ' Search Contents ' \
          --delimiter ':' \
          --preview 'bat --color=always --style=numbers,changes {1} --highlight-line {2}' \
          --preview-window 'right:55%:+{2}+3/3:wrap'
    )
    [[ -z "$result" ]] && return
    file=$(echo "$result" | cut -d: -f1)
    line=$(echo "$result" | cut -d: -f2)
    nvim "$file" +"$line"
  }

  # Ctrl-G: fzf dirty git files
  fzf-git-dirty() {
    local files
    files=$(git status --short | sed -e 's/^...//' -e 's/.* -> //' | fzf --multi --preview 'git diff --color=always {}' | tr '\n' ' ')
    if [[ -n "$files" ]]; then
      LBUFFER+="${files}"
    fi
    zle reset-prompt
  }
  zle -N fzf-git-dirty
  bindkey '^G' fzf-git-dirty

fi
