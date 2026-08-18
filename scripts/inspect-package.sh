#!/usr/bin/env bash
set -euo pipefail

deb="${1:?usage: inspect-package.sh <file.deb> <expected-version>}"
expected_version="${2:?usage: inspect-package.sh <file.deb> <expected-version>}"

[[ -s "$deb" ]]
[[ "$(dpkg-deb --field "$deb" Package)" == "metabase" ]]
[[ "$(dpkg-deb --field "$deb" Version)" == "$expected_version" ]]
[[ "$(dpkg-deb --field "$deb" Architecture)" == "all" ]]

contents="$(mktemp)"
trap 'rm -f "$contents"' EXIT

dpkg-deb --contents "$deb" > "$contents"

grep -qE 'usr/local/metabase/metabase\.jar$' "$contents"
grep -qE 'usr/local/metabase/VERSION\.MF$' "$contents"
grep -qE '(lib|usr/lib)/systemd/system/metabase\.service$' "$contents"

echo "Package metadata:"
dpkg-deb --field "$deb" Package Version Architecture Depends

echo
echo "Package contents:"
cat "$contents"
