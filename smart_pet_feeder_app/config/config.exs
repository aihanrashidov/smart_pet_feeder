# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :smart_pet_feeder_app,
  ecto_repos: [SmartPetFeederApp.Repo],
  token_exp_time: 6000 * 24

config :smart_pet_feeder_app, :jwt,
  alg: "RS256",
  keys: [
    priv: {Path.join([File.cwd!(), "priv/certs"]), "private_key.pem"},
    pub: {Path.join([File.cwd!(), "priv/certs"]), "public_key.pem"}
  ]

# config :smart_pet_feeder_app, :communication,
#   rabbitmq: [
#     host: "31.13.251.48",
#     port: 5672,
#     vhost: "smartpetfeeder",
#     username: "ayhan",
#     password: "rich12ard"
#   ]

# Configures the endpoint
config :smart_pet_feeder_app, SmartPetFeederAppWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "c52stOqMUe/JtMVky17rTGH892KTCIasGwP/hBZ9ZB0eqD+4zryX7pB/9Xx/J7Tc",
  render_errors: [view: SmartPetFeederAppWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: SmartPetFeederApp.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
