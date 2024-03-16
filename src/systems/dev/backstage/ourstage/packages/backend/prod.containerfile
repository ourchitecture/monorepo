ARG NODE_VERSION=20.11.1
ARG OS_VERSION=bookworm-slim

ARG IMAGE_NAME=node
ARG IMAGE_REGISTRY=docker.io/library/
ARG IMAGE_SHA=sha256:2440a04b7b2ec79fc73d1f5e06fd90ba4f29ac57c129ba7adc3b3b0836774b3c
ARG IMAGE_TAG=${NODE_VERSION}-${OS_VERSION}@${IMAGE_SHA}

ARG BASE_IMAGE=${IMAGE_REGISTRY}${IMAGE_NAME}:${IMAGE_TAG}

ARG NPM_REGISTRY_URL_SUFFIX=//127.0.0.1:8081/repository/npm-all/
ARG NPM_REGISTRY_URL=http:${NPM_REGISTRY_URL_SUFFIX}
ARG NPM_REGISTRY_TOKEN

FROM ${BASE_IMAGE} as base

# Install isolate-vm dependencies, these are needed by the @backstage/plugin-scaffolder-backend.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  apt-get update \
  && apt-get install \
  --assume-yes \
  --no-install-recommends \
  build-essential \
  g++ \
  git \
  iputils-ping \
  libsqlite3-dev \
  python3 \
  && rm -rf /var/lib/apt/lists/* \
  && yarn config set python /usr/bin/python3

FROM base as prod_build

ARG NPM_REGISTRY_TOKEN
ARG NPM_REGISTRY_URL

USER node

WORKDIR /app

# This switches many Node.js dependencies to production mode.
ENV NODE_ENV=production

# syntax=docker/dockerfile:experimental
# RUN --mount=type=secret,id=npm_password \
#   git init \
#   ...
#   && echo "//localhost:8081/repository/npm-all/:_auth=\"$(cat /run/secrets/npm_password)\"" >> .npmrc \
RUN --mount=type=secret,id=npm_password \
  mkdir --parents /home/node/.cache/yarn \
  && npm config set registry ${NPM_REGISTRY_URL} \
  && yarn config set registry ${NPM_REGISTRY_URL}

# Install system dependencies with core files to
# avoid unnecessary docker cache invalidation.
# Append npm registry credentials to the yarn configuration.
# Backup specific files for later.
COPY --chown=node:node .yarnrc.yml package.json makefile ./
COPY --chown=node:node .yarn/releases/ .yarn/releases/
COPY --chown=node:node packages/app/package.json ./packages/app/
COPY --chown=node:node packages/backend/package.json ./packages/backend/
RUN --mount=type=cache,target=/home/node/.cache/yarn,sharing=locked,uid=1000,gid=1000 \
  printf "\nenableStrictSsl: false\nnpmAlwaysAuth: true\nnpmRegistryServer: ${NPM_REGISTRY_URL}\nunsafeHttpWhitelist: [127.0.0.1]\nnpmRegistries:\n    \"${NPM_REGISTRY_URL}\":\n        npmAlwaysAuth: true\n        npmAuthIdent: ${NPM_REGISTRY_TOKEN}\n" >> ./.yarnrc.yml \
  && yarn install --silent \
  && cp ./yarn.lock ./yarn.lock.bak

# Copy the source code.
# Restore the backup files.
# Install the system.
# IMPORTANT: Do not run `make check` here as tests require development environment dependencies.
COPY --chown=node:node . ./
RUN --mount=type=cache,target=/home/node/.cache/yarn,sharing=locked,uid=1000,gid=1000 \
  rm --force ./yarn.lock \
  && cp yarn.lock.bak ./yarn.lock \
  && make install

FROM base as prod_release

ARG NPM_REGISTRY_TOKEN
ARG NPM_REGISTRY_URL

USER node

WORKDIR /app

# This switches many Node.js dependencies to production mode.
ENV NODE_ENV production

# Copy backend distribution.
COPY --from=prod_build --chown=node:node /app/packages/backend/dist/bundle.tar.gz ./

RUN tar xzf ./bundle.tar.gz \
  && rm --force ./bundle.tar.gz

# Install system dependencies with core files to
# avoid unnecessary docker cache invalidation.
# Append npm registry credentials to the yarn configuration.
# Backup specific files for later.
COPY --chown=node:node ./.yarnrc.yml ./package.json ./
COPY --chown=node:node ./.yarn/releases/ ./.yarn/releases/
COPY --chown=node:node ./packages/app/package.json ./packages/app/
COPY --chown=node:node ./packages/backend/package.json ./packages/backend/
RUN --mount=type=cache,target=/home/node/.cache/yarn,sharing=locked,uid=1000,gid=1000 \
  printf "\nenableStrictSsl: false\nnpmAlwaysAuth: true\nnpmRegistryServer: ${NPM_REGISTRY_URL}\nunsafeHttpWhitelist: [127.0.0.1]\nnpmRegistries:\n    \"${NPM_REGISTRY_URL}\":\n        npmAlwaysAuth: true\n        npmAuthIdent: ${NPM_REGISTRY_TOKEN}\n" >> ./.yarnrc.yml \
  && yarn workspaces focus --production --all \
  && rm --recursive --force ./.yarn/ ./.yarnrc.yml ./packages/backend/README.md

# Copy frontend distribution.
COPY --from=prod_build --chown=node:node /app/packages/app/dist/ ./packages/app/dist/

# Copy the catalog information.
COPY --chown=node:node ./catalog-info.yaml ./
# Copy system configuration.
COPY --chown=node:node ./app-config.yaml ./app-config.production.yaml ./

CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]
