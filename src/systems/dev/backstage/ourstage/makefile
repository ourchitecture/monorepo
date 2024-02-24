.DEFAULT_GOAL:=all

all: init install check

.PHONY: init
init:
	@echo "Initializing ourstage..."
	@yarn install --immutable
	@yarn workspaces foreach --all --interlaced run install --immutable
	@echo "Successfully initialized ourstage."

.PHONY: install
install:
	@echo "Installing ourstage..."
	@yarn workspaces foreach --all --interlaced run tsc
	@yarn workspaces foreach --all --interlaced run build
	@echo "Successfully installed ourstage."

.PHONY: check
check:
	@echo "Checking ourstage..."
	@yarn prettier:check
	@yarn workspaces foreach --all --interlaced run lint
	@yarn workspaces foreach --all --interlaced run test
	@echo "Successfully checked ourstage."
