defmodule FillWater do
    require Logger

    def request() do
      start_pump()
      response = fill_util_full()
      #ResponseHandler.build_response(response)
    end

    defp start_pump() do
      Logger.info("[#{__MODULE__}] Pump started!")
    end

    defp stop_pump() do
      Logger.info("[#{__MODULE__}] Pump stopped!")
    end

    defp fill_util_full() do
      case WaterSensors.get_state.sensors_data.top_water_sensor do
        "YES" ->
          stop_pump()
          Logger.info("[#{__MODULE__}] Water level is full!")
          :water_level_full

        "NO" ->
          :timer.sleep(1000)
          Logger.info("[#{__MODULE__}] Filling water!")
          fill_util_full()
      end
    end
end