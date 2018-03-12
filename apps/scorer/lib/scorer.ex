defmodule Scorer do
  @moduledoc """
  Scorer keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  use Agent

  def start_link() do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def update_score(user, event_type) do
    Agent.update(__MODULE__, fn(state) ->
      with {:ok, current_score} <- Map.fetch(state, user) do
        Map.put(state, user, current_score + score(event_type))
      else
        _ -> Map.put(state, user, score(event_type))
      end
    end)
  end

  def user_score(user) do
    Agent.get(__MODULE__, fn(state) ->
      with {:ok, current_score} <- Map.fetch(state, user) do
        current_score
      else
        _ -> 0
      end
    end)
  end

  def scores() do
    Agent.get(__MODULE__, fn(state) ->
      state
    end)
  end

  def clear_scores() do
    Agent.update(__MODULE__, fn(state) ->
      %{}
    end)
  end

  def score(:push), do: 5
  def score(:pull_request_review_comment), do: 4
  def score(:watch), do: 3
  def score(:create), do: 2
  def score(_), do: 1
end
