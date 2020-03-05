# Author: Ricardo Madriz <richin13[at]gmail.com>
# Bash helpers to improve my git workflow

# Section: Variables ---------------------------------------------- {{{
#
# }}}

# Section: Aliases ------------------------------------------------ {{{

alias gci="gco integration"
alias 'gp!'="gp --force"
alias gwip="gaa && gcmsg '[WIP]'"
alias guwip="grh HEAD~1"

# Edit modified files
alias vemd="vim \$(git status --porcelain=v2 | grep -P '\.M' | cut -d ' ' -f 9)"

# }}}
# Section: Functions ---------------------------------------------- {{{
function gdiff() {
  if [[ $# -lt 2 ]]; then
    echo "Missing ref"
    echo "Usage: $0 <ref1> <ref2>"
    exit 1
  fi
}

# cd to the current git root
function groot() {
  if [ $(git rev-parse --is-inside-work-tree 2>/dev/null ) ]; then
    cd $(git rev-parse --show-toplevel)
  else
    echo "'$PWD' is not inside a git repository"
    return 1
  fi
}
# }}}
