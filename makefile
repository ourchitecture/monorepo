.DEFAULT_GOAL:=all

all: check

.PHONY: install
install:
	@yarn install --immutable

.PHONY: check-repository
check-repository: install
	@yarn lint

.PHONY: check
check: check-repository
