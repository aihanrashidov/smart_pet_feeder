defmodule SmartPetFeederAgent.Application do
  use Application
  require Logger

  def start(_type, _args) do

  
    children = [
      SmartPetFeederAgent.Supervisor
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end