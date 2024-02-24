.DEFAULT_GOAL:=all

all: init install check

.PHONY: init
init:
	@echo "Initializing monorepo..."
	@yarn install --immutable
	@yarn workspaces foreach --all --interlaced run install --immutable
	@echo "Successfully initialized monorepo."

	@echo "Initializing independent projects..."
	@cd ./src/systems/dev/backstage/ourstage && make $@
	@echo "Successfully initialized independent projects."

.PHONY: install
install:
	@echo "Installing independent projects..."
	@cd ./src/systems/dev/backstage/ourstage && make $@
	@echo "Successfully installed independent projects."

.PHONY: check
check:
	@echo "Checking monorepo..."
	@yarn workspaces foreach --all --interlaced run lint
	@echo "Successfully checked monorepo."

	@echo "Checking independent projects..."
	@cd ./src/systems/dev/backstage/ourstage && make $@
	@echo "Successfully checked independent projects."

################################################################################
# Git convience commands
################################################################################

.PHONY: hack
hack:
ifndef name
	$(error name is not set)
endif
	@git-town hack $(name)

.PHONY: sync
sync:
	@git-town sync

.PHONY: chore
chore:
ifndef m
	$(error message "m" is not set)
endif
	@git add .
ifdef f
	@git commit -asm "chore($(f)): $(m)"
else
	@git commit -asm "chore: $(m)"
endif

.PHONY: bug
bug:
ifndef m
	$(error message "m" is not set)
endif
	@git add .
ifdef f
	@git commit -asm "bug($(f)): $(m)"
else
	@git commit -asm "bug: $(m)"
endif

.PHONY: docs
docs:
ifndef m
	$(error message "m" is not set)
endif
	@git add .
ifdef f
	@git commit -asm "docs($(f)): $(m)"
else
	@git commit -asm "docs: $(m)"
endif

.PHONY: ci
ci:
ifndef m
	$(error message "m" is not set)
endif
	@git add .
ifdef f
	@git commit -asm "ci($(f)): $(m)"
else
	@git commit -asm "ci: $(m)"
endif

.PHONY: feat
feat:
ifndef m
	$(error message "m" is not set)
endif
	@git add .
ifdef f
	@git commit -asm "feat($(f)): $(m)"
else
	@git commit -asm "feat: $(m)"
endif

.PHONY: pr
pr:
	@gh pr create --base main --fill-first --assignee @me --label enhancement
