defmodule SmartPetFeederApp.SerialOperations do
  @moduledoc """
  Serial database operations module.
  """

  import Ecto.Query, warn: false

  alias SmartPetFeederApp.Serials
  alias SmartPetFeederApp.Repo

  @type serial() :: String.t()

  @spec add(serial()) :: tuple()
  def add(serial) do
    serial = %Serials{
      serial: serial
    }

    case Repo.insert(serial) do
      {:ok, serial} ->
        {:ok,
         %{
           id: serial.id,
           serial: serial.serial
         }}

      {:error, error} ->
        {:error, error}
    end
  end

  @spec get() :: tuple()
  def get() do
    query =
      from(p in "serials",
        select: [p.id, p.serial]
      )

    response =
      query
      |> Ecto.Queryable.to_query()
      |> Repo.all([])

    serials =
      for [id, serial] <- response,
          do: %{
            id: id,
            serial: serial
          }

    {:ok, serials}
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
