#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/packaging.conf"

output="${1:?usage: fetch-latest.sh <output.jar>}"
mkdir -p "$(dirname "$output")"

tmp="${output}.tmp"
trap 'rm -f "$tmp"' EXIT

echo "Downloading latest official metabase.jar: ${METABASE_JAR_URL}" >&2
curl \
  --fail \
  --location \
  --retry 3 \
  --retry-delay 2 \
  --show-error \
  --output "$tmp" \
  "$METABASE_JAR_URL"

test -s "$tmp"
unzip -tqq "$tmp" >/dev/null

version="$($ROOT_DIR/scripts/jar-version.sh "$tmp")"

mv "$tmp" "$output"
trap - EXIT

printf '%s\n' "$version"
