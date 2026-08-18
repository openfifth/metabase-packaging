# APT client setup

```
export FORGEJO_ORG="openfifth"
export FORGEJO_SUITE="Metabase"
export FORGEJO_COMPONENTS="main"
export FORGEJO_ARCH="all"

curl "https://forgejo.openfifth.co.uk/api/packages/$FORGEJO_ORG/debian/repository.key" \
  | gpg --dearmor \
  | sudo tee "/usr/share/keyrings/$FORGEJO_ORG.gpg" >/dev/null

cat <<EOF_SOURCES | sudo tee "/etc/apt/sources.list.d/$FORGEJO_ORG-$FORGEJO_SUITE.sources"
X-Repolib-Name: $FORGEJO_ORG/$FORGEJO_SUITE@$FORGEJO_COMPONENTS
Enabled: yes
Types: deb
Architectures: $FORGEJO_ARCH
Signed-by: /usr/share/keyrings/$FORGEJO_ORG.gpg
URIs: https://forgejo.openfifth.co.uk/api/packages/$FORGEJO_ORG/debian
Suites: $FORGEJO_SUITE
Components: $FORGEJO_COMPONENTS
X-Repolib-Default-Mirror: https://forgejo.openfifth.co.uk/api/packages/$FORGEJO_ORG/debian
X-Repolib-ID: $FORGEJO_ORG-$FORGEJO_SUITE@$FORGEJO_COMPONENTS
EOF_SOURCES

sudo apt update
apt-cache policy metabase
```
