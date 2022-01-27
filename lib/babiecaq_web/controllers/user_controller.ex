defmodule BabiecaqWeb.UserController do
  use BabiecaqWeb, :controller
  use PhoenixSwagger
  alias BabiecaqWeb.Controllers.Utils

  swagger_path :index do
    get("/api/config/topic/{topic_name}/user")
    description("List of user in topic")
    produces "application/json"
    tag "Config Topic"
    parameters do
      topic_name :path, :string, "name of topic"
    end
    response 200, "{status: ok, info: [ user1, user2..] }"
    response 400, "{info: Topic: {topic_name} not exist, status: error}"
  end
  def index(conn, %{"topic_name" => topic_name}) do
    Utils.json_response(conn, Babiecaq.BabiecaQClient.user_list(topic_name), 200, 400)
  end

  swagger_path :create do
    post("/api/config/topic/{topic_name}/user")
    description("Create user in the topic")
    produces "application/json"
    tag "Config Topic"
    parameters do
      topic_name :path, :string, "name of topic"
      user_name :query, :string, "name of user"
    end
    response 201, "{status: ok, info: The user: {user_name} has been added in topic {topic_name}}"
  end
  def create(conn, %{"topic_name" => topic_name, "user_name" => user_name}) do
    Utils.json_response(conn, Babiecaq.BabiecaQClient.create_user(user_name, topic_name), 201, 400)
  end
end
