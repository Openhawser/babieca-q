defmodule Core do
  alias Core.TopicManager

  @moduledoc """
  Core is the orchestator module, this GenServer is the entrypoint to work
  """

  @name __MODULE__

  def start do
    case Process.whereis(@name) do
      nil ->
        pid = spawn(fn -> loop() end)
        Process.register(pid, @name)
        :ok
      _ ->
        :already_started
    end
  end

  def loop() do
    receive do
      {from, :create_topic, topic_name} -> send(from, TopicManager.start(topic_name))
                                           loop()
    end
  end


end
