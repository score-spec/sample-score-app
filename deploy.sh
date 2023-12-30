#!/usr/bin/env bash

score-humanitec delta \
    --env development \
    --app ${HUMANITEC_APP} \
    --org="${HUMANITEC_ORG}" \
    --token "${HUMANITEC_TOKEN}" \
    --deploy