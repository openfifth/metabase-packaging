#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../packaging.conf
source "$ROOT_DIR/packaging.conf"

version="${1:?usage: package-exists.sh <upstream-version>}"
base="${FORGEJO_BASE_URL}/api/packages/${FORGEJO_ORG}/debian"
packages_url="${base}/dists/${FORGEJO_SUITE}/${FORGEJO_COMPONENT}/binary-${PACKAGE_ARCH}/Packages"

index="$(mktemp)"
trap 'rm -f "$index"' EXIT

if ! curl --fail --silent --show-error --location "$packages_url" -o "$index"; then
  exit 1
fi

awk -v wanted_pkg="$PACKAGE_NAME" -v wanted_ver="$version" '
  BEGIN { RS=""; FS="\n" }
  {
    pkg=""; ver=""
    for (i=1; i<=NF; i++) {
      if ($i ~ /^Package: /) { pkg=substr($i, 10) }
      if ($i ~ /^Version: /) { ver=substr($i, 10) }
    }
    if (pkg == wanted_pkg && index(ver, wanted_ver "-") == 1) { found=1 }
  }
  END { exit(found ? 0 : 1) }
' "$index"
