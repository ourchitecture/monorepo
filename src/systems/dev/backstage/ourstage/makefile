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

.PHONY: check-audit
check-audit:
	@echo "Auditing ourstage..."
	@yarn npm audit --all
	@echo "Successfully audited ourstage."
.PHONY: audit
audit: check-audit

.PHONY: check-lint
check-lint:
	@echo "Linting ourstage..."
	@yarn workspaces foreach --all --interlaced run lint
	@echo "Successfully linted ourstage."
.PHONY: lint
lint: check-lint

.PHONY: check-test
check-test:
	@echo "Testing ourstage..."
	@yarn workspaces foreach --all --interlaced run test
	@echo "Successfully tested ourstage."
.PHONY: test
test: check-test

.PHONY: check
check: check-audit check-lint check-test

# Rely on monorepo formatting.
# While the monorepo treats Backstage as a separate project, tools like
# `prettier` and related VS Code extensions assume to use the root
# configuration and ".ignore" files. As a result, project-specific
# configuration and ".ignore" files are unexpectedly ignored. So, the
# solution is to rely on the monorepo's formatting entirely.
.PHONY: format
format:
	@cd ../../../../../ && make $@
