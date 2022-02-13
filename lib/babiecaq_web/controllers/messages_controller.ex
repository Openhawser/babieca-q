defmodule BabiecaqWeb.MessagesController do
  require Logger
  use BabiecaqWeb, :controller
  alias BabiecaqWeb.Controllers.Utils
  use PhoenixSwagger



  swagger_path :delete do
    PhoenixSwagger.Path.delete "/api/config/topic/{topic_name}/messages"
    summary "Delete messages of Topic"
    description "Delete all messages of Topic by topic_name"
    tag "Messages"
    parameters do
      topic_name :path, :string, "name of topic"
    end
    response 203, "{info: The messages of topic {topic_name} has been delete, status: ok}"
    response 404, "{info: Topic: {topic_name} not exist, status: error}"
  end
  def delete(conn, %{"topic_name" => topic_name}) do
    Utils.json_response(conn, Babiecaq.BabiecaQClient.delete_messages_of_topic(topic_name), 203, 404)
  end

  swagger_path :get do
    PhoenixSwagger.Path.get "/api/config/topic/{topic_name}/messages/{user_name}"
    summary "Get message of Topic"
    description "Get messages of Topic by topic_name"
    tag "Messages"
    parameters do
      topic_name :path, :string, "name of topic"
      user_name :path, :string, "name of user"
    end
    response 200, "{status: ok, info: message}"
    response 404, "{status: error, info: User: {user_name} not exist or info: Topic: {topic_name} not exist}"
  end
  def get(conn, %{"topic_name" => topic_name, "user_name" => user_name}) do
    Utils.json_response(conn, Babiecaq.BabiecaQClient.consumer_pull(user_name, topic_name), 200, 404)
  end

  swagger_path :create do
    PhoenixSwagger.Path.post "/api/config/topic/{topic_name}/messages"
    summary "Add message of Topic"
    description "Add messages of Topic by topic_name"
    tag "Messages"
    parameters do
      topic_name :path, :string, "name of topic"
      message :query, :string, "message to insert in the topic "
    end
    response 200, "{status: ok, info: The message has been insert in {topic_name}}"
    response 404, "{status: error, info: information to error}"
  end
  def create(conn, %{"topic_name" => topic_name, "message" => msg}) do
    Utils.json_response(conn, Babiecaq.BabiecaQClient.add_message_2_topic(msg, topic_name), 200, 404)
  end

end
