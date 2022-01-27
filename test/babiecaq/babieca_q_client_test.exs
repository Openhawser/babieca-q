defmodule CoreClientTest do
  use ExUnit.Case
  alias Babiecaq.BabiecaQClient, as: Client

  @moduletag :capture_log

  doctest Babiecaq.BabiecaQClient

  test "module exists" do
    assert is_list(Babiecaq.BabiecaQClient.module_info())
  end

  test "create topic" do
    topic_name = "test"
    assert Client.create_topic(topic_name) == {:ok, "The Topic test has been create"}
    assert Client.create_topic(topic_name) == {:error, "Topic exist, I can't create"}
    Client.delete_topic(topic_name)
    assert Client.delete_topic(topic_name) == {:error, "Topic: test not exist"}
  end

  test "add message" do
    topic_name = "test_add"
    assert Client.add_message_2_topic(%{a: 1, b: 2}, topic_name) == {:error, "Topic not exist"}
    Client.create_topic(topic_name)
    assert Client.add_message_2_topic(%{a: 1, b: 2}, topic_name) == {:ok, "The message has been insert in test_add"}
    assert Client.add_message_2_topic(%{a: 1, b: String.duplicate("a", 1_000_000)}, topic_name) == {
             :error,
             "The bytes of the message exceeds the maximum 512000"
           }
    Client.delete_topic(topic_name)
    assert Client.add_message_2_topic(%{a: 1, b: 2}, topic_name) == {:error, "Topic not exist"}
  end

  test "add multiple messages" do
    topic_name = "test_add_multiple"
    assert Client.add_multiples_messages_2_topic([%{a: 1, b: 2}], topic_name) == {:error, "Topic not exist"}
    Client.create_topic(topic_name)
    assert Client.add_multiples_messages_2_topic([%{a: 1, b: 2}], topic_name) == {
             :ok,
             "The messages has been insert in test_add_multiple"
           }
    value = String.duplicate("a", 1_000_000)
    assert Client.add_multiples_messages_2_topic([%{a: 1, b: value}], topic_name) == {
             :incomplete,
             "The following messages could not be inserted",
             [%{a: 1, b: value}]
           }
    Client.delete_topic(topic_name)
    assert Client.add_multiples_messages_2_topic([%{a: 1, b: 2}], topic_name) == {:error, "Topic not exist"}
  end

  test "consumer" do
    topic_name = "test_consumer"
    user = "user"
    assert Client.create_user(user, topic_name) == {:error, "Not exist topic"}
    assert Client.consumer_pull(user, topic_name) == {:error, "User not exist"}
    assert Client.create_topic(topic_name) == {:ok, "The Topic test_consumer has been create"}
    assert Client.create_user(user, topic_name) == {:ok, "The user: user has been added in topic test_consumer"}
    assert Client.create_user(user, topic_name) == {:ok, "The user: user exist in the topic"}
    assert Client.consumer_pull(user, topic_name) == {:finished, "Don't have more messages"}
    Client.add_multiples_messages_2_topic([%{a: 1, b: 2}, %{a: 2, b: 3}, %{a: 3, b: 4}], topic_name)
    {:ok, %{msg: msg1, timestamp: _}} = Client.consumer_pull(user, topic_name)
    {:ok, %{msg: msg2, timestamp: _}} = Client.consumer_pull(user, topic_name)
    {:ok, %{msg: msg3, timestamp: _}} = Client.consumer_pull(user, topic_name)
    assert  msg1 == %{a: 1, b: 2}
    assert  msg2 == %{a: 2, b: 3}
    assert  msg3 == %{a: 3, b: 4}
    assert Client.consumer_pull(user, topic_name) == {:finished, "Don't have more messages"}
    Client.add_message_2_topic(%{a: 4, b: 5}, topic_name)
    {:ok, %{msg: msg4, timestamp: _}} = Client.consumer_pull(user, topic_name)
    assert  msg4 == %{a: 4, b: 5}
    assert Client.consumer_pull(user, topic_name) == {:finished, "Don't have more messages"}
    Client.delete_topic(topic_name)
  end

  test "flow complete" do
    topic_name = "test_flow_complete_client"
    user = "user"
    assert Client.create_user(user, topic_name) == {:error, "Not exist topic"}
    assert Client.consumer_pull(user, topic_name) == {:error, "User not exist"}
    assert Client.create_topic(topic_name) == {:ok, "The Topic test_flow_complete_client has been create"}
    assert Client.create_user(user, topic_name) == {:ok, "The user: user has been added in topic test_flow_complete_client"}
    Client.create_user("user2", topic_name)
    assert Client.user_list(topic_name) == {:ok, ["user2", "user"]}
    assert Client.create_user(user, topic_name) == {:ok, "The user: user exist in the topic"}
    assert Client.consumer_pull(user, topic_name) == {:finished, "Don't have more messages"}
    Client.add_multiples_messages_2_topic([%{a: 1, b: 2}, %{a: 2, b: 3}, %{a: 3, b: 4}], topic_name)
    {:ok, %{msg: msg1, timestamp: _}} = Client.consumer_pull(user, topic_name)
    assert  msg1 == %{a: 1, b: 2}
    assert Client.delete_messages_of_topic(topic_name) == {:ok, "The messages of topic test_flow_complete_client has been delete"}
    assert Client.consumer_pull(user, topic_name) == {:finished, "Don't have more messages"}
    Client.add_multiples_messages_2_topic([%{a: 1, b: 2}, %{a: 2, b: 3}, %{a: 3, b: 4}], topic_name)
    {:ok, %{msg: msg, timestamp: _}} = Client.consumer_pull(user, topic_name)
    assert  msg == %{a: 1, b: 2}
    {:ok, %{msg: msg, timestamp: _}} = Client.consumer_pull(user, topic_name)
    assert  msg == %{a: 2, b: 3}
    {:ok, %{msg: msg, timestamp: _}} = Client.consumer_pull(user, topic_name)
    assert  msg == %{a: 3, b: 4}
    assert Client.consumer_pull(user, topic_name) == {:finished, "Don't have more messages"}
    Client.delete_topic(topic_name)
    assert Client.delete_messages_of_topic(topic_name) == {:error, "Topic: test_flow_complete_client not exist"}
    assert Client.delete_messages_of_topic(nil) == {:error, "The name of topic is incorrect"}
  end
end
