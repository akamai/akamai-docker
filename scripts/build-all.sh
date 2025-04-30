#!/bin/bash

#####################
# SETUP
#########

# Fail fast
set -e

# Assume PWD is root of the repo
source ./scripts/env.sh

# Print all lines from ./variants, excluding comments
# and blank lines.
variants() {
  #  `|| [ -n "$line" ]` catches the final line if it is not
  # terminated with a newline
  sed -E 's/\s*#.*$//g; /^\s*$/d' variants |
    while read line || [ -n "$line" ];
    do
      echo "$line"
    done
}

#####################
# BUILD ALL
#########

variants | while read chain;
do
  ./scripts/build-chain.sh "$chain"
done
