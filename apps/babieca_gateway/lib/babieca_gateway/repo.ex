defmodule BabiecaGateway.Repo do
  use Ecto.Repo,
    otp_app: :babieca_gateway,
    adapter: Ecto.Adapters.Postgres
end
