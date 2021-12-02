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
    assert Utilities.exist_topic_agent?("name") == false
    Agent.start_link(fn -> [] end, name: :"babieca-topic-Test")
    assert Utilities.exist_topic_agent?("Test") == true
  end
end
