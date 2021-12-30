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

  end


end
