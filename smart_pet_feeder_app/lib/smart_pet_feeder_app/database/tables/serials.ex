defmodule SmartPetFeederApp.Serials do
  use Ecto.Schema
  import Ecto.Changeset

  schema "serials" do
    field(:serial, :string)
  end

  def changeset(serials, attrs \\ %{}) do
    serials
    |> cast(attrs, [:serial])
  end
end
