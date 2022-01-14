defmodule TopicManagerTest do
  use ExUnit.Case

  alias Core.TopicManager

  @moduletag :capture_log

  doctest TopicManager

  test "module exists" do
    assert is_list(TopicManager.module_info())
  end
end
