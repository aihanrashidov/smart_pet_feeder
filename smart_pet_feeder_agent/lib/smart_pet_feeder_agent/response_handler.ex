defmodule ResponseHandler do

    require Logger

    def build_response(response) do
        ##TODO: Parse the operations response to something in better format.
        server_resp(:erlang.term_to_binary(response))
    end

    defp server_resp(response) do
    #Sending the response to the server if there is an internet connection.
    case HTTPoison.head("www.google.com") do
      {:ok, _} ->
        spawn(fn ->
          RabbitMQCommunication.send_response(response)
        end)

      {:error, _} ->
        Logger.error("[MessageHandler] No internet connection. Response was not sent.", log: :error)
    end
  end

end