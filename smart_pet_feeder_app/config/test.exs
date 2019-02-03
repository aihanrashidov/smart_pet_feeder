use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :smart_pet_feeder_app, SmartPetFeederAppWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :smart_pet_feeder_app, SmartPetFeederApp.Repo,
  username: "postgres",
  password: "postgres",
  database: "smart_pet_feeder_app_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
