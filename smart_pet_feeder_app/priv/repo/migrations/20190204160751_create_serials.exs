defmodule SmartPetFeederApp.Repo.Migrations.CreateSerials do
  use Ecto.Migration

  def change do
    create table(:serials) do
      add :serial, :string
    end
  end
end
