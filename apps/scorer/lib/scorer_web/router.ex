defmodule ScorerWeb.Router do
  use ScorerWeb, :router

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

  scope "/", ScorerWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  #Other scopes may use custom stacks.
  scope "/events", ScorerWeb do
    pipe_through :api

    post "/", EventsController, :process_event
    get "/scores", EventsController, :user_scores
  end
end
