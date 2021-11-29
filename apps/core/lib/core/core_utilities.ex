defmodule Core.Utilities do
  @moduledoc """
  Módulo que contiene las funciones utilitarias del modulo core
  """

  @doc """
  Validación de nombres, solamente válidos letras, números y _ o -
  """
  @spec valid?(String.t()) :: boolean
  def valid?(name)
  def valid?(name) when not is_bitstring(name), do: false
  def valid?(name) do
    name
    |> String.downcase()
    |> String.graphemes()
    |> Enum.filter(fn x -> (x >= "a" and x <= "z") or x in ["_", "-"] or (x >= "0" and x <= "9") end)
    |> length() == String.length(name)
  end

  @doc """
  Validate if the topic has a process
  """
  @spec exist_topic_process?(String.t()) :: boolean
  def exist_topic_process?(topic_name)
  def exist_topic_process?(topic_name) when not is_bitstring(topic_name), do: false
  def exist_topic_process?(topic_name) do
    name_process = String.to_atom("babieca-topic-#{topic_name}-messages")
    case Process.whereis(name_process) do
      nil -> false
      _ -> true
    end
  end

  @doc """
  Create atom topic name
  """
  @spec topic_name_process(String.t()) :: atom
  def topic_name_process(topic_name) do
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