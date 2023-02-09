# Author: Ricardo Madriz <richin13[at]gmail.com>
# Bash helpers to improve my Python development workflow
#
# ===== Variables =====
DEV_PKGS=(pip neovim bpython isort toml-sort docformatter black ruff)
PY_DEFAULT_VERSION=python3.8
PYTHON_VENV_DIR=.venv
# ====== Aliases ======
alias p="bpython"

alias pipi="pip install"
alias pipu="pip uninstall"
alias pips="pip search"
alias pipf="pip freeze"
alias pipff="pip freeze > requirements.txt"
alias pip-dev="pipi -U $DEV_PKGS"

alias pt="poetry"
alias pa="poetry add"
alias pad="poetry add --group dev"
alias pi="poetry install"
alias pu="poetry update"
alias pr="poetry remove"
alias prd="poetry remove --group=dev"
alias prun="poetry run"
alias pinit="poetry init -n"

alias django="python manage.py"

alias cc="cookiecutter"
# ====== Functions ======
# va: Activates a virtualenvironment ------------------------------ {{{
function va() {
  local venv_name=$PYTHON_VENV_DIR
  if [ ${#} -gt 0 ]; then
    venv_name=$@
  fi

  if [[ -d $venv_name ]]; then
    [[ -z "$VIRTUAL_ENV" ]] \
      && yellow "Virtualenv exists but it's not activated" \
      || yellow "Virtualenv already activated"
    return 1
  fi

  python -m venv $venv_name

  source $venv_name/bin/activate && pip install -U pip $DEV_PKGS
}
# }}}
# vd: Delete the virtualenv activated in the current project ------ {{{
function vd() {
  local venv_name=$PYTHON_VENV_DIR
  if [ ${#} -gt 0 ]; then
    venv_name=$@
  fi

  [[ -n "$VIRTUAL_ENV" ]] && deactivate

  [[ -d $venv_name ]] \
    && rm -rf $venv_name > /dev/null \
    && green "Deleted ./$venv_name/"

  [[ $? -ne 0 ]] \
    && red "No virtualenv at ./$PYTHON_VENV_DIR/" \
    || true
}
# }}}
# pyscript: Simple python script generator ------------------------ {{{
function pyscript() {
  if [ ${#} -ne 1 ]; then
    echo -e "[${RED}ERROR${NC}]: Missing required paramater <script-name>"
    echo -e "Usage: pyscript <script-name>"
    return 1
  fi

  cat > $@ << EOF
#!/usr/bin/env python


def main():
    pass


if __name__ == '__main__':
    main()
EOF

}
# }}}
# mypy_ini: mypy config file to ignore missing imports ------------ {{{
function mypy_ini() {
  echo -e "[mypy]\n\n" > mypy.ini

  for pkg in $@; do
    echo -e "[mypy-$pkg.*]\nignore_missing_imports = True\n\n" >> mypy.ini
  done
} # }}}
# flask_makefile: Basic Makefile for a Flask app ------------------ {{{
function flask_makefile() {
  if [ ${#} -lt 1 ]; then
    echo -e "[${RED}ERROR${NC}]: Missing required paramater <application-package>"
    echo -e "Usage: flask_makefile <application-package>"
    return 1
  fi
  pkg=$1

  cat > Makefile << EOF
.EXPORT_ALL_VARIABLES:
APP = \$(notdir \$(PWD))
FLASK_APP = ${pkg}
FLASK_ENV = development
FLASK_CONFIG = config.DevConfig

.PHONY: help
help: ## Show this help.
	  @echo -e "\$\$(grep -hE '^\S+:.*##' \$(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\\\x1b[36m\1\\\\x1b[m:\2/' | column -c2 -t -s :)"

.PHONY: docker
docker: lint test ## Creates a docker container
	docker build -t basic-backend .
	docker run -d -p 4000:80 basic-backend

.PHONY: run
run: database ## Run the development server
	flask run

.PHONY: create_db
create_db: database ## Creates the database tables
	flask create_db

.PHONY: shell
shell: ## Spawns a Python shell with Flask app preloaded
	flask shell

.PHONY: routes
routes: ## Shows the application routes
	flask routes

.PHONY: database
database: ## Launch the development database
	-docker run -e POSTGRES_PASSWORD="\$(DB_PASSWORD)" -e POSTGRES_DB="\$(DB_DATABASE)" -p 5432:5432 -d postgres

.PHONY: test
test: ## Run the tests
	FLASK_CONFIG="config.TestConfig" pytest --disable-pytest-warnings

.PHONY: lint
lint: ## Lint the application's code
	pylint ${pkg}
	mypy ${pkg}

.PHONY: clean
clean: ## Deletes the python generated files and directories
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -delete
EOF
} # }}}
# fsetup: Generates a basic structure for a Flask application ----- {{{
function fsetup() {
  if [ ${#} -lt 1 ]; then
    echo -e "[${RED}ERROR${NC}]: Missing required paramater <app-name>"
    echo -e "Usage: fsetup <app-name>"
    return 1
  elif [[ -d $@ ]]; then
    echo -e "[${RED}ERROR${NC}]: App $@ already exists"
  else
    pkg=application
    app=$@
    mkdir $app
    pushd $app > /dev/null 2>&1
    # First step is to create a new virtual environment for the project
    green "Creating virtual environment for $app"
    va $app > /dev/null 2>&1

    green "Creating .gitignore file"
    ignore "python,vim" > .gitignore > /dev/null 2>&1

    green "Creating basic app skeleton"
    mkdir ./instance
    mkdir ./$pkg # This should configurable maybe?
    mkdir -p "./test/unit" # test is a reserved keyword
    mkdir -p "./test/integration"
    touch ./instance/config.py
    touch ./config.py
    touch ./$pkg/__init__.py
    touch "./test/__init__.py"
    touch "./test/unit/__init__.py"
    touch "./test/integration/__init__.py"

    green "Installing dependencies"
    $(pyenv which pip) install flask flask-sqlalchemy mixer pytest pylint mypy > /dev/null 2>&1
    $(pyenv which pip) freeze > requirements.txt 2> /dev/null

    green "Setting up Git"
    git init > /dev/null 2>&1
    git add --all > /dev/null 2>&1
    git commit -m "Initial commit" > /dev/null 2>&1

    green "Genereating default settings for tools"
    mypy_ini flask flask-sqlalchemy
    flask_makefile $pkg

    popd > /dev/null 2>&1

    echo "Done!"
    echo " \$ cd $app/"
  fi
} # }}}
# pyrm: Deletes a directory that contains a Python project -------- {{{
function pyrm() {
  if [ ${#} -ne 1 ]; then
    echo -e "[${RED}ERROR${NC}]: Missing required paramater <project-folder>"
    echo -e "Usage: fsetup <project-folder>"
    return 1
  elif [[ ! -d $@ ]]; then
    echo -e "[${RED}ERROR${NC}]: Folder $@ does not exists"
    return 1
  fi

  folder=$@
  pushd $folder > /dev/null 2>&1
  dvenv
  popd > /dev/null 2>&1
  rm -rf $folder
}
# }}}
# pipii: Installs a package and saves it to requirements.txt ------ {{{
function pipii() {
  # super hacky but it works :D
  temp="/tmp/$(echo $@ | md5sum).tmp"
  str="Successfully installed "
  pip install $@ | tee $temp
  installed_pkgs=($(cat $temp | grep $str | sed "s/$str//"))

  if [[ $? -eq 0 ]]; then
    for pkg in $installed_pkgs; do
      pkg=$(echo $pkg | sed 's/\(.*\)-/\1=/')
      name=$(echo $pkg | cut -d "=" -f 1)

      if echo $@ | grep -iq $name; then
        echo $pkg >> requirements.txt
      fi
    done

    sort -o requirements.txt requirements.txt
  fi

  rm $temp
}
# }}}
# pyni: Initializes a new python package (__init__.py) ------ {{{
function pyni() {
  dir=.
  if  [[ $# -eq 1 ]]; then
    dir=$1
  fi

  touch $dir/__init__.py
}
# }}}
# _py_venv_activation_hook: Hook to activate venvs ---------------- {{{
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
# }}}
# pymod: Adds an __init__.py to a folder -------------------------- {{{
function pymod() {
  if  [[ $# -lt 1 ]]; then
    red "Specify a target folder"
    return 1
  fi
  target=$1

  if [[ -d $target ]]; then
    touch "$target/__init__.py"
  else
    mkdir $target
    touch "$target/__init__.py"
  fi
}
# }}}
