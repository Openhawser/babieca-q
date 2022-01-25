defmodule BabiecaGatewayWeb.ConfigController do
  use BabiecaGatewayWeb, :controller

  def index(conn, _params) do
    json(conn, BabiecaQClient.topic_list())
  end

  def create(conn, %{"topic_name" => topic_name}) do
    case BabiecaQClient.create_topic(topic_name) do
      {:ok, value} -> json(conn, %{status: "ok", info: value})
      {:error, value} -> json(conn, %{status: "error", info: value})
    end

  end

end
