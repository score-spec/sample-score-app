include .env

score-compose:
	score-compose run \
		--build . \
		-f score.yaml \
		-o compose.yaml

compose-up:
	docker compose up -d

compose-down:
	docker compose down -v --remove-orphans

score-helm:
	score-helm run \
		-f score.yaml \
		-p containers.hello-world.image=sample-score-app-hello-world \
		-o values.yaml

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
	kubectl set env deployment hello-world DB_PASSWORD=${DB_PASSWORD} DB_USER=${DB_USERNAME} DB_DATABASE=${DB_NAME} DB_HOST=postgres

k8s-test:
	kubectl port-forward service/hello-world 8081:8080

k8s-down:
	kubectl delete deployment postgres \
		-n ${NAMESPACE}
	kubectl delete svc postgres \
		-n ${NAMESPACE}
	
	helm uninstall \
		-n ${NAMESPACE} \
		hello-world