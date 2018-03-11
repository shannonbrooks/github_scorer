defmodule ScorerWeb.EventsControllerTest do
  use ScorerWeb.ConnCase
  alias GithubMock.Fixtures.Events

  describe "POST /events/" do
    test "returns 204 status", %{conn: conn} do
      event = Events.get_event(:push, "shannon")
      headers = %{"Content-Type" => "application/json", "X-GitHub-Event" => "push"}
      conn = conn
             |> put_req_header("content-type", "application/json")
             |> put_req_header("x-github-event", "push")
             |> post("/events/", event)
      assert conn.status == 204
    end

    test "updates the user score", %{conn: conn} do

    end
  end
end
