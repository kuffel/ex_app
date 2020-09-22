# ExApp

This project is just my playground project. It was created using this command:

```bash
mix phx.new ex_app --no-ecto --no-webpack
```

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

# While being the application main folder run this install the versions specified in the .tool-versions file:
asdf install
```

## Running

You can setup the application by running the following make commands:

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

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
