defmodule CoreTopicManagerTest do
  use ExUnit.Case

  alias Core.TopicManager
  alias Core.MessageStore
  alias Core.Client

  @moduletag :capture_log

  doctest Core.TopicManager

  test "module exists" do
    assert is_list(TopicManager.module_info())
  end

  test "exist user" do
    topic_name = "exist_user"
    user = "user"
    assert TopicManager.exist_user?(user, topic_name) == false
    TopicManager.start(topic_name)
    assert TopicManager.exist_user?(user, topic_name) == false
    assert TopicManager.add_user(user, topic_name) == {:ok, "The user: user has been added in topic exist_user"}
    assert TopicManager.exist_user?(user, topic_name) == true
    assert TopicManager.add_user(user, topic_name) == {:error, "The user: user exist in topic exist_user"}
    TopicManager.delete_topic(topic_name)
  end

  test "start errors" do
    assert TopicManager.start(String.duplicate("a", 513)) == {
             :error,
             "The length of the topic_name exceeds the maximum 512"
           }
    assert TopicManager.start("1321*") == {
             :error,
             "Name of topic: 1321* is incorrect, only use letters,numbers, _ or -"
           }
    MessageStore.start("topic")
    assert TopicManager.start("topic") == {:error, "The storage of topic topic already exists"}
    TopicManager.delete_topic("topic")
  end

  test "get user key" do
    topic_name = "user_key"
    user = "user"
    TopicManager.start(topic_name)
    TopicManager.add_message_2_topic(%{a: 1, b: 2}, topic_name)
    TopicManager.add_user(user, topic_name)
    assert TopicManager.exist_user?(user, topic_name) == true
    assert is_atom(TopicManager.get_user_key(user, topic_name))
    TopicManager.delete_topic(topic_name)
  end

  test "get last message" do
    topic_name = "next_message"
    user = "user"
    TopicManager.start(topic_name)
    TopicManager.add_message_2_topic(%{a: 1, b: 2}, topic_name)
    TopicManager.add_message_2_topic(%{a: 3, b: 4}, topic_name)
    {:ok, %{msg: msg, timestamp: _}} = TopicManager.get_message(user, topic_name)
    assert msg == %{a: 3, b: 4}
    TopicManager.delete_topic(topic_name)
  end

  test "complete flow" do
    topic_name = "flow"
    user = "user"
    TopicManager.start(topic_name)
    assert TopicManager.get_message(user, topic_name) == {:finished, "Not more messages"}
    TopicManager.add_message_2_topic(%{a: 1, b: 2}, topic_name)
    {:ok, %{msg: msg, timestamp: _}} = TopicManager.get_message(user, topic_name)
    assert msg == %{a: 1, b: 2}

  end

end
