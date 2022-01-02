defmodule Core do
  use GenServer
  alias Core.TopicManager


  @moduledoc """
  Core is the orchestator module, this GenServer is the entrypoint to work
  """

  @name __MODULE__

  def start_link(state \\ []) do
    GenServer.start_link(@name, state, name: :BabiecaQ)
  end
  def init(init_arg) do
    {:ok, init_arg}
  end

  def handle_call({:create_topic, topic_name}, _from, state) do
    {:reply, TopicManager.start(topic_name), state}
  end

  def handle_call({:add_message, topic_name, msg}, _from, state) do
    {:reply, TopicManager.add_message_2_topic(msg, topic_name), state}
  end
  def handle_call({:add_multiples_messages, topic_name, messages}, _from, state) do
    {:reply, TopicManager.add_multiples_messages_2_topic(messages, topic_name), state}
  end

end
