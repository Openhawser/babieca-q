defmodule CoreClientTest do
  use ExUnit.Case

  alias Core.Client

  @moduletag :capture_log

  doctest Core.Client

  test "module exists" do
    assert is_list(Core.Client.module_info())
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
end
