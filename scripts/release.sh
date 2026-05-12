#!/usr/bin/env bash

set -euo pipefail

version="$1"

branch="release/$version"

git checkout main

git pull --ff-only

git checkout -B "$branch"

rm -rf test

git add -A

git commit -m "Prepare $version release source"

git tag "$version"

git push origin "$branch"

git push origin "$version"

git checkout main
