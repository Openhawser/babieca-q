defmodule Babiecaq.Core.Utilities do
  require Babiecaq.Core.Config

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
  @spec exist_ets_storage?(Atom) :: boolean
  def exist_ets_storage?(name_storage)
  def exist_ets_storage?(name_storage) when not is_atom(name_storage), do: false
  def exist_ets_storage?(name_storage) do
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

  @doc """
    validate if the message is correct
  """
  @spec valid_message?(any()) :: boolean
  def valid_message?(nil), do: false
  def valid_message?(message) do
    byte_size = message
                |> :erlang.term_to_binary()
                |> :erlang.byte_size()
    byte_size <= Babiecaq.Core.Config.max_bytes_msg
  end
  @doc """
    validate if the message is incorrect
  """
  @spec valid_message?(any()) :: boolean
  def invalid_message?(message), do: not valid_message?(message)

  @doc"""
  This function separates the valid and invalid messages from the list of messages.
  """
  @spec split_valid_invalid_msg(list(String.t)) :: {list(String.t), list(String.t)}
  def split_valid_invalid_msg(messages, valid_messages \\ [], invalid_messages \\ [])
  def split_valid_invalid_msg([], valid, invalid), do: {Enum.reverse(valid), Enum.reverse(invalid)}
  def split_valid_invalid_msg([msg | t], valid, invalid) do
    if valid_message?(msg) do
      split_valid_invalid_msg(t, [msg | valid], invalid)
    else
      split_valid_invalid_msg(t, valid, [msg | invalid])
    end
  end
end