# Sample Score App

This is a simple micro service which is deployed with Score (`score-compose` and `score-helm`).

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/score-spec/sample-score-app)

## The Workload

The workload is a simple containerized NodeJS app which talking to a PostreSQL database.

## Deploying

[Score](https://score.dev/) is used to deploy the workload locally with `docker-compose` or to Kubernetes, see [Makefile](Makefile) for more details.
