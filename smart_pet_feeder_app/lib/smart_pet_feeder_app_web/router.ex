defmodule SmartPetFeederAppWeb.Router do
  use SmartPetFeederAppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SmartPetFeederAppWeb do
    pipe_through :browser

    get "/", PageController, :index

    get "/login", SessionController, :login
    get "/register", SessionController, :register
    post "/logout", SessionController, :logout
    post "/set_auth_configs", SessionController, :set_auth_configs
    
  end

  # Other scopes may use custom stacks.
  # scope "/api", SmartPetFeederAppWeb do
  #   pipe_through :api
  # end
end
