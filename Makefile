default: help

.PHONY: help
help: ## Show help for all commands
	@echo
	@echo "Available commands:"
	@echo
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)


.PHONY: build 
build: ## Build container for testing changes
	@echo 'building picobook-dev:latest image...'
	@docker build -t picobook-dev:latest .

.PHONY: _test
_test:
	@docker run -t --rm picobook-dev:latest vim -c 'Vader! test/*.vader'

.PHONY: test
test: ## Execute tests in container
	$(MAKE) build
	$(MAKE) _test

.PHONY: _lint
_lint:
	@docker run -t --rm picobook-dev:latest vint test/*.vader plugin/*

.PHONY: lint
lint: ## Lint the vimscript code
	$(MAKE) build
	$(MAKE) _lint

.PHONY: test-local
test-local:  ## Execute tests locally (Not Recommended)
	@rm -f ~/.tickets/ticket.vim/*
	@/usr/bin/vim -c 'Vader! test/*.vader' 

