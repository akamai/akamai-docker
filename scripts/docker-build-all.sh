#!/bin/bash

set -e

build_img() {
  if [ "$#" == 2 ];
  then
    docker build -t $1 -f $2 .
  elif [ "$#" == 3 ];
  then
    docker build -t $1 -f $2 --build-arg BASE=$3 .
  fi
}

build_chain() {
  if [ "$#" == 1 ];
  then
    build_img akamai/akamai-docker-$1 dockerfiles/akamai-docker-$1.Dockerfile
  else
    local base=$1; shift
    while [ "$#" -gt 1 ];
    do
      local tag=$1; shift
      build_img akamai/akamai-docker-$tag-chain dockerfiles/akamai-docker-$tag.Dockerfile akamai/akamai-docker-$base
      [ "$base" =~ "-chain" ] && docker rmi akamai/akamai-docker-$base
      base=$tag-chain
    done
    build_img akamai/akamai-docker-$1 dockerfiles/akamai-docker-$1.Dockerfile akamai/akamai-docker-$base
  fi
}

#  `|| [ -n "$line" ]` catches the final line if it is not
# terminated with a newline
cat variants | while read line || [ -n "$line" ];
do
  build_chain $line
done
