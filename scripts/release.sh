#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: scripts/release.sh VERSION" >&2
}

if [ "$#" -ne 1 ]; then
  usage
  exit 64
fi

version="$1"
repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${repo_root}"

tag="v${version}"

if [ "$(git branch --show-current)" != "main" ]; then
  echo "Releases must be cut from main" >&2
  exit 1
fi

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Release requires a clean working tree before generated artifacts are created" >&2
  exit 1
fi

mix_version="$(mix eval --no-compile --no-deps-check 'Mix.Project.config()[:version] |> IO.write()')"
gleam_version="$(awk -F '"' '/^version = / { print $2; found = 1; exit } END { if (!found) exit 1 }' gleam.toml)"

if [ "${mix_version}" != "${version}" ]; then
  echo "Input version ${version} does not match Mix package version ${mix_version}" >&2
  exit 1
fi

if [ "${gleam_version}" != "${version}" ]; then
  echo "Input version ${version} does not match Gleam package version ${gleam_version}" >&2
  exit 1
fi

if git rev-parse -q --verify "refs/tags/${tag}" >/dev/null; then
  echo "Tag ${tag} already exists locally" >&2
  exit 1
fi

if git ls-remote --exit-code --tags origin "${tag}" >/dev/null 2>&1; then
  echo "Tag ${tag} already exists on origin" >&2
  exit 1
fi

gleam deps download
mix deps.get
gleam test
rm -rf build/prod/erlang
gleam export erlang-shipment
rm -f build/prod/erlang/*/_gleam_artefacts/gleam@@compile.erl
mix compile --warnings-as-errors
mix test

git add -f build/prod/erlang

if git diff --cached --quiet -- build/prod/erlang; then
  echo "No Gleam build artifacts were staged" >&2
  exit 1
fi

git commit -m "Release ${tag}"
git tag "${tag}"
git push origin "refs/tags/${tag}"
