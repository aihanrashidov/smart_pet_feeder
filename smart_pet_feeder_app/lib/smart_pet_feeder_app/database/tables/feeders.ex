defmodule SmartPetFeederApp.Feeders do
  use Ecto.Schema
  import Ecto.Changeset

  alias SmartPetFeederApp.Users

  schema "feeders" do
    field(:serial, :string)
    field(:device_status, :string)
    field(:water_status, :string)
    field(:location, :string)
    belongs_to(:users, Users)
  end

  def changeset(feeders, attrs \\ %{}) do
    feeders
    |> cast(attrs, [:serial, :device_status, :water_status, :location, :users_id])
  end
end
