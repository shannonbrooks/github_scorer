defmodule ScorerWeb.EventsControllerTest do
  use ScorerWeb.ConnCase
  alias GithubMock.Fixtures.Events
  alias Scorer.Sets

  setup(context) do
    user = Faker.Name.first_name() |> String.downcase()
    on_exit fn -> Scorer.clear_scores() end
    {:ok, Map.merge(context, %{user: user})}
  end

  def user_scores(context) do
    users = Enum.reduce(1..5, [], fn(_i) -> Faker.Name.first_name() |> String.downcase() end)
    initial_scores = Enum.reduce(users, %{}, fn(user, acc) ->
      Map.put(acc, user, 0)
    end)
    user_scores = Enum.reduce(users, initial_scores, fn(user, acc) ->
      event_type_1 = Sets.events
                   |> Enum.random
                   |> String.to_atom
      event_type_2 = Sets.events
                   |> Enum.random
                   |> String.to_atom

      event_1 = Events.get_event(event_type_1, user)
      event_2 = Events.get_event(event_type_2, user)
      conn
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-github-event", event_type_1 |> to_string())
      |> post("/events/", event_1)
      conn
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-github-event", event_type_1 |> to_string())
      |> post("/events/", event_2)
      score = Map.get(acc, user) + Scorer.score(event_type_1) + Scorer.score(event_type_2)
      Map.put(acc, user, score)
    end)
    Map.merge(context, %{user_scores: user_scores})
  end

  describe "GET /events/scores" do
    setup [:user_scores]

    test "returns 200 status", %{conn: conn} do
      conn = get(conn, "/events/scores")
      assert conn.status == 200
    end

    test "returns the user scores as json", context do
      conn = get(context.conn, "/events/scores")
      assert json_response(conn, 200) == context.user_scores
    end
  end

  describe "POST /events/" do
    test "returns 204 status", %{conn: conn, user: user} do
      event = Events.get_event(:push, user)
      conn = conn
             |> put_req_header("content-type", "application/json")
             |> put_req_header("x-github-event", "push")
             |> post("/events/", event)
      assert conn.status == 204
    end

    test "updates the user score for known events", %{conn: conn, user: user} do
      event_type = Sets.events
                   |> Enum.random
                   |> String.to_atom

      event = Events.get_event(event_type, user)
      conn
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-github-event", event_type |> to_string())
      |> post("/events/", event)
      assert Scorer.user_score(user) == Scorer.score(event_type)
    end

    test "updates the user score for unknown events", %{conn: conn, user: user} do
      event_type = ["installation", "installation_repositories"]
                   |> Enum.random
                   |> String.to_atom

      event = Events.get_event(event_type, user)
      conn
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-github-event", event_type |> to_string())
      |> post("/events/", event)
      assert Scorer.user_score(user) == Scorer.score(event_type)
    end
  end

  test "no ops if gitub event header is missing", %{conn: conn, user: user} do
      event = Events.get_event(:push, user)
      conn = conn
             |> put_req_header("content-type", "application/json")
             |> post("/events/", event)
      assert conn.status == 204
  end
end
