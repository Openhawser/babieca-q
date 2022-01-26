defmodule BabiecaqWeb.ConfigController do
  use BabiecaqWeb, :controller

  def index(conn, _params) do
    json(conn, GenServer.call(:BabiecaQ, {:topic_list}))
  end

  def create(conn, %{"topic_name" => topic_name}) do
    case GenServer.call(:BabiecaQ, {:create_topic, topic_name}) do
      {:ok, value} -> json(conn, %{status: "ok", info: value})
      {:error, value} -> json(conn, %{status: "error", info: value})
    end

  end

end
