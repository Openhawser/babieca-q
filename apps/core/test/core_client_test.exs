defmodule CoreClientTest do
  use ExUnit.Case

  alias Core.Client

  @moduletag :capture_log

  doctest Core.Client

  test "module exists" do
    assert is_list(Core.Client.module_info())
  end
end
