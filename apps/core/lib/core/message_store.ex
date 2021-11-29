defmodule Core.MessageStore do
  import Core.Utilities, only: [
    topic_name_valid?: 1,
    exist_topic_storage?: 1,
    topic_name_storage: 1,
    valid_message?: 1]

  @moduledoc """
  Module that creates storage by topic, for them what it does is create a genserver and register it
     as babieca-topic- {topic name} -messages

     The messages will be stored in a table ets {non-negative integer as key, %{msg: str, timestamp: ~ D []}}
  """


  @doc """
    Creator of the process in charge of storing messages.

  ## Parameters

       - topic_name: String with the name of the topic

  ## Return

       - {:ok , "The process babieca-topic-topic_name-messages has been create"}

       - {:error , "error description"}

  """
  @spec start(String.t()) :: {:ok | :error, String.t()}
  def start(topic_name) do
    cond do
      not topic_name_valid?(topic_name) -> {:error, "Name of topic is incorrect, only use letters,numbers, _ or -"}
      exist_topic_storage?(topic_name) -> {:error, "The storage of topic #{topic_name} already exists"}
      true -> name_process = topic_name_storage(topic_name)
              :ets.new(name_process, [:ordered_set, :protected, :named_table, read_concurrency: true])
              {:ok, "The storage #{name_process} has been create"}
    end
  end

  @doc """
    Function to stop the server created to store message

  ## Parameters

      - topic_name: String with the name of the topic


  ## Return

       - {:ok , "The process babieca-topic-topic_name-messages has been close"}

       - {:error , "error description"}


  """
  @spec stop(String.t()) :: {:ok | :error, String.t()}
  def stop(topic_name) do
    cond do
      not topic_name_valid?(topic_name) -> {:error, "Name of topic is incorrect, only use letters, numbers, _ or -"}
      not exist_topic_storage?(topic_name) -> {:error, "The topic #{topic_name} not exists"}
      true -> name_process = topic_name_storage(topic_name)
              :ets.delete(name_process)
              {:ok, "The storage #{name_process} has been close"}
    end
  end

  @type message :: %{msg: String.t(), timestamp: non_neg_integer}

  @doc"""
  Function to add message

  ## Parameters

      - topic_name: String with the name of the topic

      - message: %{msg: str, timestamp: Unix Timestamp}


  ## Return

      - {:ok , "The message has been insert in topic_name"}

      - {:error , "error description"}

  """
  @spec add_message(String.t(), message) :: {:ok | :error, String.t()}
  def add_message(topic_name, message)
  def add_message(topic_name, message) do
    table_name = topic_name_storage(topic_name)
    if valid_message?(message) do
      last_index = :ets.last(table_name)
      result =
        case last_index do
          :"$end_of_table" -> :ets.insert_new(table_name, {1, message})
          _ -> :ets.insert_new(table_name, {last_index + 1, message})
        end
      case result do
        true ->
          {:ok, "The message has been insert in #{topic_name}"}
        false ->
          {:error, "The message has not been inserted in the #{topic_name} because the index already existed"}
      end
    else
      {:error, "Message is invalid"}
    end
  end

  @doc"""
    Function to get the following message to the message_id messages of a topic.

  ## Parameters

      - topic_name: String with the name of the topic

      - message_id: message id, integer

  ## Return

      - {:ok ,{id_message, message}} | {:finished, "Don't have more messages"}

  """
  @spec get_next_messages(String.t(), integer) :: {:ok, list({integer, message})} | {:finished, String.t()}
  def get_next_messages(topic_name, message_id) do
    result = :ets.lookup(topic_name_storage(topic_name), message_id + 1)
    case result do
      [] -> {:finished, "Don't have more messages"}
      [msg] -> {:ok, msg}
    end
  end

end