defmodule ExApp.Plugs.VersionPlug do
  @moduledoc """
  Adds the version and build to the response headers.
  """

  import Plug.Conn

  def init(options), do: options

  def call(conn, _opts) do
    version = ExApp.version()

    conn
    |> put_resp_header("x-app-version", "#{version.major}.#{version.minor}.#{version.patch}")
    |> put_resp_header("x-app-build", "#{version.build}")
  end
end
