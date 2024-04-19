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

include .env

CONTAINER_IMAGE = hello-world:test

compose.yaml: score.yaml
	score-compose init \
		--no-sample
	score-compose generate score.yaml \
		--build 'hello-world={"context":".","tags":["${CONTAINER_IMAGE}"]}' \
		--override-property containers.hello-world.variables.MESSAGE="Hello, Compose!"

## Generate a compose.yaml file from the score spec and launch it.
.PHONY: compose-up
compose-up: compose.yaml
	docker compose up --build -d --remove-orphans

## Generate a compose.yaml file from the score spec, launch it and test (curl) the exposed container.
.PHONY: compose-test
compose-test: compose-up
	sleep 5
	curl localhost:8080

## Delete the containers running via compose down.
.PHONY: compose-down
compose-down:
	docker compose down -v --remove-orphans || true

values.yaml: score.yaml
	score-helm run \
		-f score.yaml \
		-p containers.hello-world.image=${CONTAINER_IMAGE} \
		-p containers.hello-world.variables.MESSAGE="Hello, Kubernetes!" \
		-p containers.hello-world.variables.DB_PASSWORD=${DB_PASSWORD} \
		-p containers.hello-world.variables.DB_USER=${DB_USERNAME} \
		-p containers.hello-world.variables.DB_DATABASE=${DB_NAME} \
		-p containers.hello-world.variables.DB_HOST=postgres \
		-o values.yaml

## Load the local container image in the current Kind cluster.
.PHONY: kind-load-image
kind-load-image:
	kind load docker-image ${CONTAINER_IMAGE}

NAMESPACE ?= default
.PHONY: k8s-up
k8s-up: values.yaml
	$(MAKE) k8s-down || true
	$(MAKE) compose-down || true
	kubectl create deployment postgres \
		--image=postgres:alpine \
		-n ${NAMESPACE}
	kubectl set env deployment postgres POSTGRES_PASSWORD=${DB_PASSWORD} POSTGRES_USER=${DB_USERNAME} POSTGRES_DB=${DB_NAME}
	kubectl expose deployment postgres \
		--port 5432 \
		-n ${NAMESPACE}
	
	helm upgrade \
		-n ${NAMESPACE} \
		--install \
		--create-namespace \
		hello-world \
		--repo https://score-spec.github.io/score-helm-charts \
		workload \
		--values values.yaml \
		--set containers.hello-world.image.name=${CONTAINER_IMAGE}

## Expose the container deployed in Kubernetes via port-forward.
.PHONY: k8s-test
k8s-test: k8s-up
	kubectl wait pods \
		-n ${NAMESPACE} \
		-l app.kubernetes.io/name=hello-world \
		--for condition=Ready \
		--timeout=90s
	kubectl port-forward \
		-n ${NAMESPACE} \
		service/hello-world \
		8080:8080

## Delete the the deployment of the local container in Kubernetes.
.PHONY: k8s-down
k8s-down:
	kubectl delete deployment postgres \
		-n ${NAMESPACE}
	kubectl delete svc postgres \
		-n ${NAMESPACE}
	
	helm uninstall \
		-n ${NAMESPACE} \
		hello-world
