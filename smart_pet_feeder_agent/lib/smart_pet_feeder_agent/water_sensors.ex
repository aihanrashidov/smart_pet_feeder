defmodule WaterSensors do
    use GenServer
    require Logger

    def start_link(_ag) do
        GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
    end

    def get_state() do
        GenServer.call(__MODULE__, {:get_state})
    end

    def init(:ok) do
        {top_ref, bottom_ref} = gpio_init()

        top_water_check()
        bottom_water_check()

        state =
            %{
                top_water_sensor_ref: top_ref,
                bottom_water_sensor_ref: bottom_ref,
                sensors_data:
                    %{
                        top_water_sensor: nil,
                        bottom_water_sensor: nil,
                    }
            }
        {:ok, state}
    end

    def handle_call({:get_state}, _from, state) do
        {:reply, state, state}
    end

    def handle_info(:top_water_check, state) do
        resp = Circuits.GPIO.read(state.top_water_sensor_ref)

        status =
            case resp do
                0 -> "YES"
                1 -> "NO"
            end

        sensors_data = state.sensors_data
        new_sensors_data = %{sensors_data | top_water_sensor: status}

        Logger.info("TOP Water: #{inspect(status)}")

        top_water_check()
        {:noreply, %{state | sensors_data: new_sensors_data}}
    end

    def handle_info(:bottom_water_check, state) do
        resp = Circuits.GPIO.read(state.bottom_water_sensor_ref)

        status =
            case resp do
                0 -> "YES"
                1 -> "NO"
            end

        Logger.info("BOTTOM Water: #{inspect(status)}")

        sensors_data = state.sensors_data
        new_sensors_data = %{sensors_data | bottom_water_sensor: status}

        bottom_water_check()
        {:noreply, %{state | sensors_data: new_sensors_data}}
    end

    ## Private functions

    defp gpio_init() do
        top_level = Circuits.GPIO.open(20, :input)
        bottom_level = Circuits.GPIO.open(21, :input)

        if elem(top_level, 0) != :ok || elem(bottom_level, 0) != :ok do
            gpio_init()
        else
            Logger.info("[#{__MODULE__}] GPIO's Initialized!")
            {elem(top_level, 1), elem(bottom_level, 1)}
        end

    end

    defp top_water_check(), do: Process.send_after(self(), :top_water_check, 4000)
    defp bottom_water_check(), do: Process.send_after(self(), :bottom_water_check, 4000)
end
