defmodule Core.TopicManager do
  require Logger

  alias Core.Utilities
  alias Core.MessageStore

  @moduledoc """
    Module that creates an agent by topic, where it will be saved

  ```Elixir
  [{"user", %{status: :to_assign, :asigned, id: id of message or nil}}
  ```

    This module provides all the functionality to obtain messages from users, the logic is as follows.

  Given a topic and a username

  * If the user is new, it registers it, looks for the most modern message, if not, it would be
  assigned the state :to_assign to be assigned in the next iteration if there is already data.

  * If the user is registered and has status: assigned and therefore a message id, we will serve the following message.

  * If the user is registered and has a status: to_assign the first message is searched and the message associated with this message is returned

  It also provides the functionality to update the id of the message that the user has.
  Since it should not be updated unless the message has been delivered to the consumer

  We also have the possibility to change the id of the message to the oldest or the most modern

  """

  def start(topic_name) do
    cond do
      not Utilities.topic_name_valid?(topic_name) ->
        {:error, "Name of topic is incorrect, only use letters,numbers, _ or -"}
      Utilities.exist_topic_agent?(topic_name) ->
        {:error, "Topic exist, I can't create"}
      true ->
        {result, msg} = MessageStore.start(topic_name)
        if result == :ok do
          Agent.start_link(fn -> [] end, name: Utilities.key_topic_name(topic_name))
          Logger.info("The Topic #{topic_name} has been create")
          {:ok, "The Topic #{topic_name} has been create"}
        else
          {result, msg}
        end
    end
  end

end
