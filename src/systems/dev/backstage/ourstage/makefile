python3 := python3

ourstage_backend_port := 7007
ourstage_backend_container_port := 7007
ourstage_backend_env := dev
ourstage_backend_image_name := localhost/ourstage/backend-$(ourstage_backend_env):latest
ourstage_backend_container_name := ourstage-backend-$(ourstage_backend_env)

.DEFAULT_GOAL:=all

all: install-dependencies install check

.PHONY: install-dependencies-node
install-dependencies-node:
	@echo "Installing ourstage node dependencies..."
	@npm_config_loglevel=error yarn install --immutable
	@yarn workspaces foreach --all --interlaced run install --immutable
	@echo "Successfully installed ourstage node dependencies."

.PHONY: install-python-venv
install-python-venv:
	@$(python3) -m venv ./.venv

.PHONY: install-dependencies-python
install-dependencies-python: install-python-venv
	@activate_file_path="$(shell find ./.venv -name activate -type f)" \
	&& . "$$activate_file_path" \
	&& node ./tasks/install-dependencies-python.js

.PHONY: install-dependencies
install-dependencies: install-dependencies-node install-dependencies-python
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
	@node ./tasks/install-container.mjs

.PHONY: local-dev
local-dev:
	@echo "Starting ourstage locally..."
	@yarn dev
	@echo "Successfully started ourstage locally."

.PHONY: up
up: install-container
	@node ./tasks/start-container.mjs
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
	@node ./tasks/debug-container.mjs

.PHONY: logs
logs:
	@node ./tasks/get-container-logs.mjs

.PHONY: down
down:
	@node ./tasks/stop-container.mjs
.PHONY: stop
stop: down
.PHONY: shutdown
shutdown: down

.PHONY: upgrade
upgrade:
	@echo "Upgrading ourstage..."
	@yarn upgrade-interactive
	@echo "Successfully upgraded ourstage."
.PHONY: update
update: upgrade

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
