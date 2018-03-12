defmodule Scorer.Sets do
  import EnvHelper

  app_env(:events, [:scorer, :events], ["push", "pull_request_review_comment", "watch", "create"])
end
