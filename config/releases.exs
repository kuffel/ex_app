import Config

config :ex_app, ExAppWeb.Endpoint,
  http: [
    port: 4000,
    transport_options: [socket_opts: [:inet6]]
  ],
  debug_errors: false,
  code_reloader: false,
  check_origin: false,
  server: true,
  secret_key_base: System.fetch_env!("SECRET_KEY_BASE")

config :logger, level: :info
