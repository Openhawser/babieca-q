defmodule Core.Utilities do
  @moduledoc """
  Module that contains the utilitarian functions of the core module
  """

  @doc """
  Validation of names, only valid letters, numbers and _ or -
  """
  @spec topic_name_valid?(String.t()) :: boolean
  def topic_name_valid?(name)
  def topic_name_valid?(name) when not is_bitstring(name), do: false
  def topic_name_valid?(name) do
    name
    |> String.downcase()
    |> String.graphemes()
    |> Enum.filter(fn x -> (x >= "a" and x <= "z") or x in ["_", "-"] or (x >= "0" and x <= "9") end)
    |> length() == String.length(name)
  end

  @doc """
  Validate if the topic has a storage
  """
  @spec exist_topic_storage?(String.t()) :: boolean
  def exist_topic_storage?(topic_name)
  def exist_topic_storage?(topic_name) when not is_bitstring(topic_name), do: false
  def exist_topic_storage?(topic_name) do
    name_storage = String.to_atom("babieca-topic-#{topic_name}-messages")
    case :ets.whereis(name_storage) do
      :undefined -> false
      _ -> true
    end
  end

  @doc """
  Create atom topic name
  """
  @spec topic_name_storage(String.t()) :: atom
  def topic_name_storage(topic_name) do
    String.to_atom("babieca-topic-#{topic_name}-messages")
  end

  @doc """
    validate if the message is correct
    %{msg: str, timestamp: non negative integer}
  """
  @spec valid_message?(Core.MessageStore.message) :: boolean
  def valid_message?(message)
  def valid_message?(%{msg: text, timestamp: value}) when is_bitstring(text) and is_number(value) and value > 0,
      do: true
  def valid_message?(_), do: false
end