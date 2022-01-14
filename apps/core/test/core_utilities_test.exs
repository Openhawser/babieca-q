defmodule CoreUtilitiesTest do
  use ExUnit.Case

  alias Core.Utilities

  @moduletag :capture_log

  doctest Utilities

  test "module exists" do
    assert is_list(Utilities.module_info())
  end

  test "validate_name not string" do
    refute Utilities.topic_name_valid?(1)
    refute Utilities.topic_name_valid?(:valor)
  end

  test "validate_name string values" do
    refute Utilities.topic_name_valid?("test test")
    refute Utilities.topic_name_valid?("test test*")
    assert Utilities.topic_name_valid?("test_test")
  end

  test "key_topic_name create" do
    assert Utilities.exist_topic_agent?(1) == false
    assert Utilities.exist_topic_agent?(true) == false
    assert Utilities.exist_topic_agent?("name") == false
    Agent.start_link(fn -> [] end, name: :"babieca-topic-Test")
    assert Utilities.exist_topic_agent?("Test") == true
  end

  test "exist_storage_message_agent" do
    assert Utilities.exist_storage_message_agent?(1) == false
    assert Utilities.exist_storage_message_agent?(true) == false
    assert Utilities.exist_storage_message_agent?("name") == false
    Agent.start_link(fn -> [] end, name: :"babieca-topic-Test-messages")
    assert Utilities.exist_storage_message_agent?("Test") == true
  end

  test "exist topic storage not string" do
    assert Utilities.exist_ets_storage?(1) == false
  end

  test "all logic function" do
    assert Utilities.all([])
    assert Utilities.all([1]) == false
    assert Utilities.all([true, 1]) == false
    assert Utilities.all([true, true, true]) == true
    assert Utilities.all([true, false, true]) == false
  end

  test "validate if size of bytes of message is correct" do
    assert Utilities.valid_message?(1) == true
    assert Utilities.valid_message?([]) == true
    assert Utilities.valid_message?(%{}) == true
    assert Utilities.valid_message?({}) == true
    assert Utilities.valid_message?("") == true
    assert Utilities.valid_message?(nil) == false
    assert Utilities.valid_message?(String.duplicate("a", 511_994)) == true
    assert Utilities.valid_message?(String.duplicate("a", 511_995)) == false
  end

  test "split messages valid and invalid" do
    invalid = String.duplicate("a", 511_995)
    msgs = [1, 2, %{}, nil, invalid]
    assert Utilities.split_valid_invalid_msg(msgs) == {[1, 2, %{}], [nil, invalid]}
    assert Utilities.split_valid_invalid_msg([]) == {[], []}
  end
end
