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
    users = Enum.reduce(1..5, [], fn(_i, acc) -> [Faker.Name.first_name() |> String.downcase() | acc] end)
    initial_scores = Enum.map(users, fn(user) ->
      %{"user" => user, "score" => 0}
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
      context.conn
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-github-event", event_type_1 |> to_string())
      |> post("/events/", event_1)
      context.conn
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-github-event", event_type_2 |> to_string())
      |> post("/events/", event_2)
      {[%{"user" => ^user, "score" => current_score}], rest} = Enum.split_with(acc, fn(i) -> i["user"] == user end)
      score = current_score + Scorer.score(event_type_1) + Scorer.score(event_type_2)
      [%{"user" => user, "score" => score} | rest]
    end)
    Map.merge(context, %{user_scores: user_scores, users: users})
  end

  describe "GET /events/scores" do
    setup :user_scores

    test "returns 200 status", %{conn: conn} do
      conn = get(conn, "/events/scores")
      assert conn.status == 200
    end

    test "returns the user scores as json", context do
      conn = get(context.conn, "/events/scores")
      assert conn.status == 200
      response = json_response(conn, 200)
      assert Enum.count(response["items"]) == Enum.count(context.user_scores)
      Enum.each(response["items"], fn(i) ->
        assert Enum.member?(context.user_scores, i)
      end)
    end
  end

  describe "GET /events/scores/:user" do
    setup :user_scores

    test "returns 200 status", %{conn: conn, users: users} do
      user = Enum.random(users)
      conn = get(conn, "/events/scores/#{user}")
      assert conn.status == 200
    end

    test "unknown users have score 0", context do
      conn = get(context.conn, "/events/scores/#{context.user}")
      assert json_response(conn, 200) == %{"user" => context.user, "score" => 0}
    end

    test "returns the user score as json", context do
      user = Enum.random(context.users)
      conn = get(context.conn, "/events/scores/#{user}")
      assert conn.status == 200
      expected_response = Enum.find(context.user_scores, fn(s) ->
        s["user"] == user
      end)
      assert json_response(conn, 200) == expected_response
    end
  end

  describe "POST /events/scores/reset" do
    setup :user_scores

    test "returns 204 status", %{conn: conn} do
      conn = conn
             |> put_req_header("content-type", "application/json")
             |> post("/events/scores/reset", "")
      assert conn.status == 204
    end

    test "clears scores", %{conn: conn} do
      refute Scorer.scores == %{}
      conn
      |> put_req_header("content-type", "application/json")
      |> post("/events/scores/reset", "")
      assert Scorer.scores == %{}
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
