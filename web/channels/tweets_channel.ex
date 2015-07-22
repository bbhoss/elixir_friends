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
    spawn fn ->
      q = db("elixirfriends")
        |> table("tweets")
        |> changes
        |> ElixirFriends.Database.run 
      q |> Stream.chunk(1) |> Enum.each fn(change) ->
        %{"new_val" => post} = hd change
        html = Phoenix.View.render_to_string ElixirFriends.PostView, "_post.html", post: post
        push socket, "tweet", %{view: html}
     end
    end
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
