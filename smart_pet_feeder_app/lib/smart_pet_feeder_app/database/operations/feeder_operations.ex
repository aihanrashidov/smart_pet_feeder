defmodule SmartPetFeederApp.FeederOperations do
  @moduledoc """
  Feeder database operations module.
  """

  import Ecto.Query, warn: false
  alias SmartPetFeederApp.Users
  alias SmartPetFeederApp.Feeders
  alias SmartPetFeederApp.Repo

  @type serial() :: String.t()
  @type user_id() :: integer()
  @type feeder_id() :: integer()
  @type update_list() :: list()

  @doc """
  Inserts a new feeder to the database.
  ##Parameters:
  -serial: The device's serial number.
  -user_id: The id of the user to whom the feeder belongs.
  ##Examples:
  iex(1)> SmartPetFeederApp.FeederOperations.add("2387535", 1)
  """

  @spec add(serial(), user_id()) :: tuple()
  def add(serial, user_id) do
    feeder = %Feeders{
      serial: serial,
      device_status: nil,
      water_status: nil,
      food_status: nil,
      users_id: user_id
    }

    case Repo.insert(feeder) do
      {:ok, feeder} ->
        {:ok,
         %{
           id: feeder.id,
           serial: feeder.serial,
           device_status: feeder.device_status,
           water_status: feeder.water_status,
           food_status: feeder.food_status,
           users_id: feeder.users_id
         }}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Updates feeder field values by feeder id.
  ##Parameters:
  -feeder_id: The id of the pet that will be updated.
  -list: Field and their new content.
  ##Examples:
  iex(1)> SmartPetFeederApp.FeederOperations.update(1, [serial: "325895"])
  """

  @spec update(feeder_id(), update_list()) :: tuple()
  def update(feeder_id, list) do
    response =
      for {key, value} <- list do
        query = from(p in "feeders", where: p.id == ^feeder_id, update: [set: ^[{key, value}]])

        query
        |> Ecto.Queryable.to_query()
        |> Repo.update_all([])
        |> elem(0)
        |> db_response
      end

    case Enum.any?(response, fn x -> x != "Ok." end) do
      true ->
        {:error, :feeder_or_user_does_not_exist}

      false ->
        {:ok, :feeder_updated}
    end
  end

  @doc """
  Deletes a feeder from the database.
  ##Parameters:
  -feeder_id: The id of the feeder that will be deleted.
  ##Examples:
  iex(1)> SmartPetFeederApp.FeederOperations.delete_feeder(1)
  """

  @spec delete(feeder_id()) :: tuple()
  def delete(feeder_id) do
    query = from(p in "feeders", where: p.id == ^feeder_id)

    response =
      query
      |> Ecto.Queryable.to_query()
      |> Repo.delete_all([])
      |> elem(0)
      |> db_response

    case response != "Ok." do
      true ->
        {:error, :feeder_does_not_exist}

      false ->
        {:ok, :feeder_deleted}
    end
  end

  @doc """
  Get all feeders from the database for user.
  ##Parameters:
  -user_id: The id of the user where the feeders belong.
  ##Examples:
  iex(1)> SmartPetFeederApp.FeederOperations.get(1)
  """

  @spec get(user_id()) :: tuple()
  def get(user_id) do
    query =
      from(p in "feeders",
        where: p.users_id == ^user_id,
        select: [p.id, p.serial, p.device_status, p.water_status, p.food_status, p.users_id]
      )

    response =
      query
      |> Ecto.Queryable.to_query()
      |> Repo.all([])

    IO.inspect(response)

    feeders =
      for [id, serial, device_status, water_status, food_status, users_id] <- response,
          do: %{
            id: id,
            serial: serial,
            device_status: device_status,
            water_status: water_status,
            food_status: food_status,
            users_id: users_id
          }

    {:ok, feeders}
  end

  # Database response parser
  defp db_response(query_resp) do
    case query_resp do
      1 ->
        "Ok."

      :ok ->
        "Ok."

      error ->
        "Error #{inspect(error)}."
    end
  end
end
