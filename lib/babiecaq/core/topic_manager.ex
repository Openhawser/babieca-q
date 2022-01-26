defmodule Babiecaq.Core.TopicManager do
  require Logger
  require Babiecaq.Core.Config

  alias Babiecaq.Core.Utilities
  alias Babiecaq.Core.MessageStore

  @moduledoc """
    Module that creates an agent by topic, where it will be saved

  ```Elixir
  [{:"user", %{status: :to_assign, :asigned, id: id of message or nil}},]
  ```

    This module provides all the functionality to obtain messages from users, the logic is as follows.

  Given a topic and a username

  * If the user is new, it registers it, looks for the most modern message, if not, it would be
  assigned the state :to_assign to be assigned in the next iteration if there is already data.

  * If the user is registered and has status :assigned and therefore a message id, we will serve the following message.

  * If the user is registered and has a status :to_assign the first message is searched and the message associated with this message is returned

  It also provides the functionality to update the id of the message that the user has.
  Since it should not be updated unless the message has been delivered to the consumer

  We also have the possibility to change the id of the message to the oldest or the most modern

  """

  @doc """
  Start function create the topic infraestructure. Ets to save the user info and the messages stores
  """
  @spec start(String.t()) :: {:ok | :error, String.t()}
  def start(topic_name) do
    cond do
      String.length(topic_name) >= Babiecaq.Core.Config.max_length_topic ->
        {:error, "The length of the topic_name exceeds the maximum #{Babiecaq.Core.Config.max_length_topic}"}
      not Utilities.topic_name_valid?(topic_name) ->
        Logger.error("Name of topic: #{topic_name} is incorrect, only use letters,numbers, _ or -")
        {:error, "Name of topic: #{topic_name} is incorrect, only use letters,numbers, _ or -"}
      exist_topic?(topic_name) ->
        {:error, "Topic exist, I can't create"}
      true ->
        case MessageStore.start(topic_name) do
          {:ok, _} ->
            :ets.new(Utilities.key_topic_name(topic_name), [:set, :protected, :named_table, read_concurrency: true])
            Logger.info("The Topic #{topic_name} has been create")
            {:ok, "The Topic #{topic_name} has been create"}
          {:error, msg} ->
            {:error, msg}
        end

    end
  end

  def delete_topic(topic_name) do
    storage_name = Utilities.key_topic_name(topic_name)
    if Utilities.exist_ets_storage?(storage_name) do
      :ets.delete(storage_name)
      MessageStore.stop(topic_name)
      {:ok, "Topic: #{topic_name} has been deleted"}
    else
      {:error, "Topic: #{topic_name} not exist"}
    end
  end

  @doc """
   Function to add message to topic
  """
  @spec add_message_2_topic(any(), String.t()) :: {:ok | :error, String.t()}
  def add_message_2_topic(msg, topic_name) do
    cond do
      not exist_topic?(topic_name) ->
        {:error, "Topic not exist"}
      Utilities.invalid_message?(msg) ->
        {:error, "The bytes of the message exceeds the maximum #{Babiecaq.Core.Config.max_bytes_msg}"}
      true -> MessageStore.add_message(%{msg: msg, timestamp: :os.system_time(:millisecond)}, topic_name)
    end
  end

  @doc """
   Function to add message to topic
  """
  @spec add_multiples_messages_2_topic(list(String.t()), String.t()) :: {:ok | :error, String.t()}
  def add_multiples_messages_2_topic(messages, topic_name) do
    if not_exist_topic?(topic_name) do
      {:error, "Topic not exist"}
    else
      {valid_msgs, invalid_msgs} = Utilities.split_valid_invalid_msg(messages)

      valid_msgs
      |> Enum.each(
           fn msg ->
             MessageStore.add_message(
               %{
                 msg: msg,
                 timestamp: :os.system_time(:millisecond)
               },
               topic_name
             )
           end
         )
      if length(invalid_msgs) > 0 do
        {:incomplete, "The following messages could not be inserted", invalid_msgs}
      else
        {:ok, "The messages has been insert in #{topic_name}"}
      end
    end
  end

  @doc """
  Function to know if topic has been create
  """
  @spec exist_topic?(String.t()) :: boolean
  def exist_topic?(topic_name) do
    Utilities.all(
      [
        Utilities.exist_ets_storage?(Utilities.key_topic_name(topic_name)),
        Utilities.exist_ets_storage?(Utilities.key_topic_message_name(topic_name)),
        Utilities.exist_storage_message_agent?(topic_name)
      ]
    )
  end

  @spec topic_list() :: [String.t()]
  def topic_list() do
    :ets.all()
    |> Enum.filter(
         fn x ->
           is_atom(x) and String.starts_with?(to_string(x), "babieca-topic") and not (
             String.ends_with?(to_string(x), "-messages"))
         end
       )
    |> Enum.map(fn x -> String.replace(to_string(x), "babieca-topic-", "") end)

  end

  @doc """
  Function to know if topic hasn't been create
  """
  @spec not_exist_topic?(String.t()) :: boolean
  def not_exist_topic?(topic_name) do
    not exist_topic?(topic_name)
  end

  @doc """
   Function to know if the user has been register in the topic
  """
  @spec exist_user?(String.t(), String.t()) :: boolean
  def exist_user?(user_name, topic_name) do
    if Utilities.exist_ets_storage?(Utilities.key_topic_name(topic_name)) do
      not Enum.empty?(:ets.lookup(Utilities.key_topic_name(topic_name), String.to_atom(user_name)))
    else
      false
    end
  end

  @spec add_user(String.t(), String.t()) :: {:ok | :error, String.t()}
  def add_user(user_name, topic_name) do
    if exist_topic?(topic_name) do
      if exist_user?(user_name, topic_name) do
        {:ok, "The user: #{user_name} exist in the topic"}
      else
        :ets.insert(
          Utilities.key_topic_name(topic_name),
          {String.to_atom(user_name), MessageStore.get_id_last_message(topic_name)}
        )
        {:ok, "The user: #{user_name} has been added in topic #{topic_name}"}
      end
    else
      {:error, "Not exist topic"}
    end
  end

  @spec get_message(String.t(), String.t()) :: {:ok | :error | :finished, String.t()}
  def get_message(user_name, topic_name) do
    if exist_user?(user_name, topic_name) do
      user_key = get_user_key(user_name, topic_name)
      next_key = MessageStore.get_next_id_message(user_key, topic_name)
      if next_key == nil do
        {:finished, "Not more messages"}
      else
        case MessageStore.get_message_with_id(next_key, topic_name) do
          {:ok, value} -> {:ok, value}
          {:error, "Not exist"} -> {:finished, "Not more messages"}
          {other, msg} -> {other, msg}
        end
      end
    else
      {:error, "User not exist"}
    end
  end

  @spec get_user_key(String.t(), String.t()) :: String.t() | nil
  def get_user_key(user_name, topic_name) do
    case :ets.match(Utilities.key_topic_name(topic_name), {String.to_atom(user_name), :"$1"}) do
      [[key]] -> key
      value -> value
    end
  end

  @spec move_user_to_next_message(String.t(), String.t()) :: :ok | {:error, any()}
  def move_user_to_next_message(user_name, topic_name) do
    try do
      old_key = get_user_key(user_name, topic_name)
      new_key = MessageStore.get_next_id_message(old_key, topic_name)
      if new_key != nil do
        :ets.insert(
          Utilities.key_topic_name(topic_name),
          {String.to_atom(user_name), new_key}
        )
      end
      :ok
    rescue
      e -> {:error, e}
    end
  end

  @spec delete_messages_of_topic(String.t()) :: {:ok | :error, String.t()}
  def delete_messages_of_topic(nil), do: {:error, "The name of topic is incorrect"}
  def delete_messages_of_topic(topic_name) do
    if exist_topic?(topic_name) do
      MessageStore.delete_messages_of_topic(topic_name)
    else
      {:error, "Topic: #{topic_name} not exist"}
    end

  end

end


