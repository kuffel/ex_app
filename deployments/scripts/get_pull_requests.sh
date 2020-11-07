#!/usr/bin/env bash
set -e
# Returns information about all pull requests that are available in the GitHub Repo.

GITHUB_TOKEN=${1:-`cat ~/.github_token`}
# LAMBDA_URL=${2:-"https://cn6abx7xxi.execute-api.eu-central-1.amazonaws.com/api"}
LAMBDA_URL=${2:-"http://localhost:8000"}

wget --quiet \
--method GET \
--header "content-type: application/json" \
--header "x-api-key: ${GITHUB_TOKEN}" \
--output-document \
- ${LAMBDA_URL}/pull-requests