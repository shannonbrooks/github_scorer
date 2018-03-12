defmodule GithubMock.Application do
  @moduledoc false

  use Application
  alias GithubMock.Sets

  def start(_type, _args) do
    children = [
      {GithubMock, %GithubMock{
        users: Sets.users,
        events: Sets.events,
        webhook_url: Sets.webhook_url}}
    ]

    opts = [strategy: :one_for_one, name: GithubMock.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
