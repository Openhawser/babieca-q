defmodule BabiecaqWeb.ConfigController do
  use BabiecaqWeb, :controller
  alias BabiecaqWeb.Controllers.Utils

  use PhoenixSwagger

  swagger_path :index do
    get("/api/config/topic")
    description("List of topics")
    produces "application/json"
    tag "Config Topic"
    response 200, "{status: ok, info: [ topic1, topic2..] }"
    response 400, "{status: error, info: Error info}"
  end

  def index(conn, _params) do
    Utils.json_response(conn, Babiecaq.BabiecaQClient.topic_list(), 200, 400)
  end

  swagger_path :create do
    post("/api/config/topic")
    description("Create topic")
    produces "application/json"
    tag "Config Topic"
    parameters do
      topic_name :query, :string, "name of topic"
    end
    response 201, "{info: The Topic {topic_name} has been create,status: ok}"
  end
  def create(conn, %{"topic_name" => topic_name}) do
    Utils.json_response(conn, Babiecaq.BabiecaQClient.create_topic(topic_name), 201, 400)
  end

  swagger_path :delete do
    PhoenixSwagger.Path.delete "/api/config/topic/{topic_name}"
    summary "Delete Topic"
    description "Delete a Topic by topic_name"
    tag "Config Topic"
    parameters do
      topic_name :path, :string, "name of topic"
    end
    response 203, "{info: Topic: {topic_name} has been deleted, status: ok}"
    response 404, "{info: Topic: {topic_name} not exist, status: error}"
  end
  def delete(conn, %{"topic_name" => topic_name}) do
    Utils.json_response(conn, Babiecaq.BabiecaQClient.delete_topic(topic_name), 203, 404)
  end



end
