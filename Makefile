# Local dev helpers for the Themis homebrew tap.
#
# The brew targets need Homebrew (macOS or Linux) — they won't run on a plain
# Arch box. `bump` only needs gh + python3. Run `make help` for the list.

SHELL := /bin/bash
FORMULA := Formula/themis.rb

.DEFAULT_GOAL := help

.PHONY: help style audit livecheck install test bump

help: ## Show this help
	@grep -E '^[a-zA-Z0-9_-]+:.*?## ' $(MAKEFILE_LIST) \
		| awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

style: ## Check formula formatting (brew style / rubocop)
	brew style $(FORMULA)

audit: ## Audit the formula (brew audit --strict --online)
	brew audit --strict --online $(FORMULA)

livecheck: ## Show the latest upstream version brew livecheck detects
	brew livecheck --formula $(FORMULA)

install: ## Install the formula from this checkout
	brew install $(FORMULA)

test: ## Run the formula's test block (install first)
	brew test $(FORMULA)

bump: ## Detect the latest Themis release and update the formula in place
	./scripts/bump.sh
