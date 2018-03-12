defmodule ScorerWeb.EventsController do
  use ScorerWeb, :controller
  alias Scorer.Sets

  def process_event(conn, params) do
    with {:ok, user} <- user(params),
         {:ok, event_type} <- event_type(conn) do
      Scorer.update_score(user, event_type)
    end
    conn
    |> send_resp(:no_content, "")
  end

  def user_scores(conn, params) do
    conn
    |> put_status(:ok)
    |> json(%{})
  end

  defp user(params) do
    with {:ok, sender} <- Map.fetch(params, "sender"),
         {:ok, user} <- Map.fetch(sender, "login") do
           {:ok, user}
    else
      :error -> {:error, :no_user}
    end
  end

  defp event_type(conn) do
    with [event_header | _tail] <- get_req_header(conn, "x-github-event"),
         true <- Enum.member?(Sets.events, event_header) do
           {:ok, event_header |> String.to_atom}
    else
      [] -> {:error, :missing_event_header}
      false -> {:ok, :other}
    end
  end

end
