defmodule Core.Client do
  require Logger

  @moduledoc """
    Client to access BabiecaQ. Can be done

    * Create topic
    * Add message in topic
    * Consume message from a topic
  """

  @spec create_topic(String.t()) :: {:ok | :error, String.t()}
  def create_topic(topic_name) do
    GenServer.call(:BabiecaQ, {:create_topic, topic_name})
  end

  @spec add_message_2_topic(String.t(), String.t()) :: {:ok | :error, String.t()}
  def add_message_2_topic(msg, topic_name) do
    GenServer.call(:BabiecaQ, {:add_message, topic_name, msg})
  end

  @spec add_multiples_messages_2_topic(list(String.t()), String.t()) :: {
                                                                          :ok | :incomplete,
                                                                          String.t(),
                                                                          list(String.t())
                                                                        }
  def add_multiples_messages_2_topic(messages, topic_name) do
    GenServer.call(:BabiecaQ, {:add_multiples_messages, topic_name, messages})
  end

  @spec delete_topic(String.t()) :: {:ok | :error, String.t()}
  def delete_topic(topic_name) do
    GenServer.call(:BabiecaQ, {:delete_topic, topic_name})
  end

  @spec create_user(String.t(), String.t()) :: {:error, String.t()} | {:ok, any()}
  def create_user(user_name, topic_name) do
    GenServer.call(:BabiecaQ, {:create_user, user_name, topic_name})
  end

  @spec consumer_pull(String.t(), String.t()) :: {:error, String.t()} | {:finished, String.t()} | {:ok, any()}
  def consumer_pull(user_name, topic_name) do
    case GenServer.call(:BabiecaQ, {:get_next_message, user_name, topic_name}) do
      {:error, value} -> Logger.error(value)
                         {:error, value}
      {:ok, value} -> case GenServer.call(:BabiecaQ, {:move_user_to_next_message, user_name, topic_name}) do
                        :ok -> {:ok, value}
                        {:error, msg} -> Logger.error(msg)
                                         {:error, msg, value}
                      end
      {:finished, value} -> Logger.info(value)
                            {:finished, "Don't have more messages"}
      {key, value} -> Logger.warning("The process has returned uncontrolled states #{inspect({key, value})}")
                      {key, value}
    end
  end
end