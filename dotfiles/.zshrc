include "$HOME/.bashrc"

source "${ZINIT_HOME}/zinit.zsh"

# Old Oh-my-zsh setup
zinit snippet OMZL::completion.zsh
zinit snippet OMZL::compfix.zsh
zinit snippet OMZL::directories.zsh
zinit snippet OMZL::git.zsh
zinit snippet OMZL::history.zsh
zinit snippet OMZL::key-bindings.zsh

zinit ice src"dracula.zsh-theme"
zinit light richin13/dracula.zsh-theme

# Cool stuff
zinit light paulirish/git-open
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zdharma-continuum/history-search-multi-word

autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

#: Zsh settings
setopt auto_cd
setopt prompt_subst
zstyle ":completion:*" ignored-patterns "(*/)#(__pycache__|*.pyc|node_modules|.git|*.egg-info)"
bindkey '^P' up-line-or-beginning-search
bindkey '^N' down-line-or-beginning-search
bindkey '^K' clear-screen #: Use C-K to clear the screen

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
    source $PYTHON_VENV_DIR/bin/activate 2>/dev/null || deactivate || true
  else
    source $PYTHON_VENV_DIR/bin/activate 2>/dev/null || true
  fi

  return $ret
}

typeset -g -a precmd_functions
if [[ -z $precmd_functions[(r)_py_venv_activation_hook] ]]; then
  precmd_functions=(_py_venv_activation_hook $precmd_functions);
fi

#: Autocompletion
autoload -Uz compinit && compinit
_repos() {
  local state

  _arguments \
    '1: :->dir'

  case $state in
    (dir) _arguments '1:projects:($(ls $REPOS_FOLDER))' ;;
  esac
}
compdef _repos repos

function rckt() {
  cd "$ROCKET_FOLDER/$1"
}

_rckt() {
  local state

  _arguments \
    '1: :->dir'

  case $state in
    (dir) _arguments '1:projects:($(ls $ROCKET_FOLDER))' ;;
  esac
}
compdef _rckt rckt

_docs() {
  local state

  _arguments \
    '1: :->dir'

  case $state in
    (dir) _arguments '1:documentations:($(ls $DOCS_FOLDER))' ;;
  esac
}
compdef _docs docs

zinit cdreplay -q

if [ ! -z $ZPROF ]; then
  zprof
fi
