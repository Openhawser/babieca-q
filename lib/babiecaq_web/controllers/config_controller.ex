defmodule BabiecaqWeb.ConfigController do
  use BabiecaqWeb, :controller
  alias BabiecaqWeb.Controllers.Utils


  def index(conn, _params) do
    json(conn, GenServer.call(:BabiecaQCore, {:topic_list}))
  end

  def create(conn, %{"topic_name" => topic_name}) do
    Utils.json_response(conn, GenServer.call(:BabiecaQCore, {:create_topic, topic_name}))
  end

  def delete(conn, %{"topic_name" => topic_name}) do
    Utils.json_response(conn, GenServer.call(:BabiecaQCore, {:delete_topic, topic_name}))
  end




end
