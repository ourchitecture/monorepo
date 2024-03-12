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
	@echo "Installing nexus container..."
	@docker build \
		./ \
		--file ./containerfile \
		--tag $(nexus_image_name)
	@echo "Successfully installed nexus container."

.PHONY: up
up: install
	@echo "Starting nexus container..."
	@docker run \
		--name $(nexus_container_name) \
		--network host \
		--detach \
		--volume $(nexus_data_volume_name):/nexus-data \
		$(nexus_image_name)
	@echo "" && echo "Our Nexus is running at http://localhost:$(nexus_port)" && echo ""
	@echo "Successfully started nexus container."

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
		--name debug-$(nexus_container_name) \
		--rm \
		--interactive \
		--tty \
		--entrypoint /bin/bash \
		--user node \
		--network host \
		$(nexus_container_name)
	@echo "Successfully started ourstage."

.PHONY: logs
logs:
	@echo "Retrieving ourstage logs..."
ifndef follow
	@docker logs $(nexus_container_name)
else
	@docker logs $(nexus_container_name) --follow
endif
	@echo "Retrieved ourstage logs."

.PHONY: clean
clean:
	@echo "Stopping ourstage..."
	@docker rm --force $(nexus_container_name)
	@echo "Stopping stopped ourstage."
.PHONY: down
down: clean
.PHONY: stop
stop: clean
.PHONY: shutdown
shutdown: clean

.PHONY: reset
reset: clean
	@echo "Resetting ourstage..."
	@docker volume rm --force $(nexus_data_volume_name)
	@echo "Successfully reset ourstage."
