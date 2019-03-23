defmodule SmartPetFeederAppWeb.Router do
  use SmartPetFeederAppWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", SmartPetFeederAppWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/feeder_management", PageController, :feeder_management)

    get("/login", SessionController, :login)
    post("/login_user", SessionController, :login_user)

    get("/register", SessionController, :register)
    post("/register_user", SessionController, :register_user)

    get("/logout", SessionController, :logout)

    post("/set_auth_configs", SessionController, :set_auth_configs)

    post("/add_feeder", PageController, :add_feeder)
    post("/delete_feeder", PageController, :delete_feeder)
    post("/update_feeder", PageController, :update_feeder)
    post("/get_feeders", PageController, :get_feeders)
  end

  # Other scopes may use custom stacks.
  # scope "/api", SmartPetFeederAppWeb do
  #   pipe_through :api
  # end
end
