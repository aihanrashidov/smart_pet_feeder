defmodule FillWater do
    require Logger

    def request() do
      try do
        start_pump()
      rescue
        error ->
          Logger.error("[FillWater] GPIO Error - #{inspect(error)}")
          request()
      end
    end

    defp start_pump() do
      pins = [23, 24, 25]

      pins = for p <- pins do
        {:ok, pin} = Circuits.GPIO.open(p, :output)
        Circuits.GPIO.write(pin, 0)
        pin
      end

      Circuits.GPIO.write(Enum.at(pins, 0), 1)
      Circuits.GPIO.write(Enum.at(pins, 1), 0)
      Circuits.GPIO.write(Enum.at(pins, 2), 1)

      Logger.info("[#{__MODULE__}] Pump started!")

      fill_until_full(pins)
    end

    defp stop_pump(pins) do
      # Circuits.GPIO.write(Enum.at(pins, 0), 1)
      # Circuits.GPIO.write(Enum.at(pins, 1), 0)
      Circuits.GPIO.write(Enum.at(pins, 2), 0)
      Logger.info("[#{__MODULE__}] Pump stopped!")
      SocketCommunication.send_request()
    end

    defp fill_until_full(pins) do
      #######
      :timer.sleep(10000)
      stop_pump(pins)
      #######

      # case WaterSensors.get_state.sensors_data.top_water_sensor do
      #   "YES" ->
      #     stop_pump(pins)
      #     Logger.info("[#{__MODULE__}] Water level is full!")

      #   "NO" ->
      #     :timer.sleep(1000)
      #     Logger.info("[#{__MODULE__}] Filling water!")
      #     fill_until_full(pins)
      # end
    end
end
