defmodule Core.Client do
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


end
