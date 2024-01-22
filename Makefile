score-compose:
	score-compose run \
		--build . \
		-f score.yaml \
		-o compose.yaml

compose-up:
	docker compose up -d

compose-down:
	docker compose down -v --remove-orphans

score-humanitec:
	score-humanitec delta \
		--env development \
		--app ${HUMANITEC_APP} \
		--org="${HUMANITEC_ORG}" \
		--token "${HUMANITEC_TOKEN}" \
		-f score.yaml \
		--extensions humanitec.score.yaml \
		--deploy