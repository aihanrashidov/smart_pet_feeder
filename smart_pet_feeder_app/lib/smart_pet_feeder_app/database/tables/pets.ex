defmodule SmartPetFeederApp.Pets do
  use Ecto.Schema
  import Ecto.Changeset

  alias SmartPetFeederApp.Users

  schema "pets" do
    field :name, :string
    field :type, :string
    field :age, :integer
    field :gender, :string
    field :breed, :string
    belongs_to(:users, users)
  end

  def changeset(pets, attrs \\ %{}) do
    pets
    |> cast(attrs, [:name, :type, :age, :gender, :breed, :user_id])
  end
end