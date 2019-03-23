defmodule MessageParser do
    
    def parse(message) do
        case :erlang.binary_to_term(message) do
            {:fill_water} ->
                FillWater.request()

            {:fill_food, params} ->
                FillFood.request(params)
        end
    end
end