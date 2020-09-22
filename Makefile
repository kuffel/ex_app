SHELL := /bin/bash
VERSION=`cat ./VERSION`
DOCKER_BUILD_DIR=_build/prod/rel/ex_app
ROOT_DIR=$(realpath $(shell pwd))
DOCKER_TAG ?= latest
.DEFAULT_GOAL := help


# https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

setup: ## Get dependencies and build the project
	mix deps.get
	mix compile --force --warnings-as-errors

review: ## Run formatting checks, static code analysis and tests
	mix format --check-formatted
	mix credo
	mix coveralls.html --trace

run: ## Start the application
	iex -S mix phx.server

release: ## Build a release package
	MIX_ENV=prod mix release --overwrite