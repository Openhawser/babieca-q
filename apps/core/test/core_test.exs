defmodule CoreTest do
  use ExUnit.Case

  alias Core

  @moduletag :capture_log

  doctest Core

  test "module exists" do
    assert is_list(Core.module_info())
  end

  test "start link" do
      Core.start_link()
  end

  test "flow complete" do
    topic_name = "test_flow_complete"
    user_name = "user"
    assert GenServer.call({:global, :BabiecaQ}, {:create_user, user_name, topic_name}) == {:error, "Not exist topic"}
    assert GenServer.call({:global, :BabiecaQ}, {:get_next_message, user_name, topic_name}) == {:error, "User not exist"}
    assert GenServer.call({:global, :BabiecaQ}, {:create_topic, topic_name}) == {:ok, "The Topic test_flow_complete has been create"}
    assert GenServer.call({:global, :BabiecaQ}, {:create_user, user_name, topic_name}) == {:ok, "The user: user has been added in topic test_flow_complete"}
    assert GenServer.call({:global, :BabiecaQ}, {:create_user, user_name, topic_name}) == {:ok, "The user: user exist in the topic"}
    assert GenServer.call({:global, :BabiecaQ}, {:get_next_message, user_name, topic_name}) == {:finished, "Not more messages"}
    GenServer.call({:global, :BabiecaQ}, {:add_multiples_messages, topic_name, [%{a: 1, b: 2}, %{a: 2, b: 3}]})
    GenServer.call({:global, :BabiecaQ}, {:add_message, topic_name, %{a: 3, b: 4}})
    {:ok, %{msg: msg, timestamp: _}} = GenServer.call({:global, :BabiecaQ}, {:get_next_message, user_name, topic_name})
    assert  msg == %{a: 1, b: 2}
    assert GenServer.call({:global, :BabiecaQ}, {:move_user_to_next_message, user_name, topic_name}) == :ok
    {:ok, %{msg: msg, timestamp: _}} = GenServer.call({:global, :BabiecaQ}, {:get_next_message, user_name, topic_name})
    assert  msg == %{a: 2, b: 3}
    assert GenServer.call({:global, :BabiecaQ}, {:move_user_to_next_message, user_name, topic_name}) == :ok
    {:ok, %{msg: msg, timestamp: _}} = GenServer.call({:global, :BabiecaQ}, {:get_next_message, user_name, topic_name})
    assert  msg == %{a: 3, b: 4}
    assert GenServer.call({:global, :BabiecaQ}, {:delete_messages, topic_name}) == {:ok, "The messages of topic test_flow_complete has been delete"}
    assert GenServer.call({:global, :BabiecaQ}, {:delete_topic, topic_name}) ==  {:ok, "Topic: test_flow_complete has been deleted"}

  end
end
