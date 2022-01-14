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
end
