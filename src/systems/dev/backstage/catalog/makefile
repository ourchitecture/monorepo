.PHONY: install
install:
	@echo "Installing ourstage catalog..."
	@docker build \
		--tag localhost/ourstage/catalog:latest \
		--file ./containerfile \
		./
	@echo "Installing started ourstage catalog."

.PHONY: debug
debug: install
	@echo "Debugging ourstage catalog..."
	@docker run \
		--name debug-ourstage-catalog \
		--rm \
		--interactive \
		--tty \
		--entrypoint /bin/sh \
		--user root \
		--network host \
		localhost/ourstage/catalog:latest
	@echo "Successfully debugged ourstage catalog."

.PHONY: up
up: install
	@echo "Starting ourstage catalog..."
	@docker run \
		--detach \
		--name ourstage-catalog \
		--network host \
		--user root \
		localhost/ourstage/catalog:latest
	@echo "Ourstage catalog is available at http://localhost:3005."
	@echo "Successfully started ourstage catalog."
.PHONY: start
start: up
.PHONY: startup
startup: up
.PHONY: serve
serve: up
.PHONY: run
run: up

.PHONY: logs
logs:
	@echo "Getting ourstage catalog logs..."
	@docker logs ourstage-catalog
	@echo "Successfully got ourstage catalog logs."

.PHONY: down
down:
	@echo "Stopping ourstage catalog..."
	@docker rm -f ourstage-catalog || true
	@echo "Successfully stopped ourstage catalog."
.PHONY: stop
stop: down
.PHONY: shutdown
shutdown: down

.PHONY: restart
restart: down up
