defmodule SmartPetFeederAppWeb.FeederChannel do
  use SmartPetFeederAppWeb, :channel
  require Logger

  def join("feeder:communication", _msg, socket) do
    Logger.info("Joined room.")
    {:ok, socket}
  end

  def handle_in(event, msg, socket) do
    IO.inspect(msg)
    broadcast!(socket, event, %{message: msg})
    {:noreply, socket}
  end
end
