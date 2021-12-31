defmodule Core.MessageStoreTest do
  use ExUnit.Case
  import ExUnit.CaptureLog
  require Logger

  alias Core.MessageStore, as: MessageStore
  alias Core.Utilities, as: Utilities


  test "module exists" do
    assert is_list(MessageStore.module_info())
  end

  test "create and close process with correct name" do
    log = capture_log(
      fn -> assert {:ok, "The storage babieca-topic-Test-messages has been create"} == MessageStore.start("Test") end
    )
    assert log =~ "The storage babieca-topic-Test-messages has been create"
    assert :ets.whereis(:"babieca-topic-Test-messages") != :undefined
    assert Process.whereis(:"babieca-topic-Test-messages") != nil
    MessageStore.stop("Test")
    assert :ets.whereis(:"babieca-topic-Test-messages") == :undefined
    assert Process.whereis(:"babieca-topic-Test-messages") == nil
  end

  test "create Topic exist" do
    MessageStore.start("Test")
    assert MessageStore.start("Test") == {:error, "The storage of topic Test already exists"}
  end

  test "Agent of topic exist" do
    name_process = :"babieca-topic-Test-messages"
    Agent.start_link(fn -> [] end, name: name_process)
    assert MessageStore.start("Test") == {:error, "The Agent of topic Test already exists"}
  end

  test "stop Topic not exist" do
    log = capture_log(fn -> MessageStore.stop("Test") end)
    for msg <- ["The topic Test storage not exists", "The Agent of topic Test not exists"] do
      assert log =~ msg
    end
  end

  test "topic name incorrect" do
    assert {:error, "Name of topic:Test Test is incorrect, only use letters,numbers, _ or -"} == MessageStore.start(
             "Test Test"
           )
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
    table = :ets.whereis(Utilities.key_topic_message_name(topic))
    msg = %{msg: "First message", timestamp: :os.system_time(:millisecond)}
    msg2 = %{msg: "Second message", timestamp: :os.system_time(:millisecond)}

    assert :ok == MessageStore.add_message(msg, topic)
    [{_, result}] = :ets.tab2list(table)
    assert result == msg
    assert :ok == MessageStore.add_message(msg2, topic)
    assert length(:ets.tab2list(table)) == 2
    assert :ets.tab2list(table)
           |> Enum.filter(fn {_, msg} -> msg not in [msg, msg2] end) == []

    assert {:error, "Message is invalid"} == MessageStore.add_message(%{msg: 1, timestamp: 1}, topic)
    assert {:error, "Message is invalid"} == MessageStore.add_message(%{msg: 1, timestamp: -1}, topic)
    assert {:error, "Message is invalid"} == MessageStore.add_message("", topic)
    MessageStore.stop(topic)
  end

  test "get messages and get_id.." do
    topic = "Test"
    proces_name = Utilities.key_topic_message_name(topic)
    MessageStore.start(topic)
    1..10
    |> Enum.map(
         fn x -> MessageStore.add_message(%{msg: "#{x} message", timestamp: :os.system_time(:millisecond)}, topic)end
       )

    message8 = 10 - 8
    {:ok, result} = MessageStore.get_messages(Enum.at(Agent.get(proces_name, &(&1)), message8), topic)
    assert result
           |> Enum.map(fn {_, value} -> value.msg end) == 9..10
                                                          |> Enum.map(fn x -> "#{x} message" end)
    message3 = 10 - 3
    {:ok, result} = MessageStore.get_messages(Enum.at(Agent.get(proces_name, &(&1)), message3), topic)
    assert result
           |> Enum.map(fn {_, value} -> value.msg end) == 4..10
                                                          |> Enum.map(fn x -> "#{x} message" end)

    assert {:not_asigned, []} = MessageStore.get_messages(nil, topic)


    {:ok, value} = MessageStore.get_message_with_id(MessageStore.get_id_last_message(topic), topic)
    assert value.msg == "10 message"
    {:ok, value} = MessageStore.get_message_with_id(MessageStore.get_id_first_message(topic), topic)
    assert value.msg == "1 message"
    MessageStore.stop(topic)
  end
  test "get messages and get_id.. empty" do
    topic = "Test"
    MessageStore.start(topic)
    {:not_asigned, []} == MessageStore.get_messages(nil, topic)
    assert  {:finished, "Don't have more messages"} == MessageStore.get_messages("key", topic)
    assert MessageStore.get_id_last_message(topic) == nil
    assert MessageStore.get_id_first_message(topic) == nil
    assert MessageStore.get_message_with_id(" ", topic) == {:error, "Not exist"}
  end

end