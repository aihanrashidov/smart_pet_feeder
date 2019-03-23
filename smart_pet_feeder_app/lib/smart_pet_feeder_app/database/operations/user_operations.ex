defmodule SmartPetFeederApp.UserOperations do
  @moduledoc """
  User database operations module.
  """

  import Ecto.Query, warn: false
  alias SmartPetFeederApp.Users
  alias SmartPetFeederApp.Repo
  alias Comeonin.Bcrypt

  @type username() :: String.t()
  @type password() :: String.t()
  @type email() :: String.t()
  @type first_name() :: String.t()
  @type last_name() :: String.t()
  @type user_id() :: integer()

  @doc """
  Inserts a new user to the database (registration).
  ##Parameters:
  -username: The owner's username.
  -password: The owner's password.
  -email: The owner's email.
  -first_name: The owner's first name.
  -last_name: The owner's last name.
  ##Examples:
  iex(1)> SmartPetFeederApp.UserOperations.add("testuser", "testpassword", "testemail@test.com", "testfirstname", "testlastname")
  """

  @spec add(username(), password(), email(), first_name(), last_name()) :: tuple()
  def add(username, password, email, first_name, last_name) do
    user_changeset =
      %Users{}
      |> Users.changeset(%{
        username: username,
        password: password,
        email: email,
        first_name: first_name,
        last_name: last_name
      })

    case Repo.insert(user_changeset) do
      {:ok, user} ->
        {:ok,
         %{
           id: user.id,
           username: user.username,
           email: user.email,
           first_name: user.first_name,
           last_name: user.last_name
         }}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Gets all users from the database.
  ##Parameters:
  No parameters.
  ##Examples:
  iex(1)> SmartPetFeederApp.UserOperations.get()
  """

  @spec get() :: tuple()
  def get() do
    case Repo.all(Users) do
      [] ->
        {:ok, []}

      users ->
        u =
          for x <- users,
              do: %{
                id: x.id,
                username: x.username,
                email: x.email,
                first_name: x.first_name,
                last_name: x.last_name
              }

        {:ok, u}
    end
  end

  @doc """
  Gets user id by given username.
  ##Parameters:
  -username: The username of the owner whose id will be get.
  ##Examples:
  iex(1)> Qpdatabase.UserOperations.get_user_id("testuser")
  """

  @spec get_user_id(username()) :: {:ok, map()} | {:error, reason :: atom()}
  def get_user_id(username) do
    try do
      user = Repo.get_by!(Users, username: username)
      {:ok, %{user_id: user.id}}
    rescue
      _error -> {:error, :user_does_not_exist}
    end
  end

  @doc """
  Authenticates a user. Check if user exists in the database (login).
  ##Parameters:
  -username: The owner's username.
  -password: The owner's password.
  ##Examples:
  iex(1)> SmartPetFeederApp.UserOperations.authenticate("testuser", "testpassword")
  """

  @spec authenticate(username(), password()) :: tuple()
  def authenticate(username, password) do
    query = Ecto.Query.from(u in Users, where: u.username == ^username)

    Repo.one(query)
    |> check_password(password)
  end

  defp check_password(nil, _), do: {:error, :incorrect_usr_or_pass}

  defp check_password(user, password) do
    case Bcrypt.checkpw(password, user.password_hash) do
      true ->
        {:ok,
         %{
           id: user.id,
           username: user.username,
           email: user.email,
           first_name: user.first_name,
           last_name: user.last_name
         }}

      false ->
        {:error, :incorrect_usr_or_pass}
    end
  end

  @doc """
  Deletes a user from the database.
  ##Parameters:
  -user_id: The user's id.
  ##Examples:
  iex(1)> SmartPetFeederApp.UserOperations.delete(1)
  """

  @spec delete(user_id()) :: tuple()
  def delete(user_id) do
    user = Repo.get_by!(Users, id: user_id)

    case Repo.delete(user) do
      {:ok, _} ->
        {:ok, :user_deleted}

      {:error, error} ->
        {:error, error}
    end
  end
end
