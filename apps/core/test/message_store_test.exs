defmodule Core.MessageStoreTest do
  use ExUnit.Case

  alias Core.MessageStore, as: MessageStore
  alias Core.Utilities, as: Utilities


  test "module exists" do
    assert is_list(MessageStore.module_info())
  end

  test "create and close process with correct name" do
    MessageStore.start("Test")
    assert :ets.whereis(:"babieca-topic-Test-messages") != :undefined
    MessageStore.stop("Test")
    assert :ets.whereis(:"babieca-topic-Test-messages") == :undefined
  end

  test "create Topic exist" do
    MessageStore.start("Test")
    assert MessageStore.start("Test") == {:error, "The storage of topic Test already exists"}
  end

  test "stop Topic not exist" do
    assert MessageStore.stop("Test") == {:error, "The topic Test not exists"}
  end

  test "topic name incorrect" do
    assert {:error, "Name of topic is incorrect, only use letters,numbers, _ or -"} == MessageStore.start("Test Test")
  end

  test "create multiples process and stop " do
    MessageStore.start("Test1")
    MessageStore.start("Test2")
    assert :ets.whereis(:"babieca-topic-Test1-messages") != :undefined
    assert :ets.whereis(:"babieca-topic-Test2-messages") != :undefined
    MessageStore.stop("Test1")
    MessageStore.stop("Test2")
    assert :ets.whereis(:"babieca-topic-Test1-messages") == :undefined
    assert :ets.whereis(:"babieca-topic-Test2-messages") == :undefined
  end

  test "create table ets and delete" do
    MessageStore.start("Test")
    assert :ets.whereis(:"babieca-topic-Test-messages") != :undefined
    MessageStore.stop("Test")
    assert :ets.whereis(:"babieca-topic-Test-messages") == :undefined
  end

  test "store messages" do
    topic = "Test"
    MessageStore.start(topic)
    table = :ets.whereis(Utilities.topic_name_storage(topic))
    result = MessageStore.add_message(topic, %{msg: "First message", timestamp: :os.system_time(:millisecond)})
    assert result == {:ok, "The message has been insert in #{topic}"}
    [{index, %{msg: text, timestamp: _}}] = :ets.tab2list(table)
    assert index == 1 and text == "First message"
    MessageStore.add_message(topic, %{msg: "Second message", timestamp: :os.system_time(:millisecond)})
    assert length(:ets.tab2list(table)) == 2
    assert :ets.last(table) == 2
    [{2, %{msg: text, timestamp: _}}] = :ets.lookup(table, 2)
    assert text == "Second message"
    assert {:error, "Message is invalid"} == MessageStore.add_message(topic, %{msg: 1, timestamp: 1})
    assert {:error, "Message is invalid"} == MessageStore.add_message(topic, %{msg: 1, timestamp: -1})
    assert {:error, "Message is invalid"} == MessageStore.add_message(topic, "")
  end

  test "next messages" do
    topic = "Test"
    table_name = Utilities.topic_name_storage(topic)
    MessageStore.start(topic)
    1..100 |> Enum.map(fn x -> :ets.insert(table_name, {x,"Test#{x}"}) end)
    assert MessageStore.get_next_messages(topic, 80) == {:ok, {81, "Test81"}}
    assert MessageStore.get_next_messages(topic, 60) == {:ok, {61, "Test61"}}
    assert MessageStore.get_next_messages(topic, 100) == {:finished, "Don't have more messages"}
    MessageStore.stop(topic)
  end
end