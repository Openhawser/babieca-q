defmodule BabiecaqWeb.Controllers.Utils do
  @moduledoc false

  def json_response(conn, response) do
    case response do
      {:ok, value} -> Phoenix.Controller.json(conn, %{status: "ok", info: value})
      {:error, value} -> Phoenix.Controller.json(conn, %{status: "error", info: value})
    end
  end
end
