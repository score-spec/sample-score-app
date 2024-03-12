include .env

score-compose:
	score-compose init
	score-compose generate score.yaml \
		--override-property containers.hello-world.variables.MESSAGE="Hello, Compose!"

compose-up:
	docker compose up -d

compose-test:
	curl localhost:3000

compose-down:
	docker compose down -v --remove-orphans

score-helm:
	score-helm run \
		-f score.yaml \
		-p containers.hello-world.image=sample-score-app-hello-world \
		-p containers.hello-world.variables.MESSAGE="Hello, Kubernetes!" \
		-p containers.hello-world.variables.DB_PASSWORD=${DB_PASSWORD} \
		-p containers.hello-world.variables.DB_USER=${DB_USERNAME} \
		-p containers.hello-world.variables.DB_DATABASE=${DB_NAME} \
		-p containers.hello-world.variables.DB_HOST=postgres \
		-o values.yaml

NAMESPACE ?= default
k8s-up:
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
		--set containers.hello-world.image.name=registry.humanitec.io/public/sample-score-app:latest

k8s-test:
	kubectl port-forward service/hello-world 8080:8080

k8s-down:
	kubectl delete deployment postgres \
		-n ${NAMESPACE}
	kubectl delete svc postgres \
		-n ${NAMESPACE}
	
	helm uninstall \
		-n ${NAMESPACE} \
		hello-world
