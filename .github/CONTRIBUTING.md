# Contributing guidelines

[![GitHub Repo stars](https://img.shields.io/github/stars/ourchitecture/monorepo)](https://github.com/ourchitecture/monorepo)

Welcome one and all. This project is very early in development and will update contributor guidelines in the near future. Please [star this repository](https://github.com/ourchitecture/monorepo) and check back regularly for updates.

## Prerequisites

1. A docker-compatible CLI, like Rancher Desktop, Podman Desktop with a `docker` alias, or Docker Desktop (free for open source and small organizations, but requires a paid license for larger organizations).
2. The Long-Term Support version of NodeJS.

## Getting started

1. First, [setup the Nexus server](../src/systems/dev/nexus/README.md)
2. Once Nexus is configured and running and `yarn` has authenticated to the server
3. Navigate to the root of this repository and run `make` to install and check all projects in the monorepo.
