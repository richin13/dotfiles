# Author: Ricardo Madriz <richin13[at]gmail.com>
# Bash helpers to improve my git workflow

# Section: Variables ---------------------------------------------- {{{
#
# }}}

# Section: Aliases ------------------------------------------------ {{{

alias 'gp!'="gp --force"
alias gwip="gaa && gcmsg 'WIP :: WIP :: WIP'"
alias wip="gwip"
alias guwip="unwip"
alias gcsmg="git commit -m"
alias gcmsgnv="git commit --no-verify -m"
alias gcb="git switch -c"
#: This assumes latest version of git (^2.37)
alias 'gc!'="git commit -v --amend --no-edit"
alias 'gcc!'="git commit -v --amend"
alias gdlc="git diff HEAD~1..HEAD"

# Edit modified files
alias vemd="vim \$(git status --porcelain=v2 | grep -P '\.M' | cut -d ' ' -f 9)"

# }}}
# Section: Functions ---------------------------------------------- {{{

# cd to the current git root
function groot() {
  if [ $(git rev-parse --is-inside-work-tree 2>/dev/null ) ]; then
    cd $(git rev-parse --show-toplevel)
  else
    echo "'$PWD' is not inside a git repository"
    return 1
  fi
}

function unwip() {
  if git log -1 --pretty=%B | grep 'WIP' >/dev/null; then
    git reset HEAD~1
  else
    echo "No WIP commit found"
  fi
}
# }}}
