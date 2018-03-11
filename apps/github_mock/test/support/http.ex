defmodule Test.Http do
  use HTTPoison.Base

  def clear() do
    Stash.clear(:stubs)
  end

  def set_get_response(response) do
    Stash.set(:stubs, "Test.Http.get", response)
  end

  def get_get_params() do
    Stash.get(:stubs, "Test.Http.get.params")
  end

  def get(url, headers) do
    Stash.set(:stubs, "Test.Http.get.params", {url, headers})
    Stash.get(:stubs, "Test.Http.get")
  end

  def set_post_response(response) do
    Stash.set(:stubs, "Test.Http.post", response)
  end

  def get_post_params() do
    Stash.get(:stubs, "Test.Http.post.params")
  end

  def post(url, body, headers) do
    Stash.set(:stubs, "Test.Http.post.params", {url, body, headers})
    Stash.get(:stubs, "Test.Http.post")
  end
end
