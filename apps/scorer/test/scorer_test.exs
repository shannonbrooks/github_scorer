defmodule ScorerTest do
  use ExUnit.Case

  setup do
    score_map = %{
      :push => 5,
      :pull_request_review_comment => 4,
      :watch => 3,
      :create => 2,
      :other => 1
    }
    users = Enum.reduce(1..5, [], fn(_i, acc) -> [Faker.Name.first_name() |> String.downcase() | acc] end)
    user = users |> Enum.random()
    event_type_1 = score_map
                   |> Map.keys()
                   |> Enum.random()
    event_type_2 = score_map
                   |> Map.keys()
                   |> Enum.random()
    on_exit fn -> Scorer.clear_scores() end
    {:ok,
      %{users: users,
        user: user,
        event_type_1: event_type_1,
        event_type_2: event_type_2,
        score_map: score_map}}
  end

  test "returns all user scores", context do
    user_scores = Enum.reduce(context.users, %{}, fn(u, acc) ->
      Scorer.update_score(u, context.event_type_1)
      Scorer.update_score(u, context.event_type_2)
      Map.merge(acc, %{u => context.score_map[context.event_type_1] + context.score_map[context.event_type_2]})
    end)
    assert Scorer.scores == user_scores
  end

  test "cumulatively updates a user score", context do
    assert Scorer.user_score(context.user) == 0
    Scorer.update_score(context.user, context.event_type_1)
    assert Scorer.user_score(context.user) == context.score_map[context.event_type_1]
    Scorer.update_score(context.user, context.event_type_2)
    assert Scorer.user_score(context.user) == context.score_map[context.event_type_1] + context.score_map[context.event_type_2]
  end
end
