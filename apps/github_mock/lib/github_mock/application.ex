defmodule GithubMock.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {GithubMock, %GithubMock{
        users: Application.get_env(:github_mock, :users),
        events: Application.get_env(:github_mock, :events),
        webhook_url: Application.get_env(:github_mock, :webhook_url)}}
    ]

    opts = [strategy: :one_for_one, name: GithubMock.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
