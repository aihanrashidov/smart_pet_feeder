defmodule SmartPetFeederApp.Repo do
  use Ecto.Repo,
    otp_app: :smart_pet_feeder_app,
    adapter: Ecto.Adapters.Postgres
end
