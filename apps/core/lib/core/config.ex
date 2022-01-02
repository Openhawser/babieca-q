defmodule Core.Config do
  @moduledoc """
  Configurate Module
  """


  defmacro max_bytes_msg, do: 512_000
  defmacro max_length_topic, do: 512


end
