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
    topic_name = "extist_user"
    user = "user"
    assert TopicManager.exist_user?(user, topic_name) == false
    TopicManager.start(topic_name)
    assert TopicManager.exist_user?(user, topic_name) == false
    assert TopicManager.add_user(user, topic_name) == {:ok, "The user:user has been added in topic extist_user"}
    assert TopicManager.exist_user?(user, topic_name) == true
    assert TopicManager.add_user(user, topic_name) == {:error, "The user:user exist in topic extist_user"}
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
  end
end
