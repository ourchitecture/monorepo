# Package caching with Nexus

This project installs a local Nexus server for package caching.

## Why

- Improves network bandwidth with localized caching.
- Improves multi-project dependency downloads with reusable caching.
- Improves support for offline development when packages already exist.
- Simulates Enterprise package proxies like JFrog Artifactory, Sonatype Nexus Repository Pro, and Inedo ProGet.

## Prerequisites

Docker-compatable CLI like Rancher Desktop with Docker, Podman Desktop with a `docker` alias, or Docker Desktop (free for Open Source, but requires a paid license in Enterprises).

## Getting started

1. Install an independent container volume that will survive infrastructure create, start, stop, and destroy lifecycles with the command `make install-storage`.
2. Build and run the Nexus server with `make up`.
3. Stop the server with `make down`.
4. Reset (destroy) everything with `make reset`.

### Configuring package registries

Once the server is started, custom users, registry proxies, and groups can be setup.

1. After the first time the server is started, retreive the default administrator password with the command `docker exec --interactive --tty our-nexus cat /nexus-data/admin.password`.
2. Login to <http://127.0.0.1:8081/> using the username "admin" and the password retrieved above. Set a new admin password.
3. Setup an NPM proxy to the public registry as well as an NPM "Group" with the name "npm-all" containing the NPM proxy registry.
4. Create a new "dev" user with a password.
5. Navigate to the root of this repository and run the command `yarn npm login`. Enter the username "dev" along with the password.
6. Once logged in, it is now possible to run `make init` to install dependencies through the new package proxy.
