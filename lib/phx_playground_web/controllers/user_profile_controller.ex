defmodule PhxPlaygroundWeb.UserProfileController do
  use PhxPlaygroundWeb, :controller

  alias PhxPlayground.Accounts
  alias PhxPlayground.Accounts.User
  alias PhxPlayground.Repo

  def edit(conn, _params) do
    render(conn, :edit, error_message: nil)
  end

  def update(conn, %{"user" => user_params}) do
    %{
      "current_password" => current_password, 
      "new_password" => new_password,
      "new_password_repeated" => new_password_repeated,
    } = user_params

    if new_password != new_password_repeated do
      render(conn, :edit, error_message: "Mismatch in newly entered passwords")
    else
      current_user = conn.assigns[:current_user]
      if User.valid_password?(current_user, current_password) do
        case Accounts.update_password(current_user, %{password: new_password, current_password: current_password}) do
          {:error, changeset} -> render(conn, :edit, error_message: Repo.changeset_errors_to_string(changeset))
          {:ok, _user} ->
            conn
              |> put_flash(:info, "Password changed")
              |> redirect(to: ~p"/profile/edit")
        end
      else
        render(conn, :edit, error_message: "Wrong current password")
      end
    end
  end
end
