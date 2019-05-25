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
      render(conn, "login.html")
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

    resp =
      if name == "" || age == "" || type == "" || gender == "" || breed == "" do
        list = [name: name, age: age, type: type, gender: gender, breed: breed]

        case list do
          ["", "", "", "", ""] ->
            {:error, :all}

          _ ->
            l = for {k, v} <- list, v == "", do: k
            {:error, Enum.join(l, ", ")}
        end
      else
        {_status, resp} = DBManager.get_user_id(:user, username: username)

        {status, resp} =
          DBManager.add(:pet,
            name: name,
            type: type,
            age: age,
            gender: gender,
            breed: breed,
            user_id: resp.user_id
          )

        {status, resp}
      end

    json(conn, %{status: elem(resp, 0), response: elem(resp, 1)})
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

    resp =
      if pet == "" do
        {:error, :pet}
      else
        case [name, age, type, gender, breed] do
          ["", "", "", "", ""] ->
            {:error, :all}

          _ ->
            [pet_id, _rest] = String.split(pet, "|")
            [_rest, pet_id] = String.split(pet_id, ":")

            age =
              if age != "" do
                String.to_integer(params["age"])
              else
                age
              end

            list = [name: name, type: type, age: age, gender: gender, breed: breed]
            list = for {x, y} <- list, y != "", do: {x, y}

            {status, resp} =
              DBManager.update(:pet,
                pet_id: String.to_integer(pet_id),
                list: list
              )

            {status, resp}
        end
      end

    json(conn, %{status: elem(resp, 0), response: elem(resp, 1)})
  end

  def delete_pet(conn, params) do
    username = params["username"]
    token = params["token"]
    pet = params["pet"]

    resp =
      if pet == "" do
        {:error, :pet}
      else
        [pet_id, _rest] = String.split(pet, "|")
        [_rest, pet_id] = String.split(pet_id, ":")

        {status, resp} =
          DBManager.delete(:pet,
            pet_id: String.to_integer(pet_id)
          )

        {status, resp}
      end

    json(conn, %{status: elem(resp, 0), response: elem(resp, 1)})
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
      render(conn, "login.html")
    else
      username = conn.private.plug_session["username"]
      token = conn.private.plug_session["token"]

      render(conn, "feeder_management.html", username: username, token: token)
    end
  end

  def add_feeder(conn, params) do
    username = params["username"]
    token = params["token"]
    new_serial = params["serial"]
    location = params["location"]

    resp =
      if new_serial == "" || location == "" do
        list = [new_serial, location]

        case list do
          ["", ""] ->
            :both

          ["", _location] ->
            :new_serial

          [_new_serial, ""] ->
            :location
        end
      else
        {_status, usr_resp} = DBManager.get_user_id(:user, username: username)

        {_status, resp} = DBManager.get(:serial, [])
        IO.inspect(resp)

        serials = for ser <- resp, ser.serial == new_serial, do: ser

        case serials do
          [] ->
            "no_such_serial"

          [serial] ->
            {_status, resp} =
              DBManager.add(:feeder,
                serial: serial.serial,
                user_id: usr_resp.user_id,
                location: location
              )

            resp
        end
      end

    json(conn, %{response: resp})
  end

  def update_feeder(conn, params) do
    username = params["username"]
    token = params["token"]
    feeder = params["feeder"]
    location = params["location"]

    resp =
      if feeder == "" || location == "" do
        list = [feeder, location]

        case list do
          ["", ""] ->
            :both

          ["", _location] ->
            :feeder

          [_feeder, ""] ->
            :location
        end
      else
        [feeder_id, _rest] = String.split(feeder, "|")
        [_rest, feeder_id] = String.split(feeder_id, ":")

        {_status, resp} =
          DBManager.update(:feeder,
            feeder_id: String.to_integer(feeder_id),
            list: [location: location]
          )

        resp
      end

    json(conn, %{response: resp})
  end

  def update_feeder_status(conn, params) do
    feeder_id = params["feeder"]
    top_water_sensor = params["top_water_sensor"]
    bottom_water_sensor = params["bottom_water_sensor"]
    device_status = params["device_status"]

    {_status, resp} =
      case bottom_water_sensor do
        "NO" ->
          DBManager.update(:feeder,
            feeder_id: String.to_integer(feeder_id),
            list: [water_status: "No water", device_status: device_status]
          )

        "YES" ->
          DBManager.update(:feeder,
            feeder_id: String.to_integer(feeder_id),
            list: [water_status: "Water level okay", device_status: device_status]
          )

        "" ->
          {:init, :init}
      end

    json(conn, %{response: resp})
  end

  def update_feeder_dev_status(conn, params) do
    feeder_id = params["feeder"]
    device_status = params["device_status"]

    {_status, resp} =
      DBManager.update(:feeder,
        feeder_id: String.to_integer(feeder_id),
        list: [device_status: device_status]
      )

    json(conn, %{response: resp})
  end

  def delete_feeder(conn, params) do
    username = params["username"]
    token = params["token"]
    feeder = params["feeder"]

    resp =
      if feeder == "" do
        :feeder
      else
        [feeder_id, _rest] = String.split(feeder, "|")
        [_rest, feeder_id] = String.split(feeder_id, ":")

        {_status, resp} =
          DBManager.delete(:feeder,
            feeder_id: String.to_integer(feeder_id)
          )

        resp
      end

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
