defmodule ScorerWeb.EventsController do
  use ScorerWeb, :controller

  def process_event(conn, params) do
    conn
    |> send_resp(:no_content, "")
  end
end
