defmodule SmartPetFeederApp.Repo.Migrations.CreatePets do
  use Ecto.Migration

  def change do
    create table(:pets) do
      add :name, :string
      add :type, :string
      add :age, :integer
      add :gender, :string
      add :breed, :string
      add :user_id, references("users")
    end
  end
end
