defmodule PhxPlayground.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias PhxPlayground.Repo

  alias PhxPlayground.Accounts.{User, UserToken}

  @doc """
  Gets a user by name.

  ## Examples

      iex> get_user_by_name("foo@example.com")
      %User{}

      iex> get_user_by_name("unknown@example.com")
      nil

  """
  def get_user_by_name(name) when is_binary(name) do
    Repo.get_by(User, name: name)
  end

  @doc """
  Gets a user by name and password.

  ## Examples

      iex> get_user_by_name_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_user_by_name_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_user_by_name_and_password(name, password)
      when is_binary(name) and is_binary(password) do
    user = Repo.get_by(User, name: name)
    if User.valid_password?(user, password), do: user
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Registers a user.
  
  ## Examples
  
      iex> register_user(%{field: value})
      {:ok, %User{}}
  
      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  
  """
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_user_session_token(token) do
    Repo.delete_all(UserToken.by_token_and_context_query(token, "session"))
    :ok
  end

  @doc """
  Updates user password
  """
  def update_password(user, attrs) do
    user
    |> User.password_changeset(attrs)
    |> Repo.update()
  end
end
