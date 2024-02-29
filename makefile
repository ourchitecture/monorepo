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

.PHONY: check-audit
check-audit:
	@echo "Auditing monorepo..."
	@yarn npm audit --all
	@echo "Successfully audited monorepo."

	@echo "Auditing independent projects..."
	@cd ./src/systems/dev/backstage/ourstage && make $@
	@echo "Successfully audited independent projects."
.PHONY: audit
audit: check-audit

.PHONY: check-lint
check-lint:
	@echo "Linting monorepo..."
	@yarn workspaces foreach --all --interlaced run lint
	@echo "Successfully linted monorepo."

	@echo "Linting independent projects..."
	@cd ./src/systems/dev/backstage/ourstage && make $@
	@echo "Successfully linted independent projects."
.PHONY: lint
lint: check-lint

.PHONY: check-test
check-test:
	@echo "Testing monorepo..."
	@yarn workspaces foreach --all --interlaced run test
	@echo "Successfully tested monorepo."

	@echo "Testing independent projects..."
	@cd ./src/systems/dev/backstage/ourstage && make $@
	@echo "Successfully tested independent projects."
.PHONY: test
test: check-test

.PHONY: check
check: check-audit check-lint check-test

.PHONY: format
format:
	@echo "Formatting monorepo..."
	@yarn workspaces foreach --all --interlaced run format
	@echo "Successfully formatted monorepo."

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

.PHONY: fix
fix:
ifndef m
	$(error message "m" is not set)
endif
	@git add .
ifdef f
	@git commit -asm "fix($(f)): $(m)"
else
	@git commit -asm "fix: $(m)"
endif

.PHONY: bug
bug: fix

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
	@gh pr create \
		--repo ourchitecture/monorepo \
		--base main \
		--fill-first \
		--assignee @
.PHONY: pr-chore
pr-chore: pr

.PHONY: pr-feat
pr-feat:
	@gh pr create \
		--repo ourchitecture/monorepo \
		--base main \
		--fill-first \
		--assignee @me \
		--label enhancement

.PHONY: pr-fix
pr-fix:
	@gh pr create \
		--repo ourchitecture/monorepo \
		--base main \
		--fill-first \
		--assignee @me \
		--label bug
.PHONY: pr-bug
pr-bug: pr-fix
