# Disable all the default make stuff
MAKEFLAGS += --no-builtin-rules
.SUFFIXES:

## Display a list of the documented make targets
.PHONY: help
help:
	@echo Documented Make targets:
	@perl -e 'undef $$/; while (<>) { while ($$_ =~ /## (.*?)(?:\n# .*)*\n.PHONY:\s+(\S+).*/mg) { printf "\033[36m%-30s\033[0m %s\n", $$2, $$1 } }' $(MAKEFILE_LIST) | sort

.PHONY: .FORCE
.FORCE:

CONTAINER_NAME = hello-world
CONTAINER_IMAGE = ${CONTAINER_NAME}:test
WORKLOAD_NAME = hello-world

.score-compose/state.yaml:
	score-compose init \
		--no-sample \
		--patch-templates https://raw.githubusercontent.com/score-spec/community-patchers/refs/heads/main/score-compose/unprivileged.tpl

compose.yaml: score.yaml .score-compose/state.yaml Makefile
	score-compose generate score.yaml \
		--build '${CONTAINER_NAME}={"context":".","tags":["${CONTAINER_IMAGE}"]}' \
		--override-property containers.${CONTAINER_NAME}.variables.MESSAGE="Hello, Compose!"

## Generate a compose.yaml file from the score spec and launch it.
.PHONY: compose-up
compose-up: compose.yaml
	docker compose up --build -d --remove-orphans
	sleep 5

## Generate a compose.yaml file from the score spec, launch it and test (curl) the exposed container.
.PHONY: compose-test
compose-test: compose-up
	curl $$(score-compose resources get-outputs dns.default#${WORKLOAD_NAME}.dns --format '{{ .host }}:8080')

## Delete the containers running via compose down.
.PHONY: compose-down
compose-down:
	docker compose down -v --remove-orphans || true

.score-k8s/state.yaml:
	score-k8s init \
		--no-sample \
		--provisioners https://raw.githubusercontent.com/score-spec/community-provisioners/refs/heads/main/route/score-k8s/10-shared-gateway-httproute.provisioners.yaml \
		--patch-templates https://raw.githubusercontent.com/score-spec/community-patchers/refs/heads/main/score-k8s/unprivileged.tpl

manifests.yaml: score.yaml .score-k8s/state.yaml Makefile
	score-k8s generate score.yaml \
		--image ${CONTAINER_IMAGE} \
		--override-property containers.${CONTAINER_NAME}.variables.MESSAGE="Hello, Kubernetes!"

## Create a local Kind cluster.
.PHONY: kind-create-cluster
kind-create-cluster:
	./scripts/setup-kind-cluster.sh

## Load the local container image in the current Kind cluster.
.PHONY: kind-load-image
kind-load-image:
	kind load docker-image ${CONTAINER_IMAGE}

NAMESPACE ?= default
## Generate a manifests.yaml file from the score spec, deploy it to Kubernetes and wait for the Pods to be Ready.
.PHONY: k8s-up
k8s-up: manifests.yaml
	kubectl apply \
		-f manifests.yaml \
		-n ${NAMESPACE}
	kubectl wait deployments/${WORKLOAD_NAME} \
		-n ${NAMESPACE} \
		--for condition=Available
	kubectl wait pods \
		-n ${NAMESPACE} \
		-l app.kubernetes.io/name=${WORKLOAD_NAME} \
		--for condition=Ready \
		--timeout=90s

## Expose the container deployed in Kubernetes via port-forward.
.PHONY: k8s-test
k8s-test: k8s-up
	curl $$(score-k8s resources get-outputs dns.default#${WORKLOAD_NAME}.dns --format '{{ .host }}')

## Delete the deployment of the local container in Kubernetes.
.PHONY: k8s-down
k8s-down:
	kubectl delete \
		-f manifests.yaml \
		-n ${NAMESPACE}

## Generate catalog-info.yaml for Backstage.
.PHONY: generate-catalog-info
generate-catalog-info:
	score-k8s init \
		--no-sample \
		--patch-templates https://raw.githubusercontent.com/score-spec/community-patchers/refs/heads/main/score-k8s/backstage-catalog-entities.tpl
	score-k8s generate \
		--namespace sample-score-app \
		--generate-namespace \
		--image ghcr.io/score-spec/sample-score-app:latest \
		score.yaml \
		--output catalog-info.yaml
	sed 's,$$GITHUB_REPO,score-spec/sample-score-app,g' -i catalog-info.yaml
