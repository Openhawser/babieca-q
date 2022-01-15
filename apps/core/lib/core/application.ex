defmodule Core.Application do
  @moduledoc false
  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    Logger.info("The BabiecaQ has been started")

    children = [
      %{
        id: Core,
        start: {Core, :start_link, []},
        type: :supervisor
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Core.Supervisor]

    Supervisor.start_link(children, opts)
  end

  def stop(_), do: Logger.info("The BabiecaQ has been stoped")
end
