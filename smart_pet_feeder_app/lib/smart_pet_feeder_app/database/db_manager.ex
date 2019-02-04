defmodule SmartPetFeederApp.DBManager do
  alias SmartPetFeederApp.UserOperations
  alias SmartPetFeederApp.PetOperations

  require Logger

  ## User validation schemas
  @user_add %{
    username: [required: true, validator: &is_binary/1],
    password: [required: true, validator: &is_binary/1],
    email: [required: true, validator: &is_binary/1],
    first_name: [required: true, validator: &is_binary/1],
    last_name: [required: true, validator: &is_binary/1]
  }

  @user_auth %{
    username: [required: true, validator: &is_binary/1],
    password: [required: true, validator: &is_binary/1]
  }

  @user_delete %{
    user_id: [required: true, validator: &is_integer/1]
  }

  @user_get %{}

  ## Pet validation schemas
  @pet_add %{
    name: [required: true, validator: &is_binary/1],
    type: [required: true, validator: &is_binary/1],
    age: [required: true, validator: &is_binary/1],
    gender: [required: true, validator: &is_binary/1],
    breed: [required: true, validator: &is_binary/1],
    user_id: [required: true, validator: &is_integer/1]
  }

  @pet_update %{
    pet_id: [required: true, validator: &is_integer/1],
    list: [required: true, validator: validator: &SmartPetFeederApp.DBManager.pet_list_validator/1]
  }

  @pet_delete %{
    pet_id: [required: true, validator: &is_integer/1]
  }

  @pet_get %{
    user_id: [required: true, validator: &is_integer/1]
  }

  @pet_update_list %{
    name: [validator: &is_binary/1],
    type: [validator: &is_binary/1],
    age: [validator: &is_binary/1],
    gender: [validator: &is_binary/1],
    breed: [validator: &is_binary/1],
    user_id: [validator: &is_integer/1]
  }

  ## Users operations
  def add(:user, params) do
    case Optium.parse(params, @user_add) do
      {:ok, _} ->
        if Kernel.map_size(@user_add) == Kernel.length(params) do
          [username: username, password: password, email: email, first_name: first_name, last_name: last_name] = params
          Kernel.apply(UserOperations, :add, [username, password, email, first_name, last_name])
        else
          {:error, :key_match_error}
        end

      {:error, _error} ->
        {:error, :key_match_error}
    end
  end

  def authenticate(:user, params) do
    case Optium.parse(params, @user_auth) do
      {:ok, _} ->
        if Kernel.map_size(@user_auth) == Kernel.length(params) do
          [username: username, password: password] = params
          Kernel.apply(UserOperations, :authenticate, [username, password])
        else
          {:error, :key_match_error}
        end

      {:error, _error} ->
        {:error, :key_match_error}
    end
  end

  def delete(:user, params) do
    case Optium.parse(params, @user_delete) do
      {:ok, _} ->
        if Kernel.map_size(@user_delete) == Kernel.length(params) do
          [user_id: user_id] = params
          Kernel.apply(UserOperations, :delete, [user_id])
    else
          {:error, :key_match_error}
        end

      {:error, _error} ->
        {:error, :key_match_error}
    end
  end

  def get(:user, params) do
    case Optium.parse(params, @user_get) do
      {:ok, _} ->
        if Kernel.map_size(@user_get) == Kernel.length(params) do
          [] = params
          Kernel.apply(UserOperations, :get, [])
    else
          {:error, :key_match_error}
        end

      {:error, _error} ->
        {:error, :key_match_error}
    end
  end

  ##pet operations
  def add(:pet, params) do
    case Optium.parse(params, @pet_add) do
      {:ok, _} ->
        if Kernel.map_size(@pet_add) == Kernel.length(params) do
          [name: name, type: type, age: age, gender: gender, breed: breed, user_id: user_id] = params
          Kernel.apply(PetOperations, :add, [name, type, age, gender, breed, user_id])
        else
          {:error, :key_match_error}
        end

      {:error, _error} ->
        {:error, :key_match_error}
    end
  end

  def update(:pet, params) do
    case Optium.parse(params, @pet_update) do
      {:ok, _} ->
        if Kernel.map_size(@pet_update) == Kernel.length(params) do
          [pet_id: pet_id, list: list] = params
          Kernel.apply(PetOperations, :update, [pet_id, list])
        else
          {:error, :key_match_error}
        end

      {:error, _error} ->
        {:error, :key_match_error}
    end
  end

  def delete(:pet, params) do
    case Optium.parse(params, @pet_delete) do
      {:ok, _} ->
        if Kernel.map_size(@pet_delete) == Kernel.length(params) do
          [pet_id: pet_id] = params
          Kernel.apply(PetOperations, :delete, [pet_id])
         else
          {:error, :key_match_error}
        end

      {:error, _error} ->
        {:error, :key_match_error}
    end
  end

  def get(:pet, params) do
    case Optium.parse(params, @pet_get) do
      {:ok, _} ->
        if Kernel.map_size(@pet_get) == Kernel.length(params) do
          [user_id: user_id] = params
          Kernel.apply(PetOperations, :get, [user_id])
        else
          {:error, :key_match_error}
        end

      {:error, _error} ->
        {:error, :key_match_error}
    end
  end

  def pet_list_validator(params) do
    case Optium.parse(params, @pet_update_list) do
      {:ok, _} ->
        valids = for {x, _y} <- params, do: Map.has_key?(@pet_update_list, x)
        if  Kernel.length(params) <= Kernel.map_size(@pet_update_list) && Enum.any?(valids, fn(x)-> x == false end) == false && params != [] do
          true
        else
          false
        end

      {:error, _error} -> 
        false
    end
  end