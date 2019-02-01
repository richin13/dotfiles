# Author: Ricardo Madriz <richin13[at]gmail.com>
# Bash helpers to improve my git workflow

# Section: Variables ---------------------------------------------- {{{
#
# }}}

# Section: Aliases ------------------------------------------------ {{{

alias gci="gco integration"
alias 'gp!'="gp --force"

# }}}
# Section: Functions ---------------------------------------------- {{{
function gdiff() {
  if [[ $# -lt 2 ]]; then
    echo "Missing ref"
    echo "Usage: $0 <ref1> <ref2>"
    exit 1
  fi
}
# }}}