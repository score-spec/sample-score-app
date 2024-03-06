include .env

score-compose:
	score-compose run \
		--build . \
		-f score.yaml \
		-p containers.hello-world.variables.MESSAGE="Hello, Compose!" \
		-o compose.yaml

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
		--set containers.hello-world.image.name=registry.humanitec.io/public/sample-score-app:latest \
		--set containers.hello-world.env.DB_PASSWORD=${DB_PASSWORD} \
		--set containers.hello-world.env.DB_DATABASE=${DB_NAME} \
		--set containers.hello-world.env.DB_HOST=postgres

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
