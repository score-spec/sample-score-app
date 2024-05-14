# Sample Score App

This is a simple micro service which is deployed with Score (`score-compose` and `score-k8s`).

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/score-spec/sample-score-app)

## The Workload

The workload is a simple containerized NodeJS app talking to a PostreSQL database.

## Deploying

[Score](https://score.dev/) is used to deploy the workload locally with `score-compose` in Docker or with `score-k8s` in Kubernetes. See [Makefile](Makefile) for more details.

Locally:
```bash
make compose-test
```

In Kubernetes (`Kind`):
```bash
kind create cluster
kubectl apply \
    -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml
helm install ngf oci://ghcr.io/nginxinc/charts/nginx-gateway-fabric \
    --create-namespace \
    -n nginx-gateway \
    --set service.type=ClusterIP
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
name: default
spec:
gatewayClassName: nginx
listeners:
- name: http
    port: 80
    protocol: HTTP
EOF

make kind-load-image

make k8s-up
```