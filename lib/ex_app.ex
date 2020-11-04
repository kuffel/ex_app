defmodule ExApp do
  @moduledoc """
  ExApp keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def version() do
    :ex_app
    |> Application.spec()
    |> Keyword.get(:vsn)
    |> List.to_string()
    |> Version.parse!()
  end
end
