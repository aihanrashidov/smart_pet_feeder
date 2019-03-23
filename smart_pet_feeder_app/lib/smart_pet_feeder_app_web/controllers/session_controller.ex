defmodule SmartPetFeederAppWeb.SessionController do
  use SmartPetFeederAppWeb, :controller

  alias SmartPetFeederApp.DBManager
  alias SmartPetFeederApp.Token

  def register(conn, _params) do
    render(conn, "register.html")
  end

  def register_user(conn, params) do
    {_status, resp} =
      DBManager.add(:user,
        username: params["username"],
        password: params["password"],
        email: params["email"],
        first_name: params["first_name"],
        last_name: params["last_name"]
      )

    json(conn, %{response: resp})
  end

  def login(conn, _params) do
    render(conn, "login.html")
  end

  def login_user(conn, params) do
    {status, resp} =
      DBManager.authenticate(:user,
        username: params["username"],
        password: params["password"]
      )

    case status do
      :ok ->
        json(conn, %{response: %{token: Token.get_token(resp.username), username: resp.username}})

      _ ->
        json(conn, %{response: resp})
    end
  end

  def logout(conn, _params) do
    conn
    |> clear_session
    |> render("login.html")
  end

  def set_auth_configs(conn, params) do
    token = params["token"]
    username = params["username"]

    conn = put_session(conn, :token, token)
    conn = put_session(conn, :username, username)

    IO.inspect(conn)

    json(conn, %{response: "Token and username saved to session."})
  end
end
