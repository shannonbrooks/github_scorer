defmodule GithubMock.Sets do
  import EnvHelper

  app_env(:users, [:github_mock, :users], ["frank", "bob", "sue", "matt", "shannon", "adam"])
  app_env(:events, [:github_mock, :events], [:push_event, :pull_request_review_comment_event, :watch_event, :create_event, :other])
  app_env(:webhook_url, [:github_mock, :webhook_url], "localhost:11012/events/")
  app_env(:http, [:github_mock, :http], GithubMock.Clients.Http)
end
