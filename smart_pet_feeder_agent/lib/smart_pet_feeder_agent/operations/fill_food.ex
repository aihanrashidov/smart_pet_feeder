defmodule FillFood do

    def request(_params) do
      #TODO: Fill the specified amount of food.
      response = "Got something as a resposne from the operation."
      ResponseHandler.build_response(response)
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
    end

end
