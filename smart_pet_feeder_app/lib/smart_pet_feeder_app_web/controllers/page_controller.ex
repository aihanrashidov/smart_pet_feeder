defmodule SmartPetFeederAppWeb.PageController do
  use SmartPetFeederAppWeb, :controller

  alias SmartPetFeederApp.DBManager
  alias SmartPetFeederApp.Token

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def feeder_management(conn, _params) do
    username = conn.private.plug_session["username"]
    token = conn.private.plug_session["token"]

    render(conn, "feeder_management.html", username: username, token: token)
  end

  def add_feeder(conn, params) do
    username = params["username"]
    token = params["token"]
    serial = params["serial"]

    {_status, resp} = DBManager.get_user_id(:user, username: username)
    {_status, resp} = DBManager.add(:feeder, serial: serial, user_id: resp.user_id)

    json(conn, %{response: resp})
  end

  def update_feeder(conn, params) do
    username = params["username"]
    token = params["token"]
    feeder = params["feeder"]
    serial = params["serial"]

    {_status, resp} =
      DBManager.update(:feeder,
        feeder_id: String.to_integer(String.at(feeder, 4)),
        list: [serial: serial]
      )

    json(conn, %{response: resp})
  end

  def delete_feeder(conn, params) do
    username = params["username"]
    token = params["token"]
    feeder = params["feeder"]
    serial = params["serial"]

    {_status, resp} =
      DBManager.delete(:feeder,
        feeder_id: String.to_integer(String.at(feeder, 4))
      )

    json(conn, %{response: resp})
  end

  def get_feeders(conn, params) do
    username = params["username"]
    token = params["token"]

    {_status, resp} = DBManager.get_user_id(:user, username: username)
    {_status, resp} = DBManager.get(:feeder, user_id: resp.user_id)

    json(conn, %{response: resp})
  end
end
