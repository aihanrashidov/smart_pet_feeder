defmodule RabbitMQCommunication do
  @moduledoc """
  RabbitMQ communication server module.
  """

  use GenServer
  require Logger

  @net_check_time_delay Application.get_env(:embeded_agent, :net_check_time_delay)
  @host Application.get_env(:embeded_agent, :host)
  @port Application.get_env(:embeded_agent, :port)
  @virtual_host Application.get_env(:embeded_agent, :virtual_host)
  @username Application.get_env(:embeded_agent, :username)
  @password Application.get_env(:embeded_agent, :password)
  @web_exchange Application.get_env(:embeded_agent, :web_exchange)
  @web_queue Application.get_env(:embeded_agent, :web_queue)
  @web_exchange Application.get_env(:embeded_agent, :web_exchange)
  @web_queue Application.get_env(:embeded_agent, :web_queue)

  @type response_binary() :: binary()

  ## Client API

  @doc """
  Starts the GenServer.
  """

  def start_link(_ag) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Sends a response binary to the server.
  """

  @spec send_response(response_binary()) :: atom()
  def send_response(response) do
    GenServer.call(__MODULE__, {:send, response})
  end

  @doc """
  Returns the state containing connection details.
  ##Parameters:
  No parameters
  ##Examples:
  No examples
  """

  @spec get_state() :: map()
  def get_state() do
    GenServer.call(__MODULE__, {:get_state})
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, initial_state()}
  end

  def handle_call({:send, response}, _from, state) do
    send_msg(state.connection, {response, state.web_exchange, state.web_queue})
    {:reply, :ok, state}
  end

  def handle_call({:get_state}, _from, state) do
    {:reply, state, state}
  end

  ## Enters this clause when the connection or channel is down.
  def handle_info({:DOWN, pid_ref, :process, _pid, error}, %{conn_ref: conn_ref, chan_ref: chan_ref} = state) when pid_ref == conn_ref or pid_ref == chan_ref do
    Logger.error("[RabbitMQCommunication] Connection or channel is down, reason: #{inspect(error)}", log: :error)

    Process.demonitor(conn_ref)
    Process.demonitor(chan_ref)

    # Start async network status checks. When the network connection is recovered we are building new state.
    monitor_net_status()

    {:noreply, state}
  end

  def handle_info({:basic_deliver, _payload, _amqp_map}, %{channel: nil} = state) do
    Logger.error("[RabbitMQCommunication] Delivered new message when channel is nil !", log: :error)
    {:noreply, state}
  end

  def handle_info({:basic_deliver, msg, amqp_map}, %{channel: channel} = state) do
    # We are sending back acknowledge so the rabbit server can delete the delivered message.
    try do
      AMQP.Basic.ack(channel, amqp_map.delivery_tag)
      Logger.info("[RabbitMQCommunication] New message has been received.", log: :info)
      # Adding the new message to the state.
      IO.inspect(msg)
      #MessageHandler.add_new_message(msg)
    catch
      error ->
        Logger.error("[RabbitMQCommunication] Could not send back acknowledge : #{inspect(error)}", log: :error)
    end

    {:noreply, state}
  end

  def handle_info({:basic_consume_ok, _amqp_map}, state), do: {:noreply, state}

  def handle_info(:net_status, state), do: {:noreply, internet_check(state)}

  ## Internal functions

  ## Connection and channel setup.
  defp setup() do
    {:ok, connection} = AMQP.Connection.open(username: @username, password: @password, host: @host, port: @port, virtual_host: @virtual_host)
    {:ok, channel} = AMQP.Channel.open(connection)

    Logger.info("[RabbitMQCommunication] Server connection is successful.", log: :info)

    AMQP.Basic.consume(channel, @agent_queue, nil, ack: true)
  
    ## Returning the new state
    %{
      :connection => connection,
      :channel => channel,
      :conn_ref => :erlang.monitor(:process, Map.get(connection, :pid)),
      :chan_ref => :erlang.monitor(:process, Map.get(channel, :pid)),
      :agent_exchange => @agent_exchange,
      :agent_queue => @agent_queue,
      :web_exchange => @web_exchange,
      :web_queue => @web_queue
    }
  end

  # Sending a message through RabiitMQ
  defp send_msg(connection, {message, exchange, queue}) do
    try do
      {:ok, channel} = AMQP.Channel.open(connection)
      AMQP.Basic.publish(channel, exchange, queue, message)
      AMQP.Channel.close(channel)
    catch
      error ->
        Logger.error(
          "[RabbitMQCommunication] Error while sending the response to the server: #{inspect(error)}",
          log: :error
        )
    end
  end

  defp monitor_net_status(), do: Process.send_after(self(), :net_status, @net_check_time_delay)

  #If there is an internet connection we are building state with rabbit connection and references and if not - we return the given state instead
  defp internet_check(state) do
    case HTTPoison.head("www.google.com") do
      {:ok, _} ->
        Logger.info("[RabbitMQCommunication] Internet connection is ok!", log: :info)
        setup()

      {:error, _} ->
        Logger.error("[RabbitMQCommunication] No internet connection!", log: :error)
        monitor_net_status()
        state
    end
  end

  #Checks for internet connection in the initialization of the state
  defp initial_state(), do: internet_check(%{})
end