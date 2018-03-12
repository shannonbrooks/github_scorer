# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :scorer,
  namespace: Scorer

config :scorer, events: ["push", "pull_request_review_comment", "watch", "create"]

# Configures the endpoint
config :scorer, ScorerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "t1ohnM298a+OhEzzrKgPIIbpjfjRq9vK2z6fsSSY7LKu/YtGZbu+Vomfgo/z/lYZ",
  render_errors: [view: ScorerWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Scorer.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
