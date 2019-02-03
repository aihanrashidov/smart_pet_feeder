defmodule SmartPetFeederAppWeb.PageController do
  use SmartPetFeederAppWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
