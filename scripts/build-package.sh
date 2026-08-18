#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

source "$ROOT_DIR/packaging.conf"

version="${1:?usage: build-package.sh <version> <metabase.jar>}"
source_jar="${2:?usage: build-package.sh <version> <metabase.jar>}"
package_version="${version}-${PACKAGE_REVISION}"

if [[ ! -s "$source_jar" ]]; then
  echo "didn't find a .jar: $source_jar" >&2
  exit 1
fi

unzip -tqq "$source_jar" >/dev/null

java_depends="$JAVA_DEPENDS"
if detected_java_depends="$("$ROOT_DIR/scripts/java-dep-from-image.sh" "$version")"; then
  java_depends="$detected_java_depends"
else
  echo "WARNING: could not determine Java dependency from the Metabase Docker image; using fallback: $JAVA_DEPENDS" >&2
fi
echo "Java dependency: $java_depends"

rm -rf build dist
mkdir -p build dist
rm -f debian/control debian/changelog

cp "$source_jar" build/metabase.jar
printf '%s\n' "$version" > build/VERSION.MF
sha256sum build/metabase.jar > "dist/metabase-${version}.jar.sha256"

python3 - "$java_depends" <<'PY'
from pathlib import Path
import sys
java_depends = sys.argv[1]
template = Path('debian/control.in').read_text()
Path('debian/control').write_text(template.replace('@JAVA_DEPENDS@', java_depends))
PY

cat > debian/changelog <<EOF_CHANGELOG
metabase (${package_version}) unstable; urgency=medium

  * Automated package of upstream Metabase ${version}.

 -- Jake Bateman <jake.bateman@openfifth.co.uk>  $(date -R)
EOF_CHANGELOG

dpkg-buildpackage -us -uc -b

built="../${PACKAGE_NAME}_${package_version}_${PACKAGE_ARCH}.deb"
if [[ ! -s "$built" ]]; then
  echo "Expected package was not produced: $built" >&2
  exit 1
fi

mv "$built" dist/

# Keep useful build metadata beside the .deb for Actions artifacts.
for suffix in changes buildinfo; do
  candidate="../${PACKAGE_NAME}_${package_version}_${PACKAGE_ARCH}.${suffix}"
  if [[ -f "$candidate" ]]; then
    mv "$candidate" dist/
  fi
done

echo "Built dist/${PACKAGE_NAME}_${package_version}_${PACKAGE_ARCH}.deb"
