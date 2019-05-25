defmodule FillWater do
    require Logger

    def request() do
      {a, b, c} = gpio_init()
      start_pump(a, b, c)
      :timer.sleep(10000)
      stop_pump(a, b, c)
      # fill_util_full(c)
    end

    defp start_pump(a,b,c) do
      Logger.info("[#{__MODULE__}] Pump started!")
      Circuits.GPIO.write(a, 1)
      Circuits.GPIO.write(b, 0)
      Circuits.GPIO.write(c, 1)
    end

    defp stop_pump(a, b, c) do
      Logger.info("[#{__MODULE__}] Pump stopped!")
      Circuits.GPIO.write(a, 0)
      Circuits.GPIO.write(b, 0)
      Circuits.GPIO.write(c, 0)
    end

    # defp fill_util_full(c) do
    #   case WaterSensors.get_state.sensors_data.top_water_sensor do
    #     "YES" ->
    #       stop_pump(c)
    #       Logger.info("[#{__MODULE__}] Water level is full!")

    #     "NO" ->
    #       :timer.sleep(1000)
    #       Logger.info("[#{__MODULE__}] Filling water!")
    #       fill_util_full(c)
    #   end
    # end

    defp gpio_init() do
      a = Circuits.GPIO.open(23, :output)
      b = Circuits.GPIO.open(24, :output)
      c = Circuits.GPIO.open(25, :output)

      if elem(a, 0) != :ok || elem(b, 0) != :ok || elem(c, 0) != :ok do
          gpio_init()
      else
          Logger.info("[#{__MODULE__}] Pump GPIO's initialized!")
          {elem(a, 1), elem(b, 1), elem(c, 1)}
      end

  end
end
