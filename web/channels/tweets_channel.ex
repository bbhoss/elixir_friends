defmodule ElixirFriends.TweetsChannel do
  use ElixirFriends.Web, :channel
  use ElixirFriends.Web, :view
  import RethinkDB.Query

  def join("tweets", payload, socket) do
    if authorized?(payload) do
      send self, :after_join
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info(:after_join, socket) do
    {:ok, sv} = Task.Supervisor.start_link(restart: :transient)
    Task.Supervisor.start_child sv, fn -> tweetstream(socket) end
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  defp tweetstream(socket) do
    import RethinkDB.Query
    require RethinkDB.Lambda
    import RethinkDB.Lambda
    db("elixirfriends")
      |> table("tweets")
      |> filter(lambda fn (tweet) ->
        tweet[:content] |> match("(?i)Chicago")
      end) |>
      changes |>
      ElixirFriends.Database.run |>
      Stream.take_every(1) |>
      Enum.each fn(change) ->
        %{"new_val" => post} = change
        html = Phoenix.View.render_to_string ElixirFriends.PostView, "_post.html", post: post
        push socket, "tweet", %{view: html}
      end
  end
end
