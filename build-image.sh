#!/usr/bin/env bash

docker build -t sample-score-app:latest --platform linux/amd64 .

docker push my-registry.example/sample-score-app:latest
