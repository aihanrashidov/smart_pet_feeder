defmodule SmartPetFeederAgent.MixProject do
  use Mix.Project

  def project do
    [
      app: :smart_pet_feeder_agent,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {SmartPetFeederAgent.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      {:circuits_gpio, "~> 0.1"},
      {:circuits_spi, "~> 0.1"},
      {:poison, "~> 4.0", override: true},
      {:httpoison, "~> 1.5"},
      {:phoenix_gen_socket_client, "~> 2.1.1"},
      {:websocket_client, "~> 1.2"},
      {:websockex, "~> 0.4.0"},
      {:micro_timer, "~> 0.1.0"}
    ]
  end
end
