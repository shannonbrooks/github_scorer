defmodule GithubMockTest do
  use ExUnit.Case
  alias GithubMock.Fixtures.Events
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

  test "posts to the webhook url", context do
    url = context.url
    assert {^url, _body, _headers} = Test.Http.get_post_params()
  end

  test "sends random events periodically", context do
    events = context.events
    {_url, _body, headers} = Test.Http.get_post_params()
    event_type_1 = Map.get(headers, "X-GitHub-Event") |> String.to_atom
    assert Enum.member?(events, event_type_1)
    :timer.sleep(1000)
    {_url, _body, headers} = Test.Http.get_post_params()
    event_type_2 = Map.get(headers, "X-GitHub-Event") |> String.to_atom
    assert Enum.member?(events, event_type_2)
    assert event_type_1 != event_type_2
  end

  test "gets the correct event body for the event", context do
    users = context.users
    {_url, body, headers} = Test.Http.get_post_params()
    event_type = Map.get(headers, "X-GitHub-Event") |> String.to_atom
    event_payload = Poison.decode!(body)
    assert event_payload
           |> Map.keys()
           |> Enum.member?("sender")
    user = event_payload["sender"]["login"]
    assert Enum.member?(users, user)
    expected_event = get_event(event_type, user)
    assert event_payload == expected_event
  end

  def get_event(event_type, user) do
    case event_type do
      :installation -> Events.installation_event(user)
      :installation_repositories -> Events.installation_repositories_event(user)
      :push -> Events.push_event(user)
      :pull_request_review_comment -> Events.pull_request_review_comment_event(user)
      :watch -> Events.watch_event(user)
      :create -> Events.create_event(user)
    end
  end
end
