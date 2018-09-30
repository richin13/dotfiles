# Author: Ricardo Madriz <richin13[at]gmail.com>
# Bash helpers to improve my Python development workflow
#
# Alias definitions
alias p="bpython"
# alias va="pyenv virtualenv $(basename $PWD)-venv && echo $(basename $PWD)-venv > .python-version"

alias pipi="pip install"
alias pipu="pip uninstall"
alias pips="pip search"
alias pipf="pip freeze"
alias pipff="pip freeze > requirements.txt"

alias django="python manage.py"
# Functions
function va() {
  if [ ${#} -ne 1 ]; then
    pkg=$(basename $PWD)
  else
    pkg=$@
  fi

  pyenv virtualenv $pkg-venv
  echo $pkg-venv > .python-version

}
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

# Generates a mypy.ini file with basic configuration
# to ignore missing imports for the given packages.
function mypy_ini() {
  echo -e "[mypy]\n\n" > mypy.ini

  for pkg in $@; do
    echo -e "[mypy-$pkg.*]\nignore_missing_imports = True\n\n" >> mypy.ini
  done
}


function flask_makefile() {
  if [ ${#} -lt 1 ]; then
    echo -e "[${RED}ERROR${NC}]: Missing required paramater <application-package>"
    echo -e "Usage: flask_makefile <application-package>"
    return 1
  fi
  pkg=$1

  cat > Makefile << EOF
.EXPORT_ALL_VARIABLES
APP = \$(notdir \$(PWD))
FLASK_APP=${pkg}
FLASK_ENV=development
FLASK_DEBUG=1

help: ## Show this help.
	  @fgrep -h "##" \$(MAKEFILE_LIST) | \\
		fgrep -v fgrep | \\
		    sed -e 's/\\\$\$//' | \\
		    sed -e 's/##//'

.PHONY: build-container
build-container: lint test ## Build the application container
	docker build -t basic-backend .

.PHONY: run-container
deploy-local: build-container ## Run the application container
	docker run -d -p 4000:80 basic-backend

.PHONY: run
run: ## Run the development server
	flask run

.PHONY: test
test: ## Run the tests
	pytest --disable-pytest-warnings

.PHONY: lint
lint: ## Lint the application's code
	pylint ${pkg}
	mypy ${pkg}

.PHONY: clean
clean: ## Deletes the python generated files and directories
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -delete
EOF
}

# Generates a basic structure for a Flask application
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
    va "$app-venv" > /dev/null 2>&1

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
}

# Delete the virtual env version of the current project
function dvenv() {
  [[ -f .python-version ]] && pyenv uninstall -f $(cat .python-version)
}

# Deletes a directory that contains a Python project
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
