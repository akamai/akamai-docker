#!/bin/bash

set -e

chalk() {
  local code=$1; shift;
  [ -t 2 ] && 
    echo -e "\033[$code$@\033[0m" ||
    echo $@
}

debug() {
  1>&2 echo "[DEBUG] $@"
}
info() {
  1>&2 echo "[INFO] $@"
}
err() {
  1>&2 echo "[ERR] $@"
}

build_img() {
  info "build_img: $1"
  if [ "$#" == 2 ];
  then
    docker build --force-rm -t $1 -f $2 .
  elif [ "$#" == 3 ];
  then
    docker build --force-rm -t $1 -f $2 --build-arg BASE=$3 .
  fi
}

build_chain() {
  info $(chalk 1\;93m "build_chain: $@")
  if [ "$#" == 1 ];
  then
    build_img akamai/$1 dockerfiles/$1.Dockerfile
  else
    local base=$1; shift
    while [ "$#" -gt 1 ];
    do
      local tag=$1; shift
      build_img akamai/$tag-chain dockerfiles/$tag.Dockerfile akamai/$base
      base=$tag-chain
    done
    build_img akamai/$1 dockerfiles/$1.Dockerfile akamai/$base
  fi
}

#  `|| [ -n "$line" ]` catches the final line if it is not
# terminated with a newline
sed -E 's/\s*#.*$//g; /^$/ d' variants | while read line || [ -n "$line" ];
do
  build_chain $line
done
