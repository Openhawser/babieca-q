defmodule Babiecaq.BabiecaQClient do
  require Logger

  @moduledoc """
    Client to access BabiecaQ. Can be done

    * Create topic
    * Add message in topic
    * Consume message from a topic
  """

  @spec create_topic(String.t()) :: {:ok | :error, String.t()}
  def create_topic(topic_name) do
    GenServer.call(:BabiecaQCore, {:create_topic, topic_name})
  end

  @spec topic_list() :: [String.t()]
  def topic_list(), do: GenServer.call(:BabiecaQCore, {:topic_list})

  @spec delete_topic(String.t()) :: {:ok | :error, String.t()}
  def delete_topic(topic_name) do
    GenServer.call(:BabiecaQCore, {:delete_topic, topic_name})
  end

  @spec create_user(String.t(), String.t()) :: {:error, String.t()} | {:ok, any()}
  def create_user(user_name, topic_name) do
    GenServer.call(:BabiecaQCore, {:create_user, user_name, topic_name})
  end

  @spec user_list(String.t()) :: {:error | :ok, [String.t()] | String.t()}
  def user_list(topic_name), do: GenServer.call(:BabiecaQCore, {:user_list, topic_name})


  @spec add_message_2_topic(String.t(), String.t()) :: {:ok | :error, String.t()}
  def add_message_2_topic(msg, topic_name) do
    GenServer.call(:BabiecaQCore, {:add_message, topic_name, msg})
  end

  @spec add_multiples_messages_2_topic(list(String.t()), String.t()) :: {
                                                                          :ok | :incomplete,
                                                                          String.t(),
                                                                          list(String.t())
                                                                        }
  def add_multiples_messages_2_topic(messages, topic_name) do
    GenServer.call(:BabiecaQCore, {:add_multiples_messages, topic_name, messages})
  end

  @spec consumer_pull(String.t(), String.t()) :: {:error, String.t()} | {:finished, String.t()} | {:ok, any()}
  def consumer_pull(user_name, topic_name) do
    case GenServer.call(:BabiecaQCore, {:get_next_message, user_name, topic_name}) do
      {:error, value} -> Logger.error(value)
                         {:error, value}
      {:ok, value} -> case GenServer.call(:BabiecaQCore, {:move_user_to_next_message, user_name, topic_name}) do
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

  @spec delete_messages_of_topic(String.t()) :: {:ok | :error, String.t()}
  def delete_messages_of_topic(topic_name) do
    GenServer.call(:BabiecaQCore, {:delete_messages, topic_name})
  end

end