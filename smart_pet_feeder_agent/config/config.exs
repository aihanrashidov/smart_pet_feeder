# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :smart_pet_feeder_agent, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:smart_pet_feeder_agent, :key)
#
# You can also configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env()}.exs"

config :smart_pet_feeder_agent,
  host: "31.13.251.48",
  port: 5672,
  virtual_host: "smartpetfeeder",
  username: "ayhan",
  password: "rich12ard",
  internet_check_time_delay: 2000,
  message_check: 1000,
  serial_number: :os.cmd(:"cat /proc/cpuinfo | grep Serial | cut -d ' ' -f 2") |> List.to_string() |> String.split("\n") |> Enum.at(0)
