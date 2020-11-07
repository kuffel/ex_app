SHELL := /bin/bash
VERSION=`cat ./VERSION`
GIT_HASH=`git log --pretty=format:'%h' -n 1`
DOCKER_BUILD_DIR=_build/prod/rel/ex_app
WORK_DIR=$(realpath $(shell pwd))
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

docker_release: ## Build a release within docker
	docker run --rm \
	-v $(WORK_DIR):/opt/ex_app \
	-w /opt/ex_app elixir:1.10.3 \
	/bin/bash -c "\
	mix local.hex --force && \
	mix local.rebar --force && \
  	mix deps.get && \
  	MIX_ENV=prod mix do compile --force, release --overwrite && \
	cp Dockerfile /opt/ex_app/_build/prod/rel/ex_app && \
 	chown $(shell id -u):$(shell id -g) /opt/ex_app/* -R"

docker: ## Build a docker image
	make docker_release
	docker build $(DOCKER_BUILD_DIR) --build-arg version=$(VERSION) -t kuffel/ex_app:$(VERSION)-$(GIT_HASH)

docker_run: ## Runs the latest image
	docker run --name ex_app --net=host -d -t kuffel/ex_app:$(VERSION)-$(GIT_HASH)

diagrams: ## Creates PNG files from the .puml file in thesis
	plantuml -tpng -o diagrams ./thesis/*.puml
