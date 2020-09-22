defmodule ExAppWeb.PageController do
  use ExAppWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
