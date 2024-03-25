# Task automation workflow

- Engineers e.g. developers
- Automation servers e.g. Continuous Integration (CI)

## Building the system

1. Dependency management - optionally, initialize, install, and start the Nexus registry server to proxy / cache all dependencies
2. Initialize, install, check, and package.
   1. The project (monorepo root).
   2. Each system.
3. Deploy and check each system.

## Deployment targets

- Local machine e.g. engineer, automation server
- Remote host environment e.g. cloud
