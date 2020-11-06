#!/usr/bin/env bash
set -e
# Create a new comment in the given pull request.

PULL_REQUEST_ID=$1
COMMENT=$2
GITHUB_TOKEN=${3:-`cat ~/.github_token`}
LAMBDA_URL=${4:-"https://cn6abx7xxi.execute-api.eu-central-1.amazonaws.com/api"}

wget --quiet \
--method POST \
--header "content-type: application/json" \
--header "x-api-key: ${GITHUB_TOKEN}" \
--body-data "{\"comment\": \"${COMMENT}\"}" \
--output-document \
- ${LAMBDA_URL}/add-comment/${PULL_REQUEST_ID}