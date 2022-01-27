defmodule BabiecaqWeb.MessagesController do
  use BabiecaqWeb, :controller
  alias BabiecaqWeb.Controllers.Utils
  use PhoenixSwagger



  swagger_path :delete do
    PhoenixSwagger.Path.delete "/api/config/topic/{topic_name}/messages"
    summary "Delete messages of Topic"
    description "Delete all messages of Topic by topic_name"
    tag "Config Messages"
    parameters do
      topic_name :path, :string, "name of topic"
    end
    response 203, "{info: The messages of topic {topic_name} has been delete, status: ok}"
    response 404, "{info: Topic: {topic_name} not exist, status: error}"
  end
  def delete(conn, %{"topic_name" => topic_name}) do
    Utils.json_response(conn, Babiecaq.BabiecaQClient.delete_messages_of_topic(topic_name), 203, 404)
  end
end
