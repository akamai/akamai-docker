#!/bin/bash

# Copyright 2020 Akamai Technologies
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
