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

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
