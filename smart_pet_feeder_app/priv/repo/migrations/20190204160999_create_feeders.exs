defmodule SmartPetFeederApp.Repo.Migrations.CreateFeeders do
  use Ecto.Migration

  def change do
    create table(:feeders) do
      add(:serial, :string)
      add(:device_status, :string)
      add(:water_status, :string)
      add(:location, :string)
      add(:users_id, references("users"))
    end
  end
end
