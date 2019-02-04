defmodule SmartPetFeederApp.PetOperations do

    @moduledoc """
    pet database operations module.
    """

    import Ecto.Query, warn: false
    alias SmartPetFeederApp.Users
    alias SmartPetFeederApp.pets
    alias SmartPetFeederApp.Repo

    @type name() :: String.t()
    @type type() :: String.t()
    @type age() :: integer()
    @type gender() :: String.t()
    @type breed() :: String.t()
    @type user_id() :: integer()
    @type pet_id() :: integer()
    @type update_list() :: list()

    @doc """
    Inserts a new pet to the database.
    ##Parameters:
    -name: The pet's name.
    -type: The owner's object where the pet will be added.
    -age: The age of the pet.
    -gender: The gender of the pet.
    -breed: The breed of the pet.
    -user_id: The id of the user to whom the pet belongs.
    ##Examples:
    iex(1)> SmartPetFeederApp.PetOperations.add("Rocky", "Dog", 4, "Male", "Pug", 1)
    """

    @spec add(name(), type(), age(), gender(), breed(), user_id()) :: tuple()
    def add(name, type, age, gender, breed, user_id) do
      pet = %pets{id: id, name: name, type: type, age: age, gender: gender, breed: breed, user_id: user_id}
        
      case Repo.insert(pet) do
        {:ok, pet} ->
          {:ok, %{id: pet.id, type: pet.type, age: pet.age, gender: pet.gender, breed: pet.breed, user_id: pet.user_id}}

        {:error, error} ->
          {:error, error}
      end
    end

    @doc """
    Updates pet field values by pet id.
    ##Parameters:
    -pet_id: The id of the pet that will be updated.
    -list: Field and their new content.
    ##Examples:
    iex(1)> SmartPetFeederApp.PetOperations.update(1, [name: "Max", age: 5])
    """

    @spec update(pet_id(), update_list()) :: tuple()
    def update(pet_id, list) do
      response = 
        for {key, value} <- list do
          query = from p in "pets", where: p.id == ^pet_id, update: [set: ^[{key, value}]]

          query
          |> Ecto.Queryable.to_query
          |> Repo.update_all([])
          |> elem(0)
          |> db_response
        end

        case Enum.any?(response, fn(x) -> x != "Ok." end) do
          true ->
            {:error, :pet_or_user_does_not_exist}

          false ->
            {:ok, :pet_updated}
        end
    end

    @doc """
    Deletes a pet from the database.
    ##Parameters:
    -pet_id: The id of the pet that will be deleted.
    ##Examples:
    iex(1)> SmartPetFeederApp.PetOperations.delete_pet(1)
    """

    @spec delete(pet_id()) :: tuple()
    def delete(pet_id) do
      query = from p in "pets", where: p.id == ^pet_id

      response = 
        query
        |> Ecto.Queryable.to_query
        |> Repo.delete_all([])
        |> elem(0)
        |> db_response

      case response != "Ok." do
        true ->
          {:error, :pet_does_not_exist}

        false ->
          {:ok, :pet_deleted}
      end
    end

    @doc """
    Get all pets from the database for user.
    ##Parameters:
    -user_id: The id of the user where the pets belong.
    ##Examples:
    iex(1)> SmartPetFeederApp.PetOperations.get(1)
    """

    @spec get(user_id()) :: tuple()
    def get(user_id) do
      query = from p in "pets", where: p.user_id == ^user_id, select: [p.name, p.type, p.age, p.gender, p.breed, p.user_id]

      response =
        query
        |> Ecto.Queryable.to_query
        |> Repo.all([])

      pets = for [name, type, age, gender, breed, user_id] <- response, do: %{id: pet.id, type: pet.type, age: pet.age, gender: pet.gender, breed: pet.breed, user_id: pet.user_id}
      {:ok, pets}
    end

    #Database response parser
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