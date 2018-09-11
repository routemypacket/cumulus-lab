#!/usr/bin/env bash

set -x

###########################
# linter.sh
# -----
# looks through the current directory
# for all files ending in .yml
# and then passes them through yamllint
# which checks for valid yaml syntax
#
# YamlLint can be found at
# https://pypi.python.org/pypi/yamllint
#
# Installed via pip with
# $ pip install yamllint
#
#
###########################

yamllint ./ -c ./tests/.yamllint
