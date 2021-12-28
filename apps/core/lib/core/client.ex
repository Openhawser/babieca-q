defmodule Core.Client do
  @moduledoc false

  def create_topic(topic_name) do
    GenServer.call(:BabiecaQ, {:create_topic, topic_name})
  end

end
