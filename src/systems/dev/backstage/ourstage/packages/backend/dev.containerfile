# This dockerfile builds an image for the backend package.
# It should be executed with the root of the repo as docker context.
#
# Before building this image, be sure to have run the following commands in the repo root:
#
# yarn install
# yarn tsc
# yarn build:backend
#
# Once the commands have been run, you can build the image using `yarn build-image`

ARG OS_VERSION=bookworm-slim
ARG NODE_VERSION=20.11.1

ARG IMAGE_REGISTRY=docker.io/library/
ARG IMAGE_NAME=node
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
  iputils-ping \
  python3 \
  && rm -rf /var/lib/apt/lists/* \
  && yarn config set python /usr/bin/python3

FROM base as dev_base

ARG NPM_REGISTRY_URL_SUFFIX
ARG NPM_REGISTRY_URL
ARG NPM_REGISTRY_TOKEN

# TODO: Use Nexus for the apt repository.
# sudo sed -i '/myrepository\.com/d' /etc/apt/sources.list \
# && echo "deb http://localhost:8081/repository/apt-public-debian-bookworm/ bookworm main" > /etc/apt/sources.list \
# http://localhost:8081/repository/apt-public-focal/

# Install sqlite3 dependencies. You can skip this if you don't use sqlite3 in the image,
# in which case you should also move better-sqlite3 to "devDependencies" in package.json.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  apt-get update \
  && apt-get install \
  --assume-yes \
  --no-install-recommends \
  curl \
  git \
  libsqlite3-dev \
  && rm -rf /var/lib/apt/lists/* \
  && git config --global init.defaultBranch main

FROM dev_base as dev_build

# From here on we use the least-privileged `node` user to run the backend.
USER node

# This should create the app dir as `node`.
# If it is instead created as `root` then the `tar` command below will fail: `can't create directory 'packages/': Permission denied`.
# If this occurs, then ensure BuildKit is enabled (`DOCKER_BUILDKIT=1`) so the app dir is correctly created as `node`.
WORKDIR /app

ENV NODE_ENV=development

# syntax=docker/dockerfile:experimental
# RUN --mount=type=secret,id=npm_password \
#   git init \
#   ...
#   && echo "//localhost:8081/repository/npm-all/:_auth=\"$(cat /run/secrets/npm_password)\"" >> .npmrc \
RUN --mount=type=secret,id=npm_password \
  git init \
  && git config user.email "dev.noreply@ourchitecture.io" \
  && git config user.name "Ourchitecture Automation" \
  && git commit --allow-empty --message "chore: initial commit" \
  && mkdir --parents /home/node/.cache/yarn \
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
# Install and check the system.
COPY --chown=node:node . ./
RUN --mount=type=cache,target=/home/node/.cache/yarn,sharing=locked,uid=1000,gid=1000 \
  rm --force ./yarn.lock \
  && cp yarn.lock.bak ./yarn.lock \
  && make install check

FROM dev_build as dev_release

USER node

WORKDIR /app

ENV NODE_ENV=development

# Start the development server.
CMD ["yarn", "dev"]
