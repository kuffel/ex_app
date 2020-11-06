# ExApp

[![ExApp](https://circleci.com/gh/kuffel/ex_app.svg?style=svg)](https://ex-app.kuffel.me)

This project is for my currently ongoing master thesis about `Implemetation of CI/CD for container based applications` at the FOM Dortmund.

It contains a [Phoenix Framework](https://www.phoenixframework.org/) based project that is build by [Circle CI](https://circleci.com/) and automatically deployed to AWS.

It has the following features:

- Static code analysis, formatting checks and test for every commit using GitHub actions
- Cirlce CI pipeline with various tests for every pull request
- Automatic serverless deployment using AWS Fargate and [terraform](https://www.terraform.io/)
- Automatic preview environments for pull requests
- Automatic cleanup of preview environments when pull requests are closed or merged
- Automatic deployment into production for merged pull requests

## Getting started

A Linux OS is the recommended environment for running this application. 

Install [Docker](https://www.docker.com/get-started) and [asdf](https://asdf-vm.com/) and execute the following plugins:

```bash
# Elixir/Erlang
apt-get -y install build-essential autoconf m4 libncurses5-dev libwxgtk3.0-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev xsltproc fop
asdf plugin-add erlang
asdf plugin-add elixir

# NodeJS
apt-get install dirmngr gpg
asdf plugin-add nodejs

# Add the following to your ~/.bashrc to make global package installation work
export PATH=$PATH:/usr/local/lib/npm/bin

# Terrform
asdf plugin-add terraform

# While being the application main folder run this install the versions specified in the .tool-versions file:
asdf install
```

## Running locally

You can set up the application by running the following make commands:

```bash
make setup
make run
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Running in docker

To build a docker image and run it you can use this commands:

```
make docker
make run_docker
```

