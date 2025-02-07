defmodule SocketCommunication do
  alias Phoenix.Channels.GenSocketClient
  require Logger

  @ws_host "ws://192.168.1.108:4000/socket/websocket"
  @ws_topic "feeder:communication"
  @ws_event Application.get_env(:smart_pet_feeder_agent, :serial_number)

  def child_spec(opts) do
      %{
        id: __MODULE__,
        start: {__MODULE__, :start_link, [opts]},
        type: :worker,
        restart: :permanent,
        shutdown: 500
      }
  end

  def start_link(_args) do
    GenSocketClient.start_link(
      __MODULE__,
      Phoenix.Channels.GenSocketClient.Transport.WebSocketClient,
      %{url: @ws_host},
      [],
      name: __MODULE__
    )
  end

  def send_request() do
    GenSocketClient.call(__MODULE__, {:send_operation_finished})
  end

  def init(data) do
    {:connect, data.url, [], %{}}
  end

  def handle_connected(transport, state) do
    Logger.info("[WS] Connected to SmartPetFeeder App WebSocket!")
    GenSocketClient.join(transport, @ws_topic)
    {:ok, state}
  end

  def handle_joined(_topic, _payload, _transport, state) do
    Logger.info("[WS] Joined the channel!")
    {:ok, state}
  end

  def handle_call({:send_operation_finished}, _pid, transport, state) do
    GenSocketClient.push(transport, @ws_topic, "#{@ws_event}_operation_app", %{serial: @ws_event, operation: "done"})
    {:reply, :ok, state}
  end

  def handle_message(_topic, "#{@ws_event}_agent", payload, transport, state) do
    case payload do
      %{"message" => "fill_water"} ->
        Logger.info("[WS] Web app wants to fill water.")
        spawn( fn -> FillWater.request() end )

      %{"message" => %{"message" => "fill_food", "portions" => portions}} ->
        Logger.info("[WS] Web app wants to fill food.")
        spawn( fn -> FillFood.request(portions) end )

      _ ->
        message = payload["message"] |> Enum.at(0)
        _serial = message["serial"]
        feeder_id = message["id"]

        Logger.info("[WS] Web app wants sensors info for #{@ws_event}")
        GenSocketClient.push(transport, @ws_topic, "#{@ws_event}_app", %{feeder_id: feeder_id, serial: @ws_event, sensors_data: WaterSensors.get_state().sensors_data})
    end

    {:ok, state}
  end

  def handle_message(_topic, _event, _payload, _transport, state) do
    {:ok, state}
  end

  def handle_disconnected({:remote, :closed}, state) do
    Logger.error("[WS] Disconnected from SmartPetFeeder App WebSocket server! Server stopped!")
    Process.send_after(self(), :connect, :timer.seconds(3))
    {:ok, state}
  end

  def handle_disconnected({:error, :econnrefused}, state) do
    Logger.error("[WS] Cannot connect to SmartPetFeeder App WebSocket server! Check server!")
    Process.send_after(self(), :connect, :timer.seconds(3))
    {:ok, state}
  end

  def handle_disconnected(reason, state) do
    Logger.error("[WS] Connection error! Reason: #{inspect(reason)}")
    Process.send_after(self(), :connect, :timer.seconds(3))
    {:ok, state}
  end

  def handle_info(:connect, _transport, state) do
    Logger.info("[WS] Reconnecting.")
    {:connect, state}
  end
end
