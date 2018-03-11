defmodule ScorerWeb.PageController do
  use ScorerWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
