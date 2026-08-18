#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../packaging.conf
source "$ROOT_DIR/packaging.conf"

deb="${1:?usage: publish.sh <file.deb>}"

: "${FORGEJO_PACKAGE_USER:?FORGEJO_PACKAGE_USER is required}"
: "${FORGEJO_PACKAGE_TOKEN:?FORGEJO_PACKAGE_TOKEN is required}"

[[ -s "$deb" ]]
url="${FORGEJO_BASE_URL}/api/packages/${FORGEJO_ORG}/debian/pool/${FORGEJO_SUITE}/${FORGEJO_COMPONENT}/upload"
response="$(mktemp)"
trap 'rm -f "$response"' EXIT

status="$({
  curl \
    --silent \
    --show-error \
    --user "${FORGEJO_PACKAGE_USER}:${FORGEJO_PACKAGE_TOKEN}" \
    --upload-file "$deb" \
    --output "$response" \
    --write-out '%{http_code}' \
    "$url"
})"

case "$status" in
  201)
    echo "published $(basename "$deb") to ${FORGEJO_SUITE}/${FORGEJO_COMPONENT}."
    ;;
  409)
    echo "package already exists in ${FORGEJO_SUITE}/${FORGEJO_COMPONENT}; treating 409 as success."
    ;;
  *)
    echo "package upload failed with HTTP ${status}" >&2
    cat "$response" >&2 || true
    exit 1
    ;;
esac
