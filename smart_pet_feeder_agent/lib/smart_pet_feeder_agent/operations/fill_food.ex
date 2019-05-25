defmodule FillFood do
    require Logger

    def request(portions) do
      try do
        fill_food(portions)
      rescue
        error ->
          Logger.error("[FillFood] GPIO Error - #{inspect(error)}")
          request(portions)
      end
    end

    def fill_food(portions) do
      portion = 511
      portions = portion*portions

      pins = [26, 17, 27, 22]

      pins = for p <- pins do
        {:ok, pin} = Circuits.GPIO.open(p, :output)
        Circuits.GPIO.write(pin, 0)
        pin
      end

      halfstep_sequence = [
        [1,0,0,0],
        [1,1,0,0],
        [0,1,0,0],
        [0,1,1,0],
        [0,0,1,0],
        [0,0,1,1],
        [0,0,0,1],
        [1,0,0,1]
      ]

        for _i <- 0..portions do
          for halfstep <- 0..7 do
            for pin <- 0..3 do
              Circuits.GPIO.write(Enum.at(pins, pin), halfstep_sequence |> Enum.at(halfstep) |> Enum.at(pin))
              MicroTimer.usleep(330)
            end
          end
        end

        for pin <- pins do
          Circuits.GPIO.write(pin, 0)
        end

        SocketCommunication.send_request()
    end

end
