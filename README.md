# GithubScorer

## About

GithubScorer is an umbrella app consisting of a mock Github Server which posts events to a configurable webhook url, and a Scorer app which tracks scores based on events received per user.

Events are scored as follows:

| Event Type | Points |
|------------|--------|
| PushEvent  | 5 |
| PullRequestReviewCommentEvent | 4 |
| WatchEvent | 3 |
| CreateEvent | 2 |
| All other events | 1 |

## Usage

    git clone https://github.com/shannonbrooks/github_scorer.git
    cd github_scorer
    mix deps.get

To run tests:

    mix test

To run server:

    mix phx.server

Available endpoints:

    GET http://localhost:11012/events/scores/ -- retrieves all user scores
    GET http://localhost:11012/events/scores/:user -- retrieves a single user's score, example: http://localhost:11012/events/scores/matt)
    POST http://localhost:11012/events/scores/reset -- resets all scores

