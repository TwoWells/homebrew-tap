# Local dev helpers for the TwoWells homebrew tap.
#
# The brew targets need Homebrew (macOS or Linux) — they won't run on a plain
# Arch box. `bump` only needs gh + python3. Run `make help` for the list.
#
# Per-formula targets default to themis; override with
# FORMULA=Formula/<name>.rb (e.g. make audit FORMULA=Formula/lattice.rb).

SHELL := /bin/bash
FORMULA ?= Formula/themis.rb

.DEFAULT_GOAL := help

.PHONY: help style audit livecheck install test bump

help: ## Show this help
	@grep -E '^[a-zA-Z0-9_-]+:.*?## ' $(MAKEFILE_LIST) \
		| awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

style: ## Check formula formatting (brew style / rubocop)
	# --except-cops: themis/lattice pin version inside on_linux (see tests.yml)
	brew style --except-cops FormulaAudit/ComponentsOrder $(FORMULA)

audit: ## Audit the formula (brew audit --strict --online)
	brew audit --strict --online $(FORMULA)

livecheck: ## Show the latest upstream version brew livecheck detects
	brew livecheck --formula $(FORMULA)

install: ## Install the formula from this checkout
	brew install $(FORMULA)

test: ## Run the formula's test block (install first)
	brew test $(FORMULA)

bump: ## Detect the latest upstream releases and update the formulae in place
	./scripts/bump.sh themis TwoWells/Themis
	./scripts/bump.sh lattice TwoWells/Lattice
	./scripts/bump.sh catenary TwoWells/Catenary catenary-macos-arm64 catenary-linux-amd64
