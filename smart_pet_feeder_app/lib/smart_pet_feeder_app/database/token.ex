defmodule SmartPetFeederApp.Token do
  require Logger

  @type token :: String.t()
  @type expire_time :: integer()
  @type user :: String.t()
  @type claims :: %{exp: expire_time(), user: user()}

  @spec get_token(user()) :: token()
  def get_token(user) do
    Logger.debug("[Qpcore.Protocols.Auth.Token] Getting token",
      ansi_color: :blue
    )

    sign(user, get_exp_time())
  end

  @spec verify_token(token()) ::
          {:ok, claims()}
          | {:error, :expired}
          | {:error, %ArgumentError{}}
  def verify_token(token) do
    case JsonWebToken.verify(token, jwt_opts(:pub)) do
      {:ok, claims} ->
        if jwt_expired?(claims[:exp]) do
          {:error, :expired}
        else
          {:ok, claims}
        end

      {:error, msg} ->
        {:error, msg}
    end
  rescue
    error ->
      {:error, error}
  end

  @spec get_exp_time() :: expire_time()
  defp get_exp_time(), do: Application.get_env(:smart_pet_feeder_app, :token_exp_time)

  defp sign(user, exp_time) do
    JsonWebToken.sign(
      %{user: user, exp: current_timestamp() + exp_time},
      jwt_opts(:priv)
    )
  end

  defp jwt_opts(p) do
    config = Application.get_env(:smart_pet_feeder_app, :jwt)
    {base_dir, pubkey} = Keyword.get(config, :keys)[p]

    fun =
      case p do
        :priv ->
          &JsonWebToken.Algorithm.RsaUtil.private_key/2

        :pub ->
          &JsonWebToken.Algorithm.RsaUtil.public_key/2
      end

    key = fun.(base_dir, pubkey)

    %{
      alg: Keyword.get(config, :alg),
      key: key
    }
  end

  _ = """
  Always expired if there is no timestamp
  """

  defp jwt_expired?(nil), do: true
  defp jwt_expired?(timestamp), do: timestamp < current_timestamp()

  defp current_timestamp, do: :os.system_time(:seconds)
end
