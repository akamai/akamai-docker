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

# Fail fast
set -e

EDITOR=${EDITOR:-vim}
SEMVER='v?([0-9]+)\.([0-9]+)\.([0-9]+)'
TEMPDIR=$(mktemp -d)

[ -z "$TEMPDIR" ] || trap "echo -n 'cleaning up, deleting temp dir: '; rm -rv $TEMPDIR" EXIT

die() {
  local excode=$1; shift;
  1>&2 echo "$0: $@"
  exit $excode
}

# previous_tag <REF?>
#   outputs the latest annotated tag matching v*.*.* reachable from
#   the ref provided as the first argument
previous_tag() {
  local from_ref=${1:-HEAD}
  git describe --abbrev=0 --match='v*.*.*' $from_ref 2>/dev/null
}

# parse_version [VERSION] [VARNAME] [VARNAME] [VARNAME]
#   parses VERSION and assigns the major, minor and patch component to
#   each extra argument successively.
parse_version() {
  local expr=$(echo -n $1 | sed -E "s#$SEMVER#$2=\1 $3=\2 $4=\3#")
  eval $expr
}

# increment_version [VERSION] major|minor|patch
#   outputs VERSION, incremented according to (simplified) semver rules
#   based on the second argument
increment_version() {
  parse_version $1 major minor patch
  eval $2=$(($2+1))
  case $2 in
    major) minor=0; patch=0;;
    minor) patch=0;;
  esac
  echo v$major.$minor.$patch
}

# version_changelog [VERSION]
#   outputs the changelog for a VERSION
version_changelog() {
  local version=${1:-HEAD}

  local previous_version=$(previous_tag $version^)
  local range="${previous_version}..${version}"
  if [ -z "${previous_version}" ];
  then
    range="${version}"
  fi

  git log --no-merges --oneline --pretty=tformat:"* %s - %an (%h)" --grep nochangelog --invert-grep $range
}

[[ $1 =~ major|minor|patch ]] || die 1 "usage: $0 major|minor|patch"
[[ $(git rev-parse --abbrev-ref HEAD) == master ]] || die 2 "should only run on master branch"
[[ -t 1 ]] || die 3 "stdout is not a terminal, this script should only be run interactively"

previous_version=$(previous_tag || echo "v0.0.0")
next_version=$(increment_version $previous_version $1)

next_changelog=$TEMPDIR/CHANGELOG.md


version_changelog > $next_changelog
$EDITOR $next_changelog

(
  echo -e "# CHANGELOG\n\n"
  echo -e "## $next_version ($(date -u +%Y-%m-%d))\n"
  cat $next_changelog
  echo

  git for-each-ref --sort=-taggerdate --format="%(refname:short) %(taggerdate:short)" refs/tags/v*.*.* |
    while read version version_date;
    do
      echo -e "## $version ($version_date)\n"
      git tag -l --format="%(contents)" $version
      echo
    done
) > CHANGELOG.md

git add CHANGELOG.md
git commit -m "chore: update changelog (nochangelog)"
git tag -a -m "$(cat $next_changelog)" $next_version

die 0 'success! next step, run git push --follow-tags'