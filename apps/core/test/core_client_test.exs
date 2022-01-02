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
  end

  test "add message" do
    topic_name = "test_add"
    assert Client.add_message_2_topic(%{a: 1, b: 2}, topic_name) == {:error, "Topic not exist"}
    Client.create_topic(topic_name)
    assert Client.add_message_2_topic(%{a: 1, b: 2}, topic_name) == {:ok, "The message has been insert in test_add"}
    Client.delete_topic(topic_name)
    assert Client.add_message_2_topic(%{a: 1, b: 2}, topic_name) == {:error, "Topic not exist"}
  end
end
