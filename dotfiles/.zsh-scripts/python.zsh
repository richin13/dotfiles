# Author: Ricardo Madriz <richin13[at]gmail.com>
# Bash helpers to improve my Python development workflow
#
# ====== Aliases ======
alias p="bpython"

alias pipi="pip install"
alias pipu="pip uninstall"
alias pips="pip search"
alias pipf="pip freeze"
alias pipff="pip freeze > requirements.txt"

alias django="python manage.py"
# ====== Functions ======
# va: Activates a virtualenvironment ------------------------------ {{{
function va() {
  if [ ${#} -ne 1 ]; then
    local pkg=$(basename $PWD)
  else
    local pkg=$@
  fi

  pyenv virtualenv $pkg-venv
  echo $pkg-venv > .python-version

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
# dvenv: Delete the virtualenv activated in the current project --- {{{
function dvenv() {
  [[ -f .python-version ]] && pyenv uninstall -f $(cat .python-version)
}
# }}}
# Deletes a directory that contains a Python project -------------- {{{
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
