defmodule GithubMockTest do
  use ExUnit.Case
  doctest GithubMock

  setup_all do
    users = Application.get_env(:github_mock, :users)
    events = Application.get_env(:github_mock, :events)
    url = Application.get_env(:github_mock, :webhook_url)
    on_exit fn ->
      Test.Http.clear()
    end
    {:ok, %{
      users: users,
      events: events,
      url: url
    }}
  end

  test "starts with users, events, and url from app config", context do
    {users, events, url} = {context.users, context.events, context.url}
    assert %{users: ^users, events: ^events, webhook_url: ^url} = GithubMock.state()
  end

  test "sends a random event for a user to the webhook url", context do
    {_users, events, url} = {context.users, context.events, context.url}
    assert {^url, _body, headers} = Test.Http.get_post_params()
    assert Enum.member?(events, Map.get(headers, "X-GitHub-Event") |> String.to_atom)
  end
end
