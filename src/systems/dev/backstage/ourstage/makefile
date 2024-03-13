ourstage_backend_image_name := localhost/ourstage/backend:latest
ourstage_backend_port := 7007
ourstage_backend_container_port := 7007
ourstage_backend_env := dev
ourstage_backend_container_name := ourstage-backend-$(ourstage_backend_env)

.DEFAULT_GOAL:=all

all: install-dependencies install check

.PHONY: install-dependencies
install-dependencies:
	@echo "Installing ourstage dependencies..."
	@npm_config_loglevel=error yarn install --immutable
	@yarn workspaces foreach --all --interlaced run install --immutable
	@echo "Successfully installed ourstage dependencies."
.PHONY: init
init: install-dependencies

.PHONY: install
install:
	@echo "Installing ourstage..."
	@yarn run tsc:full
	@yarn run build:all
	@echo "Successfully installed ourstage."

# BUG: No solution found.
# See similar issue: https://github.com/yarnpkg/berry/issues/4117
# .PHONY: check-audit
# check-audit:
# 	@echo "Auditing ourstage..."
# 	@yarn audit --all
# 	@echo "Successfully audited ourstage."
# .PHONY: audit
# audit: check-audit

.PHONY: check-lint
check-lint:
	@echo "Linting ourstage..."
	@yarn run lint:all
	@yarn run prettier:check
	@echo "Successfully linted ourstage."
.PHONY: lint
lint: check-lint

.PHONY: check-test
check-test:
	@echo "Testing ourstage..."
	@yarn run test:all
	@echo "Successfully tested ourstage."
.PHONY: test
test: check-test

.PHONY: check
check: check-lint check-test

.PHONY: format
format:
	@echo "Formatting ourstage..."
	@yarn run fix
	@yarn run format
	@echo "Successfully formatted ourstage."

.PHONY: install-container
install-container:
	@echo "Installing ourstage container..."
	@docker build \
		--build-arg="NPM_REGISTRY_TOKEN=$$(cat .nexus-npm-password)" \
		--file=./packages/backend/$(ourstage_backend_env).containerfile \
		--network=host \
		--tag=$(ourstage_backend_image_name) \
		./
	@echo "Successfully installed ourstage container."

.PHONY: local-dev
local-dev:
	@echo "Starting ourstage locally..."
	@yarn dev
	@echo "Successfully started ourstage locally."

.PHONY: up
up: install-container
	@echo "Starting ourstage..."
	@docker run \
		--detach \
		--name $(ourstage_backend_container_name) \
		--network host \
		--user node \
		$(ourstage_backend_image_name)
	@printf "\n\nOurstage is running at http://localhost:$(ourstage_backend_port)\n\n"
	@echo "Successfully started ourstage."
.PHONY: start
start: up
.PHONY: startup
startup: up
.PHONY: serve
serve: up
.PHONY: run
run: up

.PHONY: debug
debug: install-container
	@echo "Debugging ourstage..."
	@docker run \
		--entrypoint /bin/bash \
		--interactive \
		--name debug-$(ourstage_backend_container_name) \
		--network host \
		--rm \
		--tty \
		--user node \
		$(ourstage_backend_image_name)
	@echo "Successfully debugged ourstage."

.PHONY: logs
logs:
	@echo "Retrieving ourstage logs..."
	@docker logs $(ourstage_backend_container_name)
	@echo "Retrieved ourstage logs."

.PHONY: down
down:
	@echo "Stopping ourstage..."
	@docker rm --force $(ourstage_backend_container_name)
	@echo "Stopping stopped ourstage."
.PHONY: stop
stop: down
.PHONY: shutdown
shutdown: down

.PHONY: upgrade
upgrade:
	@echo "Upgrading ourstage..."
	@yarn upgrade-interactive --latest
	@echo "Successfully upgraded ourstage."

.PHONY: clean
clean:
	@echo "Cleaning ourstage..."
	@if [ -d "./node_modules" ]; then yarn run clean || true; fi
	@echo "Successfully cleaned ourstage."

.PHONY: reset
reset: clean
	@echo "Resetting ourstage..."
	@rm --recursive --force \
		./.yarn/cache \
		./.yarn/install-state.gz \
		./node_modules \
		./packages/app/node_modules \
		./packages/backend/node_modules
	@echo "Successfully reset ourstage."
