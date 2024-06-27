defmodule PhxPlayground.Superuser do
  use GenServer

  alias PhxPlayground.Accounts

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    if Accounts.get_user_by_name("superuser") == nil do
      IO.puts("Superuser undefined.")
      password = IO.gets("Superuser password: ") |> String.trim("\n")
      Accounts.register_user(%{name: "superuser", password: password})
      if Accounts.get_user_by_name_and_password("superuser", password) == nil do
        raise "Superuser failed!"
      end
    else
      IO.puts "Superuser defined"
    end
    {:ok, state}
  end
end
