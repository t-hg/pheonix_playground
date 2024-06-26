defmodule PheonixPlayground.Repo do
  use Ecto.Repo,
    otp_app: :pheonix_playground,
    adapter: Ecto.Adapters.SQLite3
end
