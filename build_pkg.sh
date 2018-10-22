#!/bin/bash

# AUTHOR: Sarfraz Kapasi

# Globals
##############################################################################

RES=$(tput sgr0)
PYTHON="c:/ProgramData/Anaconda3/python.exe"

# Functions
##############################################################################

function clean {
    rm -f `find . -name \*.pyc -print0 | xargs -0`
    rm -rf `find . -name __pycache__ -print0 | xargs -0`
    rm -rf `find . -name \*.egg-info -print0 | xargs -0`
    rm -rf `find . -name build -print0 | xargs -0`
}

function clean_all {
    clean
    rm -rf `find . -name .venv -print0 | xargs -0`
    rm -rf `find . -name dist -print0 | xargs -0`
}

function color_echo {
    echo -e "$(tput setaf $1)${2}${RES}"
}

function r_echo {
    color_echo 1 "$1"
}

function g_echo {
    color_echo 2 "$1"
}

function b_echo {
    color_echo 4 "$1"
}

function success {
    g_echo "********** Success **********"
    exit 0
}

function failure {
    r_echo "********** Failure **********"
    exit 1
}

function check_success {
    if [ $1 -ne 0 ]; then
        r_echo "$2"
        r_echo "Go check your sources!"
        failure
    fi
}

# Main
##############################################################################

# Checking python version
# it needs to be at least 3
PYTHON_VERSION=$($PYTHON -c 'import sys; print("%i" %(sys.hexversion<0x03000000))')
if [ $PYTHON_VERSION -ne 0 ]; then
    r_echo "Python is 2.x"
    r_echo "Python version 3.x is required"
    r_echo "Bye..."
    failure
else 
    b_echo "Python is 3.x"
fi

# Cleaning up before building
b_echo "Removing old build if present"
clean

# Testing package with PEP8
b_echo "Creating temp virtualenv"
b_echo "--> virtualenv .venv"
$PYTHON -m venv --without-pip .venv
source .venv/bin/activate
curl https://bootstrap.pypa.io/get-pip.py | python

# Code syntax validation
b_echo "Installing validation tool"
pip install flake8
b_echo "Checking code against linter"
flake8 ds

# do something about the code syntax rules...

# Launching tests
b_echo "Installing test runners"
pip install -r requirements.txt
b_echo "Running unit tests"
b_echo "--> $PYTHON setup.py test"
python setup.py test
check_success $? "Tests did not pass!"

# Packaging the python code
b_echo "Building..."
b_echo "--> $PYTHON setup.py build bdist_wheel"
python setup.py build bdist_wheel
check_success $? "Build failed"

# Sending built package to pypi server
if [ -z $UPDATE_INDEX ]; then
    b_echo "Package not marked for upload"
else
    b_echo "Pushing package to upstream"
    pip install devpi-client
    devpi upload
fi

b_echo "--> deactivate"
deactivate

# Nothing to declare, exiting...
success
