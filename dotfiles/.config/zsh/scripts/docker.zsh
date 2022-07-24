# Docker helper functions and aliases
# Author: Ricardo Madriz <richin13 at gmail dot com>
#

DOCKER_IMAGES_FORMAT="{{.ID}}|{{.Repository}}|{{.CreatedSince}} ago"

# Aliases: -------------------------------------------------------- {{{
alias dckr="docker"
alias dckri="docker image"
alias dckre="docker exec"
alias dckrr="docker run"
alias dckrrit="docker run -it"
alias dckrp="docker ps"

alias dc="docker-compose"
alias dcbuild="dc build"
alias dcup="dc up"
alias dcdown="dc down -v"
# }}}

# Functions: ------------------------------------------------------ {{{
function delete-docker-images () {
  if [ ${#} -ne 1 ]; then
    red "Must specify a search criteria"
    bold "Usage: $0 '<search-criteria>'"
    return 1
  fi

  for i in $(docker image ls --format $DOCKER_IMAGES_FORMAT | grep $1 | cut -d '|' -f 1)
  do
    docker image rmi --force $i
  done
}
# }}}
