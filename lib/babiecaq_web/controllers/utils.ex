defmodule BabiecaqWeb.Controllers.Utils do
  @moduledoc false
  import Plug.Conn

  def json_response(conn, response, ok_code \\ 200, error_code \\ 400) do
    case response do
      {:error, value} ->
        conn
        |> put_status(error_code)
        |> Phoenix.Controller.json(%{status: "error", info: value})
      {_, value} ->
        conn
        |> put_status(ok_code)
        |> Phoenix.Controller.json(%{status: "ok", info: value})
    end
  end
end
