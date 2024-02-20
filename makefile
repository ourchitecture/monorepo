.DEFAULT_GOAL:=all

all: check

.PHONY: check
check:
	@yarn lint
