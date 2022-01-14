defmodule CoreConfigTest do
  use ExUnit.Case

  alias Core.Config

  @moduletag :capture_log

  doctest Core.Config

  test "module exists" do
    assert is_list(Config.module_info())
  end

  test "constants" do
    assert Config.max_bytes_msg == 512_000
    assert Config.max_length_topic ==  512
  end
end
