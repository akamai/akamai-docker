#!/bin/bash

login_data() {
cat <<EOF
{
  "username": "$DOCKER_USERNAME",
  "password": "$DOCKER_PASSWORD"
}
EOF
}

TOKEN=`curl -s -H "Content-Type: application/json" -X POST -d "$(login_data)" "https://hub.docker.com/v2/users/login/" | jq -r .token`

remove_tag() {
    curl "https://hub.docker.com/v2/repositories/$1/tags/$2/" \
    -X DELETE \
    -H "Authorization: JWT ${TOKEN}"
}
