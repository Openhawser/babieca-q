defmodule ProducerTest do
  use ExUnit.Case
  doctest Producer

  test "greets the world" do
    assert Producer.hello() == :world
  end
end
