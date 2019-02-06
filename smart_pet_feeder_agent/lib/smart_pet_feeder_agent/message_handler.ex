defmodule MessageHandler do
  @moduledoc """
  This is the message handler module. Here the new messages are added to the state and then a commands are sent to the device one by one.
  """

  use GenServer
  require Logger

  @message_check Application.get_env(:embeded_agent, :message_check)

  @type message() :: binary()

  ## Client API

  @doc """
  Starts the GenServer.
  """

  def start_link(_ag) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Returns the state (show the messages added to the state).
  ##Parameters:
  No parameters
  ##Examples:
    iex()> MessageHandler.get_all_messages
    []
  """

  @spec get_state() :: list()
  def get_state() do
    GenServer.call(__MODULE__, {:get_state})
  end

  @doc """
  Adds the new message to the state.
  ##Parameters:
  - message: The binary message received by rabbitmq.
  ##Examples:
    No examples.
  """

  @spec add_new_message(message()) :: tuple()
  def add_new_message(message) do
    case GenServer.call(__MODULE__, {:add_new_message, message}) do
      :added ->
        Logger.info("[MessageHandler] New message has been added!", log: :info)

      error ->
        Logger.error(
          "[MessageHandler] Error while trying to add new message : #{inspect(error)}",
          log: :error
        )
    end
  end

  ## Server Callbacks

  def init(:ok) do
    msg_handler()
    {:ok, []}
  end

  def handle_call({:get_state}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:add_new_message, message}, _from, state) do
    new_state = state ++ [message]
    {:reply, :added, new_state}
  end

  def handle_info(:send_request, state) do
    new_state =
      if state == [] do
        msg_handler()
        []
      else
        #Getting the first message from the state.
        message = Enum.at(state, 0)
        
        MessageParser.parse(message)

        msg_handler()
        state -- [message]
      end

    {:noreply, new_state}
  end

  defp msg_handler(), do: Process.send_after(self(), :send_request, @message_check)
end