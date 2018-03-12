defmodule ScorerTest do
  use ExUnit.Case

  setup_all do
    score_map = %{
      :push => 5,
      :pull_request_review_comment => 4,
      :watch => 3,
      :create => 2,
      :other => 1
    }
    {:ok, %{score_map: score_map}}
  end

  test "cumulatively updates a user score", context do
    Scorer.start_link()
    user = Faker.Name.first_name() |> String.downcase()
    event_type_1 = context.score_map
                   |> Map.keys()
                   |> Enum.random()
    event_type_2 = context.score_map
                   |> Map.keys()
                   |> Enum.random()
    assert Scorer.user_score(user) == 0
    Scorer.update_score(user, event_type_1)
    assert Scorer.user_score(user) == context.score_map[event_type_1]
    Scorer.update_score(user, event_type_2)
    assert Scorer.user_score(user) == context.score_map[event_type_1] + context.score_map[event_type_2]
  end
end
