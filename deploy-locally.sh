#!/usr/bin/env bash

score-compose run \
    -f score.yaml \
    -o workload-compose.yaml

cat <<EOF > postgres.yaml
services:
  database:
    environment:
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_USER: ${DB_USERNAME}
      POSTGRES_DB: ${DB_NAME}
    image: postgres:latest
EOF

cat <<EOF > .env
DB_HOST=database
DB_NAME=database
DB_PASSWORD=super-password
DB_PORT=5432
DB_USERNAME=postgres
EOF

docker compose \
    -f workload-compose.yaml \
    -f postgres.yaml \
    up \
    -d \
    --wait \
    --wait-timeout 30