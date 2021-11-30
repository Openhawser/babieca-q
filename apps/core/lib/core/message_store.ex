defmodule Core.MessageStore do
  import Core.Utilities, only: [
    topic_name_valid?: 1,
    exist_topic_storage?: 1,
    exist_topic_agent?: 1,
    key_topic_name: 1,
    valid_message?: 1]

  use Agent
  require Logger

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
      exist_topic_agent?(topic_name) -> {:error, "The Agent of topic #{topic_name} already exists"}
      true -> name_process = key_topic_name(topic_name)
              Agent.start_link(fn -> [] end, name: name_process)
              :ets.new(name_process, [:duplicate_bag, :protected, :named_table, read_concurrency: true])
              Logger.info("The storage #{name_process} has been create")
              :ok
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
      true -> name_process = key_topic_name(topic_name)
              if exist_topic_storage?(topic_name) do
                :ets.delete(name_process)
              else
                Logger.warning("The topic #{topic_name} storage not exists", [error_code: :pc_load_letter])
              end
              if exist_topic_agent?(topic_name) do
                Agent.stop(name_process)
              else
                Logger.warning("The Agent of topic #{topic_name} not exists", [error_code: :pc_load_letter])
              end
              {:ok, "The topic #{name_process} has been close"}
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
    if valid_message?(message) do
      name_process = key_topic_name(topic_name)
      key = UUID.uuid4()
      :ets.insert_new(name_process, {key, message})
      Agent.update(name_process, &([key | &1]))
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
  @spec get_messages(String.t(), integer) :: {:ok, list({integer, message})} | {:finished, String.t()}
  def get_messages(topic_name, message_key) do
    name_process = key_topic_name(topic_name)
    keys = Agent.get(
             name_process,
             &(
               &1
               |> Enum.take_while(fn x -> x != message_key  end))
           )
           |> Enum.reverse()
    result = keys
             |> Enum.map(
                  fn key -> [h] = :ets.lookup(name_process, key)
                            h
                  end
                )
    if result == [] do
      {:finished, "Don't have more messages"}
    else
      {:ok, result}
    end
  end
end

end