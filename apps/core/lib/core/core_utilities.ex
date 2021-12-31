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
    name_storage = key_topic_message_name(topic_name)
    case :ets.whereis(name_storage) do
      :undefined -> false
      _ -> true
    end
  end

  @doc """
  validate si exist the agent that save the messages
  """
  @spec exist_storage_message_agent?(String.t()) :: boolean
  def exist_storage_message_agent?(topic_name) when not is_bitstring(topic_name), do: false
  def exist_storage_message_agent?(topic_name) do
    topic_name
    |> key_topic_message_name()
    |> exit_agent?()
  end

  @doc """
  validate si exist the agent that save the user in the topic, and his position
  """
  @spec exist_topic_agent?(String.t()) :: boolean
  def exist_topic_agent?(topic_name) when not is_bitstring(topic_name), do: false
  def exist_topic_agent?(topic_name) do
    topic_name
    |> key_topic_name()
    |> exit_agent?()
  end

  defp exit_agent?(name) do
    if Process.whereis(name) == nil do
      false
    else
      true
    end
  end

  @doc """
  Create atom topic name to messages agent or messages ets
  """
  @spec key_topic_message_name(String.t()) :: atom
  def key_topic_message_name(topic_name) do
    String.to_atom("babieca-topic-#{topic_name}-messages")
  end

  @doc """
  Create atom topic name agent or ets topic
  """
  @spec key_topic_name(String.t()) :: atom
  def key_topic_name(topic_name) do
    String.to_atom("babieca-topic-#{topic_name}")
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

  @doc """
  All function of python all([true, true, true]) -> true,  all([true, false, true])-> false
  """
  @spec all(list(boolean)) :: boolean
  def all(list_of_boleans)
  def all([]), do: true
  def all([h | _]) when not is_boolean(h), do: false
  def all([h | t]) do
    if h == false do
      false
    else
      all(t)
    end
  end

end