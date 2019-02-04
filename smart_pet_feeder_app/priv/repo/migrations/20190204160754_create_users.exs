defmodule SmartPetFeederApp.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :password, :string
      add :password_hash, :string
      add :email, :string
      add :first_name, :string
      add :last_name, :string
      timestamps()
    end
  end
end
