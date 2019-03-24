defmodule RabbitMQCommunication do
  @moduledoc """
  AMQP operation with the RabbitMQ server.
  TODOs:
  - Rabbit recev_msg struct
  """

  use GenServer
  require Logger

  alias Qputils.Serialization

  @host Application.get_env(:smart_pet_feeder_agent, :host)
  @port Application.get_env(:smart_pet_feeder_agent, :port)
  @vhost Application.get_env(:smart_pet_feeder_agent, :virtual_host)
  @user Application.get_env(:smart_pet_feeder_agent, :username)
  @pass Application.get_env(:smart_pet_feeder_agent, :password)
  @serial_number Application.get_env(:smart_pet_feeder_agent, :serial_number)

  ## Client API

  @doc """
  Starts the GenServer.
  """

  def start_link(_arg) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Declares an exchange.
  ##Parameters:
  -name: String for name of the new exchange.
  -type: Exchange type.
  -options: A list with options(could be empty).
  • :durable: If set, keeps the Exchange between restarts of the broker
  • :auto_delete: If set, deletes the Exchange once all queues unbind from it
  • :passive: If set, returns an error if the Exchange does not already exist
  • :internal: If set, the exchange may not be used directly by publishers,
  but only when bound to other exchanges. Internal exchanges are used to
  construct wiring that is not visible to applications
  ##Examples:
  No examples.
  """

  @spec create_exchange(String.t(), atom(), list()) :: atom()
  def create_exchange(name, type \\ :direct, options \\ []) do
    GenServer.call(__MODULE__, {:create_exchange, name, type, options})
  end

  @doc """
  Declares a queue.
  ##Parameters:
  -name: String for name of the new queue.
  -options: A list with options(could be empty).
  • :durable - If set, keeps the Queue between restarts of the broker
  • :auto_delete - If set, deletes the Queue once all subscribers disconnect
  • :exclusive - If set, only one subscriber can consume from the Queue
  • :passive - If set, raises an error unless the queue already exists
  ##Examples:
  No examples.
  """

  @spec create_queue(String.t(), list()) :: atom()
  def create_queue(name, options \\ []) do
    GenServer.call(__MODULE__, {:create_queue, name, options})
  end

  @doc """
  Binds an exchange to an exchange.
  ##Parameters:
  -source: The name of the source exchange.
  -destination: The name of the destination_exchange.
  -options: A list with options(could be empty).
  ##Examples:
  No examples.
  """

  @spec bind_exchange_to_exchange(String.t(), String.t(), list()) :: atom()
  def bind_exchange_to_exchange(source, destination, options \\ []) do
    GenServer.call(__MODULE__, {:bind_exchange_to_exchange, source, destination, options})
  end

  @doc """
  Binds a queue to an exchange.
  ##Parameters:
  -queue: The queue name.
  -exchange: The exchange name.
  -options: A list with options(could be empty).
  ##Examples:
  No examples.
  """

  @spec bind_queue_to_exchange(String.t(), String.t(), list()) :: atom()
  def bind_queue_to_exchange(queue, exchange, options \\ []) do
    GenServer.call(__MODULE__, {:bind_queue_to_exchange, queue, exchange, options})
  end

  @doc """
  Registers a queue consumer process.
  ##Parameters:
  -name: The name of the queue where you want to subscribe.
  -consumer_pid: The pid of the process can be set using the consumer_pid argument
  and defaults to the calling process.
  -options: A list with options(could be empty).
  ##Examples:
  No examples.
  """

  @spec subscribe_to_queue(String.t(), pid(), list()) :: atom()
  def subscribe_to_queue(name, consumer_pid \\ nil, options \\ []) do
    GenServer.call(__MODULE__, {:subscribe_to_queue, name, consumer_pid, options})
  end

  @doc """
  Delete an exchange.
  ##Parameters:
  -name: The name of the queue which will be deleted.
  ##Examples:
  No examples.
  """

  @spec delete_exchange(name :: Strint.t()) :: :ok | {:error, reason :: term()}
  def delete_exchange(name) do
    GenServer.call(__MODULE__, {:delete_exchange, name})
  end

  @doc """
  Delete a queue.
  ##Parameters:
  -name: The name of the queue which will be deleted.
  ##Examples:
  No examples.
  """

  @spec delete_queue(name :: Strint.t()) :: :ok | {:error, reason :: term()}
  def delete_queue(name) do
    GenServer.call(__MODULE__, {:delete_queue, name})
  end

  @doc """
  Acknowledge the server that the message is delivered.
  ##Parameters:
  -delivery_tag: Delivery identifier.
  ##Examples:
  No examples.
  """

  @spec do_ack(integer()) :: atom()
  def do_ack(delivery_tag) do
    GenServer.call(__MODULE__, {:do_ack, delivery_tag})
  end

  @doc """
  Publishes the message to the RabbitMQ queue.
  ##Parameters:
  -msg: The message to be published.
  -to: The queue where the message will be published.
  ##Examples:
  No examples.
  """

  @spec send_message(binary()) :: tuple()
  def send_message(msg) do
    ## TODO: fix this !!
    # msg = Serialization.serialize(msg, :rabbit)
    GenServer.call(__MODULE__, {:send_message, msg}, :infinity)
  end

  @doc """
  Returns the AMQP server state which contains connection information.
  ##Parameters:
  No parameters.
  ##Examples:
  No examples.
  """

  @spec get_state() :: map()
  def get_state() do
    GenServer.call(__MODULE__, {:get_state})
  end

  ## Server Callbacks

  def init(:ok) do
    HTTPoison.start()
    {:ok, initial_state()}
  end

  def handle_call({:create_exchange, name, type, options}, _from, state) do
    response =
      case AMQP.Exchange.declare(state.channel, name, type, options) do
        :ok ->
          :new_exchange_created

        error ->
          Logger.error(error, label: "[RabbitMQ] Exchange create error")
          :failed_to_create_exchange
      end

    {:reply, response, state}
  end

  def handle_call({:create_queue, name, options}, _from, state) do
    response =
      case AMQP.Queue.declare(state.channel, name, options) do
        {:ok, _} ->
          :new_queue_created

        error ->
          Logger.error(error, label: "[RabbitMQ] Queue create error")
          :failed_to_create_queue
      end

    {:reply, response, state}
  end

  def handle_call({:bind_exchange_to_exchange, source, destination, options}, _from, state) do
    response =
      try do
        AMQP.Exchange.bind(state.channel, destination, source, options)
        :new_binding_successfull
      rescue
        error ->
          Logger.error(error, label: "[RabbitMQ] Failed to bind")
          :failed_to_bind
      end

    {:reply, response, state}
  end

  def handle_call({:bind_queue_to_exchange, queue, exchange, options}, _from, state) do
    response =
      try do
        AMQP.Queue.bind(state.channel, queue, exchange, options)
        :new_binding_successfull
      rescue
        error ->
          Logger.error(error, label: "[RabbitMQ] Failed to bind")
          :failed_to_bind
      end

    {:reply, response, state}
  end

  def handle_call({:subscribe_to_queue, name, consumer_pid, options}, _from, state) do
    response =
      case AMQP.Basic.consume(state.channel, name, consumer_pid, options) do
        {:ok, consumer_tag} ->
          {:subscribed, state.channel, consumer_tag}

        error ->
          Logger.error(error, label: "[RabbitMQ] Failed to subscribe to queue")
          :failed_to_subcribe
      end

    {:reply, response, state}
  end

  def handle_call({:delete_exchange, name}, _from, state) do
    response =
      case AMQP.Exchange.delete(state.channel, name) do
        :ok ->
          :exchange_deleted

        error ->
          Logger.error(error, label: "[RabbitMQ] Failed to delete exchange")
          :failed_to_delete
      end

    {:reply, response, state}
  end

  def handle_call({:delete_queue, name}, _from, state) do
    response =
      case AMQP.Queue.delete(state.channel, name) do
        {:ok, _} ->
          :queue_deleted

        error ->
          Logger.error(error, label: "[RabbitMQ] Failed to delete queue")
          :failed_to_delete
      end

    {:reply, response, state}
  end

  def handle_call({:do_ack, delivery_tag}, _from, state) do
    response =
      case AMQP.Basic.ack(state.channel, delivery_tag) do
        :ok ->
          :ack_successfull

        error ->
          Logger.error(error, label: "[RabbitMQ] Failed to acknowledge")
          :failed_to_ack
      end

    {:reply, response, state}
  end

  def handle_call({:send_message, msg}, from, state) do
    response =
      case AMQP.Basic.publish(state.channel, state.exchange, state.queue, msg) do
        :ok ->
          :sent

        error ->
          Logger.error(error, label: "[RabbitMQ] Failed to send message")
          :failed_to_send
      end

    {:reply, response, state}
  end

  def handle_call({:get_state}, _from, state) do
    {:reply, state, state}
  end

  def handle_info({:basic_deliver, data, %{reply_to: _reply_to} = map}, state) do
    # We are sending back acknowledge so the rabbit server can delete the delivered message.
    # try do
      #AMQP.Basic.ack(channel, amqp_map.delivery_tag)
      Logger.info("[RabbitMQCommunication] New message has been received.", log: :info)
      # Adding the new message to the state.
      IO.inspect(data)
      #MessageHandler.add_new_message(data)
    # catch
    #   error ->
    #     Logger.error("[RabbitMQCommunication] Could not send back acknowledge : #{inspect(error)}", log: :error)
    # end

    {:noreply, state}
  end

  def handle_info({:basic_consume_ok, %{consumer_tag: _consumer_tag}}, state) do
    {:noreply, state}
  end

  def handle_info({:basic_cancel, %{consumer_tag: _consumer_tag}}, state) do
    {:stop, :normal, state}
  end

  def handle_info({:basic_cancel_ok, %{consumer_tag: _consumer_tag}}, state) do
    {:noreply, state}
  end

  def handle_info(
        {:DOWN, _pid_ref, :process, _pid, {_, {:connection_closing, {_, _, _}}} = error},
        state
      ) do
    Logger.error(error, label: "[RabbitMQ] Error, reason")

    # Start async network status checks. When the network connection is recovered we are building new state.
    monitor_net_status()
    {:noreply, state}
  end

  def handle_info({:DOWN, _pid_ref, :process, _pid, error}, state) do
    Logger.error("[RabbitMQ] Pid DOWN with error reason: , #{inspect(error)}")
    {:noreply, state}
  end

  def handle_info(:net_status, state) do
    {:noreply, internet_check(state)}
  end

  def handle_info(any, state) do
    Logger.debug(any, label: "[RabbitMQ] ANY")
    {:noreply, state}
  end

  ## Internal Functions

  defp monitor_net_status(), do: Process.send_after(self(), :net_status, 2000)

  defp connection_setup() do
    {:ok, connection} =
      AMQP.Connection.open(
        host: @host,
        port: @port,
        virtual_host: @vhost,
        username: @user,
        password: @pass
      )

    {:ok, channel} = AMQP.Channel.open(connection)

    AMQP.Exchange.declare(channel, @serial_number, :topic, [])

    AMQP.Queue.declare(channel, "#{@serial_number}_agent", [durable: true])
    AMQP.Queue.declare(channel, "#{@serial_number}_app", [durable: true])

    AMQP.Queue.bind(channel, "#{@serial_number}_agent", @serial_number, [routing_key: "#{@serial_number}_agent"])
    AMQP.Queue.bind(channel, "#{@serial_number}_app", @serial_number, [routing_key: "#{@serial_number}_app"])

    {:ok, consumer} = AMQP.Basic.consume(channel, "#{@serial_number}_agent", nil, ack: true)
    Logger.info("[RabbitMQ] RabbitMQ connection established.")

    %{
      connection: connection,
      channel: channel,
      conn_ref: :erlang.monitor(:process, Map.get(connection, :pid)),
      chan_ref: :erlang.monitor(:process, Map.get(channel, :pid)),
      queue: "#{@serial_number}_app",
      exchange: @serial_number
    }
  end

  defp internet_check(state) do
    ## If internet stops starts checking and when back creates a new connection.
    case HTTPoison.head("www.google.com") do
      {:ok, _} ->
        Logger.info("[RabbitMQ] Internet connection is ok!")
        connection_setup()

      {:error, _} ->
        Logger.error("[RabbitMQ] No internet connection!")
        monitor_net_status()
        state
    end
  end

  defp initial_state(), do: internet_check(%{})
end
