defmodule PhxPlayground.Admin do
  use GenServer

  alias PhxPlayground.Accounts

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    if Accounts.get_user_by_name("admin") == nil do
      IO.puts("setting up admin account")
      password = IO.gets("admin password: ") |> String.trim("\n")
      Accounts.register_user(%{name: "admin", password: password})
      if Accounts.get_user_by_name_and_password("admin", password) == nil do
        raise "setting up admin account failed"
      end
    else
      IO.puts "admin account created"
    end
    {:ok, state}
  end
end
