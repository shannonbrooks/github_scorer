defmodule GithubMock do
  @moduledoc """
  Documentation for GithubMock.
  """

  use GenServer
  alias GithubMock.Sets

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    send(self(), :send_event)
    {:ok, state}
  end

  def state() do
    GenServer.whereis(__MODULE__)
    |> GenServer.call(:get_state)
  end

  def handle_call(:get_state, _caller, state) do
    {:reply, state, state}
  end

  #select random user from state, select random event from state, send to endpoint, loop
  def handle_info(:send_event, state) do
    user = Enum.random(Sets.users)
    event_type = Enum.random(Sets.events)
    Sets.http.post(state.webhook_url, "", %{"X-GitHub-Event" => "#{event_type}"})

    {:noreply, state}
  end
end
