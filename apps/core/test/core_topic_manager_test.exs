defmodule CoreTopicManagerTest do
  use ExUnit.Case

  alias Core.TopicManager
  alias Core.MessageStore

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
    TopicManager.add_message_2_topic(%{a: 1, b: 1}, topic_name)
    TopicManager.add_message_2_topic(%{a: 1, b: 2}, topic_name)
    TopicManager.add_message_2_topic(%{a: 3, b: 4}, topic_name)
    TopicManager.add_user(user, topic_name)
    TopicManager.add_message_2_topic(%{a: 4, b: 5}, topic_name)
    TopicManager.add_message_2_topic(%{a: 6, b: 7}, topic_name)
    {:ok, %{msg: msg, timestamp: _}} = TopicManager.get_message(user, topic_name)
    assert msg == %{a: 4, b: 5}
    TopicManager.delete_topic(topic_name)
  end

  test "complete flow" do
    topic_name = "flow"
    user = "user"
    user2 = "user2"
    TopicManager.start(topic_name)
    assert TopicManager.get_message(user, topic_name) == {:error, "User not exist"}
    TopicManager.add_user(user, topic_name)
    assert TopicManager.get_message(user, topic_name) == {:finished, "Not more messages"}
    TopicManager.add_message_2_topic(%{a: 1, b: 2}, topic_name)
    {:ok, %{msg: msg, timestamp: _}} = TopicManager.get_message(user, topic_name)
    assert msg == %{a: 1, b: 2}
    TopicManager.move_user_to_next_message(user, topic_name)
    assert TopicManager.get_user_key(user, topic_name) != nil
    assert TopicManager.get_message(user, topic_name) == {:finished, "Not more messages"}
    TopicManager.add_message_2_topic(%{a: 2, b: 3}, topic_name)
    TopicManager.add_user(user2, topic_name)
    TopicManager.add_message_2_topic(%{a: 3, b: 4}, topic_name)
    {:ok, %{msg: msg, timestamp: _}} = TopicManager.get_message(user, topic_name)
    assert msg == %{a: 2, b: 3}
    TopicManager.move_user_to_next_message(user, topic_name)
    {:ok, %{msg: msg, timestamp: _}} = TopicManager.get_message(user, topic_name)
    assert msg == %{a: 3, b: 4}
    {:ok, %{msg: msg, timestamp: _}} = TopicManager.get_message(user2, topic_name)
    assert msg == %{a: 3, b: 4}
    TopicManager.move_user_to_next_message(user, topic_name)
    TopicManager.move_user_to_next_message(user2, topic_name)
    assert TopicManager.get_message(user, topic_name) == {:finished, "Not more messages"}
    assert TopicManager.get_message(user2, topic_name) == {:finished, "Not more messages"}
    TopicManager.delete_topic(topic_name)
  end

end
