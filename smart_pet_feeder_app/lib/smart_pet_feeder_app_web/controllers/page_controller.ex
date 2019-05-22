defmodule SmartPetFeederAppWeb.PageController do
  use SmartPetFeederAppWeb, :controller

  alias SmartPetFeederApp.DBManager
  alias SmartPetFeederApp.Token

  def index(conn, _params) do
    check = Map.get(conn.private.plug_session, "username", :undefined)

    if check == :undefined do
      render(conn, "index.html")
    else
      username = conn.private.plug_session["username"]
      token = conn.private.plug_session["token"]

      render(conn, "pet_management.html", username: username, token: token)
    end
  end

  def pet_management(conn, _params) do
    check = Map.get(conn.private.plug_session, "username", :undefined)

    if check == :undefined do
      render(conn, "index.html")
    else
      username = conn.private.plug_session["username"]
      token = conn.private.plug_session["token"]

      render(conn, "pet_management.html", username: username, token: token)
    end
  end

  def add_pet(conn, params) do
    username = params["username"]
    token = params["token"]
    name = params["name"]
    age = params["age"]
    type = params["type"]
    gender = params["gender"]
    breed = params["breed"]

    {_status, resp} = DBManager.get_user_id(:user, username: username)

    {_status, resp} =
      DBManager.add(:pet,
        name: name,
        type: type,
        age: age,
        gender: gender,
        breed: breed,
        user_id: resp.user_id
      )

    json(conn, %{response: resp})
  end

  def update_pet(conn, params) do
    username = params["username"]
    token = params["token"]
    pet = params["pet"]
    name = params["name"]
    age = params["age"]
    type = params["type"]
    gender = params["gender"]
    breed = params["breed"]

    age =
      if age != "" do
        String.to_integer(params["age"])
      else
        age
      end

    list = [name: name, type: type, age: age, gender: gender, breed: breed]
    list = for {x, y} <- list, y != "", do: {x, y}

    [_x, y, _z] = String.split(pet, ":")
    [x, _y] = String.split(y, "|")
    pet = String.to_integer(x)

    {_status, resp} =
      DBManager.update(:pet,
        pet_id: pet,
        list: list
      )

    json(conn, %{response: resp})
  end

  def delete_pet(conn, params) do
    username = params["username"]
    token = params["token"]
    pet = params["pet"]
    name = params["name"]

    [_x, y, _z] = String.split(pet, ":")
    [x, _y] = String.split(y, "|")
    pet = String.to_integer(x)

    {_status, resp} =
      DBManager.delete(:pet,
        pet_id: pet
      )

    json(conn, %{response: resp})
  end

  def get_pets(conn, params) do
    username = params["username"]
    token = params["token"]

    {_status, resp} = DBManager.get_user_id(:user, username: username)
    {_status, resp} = DBManager.get(:pet, user_id: resp.user_id)

    json(conn, %{response: resp})
  end

  def feeder_management(conn, _params) do
    check = Map.get(conn.private.plug_session, "username", :undefined)

    if check == :undefined do
      render(conn, "index.html")
    else
      username = conn.private.plug_session["username"]
      token = conn.private.plug_session["token"]

      render(conn, "feeder_management.html", username: username, token: token)
    end
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

  def update_feeder_status(conn, params) do
    feeder_id = params["feeder"]
    top_water_sensor = params["top_water_sensor"]
    bottom_water_sensor = params["bottom_water_sensor"]

    {_status, resp} =
      case bottom_water_sensor do
        "NO" ->
          DBManager.update(:feeder,
            feeder_id: String.to_integer(feeder_id),
            list: [water_status: "No water."]
          )

        "YES" ->
          DBManager.update(:feeder,
            feeder_id: String.to_integer(feeder_id),
            list: [water_status: "Water level okay."]
          )
      end

    json(conn, %{response: resp})
  end

  def delete_feeder(conn, params) do
    username = params["username"]
    token = params["token"]
    feeder = params["feeder"]
    serial = params["serial"]

    [_x, y, _z] = String.split(feeder, ":")
    [x, _y] = String.split(y, "|")
    feeder = String.to_integer(x)

    {_status, resp} =
      DBManager.delete(:feeder,
        feeder_id: feeder
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
