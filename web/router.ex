defmodule ElixirFriends.Router do
  use ElixirFriends.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ElixirFriends do
    pipe_through :browser # Use the default browser stack

    get "/", PostController, :index
    resources "/posts", PostController, only: [:show]
  end

  socket "/ws", ElixirFriends do
    channel "tweets", TweetsChannel
  end

  # Other scopes may use custom stacks.
  # scope "/api", ElixirFriends do
  #   pipe_through :api
  # end
end
