defmodule Core.MessageStore do
  use GenServer
  import Core.Utilities, only: [valid?: 1 , exist_topic_process?: 1]

  @moduledoc """
  Modulo encargado de crear el almacenamiento por topic, para ellos lo que hace es crear un genserver y registrarlo
  como babieca-topic-{topic name}-messages

  Los mensajes serán almacenados como una Keyword lists. Será una pila, es decir el mensaje más nuevo estará el primero
  Cada elemento de esta keywordlist será
  {num mensaje en string, %{message: "", datatime: ~D()}
  """
  @impl true
  @spec init(any()) :: Tuple
  def init(_), do: {:ok, []}

  @doc """
    Creador del proceso encargado de almacenar los mensajes.

  ## Parameters

      - topic_name: String con el nombre del topic

  ## Return

      - {:ok | "The process babieca-topic-topic_name-messages has been create"}

      - {:error | "error description"}

  """
  @spec start(String.t()) :: {:ok | :error, String.t()}
  def start(topic_name) do
    cond do
      not valid?(topic_name) -> {:error, "Name of topic is incorrect, only use letters,numbers, _ or -"}
      exist_topic_process?(topic_name) -> {:error, "The topic #{topic_name} already exists"}
      true -> name_process = String.to_atom("babieca-topic-#{topic_name}-messages")
              GenServer.start_link(__MODULE__, [], name: name_process)
              {:ok, "The process #{name_process} has been create"}
    end
  end

  @doc """
    Función para parar el servidor creado para almacenar mensaje

  ## Parameters

          - topic_name: String con el nombre del topic


  ## Return

          - {:ok | "The process babieca-topic-topic_name-messages has been close"}

          - {:error | "error description"}
  """
  @spec stop(String.t()) :: {:ok | :error, String.t()}
  def stop(topic_name) do
    cond do
      not valid?(topic_name) -> {:error, "Name of topic is incorrect, only use letters, numbers, _ or -"}
      not exist_topic_process?(topic_name) -> {:error, "The topic #{topic_name} not exists"}
      true -> name_process = String.to_atom("babieca-topic-#{topic_name}-messages")
              pid = GenServer.whereis(name_process)
              GenServer.stop(pid)
              {:ok, "The process #{name_process} has been close"}
    end
  end

end
