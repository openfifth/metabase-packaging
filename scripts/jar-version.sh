#!/usr/bin/env bash
set -euo pipefail

jar="${1:?usage: jar-version.sh <metabase.jar>}"

if [[ ! -s "$jar" ]]; then
  echo "Metabase JAR not found or empty: $jar" >&2
  exit 1
fi

unzip -tqq "$jar" >/dev/null

tag="$(unzip -p "$jar" version.properties \
  | awk -F= '$1 == "tag" { sub(/\r$/, "", $2); print $2; exit }')"

if [[ -z "$tag" ]]; then
  echo "Could not determine Metabase version from version.properties" >&2
  exit 1
fi

version="${tag#v}"

# reject release versions which look wrong in some way
if [[ ! "$version" =~ ^0\.[0-9]+\.[0-9]+([.][0-9]+)?$ ]]; then
  echo "Unexpected Metabase release tag in JAR: ${tag}" >&2
  exit 1
fi

printf '%s\n' "$version"
