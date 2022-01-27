defmodule CoreTest do
  use ExUnit.Case

  alias Babiecaq.Core

  @moduletag :capture_log

  doctest Babiecaq.Core

  test "module exists" do
    assert is_list(Core.module_info())
  end

  test "start link" do
    Core.start_link()
  end

  test "flow complete" do
    topic_name = "test_flow_complete"
    user_name = "user"
    assert GenServer.call(:BabiecaQCore, {:create_user, user_name, topic_name}) == {:error, "Not exist topic"}
    assert GenServer.call(:BabiecaQCore, {:get_next_message, user_name, topic_name}) == {:error, "User not exist"}
    assert GenServer.call(:BabiecaQCore, {:create_topic, topic_name}) == {
             :ok,
             "The Topic test_flow_complete has been create"
           }
    assert GenServer.call(:BabiecaQCore, {:create_user, user_name, topic_name}) == {
             :ok,
             "The user: user has been added in topic test_flow_complete"
           }
    assert GenServer.call(:BabiecaQCore, {:create_user, user_name, topic_name}) == {
             :ok,
             "The user: user exist in the topic"
           }
    assert GenServer.call(:BabiecaQCore, {:get_next_message, user_name, topic_name}) == {:finished, "Not more messages"}
    GenServer.call(:BabiecaQCore, {:add_multiples_messages, topic_name, [%{a: 1, b: 2}, %{a: 2, b: 3}]})
    GenServer.call(:BabiecaQCore, {:add_message, topic_name, %{a: 3, b: 4}})
    {:ok, %{msg: msg, timestamp: _}} = GenServer.call(:BabiecaQCore, {:get_next_message, user_name, topic_name})
    assert  msg == %{a: 1, b: 2}
    assert GenServer.call(:BabiecaQCore, {:move_user_to_next_message, user_name, topic_name}) == :ok
    {:ok, %{msg: msg, timestamp: _}} = GenServer.call(:BabiecaQCore, {:get_next_message, user_name, topic_name})
    assert  msg == %{a: 2, b: 3}
    assert GenServer.call(:BabiecaQCore, {:move_user_to_next_message, user_name, topic_name}) == :ok
    {:ok, %{msg: msg, timestamp: _}} = GenServer.call(:BabiecaQCore, {:get_next_message, user_name, topic_name})
    assert  msg == %{a: 3, b: 4}
    assert GenServer.call(:BabiecaQCore, {:delete_messages, topic_name}) == {
             :ok,
             "The messages of topic test_flow_complete has been delete"
           }
    assert GenServer.call(:BabiecaQCore, {:delete_topic, topic_name}) == {:ok, "Topic: test_flow_complete has been deleted"}

  end
end
