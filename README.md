# Sample Score App

This is a simple micro service which is deployed with Score (`score-compose` and `score-k8s`).

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/score-spec/sample-score-app)
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fscore-spec%2Fsample-score-app.svg?type=shield)](https://app.fossa.com/projects/git%2Bgithub.com%2Fscore-spec%2Fsample-score-app?ref=badge_shield)

## The Workload

The workload is a simple containerized NodeJS app talking to a PostreSQL database.

## Deploying

[Score](https://score.dev/) is used to deploy the workload locally with `score-compose` in Docker or with `score-k8s` in Kubernetes. See [Makefile](Makefile) for more details.

Locally:
```bash
make compose-up

make compose-test
```

In Kubernetes (`Kind`):
```bash
make kind-create-cluster

make kind-load-image

make k8s-up

make k8s-test
```

## License
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fscore-spec%2Fsample-score-app.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2Fscore-spec%2Fsample-score-app?ref=badge_large)