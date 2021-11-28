defmodule Core.MessageStoreTest do
  use ExUnit.Case

  alias Core.MessageStore, as: MessageStore


  test "module exists" do
    assert is_list(MessageStore.module_info())
  end

  test "create and close process with correct name" do
    MessageStore.start("Test")
    pid = Process.whereis(:"babieca-topic-Test-messages")
    assert Process.alive?(pid)
    MessageStore.stop("Test")
    assert  not Process.alive?(pid)
  end

  test "create multiples process and stop " do
    MessageStore.start("Test1")
    MessageStore.start("Test2")
    pid1 = Process.whereis(:"babieca-topic-Test1-messages")
    pid2 = Process.whereis(:"babieca-topic-Test1-messages")
    assert Process.alive?(pid1) and Process.alive?(pid2)
    MessageStore.stop("Test1")
    assert  not Process.alive?(pid1)
    MessageStore.stop("Test2")
    assert  not Process.alive?(pid2)
  end

end
