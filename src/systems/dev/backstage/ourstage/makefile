.DEFAULT_GOAL:=all

all: init install check

.PHONY: init
init:
	@echo "Initializing ourstage..."
	@yarn install --immutable
	@echo "Successfully initialized ourstage."

.PHONY: install
install:
	@echo "Installing ourstage..."
	@yarn run tsc:full
	@yarn run build:all
	@echo "Successfully installed ourstage."

.PHONY: check-audit
check-audit:
	@echo "Auditing ourstage..."
	@yarn audit --all
	@echo "Successfully audited ourstage."
.PHONY: audit
audit: check-audit

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
	@echo "Successfully formatted ourstage."

ourstage_backend_image_name := localhost/ourstage/backend
ourstage_backend_port := 7007
ourstage_backend_container_port := 7007
ourstage_backend_env := dev
ourstage_backend_container_name := ourstage-backend-$(ourstage_backend_env)

.PHONY: install-container
install-container:
	@echo "Installing ourstage container..."
	@docker build \
		./ \
		--file ./packages/backend/$(ourstage_backend_env).containerfile \
		--tag $(ourstage_backend_image_name)
	@echo "Successfully installed ourstage container."

.PHONY: up
up: install-container
	@echo "Starting ourstage..."
	@docker run \
		--name $(ourstage_backend_container_name) \
		--detach \
		--user node \
		--network host \
		$(ourstage_backend_image_name)
	@echo "" && echo "Ourstage is running at http://localhost:$(ourstage_backend_port)" && echo ""
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
	@echo "Starting ourstage..."
	@docker run \
		--name debug-$(ourstage_backend_container_name) \
		--rm \
		--interactive \
		--tty \
		--entrypoint /bin/bash \
		--user node \
		--network host \
		$(ourstage_backend_image_name)
	@echo "" && echo "Ourstage is running at http://localhost:$(ourstage_backend_port)" && echo ""
	@echo "Successfully started ourstage."

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
