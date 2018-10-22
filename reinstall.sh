#!/bin/bash

# AUTHOR: Sarfraz Kapasi

# Globals
##############################################################################

RES=$(tput sgr0)
PYTHON=$(which python)
PIP=$(which pip)
PROJECT_NAME=fsa-connect

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

$PIP install -e .

# Nothing to declare, exiting...
success
