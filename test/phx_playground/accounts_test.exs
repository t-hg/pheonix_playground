defmodule PheonixPlayground.AccountsTest do
  use PheonixPlayground.DataCase

  alias PheonixPlayground.Accounts

  import PheonixPlayground.AccountsFixtures
  alias PheonixPlayground.Accounts.{User, UserToken}

  describe "get_user_by_name/1" do
    test "does not return the user if the name does not exist" do
      refute Accounts.get_user_by_name("unknown@example.com")
    end

    test "returns the user if the name exists" do
      %{id: id} = user = user_fixture()
      assert %User{id: ^id} = Accounts.get_user_by_name(user.name)
    end
  end

  describe "get_user_by_name_and_password/2" do
    test "does not return the user if the name does not exist" do
      refute Accounts.get_user_by_name_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the user if the password is not valid" do
      user = user_fixture()
      refute Accounts.get_user_by_name_and_password(user.name, "invalid")
    end

    test "returns the user if the name and password are valid" do
      %{id: id} = user = user_fixture()

      assert %User{id: ^id} =
               Accounts.get_user_by_name_and_password(user.name, valid_user_password())
    end
  end

  describe "get_user!/1" do
    test "raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user!(-1)
      end
    end

    test "returns the user with the given id" do
      %{id: id} = user = user_fixture()
      assert %User{id: ^id} = Accounts.get_user!(user.id)
    end
  end

  describe "register_user/1" do
    test "requires name and password to be set" do
      {:error, changeset} = Accounts.register_user(%{})

      assert %{
               password: ["can't be blank"],
               name: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates name uniqueness" do
      %{name: name} = user_fixture()
      {:error, changeset} = Accounts.register_user(%{name: name})
      assert "has already been taken" in errors_on(changeset).name

      # Now try with the upper cased name too, to check that name case is ignored.
      {:error, changeset} = Accounts.register_user(%{name: String.upcase(name)})
      assert "has already been taken" in errors_on(changeset).name
    end

    test "registers users with a hashed password" do
      name = unique_user_name()
      {:ok, user} = Accounts.register_user(valid_user_attributes(name: name))
      assert user.name == name
      assert is_binary(user.hashed_password)
      assert is_nil(user.password)
    end
  end

  describe "generate_user_session_token/1" do
    setup do
      %{user: user_fixture()}
    end

    test "generates a token", %{user: user} do
      token = Accounts.generate_user_session_token(user)
      assert user_token = Repo.get_by(UserToken, token: token)
      assert user_token.context == "session"

      # Creating the same token for another user should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%UserToken{
          token: user_token.token,
          user_id: user_fixture().id,
          context: "session"
        })
      end
    end
  end

  describe "get_user_by_session_token/1" do
    setup do
      user = user_fixture()
      token = Accounts.generate_user_session_token(user)
      %{user: user, token: token}
    end

    test "returns user by token", %{user: user, token: token} do
      assert session_user = Accounts.get_user_by_session_token(token)
      assert session_user.id == user.id
    end

    test "does not return user for invalid token" do
      refute Accounts.get_user_by_session_token("oops")
    end

    test "does not return user for expired token", %{token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.get_user_by_session_token(token)
    end
  end

  describe "delete_user_session_token/1" do
    test "deletes the token" do
      user = user_fixture()
      token = Accounts.generate_user_session_token(user)
      assert Accounts.delete_user_session_token(token) == :ok
      refute Accounts.get_user_by_session_token(token)
    end
  end

  describe "inspect/2 for the User module" do
    test "does not include password" do
      refute inspect(%User{password: "123456"}) =~ "password: \"123456\""
    end
  end
end
