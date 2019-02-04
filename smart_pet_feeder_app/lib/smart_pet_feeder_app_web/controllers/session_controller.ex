defmodule SmartPetFeederAppWeb.SessionController do
  use SmartPetFeederAppWeb, :controller

  def register(conn, _params) do
    render(conn, "register.html")
  end

  def login(conn, _params) do
    render(conn, "login.html")
  end

  def set_auth_configs(conn, params) do
    token = params["token"]
    username = params["username"]

    conn = put_session(conn, :token, token)
    conn = put_session(conn, :username, username)

    json(conn, %{response: "Token and username saved to session."})
  end
end