defmodule Core.TopicManager do
  require Logger
  require Core.Config

  alias Core.Utilities
  alias Core.MessageStore

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
  Start function create the topic infraestructure. Agent to save the user info and the messages stores
  """
  @spec start(String.t()) :: {:ok | :error, String.t()}
  def start(topic_name) do
    cond do
      String.length(topic_name) >= Core.Config.max_length_topic ->
        {:error, "The length of the topic_name exceeds the maximum #{Core.Config.max_length_topic}"}
      not Utilities.topic_name_valid?(topic_name) ->
        Logger.error("Name of topic: #{topic_name} is incorrect, only use letters,numbers, _ or -")
        {:error, "Name of topic: #{topic_name} is incorrect, only use letters,numbers, _ or -"}
      Utilities.exist_topic_agent?(topic_name) ->
        {:error, "Topic exist, I can't create"}
      true ->
        case MessageStore.start(topic_name) do
          {:ok, _} -> Agent.start_link(fn -> [] end, name: Utilities.key_topic_name(topic_name))
                      Logger.info("The Topic #{topic_name} has been create")
                      {:ok, "The Topic #{topic_name} has been create"}
          {:error, msg} -> {:error, msg}
        end

    end
  end

  def delete_topic(topic_name) do
    if Utilities.exist_topic_agent?(topic_name) do
      Agent.stop(Utilities.key_topic_name(topic_name))
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
        {:error, "The bytes of the message exceeds the maximum #{Core.Config.max_bytes_msg}"}
      true ->
        MessageStore.add_message(%{msg: msg, timestamp: :os.system_time(:millisecond)}, topic_name)
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
        Utilities.exist_topic_agent?(topic_name),
        Utilities.exist_topic_storage?(topic_name),
        Utilities.exist_storage_message_agent?(topic_name)
      ]
    )
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
    if Utilities.exist_topic_agent?(topic_name) do
      value = Agent.get(Utilities.key_topic_name(topic_name), &(&1[String.to_atom(user_name)]))
      if value == nil do
        false
      else
        true
      end
    else
      false
    end
  end

  @spec add_user(String.t(), String.t()) :: {:ok | :error, String.t()}
  def add_user(user_name, topic_name) do
    if exist_user?(user_name, topic_name) do
      {:error, "The user:#{user_name} exist in topic #{topic_name}"}
    else
      Agent.update(Utilities.key_topic_name(topic_name), &([{String.to_atom(user_name), 1} | &1]))
      {:ok, "The user:#{user_name} has been added in topic #{topic_name}"}
    end
  end

  @spec add_user(String.t(), String.t()) :: {:ok | :error | :finished, String.t()}
  def get_next_message(user_name, topic_name) do
    if not exist_user?(user_name, topic_name) do
      add_user(user_name, topic_name)
    end

  end

  def move_user_to_next_message(user_name, topic_name) do

  end


end


