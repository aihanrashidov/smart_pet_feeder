defmodule SmartPetFeederAgentTest do
  use ExUnit.Case
  doctest SmartPetFeederAgent

  test "greets the world" do
    assert SmartPetFeederAgent.hello() == :world
  end
end
