# ZSH profile file
# Extends the base .profile file

[ -f "$HOME/.profile" ] && source "$HOME/.profile"

# Sensitive information includes
if [ -f "$XDG_CONFIG_HOME/zsh/sensitive.zsh" ];then
  include "$XDG_CONFIG_HOME/zsh/sensitive.zsh"
fi

# Remove duplicates in $PATH
# https://til.hashrocket.com/posts/7evpdebn7g-remove-duplicates-in-zsh-path
typeset -aU path

export SHELL=zsh

ASDF_COMPLETIONS="${ASDF_DIR}/completions/_asdf"
if [ -d "$ASDF_COMPLETIONS" ]; then
  unset _asdf
  fpath+=(${ASDF_COMPLETIONS})
  autoload -Uz _asdf
  compdef _asdf asdf
fi

#: Profiling
if [ ! -z $ZPROF ]; then
  zmodload zsh/zprof
fi

