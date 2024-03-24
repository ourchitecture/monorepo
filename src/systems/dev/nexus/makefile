nexus_image_name=localhost/nexus:latest
nexus_container_name := our-nexus
nexus_data_volume_name := nexus-data
nexus_port := 8081
nexus_container_port := 8081

.DEFAULT_GOAL:=all

all: install

.PHONY: install-storage
install-storage:
	@echo "Installing nexus container storage..."
	@docker volume create $(nexus_data_volume_name)
	@echo "Successfully installed nexus container storage."

.PHONY: install
install:
	@node ./tasks/install-container.mjs

.PHONY: up
up: install
	@node ./tasks/start-container.mjs
.PHONY: start
start: up
.PHONY: startup
startup: up
.PHONY: serve
serve: up
.PHONY: run
run: up

.PHONY: down
down:
	@node ./tasks/stop-container.mjs
.PHONY: stop
stop: down
.PHONY: shutdown
shutdown: down

.PHONY: restart
restart: down up

.PHONY: debug
debug: install
	@echo "Debugging ournexus..."
	@docker run \
		--name debug-ournexus \
		--rm \
		--interactive \
		--tty \
		--entrypoint /bin/bash \
		--user nexus \
		--network host \
		localhost/ournexus:latest
	@echo "Successfully debugged ournexus."

.PHONY: logs
logs:
	@node ./tasks/get-container-logs.mjs

.PHONY: clean
clean:
	@"$(MAKE)" down || true
	@echo "Cleaning ournexus..."
	@rm --recursive --force \
		./node_modules
	@echo "Successfully cleaned ournexus."

.PHONY: reset
reset: clean
	@echo "Resetting ourstage..."
	@docker rmi --force localhost/ournexus:latest || true
	@echo "Successfully reset ourstage."

.PHONY: reset-data
reset-data:
ifneq ($(confirm),1)
	$(error Required argument confirm is not set to 1)
endif
	@echo "Resetting ournexus data..."
	@docker volume rm --force ournexus-data || true
	@echo "Successfully reset ournexus data."
