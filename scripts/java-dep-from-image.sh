#!/usr/bin/env bash
set -euo pipefail

version="${1:?usage: java-dep-from-image.sh <metabase-version>}"
image="metabase/metabase:v${version}"

if ! command -v skopeo >/dev/null 2>&1; then
  echo "WARNING: skopeo is unavailable; cannot inspect $image" >&2
  exit 1
fi

if ! inspect="$(timeout 90s skopeo inspect "docker://${image}" 2>/dev/null)"; then
  echo "WARNING: could not inspect $image" >&2
  exit 1
fi

major="$(python3 -c '
import json, re, sys
try:
    data = json.load(sys.stdin)
except Exception:
    raise SystemExit(1)
for entry in data.get("Env", []):
    if entry.startswith("JAVA_VERSION="):
        value = entry.split("=", 1)[1]
        match = re.search(r"(?:jdk-)?([0-9]+)(?:[._+\-]|$)", value)
        if match:
            major = int(match.group(1))
            if 8 <= major <= 99:
                print(major)
                raise SystemExit(0)
raise SystemExit(1)
' <<<"$inspect")" || {
  echo "WARNING: $image does not expose a usable JAVA_VERSION" >&2
  exit 1
}

java_depends="temurin-${major}-jre"
echo "Nailed it. Detected Java ${major} from ${image}; using ${java_depends}" >&2
printf '%s\n' "$java_depends"
