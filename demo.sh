#!/bin/bash

# setup
if [ ! -f demo-magic.sh ]; then
    curl -LO https://github.com/paxtonhare/demo-magic/raw/master/demo-magic.sh
fi
. demo-magic.sh -d #-n
clear

# demo cleanup
rm score.yaml
score-compose init --no-sample
score-k8s init --no-sample
clear

# make compose-test
# make kind-create-cluster
# make kind-load-image
# make k8s-test

pe "echo \"Developers should not write either Docker Compose file or Kubernetes manifests, let me show you how!\""

pe "code index.js"

pe "code Dockerfile"

cat <<EOF > score.yaml
apiVersion: score.dev/v1b1
metadata:
  name: hello-world
containers:
  hello-world:
    image: .
EOF

pe "code score.yaml"

pe "score-compose generate score.yaml --build 'hello-world={\"context\":\".\",\"tags\":[hello-world:test]}'"

pe "code compose.yaml"

pe "docker compose up --build -d --remove-orphans"

pe "score-k8s generate score.yaml --image hello-world:test"

pe "code manifests.yaml"

pe "kubectl apply -f manifests.yaml"

pe "clear"

pe "echo \"Let's make it more real!\""
clear

pe "echo \"I want to expose my Workload and want to talk to a PostgreSQL database!\""
clear

cat <<EOF > score.yaml
apiVersion: score.dev/v1b1
metadata:
  name: hello-world
containers:
  hello-world:
    image: .
    variables:
      PORT: "3000"
      MESSAGE: "Hello, World!"
      DB_DATABASE: \${resources.db.name}
      DB_USER: \${resources.db.username}
      DB_PASSWORD: \${resources.db.password}
      DB_HOST: \${resources.db.host}
      DB_PORT: \${resources.db.port}
resources:
  db:
    type: postgres
  dns:
    type: dns
  route:
    type: route
    params:
      host: \${resources.dns.host}
      path: /
      port: 8080
service:
  ports:
    www:
      port: 8080
      targetPort: 3000
EOF

pe "code score.yaml"

pe "score-compose generate score.yaml --build 'hello-world={\"context\":\".\",\"tags\":[hello-world:test]}'"

pe "code compose.yaml"

pe "score-compose resources list"

pe "docker compose up --build -d --remove-orphans"

pe "docker ps"

pe "curl $(score-compose resources get-outputs dns.default#hello-world.dns --format '{{ .host }}:8080')"

pe "clear"

pe "code .score-compose/zz-default.provisioners.yaml"

pe "score-k8s generate score.yaml --image hello-world:test"

pe "code manifests.yaml"

pe "score-k8s resources list"

pe "kubectl apply -f manifests.yaml"

pe "kubectl get all"

pe "curl $(score-k8s resources get-outputs dns.default#hello-world.dns --format '{{ .host }}:8080')"

pe "clear"

pe "code .score-k8s/zz-default.provisioners.yaml"