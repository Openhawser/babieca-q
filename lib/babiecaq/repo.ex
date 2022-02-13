defmodule Babiecaq.Repo do
  use Ecto.Repo,
    otp_app: :babiecaq,
    adapter: Ecto.Adapters.Postgres
end
