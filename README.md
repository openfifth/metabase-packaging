[![Tests passing!](https://forgejo.openfifth.co.uk/openfifth/metabase-packaging/badges/workflows/package.yml/badge.svg?branch=main)](https://forgejo.openfifth.co.uk/openfifth/metabase-packaging/actions)

# Metabase Debian packages and associated defaults

This repository rolls the official OSS version `metabase.jar` as a Debian
package and publishes it to the O5 Forgejo apt repo.

We do not build from source here - just find the latest pre-compiled jar
and wrap it up in a .deb with the various defaults and file locations 
used by the original Metabase packaging script.

`https://downloads.metabase.com/latest/metabase.jar` is used. We
ascertain version number by reading `version.properties` from the
recovered `.jar`.


## Package contents

The package retains the existing layout from live hosts:

```
/usr/local/metabase/metabase.jar
/usr/local/metabase/VERSION.MF
/usr/local/metabase/apache2.conf.example
/usr/local/metabase/env.example
/usr/local/metabase/rsyslog.conf.example
```

## Actions

The workflow is `.forgejo/workflows/package.yml`.

It runs:

- on pushes to `main` (useful if we're changing the packaging process without any actual release happening),
- every six hours,
- manually via `workflow_dispatch`.


## `apt` conventions

```
Owner:       openfifth
Base URI:    https://forgejo.openfifth.co.uk/api/packages/openfifth/debian
Suite:       Metabase
Component:   main
Arch:        all
```

See [docs/apt-client.md](docs/apt-client.md).

## JRE versions

At the time of writing, Temurin 25 is the JRE version recommended by the maintainer
and provided in their first party docker image. This is the fallback. Each
time a new package is built, the JRE version included with that version's
docker image is checked, and that version is used as the dep if possible.
