defmodule Core.MessageStore do
  import Core.Utilities, only: [
    topic_name_valid?: 1,
    exist_topic_storage?: 1,
    key_topic_message_name: 1,
    exist_storage_message_agent?: 1,
    valid_message?: 1]

  use Agent
  require Logger

  @moduledoc """
  Module that creates storage by topic, for them what it does is create a genserver and register it
     as babieca-topic-{topic name}-messages

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
      not topic_name_valid?(topic_name) ->
        Logger.error("Name of topic: #{topic_name} is incorrect, only use letters,numbers, _ or -")
        {:error, "Name of topic:#{topic_name} is incorrect, only use letters,numbers, _ or -"}
      exist_topic_storage?(topic_name) ->
        Logger.error("The storage of topic #{topic_name} already exists")
        {:error, "The storage of topic #{topic_name} already exists"}
      exist_storage_message_agent?(topic_name) ->
        Logger.error("The Agent of topic #{topic_name} already exists")
        {:error, "The Agent of topic #{topic_name} already exists"}
      true ->
        name_process = key_topic_message_name(topic_name)
        Agent.start_link(fn -> [] end, name: name_process)
        :ets.new(name_process, [:duplicate_bag, :protected, :named_table, read_concurrency: true])
        Logger.info("The storage #{name_process} has been create")
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
    if topic_name_valid?(topic_name) do
      name_process = key_topic_message_name(topic_name)
      if exist_topic_storage?(topic_name) do
        :ets.delete(name_process)
      else
        Logger.warning("The topic #{topic_name} storage not exists", [error_code: :pc_load_letter])
      end
      if exist_storage_message_agent?(topic_name) do
        Agent.stop(name_process)
      else
        Logger.warning("The Agent of topic #{topic_name} not exists", [error_code: :pc_load_letter])
      end
      {:ok, "The topic #{name_process} has been close"}
    else
      {:error, "Name of topic is incorrect, only use letters, numbers, _ or -"}
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
  @spec add_message(message, String.t()) :: {:ok | :error, String.t()}
  def add_message(message, topic_name)
  def add_message(message, topic_name) do
    if valid_message?(message) do
      name_process = key_topic_message_name(topic_name)
      key = UUID.uuid4()
      :ets.insert_new(name_process, {key, message})
      Agent.update(name_process, &([key | &1]))
    else
      Logger.error("Message is invalid")
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
  @spec get_messages(String.t(), String.t()) :: {:ok, list({String.t(), message})} | {:finished, String.t()}
  def get_messages(message_key, topic_name)
  def get_messages(nil, _), do: {:not_asigned, []}
  def get_messages(message_key, topic_name) do
    name_process = key_topic_message_name(topic_name)
    keys = Agent.get(
             name_process,
             &(
               &1
               |> Enum.take_while(fn x -> x != message_key  end))
           )
           |> Enum.reverse()
    result = keys
             |> Enum.map(
                  fn key -> [msg] = :ets.lookup(name_process, key)
                            msg
                  end
                )

    if Enum.empty?(result) do
      {:finished, "Don't have more messages"}
    else
      {:ok, result}
    end

  end

  @doc """
  Funtion to get the last id of message


  ## Parameters

      - topic_name: String with the name of the topic


  ## Return

      - UIID4 of last message or nil if the list is empty

  """
  @spec get_id_last_message(String.t()) :: String.t() | nil
  def get_id_last_message(topic_name) do
    Agent.get(
      key_topic_message_name(topic_name),
      fn x -> if x == [] do
                nil
              else
                List.first(x)
              end
      end
    )
  end

  @doc """
  Funtion to get the first id of message

  ## Parameters

      - topic_name: String with the name of the topic


  ## Return

      - UIID4 of first message or nil if the list is empty

  """
  @spec get_id_first_message(String.t()) :: String.t() | nil
  def get_id_first_message(topic_name) do
    Agent.get(
      key_topic_message_name(topic_name),
      fn x -> if x == [] do
                nil
              else
                List.last(x)
              end
      end
    )
  end

  @doc """
  Funtion to get the message with the id

  ## Parameters

      - topic_name: String with the name of the topic

      - id: UUID4 of message


  ## Return

      - {:ok, message} or {:error, "Not exist"}

  """
  @spec get_message_with_id(String.t(), String.t()) :: {:ok, message} | {:error, String.t()}
  def get_message_with_id(id, topic_name) do
    value = :ets.lookup(key_topic_message_name(topic_name), id)
    if value != [] do
      [{_, msg}] = value
      {:ok, msg}
    else
      {:error, "Not exist"}
    end
  end
end
