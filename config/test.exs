use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ex_app, ExAppWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :junit_formatter,
  print_report_file: true,
  prepend_project_name?: false,
  include_filename?: true
