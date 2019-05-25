defmodule SmartPetFeederAppWeb.SessionController do
  use SmartPetFeederAppWeb, :controller

  alias SmartPetFeederApp.DBManager
  alias SmartPetFeederApp.Token

  def register(conn, _params) do
    # render(conn, "register.html")

    check = Map.get(conn.private.plug_session, "username", :undefined)

    if check == :undefined do
      render(conn, "register.html")
    else
      # username = conn.private.plug_session["username"]
      # token = conn.private.plug_session["token"]

      redirect(conn, to: "/pet_management")
    end
  end

  def register_user(conn, params) do
    username = params["username"]
    password = params["password"]
    email = params["email"]
    first_name = params["first_name"]
    last_name = params["last_name"]

    resp =
      if username == "" || password == "" || email == "" || first_name == "" || last_name == "" do
        list = [
          username: username,
          password: password,
          email: email,
          first_name: first_name,
          last_name: last_name
        ]

        case list do
          ["", "", "", "", ""] ->
            {:error, :all}

          _ ->
            l = for {k, v} <- list, v == "", do: k
            {:error_all, Enum.join(l, ", ")}
        end
      else
        list = [
          username: Regex.match?(~r/^[A-Za-z0-9._-]{2,12}$/, username),
          password: Regex.match?(~r/^[A-Za-z0-9]{4,20}$/, password),
          email: Regex.match?(~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/, email),
          first_name: Regex.match?(~r/^[A-Za-z]{2,20}$/, first_name),
          last_name: Regex.match?(~r/^[A-Za-z]{2,20}$/, last_name)
        ]

        case list do
          [username: true, password: true, email: true, first_name: true, last_name: true] ->
            IO.inspect("Enters good case")

            {status, resp} =
              DBManager.add(:user,
                username: username,
                password: password,
                email: email,
                first_name: first_name,
                last_name: last_name
              )

            {status, resp}

          any ->
            IO.inspect("Enters bad case. - #{inspect(any)}")
            l = for {k, v} <- list, v == false, do: k
            {:error, Enum.at(l, 0)}
        end
      end

    json(conn, %{status: elem(resp, 0), response: elem(resp, 1)})
  end

  def login(conn, _params) do
    # render(conn, "login.html")

    check = Map.get(conn.private.plug_session, "username", :undefined)

    if check == :undefined do
      render(conn, "login.html")
    else
      # username = conn.private.plug_session["username"]
      # token = conn.private.plug_session["token"]

      redirect(conn, to: "/pet_management")
    end
  end

  def login_user(conn, params) do
    username = params["username"]
    password = params["password"]

    resp =
      if username == "" || password == "" do
        list = [username, password]

        case list do
          ["", ""] ->
            :both

          ["", _password] ->
            :username

          [_username, ""] ->
            :password
        end
      else
        {status, resp} =
          DBManager.authenticate(:user,
            username: username,
            password: password
          )

        case status do
          :ok ->
            %{token: Token.get_token(resp.username), username: resp.username}

          _ ->
            resp
        end
      end

    json(conn, %{response: resp})
  end

  def logout(conn, _params) do
    conn
    |> clear_session
    |> render("index.html")
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
